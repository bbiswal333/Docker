###### Purpose:
Install tools to perform an NFS mount inside th container

###### start a container:

  `docker run -it --privileged dockerdevregistry:5000/rh70/rh7-nfs /bin/sh`


Note: **--privileged** is required

###### Examples of mounts from the container:

  `mount -r -o nolock \<server>:/\<path  /mnt/nfs`

  `mount -w \<server>:/\<path  /mnt/nfs`


