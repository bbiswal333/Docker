###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com
#
#  DOWNLOADS: 
#  /net/build-drops-wdf/dropzone/nett_dev/sapcar.exe
#  /net/build-drops-wdf/dropzone/nett_dev/ual_afl.sar
#  http://moo-repo.wdf.sap.corp:8080/static/pblack/newdb/NewDB100/rel/092/server/linuxx86_64/SAP_HANA_DATABASE100_092_Linux_on_x86_64.SAR
#      REPLACES: \\production\newdb\NewDB100\rel\092\server\linuxx86_64\SAP_HANA_DATABASE
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
function RemoveDir {
  if [ -d "$1" ]; then
    rm -rf $1; fi }


#--------------------------------------
function CleanupBuildSpace {

  echo
  echo ". Cleaning Hana$REV build workspace"

  RemoveDir "$1/installer"

  mkdir -p "$1"/installer/sapcar; }
# mkdir    "$1"/installer/ual_afl; }


#--------------------------------------
function Download_sapcar {

  echo
  echo ". Downloading '/net/build-drops-wdf/dropzone/nett_dev/sapcar.exe'"

  cp  /net/build-drops-wdf/dropzone/nett_dev/sapcar.exe   $1/installer/sapcar/

  if [ ! -f $1/installer/sapcar/sapcar.exe ]; then
    abort 1  "Failed to download 'sapcar.exe'"; fi; }


#--------------------------------------
#function Download_ualafl {

#  echo
#  echo ". Downloading '/net/build-drops-wdf/dropzone/nett_dev/ual_afl.sar'"

#  cp  /net/build-drops-wdf/dropzone/nett_dev/ual_afl.sar   $1/installer/ual_afl/
#  if [ ! -f $1/installer/ual_afl/ual_afl.sar ]; then
#    abort 1  "Failed to download 'ual_afl.sar'"; fi

#  echo ". Uncompressing '$1/installer/ual_afl/ual_afl.sar'"

#  cd $1/installer/ual_afl
#  $1/installer/sapcar/sapcar.exe  -xf  $1/installer/ual_afl/ual_afl.sar > /dev/nul

#  STATUS=$?
#  if [ $STATUS -ne 0 ]; then
#    abort $STATUS  "Error decompressing '$1/installer/ual_afl/ual_afl.sar'"; fi

#  rm -f $1/installer/ual_afl/ual_afl.sar; }


#--------------------------------------
function Download_HanaDb {

  FILE=SAP_HANA_DATABASE100_092_Linux_on_x86_64.SAR

  echo
  echo ". Downloading 'http://moo-repo.wdf.sap.corp:8080/static/pblack/newdb/NewDB100/rel/092/server/linuxx86_64/$FILE'"

  cd $1/installer

  wget -o /dev/nul http://moo-repo.wdf.sap.corp:8080/static/pblack/newdb/NewDB100/rel/092/server/linuxx86_64/$FILE
  if [ ! -f $FILE ]; then
    abort 1 "Failed to download '$FILE'"; fi

  echo ". Uncompressing '$1/installer/$FILE'"
  echo

  $1/installer/sapcar/sapcar.exe  -xf  $FILE > /dev/nul

  STATUS=$?
  if [ $STATUS -ne 0 ]; then
    error $STATUS "Error decompressing '$FILE'"; fi

  rm -f $FILE
  chmod -R 755 SAP_HANA_DATABASE/*; }


#--------------------------------------
function DeleteContainer092 {

  docker ps -a | awk '$NF == "$HANA$REV"'

  if [ $? -ne 0 ]; then
    return; fi

  echo ". Deleting container $HANA$REV"

  docker ps | grep $HANA$REV

  if [ $? -eq 0 ]; then
    docker stop $HANA$REV; fi

  docker rm $HANA$REV > /dev/nul; }


#--------------------------------------
function DeleteImage092 {

  docker images | grep $HANA$REV

  if [ $? -eq 0 ]; then
    echo ". Deleting image $HANA$REV"
    docker rmi $REGISTRY/hana/$HANA$REV > /dev/nul; fi; }


#--------------------------------------
function BuildImageHana092 {

  echo ". Creating container, installing Hana"

  cd $LOCATION

  docker run --name=$HANA$REV --net=host --privileged \
      -v /etc/localtime:/etc/localtime \
      -v $LOCATION/installer:/setup \
      -v $LOCATION/InstallHana$REV.sh:/InstallHana$REV.sh \
      $REGISTRY/rh70/rh70lib \
      /bin/sh -c /InstallHana$REV.sh

  STATUS=$?  
  if [ $STATUS -ne 0 ]; then
    abort $STATUS  "Failed to install Hana$REV in the container"; fi; }


#--------------------------------------
function WriteImageHana092 {

  echo
  echo ". Committing container to an image"

  docker commit $HANA$REV $REGISTRY/hana/$HANA$REV

  STATUS=$?
  if [ $STATUS -ne 0 ]; then
    abort $STATUS "Failed to commit $HANA$REV to an image"; fi; }


#--------------------------------------
function PushImageHana092 {

  echo
  echo ". Pushing image to the registry server"

  docker push $HANA$REV

  STATUS=$?
  if [ $STATUS -ne 0 ]; then
    abort $STATUS "Failed to push $HANA$REV to registry"; fi; }


#---------------  MAIN
clear
#set -x

HANA="hana"
REV="092"
REGISTRY=dewdftzlidck:5000
LOCATION=/root/docker/build/$HANA/$REV

CleanupBuildSpace  $LOCATION

Download_sapcar   $LOCATION
#Download_ualafl   $LOCATION
Download_HanaDb   $LOCATION

DeleteContainer092
DeleteImage092

BuildImageHana092
WriteImageHana092
#PushImageHana092



#--------------------------------------
# read -s PASSWORD
# if [ ! "${PASSWORD}" ]; then
#   exit 1; fi

# Use smbclient instead of 'mount -t cifs' -> 'input/output error'
# echo ". Downloading '\\production\newdb\NewDB100\rel\092\server\linuxx86_64\SAP_HANA_DATABASE'"
# smbclient -W $DOMAIN -U $USER%$PASSWORD //production/newdb -c 'prompt;recurse;cd NewDB100\rel\092\server\linuxx86_64\SAP_HANA_DATABASE\;mget *' 2>&1 >/dev/null
