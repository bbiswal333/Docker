##### Create the container:

`docker run -it --privileged dockerdevregistry:5000/rh70/rh7-nfs /bin/sh`


Note: **--privileged** is required

##### Mounts inside the container (example):

`mount -r -o nolock \<server>:/\<path  /mnt/nfs`

`mount -w \<server>:/\<path  /mnt/nfs`


