###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com
#
###############################################################################

REV=092


# BuildOps tool requires 2 levels of TAR
tar -cvf hana$REV.tar.tar  hana$REV.tar
if [ $? != 0 ]; then
  echo "Failed to TAR 'hana$REV.tar'"
  exit 1; fi


# High compression before copying to NEXUS
gzip hana$REV.tar.tar
if [ $? != 0 ]; then
  echo "Failed to GZIP 'hana$REV.tar.tar'"
  exit 1; fi
