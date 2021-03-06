###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com
#
###############################################################################

#!/bin/sh

PATHINST=/hana/shared
PATHDATA=/hana/data
PATHLOG=/hana/log
SID=DCK
MAXINSTANCE=97
PASSWORD=Password01
SCRIPT="/HanaFolder.sh"


mkdir -p $PATHINST
mkdir    $PATHDATA
mkdir    $PATHLOG

#--------------- HANA installation
# /setup/SAP_HANA_DATABASE/hdbinst --b --sid $SID --number=$MAXINSTANCE -password $PASSWORD -system_user_password $PASSWORD --sapmnt=$PATHINST --datapath=$PATHDATA --logpath=$PATHLOG --ignore=check_hardware

cd /setup/SAP_HANA_DATABASE
./hdblcm --b --action=install --components=server --sid $SID --number=$MAXINSTANCE -password $PASSWORD -sapadm_password $PASSWORD  -system_user_password $PASSWORD \
             --sapmnt=$PATHINST --datapath=$PATHDATA --logpath=$PATHLOG --ignore=check_hardware
STATUS=$?
if [ $STATUS -ne 0 ]; then
  exit $STATUS; fi


###  MARCH 2013 : UAL install removed, decided that this install belongs to BUILD process
#--------------- UAL_AFL package installation
# echo -e "$SID\n$PASSWORD" | /setup/ual_afl/hdbinst
# STATUS=$?
# if [ $STATUS -ne 0 ]; then
#   exit $STATUS; fi


#--------------- generated-script to indicate Hana install location
echo "echo $PATHINST" > $SCRIPT
chmod 755 $SCRIPT
