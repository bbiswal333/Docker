set -x

#curl -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jre/8u91-b27/jre-8u91-linux-x64.rpm > jre-8u91-linux-x64.rpm
if ! rpm -ivh /scripts/jre-8u91-linux-x64.rpm; then exit 1; fi

mkdir -p /net/sapmnt.production.makeresults.newdb_dev/
if ! mount -t nfs derotvi0303.wdf.sap.corp:/derotvi0303a_newdb_dev/q_newdb_dev /net/sapmnt.production.makeresults.newdb_dev; then exit 1; fi

mkdir -p /net/sapmnt.production.makeresults.newdb_archive
if ! mount -t nfs derotvi0157.wdf.sap.corp:/derotvi0157a_ld9252/q_files /net/sapmnt.production.makeresults.newdb_archive; then exit 1; fi

#/net/sapmnt.production.makeresults.newdb_archive/HANA_WS_COR/released_weekstones/LastWS/lcm/linuxx86_64/SAP_HANA_LCM/hdblcm \
#  -b \
#  --action=install \
#  --components=xs \
#  --sid=DCK \
#  --number=97 \
#  -password Password01 -sapadm_password Password01 -org_manager_password Password01 -system_user_password Password01 \
#  --sapmnt=/hana/shared --datapath=/hana/data --logpath=/hana/log \
#  --component_dirs=/net/sapmnt.production.makeresults.newdb_dev/POOL_EXT/external_components/XSA_RT/SPS12/LASTREL/XSA_RT/linuxx86_64,\
#/net/sapmnt.production.makeresults.newdb_dev/POOL_EXT/external_components/XSA_RT/SPS12/LASTREL/XSA_CONT

hostFQDN=$(hostname -f)
secret="Password01"

HDBLCM_LOGDIR_COPY="/scripts"
HDB_INSTALLER_TRACE_FILE="HDB_INSTALLER_TRACE_FILE"

/net/sapmnt.production.makeresults.newdb_archive/HANA_WS_COR/released_weekstones/LastWS/lcm/linuxx86_64/SAP_HANA_LCM/hdblcm \
  -b \
  --action=install \
  --components=xs \
  --xs_components=xsac_monitoring,xsac_services,xsac_shine \
  --system_usage=custom \
  --sid=DCK \
  --number=97 \
  --hostname=$hostFQDN \
  -password $secret -sapadm_password $secret -org_manager_password $secret -system_user_password $secret \
  --org_name=REF \
  --remote_execution=ssh \
  --install_hostagent=off \
  --add_local_roles=xs_worker \
  --import_xs_content=yes \
  --component_dirs=/net/sapmnt.production.makeresults.newdb_dev/POOL_EXT/external_components/XSA_RT/SPS12/LASTWS/XSA_RT/linuxx86_64,\
/net/sapmnt.production.makeresults.newdb_dev/POOL_EXT/external_components/XSA_RT/SPS12/LASTWS/XSA_CONT
