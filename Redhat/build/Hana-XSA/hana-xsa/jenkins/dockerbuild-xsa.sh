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

  $GithubURL = 'https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Hana-XSA/hana-xsa/jenkins'

  if ! curl -k -s $GithubURL/trigger-xsa.txt -o trigger-xsa.tx; then
    OnError "Failed to download 'trigger-xsa.txt' from Github"; fi

  # replace Windows Newlines
  tr -d "\r" < trigger-xsa.tx > trigger-xsa.txt
  rm trigger-xsa.tx }


#--------------------------------------
function GetCifsInstaller {

  if ! mount -t cifs "//production.wdf.sap.corp/makeresults/newdb" /mnt/cifs  -o domain=global,user=$1,password=$2; then
    OnError "Failed to mount 'production.wdf.sap.corp' in CIFS"; fi

  rel=../../hana-installers
  mkdir -p upload/{RT,XSA}

  cp    $rel/SAPCAR*                                          upload/
  cp -r $rel/SAP_HANA_LCM                                     upload/
  cp    $rel/SAP_HANA_DATABASE*.SAR                           upload/

  cp    $rel/xs.onpremise.runtime.hanainstallation*[0-9].SAR  upload/RT
  cp    $rel/jobscheduler-assembly*[0-9].zip                  upload/
  cp    $rel/*MONITORING*                                     upload/XSA/
  cp    $rel/sap-xsac-hrtt*[0-9].zip                          upload/XSA/
  cp    $rel/*XSACDICORE*                                     upload/XSA/
  cp    $rel/sap-xsac-webide*[0-9].zip                        upload/XSA/
  cp    $rel/*[0-9].mtaext                                    upload/XSA/; }

#  cp    $rel/xs.onpremise.runtime.hanainstallation*           upload/RT
#  cp    $rel/jobscheduler-assembly*                           upload/
#  cp    $rel/sap-xsac-admin*                                  upload/XSA/
#  cp    $rel/sap-xsac-hrtt*                                   upload/XSA/
#  cp    $rel/sap-xsac-di*                                     upload/XSA/
#  cp    $rel/sap-xsac-webide*                                 upload/XSA/; }


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
set -x

registry="docker.wdf.sap.corp"
push=51010
pull=50000
image="hanaxsshine/weekstone/hana-xsa"
imgPush=$registry:$push/$image
imgPull=$registry:$pull/$image

echo "Getting Trigger manifest from Github"
GetTriggerFile
exit 1
echo "Create workspace folder 'build'"
#if [ -d build ]; then
#  rm -rf build; fi
#mkdir build
cd build

echo "Getting 'hanadb' and 'lcm' installers to upload"
GetCifsInstaller
exit
echo "Getting Dockerfile from Github"
if ! curl -s -k https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Hana-XSA/hana-xsa/build/Dockerfile > Dockerfile; then
  OnError "Failed to curl Dockerfile"; fi

echo "Initialize Artifactory login"
InitArtifactoryLogin

echo "Clean up failed previous builds"
DeleteFailedBuildsContainers
DeleteFailedBuildsImages

echo "Running 'docker build'"
if ! docker build -t $imgPush .; then
  OnError "Failed to build Dockerfile"; fi

echo "Pushing image"
if ! docker push $imgPush; then
  OnError "Failed to push image to Artifactory"; fi

docker logout $registry:$push

echo "Renaming local image from Push to Pull tag"
dummy=$(docker rmi $imgPull 2>&1)
if ! docker tag $imgPush $imgPull; then OnError "Failed to tag image from Push to Pull"; fi
if ! docker rmi $imgPush;          then OnError "Failed to delete local Push image"; fi
