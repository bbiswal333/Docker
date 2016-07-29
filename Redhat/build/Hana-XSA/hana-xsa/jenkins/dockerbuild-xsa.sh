#!/bin/bash

###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - July 2016 -
#  PURPOSE: builds the Dockerfile of image hana-xsa
#
###############################################################################


#--------------------------------------
function OnError {
  echo
  echo $1
  echo
  exit 1; }


#--------------------------------------
function PrepareInstaller {

  if [ -d mount ]; then exit 1; fi

  mkdir mount
  if ! sudo mount -t cifs //mo-a9901609a.mo.sap.corp/XSA mount -o domain=global,user=$1,password=$2; then exit 1; fi

  rm -rf upload
  mkdir -p upload/51050846/DATA_UNITS

  cp mount/51050846/*            upload/51050846/
  cp mount/51050846/DATA_UNITS/* upload/51050846/DATA_UNITS/

  cp -r mount/51050846/DATA_UNITS/HDB_LCM_LINUX_X86_64     upload/51050846/DATA_UNITS/
  cp -r mount/51050846/DATA_UNITS/HDB_SERVER_LINUX_X86_64  upload/51050846/DATA_UNITS/
  cp -r mount/51050846/DATA_UNITS/XSA_RT_10_LINUX_X86_64   upload/51050846/DATA_UNITS/
  cp -r mount/51050846/DATA_UNITS/XSA_CONTENT_10           upload/51050846/DATA_UNITS/

  if ! sudo umount mount; then exit 1; fi
  rm -r mount; }


#--------------------------------------
function CheckLoginFile {

  if [ -f ~/.docker/config-SAVE.json ]; then
    cat ~/.docker/config-SAVE.json > ~/.docker/config.json
    return 0; fi

  if [ -f ~/.docker/config.json ]; then
    cat ~/.docker/config.json > ~/.docker/config-SAVE.json
    return 0; fi;

  OnError "File '~/.docker/config.json' is missing, cannot connect to Artifactory server"; }


#---------------  MAIN
set -x

if [ $# -ne 2 ]; then
  OnError "Expected parameters: GLOBAL\<login> <password>"; fi

registry="docker.wdf.sap.corp"
push=51010
pull=50000
image="hanaxsshine/weekstone/hana-xsa"
imgPush=$registry:$push/$image
imgPull=$registry:$pull/$image

echo "Create workspace folder 'build'"
if [ -d build ]; then
  rm -rf build; fi
mkdir build
cd build

echo "Filtering HanaXS installer files to upload"
PrepareInstaller $1 $2

echo "Getting Dockerfile from Github"
if ! curl -s -k https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Hana-XSA/hana-xsa/build/Dockerfile > Dockerfile; then
  OnError "Failed to curl Dockerfile"; fi

CheckLoginFile

echo "Cleanup build"
dummy=$(docker rmi $imgPull 2>&1)
dummy=$(docker rmi $imgPush 2>&1)

echo "Running 'docker build'"
if ! docker build -t $imgPush .; then
  dummy=$(docker ps -a -q)
  if [ "${dummy}" ]; then
    docker rm -f -v $(docker ps -a -q); fi
  OnError "Failed to build Dockerfile"; fi

echo "Pushing image"
if ! docker push $imgPush; then
  OnError "Failed to push image to Artifactory"; fi

docker logout $registry:$push

echo "Renaming local image from Push to Pull tag"
if ! docker tag $imgPush $imgPull; then OnError "Failed to tag image from Push to Pull"; fi
if ! docker rmi $imgPush;          then OnError "Failed to delete local Push image"; fi