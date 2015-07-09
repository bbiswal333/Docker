# PURPOSE:
# Hana installer requires a few Linux tools like 'hostname'
# This image completes the RedHat system image with Linux tools on the host
#    locations are the same to preserve the PATH env variable

FROM rhel-server-docker-7.0-23.x86_64

MAINTAINER gerald.braunwarth@sap.com

ADD usr/bin   /usr/bin
ADD usr/sbin  /usr/sbin
ADD usr/lib64 /usr/lib64
