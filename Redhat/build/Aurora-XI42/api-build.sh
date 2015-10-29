# Script to build the aurora image on your swarm cluster
 
#   Parameter : SwarmManagerSrv-FQDN


#!/bin/bash


#	IMAGES ON THE CLUSTER BEFORE THE BUILD

echo 'Images on the swarm cluster before the build :'
curl dewdftv01641.dhcp.pgdev.sap.corp:4000/images/json?all=1


#	DOWNLOADING DOCKERFILE

curl -k -s  https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Aurora-XI42/Dockerfile > Dockerfile

#	BUILD PROCESS THROUGH THE SWARM API 

mkdir aurora
mv Dockerfile aurora/
cd aurora/
tar zcf Dockerfile.tar.gz Dockerfile
cd ..

curl -v -X POST -H "Content-Type:application/tar" --data-binary '@aurora/Dockerfile.tar.gz' $1:4000/build?t=aurora-image\&forcerm=1
rm aurora/Dockerfile aurora/Dockerfile.tar.gz
rmdir aurora


#	RESULT: IMAGES ON THE CLUSTER AFTER THE BUILD
echo 'Images on the swarm cluster after the build :'
curl dewdftv01641.dhcp.pgdev.sap.corp:4000/images/json?all=1

