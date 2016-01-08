###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - November 2015 -
#  PURPOSE: writes the swarm cluster nodes list into file 'nodesList.txt'
#
###############################################################################


#---------------  MAIN
clear
set -x

location=$(dirname $(readlink -e $0))

request="$location/swarm-request.ini"
nodesInstall="$location/nodesInstall.txt"
nodesList="$location/nodesList.txt"


if [ ! -f $request ]; then
  echo "File '$request' not found"
  exit 1; fi

if [ -f $nodesList ]; then
  rm -f $nodesList; fi

source "$request"


arrManagers=${managers//,/ }
for manager in $arrManagers; do
  docker -H $manager:$managerport ps &> /dev/null
  if [ $? -ne 0 ]; then
    echo "'$manager' doesn't respond, trying next cluster member"
    continue; fi
  docker -H $manager:$managerport ps -a | grep $1 > $nodesInstall
  status=1
  break
done

if [ ! ${status} ]; then
  echo "No alive Swarm manager member found. Couldn't execute the command"
  exit 1; fi


arrNodes=${nodes//,/ }
for nodeFQDN in $arrNodes; do
  node="${nodeFQDN%%.*}"
  grep $node $nodesInstall
  if [ $? -eq 0 ]; then
    printf "$node\n" >> $nodesList; fi
done

rm -f $nodesInstall
