###### Purpose:
Install tools to perform an NFS mount inside the container

###### Start a container:
`docker run -it --privileged dockerdevregistry:5000/rh70/rh7-nfs /bin/sh`  
> Note: the "mount" command requires the **--privileged** mode

###### Examples of mounts from the container:
`mount -r -o nolock \<server>:/\<path  /mnt/nfs`  
`mount -w \<server>:/\<path  /mnt/nfs`
