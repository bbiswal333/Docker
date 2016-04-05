# WEBI SBOP 4.x prerequisites installation


MAINTAINER gerald.braunwarth@sap.com, simon.gomez@sap.com

RUN	yum -y install \
	libc.so.* \
  	libstdc++* \
  	libX11* \
	libXext* \
  	expat* \
  	libgcc_s.so.* \
  	libstdc++.so.6 \
 	libXcursor* \
  	compat-libstdc++-33-3.2.3-72.el7 \
  	compat-libstdc++-33-3.2.3-72.el7.i686 \

        # QA: Christophe Dolimont
        java-1.7.0-openjdk-devel; \

	yum clean all; \

	# ADD locale
	localedef -c -i en_US -f UTF-8 en_US.UTF-8; \
	
	# XI installation: GROUP td AND USER qaunix
	groupadd td; \
	adduser -g td -G wheel -m -d /home/qaunix qaunix; \
	echo qaunix | passwd --stdin qaunix; \

	# XI INSTALL DIRECTORY
	mkdir -p /usr/sap/XI4x -m 0755; \
	chown -R qaunix:td /usr/sap/XI4x

	# XI SCRIPTS
ADD	https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Aurora-XI4x/installAurora.sh  /mnt/installAurora.sh 
ADD	https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Aurora-XI4x/response.ini      /mnt/response.ini
ADD	https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Aurora-XI4x/startAurora.sh    /mnt/startAurora.sh 

RUN	chmod +x /mnt/installAurora.sh; \
        chmod +x /mnt/startAurora.sh; \
        chmod +r /mnt/response.ini

# EXPOSE Aurora4.x PORTS
EXPOSE  6410 6400 2638 8080 8005 8443 6405 10001 10002 10003 10004 10006

CMD ["/usr/sbin/init"]
