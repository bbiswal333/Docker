###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - November 2015 -
#  PURPOSE: set up a Swarm cluster 
#
###############################################################################

#!/bin/sh


#---------------  MAIN
# clear

if [ $# -eq 0 ]; then
  echo "Missing command, nothing to execute with 'docker -H'"
  exit 1; fi

scriptpath=$(dirname $(readlink -e $0))
request="$scriptpath/swarm-request.ini"

source "$request"

if [ "${managerLB}" ]; then
  docker -H $managerLB:$managerport $*
  exit $?; fi

arrManagers=${managers//,/ }

for manager in $arrManagers; do
  docker -H $manager:$managerport $* &> /dev/null
  if [ $? -ne 0 ]; then
    echo "'$manager' doesn't respond, trying next cluster member"
    continue; fi
  echo
  docker -H $manager:$managerport $*
  exit $?
done

echo "No alive Swarm manager member found. Couldn't execute the command"
exit 1
