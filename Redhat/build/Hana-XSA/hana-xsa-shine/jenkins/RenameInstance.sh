#!/bin/bash

set -x

OLDHOST=$($saphome/shared/$sid/hdblcm/hdblcm --list_systems | grep -i 'host:' | awk '$2 { print tolower($2) }')
NEWHOST=$(echo $(hostname -f) | awk '{ print tolower($0) }')
newsid='SI5'
newnumber='05'

#$saphome/shared/$sid/hdblcm/hdblcm -b --action=rename_system --source_password=$secret --target_password=$secret --hostmap=$OLDHOST=$NEWHOST
$saphome/shared/$sid/hdblcm/hdblcm -b --action=rename_system \
                                      --source_password=$secret --target_password=$secret \
                                      --hostmap=$OLDHOST=$NEWHOST \
                                      --source_sid=$sid --target_sid=$newsid \
                                      --number=$newnumber
echo $?
