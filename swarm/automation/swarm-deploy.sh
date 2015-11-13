###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com
#    November 2015
#
###############################################################################
 

#--------------------------------------
function InitVars {
  export consul=dewdftzws023.dhcp.pgdev.sap.corp
  export manager=$consul
  export node01=dewdftv00249.dhcp.pgdev.sap.corp
  export port=2375
  export managerport=4243
  export token=MyCluster; }


#--------------------------------------
function Deploy-Consul {

  ID=$(docker -H $1:$2 run -d -p 8400:8400 -p 8500:8500 -p 8600:53/udp -h consul progrium/consul -server -bootstrap -ui-dir /ui)

  if [ $? -ne 0  ]; then
    echo "Failed to start Consul container"
    exit 1; fi

  loop=1
  while [ $loop -eq 1 ]; do 
    sleep 10
    docker -H $1:$2 logs $ID | grep "New leader elected"
    loop=$?
  done; }


#--------------------------------------
function Deploy-Nodes {

  docker -H $1:$2 run -d swarm join --advertise=$3:$2 consul://$4:8500/$5

  if [ $? -ne 0  ]; then
    echo "Failed to start Swarm join container"
    exit 1; fi; }


#--------------------------------------
function Deploy-Manager {

  docker -H $1:$2 run -d -p $managerport:$2 swarm manage consul://$3:8500/$4

  if [ $? -ne 0  ]; then
    echo "Failed to start Swarm Manager container"
    exit 1; fi; }


#---------------  MAIN
clear
set -x

InitVars

Deploy-Consul  $consul  $port
Deploy-Nodes   $node01  $port $node01 $consul $token
Deploy-Manager $manager $port $consul $token
