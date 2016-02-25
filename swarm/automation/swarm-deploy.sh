#!/bin/bash

###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com	- November 2015 - 
#  PURPOSE: set up a Swarm cluster
#
###############################################################################


#--------------------------------------
function InitLocation {

  location=$(dirname $(readlink -e $0))
  cd $location; }


#--------------------------------------
function InitVars {

  export request="../swarm-request.ini"
  export log="swarm-deploy.log"; }


#--------------------------------------
function InitLog {
  if [ -f $log ]; then
    rm -f $log; fi; }


#--------------------------------------
function writelog { printf "$1" >> $log; }


#--------------------------------------
function TestFileExists {

  if [ ! -f $1 ]; then
    echo "File '$1' not found"
    exit 1; fi; }


#--------------------------------------
function CheckRequest {

  echo ". Check request"

  mandatory="zookeepers managers nodes token tls engineport managerport"

  for keyword in $mandatory; do
    eval "var=\"\$$keyword\""
    if [ ! "${var}" ]; then
      echo "  Keyword '$keyword' missing in '$1'"
      exit 1; fi
  done; }


#--------------------------------------
function CheckClusterZookeepers {

  array=($1)

  if [ ${#array[@]} -eq 2 ]; then
    echo "  A Zookeeper cluster requires at least 3 instances"
    exit 1; fi; }


#--------------------------------------
function CheckClusterManagers {

  array=($1)

  if [ ${#array[@]} -eq 2 ]; then
    echo "  A Swarm-Manager cluster requires at least 3 instances"
    exit 1; fi; }


#--------------------------------------
function ReadRequestFile {

  echo
  echo ". Read request file"

  TestFileExists "$request"
  source "$request"
  CheckRequest "$request"

  CheckClusterZookeepers "$zookeepers"
  CheckClusterManagers   "$managers"

  tls=0                 # overrides 'swarm-request.ini' until TLS implemented

  dockerports=(2375 2376)
  export engineport=${dockerports[tls]}; }


#--------------------------------------
function WaitForStart {        # host, port, ID, search

  status=1
  count=1

  while [ $status -ne 0 ] && [ $count -le 10 ]; do
    sleep 2
    str=$(docker -H $1:$2 logs $3 2>&1 | grep "$4")
    status=$?
    count=$((count+1)); done

  return $status; }


#--------------------------------------
function OnStatusFailed {	# status, errmsg
  if [ $1 -ne 0  ]; then
    echo
    echo
    echo "    *****  $2  *****"
    echo
    exit 1; fi; }


#--------------------------------------
#function WaitForMembers {	# host, port, ID, nb

#  nb=0
#  count=0

#  while [ $nb -ne $4 ] && [ $count -le 20 ]; do
#    sleep 4
#    members=$(docker -H $1:$2 exec $3 consul members)
#    nb=$(grep -o "alive" <<< "$members" | wc -l)
#    count=$((count+1)); done

#  if [ $nb -ne $4 ]; then
#    return 1; fi

#  return 0; }


#function Deploy-Consul {	# consuls, port

#  echo
#  echo ". start Consul"

#  arrConsuls=($(echo $1 | tr "," " "))
#  consul01=${arrConsuls[0]}

#  if [ ${#arrConsuls[@]} -eq 1 ]; then
#    restart=--restart=always; fi

#  echo "    start Consul on '$consul01'"
#  ID01=$(docker -H $consul01:$2 run -d $restart  --net=host progrium/consul -server -bootstrap -ui-dir /ui)
#  OnStatusFailed $?  "Failed to start Consul Bootstrap Server on '$consul01'"

#  WaitForStart $consul01 $2 $ID01 "New leader elected"
#  OnStatusFailed $? "Timeout waiting for Consul Bootstrap Server starting on '$consul01'"

#  # SIMPLE CONFIGURATION
#  if [ ${#arrConsuls[@]} -eq 1 ]; then
#    return 0; fi

#  # CLUSTER CONFIGURATION
#  for consul in ${arrConsuls[@]}; do

#    if [ $consul != $consul01 ]; then

#      echo "    start Consul on '$consul'"
#      ID=$(docker -H $consul:$2 run -d --net=host --restart=always progrium/consul -server -ui-dir /ui)
#      OnStatusFailed $? "Failed to start Consul Simple Server on '$consul'"

#      WaitForStart $consul $2 $ID "Aborting election"
#      OnStatusFailed $? "Timeout waiting for Consul Simple Server starting on '$consul'"

#      ToJoin="$ToJoin $consul "; fi; done

#  echo "    gather ${#arrConsuls[@]} servers in a cluster"
#  str=$(docker -H $consul01:$2 exec $ID01 consul join $ToJoin)
#  OnStatusFailed $? "Failed to join '$ToJoin' as Consul cluster members on '$consul01'"

#  echo "    stop and delete bootstrap"
## str=$(docker -H $consul01:$2 exec $ID01 consul leave)		#  NEVER DO THAT, any leave is definitive!!
#  str=$(docker -H $consul01:$2 rm -f -v $ID01)
#  OnStatusFailed $? "Failed to delete Bootstrap Server on '$consul01'"

#  echo "    restart bootstrap as simple server"
#  ID01=$(docker -H $consul01:$2 run -d --net=host --restart=always progrium/consul -server -ui-dir /ui)
#  OnStatusFailed $?  "Failed to restart Bootstrap Server as simple server on '$consul01'"

#  echo "    wait for bootstrap to re-join the cluster as simple server"
#  WaitForMembers $consul01 $2 $ID01 ${#arrConsuls[@]}
#  OnStatusFailed $? "Failed to gather servers in a cluster"; }


#--------------------------------------
function Deploy-Zookeepers {    # zookeepers, engineport

  echo
  echo ". Start Zookeepers"

  writelog "\nStart Zookeepers\n"

  arrZookeepers=(${1//,/ })		# "dewdftv00249  dewdftv00765  dewdftv00766"
  serversZK=${1// /}			# "dewdftv00249,dewdftv00765,dewdftv00766"

  myid=1

  for zk in ${arrZookeepers[@]}; do

    if [ ${#arrZookeepers[@]} -gt 1 ]; then
      clustering="-e MYID=$myid -e SERVERS=$serversZK"; fi

    echo "    start Zookeeper on '$zk'"
    writelog "  docker -H $zk:$2 run -d --restart=always --net=host $clustering mesoscloud/zookeeper:3.4.6-ubuntu-14.04\n"

    ID=$(docker -H $zk:$2 run -d --restart=always --net=host $clustering mesoscloud/zookeeper:3.4.6-ubuntu-14.04)
    OnStatusFailed $?  "Failed to start 'Zookeeper'  on '$zk'"

    WaitForStart $zk $2 $ID "binding to port"
    OnStatusFailed $? "Timeout waiting for Zookeeper server starting on '$zk'"

    myid=$((myid+1)); done; }


#--------------------------------------
function GetZooEndPoint {

  if [ "${zooLB}" ]; then
    ZooEndPoint=$zooLB
  else
    ZooEndPoint=${1// /}; fi		# "dewdftv00249,dewdftv00765,dewdftv00766"

  echo "$ZooEndPoint"; }


#--------------------------------------
function Deploy-Nodes {	   # nodes, engineport, zookeepers, token

  echo
  echo ". Start nodes"

  writelog "\nStart nodes\n"

  arrNodes=${1//,/ }
# arrConsuls=($(echo $3 | tr "," " "))
  ZooEndPoint=$(GetZooEndPoint "$3")

# consul01=${arrConsuls[0]}

  for node in $arrNodes; do

    echo "    start node on '$node'"
    writelog "  docker -H $node:$2 run -d --restart=always swarm join --advertise=$node:$2 zk://$ZooEndPoint/$4\n"

#   ID=$(docker -H $node:$2 run -d --restart=always swarm join --advertise=$node:$2 consul://$consul01:8500/$4)
    ID=$(docker -H $node:$2 run -d --restart=always swarm join --advertise=$node:$2 zk://$ZooEndPoint/$4)
    OnStatusFailed $?  "Failed to start 'Swarm-Join' container on '$node'"; done; }


#--------------------------------------
function Deploy-Managers {	# managers, engineport, managerport, zookeepers, token

  echo
  echo ". Start managers"

  writelog "\nStart managers\n"

  arrManagers=(${1//,/ })
# arrConsuls=($(echo $3 | tr "," " "))
  ZooEndPoint=$(GetZooEndPoint "$4")

# consul01=${arrConsuls[0]}

  for manager in ${arrManagers[@]}; do

    if [ ${#arrManagers[@]} -gt 1 ]; then
      replication="--replication --advertise $manager:$3"; fi

    echo "    Start manager on '$manager'"
    writelog "  docker -H $manager:$2 run -d --restart=always -p $3:$3 swarm manage -H :$3 $replication zk://$ZooEndPoint/$5\n"

#   ID=$(docker -H $manager:$2 run -d --restart=always -p $3:$3 swarm manage -H :$3 $replication consul://$consul01:8500/$4)
    ID=$(docker -H $manager:$2 run -d --restart=always -p $3:$3 swarm manage -H :$3 $replication zk://$ZooEndPoint/$5)
    OnStatusFailed $?  "Failed to start Swarm-Manager container on '$manager'"

    if [ ${#arrManagers[@]} -eq 1 ]; then
      WaitForStart $manager $2 $ID "Registered Engine"
      OnStatusFailed $?  "Timeout waiting for Swarm-Manager starting on '$manager'"
    else
      WaitForStart $manager $2 $ID "Cluster leadership lost"
      OnStatusFailed $?  "Timeout waiting for gathering servers in a cluster"; fi

  done; }


#--------------------------------------
function Deploy-Images {	# managers, managerport, image

  if [ ! ${3} ]; then
    return 0; fi

  echo
  echo ". Start image instance"

  writelog "\nStart images\n"

  arrManagers=(${1//,/ })
  manager=${arrManagers[0]}

  echo "    start image '$3'"
  writelog "  docker -H $manager:$2 run -d --privileged --net=host $3  /bin/sh -c \"/mnt/startAurora.sh\"\n"

  docker -H $manager:$2 run -d --privileged --net=host $3  /bin/sh -c "/mnt/startAurora.sh"
  OnStatusFailed $? "Failed to start '$3' container on '$1'"; }


#--------------------------------------
function OnDeployed {		# managers, managerport

  echo
  echo
  echo "*******************************************"
  echo "*   Swarm cluster successfully deployed   *"
  echo "*******************************************"
  echo
  echo

  if [ ! "${managerLB}" ]; then
    msg="No Sw-Balancer defined, command will be run on the first Sw-Manager"
    echo $msg
    writelog "\n\n$msg\n"
    arrManagers=(${1//,/ })
    balancer=${arrManagers[0]}
  else
    msg="Sw-Balancer defined, command will be run on the Sw-Balancer"
    echo $msg
    writelog "\n\n$msg\n"
    balancer=$managerLB; fi

  msg="COMMAND: docker -H $balancer:$2 info"
  echo
  echo $msg
  echo
  echo
  writelog "\n$msg\n"

  docker -H $balancer:$2 info; }


#---------------  MAIN
clear
# set -x

InitLocation
InitVars
InitLog

ReadRequestFile

Deploy-Zookeepers "$zookeepers" $engineport
Deploy-Nodes      "$nodes"      $engineport   "$zookeepers" $token
Deploy-Managers   "$managers"   $engineport   $managerport "$zookeepers" $token

Deploy-Images     "$managers"   $managerport  $image
OnDeployed        "$managers"   $managerport
