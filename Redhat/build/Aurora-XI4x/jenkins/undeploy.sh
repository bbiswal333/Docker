#!/bin/bash

###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - November 2015 -
#  PURPOSE: delete all containers and images from the cluster related to the SuiteName in parameter
#
###############################################################################


#---------------  MAIN
# clear

if [ $# -ne 1 ]; then
  echo " Expected parameter: <SuiteName>"
  echo " Example: ./undeploy.sh  aurora"
  exit 1; fi


# Delete containers (forcing Stop)
array=$(./swarmHA-cmd.sh ps -a | awk -v value=$1 '$2 ~ value {print $NF}')

if [ "${array}" ]; then
  ./swarmHA-cmd.sh rm -f -v $array; fi


# Delete images
array=$(./swarmHA-cmd.sh images | awk -v value=$1 '$1 ~ value {print $1}')

if [ "${array}" ]; then
  ./swarmHA-cmd.sh rmi $array; fi
