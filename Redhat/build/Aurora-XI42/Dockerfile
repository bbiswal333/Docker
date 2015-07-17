#CREATE NEW IMAGE REDHAT WITH PACKAGES-NFS
# Special WEBI SBOP 42
############################
#
FROM rhel-server-docker-7.0-23.x86_64
#
#MAINTAINER Antonia Rodrigues <antonia.rodrigues@sap.com>
#
RUN /bin/bash

# COPY files from origin folder to location with Dockerfile
COPY redhat.repo /etc/yum.repos.d/
COPY systemctl /usr/bin/systemctl
COPY dbus.service /usr/lib/systemd/system/dbus.service

#proxy settings
ENV http_proxy http://proxy.wdf.sap.corp:8080
ENV https_proxy http://proxy.wdf.sap.corp:8080
ENV no_proxy localhost,127.0.0.1,sap.corp,10.0.0.0/8

# INSTALL CONFIG NFS
RUN yum -y install nfs-utils \
  yum -y install libc.so.* \
  yum -y install libstdc++* \
  yum -y install libX11* \
  yum -y install libXext* \
  yum -y install expat* \
  yum -y install libgcc_s.so.* \
  yum -y install libstdc++.so.6 \
  yum -y install libXcursor* \
  yum -y install compat-libstdc++-33-3.2.3-72.el7 \
  yum -y install compat-libstdc++-33-3.2.3-72.el7.i686 \
  yum clean all

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
VOLUME ["/run"]
VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/lib/systemd/systemd"]

# CHANGE USER
RUN su - qaunix
# ENVIRONNEMENT
#######
ENV LANG en_US.utf8
ENV LC_ALL en_US.utf8

# TCP PORTS EXPOSED BY START SERVICE
EXPOSE  6410 6400 2638 8080 8005 8443 6405 10001 10002 10003 10004 10006
