# Docker Rhel7 / NFS - autofs

This Dockerfile runs systemd, installs NFS utils

The container requires a script (configure-nfs)to run after the image is created.


### Steps to run the new image
1. Create a work folder on the linux Docker host.
2. Copy script, redhat.repo, systemd and dbus.service to this folder.
3. Copy or create a new Dockerfile
4. Build the Docker image
 * docker build -t nfs-images .
5. Run container with the following syntax:
 * docker run -it --privileged v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /run:/run --name=container nfs-image /bin/bash
6. Inside the container  
  -bash-4.2$./configure-nfs.sh

   -bash-4.2$ mount -t nfs -o nolock ....

   example:
  mount -t nfs -o nolock 10.17.136.53:dropzone/aurora_dev/aurora42_cons docker-nfs )
