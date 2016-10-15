FROM docker.wdf.sap.corp:50000/hanaxsshine/weekstone/hana-xsa-shine-req

MAINTAINER gerald.braunwarth@sap.com

#### UPLOAD INSTALLERS
COPY  upload/     /installer/

#### DOWNLOAD INSTALLERS
RUN \
    trigger='trigger-xsa'; \

    echo; echo "curl '$trigger.txt'"; \
    if ! curl -k -s https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Hana-XSA/hana-xsa/jenkins/$trigger.txt -o $trigger.tmp; then exit 1; fi; \

    # Windows \nl to Linux
    tr -d "\r" < $trigger.tmp > $trigger.txt; \
    rm $trigger.tmp; \

    mkdir /installer/{RT,XSA}; \

    echo; \
    while IFS=';' read name folder url file; do \
      if [ "$name" != "lcm" -a "$name" != "hanadb" ]; then \
        echo "curl to '$folder/$file'"; \
        if ! curl -k -s "$url/$file" -o "/$folder/$file"; then exit 1; fi; fi; \
    done < $trigger.txt; \

    echo; echo "ls /installer"; \
    ls -1 /installer; \
    echo; echo "ls /installer/RT"; \
    ls -1 /installer/RT; \
    echo; echo "ls /installer/XSA"; \
    ls -1 /installer/XSA; \
    echo

#### DECOMPRESS INSTALLER
RUN \
    sapcar=$(ls /installer/sapcar-*); \
    if [ ! "${sapcar}" ]; then exit 1; fi; \
    chmod +x $sapcar; \

    if ! $sapcar -xf /installer/SAP_HANA_DATABASE*.SAR  -R /installer/; then exit 1; fi; \
    rm /installer/SAP_HANA_DATABASE*.SAR; \

    if ! $sapcar -xf /installer/RT/xs.onpremise.runtime.hanainstallation*.SAR  -R /installer/RT; then exit 1; fi; \
    rm /installer/RT/xs.onpremise.runtime.hanainstallation*.SAR; \

    ## DEVELOPERS ARE STANDARDIZING INSTALLERS
    file=$(ls /installer/XSA/sap-xsac-hrtt*[0-9].zip | grep -v XSACHRTT); \
    if [ "${file}" ]; then \
      if ! unzip $file -d /installer/XSA; then exit 1; fi; \
      rm /installer/XSA/sap-xsac-hrtt*; fi; \

    ## DEVELOPERS ARE STANDARDIZING INSTALLERS
    file=$(ls /installer/XSA/sap-xsac-webide*[0-9].zip | grep -v XSACSAPWEBIDE); \
    if [ "${file}" ]; then \
      if ! unzip $file -d /installer/XSA; then exit 1; fi; \
      rm /installer/XSA/sap-xsac-webide*.zip; fi; \

    ## DEVELOPERS ARE STANDARDIZING INSTALLERS
    file=$(ls /installer/XSA/jobscheduler-assembly*[0-9].zip | grep -v XSACSERVICES); \
    if [ "${file}" ]; then \
      if ! unzip $file -d /installer/XSA; then exit 1; fi; \
      rm /installer/XSA/jobscheduler-assembly*; fi

#### HANA INSTALL CONSTANTS
ENV sid="DCK" \
    number="97" \
    secret="Toor1234" \
    org="REF" \
    space="PROD" \
    saphome="/usr/sap/hana"

#### Another ENV for Delayed variables expansion
#ENV PATH=$PATH:$saphome/shared/$sid/HDB$number/exe/:$saphome/shared/$sid/xs/bin/

RUN \
    mkdir -p $saphome/{shared,data,log}; \

    #### INSTALL HANA
    if ! /installer/SAP_HANA_LCM/hdblcm \
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
      --remote_execution=ssh \
      --install_hostagent=off \
      --system_usage=custom \
      --sapmnt=$saphome/shared --datapath=$saphome/data --logpath=$saphome/log \
      --components=all \
      --xs_components=all \
      --import_xs_content=yes \
      --add_local_roles=xs_worker \
      --component_dirs=/installer/RT,/installer/XSA; then exit 1; fi; \

#      --components=server,xs \
#      --xs_components=xsac_monitoring,xsac_services \


    #### ADD HRTT + DI_CORE + WEB_IDE
#    if ! /installer/SAP_HANA_LCM/hdblcm \
#      -b \
#      --action=update \
#      --sid=$sid \
#      –-components=xs \
#      –-xs_components=xsac_hrtt,xsac_di_core,xsac_sap_web_ide \
#      --xs_content_cfg=installer/XSA; then exit 1; fi; \

  # To install a new SAP HANA system with XS Advanced and SAP Web IDE
  # ./hdblcm --action=install –-components=server,xs –-xs_components=xsac_hrtt,xsac_di_core,xsac_sap_web_ide --xs_content_cfg=<path to directory with mtaextensions> …

  #  To update XS Advanced and SAP Web IDE
  #./hdblcm --action=update –-components=xs –-xs_components=xsac_hrtt,xsac_di_core,xsac_sap_web_ide --xs_content_cfg=<path todirectory with mta extensions>

    #### LOGIN TO XSA
#    if ! xs login -a https://$(hostname):3${number}30 -u XSA_ADMIN -p $secret -o $org -s $space --skip-ssl-validation; then \
#      echo "Retry 'xs login'"; \
#      if ! xs login -a https://$(hostname):3${number}30 -u XSA_ADMIN -p $secret -o $org -s $space --skip-ssl-validation; then exit 1; fi; fi; \

    #### INSTALL HRTT
#    file=$(ls /installer/XSA/sap-xsac-hrtt*[0-9].zip); \
#    if [ ! "${file}" ]; then exit 1; fi; \
#    if ! xs install $file -o ALLOW_SC_SAME_VERSION; then exit 1; fi; \

    #### INSTALL DI
#    di=$(ls /installer/XSA/sap-xsac-di*[0-9].zip); \
#    ma=$(ls /installer/XSA/sap-xsac-di*.mtaext); \
#    if [ ! "${di}" ]; then exit 1; fi; \
#    if [ ! "${ma}" ]; then exit 1; fi; \
#    if ! xs install $di -e $ma -o ALLOW_SC_SAME_VERSION; then exit 1; fi; \

    #### INSTALL WEBIDE
#    wb=$(ls /installer/XSA/sap-xsac-webide*[0-9].zip); \
#    ma=$(ls /installer/XSA/sap-xsac-webide*.mtaext); \
#    if [ ! "${wb}" ]; then exit 1; fi; \
#    if [ ! "${ma}" ]; then exit 1; fi; \
#    if ! xs install $wb -e $ma -o ALLOW_SC_SAME_VERSION; then exit 1; fi; \

    #### DELETE INSTALLER
#    if ! rm -rf /installer; then exit 1; fi; \

    #### STOP HANA
    sidadm=$(echo $sid | awk '{ print tolower($0) }')adm; \
    su - $sidadm -c "unset LD_PRELOAD; HDB stop; /usr/sap/$sid/SYS/exe/hdb/sapcontrol -nr $number -function StopService"; \
