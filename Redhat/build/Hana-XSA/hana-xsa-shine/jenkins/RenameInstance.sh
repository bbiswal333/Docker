#!/bin/bash

###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - August 2016 -
#  PURPOSE: rename the Hana instance at the container startup
#
###############################################################################

set -x

if [ $# -ne 2 ]; then
  echo "Expected parameters: <SID>  <InstanceNumber>"
  echo "Example: ./RenameInstance.sh  DCK  00"
  exit 1; fi

newsid=$1
newnumber=$2

OLDHOST=$($saphome/shared/$sid/hdblcm/hdblcm --list_systems | grep -i 'host:' | awk '$2 { print tolower($2) }')
NEWHOST=$(echo $(hostname -f) | awk '{ print tolower($0) }')


#$saphome/shared/$sid/hdblcm/hdblcm -b --action=rename_system \
#                                      --source_password=$secret --target_password=$secret \
#                                      --hostmap=$OLDHOST=$NEWHOST

if ! $saphome/shared/$sid/hdblcm/hdblcm -b --action=rename_system \
                                           --source_password=$secret --target_password=$secret \
                                           --hostmap=$OLDHOST=$NEWHOST \
                                           --source_sid=$sid --target_sid=$newsid \
                                           --number=$newnumber; then
  echo "Failed to rename instance";
  exit 1; fi

set +x
while true; do sleep 5; done
