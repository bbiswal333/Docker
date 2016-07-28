#!/bin/bash

###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - July 2016 -
#  PURPOSE: builds the Dockerfile of image hana-xsa-shine-req
#
###############################################################################


#--------------------------------------
function OnError {
  echo
  echo $1
  echo
  exit 1; }


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

registry="docker.wdf.sap.corp"
push=51010
pull=50000
image="hanaxsshine/weekstone/hana-xsa-shine-req"
imgPush=$registry:$push/$image
imgPull=$registry:$pull/$image


echo "Create folder 'build'"
if [ -d build ]; then
  rm -rf build; fi
mkdir build


echo "Getting Dockerfile from Github"
if ! curl -s -k https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Hana-XSA/hana-xsa-shine-req/build/Dockerfile > build/Dockerfile; then
  OnError "Failed to curl Dockerfile"; fi


CheckLoginFile


echo "Cleanup build"
docker rmi $imgPull>/dev/null
docker rmi $imgPush>/dev/null


echo "Running 'docker build'"
if ! docker build -t $imgPush build; then
  docker rm -f -v $(docker ps -a -q)
  OnError "Failed to build Dockerfile"; fi


echo "Pushing image"
if ! docker push $imgPush; then
  OnError "Failed to push image to Artifactory"; fi

docker logout $registry:$push


echo "Renaming local image from Push to Pull tag"
if ! docker tag $imgPush $imgPull; then OnError "Failed to tag image from Push to Pull"; fi
if ! docker rmi $imgPush;          then OnError "Failed to delete local Push image"; fi
