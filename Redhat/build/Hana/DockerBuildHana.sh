###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com
#
#  DOWNLOADS: 
#  SAPCAR   :  http://moo-repo.wdf.sap.corp:8080/static/monsoon/sapcar/7.20/linux_x86_64/sapcar.exe
#              INSTEAD OF /net/build-drops-wdf/dropzone/nett_dev/sapcar.exe
#  UAL_AFL  :  /net/build-drops-wdf/dropzone/nett_dev/ual_afl.sar
#  HANA 091 :  http://moo-repo.wdf.sap.corp:8080/static/pblack/newdb/NewDB100/rel/091/server/linuxx86_64/SAP_HANA_DATABASE100_091_Linux_on_x86_64.SAR
#  HANA 092 :  http://moo-repo.wdf.sap.corp:8080/static/pblack/newdb/NewDB100/rel/092/server/linuxx86_64/SAP_HANA_DATABASE100_092_Linux_on_x86_64.SAR
#
#      INSTEAD OF: \\production\newdb\NewDB100\rel\[REV]\server\linuxx86_64\SAP_HANA_DATABASE
#
###############################################################################


#!/bin/sh


# DEBUG PURPOSE
#--------------------------------------
function _PAUSE {
  read -p "PAUSE "; }


#--------------------------------------
function abort {
  echo
  echo $2
  exit $1; }


#--------------------------------------
function CheckPathParameter {
  if [ ! "${1}" ]; then
    echo "Usage BuildHana <Path to .SAR>"
    abort 1  "Parameter <Path to HanaDb installer (.SAR expected)> is missing"; fi }


#--------------------------------------
function SetWorkingDirectory {
  cd "$1"; }


#--------------------------------------
function InitVars {
  export DOWNLOAD_DB_FROM="$1"
  export DOWNLOAD_CL_FROM="${DOWNLOAD_DB_FROM/server/client}"
  export REGISTRY="dewdftzlidck:5000"
  export SOFTWARE="hana"
  export HANA="hana"
  export REV="NUL"
  export TAG="latest"
  export INSTANCE="00"
  export KEY_DATABASE="DATABASE"
  export KEY_CLIENT="CLIENT"
  export LOCATION=$(pwd); }


#--------------------------------------
function RemoveDir {
  if [ -d "$1" ]; then
    rm -rf $1; fi }


#--------------------------------------
function CleanupBuildSpace {

  echo
  echo ". Cleaning build workspace"

  RemoveDir "XXX"

  mkdir -p XXX/installer/sapcar
  mkdir    XXX/installer/tmp; }
# mkdir    XXX/installer/ual_afl; }


#--------------------------------------
function Download_sapcar {

  echo
  echo ". Downloading 'http://moo-repo.wdf.sap.corp:8080/static/monsoon/sapcar/7.20/linux_x86_64/sapcar.exe'"

  wget -o /dev/null "http://moo-repo.wdf.sap.corp:8080/static/monsoon/sapcar/7.20/linux_x86_64/sapcar.exe"  -P XXX/installer/sapcar/

  if [ ! -f XXX/installer/sapcar/sapcar.exe ]; then
    abort 1  "Failed to download 'sapcar.exe'"; fi

  chmod +x XXX/installer/sapcar/sapcar.exe; }


#--------------------------------------
#function Download_ualafl {

#  echo
#  echo ". Downloading '/net/build-drops-wdf/dropzone/nett_dev/ual_afl.sar'"

#  cp  /net/build-drops-wdf/dropzone/nett_dev/ual_afl.sar   $LOCATION/installer/ual_afl/
#  if [ ! -f $LOCATION/installer/ual_afl/ual_afl.sar ]; then
#    abort 1  "Failed to download 'ual_afl.sar'"; fi

#  echo ". Extracting '$LOCATION/installer/ual_afl/ual_afl.sar'"

#  cd $LOCATION/installer/ual_afl
#  $LOCATION/installer/sapcar/sapcar.exe  -xf  $LOCATION/installer/ual_afl/ual_afl.sar > /dev/null

#  STATUS=$?
#  if [ $STATUS -ne 0 ]; then
#    abort $STATUS  "Error exracting '$LOCATION/installer/ual_afl/ual_afl.sar'"; fi

#  rm -f $LOCATION/installer/ual_afl/ual_afl.sar; }


