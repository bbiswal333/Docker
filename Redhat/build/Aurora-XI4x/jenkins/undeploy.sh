#!/bin/bash

###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - November 2015 -
#  PURPOSE: delete containers and images related to the passed parameter
#
###############################################################################


#---------------  MAIN
#set -x

if [ $# -ne 1 ]; then
  echo " Expected parameter: <Name>"
  echo " Example: ./undeploy.sh  aurora|aurora42_cons"
  exit 1; fi


# Download swarmHA-cmd.sh from Github
echo
echo "Getting 'swarmHA-cmd.sh' from Github"
curl -s https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/swarm/automation/swarmHA-cmd.sh > swarmHA-cmd.sh

if [ ! -f swarmHA-cmd.sh ]; then
  echo "Failed to get 'swarmHA-cmd.sh' from github"
  exit 1; fi

chmod +x swarmHA-cmd.sh


# Delete containers (forcing Stop)
echo
echo "DELETING '$1' CONTAINERS"
array=$(./swarmHA-cmd.sh ps -a | awk -v value=$1 '$2 ~ value {print $NF}')

if [ "${array}" ]; then
  ./swarmHA-cmd.sh rm -f -v $array; fi


# Delete images
echo
echo "DELETING '$1' IMAGES"
array=$(./swarmHA-cmd.sh images | awk -v value=$1 '$1 ~ value {print $1}')

if [ "${array}" ]; then
  ./swarmHA-cmd.sh rmi $array; fi
