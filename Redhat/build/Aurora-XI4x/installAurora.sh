###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com
#
###############################################################################

### TO BE DEFINED: Buildfolder length to be passed as parameter 

#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage installAurora.sh  <BuildFolder>"
  exit 1; fi

mount -t nfs -o nolock derotvi0082.wdf.sap.corp:/dropzone/aurora_dev/$1/linux_x64/release/packages/BusinessObjectsServer /mnt/nfs/
if [ $? -ne 0 ]; then
  echo "NFS mount failed"
  exit 1; fi

# ALIAS in /etc/hosts
cp /etc/hosts /etc/hosts.old
if grep 127.0.0.1 /etc/hosts > /dev/null; then
  sed "/127.0.0.1/s/localhost/localhost  $(hostname -s)  sapboxi4x  /" /etc/hosts.old > /etc/hosts
else
  echo "127.0.0.1  localhost  $(hostname -s)  sapboxi4x" >> /etc/hosts; fi

su - qaunix -c '

  export LANG=en_US.utf8 LC_ALL=en_US.utf8
  /mnt/nfs/setup.sh -r /mnt/response.ini

  location=/usr/sap/XI4x/sap_bobj
  if [ ! -d $location ]; then
    echo "XI install failed"
    exit 1; fi

  curl -I http://localhost:10001/BOE/BI | grep OK
  if [ $? -ne 0 ]; then
    echo "XI install failed"
    exit 1; fi

  cd $location
  ./stopservers
  ./tomcatshutdown.sh
  ./sqlanywhere_shutdown.sh

  exit 0'

status=$?

umount /mnt/nfs/

if [ $status -ne 0 ]; then
  echo "XI installation failed"
  exit 1; fi
