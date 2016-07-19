FROM docker.wdf.sap.corp:50000/hanaxsshine/weekstone/hana-xsa-shine-req

MAINTAINER gerald.braunwarth@sap.com

#### UPLOAD INSTALLER
COPY  mo-a9901609a/51050846     /mo-a9901609a/51050846

#### HANA INSTALL OPTIONS
ENV sid="DCK" \
    number="97" \
    secret="Toor1234" \
    org="PROD" \
    saphome="/usr/sap/hana"

#### Delayed variables expansion of previous ENV
ENV PATH=$PATH:$saphome/shared/$sid/HDB$number/exe/:$saphome/shared/$sid/xs/bin/

RUN \
    mkdir -p $saphome/{shared,data,log}; \
    hostFQDN=$(hostname -f); \

    #### INSTALL HANA
    if ! /mo-a9901609a/51050846/DATA_UNITS/HDB_LCM_LINUX_X86_64/hdblcm \
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
      --component_dirs=/mo-a9901609a/51050846/DATA_UNITS/XSA_RT_10_LINUX_X86_64,/mo-a9901609a/51050846/DATA_UNITS/XSA_CONTENT_10; then exit 1; fi; \

    #### DELETE INSTALLER
    if ! rm -rf /mo-a9901609a; then exit 1; fi; \

    #### CREATE SHINE USER
    if ! hdbsql -i $number -n localhost:3${number}15 -u SYSTEM -p $secret \
         "CREATE USER SHINE_USER PASSWORD \"Sap12345\" NO FORCE_FIRST_PASSWORD_CHANGE \
         SET PARAMETER XS_RC_XS_CONTROLLER_ADMIN = 'XS_CONTROLLER_ADMIN',XS_RC_XS_AUTHORIZATION_ADMIN = 'XS_AUTHORIZATION_ADMIN',XS_RC_SHINE_ADMIN = 'SHINE_ADMIN'"; then exit 1; fi; \

    #### GIT CLONE SHINE
    cd $HomeBuild/git; \
    if ! git clone https://github.wdf.sap.corp/refapps/shine.git; then exit 1; fi; \

    #### BUILD SHINE WITH MAVEN
    cd shine; \
    if ! mvn clean install -s cfg/settings.xml -P release.build; then exit 1; fi; \


    #### LOGIN TO XSA
    if ! xs login -a https://$hostFQDN:3${number}30 -u XSA_ADMIN -p $secret -o $org -s SAP --skip-ssl-validation; then exit 1; fi; \

    #### INSTALL SHINE
    file=$(ls $HomeBuild/git/shine/assembly/target/*.ZIP); \
    if [ ! ${file} ]; then exit 1; fi; \
    if ! xs install $file; then exit 1; fi; \

    #### STOP HANA + XSA + sapstartsrv
    sidadm=$(echo $sid | awk '{ print tolower($0) }')adm; \
    su - $sidadm -c "HDB stop; /usr/sap/$sid/SYS/exe/hdb/sapcontrol -nr $number -function StopService"
