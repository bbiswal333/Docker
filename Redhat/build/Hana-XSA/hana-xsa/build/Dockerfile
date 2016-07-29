FROM docker.wdf.sap.corp:50000/hanaxsshine/weekstone/hana-installer

MAINTAINER gerald.braunwarth@sap.com

#### UPLOAD INSTALLER
#COPY  mo-a9901609a/51050846     /mo-a9901609a/51050846

#### HANA INSTALL OPTIONS
ENV sid="DCK" \
    number="97" \
    secret="Toor1234" \
    org="REF" \
    space="PROD" \
    saphome="/usr/sap/hana"

#### Delayed variables expansion of previous ENV
ENV PATH=$PATH:$saphome/shared/$sid/HDB$number/exe/:$saphome/shared/$sid/xs/bin/

RUN \
    mkdir -p $saphome/{shared,data,log}; \

    #### INSTALL HANA
    if ! /installer/51050846/DATA_UNITS/HDB_LCM_LINUX_X86_64/hdblcm \
      -b \
      --action=install \
      --sid=$sid \
      --number=$number \
      --hostname=$(hostname -f) \
      -sapadm_password          $secret \
          -password             $secret \
          -org_manager_password $secret \
          -system_user_password $secret \
      --org_name=$org \
      --prod_space_name=$prod \
      --components=xs \
      --xs_components=xsac_monitoring,xsac_services \
      --system_usage=custom \
      --sapmnt=$saphome/shared --datapath=$saphome/data --logpath=$saphome/log \
      --remote_execution=ssh \
      --install_hostagent=off \
      --add_local_roles=xs_worker \
      --import_xs_content=yes \
      --component_dirs=/installer/51050846/DATA_UNITS/XSA_RT_10_LINUX_X86_64,/installer/51050846/DATA_UNITS/XSA_CONTENT_10; then exit 1; fi; \

    #### DELETE INSTALLER
    if ! rm -rf /installer; then exit 1; fi; \

    #### STOP HANA
    sidadm=$(echo $sid | awk '{ print tolower($0) }')adm; \
    su - $sidadm -c "unset LD_PRELOAD; HDB stop; /usr/sap/$sid/SYS/exe/hdb/sapcontrol -nr $number -function StopService"
