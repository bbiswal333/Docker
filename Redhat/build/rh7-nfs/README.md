<h5> Create the container:

>docker run -it --privileged dockerdevregistry:5000/rh70/rh7-nfs /bin/sh


  Note: **privileged** is required

<h5> Mounts inside the container (example):

>mount -r -o nolock \<server>:/<path  /mnt/nfsshare
>mount -w \<server>:/<path  /mnt/nfsshare
