###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com
#
###############################################################################

### TO BE DEFINED: Buildfolder length to be passed as parameter 

#!/bin/bash
set -x

if [ $# -ne 1 ]; then
  echo "Usage installAurora.sh  <BuildFolder>"
  exit 1; fi

dropShare=derotvi0082.wdf.sap.corp:/dropzone/aurora_dev/$1/linux_x64/release/packages

endpoint=BusinessObjectsServer
semaphore=packages_copy_done

timeout=960    # 16 hours
elapsed=0
inc=5
status=1

while [ $status -ne 0 -a $elapsed -le $timeout ]; do
  str=$(mount -t nfs -o nolock $dropShare /mnt/nfs/ 2>&1)
  status=$?
  if [ $status -ne 0 ]; then
    echo "Drop still copying, retry MOUNT in $inc minutes"
    elapsed=$((elapsed+inc))
    sleep ${inc}m; fi
done

if [ $status -ne 0 ]; then
  echo "  . Dropzone NFS mount failed after $timeout minutes of retries"
  echo
  exit 1; fi

while [ ! -f /mnt/nfs/$semaphore ]; do
  echo "Waiting for COPYDONE semaphore file, retry in 3 minutes"
  sleep 3m; done

# ALIAS in /etc/hosts
cp /etc/hosts /etc/hosts.old
if grep 127.0.0.1 /etc/hosts > /dev/null; then
  sed "/127.0.0.1/s/localhost/localhost  $(hostname -s)  sapboxi4x  /" /etc/hosts.old > /etc/hosts
else
  echo "127.0.0.1  localhost  $(hostname -s)  sapboxi4x" >> /etc/hosts; fi

su - qaunix -c '

  export LANG=en_US.utf8 LC_ALL=en_US.utf8
  endpoint=BusinessObjectsServer

  /mnt/nfs/$endpoint/setup.sh -r /mnt/response.ini

  location=/usr/sap/XI4x/sap_bobj
  if [ ! -d $location ]; then
    echo "XI install failed"
    exit 1; fi

  curl -s -I http://localhost:10001/BOE/BI | grep OK
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
