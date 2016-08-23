#FROM docker.mo.sap.corp/library/rhel:latest
FROM docker.wdf.sap.corp:51022/rhel:7.2_sap

MAINTAINER gerald.braunwarth@sap.com, simon.gomez@sap.com

RUN \

  # INSTALL NFS
  yum install -y deltarpm; \
  yum install -y nfs-utils; \
  mkdir /mnt/nfs -m 757; \

  # INSTALL OPENSSH
  yum clean all; \
  yum -y swap -- remove systemd-container\* -- install systemd-libs; \
  yum -y install openssh-server; \
  echo root | passwd --stdin root; \
  ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''

EXPOSE 22

# CMD ["/usr/sbin/sshd"]
