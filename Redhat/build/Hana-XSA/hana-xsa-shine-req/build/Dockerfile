FROM docker.wdf.sap.corp:50000/aurora/rh7-tools

MAINTAINER gerald.braunwarth@sap.com

ENV HomeBuild="usr/repo" \
    Maven="apache-maven-3.3.9"

    # !! Delayed variable expansion
ENV PATH="$PATH:/$HomeBuild/$Maven/bin"

RUN \
    #### INSTALL MORE LIBS FOR CONTAINERIZED HANA
    if ! yum install -y libaio; then exit 1; fi; \

    ### INSTALL HANA REQUIREMENTS
      # (nfs-utils installed by rh7-tools parent image)
    if ! yum install -y unzip gcc-c++ gtk2 libicu xulrunner sudo tcsh libssh2 expect cairo graphviz iptraf-ng krb5-workstation krb5-libs.i686 \
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

    #### FAILED TO yum install compat-sap-c++.
      ## 4.7 doesn't work, requires 4.8 
#    file=compat-sap-c++-4.8.2-16.el6.x86_64.rpm; \
#    if ! curl -j -k -L ftp://mirror.switch.ch/pool/4/mirror/scientificlinux/6.7/x86_64/updates/fastbugs/$file>$file; then exit 1; fi; \
#    if ! rpm -ivh $file; then exit 1; fi; \
#    rm -f $file; \

    #### TEMPORARY WINDOWS SHARE
#   yum install -y cifs-utils; \

    #### INSTALL MORE COMMANDS FOR 3RD PARTY INSTALL \
    if ! yum -y install wget tar git which; then exit 1; fi; \

    ### HOME BUILD FOLDERS
    mkdir -p /$HomeBuild/git; \
    cd /$HomeBuild; \

    #### INSTALL JDK  (JRE for Hana install / JDK for QA)
    file=jdk-8u60-linux-x64.rpm; \
    if ! curl -v -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u60-b27/$file > $file; then exit 1; fi; \
    if ! rpm -ivh $file; then exit 1; fi; \
    rm -f $file; \

    #### INSTALL MAVEN
    file=$Maven-bin.tar.gz; \
    if ! wget http://apache.mirror.digitalpacific.com.au/maven/maven-3/3.3.9/binaries/$file; then exit 1; fi; \
    if ! tar -zxvf $file; then exit 1; fi; \
    rm -f $file