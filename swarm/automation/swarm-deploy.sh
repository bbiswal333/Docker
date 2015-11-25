###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com	- November 2015 - 
#  PURPOSE: set up a Swarm cluster
#
###############################################################################


#--------------------------------------
function TestFileExists {

  if [ ! -f $1 ]; then
    echo "File '$1' not found"
    exit 1; fi; }


#--------------------------------------
function CheckRequest {

  echo ". Check request"

  mandatory="consuls managers nodes token tls"

  for keyword in $mandatory; do
    eval "var=\"\$$keyword\""
    if [ ! "${var}" ]; then
      echo "  Keyword '$keyword' missing in '$1'"
      exit 1; fi
  done; }


#--------------------------------------
function CheckClusterConsul {

  array=($(echo $1 | tr "," " "))

  if [ ${#array[@]} -eq 2 ]; then
    echo "  A Consul cluster requires at least 3 instances"
    exit 1; fi; }


#--------------------------------------
function CheckClusterManager {

  array=($(echo $1 | tr "," " "))

  if [ ${#array[@]} -eq 2 ]; then
    echo "  A Swarm-Manager cluster requires at least 3 instances"
    exit 1; fi; }


#--------------------------------------
function ReadRequestFile {

  echo
  echo ". Read request file"

  scriptpath=$(dirname $(readlink -e $0))
  pathname="$scriptpath/swarm-request.ini"

  TestFileExists "$pathname"
  source "$pathname"
  CheckRequest "$pathname"

  CheckClusterConsul  "$consuls"
  CheckClusterManager "$managers"

  dockerports=(2375 2376)
  tls=0		# overrides 'swarm-request.ini' until TLS implemented

  export port=${dockerports[tls]}
  export managerport=4243; }


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
function WaitForMembers {	# host, port, ID, nb

  nb=0
  count=0

  while [ $nb -ne $4 ] && [ $count -le 20 ]; do
    sleep 4
    members=$(docker -H $1:$2 exec $3 consul members)
    nb=$(grep -o "alive" <<< "$members" | wc -l)
    count=$((count+1)); done

  if [ $nb -ne $4 ]; then
    return 1; fi

  return 0; }


function Deploy-Consul {	# consuls, port

  echo
  echo ". start Consul"

  arrConsuls=($(echo $1 | tr "," " "))
  consul01=${arrConsuls[0]}

  echo "    start Consul on '$consul01'"
  ID01=$(docker -H $consul01:$2 run -d --net=host progrium/consul -server -bootstrap -ui-dir /ui)
  OnStatusFailed $?  "Failed to start Consul Bootstrap Server on '$consul01'"

  WaitForStart $consul01 $2 $ID01 "New leader elected"
  OnStatusFailed $? "Timeout waiting for Consul Bootstrap Server starting on '$consul01'"

  # SIMPLE CONFIGURATION
  if [ ${#arrConsuls[@]} -eq 1 ]; then
    return 0; fi

  # CLUSTER CONFIGURATION
  for consul in ${arrConsuls[@]}; do

    if [ $consul != $consul01 ]; then

      echo "    start Consul on '$consul'"
      ID=$(docker -H $consul:$2 run -d --net=host progrium/consul -server -ui-dir /ui)
      OnStatusFailed $? "Failed to start Consul Simple Server on '$consul'"

      WaitForStart $consul $2 $ID "Aborting election"
      OnStatusFailed $? "Timeout waiting for Consul Simple Server starting on '$consul'"

      ToJoin="$ToJoin $consul "; fi; done

  echo "    gather ${#arrConsuls[@]} servers in a cluster"
  str=$(docker -H $consul01:$2 exec $ID01 consul join $ToJoin)
  OnStatusFailed $? "Failed to join '$ToJoin' as Consul cluster members on '$consul01'"

  echo "    stop and delete bootstrap"
# str=$(docker -H $consul01:$2 exec $ID01 consul leave)		#  NEVER DO THAT, any leave is definitive!!
  str=$(docker -H $consul01:$2 rm -f -v $ID01)
  OnStatusFailed $? "Failed to delete Bootstrap Server on '$consul01'"

  echo "    restart bootstrap as simple server"
  ID01=$(docker -H $consul01:$2 run -d --net=host progrium/consul -server -ui-dir /ui)
  OnStatusFailed $?  "Failed to restart Bootstrap Server as simple server on '$consul01'"

  echo "    wait for bootstrap to re-join the cluster as simple server"
  WaitForMembers $consul01 $2 $ID01 ${#arrConsuls[@]}
  OnStatusFailed $? "Failed to gather servers in a cluster"; }


#--------------------------------------
function Deploy-Nodes {	   # nodes, port, consul, token

  echo
  echo ". Start nodes"

  arrConsuls=($(echo $3 | tr "," " "))
  arrNodes=$(echo $1 | tr "," " ")

  consul01=${arrConsuls[0]}

  for node in $arrNodes; do

    echo "    start node on '$node'"
    ID=$(docker -H $node:$2 run -d swarm join --advertise=$node:$2 consul://$consul01:8500/$4)
    OnStatusFailed $?  "Failed to start 'Swarm-Join' container on '$node'"; done; }


#--------------------------------------
function Deploy-Manager {	# managers, port, consuls, token

  echo
  echo ". Start managers"

  arrManagers=($(echo $1 | tr "," " "))
  arrConsuls=($(echo $3 | tr "," " "))

  consul01=${arrConsuls[0]}

  for manager in ${arrManagers[@]}; do

    if [ ${#arrManagers[@]} -gt 1 ]; then
      replication="--replication --advertise $manager:$managerport"; fi

    echo "    Start manager on '$manager'"
    ID=$(docker -H $manager:$2 run -d -p $managerport:$managerport swarm manage -H :$managerport $replication consul://$consul01:8500/$4)
    OnStatusFailed $?  "Failed to start Swarm-Manager container on '$manager'"

    if [ ${#arrManagers[@]} -eq 1 ]; then
      WaitForStart $manager $2 $ID "Registered Engine"
      OnStatusFailed $?  "Timeout waiting for Swarm-Manager starting on '$manager'"
    else
      WaitForStart $manager $2 $ID "Cluster leadership lost"
      OnStatusFailed $?  "Timeout waiting for gathering servers in a cluster"; fi

  done; }


#--------------------------------------
function Deploy-Image {

  if [ ! ${3} ]; then
    return 0; fi

  echo
  echo ". Start image instance"

  echo "    start image '$3'"
  docker -H $1:$2 run -d --privileged --net=host $3  /bin/sh -c "/mnt/startAurora.sh"
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

  arrManagers=($(echo $1 | tr "," " "))
  manager=${arrManagers[0]}

  docker -H $manager:$2 info; }


#---------------  MAIN
clear
# set -x

ReadRequestFile

Deploy-Consul  "$consuls"   $port
Deploy-Nodes   "$nodes"     $port  "$consuls" $token
Deploy-Manager "$managers"  $port  "$consuls" $token

Deploy-Image   "$managers"  $managerport      $image
OnDeployed     "$managers"  $managerport
