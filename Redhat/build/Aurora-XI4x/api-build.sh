
# api-build.sh
# simon.gomez@sap.com

#   PURPOSE: Script to build the aurora image on your swarm cluster
#   PARAMETER: SwarmManagerSrv-FQDN


#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage api-build.sh <SwarmManagerSrv-FQDN>"
  exit 1;
fi


## DEBUG PURPOSE
#       IMAGES ON THE CLUSTER BEFORE THE BUILD
echo 'Images on the swarm cluster before the build :'
curl $1:4000/images/json?all=1
##


#       DOWNLOADING DOCKERFILE
mkdir aurora
curl -k -s  https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Aurora-XI4x/Dockerfile > aurora/Dockerfile


#       BUILD PROCESS THROUGH THE SWARM API
tar zcf aurora/Dockerfile.tar.gz aurora/Dockerfile
curl -v -X POST -H "Content-Type:application/tar" --data-binary '@aurora/Dockerfile.tar.gz' $1:4000/build?t=aurora-image\&forcerm=1
rmdir -rf aurora


## DEBUG PURPOSE
#       RESULT: IMAGES ON THE CLUSTER AFTER THE BUILD
echo 'Images on the swarm cluster after the build :'
curl $1:4000/images/json?all=1
##
