# WEBI SBOP 4.x prerequisites installation

FROM dockerdevregistry:5000/rh70/rh7-nfs:latest

MAINTAINER Antonia Rodrigues <antonia.rodrigues@sap.com>, \
           Gerald Braunwarth <gerald.braunwarth@sap.com>

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
  	compat-libstdc++-33-3.2.3-72.el7.i686 ; \
	yum clean all ; \

	# ADD locale
	localedef -v -c -i en_US -f UTF-8 en_US.UTF-8 ; \
	
	# XI INSTALL, GROUP td AND USER qaunix
	groupadd td; \
	adduser -g td -G wheel -m -d /home/qaunix qaunix; \
	echo qaunix | passwd --stdin qaunix; \

	# XI INSTALL DIRECTORY
	mkdir -p /usr/sap/XI42 -m 0755; \
	chown -R qaunix:td /usr/sap/XI42 ; \

	# XI INSTALL SCRIPTS
        curl -k -s https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Aurora-XI42/installAurora.sh > /mnt/installAurora.sh; \
	curl -0    http://dewdftv01813.dhcp.pgdev.sap.corp/artifactory/virtual_docker/TestDockerfileSimon/response.ini         > /mnt/response.ini; \

	chmod +x /mnt/installAurora.sh

# EXPOSED PORTS
EXPOSE  6410 6400 2638 8080 8005 8443 6405 10001 10002 10003 10004 10006

CMD ["/usr/sbin/init"]
