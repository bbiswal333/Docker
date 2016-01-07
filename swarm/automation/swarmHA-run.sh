###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - November 2015 -
#  PURPOSE: set up a Swarm cluster 
#
###############################################################################

#!/bin/sh
#set -x


#--------------------------------------
function RunContainer {
  docker -H $1:$2 run -d --privileged --net=host $3  /bin/sh  /mnt/startAurora.sh
  if [ $? -ne 0 ]; then
    echo "Failed to start the container instance number $4."
    exit 1; fi; }


#---------------  MAIN
# clear

if [ $# -ne 2 ]; then
  echo "Invalid number of parameters."
  echo "Usage: ./dockerhost-runAurora.sh  <NumberOfContainer>  <registry:port/repository/image/tag"
  exit 1; fi

scriptpath=$(dirname $(readlink -e $0))
request="$scriptpath/swarm-request.ini"

source "$request"

if [ "${managerLB}" ]; then
  for num in `seq 1 1 $1`; do
    RunContainer $managerLB $managerport $2 $num; done
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

for num in `seq 1 1 $1`; do
  RunContainer $manager  $managerport $2 $num; done
