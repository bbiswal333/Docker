#!/bin/bash

###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - November 2015 -
#  PURPOSE: delete all containers and images from the cluster related to the SuiteName in parameter
#
###############################################################################


#---------------  MAIN
# clear

if [ $# -eq 0 ]; then
  echo " Expected parameter : <SuiteName> to delete related containers and images."
  echo " Example: ./undeploy.sh  aurora"
  exit 1; fi

array=$(./swarmHA-cmd.sh ps -a | awk -v value=$1 '$2 ~ value {print $NF}')
./swarmHA-cmd.sh rm -f -v $array

array=$(./swarmHA-cmd.sh images | awk -v value=$1 '$1 ~ value {print $1}')
./swarmHA-cmd.sh rmi $array
