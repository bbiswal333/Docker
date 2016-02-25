###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - February 2016 -
#  PURPOSE: 
#      - writes user variables to swarm-request.ini expected by swarm-deploy.sh
#      - swarm-request.ini is written one folder above to be shared between jobs
#
###############################################################################

#set -x

file=../swarm-request.ini

printf "\n# DISCOVERY\n# -----\n"       >  $file
printf "zookeepers=\"$zookeepers\"\n"   >> $file
printf "\n# MANAGERS\n# -----\n"        >> $file
printf "managers=\"$managers\"\n"       >> $file
printf "\n# NODES\n# -----\n"           >> $file
printf "nodes=\"$nodes\"\n"             >> $file
printf "\n# CLUSTER ID\n# ----------\n" >> $file
printf "token=$token\n"                 >> $file
printf "\n# SECURITY\n# ----------\n"   >> $file
printf "tls=$tls\n"                     >> $file
printf "engineport=$engineport\n"       >> $file
printf "\nmanagerport=$managerport\n"   >> $file

echo
cat $file
echo

