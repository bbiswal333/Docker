FROM docker.wdf.sap.corp:50000/hanaxsshine/weekstone/hana-xsa

# rev-1.1.12 is stable
ARG branch

#MAINTAINER gerald.braunwarth@sap.com

RUN \
    #### RENAME HANA HOST
    OLDHOST=$($saphome/shared/$sid/hdblcm/hdblcm --list_systems | grep -i 'host:' | awk '$2 { print $2 }'); \
    NEWHOST=$(hostname -f); \

#   lowOLDHOST=$(echo $OLDHOST | awk '{ print tolower($0) }'); \
#   lowNEWHOST=$(echo $NEWHOST | awk '{ print tolower($0) }'); \

    if ! $saphome/shared/$sid/hdblcm/hdblcm -b --action=rename_system \
      --source_password=$secret --target_password=$secret \
      --hostmap=$OLDHOST=$NEWHOST; then exit 1; fi; \

#    sidadm=$(echo $sid | awk '{ print tolower($0) }')adm; \
#    if ! su - $sidadm -c "HDB start"; then exit 1; fi; \

    ### DOWNLOAD TRIGGER FILE
    trigger='trigger-shine'; \

    echo; \
    echo "curl '$trigger.txt'"; \
    if ! curl -k -s https://github.wdf.sap.corp/raw/I313177/Docker/master/Redhat/build/Hana-XSA/hana-xsa/jenkins/$trigger.txt -o $trigger.tmp; then exit 1; fi; \

    # Windows \nl to Linux
    tr -d "\r" < $trigger.tmp > $trigger.txt; \
    rm $trigger.tmp; \

    mkdir -p /installer/shine; \

    echo; \
    while IFS=';' read name folder url file; do \
      echo "curl '$folder/$file'"; \
      if ! curl -k -s "$url/$file" -o "/$folder/$file"; then exit 1; fi; \
    done < $trigger.txt; \

    echo; \
    echo "ls /installer/shine"; \
    ls -l /installer/shine; \
    echo; \

set -x; \

# yum remove compat-libstdc++-33; \
#yum remove libstdc++-4.8.5-4.el7.x86_64; \

#mkdir CXXABI138; \
#cd CXXABI138; \
file=gcc-libstdc++-4.9.1-1.ram0.99.x86_64.rpm; \
#if ! curl -s -k -O ftp://ftp.pbone.net/mirror/ftp.sourceforge.net/pub/sourceforge/r/ra/ramonelinux/Rel_0.99/releases/x86_64/packages/$file; then exit 1; fi; \
if ! curl -s -k -O http://moo-repo.wdf.sap.corp:8080/static/monsoon/r/ra/ramonelinux/Rel_0.99/releases/x86_64/packages/$file; then exit 1; fi; \

#rpm2cpio $file | cpio -idmv; \
#mv usr/lib64/libstdc++.so.6* /usr/lib64/; \
#cd /usr/lib64; \
#rm libstdc++.so.6; \
#ln -s libstdc++.so.6.0.20 libstdc++.so.6#cd ..; \
#rm -rf CXXABI138; \

if ! yum -y swap -- remove libstdc++-4.8.5-4.el7.x86_64 -- install ./$file; then exit 1; fi; \

    #### CREATE SHINE USER
#    if ! hdbsql -i $number -n localhost:3${number}15 -u SYSTEM -p $secret \
#         "CREATE USER SHINE_USER PASSWORD \"Sap12345\" NO FORCE_FIRST_PASSWORD_CHANGE \
#         SET PARAMETER XS_RC_XS_CONTROLLER_ADMIN = 'XS_CONTROLLER_ADMIN',XS_RC_XS_AUTHORIZATION_ADMIN = 'XS_AUTHORIZATION_ADMIN',XS_RC_SHINE_ADMIN = 'SHINE_ADMIN'"; then exit 1; fi; \

    #### GIT CLONE SHINE
#    cd /$HomeBuild/git; \
#    if ! git clone -b $branch https://github.wdf.sap.corp/refapps/shine.git; then exit 1; fi; \

    #### BUILD SHINE WITH MAVEN
#    cd shine; \
#    if ! mvn clean install -s cfg/settings.xml -P release.build; then exit 1; fi; \

    #### LOGIN TO XSA
    if ! xs login -a https://$NEWHOST:3${number}30 -u XSA_ADMIN -p $secret -o $org -s $space --skip-ssl-validation; then exit 1; fi; \

    #### INSTALL SHINE
#    file=$(ls /$HomeBuild/git/shine/assembly/target/*.ZIP); \
#    if [ ! ${file} ]; then exit 1; fi; \
#    if ! xs install $file; then exit 1; fi; \

    #### INSTALL SHINE.ZIP
    sh=$(ls /installer/shine/sap-xsac-shine-*[0-9].zip); \
    ma=$(ls /installer/shine/sap-xsac-shine-*.mtaext); \
    if [ ! "${sh}" ]; then exit 1; fi; \
    if [ ! "${ma}" ]; then exit 1; fi; \
    if ! sed -e "s/<USERNAME>/XSA_ADMIN/g" -e "s/<PASSWORD>/$secret/g" -i $ma; then exit 1; fi; \
    if ! xs install $sh -e $ma -o ALLOW_SC_SAME_VERSION; then exit 1; fi; \
#    if ! xs install $sh ; then exit 1; fi; \

    #### STOP HANA + XSA
    sidadm=$(echo $sid | awk '{ print tolower($0) }')adm; \
    su - $sidadm -c "unset LD_PRELOAD; HDB stop; /usr/sap/$sid/SYS/exe/hdb/sapcontrol -nr $number -function StopService"
