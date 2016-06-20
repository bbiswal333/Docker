#!/bin/bash

###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - June 2016 -
#  PURPOSE: install Hana XSA running inside a container
#
###############################################################################


#### DEBUG PURPOSE ####
#--------------------------------------
function _PAUSE {
  read -p "PAUSE "; }



#---------------  MAIN

set -x

## WORKAROUND
yum install -y cifs-utils
share=mo-a9901609a
mkdir /net/$share
if ! mount -t cifs //$share.mo.sap.corp/XSA /net/$share -o domain=global,user=service.infra.frmwk,password=$(cat /scripts/password); then exit 1; fi
## ENDWORKAROUND
_PAUSE


#### NFS MOUNTS
if ! mount -t nfs derotvi0157.wdf.sap.corp:/derotvi0157a_ld9252/q_files        $newdb_archive; then exit 1; fi
if ! mount -t nfs derotvi0303.wdf.sap.corp:/derotvi0303a_newdb_dev/q_newdb_dev $newdb_dev;     then exit 1; fi


hostFQDN=$(hostname -f)
number=97
secret="Toor1234"
org="PROD"

# HDBLCM_LOGDIR_COPY="/scripts"
# HDB_INSTALLER_TRACE_FILE="HDB_INSTALLER_TRACE_FILE"

#### XSA INSTALLATION

#$newdb_archive/NewDB100/rel/120/lcm/linuxx86_64/SAP_HANA_LCM/hdblcm \
#$newdb_archive/HANA_WS_COR/released_weekstones/LastWS/lcm/linuxx86_64/SAP_HANA_LCM/hdblcm \

# --xs_components=xsac_monitoring,xsac_services,xsac_shine \

/net/$share/51050846/DATA_UNITS/HDB_LCM_LINUX_X86_64/hdblcm \
  -b \
  --action=install \
  --sid=$sid \
  --number=$number \
  --hostname=$hostFQDN \
  -sapadm_password          $secret \
      -password             $secret \
      -org_manager_password $secret \
      -system_user_password $secret \
  --org_name=$org \
  --components=xs \
  --xs_components=xsac_monitoring,xsac_services \
  --system_usage=custom \
  --sapmnt=$saphome/shared --datapath=$saphome/data --logpath=$saphome/log \
  --remote_execution=ssh \
  --install_hostagent=off \
  --add_local_roles=xs_worker \
  --import_xs_content=yes \
  --component_dirs=/net/$share/51050846/DATA_UNITS/XSA_RT_10_LINUX_X86_64,/net/$share/51050846/DATA_UNITS/XSA_CONTENT_10
# --component_dirs=$newdb_dev/POOL_EXT/external_components/XSA_RT/SPS12/LASTWS/XSA_RT/linuxx86_64,$newdb_dev/POOL_EXT/external_components/XSA_RT/SPS12/LASTWS/XSA_CONT
# --component_dirs=$newdb_dev/POOL_EXT/external_components/XSA_RT/SPS12/LASTREL/XSA_RT/linuxx86_64,$newdb_dev/POOL_EXT/external_components/XSA_RT/SPS12/LASTREL/XSA_CONT


umount $newdb_dev
umount $newdb_archive
## WORKAROUND
umount /net/$share
## ENDWORKAROUND


#### PATH variable
export PATH=$PATH:$saphome/shared/$sid/HDB$number/exe/


#### CREATE SHINE USER
hdbsql -i $number -n localhost:3${number}15 -u SYSTEM -p $secret \
       "CREATE USER SHINE_USER PASSWORD \"Sap12345\" NO FORCE_FIRST_PASSWORD_CHANGE \
       SET PARAMETER XS_RC_XS_CONTROLLER_ADMIN = 'XS_CONTROLLER_ADMIN',XS_RC_XS_AUTHORIZATION_ADMIN = 'XS_AUTHORIZATION_ADMIN',XS_RC_SHINE_ADMIN = 'SHINE_ADMIN'"


#### GIT CLONE SHINE
cd /usr/repo/git
if ! git clone https://github.wdf.sap.corp/refapps/shine.git; then exit 1; fi


#### MAVEN BUILD
cd shine
if ! mvn clean install -s cfg/settings.xml -P release.build; then exit 1; fi


#### LOGIN TO XSA
if ! xs login -a https://$hostFQDN:3${number}30 -u XSA_ADMIN -p $secret -o $org -s SAP --skip-ssl-validation; then exit 1; fi


#### INSTALL SHINE
file=$(ls /usr/repo/git/shine/assembly/target/*.ZIP)
if [ ! ${file}]; then exit 1; fi
if ! xs install $file; then exit 1; fi


#### PROPERLY STOP RUNNING APP AND SERVICES
sidadm=$(echo $sid| tr [A-Z] [a-z])adm
su - $sidadm -c 'HDB stop'
