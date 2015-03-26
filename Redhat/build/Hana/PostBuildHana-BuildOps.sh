###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com
#
###############################################################################

#!/bin/sh


# DEBUG PURPOSE
#--------------------------------------
function _PAUSE {
  read -p "PAUSE "; }


#--------------------------------------
function CheckRevParameter {
  if [ ! "${1}" ]; then
    echo "Usage <script.sh>  <RevisionNumber>. Example: <script> 092"
    exit 1; fi }


#--------------------------------------
function SetScriptLocation {
  cd "$1"; }


#--------------------------------------
function CheckBuildWorkSpace {
  if [ ! -d $1 ]; then
    echo "Workspace for build '$1' does not exist"
    exit 1; fi }


#--------------------------------------
function InitVars {
  export REGISTRY="dewdftzlidck:5000"
  export SOFTWARE="hana"
  export HANA="hana"
  export REV=$1
  export HANACLIENT="hanaclient"
  export KEY_DATABASE="DATABASE"
  export VERSION=""
  export LOCATION=$(pwd)

  PTH=$(ls -d $REV/installer/deployer/a*)
  export DEPLOYER=$PTH/bin/artifactdeployer
  export REPO="http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.snapshots/"; }


#--------------------------------------
function hanaclientTar {

  echo
  echo ". tar $REV/$HANACLIENT.tar"

  tar -cf $REV/$HANACLIENT.tar  $REV/$HANACLIENT

  if [ $? != 0 -o ! -f $REV/$HANACLIENT.tar ]; then
    echo "Failed to 'tar $REV/$HANACLIENT.tar'"
    exit 1; fi }

#  rm -rf $REV/$HANACLIENT; }


#--------------------------------------
function hanaclientTarGzip {

  echo ". gzip $REV/$HANACLIENT.tar"

  gzip -f $REV/$HANACLIENT.tar

  if [ $? != 0 -o ! -f $REV/$HANACLIENT.tar.gz ]; then
    echo "Failed to 'gzip $REV/$HANACLIENT.tar.gz'"
    exit 1; fi }


#--------------------------------------
function ImageTar {

  echo
  echo ". save $REV/$HANA$REV.tar"

  docker save -o $REV/$HANA$REV.tar $REGISTRY/$SOFTWARE/$HANA$REV

  if [ $? != 0 -o ! -f $REV/$HANA$REV.tar ]; then
    echo "Failed to export image to '$HANA$REV.tar'"
    exit 1; fi }


#--------------------------------------
function ImageTarTar {

  echo
  echo ". tar $REV/$HANA$REV.tar.tar"

  tar -cf $REV/$HANA$REV.tar.tar  $REV/$HANA$REV.tar

  if [ $? != 0 -o ! -f $REV/$HANA$REV.tar.tar ]; then
    echo "Failed to generate '$HANA$REV.tar.tar'"
    exit 1; fi }

# rm -rf $REV/$HANA$REV.tar; }


#--------------------------------------
function ImageTarTarGzip {

  echo ". gzip $REV/$HANA$REV.tar.tar.gz"

  gzip -f $REV/$HANA$REV.tar.tar

  if [ $? != 0 -o ! -f $REV/$HANA$REV.tar.tar.gz ]; then
    echo "Failed to generate '$HANA$REV.tar.tar.gz'"
    exit 1; fi }


#--------------------------------------
function CreateFileGroovy {

  echo
  echo ". Create hana.groovy"

  echo "
    artifacts builderVersion:\"1.1\", {
      group \"com.sap.docker.images\", {
        artifact \"$HANA$REV\", {
          file \"$LOCATION/$REV/$HANA$REV.tar.tar.gz\", extension:\"tar.gz\"
          metadata \"hana_docker_path...\", typeDisplayName:\"Linuxx86_64 hana docker\"
        }
      }
      group \"com.sap.docker.$HANACLIENT\", {
        artifact \"$HANACLIENT\", {
          file \"$LOCATION/$REV/$HANACLIENT.tar.gz\", extension:\"tar.gz\"
          metadata \"hana_client_path...\", typeDisplayName:\"Linuxx86_64 hana client\"
        }
      }
    }" > $LOCATION/$REV/installer/deployer/hana.groovy; }


#--------------------------------------
function CreateFileHanaDf {

  echo ". Create hana.fr"

  $DEPLOYER pack  -f $REV/installer/deployer/hana.groovy -p "$LOCATION/$REV/hana.df" > /dev/null

  if [ $? -ne 0 ]; then
    echo "Failed to generate hana.df"
    exit 1; fi }


#--------------------------------------
function GetHanaDbFullVersion {

  echo
  echo ". Retreive Hana full version"

  FOLDERDB=$(ls -d $REV/installer/S* | grep $KEY_DATABASE)
  VERSION=$(cat $FOLDERDB/server/manifest | grep --word-regexp  "fullversion" | awk '$2 { print $2 }')
  VERSION=${VERSION:0:8}; }


#--------------------------------------
function UploadNexus {

  echo
  echo ". Upload to Nexus"
  echo

  $DEPLOYER deploy --repo-url $REPO --package-file $LOCATION/$REV/hana.df --artifact-version $VERSION --artifact-version-suffix=-SNAPSHOT

  if [ $? -ne 0 ]; then
    echo "Failed to upload hana.df to Nexus"
    exit 1; fi }


--------- MAIN ------------------------
clear
#set -x

CheckRevParameter   $1

SetScriptLocation   $(dirname $0)
CheckBuildWorkSpace $1
InitVars            $1

hanaclientTar
hanaclientTarGzip

ImageTar
ImageTarTar
ImageTarTarGzip

CreateFileGroovy
CreateFileHanaDf

GetHanaDbFullVersion
UploadNexus
