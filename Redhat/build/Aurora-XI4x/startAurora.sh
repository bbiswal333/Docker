###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com
#
###############################################################################


su - qaunix -c "

  /usr/sap/XI4x/sap_bobj/sqlanywhere_startup.sh
  /usr/sap/XI4x/sap_bobj/startservers
  /usr/sap/XI4x/sap_bobj/tomcatstartup.sh"

while true; do sleep 300; done
