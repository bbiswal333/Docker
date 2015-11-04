###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com
#
###############################################################################


su - qaunix -c "

  /usr/sap/XI42/sap_bobj/sqlanywhere_startup.sh
  /usr/sap/XI42/sap_bobj/startservers
  /usr/sap/XI42/sap_bobj/tomcatstartup.sh"

while true; do sleep 300; done
