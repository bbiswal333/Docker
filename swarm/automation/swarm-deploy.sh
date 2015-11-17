###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com	-November 2015- 
#  PURPOSE: deploy a Swarm cluster
#
###############################################################################
 

#--------------------------------------
function InitVars {
  dockerports=(2375 2376)

  export consul=dewdftzws023.dhcp.pgdev.sap.corp
  export manager=$consul
  export nodes="dewdftv00249.dhcp.pgdev.sap.corp"
  export token=MyCluster
  export tls=0
  export port=${dockerports[tls]}
  export managerport=4243
  export AuroraImg=dockerdevregistry:5000/aurora/aurora42_1781; }


#--------------------------------------
function Deploy-Consul {

  ID=$(docker -H $1:$2 run -d -p 8400:8400 -p 8500:8500 -p 8600:53/udp -h consul progrium/consul -server -bootstrap -ui-dir /ui)

  if [ $? -ne 0  ]; then
    echo "Failed to start Consul container on '$1'"
    exit 1; fi

  status=1
  count=1

  while [ $status -ne 0 ] && [ $count -le 10 ]; do 
    sleep 2
    docker -H $1:$2 logs $ID 2>&1 | grep "New leader elected"
    status=$?
    count=$((count+1)); done 

  if [ $status -ne 0 ]; then
    echo "Timeout waiting for Consul server starting on '$1'"
    exit 1; fi; }


#--------------------------------------
function Deploy-Nodes {	   # nodes,$port,$consul,$token

  arr=$(echo $1 | tr -d  " ")		# remove blanks
  arr=$(echo $1 | tr "," "\n")		# split to array

  for nd in $arr; do
    docker -H $nd:$2 run -d swarm join --advertise=$nd:$2 consul://$3:8500/$4
    if [ $? -ne 0  ]; then
      echo "Failed to start 'Swarm-Join' container on '$nd'"
      exit 1; fi; done; }


#--------------------------------------
function Deploy-Manager {

  ID=$(docker -H $1:$2 run -d -p $managerport:$2 swarm manage consul://$3:8500/$4)

  if [ $? -ne 0  ]; then
    echo "Failed to start 'Swarm-Manager' container on '$1'"
    exit 1; fi

  status=1
  count=1

  while [ $status -ne 0 ] && [ $count -le 10 ]; do
    sleep 2
    docker -H $1:$2 logs $ID 2>&1 | grep "Registered Engine"
    status=$?
    count=$((count+1)); done

  if [ $status -ne 0 ]; then
    echo "Timeout waiting for Swarm-Manager starting on '$1'"
    exit 1; fi; }


#--------------------------------------
function Deploy-Aurora {

  docker -H $1:$2 run -d --privileged --net=host $3  /bin/sh -c "/mnt/startAurora.sh"

  if [ $? -ne 0  ]; then
    echo "Failed to start '$3' container on '$1'"
    exit 1; fi; }


#---------------  MAIN
clear
set -x

InitVars

Deploy-Consul  $consul   $port
Deploy-Nodes   "$nodes"  $port  $consul $token
Deploy-Manager $manager  $port  $consul $token

Deploy-Aurora  $manager  $managerport  $AuroraImg

