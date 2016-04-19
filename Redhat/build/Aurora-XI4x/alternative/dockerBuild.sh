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
  export auroraReq=aurora-req
  export containerName=AuroraBox; }


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
function PrepareBuild {

  # create build folder
  folder=$1-$version

  if [ -d $folder ]; then
    rm -rf $folder; fi

  mkdir $folder
  cd $folder

  # download Dockerfile to build
  curl -s https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Aurora-XI4x/Dockerfile > Dockerfile

  if [ ! -f Dockerfile ]; then
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
  docker build -t $auroraReq .
  OnError $? "docker build has returned an error"; }


#--------------------------------------
function InstallAurora {  # aurora42_cons
  docker run -t --privileged --net=host --name $containerName $auroraReq /bin/sh /mnt/installAurora.sh $1/$version
  OnError $? "Aurora setup has returned an error"; }


#--------------------------------------
function CommitToImage {
  docker commit $containerName  $registry/$image 2>&1 > /dev/null
  OnError $? "Failed to commit the Aurora container to a local image"; }


#--------------------------------------
function SaveToRegistry {

  cat ~/.docker/config-SAVE.json > ~/.docker/config.json

  docker push $registry/$image
  status=$?

  docker logout $registry > /dev/null

  OnError $status "Failed to push image ' $registry/$image'"; }


#--------------------------------------
#function CleanUp {
  # docker rmi $(docker images -a -q)
#}


#---------------  MAIN
# params  aurora  aurora42_cons  aurora4xInstall
set -x

CheckParam $# $0
InitVars  $1 $2 $3
CheckLoginFile
PrepareBuild $2
DockerBuild
InstallAurora $2
CommitToImage
SaveToRegistry
#CleanUp
