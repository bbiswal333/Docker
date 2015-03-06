###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com
#
###############################################################################

#!/bin/sh

FOLDER=/hana
SID=DCK
PASSWORD=Password01

mkdir $FOLDER

#--------------- HANA installation
/setup/SAP_HANA_DATABASE/hdbinst --b --sid $SID -password $PASSWORD -system_user_password $PASSWORD --sapmnt=$FOLDER --datapath=$FOLDER --logpath=$FOLDER --ignore=check_hardware
STATUS=$?
if [ $STATUS -ne 0 ]; then
  exit $STATUS; fi


#--------------- UAL_AFL package installation
echo -e "$SID\n$PASSWORD" | /setup/ual_afl/hdbinst
STATUS=$?
if [ $STATUS -ne 0 ]; then
  exit $STATUS; fi


#--------------- generated-script to indicate Hana install location
SCRIPT="/HanaFolder.sh"
echo "echo $FOLDER" > $SCRIPT
chmod 755 $SCRIPT
