FROM rhel-server-docker-7.0-23.x86_64

# the script is maintained by Antonia
MAINTAINER Antonia Rodrigues <antonia.rodrigues@sap.com>

# create folders inside the container
RUN mkdir -p /sybase/DB
RUN mkdir /sybase/temp
RUN mkdir /sybase/trace
RUN mkdir /sybase/admin
RUN mkdir -p /soft/sybase

# upload folders in the container
ADD soft/bin /usr/bin
ADD soft/lib /usr/lib
ADD soft/sbin /usr/sbin
ADD soft/lib64 /usr/lib64
ADD soft/sybase /soft/sybase
ADD soft/admin /sybase/admin
ADD soft/etc /etc

# install Sybase
RUN /soft/sybase/./setup.bin -f installer.properties -i silent -DRUN_SILENCE=true -DAGREE_TO_SYBASE_LICENSE=true -DSYBASE_PRODUCT_LICENSE_TYPE=evaluate

# create sybase config
RUN . /sybase/IQ-16_0/IQ-16_0.sh \ && /bin/bash -c "start_iq @/sybase/admin/iq16_init.conf"

# create database
RUN /sybase/IQ-16_0/bin64/./dbisql -nogui -c "uid=DBA;pwd=sql;eng=iq16;dbn=utility_db" /sybase/admin/create_db.sql
#RUN /sybase/IQ-16_0/bin64/stop_IQ
#RUN /sybase/IQ-16_0/bin64/start_iq @/sybase/admin/iq16.conf

EXPOSE 30016 8282 8283 9999
