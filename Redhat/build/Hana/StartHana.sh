
###############################################################################
#
#  AUTHOR: sandrine.gangnebien@sap.com
#          gerald.braunwarth@sap.com
#
###############################################################################

#set -x

PASSWORD=Password01

if [ ! "${1}" ]; then
  exit 1; fi


sysctl kernel.shmall=14807668
if [ $? != 0 ]; then
  exit 1; fi


sysctl kernel.shmmax=1073741824
if [ $? != 0 ]; then
  exit 1; fi


su - dckadm -c "HDB start"
if [ $? != 0 ]; then
  exit 1; fi


if [ "$1" != "00" ]; then
  /hana/shared/DCK/global/hdb/install/bin/hdbrename  -b  --number=$1 --source_password=$PASSWORD --target_password=$PASSWORD
  if [ $? != 0 ]; then
    exit 1; fi; fi


/bin/sh
if [ $? != 0 ]; then
  exit 1; fi

