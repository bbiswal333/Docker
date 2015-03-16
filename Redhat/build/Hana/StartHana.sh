
###############################################################################
#
#  AUTHOR: sandrine.gangnebien@sap.com
#
###############################################################################


sysctl kernel.shmall=14807668
if [ $? != 0 ]; then
  exit 1; fi


sysctl kernel.shmmax=1073741824
if [ $? != 0 ]; then
  exit 1; fi


su - dckadm -c "HDB start"
if [ $? != 0 ]; then
  exit 1; fi


/bin/sh
if [ $? != 0 ]; then
  exit 1; fi

