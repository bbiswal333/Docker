
###############################################################################
#
#  AUTHOR: sandrine.gangnebien@sap.com
#          gerald.braunwarth@sap.com
#
###############################################################################


#--------------------------------------
function RenameInstance {

  # registered hostname at install: lowercase and trim
  OLDHOST=$($FOLDER/DCK/hdblcm/hdblcm --list_systems | awk -F: '/host:/ { print tolower($2) }')
  OLDHOST=${OLDHOST/ /}

  # the hostname of this machine, to upper
  NEWHOST=$(echo $(hostname) | awk '{ print tolower($0) }')

  # current Instance NUMBER
  INSTANCE=$($FOLDER/DCK/hdblcm/hdblcm --list_systems | awk -F: '/used instance number:/ { print $2 }')

  if [ ! ${INSTANCE} ]; then
    echo "Failed to retrieve Instance NUMBER"
    exit 1; fi

  INSTANCE=$(printf "%02d" $INSTANCE)

  if [ "$NEWHOST" == "$OLDHOST"  -a  $INSTANCE -eq $1 ]; then
    echo 0    
    return; fi

  $FOLDER/DCK/global/hdb/install/bin/hdbrename -b --source_password=$PASSWORD --target_password=$PASSWORD  --hostmap=$OLDHOST=$NEWHOST --number=$1

  echo 1; }

# $FOLDER/DCK/hdblcm/hdblcm -b --action=rename_system --target_password=$PASSWORD --hostmap=$NAME=$HOST --scope=instance


#---------------  MAIN
#set -x

PASSWORD="Password01"
SHMALL=14807668
SHMMAX=1073741824
FOLDER=$(/HanaFolder.sh)


if [ ! "${FOLDER}" ]; then
  exit 1; fi


if [ ! "${1}" ]; then
  echo "Usage: StartHana <NewInstanceNumber>"
  exit 1; fi


sysctl kernel.shmall=$SHMALL
if [ $? != 0 ]; then
  exit 1; fi


sysctl kernel.shmmax=$SHMMAX
if [ $? != 0 ]; then
  exit 1; fi


STARTED=$(RenameInstance $1)

if [ $STARTED -eq 0 ]; then
  su - dckadm -c "HDB start"
  if [ $? != 0 ]; then
    exit 1; fi; fi


/bin/sh
if [ $? != 0 ]; then
  exit 1; fi
