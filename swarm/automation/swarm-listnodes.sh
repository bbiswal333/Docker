###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - November 2015 -
#  PURPOSE: 
#      - writes into 'nodesList.txt' the swarm nodes list deployed with the image
#      - write into connectinfo.ini the connexion info for the first node
#
###############################################################################


#---------------  MAIN
clear
#set -x

if [ $# -ne 1 ]; then
  echo "Expected parameter <DockerImage>"
  echo "Example: $0 dockerdevregistry:5000/aurora/aurora42_1950"
  exit 1; fi

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
    if [ ! "${nodeone}" ]; then
      nodeone=$nodeFQDN; fi
    printf "$node\n" >> $nodesList; fi
done

rm -f $nodesInstall


if [ ! "${nodeone}" ]; then
  exit 0; fi


## retrieve nodeone IP 
ping=`ping -c 1 $nodeone 2>&1 | grep "("`
if [ ! "${ping}" ]; then
  echo "Failed to retrieve $nodeone IP"
  exit 1; fi
IP=`echo $ping | awk '$3 { print $3 }'`
IP=${IP/(/}
IP=${IP/)/}
 


## WRITE connectinfo.ini
curl -s -k  https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Aurora-XI4x/response.ini > response.ini

if [ ! -f response.ini ]; then
  echo "Failed to retrieve 'response.ini' from Github"
  exit 1; fi

source response.ini

file=connectinfo.ini
echo ip=$IP                             >  $file
echo user=administrator                 >> $file
echo password=$CMSPassword              >> $file
echo tomcat_port=$TomcatConnectionPort  >> $file
echo cms_port=$CMSPort                  >> $file
