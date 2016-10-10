FROM docker.wdf.sap.corp:50000/hanaxsshine/weekstone/hana-xsa-shine-req

MAINTAINER gerald.braunwarth@sap.com

#### UPLOAD INSTALLERS
COPY  upload/     /installer/

#### DOWNLOAD INSTALLERS
RUN \
    echo; \
    echo "curl 'trigger-xsa.tx'"; \
    if ! curl -k -s https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Hana-XSA/hana-xsa/jenkins/trigger-xsa.txt -o trigger-xsa.tmp; then exit 1; fi; \

    tr -d "\r" < trigger-xsa.tmp > trigger-xsa.txt; \
    rm trigger-xsa.tmp; \

    mkdir /installer/{RT,XSA}

    echo; \
    while IFS=';' read name folder url file; do \
      if [ "$name" != "lcm" -a "$name" != "hanadb" ]; then \
        echo "curl '$folder/$file'"; \
        if ! curl -k -s "$url/$file" -o "/$folder/$file"; then exit 1; fi; fi; \
    done < trigger-xsa.txt; \

    echo; \
    echo "ls /installer"; \
    ls -l /installer; \
    ls -l /installer/RT; \
    ls -l /installer/XSA; \

#### DECOMPRESS INSTALLER
    sapcar=$(ls /installer/sapcar-*); \
    if [ ! "${sapcar}" ]; then exit 1; fi; \
    chmod +x $sapcar; \

    if ! $sapcar -xf /installer/SAP_HANA_DATABASE*.SAR  -R /installer/; then exit 1; fi; \
    rm /installer/SAP_HANA_DATABASE*.SAR; \

    if ! $sapcar -xf /installer/RT/xs.onpremise.runtime.hanainstallation*.SAR  -R /installer/RT; then exit 1; fi; \
    rm /installer/RT/xs.onpremise.runtime.hanainstallation*.SAR; \

    file=$(ls /installer/jobscheduler-assembly*[0-9].zip); \
    if [ ! "${file}" ]; then exit 1; fi; \
    if ! unzip $file -d /installer/XSA; then exit 1; fi; \
    rm /installer/jobscheduler-assembly*

#### HANA INSTALL CONSTANTS
ENV sid="DCK" \
    number="97" \
    secret="Toor1234" \
    org="REF" \
    space="PROD" \
    saphome="/usr/sap/hana"

#### Another ENV for Delayed variables expansion
ENV PATH=$PATH:$saphome/shared/$sid/HDB$number/exe/:$saphome/shared/$sid/xs/bin/

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
      --components=server,xs \
      --xs_components=xsac_monitoring,xsac_services \
      --import_xs_content=yes \
      --add_local_roles=xs_worker \
      --component_dirs=/installer/RT,/installer/XSA; then exit 1; fi; \

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

  # Detected components:
      #SAP HANA Database (2.00.000.00.1470842078) in /installer/SAP_HANA_DATABASE/server
  # Wrong usage!
    # Unknown option: xs_content_cfg
    # Unknown argument: –-components=xs
    # Unknown argument: –-xs_components=xsac_hrtt,xsac_di_core,xsac_sap_web_ide

    #### LOGIN TO XSA
    if ! xs login -a https://$(hostname):3${number}30 -u XSA_ADMIN -p $secret -o $org -s $space --skip-ssl-validation; then \
      echo "Retry 'xs login'"; \
      if ! xs login -a https://$(hostname):3${number}30 -u XSA_ADMIN -p $secret -o $org -s $space --skip-ssl-validation; then exit 1; fi; fi; \

    #### INSTALL HRTT
    file=$(ls /installer/XSA/sap-xsac-hrtt*[0-9].zip); \
    if [ ! "${file}" ]; then exit 1; fi; \
    if ! xs install $file -o ALLOW_SC_SAME_VERSION; then exit 1; fi; \

    #### INSTALL DI
    di=$(ls /installer/XSA/sap-xsac-di*[0-9].zip); \
    ma=$(ls /installer/XSA/sap-xsac-di*.mtaext); \
    if [ ! "${di}" ]; then exit 1; fi; \
    if [ ! "${ma}" ]; then exit 1; fi; \
    if ! xs install $di -e $ma -o ALLOW_SC_SAME_VERSION; then exit 1; fi; \

    #### INSTALL WEBIDE
    wb=$(ls /installer/XSA/sap-xsac-webide*[0-9].zip); \
    ma=$(ls /installer/XSA/sap-xsac-webide*.mtaext); \
    if [ ! "${wb}" ]; then exit 1; fi; \
    if [ ! "${ma}" ]; then exit 1; fi; \
    if ! xs install $wb -e $ma -o ALLOW_SC_SAME_VERSION; then exit 1; fi; \

    #### DELETE INSTALLER
    if ! rm -rf /installer; then exit 1; fi; \

    #### STOP HANA
    sidadm=$(echo $sid | awk '{ print tolower($0) }')adm; \
    su - $sidadm -c "unset LD_PRELOAD; HDB stop; /usr/sap/$sid/SYS/exe/hdb/sapcontrol -nr $number -function StopService"
