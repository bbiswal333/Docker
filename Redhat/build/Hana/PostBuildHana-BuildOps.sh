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


#-------- MAIN ------------------------
set -x

if [ ! "${1}" ]; then
  echo "Usage <script.sh>  <RevisionNumber>. Example: <script> 092"
  exit 1; fi


# force location to use relative path
cd $(dirname $0)


if [ ! -d $1 ]; then
  echo "Workspace for build '$1' does not exist"
  exit 1; fi


REGISTRY="dewdftzlidck:5000"
SOFTWARE="hana"
HANA="hana"
REV=$1
HANACLIENT="HanaClient"
LOCATION=$(pwd)



# create hana.groovy
echo "
  artifacts builderVersion:\"1.1\", {
    group \"com.sap.docker.images\", {
      artifact \"$HANA$REV\", {
        file \"$LOCATION/$REV/$HANA$REV.tar.tar.gz\", extension:\"tar.gz\"
        metadata \"hana_docker_path...\", typeDisplayName:\"Linuxx86_64 hana docker\"
      }
    }
    group \"com.sap.docker.hanaclient\", {
      artifact \"hanaclient\", {
        file \"$LOCATION/$REV/hanaclient.tar.gz\", extension:\"tar.gz\"
        metadata \"hana_client_path...\", typeDisplayName:\"Linuxx86_64 hana client\"
      }
    }
  }" > $LOCATION/$REV/installer/deployer/hana.groovy
#exit


# tar HANA client
tar -cf $REV/$HANACLIENT.tar  $REV/hanaclient
if [ $? != 0 -o ! -f $REV/$HANACLIENT.tar ]; then
  echo "Failed to 'tar $REV/$HANACLIENT.tar'"
  exit 1; fi

#rm -rf $REV/hanaclient


# gzip HANA client
gzip -f $REV/$HANACLIENT.tar
if [ $? != 0 -o ! -f $REV/$HANACLIENT.tar.gz ]; then
  echo "Failed to 'gzip $REV/$HANACLIENT.tar.gz'"
  exit 1; fi


# export Docker image to .TAR file
docker save -o $REV/$HANA$REV.tar $REGISTRY/$SOFTWARE/$HANA$REV
if [ $? != 0 -o ! -f $REV/$HANA$REV.tar ]; then
  echo "Failed to export image to '$HANA$REV.tar'"
  exit 1; fi


# BuildOps tool requires 2 levels of TAR. Output = hana092.tar.tar
tar -cf $REV/$HANA$REV.tar.tar  $REV/$HANA$REV.tar
if [ $? != 0 -o ! -f $REV/$HANA$REV.tar.tar ]; then
  echo "Failed to generate '$HANA$REV.tar.tar'"
  exit 1; fi

rm -rf $REV/$HANA$REV.tar


# High compression before copying to NEXUS. Output = hana092.tar.tar.gz
gzip -f $REV/$HANA$REV.tar.tar
if [ $? != 0 -o ! -f $REV/$HANA$REV.tar.tar.gz ]; then
  echo "Failed to generate '$HANA$REV.tar.tar.gz'"
  exit 1; fi
