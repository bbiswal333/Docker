#!/bin/bash

###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - June 2016 -
#  PURPOSE: install Hana XSA running inside a container
#
###############################################################################

set -x

if ! mount -t nfs derotvi0157.wdf.sap.corp:/derotvi0157a_ld9252/q_files        $newdb_archive; then exit 1; fi
if ! mount -t nfs derotvi0303.wdf.sap.corp:/derotvi0303a_newdb_dev/q_newdb_dev $newdb_dev;     then exit 1; fi

hostFQDN=$(hostname -f)
secret="Toor1234"

# HDBLCM_LOGDIR_COPY="/scripts"
# HDB_INSTALLER_TRACE_FILE="HDB_INSTALLER_TRACE_FILE"

$newdb_archive/HANA_WS_COR/released_weekstones/LastWS/lcm/linuxx86_64/SAP_HANA_LCM/hdblcm \
  -b \
  --action=install \
  --components=xs \
  --xs_components=xsac_monitoring,xsac_services,xsac_shine \
  --system_usage=custom \
  --sid=$sid \
  --number=97 \
  --hostname=$hostFQDN \
  --sapmnt=$saphome/shared --datapath=$saphome/data --logpath=$saphome/log \
  -sapadm_password $secret -password $secret -org_manager_password $secret -system_user_password $secret \
  --org_name=REF \
  --remote_execution=ssh \
  --install_hostagent=off \
  --add_local_roles=xs_worker \
  --import_xs_content=yes \
  --component_dirs=$newdb_dev/POOL_EXT/external_components/XSA_RT/SPS12/LASTWS/XSA_RT/linuxx86_64,$newdb_dev/POOL_EXT/external_components/XSA_RT/SPS12/LASTWS/XSA_CONT
