#!/bin/bash

###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - August 2016 -
#  PURPOSE: deploy hana-xsa / hana-xsa-shine container from the image
#
###############################################################################


#--------------------------------------
function OnError {
  echo
  echo $1
  echo
  exit 1; }


#--------------------------------------
function DeleteContainers {
  dummy=$(docker ps -a -q)
  if [ $? -ne 0 ]; then
    OnError "Failed to run 'docker ps'. Is docker daemon running ?"; fi
  if [ "${dummy}" ]; then
    docker rm -f -v $dummy; fi; }


#--------------------------------------
function DeleteImages {
  dummy=$(docker images -q)
  if [ $? -ne 0 ]; then
    OnError "Failed to run 'docker images'"; fi
  if [ "${dummy}" ]; then
    docker rmi $dummy; fi; }



#---------------  MAIN
set -x

if [ $# -ne 3 ]; then
  echo "Expected parameters:  <image>  <SID>  <InstanceNumber>"
  echo "Example: ./deploy-container.sh  hana-xsa-shine  DCK  00"
  exit 1; fi

imgPull=docker.wdf.sap.corp:50000/hanaxsshine/weekstone/$1
curlScript="RenameInstance.sh"

echo "Cleanup host, delete existing containers and images"
DeleteContainers
DeleteImages

echo "Getting '$curlScript' from github"
if ! curl -s -k https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Hana-XSA/hana-xsa-shine/jenkins/$curlScript > $curlScript; then
  OnError "Failed to curl '$curlScript' from Github"; fi

echo "Deploying container"
pth=$(pwd)
if ! docker run -t --net=host -v $pth:/scripts $imgPull /bin/sh "/scripts/$curlScript $1 $2"; then
  OnError "Failed to start '$1' container"; fi
