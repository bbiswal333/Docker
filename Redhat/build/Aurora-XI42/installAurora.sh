###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com
#
###############################################################################

# TODO: manage errors

# TO BE DEFINED: BuildNum passed as parameter 
param=1851_greatest
mount -t nfs -o nolock 10.17.136.53:/dropzone/aurora_dev/aurora42_cons/$param/linux_x64/release/packages/BusinessObjectsServer /mnt/nfs/

su - qaunix
export LANG=en_US.utf8 LC_ALL=en_US.utf8

/mnt/nfs/setup.sh -r /mnt/response.ini

umount /mnt/nfs/
