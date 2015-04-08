
###############################################################################
#
#  AUTHOR: sandrine.gangnebien@sap.com
#          gerald.braunwarth@sap.com
#
###############################################################################


#--------------------------------------
function RenameHostname {

  # registered hostname at install: lowercase and trim
  NAME=$($FOLDER/DCK/hdblcm/hdblcm --list_systems | awk -F: '/host:/ { print tolower($2) }')
  NAME=${NAME/ /}

  # this machine hostname to upper
  HOST=$(echo $(hostname) | awk '{ print tolower($0) }')

  if [ "$HOST" != "$NAME" ]; then
    $FOLDER/DCK/hdblcm/hdblcm -b --action=rename_system --target_password=$PASSWORD --hostmap=$NAME=$HOST; fi }
  # /hana/shared/DCK/hdblcm/hdblcm -b --action=rename_system --hostmap=dewdftv00125.dhcp.pgdev.sap.corp=demoserver --target_password=Password01  --scope=instance


#--------------------------------------
function RenameInstance {

  $FOLDER/DCK/global/hdb/install/bin/hdbrename  -b  --number=$1 --source_password=$PASSWORD --target_password=$PASSWORD

  if [ $? != 0 ]; then
    exit 1; fi }


#---------------  MAIN
set -x

MAXINSTANCE="097"
PASSWORD="Password01"

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


FOLDER=$(/HanaFolder.sh)
if [ ! "${FOLDER}" ]; then
  exit 1; fi


RenameHostname
if [ "$1" != $MAXINSTANCE ]; then
  RenameInstance $1; fi


/bin/sh
if [ $? != 0 ]; then
  exit 1; fi
