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

    echo; echo "ls /installer";     ls -1 /installer | grep -v "[RT|XSA]"; \
    echo; echo "ls /installer/RT";  ls -1 /installer/RT; \
    echo; echo "ls /installer/XSA"; ls -1 /installer/XSA; echo

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
      rm $file; fi; \

    ## DEVELOPERS ARE STANDARDIZING INSTALLERS
    file=$(ls /installer/XSA/sap-xsac-webide*[0-9].zip | grep -v XSACSAPWEBIDE); \
    if [ "${file}" ]; then \
      if ! unzip $file -d /installer/XSA; then exit 1; fi; \
      rm $file; fi; \
#    ma=$(ls /installer/XSA/sap-xsac-webide*.mtaext); \
#    if [ "${ma}" ]; then \
#       echo "    properties:" >> $ma; \
#       echo "      NO_PROXY: \"localhost, $(hostname -f)\"" >> $ma; \
#       echo; echo "$ma customized"; \
#       cat $ma; echo; fi; \

    ## DEVELOPERS ARE STANDARDIZING INSTALLERS
    file=$(ls /installer/XSA/jobscheduler-assembly*[0-9].zip | grep -v XSACSERVICES); \
    if [ "${file}" ]; then \
      if ! unzip $file -d /installer/XSA; then exit 1; fi; \
      rm $file; fi

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
      --import_xs_content=yes \
      --add_local_roles=xs_worker \
      --component_dirs=/installer/RT; then exit 1; fi; \

#      --components=server,xs \
#      --xs_components=xsac_monitoring,xsac_services \

#      --components=all \
#      --xs_components=all \
#      --import_xs_content=yes \
#      --add_local_roles=xs_worker \
#      --component_dirs=/installer/RT,/installer/XSA; then exit 1; fi; \

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
    if ! xs login -a https://$(hostname -f):3${number}30 -u XSA_ADMIN -p $secret -o $org -s $space --skip-ssl-validation; then exit 1; fi; \
#    if ! xs target -s $space; then exit 1; fi; \

    #### PREPARE DI INSTALLATION
    xs spaces; \
    if ! xs create-space DEV; then exit 1; fi; \
    if ! xs set-space-role fschuler $org DEV SpaceDeveloper; then exit 1; fi; \
    xs spaces; \

    #### INSTALL DI
    fi=$(ls /installer/XSA/*.zip | grep -i "\-di\-"); \
    ma=$(ls /installer/XSA/*.mtaext | grep -i "\-di\-"); \
    if [ ! "${fi}" ]; then exit 1; fi; \
    if [ ! "${ma}" ]; then \
      if ! xs install $fi -o ALLOW_SC_SAME_VERSION; then exit 1; fi; \
    else \

      echo; echo "file '$ma'"; echo; \
      cat $ma; echo; \

#      ## SAP note 2304873 (rewrite the file to remove the developpers DEV_SPACE)
#      echo "_schema-version: \"2.0.0\"" > $ma; \
#      echo "ID: com.sap.devx.di.xs2-config1" >> $ma; \
#      echo "extends: com.sap.devx.di" >> $ma; \
#      echo >> $ma; \
#      echo "modules:" >> $ma; \
#      echo >> $ma; \
#      echo "  - name: di-core" >> $ma; \
#      echo "    parameters:" >> $ma; \
#      echo "      memory: 512M" >> $ma; \
#      echo "    properties:" >> $ma; \
#      echo "      JBP_CONFIG_JAVA_OPTS: '[java_opts: \"\"]'" >> $ma; \
#      echo >> $ma; \
#      echo "  - name: di-runner" >> $ma; \
#      echo "    parameters:" >> $ma; \
#      echo "      memory: 512M" >> $ma; \

#      echo; echo "$ma customized"; \
#      cat $ma; echo; \

      if ! xs install $fi -e $ma -o ALLOW_SC_SAME_VERSION; then exit 1; fi; fi; \

    #### INSTALL HRTT
    fi=$(ls /installer/XSA/*.zip | grep -i hrtt); \
    ma=$(ls /installer/XSA/*.mtaext | grep -i hrtt); \
    if [ ! "${fi}" ]; then exit 1; fi; \
    if [ ! "${ma}" ]; then \
      if ! xs install $fi -o ALLOW_SC_SAME_VERSION; then exit 1; fi; \
    else \
      if ! xs install $fi  -e $ma -o ALLOW_SC_SAME_VERSION; then exit 1; fi; fi; \

    #### INSTALL MONITORING
    fi=$(ls /installer/XSA/*.zip | grep -i admin); \
    ma=$(ls /installer/XSA/*.mtaext | grep -i admin); \
    if [ ! "${fi}" ]; then exit 1; fi; \
    if [ ! "${ma}" ]; then \
      if ! xs install $fi -o ALLOW_SC_SAME_VERSION; then exit 1; fi; \
    else \
      if ! xs install $fi -e $ma -o ALLOW_SC_SAME_VERSION; then exit 1; fi; fi; \

    #### INSTALL WEBIDE
    fi=$(ls /installer/XSA/*.zip | grep -i webide); \
    ma=$(ls /installer/XSA/*.mtaext | grep -i webide); \
    if [ ! "${fi}" ]; then exit 1; fi; \
    if [ ! "${ma}" ]; then \
      if ! xs install $fi -o ALLOW_SC_SAME_VERSION; then exit 1; fi; \
    else \

      echo; echo "$ma before customization"; \
      cat $ma; echo; \

      echo "    properties:" >> $ma; \
      echo "      NO_PROXY: \"localhost, $(hostname -f)\"" >> $ma; \

      echo; echo "$ma customized"; \
      cat $ma; echo; \

      if ! xs install $fi -e $ma -o ALLOW_SC_SAME_VERSION; then exit 1; fi; fi; \

    #### INSTALL SERVICES
    fi=$(ls /installer/XSA/*.zip | grep -i services); \
    ma=$(ls /installer/XSA/*.mtaext | grep -i services); \
    if [ ! "${fi}" ]; then exit 1; fi; \
    if [ ! "${ma}" ]; then \
      if ! xs install $fi -o ALLOW_SC_SAME_VERSION; then exit 1; fi \
    else \
      if ! xs install $fi -e $ma -o ALLOW_SC_SAME_VERSION; then exit 1; fi; fi; \

    #### DELETE INSTALLER
#    if ! rm -rf /installer; then exit 1; fi; \

    #### STOP HANA
    sidadm=$(echo $sid | awk '{ print tolower($0) }')adm; \
    su - $sidadm -c "unset LD_PRELOAD; HDB stop; /usr/sap/$sid/SYS/exe/hdb/sapcontrol -nr $number -function StopService"; \
