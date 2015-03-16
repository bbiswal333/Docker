###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com
#
###############################################################################

REGISTRY="dewdftzlidck:5000"
SOFTWARE="hana"
HANA="hana"
REV="092"


# export Docker image to .TAR file
docker save -o $HANA$REV.tar $REGISTRY/$SOFTWARE/$HANA/$REV
if [ $? != 0 ]; then
  echo "Failed to export image to '$HANA$REV.tar'"
  exit 1; fi


# BuildOps tool requires 2 levels of TAR. Output = hana092.tar.tar
tar -cvf hana$REV.tar.tar  hana$REV.tar
if [ $? != 0 ]; then
  echo "Failed to generate '$HANA$REV.tar.tar'"
  exit 1; fi


# High compression before copying to NEXUS. Output = hana092.tar.tar.gz
gzip hana$REV.tar.tar
if [ $? != 0 ]; then
  echo "Failed to generate '$HANA$REV.tar.tar.gz'"
  exit 1; fi