#--------------------------------------
function Download {

  # $1 = $KEY_xxxxxxxx
  # $2 = $DOWNLOAD_xx_FROM

  cd tmp

  echo
  echo ". Downloading '$2/'"
  wget -o /dev/null -r --no-directories --no-parent --reject="index.html*"  $2

  SAR=$(ls | grep "$1")
  if [ ! "${SAR}" ]; then
    abort 1 "Failed to download a file like 'HANA $1 .SAR'"; fi

  echo ".   Found downloaded file: '$SAR'"
  echo ".   Extracting             '$SAR'"

  cd ..
  $LOCATION/XXX/installer/sapcar/sapcar.exe  -xf  tmp/$SAR > /dev/null

  STATUS=$?
  if [ $STATUS -ne 0 ]; then
    error $STATUS "Error extracting '$SAR'"; fi

  rm -f tmp/$SAR

  FOLDER=$(ls -d S* | grep $1)
  chmod -R 755 $FOLDER/*; }


#--------------------------------------
function Download_Hana {

  cd XXX/installer

  Download  $KEY_DATABASE  $DOWNLOAD_DB_FROM
  Download  $KEY_CLIENT    $DOWNLOAD_CL_FROM

  rm -rf tmp
  echo; }


#--------------------------------------
function GetHanaRevision {

  FOLDERDB=$(ls -d S* | grep $KEY_DATABASE)
  REV=$(cat SAP_HANA_DATABASE/server/manifest | grep --word-regexp  "rev-number" | awk '$2 { print $2 }')

  if [ ! "${REV}" ]; then
    abort 1 "Failed retreive HANA revision from manifest"; fi; }


#--------------------------------------
function SetRevBuildSpace {

  cd $LOCATION

  RemoveDir $REV
  mv "XXX" $REV; }


#--------------------------------------
function DeleteContainers {

  for CONTAINER in $( docker ps -a | awk -v image="$REGISTRY/$SOFTWARE/$HANA$REV:$TAG" '$2==image { print $NF }' ); do

    NAME=$(docker ps | awk -v name=$CONTAINER '$NF==name { print $NF }')

    if [ ${NAME} ]; then
      echo ". Stopping container $CONTAINER"
      docker stop $CONTAINER > /dev/null; fi

    echo ". Deleting container $CONTAINER"
    docker rm $CONTAINER > /dev/null; done; }


#--------------------------------------
function DeleteImage {

  docker images | grep $HANA$REV > /dev/null

  if [ $? -eq 0 ]; then
    echo ". Deleting image $HANA$REV"
    docker rmi $REGISTRY/$SOFTWARE/$HANA$REV:$TAG > /dev/null; fi; }


#--------------------------------------
function BuildImageHana {

  echo ". Creating container, installing Hana"
  echo

  cd $LOCATION

  docker run --name=$HANA$REV-$INSTANCE --net=host --privileged \
      -v /etc/localtime:/etc/localtime \
      -v $LOCATION/$REV/installer:/setup \
      -v $LOCATION/InstallHana.sh:/InstallHana.sh \
      $REGISTRY/rh70/rh70lib \
      /bin/sh -c /InstallHana.sh

  STATUS=$?  
  if [ $STATUS -ne 0 ]; then
    abort $STATUS  "Failed to install Hana$REV in the container"; fi; }


#--------------------------------------
function WriteImageHana {

  echo
  echo ". Committing container to an image"

  docker commit $HANA$REV-$INSTANCE $REGISTRY/$SOFTWARE/$HANA$REV

  STATUS=$?
  if [ $STATUS -ne 0 ]; then
    abort $STATUS "Failed to commit $HANA$REV to an image"; fi; }


#--------------------------------------
function DeleteBuildContainer {
  docker rm HANA$REV-$INSTANCE > /dev/null; }


#--------------------------------------
function PushImageHana {

  echo
  echo ". Pushing image to the registry server"

  docker push $REGISTRY/$SOFTWARE/$HANA$REV:$TAG

  STATUS=$?
  if [ $STATUS -ne 0 ]; then
    abort $STATUS "Failed to push image '$REGISTRY/$SOFTWARE/$HANA$REV:$TAG' to the registry server"; fi; }


#---------------  MAIN
clear
#set -x

CheckPathParameter $1

SetWorkingDirectory  $(dirname $0)
InitVars $1
CleanupBuildSpace

Download_sapcar
#Download_ualafl
Download_Hana

GetHanaRevision
SetRevBuildSpace

DeleteContainers
DeleteImage

BuildImageHana
WriteImageHana
#PushImageHana

DeleteBuildContainer


#--------------------------------------
# read -s PASSWORD
# if [ ! "${PASSWORD}" ]; then
#   exit 1; fi

# Use smbclient instead of 'mount -t cifs' -> 'input/output error'
# echo ". Downloading '\\production\newdb\NewDB100\rel\092\server\linuxx86_64\SAP_HANA_DATABASE'"
# smbclient -W $DOMAIN -U $USER%$PASSWORD //production/newdb -c 'prompt;recurse;cd NewDB100\rel\092\server\linuxx86_64\SAP_HANA_DATABASE\;mget *' 2>&1 >/dev/null
