FROM docker.wdf.sap.corp:50000/hanaxsshine/weekstone/hana-xsa

MAINTAINER gerald.braunwarth@sap.com


RUN \
    #### RENAME HANA HOST
    OLDHOST=$($saphome/shared/$sid/hdblcm/hdblcm --list_systems | grep -i 'host:' | awk '$2 { print $2 }'); \
    NEWHOST=$(hostname -f); \

#   lowOLDHOST=$(echo $OLDHOST | awk '{ print tolower($0) }'); \
#   lowNEWHOST=$(echo $NEWHOST | awk '{ print tolower($0) }'); \

    if ! $saphome/shared/$sid/hdblcm/hdblcm -b --action=rename_system --source_password=$secret --target_password=$secret --hostmap=$OLDHOST=$NEWHOST; then exit 1; fi; \


    #### CREATE SHINE USER
    if ! hdbsql -i $number -n localhost:3${number}15 -u SYSTEM -p $secret \
         "CREATE USER SHINE_USER PASSWORD \"Sap12345\" NO FORCE_FIRST_PASSWORD_CHANGE \
         SET PARAMETER XS_RC_XS_CONTROLLER_ADMIN = 'XS_CONTROLLER_ADMIN',XS_RC_XS_AUTHORIZATION_ADMIN = 'XS_AUTHORIZATION_ADMIN',XS_RC_SHINE_ADMIN = 'SHINE_ADMIN'"; then exit 1; fi; \


    #### GIT CLONE SHINE
    cd /$HomeBuild/git; \
    if ! git clone -b rev-1.1.12 https://github.wdf.sap.corp/refapps/shine.git; then exit 1; fi; \


    #### BUILD SHINE WITH MAVEN
    cd shine; \
    if ! mvn clean install -s cfg/settings.xml -P release.build; then exit 1; fi; \


    #### LOGIN TO XSA
    if ! xs login -a https://$NEWHOST:3${number}30 -u XSA_ADMIN -p $secret -o $org -s $space --skip-ssl-validation; then exit 1; fi; \


    #### INSTALL SHINE
    file=$(ls /$HomeBuild/git/shine/assembly/target/*.ZIP); \
    if [ ! ${file} ]; then exit 1; fi; \
    if ! xs install $file; then exit 1; fi; \


    #### STOP HANA + XSA
    sidadm=$(echo $sid | awk '{ print tolower($0) }')adm; \
    su - $sidadm -c "unset LD_PRELOAD; HDB stop; /usr/sap/$sid/SYS/exe/hdb/sapcontrol -nr $number -function StopService"
