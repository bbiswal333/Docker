#!/bin/bash

###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - November 2015 -
#  PURPOSE: set up a Swarm cluster 
#
###############################################################################


#--------------------------------------
function CheckImagePulled {	# registry:port  repo/image:tag

  artibuild=https://$1/artifactory/api/storage/xmake_allrepos/$2/latest/manifest.json

  status=1
  while [ $status -ne 0 ]; do
    curl -s $artibuild | grep $2 > /dev/null
    status=$?
    if [ $status -ne 0 ]; then
      echo "Retry pulling image '$1/$2' in 3 minutes"
      sleep 3m; fi; done; }


#--------------------------------------
function RunContainers {  # manager, managerport, registry:port, repo/image:tag, NbContainers
  for num in `seq 1 1 $5`; do
    docker -H $1:$2 run -d --privileged -v /mnt/container:/host -e filter:port \
                           -p 2638:2638 -p 3690:3690 -p 6001:6001 -p 6400:6400 -p 6404:6404 \
                           -p 10001:10001 -p 10002:10002 -p 10003:10003 -p 10004:10004 \
                           -p 32770:22 $3/$4  /bin/sh  /mnt/startAurora.sh
    if [ $? -ne 0 ]; then
      echo "Failed to start the container number $num."
      exit 1; fi; done; }


#---------------  MAIN
#set -x

if [ $# -ne 3 ]; then
  echo "Invalid number of parameters."
  echo "Usage: ./swarmHA-run.sh   <registry:port>  <repository/image/tag>  <NbContainers>"
  exit 1; fi

location=$(dirname $(readlink -e $0))
cd $location

request="swarm-request.ini"

if [ ! -f ../$request ]; then
  echo "File '../$request' not found"
  exit 1; fi

source "../$request"

if [ "${managerLB}" ]; then
  CheckImagePulled $1 $2
  RunContainers    $manager $managerport $1 $2 $3
  exit $?; fi

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

CheckImagePulled $1 $2
RunContainers    $manager $managerport $1 $2 $3
