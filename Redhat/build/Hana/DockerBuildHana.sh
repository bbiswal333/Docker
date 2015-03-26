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

  mkdir -p XXX/installer/deployer
  mkdir    XXX/installer/sapcar
  mkdir    XXX/installer/tmp; }
# mkdir    XXX/installer/ual_afl; }


#--------------------------------------
function Download_Deployer {

  FROM="http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.milestones/com/sap/prd/commonrepo/artifactdeployer/com.sap.prd.commonrepo.artifactdeployer.dist.cli/0.16.5-rc1/"
  FILE="com.sap.prd.commonrepo.artifactdeployer.dist.cli-0.16.5-rc1"

  echo
  echo ". Downloading '${FROM:0:57}/......./$FILE.tar.gz'"

  wget -o /dev/null $FROM/$FILE.tar.gz  -P XXX/installer/deployer/

  if [ ! -f XXX/installer/deployer/$FILE.tar.gz ]; then
    abort 1  "Failed to download '$FILE.tar.gz'"; fi

  echo ".   Extracting '$FILE.tar.gz'"
  gunzip XXX/installer/deployer/$FILE.tar.gz

  if [ ! -f XXX/installer/deployer/$FILE.tar ]; then
    abort 1  "Failed to extract '$FILE.tar.gz'"; fi

  tar -xf XXX/installer/deployer/$FILE.tar  -C XXX/installer/deployer/

  ls -l XXX/installer/deployer/ | grep ^d > /dev/null

  STATUS=$?
  if [ $STATUS -ne 0 ]; then
    abort $STATUS "Failed to extract '$FILE.tar'"; fi

  rm -f XXX/installer/deployer/$FILE.tar; }


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
    abort $STATUS "Error extracting '$SAR'"; fi

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
function InstallHanaClient {

  FOLDERCLT=$(ls -d S* | grep $KEY_CLIENT)
  $FOLDERCLT/hdbinst  -a  client  --path=$LOCATION/XXX/hanaclient; }


#--------------------------------------
function GetHanaRevision {

  FOLDERDB=$(ls -d S* | grep $KEY_DATABASE)
  REV=$(cat $FOLDERDB/server/manifest | grep --word-regexp  "rev-number" | awk '$2 { print $2 }')

  if [ ! "${REV}" ]; then
    abort 1 "Failed retreive HANA revision from manifest"; fi; }


#--------------------------------------
function SetRevBuildSpace {

  cd $LOCATION

  RemoveDir $REV
  mv "XXX" $REV; }


#--------------------------------------
function RemoveContainer {

  NAME=$(docker ps | awk -v name=$1 '$NF==name { print $NF }')

  if [ ${NAME} ]; then
    echo ". Stopping container $1"
    docker stop $1 > /dev/null; fi

  NAME=$(docker ps -a | awk -v name=$1 '$NF==name { print $NF }')

  if [ ${NAME} ]; then
    echo ". Deleting container $1"
    docker rm $1 > /dev/null; fi; }


#--------------------------------------
function DeleteBuildContainer {
  RemoveContainer $HANA$REV-$INSTANCE; }


#--------------------------------------
function DeleteContainers {

  for CONTAINER in $( docker ps -a | awk -v image="$REGISTRY/$SOFTWARE/$HANA$REV:$TAG" '$2==image { print $NF }' ); do
    RemoveContainer $CONTAINER; done; }


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

Download_Deployer
Download_sapcar
#Download_ualafl
Download_Hana

InstallHanaClient

GetHanaRevision
SetRevBuildSpace

DeleteBuildContainer
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
