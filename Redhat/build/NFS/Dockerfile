# Base redhat image with NFS configuration 
# autofs
############################
#
FROM rhel-server-docker-7.0-23.x86_64
#
MAINTAINER Antonia Rodrigues <antonia.rodrigues@sap.com>
#
# Copy files (repo, systemctl, dbus..) to location with Dockerfile
COPY redhat.repo /etc/yum.repos.d/
COPY systemctl /usr/bin/systemctl
COPY dbus.service /usr/lib/systemd/system/dbus.service

# Proxy setting
ENV http_proxy http://proxy.wdf.sap.corp:8080
ENV https_proxy http://proxy.wdf.sap.corp:8080
ENV no_proxy localhost,127.0.0.1,sap.corp,10.0.0.0/8

# Make mount point
RUN mkdir /docker-nfs

# Install config NFS
RUN yum -y install nfs-utils; yum clean all;  yum install -y autofs
RUN echo "/docker-nfs /etc/auto.misc --timeout=50" >> /etc/auto.master

RUN systemctl mask dev-mqueue.mount dev-hugepages.mount \
 systemd-remount-fs.service sys-kernel-config.mount \
 sys-kernel-debug.mount sys-fs-fuse-connections.mount

RUN systemctl mask display-manager.service systemd-logind.service
RUN systemctl disable graphical.target

VOLUME ["/sys/fs/cgroup"]
VOLUME ["/run"]

# Copy the shell script to finish setup
COPY configure-nfs.sh /configure-nfs.sh
RUN chmod 777 configure-nfs.sh

# CREATE CONFIG FILE SEMANAGE
RUN echo "SELINUX=disabled \SELINUXTYPE=targeted" > /etc/selinux/config

