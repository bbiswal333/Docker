#!/bin/bash

###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - July 2016 -
#  PURPOSE: builds the Dockerfile of image hana-xsa-shine
#
###############################################################################


#--------------------------------------
function OnError {
  echo
  echo $1
  echo
  exit 1; }


#--------------------------------------
function InitArtifactoryLogin {

  if [ -f ~/.docker/config-SAVE.json ]; then
    cat ~/.docker/config-SAVE.json > ~/.docker/config.json
    return 0; fi

  if [ -f ~/.docker/config.json ]; then
    cat ~/.docker/config.json > ~/.docker/config-SAVE.json
    return 0; fi;

  OnError "File '~/.docker/config.json' is missing, cannot connect to Artifactory server"; }


#--------------------------------------
function DeleteFailedBuildsContainers {
  dummy=$(docker ps -a -q)
  if [ "${dummy}" ]; then
    docker rm -f -v $(docker ps -a -q); fi; }


#--------------------------------------
function DeleteFailedBuildsImages {
  imageId=$(docker images | awk -v name='<none>' '$1==name { print $3 }')
  if [ "${imageId}" ]; then
    docker rmi $imageId; fi; }


#---------------  MAIN
#set -x

#if [ $# -ne 1 ]; then
#  echo "Expected parameter: Github branch to build the Shine version"
#  echo "Example: ./dockerbuild-shine.sh rev-1.1.12"
#  exit 1; fi

registry="docker.wdf.sap.corp"
push=51010
pull=50000
image="hanaxsshine/weekstone/hana-xsa-shine"
imgPush=$registry:$push/$image
imgPull=$registry:$pull/$image

echo
echo "Create workspace folder 'build'"
if [ -d build ]; then
  rm -rf build; fi
mkdir build
cd build

echo "Curl Dockerfile from Github"
if ! curl -s -k -O https://github.wdf.sap.corp/I313177/Docker/tree/master/Redhat/build/Hana-XSA/hana-xsa-shine/build/Dockerfile; then
  OnError "Failed to curl Dockerfile"; fi

echo "Initialize Artifactory login"
InitArtifactoryLogin

echo "Cleanup Docker storage"
DeleteFailedBuildsContainers
DeleteFailedBuildsImages

echo "Run 'docker build'"
if ! docker build --build-arg branch=$1 -t $imgPush:1.0 .; then
#if ! docker build  -t $imgPush .; then
  OnError "Failed to build Dockerfile"; fi

echo "Push image"
if ! docker push $imgPush:1.0; then
  OnError "Failed to push image to Artifactory"; fi

docker logout $registry:$push

echo "Rename local image from Push to Pull tag"
dummy=$(docker rmi $imgPull:1.0 2>&1)
if ! docker tag $imgPush:1.0 $imgPull:1.0; then OnError "Failed to tag image from Push to Pull"; fi
if ! docker rmi $imgPush:1.0;          then OnError "Failed to delete local Push image"; fi
