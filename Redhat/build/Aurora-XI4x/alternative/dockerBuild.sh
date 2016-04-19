#!/bin/bash

###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - April 2016 -
#  PURPOSE: create Aurora image installing the Aurora dropped version
#
###############################################################################


#--------------------------------------
function CheckParam {
  if [ $1 -ne 3 ]; then
    echo "Expected parameters <suite>  <buildType>  <xMakerepo>"
    echo "Example: $2  aurora  aurora42_cons  aurora4xInstall"
    exit 1; fi; }


#--------------------------------------
function InitVars {  # aurora  aurora42_cons  aurora4xInstall

  export version=$(curl -s https://github.wdf.sap.corp/raw/AuroraXmake/$3/master/version.txt)

  if [ ! "${version}" ]; then
    echo "Failed to get file 'version.txt' from Github"
    exit 1; fi

  export registry="docker.wdf.sap.corp:51003"
  export image=$1/$2_$version-snapshot
  export auroraReq=aurora-req; }


#--------------------------------------
function CheckLoginFile {

  if [ ! -f ~/.docker/config-SAVE.json ]; then

    if [ -f ~/.docker/config.json ]; then
      cat ~/.docker/config.json > ~/.docker/config-SAVE.json
    else
      echo
      echo "File '~/.docker/config.json' is missing, cannot connect to Artifactory server"
      echo
      exit 1; fi; fi; }


#--------------------------------------
function RemoveContainers {
  array=$(docker ps -a -q)
  if [ "${array}" ]; then
    docker rm -f -v $array; fi; }


function RemoveImage {
  array=$(docker images | awk -v value=$1 '$1~value {print $1}')
  if [ "${array}" ]; then
    docker rmi $1; fi; }


function CleanUp {
  RemoveContainers
# RemoveImage $auroraReq
  RemoveImage $1; }


#--------------------------------------
function PrepareBuild {

  # create build folder
  folder=$1-$version

  if [ -d builds ]; then
    rm -rf builds; fi
  mkdir -p builds/$folder


  # download Dockerfile to build
  curl -s https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Aurora-XI4x/Dockerfile > builds/$folder/Dockerfile

  if [ ! -f builds/$folder/Dockerfile ]; then
    echo "Failed to get file 'Dockerfile' from GitHub"
    exit 1; fi; }


#--------------------------------------
function OnError {

  if [ $1 -ne 0 ]; then
    echo
    echo "  $2"
    echo
    exit 1; fi; }


#--------------------------------------
function DockerBuild {
  docker build -t $auroraReq builds/$1-$version
  OnError $? "docker build has returned an error"; }


#--------------------------------------
function InstallAurora {  # aurora42_cons
  docker run -t --privileged --net=host --name $1 $auroraReq /bin/sh /mnt/installAurora.sh $1/$version
  OnError $? "Aurora setup has returned an error"; }


#--------------------------------------
function CommitToImage {  # aurora42_cons
  docker commit $1  $registry/$image 2>&1 > /dev/null
  OnError $? "Failed to commit the Aurora container to a local image"; }


#--------------------------------------
function SaveToRegistry {

  cat ~/.docker/config-SAVE.json > ~/.docker/config.json

  docker push $registry/$image
  status=$?

  docker logout $registry > /dev/null

  OnError $status "Failed to push image ' $registry/$image'"; }


#---------------  MAIN
# params  aurora  aurora42_cons  aurora4xInstall
set -x

CheckParam $# $0
InitVars  $1 $2 $3
CheckLoginFile
CleanUp $2
PrepareBuild $2
DockerBuild $2
InstallAurora $2
CommitToImage $2
SaveToRegistry
