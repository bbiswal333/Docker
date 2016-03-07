#!/bin/bash

###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - November 2015 -
#  PURPOSE: set up a Swarm cluster 
#
###############################################################################


#--------------------------------------
function CheckImagePulled {	# image
  status=1
  while [ $status -ne 0 ]; do
    str=$(docker pull $1 2>&1)
    status=$?
    if [ $status -ne 0 ]; then
      echo "Retry pulling image '$1' in 3 minutes"
      sleep 3m; fi; done
  str=$(docker rmi $1 2>&1); }


#--------------------------------------
function RunContainers {
  for num in `seq 1 1 $1`; do
    docker -H $2:$3 run -d --privileged --net=host --expose=10001 -e filter:port -v /mnt/container:/host $4  /bin/sh  /mnt/startAurora.sh
    if [ $? -ne 0 ]; then
      echo "Failed to start the container number $num."
      exit 1; fi; done; }


#---------------  MAIN
# clear
#set -x

if [ $# -ne 2 ]; then
  echo "Invalid number of parameters."
  echo "Usage: ./swarmHA-run.sh  <NumberOfContainer>  <registry:port/repository/image/tag"
  exit 1; fi

location=$(dirname $(readlink -e $0))
cd $location

request="swarm-request.ini"

if [ ! -f ../$request ]; then
  echo "File '../$request' not found"
  exit 1; fi

source "../$request"

if [ "${managerLB}" ]; then
  CheckImagePulled $2
  RunContainers    $1  $managerLB  $managerport  $2
  exit 0; fi

arrManagers=${managers//,/ }

for manager in $arrManagers; do
  docker -H $manager:$managerport ps &> /dev/null
  if [ $? -ne 0 ]; then
    echo "'$manager' doesn't respond, trying next cluster member"
    continue; fi
  echo
  bDoIt=1
  break; done

if [ ! ${bDoIt} ]; then
  echo "No alive Swarm manager member found. Couldn't execute the command"
  exit 1; fi

CheckImagePulled $2
RunContainers    $1  $manager  $managerport  $2
