###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com
#
###############################################################################

# TODO: manage errors

# TO BE DEFINED: Buildfolder length to be passed as parameter 

if [ ! "${1}" ]; then
  echo "Usage installAurora.sh  <BuildFolder>"
  exit 1; fi

mount -t nfs -o nolock 10.17.136.53:/dropzone/aurora_dev/aurora42_cons/$1/linux_x64/release/packages/BusinessObjectsServer /mnt/nfs/

su - qaunix
export LANG=en_US.utf8 LC_ALL=en_US.utf8

/mnt/nfs/setup.sh -r /mnt/response.ini

umount /mnt/nfs/
