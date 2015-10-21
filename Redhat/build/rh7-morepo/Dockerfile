# dockerdevregistry:5000/rh70/rh70lib
FROM rh70lib

MAINTAINER gerald.braunwarth@sap.com

ENV http_proxy=http://proxy.wdf.sap.corp:8080 \
    https_proxy=http://proxy.wdf.sap.corp:8080 \
    no_proxy=localhost,127.0.0.1,sap.corp,10.0.0.0/8,dockerdevregistry

RUN \
cd /etc/yum.repos.d \
\
printf "\
[rhel-7-epel.repo]\n\
name=Red Hat Enterprise Linux 7 Server epel - x86_64 \n\
baseurl=http://moo-repo.wdf.sap.corp:8080/mrepo/redhat/7/rhel7epel-x86_64/RPMS.all/ \n\
gpgcheck=0 \n\
enabled=1\n" > rhel-7-epel.repo; \
\
printf "\
[rhel-7-server-extras-rpms.repo]\n\
name=Red Hat Enterprise Linux 7 Server extras - x86_64 \n\
baseurl=http://moo-repo.wdf.sap.corp:8080/mrepo/redhat/7/rhel7server-x86_64/RPMS.extras/ \n\
gpgcheck=0 \n\
enabled=1\n" > rhel-7-server-extras-rpms.repo; \
\
printf "\
[rhel-7-server-optional-rpms.repo]\n\
name=Red Hat Enterprise Linux 7 Server optional - x86_64 \n\
baseurl=http://moo-repo.wdf.sap.corp:8080/mrepo/redhat/7/rhel7server-x86_64/RPMS.optional/ \n\
gpgcheck=0 \n\
enabled=1\n" > rhel-7-server-optional-rpms.repo; \
\
printf "\
[rhel-7-server-rpms.repo]\n\
name=Red Hat Enterprise Linux 7 Server OS - x86_64 \n\
baseurl=http://moo-repo.wdf.sap.corp:8080/mrepo/redhat/7/rhel7server-x86_64/RPMS.os/ \n\
gpgcheck=0 \n\
enabled=1\n" > rhel-7-server-rpms.repo; \
\
printf "\
[sap.repo]\n\
name=SAP internal RPMs - x86_64 \n\
baseurl=http://moo-repo.wdf.sap.corp:8080/mrepo/redhat/7/sap-x86_64/RPMS.sap/ \n\
gpgcheck=0 \n\
enabled=1\n" > sap.repo
