# Base Redhat 7 build a new image to Aurora XI 42
# Include all packages (see bo requirements) and NFS
############################
#
FROM rhel-server-docker-7.0-23.x86_64
#
#MAINTAINER Antonia Rodrigues <antonia.rodrigues@sap.com>
#
RUN /bin/bash

# Copy files from origin folder to location with Dockerfile
COPY redhat.repo /etc/yum.repos.d/
COPY systemctl /usr/bin/systemctl
COPY dbus.service /usr/lib/systemd/system/dbus.service

# proxy settings
ENV http_proxy http://proxy.wdf.sap.corp:8080
ENV https_proxy http://proxy.wdf.sap.corp:8080
ENV no_proxy localhost,127.0.0.1,sap.corp,10.0.0.0/8

# INSTALL CONFIG NFS
RUN yum -y install nfs-utils; yum clean all
RUN yum -y install libc.so.*
RUN yum -y install libstdc++*
RUN yum -y install libX11*
RUN yum -y install libXext*
RUN yum -y install expat*
RUN yum -y install libgcc_s.so.*
RUN yum -y install libstdc++.so.6
RUN yum -y install libXcursor*
RUN yum -y install compat-libstdc++-33-3.2.3-72.el7
RUN yum -y install compat-libstdc++-33-3.2.3-72.el7.i686

RUN systemctl mask dev-mqueue.mount dev-hugepages.mount \
 systemd-remount-fs.service sys-kernel-config.mount \
 sys-kernel-debug.mount sys-fs-fuse-connections.mount

RUN systemctl mask display-manager.service systemd-logind.service
RUN systemctl disable graphical.target

# Copy the shell script to finish setup
COPY configure-nfs.sh /configure-nfs.sh
RUN chmod 777 configure-nfs.sh

# CREATE NEW USER
RUN mkdir -p /home/qaunix -m 755
RUN groupadd td
RUN adduser  -g td -G wheel -m -d /home/qaunix qaunix
RUN echo qaunix | passwd --stdin qaunix
RUN chown -R qaunix:td /home/qaunix

# CREATE CONFIG FILE SEMANAGE
RUN echo "SELINUX=disabled \SELINUXTYPE=targeted" > /etc/selinux/config

# CREATE DIRECTORIES
#########
RUN mkdir -p /usr/sap/XI42 -m 0755
RUN chown -R qaunix:td /usr/sap/XI42
RUN mkdir -p /soft -m 0755
RUN mkdir -p /soft/BO -m 0755
RUN touch /tmp/text.txt
RUN chmod 777 /tmp/text.txt
RUN chown -R qaunix:td /home/qaunix

# ADD FOLDER on Container
########
ADD response.ini soft/
ADD mnt-webi.sh /mnt-webi.sh

# MOUNT VOLUMES
#######
VOLUME ["/usr/bin"]
VOLUME ["/usr/sbin"]
VOLUME ["/usr/lib64"]
VOLUME ["/usr/lib"]
VOLUME ["/etc"]
CMD ["/usr/lib/systemd/systemd"]
VOLUME ["/run"]
VOLUME ["/sys/fs/cgroup"]

# ADD ALIAS  ETC/HOSTS
RUN host1line=`grep \`uname -n\` /etc/hosts`packages; cp /etc/hosts /etc/hosts.old; host1line=`grep \`uname -n\` /etc/hosts`; sed  "/$host1line/s/$/ sapboxi42/" /etc/hosts.old > /etc/hosts

# CHANGE USER
RUN su - qaunix

# ENVIRONNEMENT
#######
ENV LANG en_US.utf8
ENV LC_ALL en_US.utf8

# TCP PORTS EXPOSED BY START SERVICE
EXPOSE  6410 6400 2638 8080 8005 8443 6405 10001 10002 10003 10004 10006
