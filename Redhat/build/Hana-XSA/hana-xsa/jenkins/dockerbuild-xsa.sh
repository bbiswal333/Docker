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
function GetTriggerFile {

  GithubURL='https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Hana-XSA/hana-xsa/jenkins'

  if ! curl -k -s $GithubURL/trigger-xsa.txt -o trigger-xsa.tx; then
    OnError "Failed to download 'trigger-xsa.txt' from Github"; fi

  # replace Windows Newlines
  tr -d "\r" < trigger-xsa.tx > trigger-xsa.txt
  rm trigger-xsa.tx; }


#--------------------------------------
function GetCifsInstaller {

  #   Windows = //production.wdf.sap.corp/makeresults/newdb/POOL/HANA_WS_COR/released_weekstones/LastWS/lcm/linuxx86_64
  #   mount -t nfs derotvi0157.wdf.sap.corp:/derotvi0157a_ld9252/q_files  /mnt/xsa
  #      =>  /mnt/xsa/HANA_WS_COR/released_weekstones/LastWS/lcm/linuxx86_64

  remove="//production.wdf.sap.corp/makeresults/newdb/POOL/"

  if ! sudo mount -t nfs "derotvi0157.wdf.sap.corp:/derotvi0157a_ld9252/q_files"  /mnt/xsa; then
    OnError "Failed to mount '$radix' in CIFS"; fi

  while IFS=';' read name folder url file; do

    if [ "$name" == "lcm" -o "$name" == "hanadb" ]; then

      endpoint=${url/$remove/}

      if ! cp -r /mnt/xsa/$endpoint/$file  build/$folder/; then
        sudo umount /mnt/xsa
        OnError "Failed to copy from '$url'"; fi; fi

  done < trigger-xsa.txt

  sudo umount /mnt/xsa; }


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
  if [ $? -ne 0 ]; then
    OnError "Failed to run 'docker ps'. Is docker daemon running ?"; fi
  if [ "${dummy}" ]; then
    docker rm -f -v $(docker ps -a -q); fi; }


#--------------------------------------
function DeleteFailedBuildsImages {
  imageId=$(docker images | awk -v name='<none>' '$1==name { print $3 }')
  if [ "${imageId}" ]; then
    docker rmi $imageId; fi; }


#---------------  MAIN
#set -x

registry="docker.wdf.sap.corp"
push=51010
pull=50000
image="hanaxsshine/weekstone/hana-xsa"
imgPush=$registry:$push/$image
imgPull=$registry:$pull/$image

echo; echo "Download 'trigger-xsa.txt' from Github"
GetTriggerFile

echo "Create workspace folder 'build'"
if [ ! -d /mnt/xsa ]; then
  mkdir /mnt/xsa; fi
if [ -d build ]; then
  rm -rf build; fi
mkdir -p build/upload

echo "Get 'hanadb' and 'lcm' installers to upload"
GetCifsInstaller

echo "Get Dockerfile from Github"
if ! curl -s -k https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Hana-XSA/hana-xsa/build/Dockerfile -o build/Dockerfile; then
  OnError "Failed to curl Dockerfile"; fi

echo "Initialize Artifactory login"
InitArtifactoryLogin

echo; echo "Clean up Docker storage"
DeleteFailedBuildsContainers
DeleteFailedBuildsImages

echo; echo "Run 'docker build'"
if ! docker build -t $imgPush build; then
  OnError "Failed to build Dockerfile"; fi

#echo "Push image"
#if ! docker push $imgPush; then
#  OnError "Failed to push image to Artifactory"; fi

#docker logout $registry:$push

echo "Rename local image from Push to Pull tag"
dummy=$(docker rmi $imgPull 2>&1)
if ! docker tag $imgPush $imgPull; then OnError "Failed to tag image from Push to Pull"; fi
if ! docker rmi $imgPush;          then OnError "Failed to delete local Push image"; fi
