###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com
#
###############################################################################


# ALIAS in /etc/hosts
cp /etc/hosts /etc/hosts.old
if grep 127.0.0.1 /etc/hosts > /dev/null; then
  sed "/127.0.0.1/s/localhost/localhost  $(hostname -s)  sapboxi4x  /" /etc/hosts.old > /etc/hosts
else
  echo "127.0.0.1  localhost  $(hostname -s)  sapboxi4x" >> /etc/hosts; fi


su - qaunix -c "

  /usr/sap/XI4x/sap_bobj/sqlanywhere_startup.sh
  /usr/sap/XI4x/sap_bobj/startservers
  /usr/sap/XI4x/sap_bobj/tomcatstartup.sh"

/usr/sbin/sshd

while true; do sleep 5; done
