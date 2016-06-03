FROM docker.wdf.sap.corp:50000/aurora/rh7-tools

MAINTAINER gerald.braunwarth@sap.com

RUN \
    #### INSTALL MORE CORE LIBS FOR CONTAINERIZED HANA
    if ! yum install -y libaio; then exit 1; fi; \

    ### INSTALL HANA REQUIREMENTS
    if ! yum install -y unzip gtk2 libicu xulrunner sudo tcsh libssh2 expect cairo graphviz iptraf-ng krb5-workstation krb5-libs.i686 \
                        nfs-utils lm_sensors rsyslog compat-sap-c++ openssl098e openssl PackageKit-gtk-module libcanberra-gtk2 libtool-ltdl \
                        xorg-x11-xauth compat-libstdc++-33 numactl; then exit 1; fi; \

#    if ! ln -s /usr/lib64/libssl.so.0.9.8e /usr/lib64/libssl.so.0.9.8; then exit 1; fi; \
#    if ! ln -s /usr/lib64/libssl.so.1.0.1e /usr/lib64/libssl.so.1.0.1; then exit 1; fi; \
#    if ! ln -s /usr/lib64/libcrypto.so.0.9.8e /usr/lib64/libcrypto.so.0.9.8; then exit 1; fi; \
#    if ! ln -s /usr/lib64/libcrypto.so.1.0.1e /usr/lib64/libcrypto.so.1.0.1; then exit 1; fi; \

    cp /usr/lib64/libssl.so.0.9.8e /usr/lib64/libssl.so.0.9.8; \
    cp /usr/lib64/libssl.so.1.0.1e /usr/lib64/libssl.so.1.0.1; \
    cp /usr/lib64/libcrypto.so.0.9.8e /usr/lib64/libcrypto.so.0.9.8; \
    cp /usr/lib64/libcrypto.so.1.0.1e /usr/lib64/libcrypto.so.1.0.1; \

    #### INSTALL MORE COMMANDS FOR 3RD PARTY COMPONENTS INSTALL \
    if ! yum -y install wget tar git which; then exit 1; fi; \

    #### HOME FOLDER
    mkdir /usr/repo; \
    cd /usr/repo; \

    #### INSTALL MAVEN
    file=apache-maven-3.3.3-bin.tar.gz
#    if ! wget http://apache.mirror.digitalpacific.com.au/maven/maven-3/3.3.3/binaries/$file; then exit 1; fi; \
#    if ! tar -zxvf $file; then exit 1; fi; \
#    PATH="$PATH::/usr/repo/apache-maven-3.3.3/bin"; \

    #### INSTALL JDK
    file=jdk-8u60-linux-x64.rpm
#    if ! curl -v -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u60-b27/$file > $file; then exit 1; fi; \
#    if ! rpm -ivh $file; then exit 1; fi; \

    #### CLONE SHINE
#    mkdir git; \
#    cd git; \
#    if ! git clone https://github.wdf.sap.corp/refapps/shine.git; then exit 1; fi; \

    #### MAVEN BUILD
#    cd shine; \
#    if ! mvn clean install -s cfg/settings.xml; then exit 1; fi
