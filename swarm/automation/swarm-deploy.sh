###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com	-November 2015- 
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

  mandatory="consul manager nodes token tls"

  for keyword in $mandatory; do
    eval "var=\"\$$keyword\""
    if [ ! "${var}" ]; then
      echo "Keyword '$keyword' missing in '$1'"
      exit 1; fi
  done; }


#--------------------------------------
function ReadRequestFile {

  echo
  echo ". Read request file"

  scriptpath=$(dirname $(readlink -e $0))
  pathname="$scriptpath/swarm-request.ini"

  TestFileExists "$pathname"
  source "$pathname"
  CheckRequest "$pathname"

  dockerports=(2375 2376)
  tls=0		# overrides 'swarm-request.ini' until TLS implemented

  export port=${dockerports[tls]}
  export managerport=4243; }


#--------------------------------------
function Deploy-Consul {

  echo
  echo ". start Consul server on '$1'"

  ID=$(docker -H $1:$2 run -d -p 8400:8400 -p 8500:8500 -p 8600:53/udp -h consul progrium/consul -server -bootstrap -ui-dir /ui)

  if [ $? -ne 0  ]; then
    echo "Failed to start Consul container on '$1'"
    exit 1; fi

  status=1
  count=1

  while [ $status -ne 0 ] && [ $count -le 10 ]; do 
    sleep 2
    str=$(docker -H $1:$2 logs $ID 2>&1 | grep "New leader elected")
    status=$?
    count=$((count+1)); done 

  if [ $status -ne 0 ]; then
    echo "Timeout waiting for Consul server starting on '$1'"
    exit 1; fi; }


#--------------------------------------
function Deploy-Nodes {	   # nodes,$port,$consul,$token

  echo
  echo ". Start nodes"

  arr=$(echo $1 | tr "," " ")

  for node in $arr; do
    echo "    start node on '$node'"
    ID=$(docker -H $node:$2 run -d swarm join --advertise=$node:$2 consul://$3:8500/$4)
    if [ $? -ne 0  ]; then
      echo "Failed to start 'Swarm-Join' container on '$node'"
      exit 1; fi; done; }


#--------------------------------------
function Deploy-Manager {

  echo
  echo ". Start manager on '$1'"

  ID=$(docker -H $1:$2 run -d -p $managerport:$2 swarm manage consul://$3:8500/$4)

  if [ $? -ne 0  ]; then
    echo "Failed to start 'Swarm-Manager' container on '$1'"
    exit 1; fi

  status=1
  count=1

  while [ $status -ne 0 ] && [ $count -le 10 ]; do
    sleep 2
    str=$(docker -H $1:$2 logs $ID 2>&1 | grep "Registered Engine")
    status=$?
    count=$((count+1)); done

  if [ $status -ne 0 ]; then
    echo "Timeout waiting for Swarm-Manager starting on '$1'"
    exit 1; fi; }


#--------------------------------------
function Deploy-Image {

  if [ ! ${3} ]; then
    return 0; fi

  echo
  echo ". Start image instance"

  docker -H $1:$2 run -d --privileged --net=host $3  /bin/sh -c "/mnt/startAurora.sh"

  if [ $? -ne 0  ]; then
    echo "Failed to start '$3' container on '$1'"
    exit 1; fi; }


#---------------  MAIN
clear
# set -x

ReadRequestFile

Deploy-Consul  "$consul"   $port
Deploy-Nodes   "$nodes"    $port  $consul $token
Deploy-Manager "$manager"  $port  $consul $token

Deploy-Image   "$manager"  $managerport  $image

echo
echo "*** Swarm cluster successfully deployed ***"
echo
echo

