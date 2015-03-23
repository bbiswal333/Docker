FROM rhel-server-docker-7.0-23.x86_64
ADD lvdc-s-plerin01.repo /etc/yum.repos.d/lvdc-s-plerin01.repo
ADD lvdc-s-plerin01extra.repo /etc/yum.repos.d/lvdc-s-plerin01extra.repo

ADD rpm.oracle /tmp/rpm.oracle
RUN yum -y swap -- remove fakesystemd -- install systemd systemd-libs
RUN yum install -y `cat /tmp/rpm.oracle` 
