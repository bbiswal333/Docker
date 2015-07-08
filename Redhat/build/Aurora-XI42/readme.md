# Docker Rhel7 / NFS and all packages for Aurora XI42

This Dockerfile runs systemd, installs NFS utils and all packages necessaries to Aurora installation (see requirements)

The container requires some scripts and files:
* **configure-nfs.sh** : to run NFS after the image is created.
The mnt-webi.sh is not mandatory, just if you mount by script or not.
* **add-host.sh** : this script adds an alias called "sapboxi42" on /etc/hosts file. This alias is mandatory if you want commit (save) a new image since a container where XI42 is already installed... this "host alias" must to be indicated on *response.ini*
* **response.ini** : available on the XI build directory: only if you want install XI in silent mode. Your can change some options  (as installdir, product key...ports )
 - ex: InstallDir=/usr/sap/XI42

#### Steps to build the new image AURORA
1. Create a work's folder on the linux Docker host.
2. Copy scripts, redhat.repo, systemd and dbus.service to the folder.
3. Copy or create a new Dockerfile
4. Build the Docker image

  `# docker build -t aurora-image . `

#### Steps to run a new container and install XI
5. Run container with the following syntax:

  `$ docker run -it --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /run:/run:ro -p 6400:6400 -p 6404:6404 -p 6001:6001 -p 2638:2638 -p 3690:3690 -p 10001:10001 -p 10002:10002 -p 10003:10003 -p 10004:10004 --name=aurora-container aurora-image /bin/bash`

or if only 1 XI container on your dockerhost:

  `$ docker run -it --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /run:/run:ro -P --name=aurora-container aurora-image /bin/bash`
6. Inside the container

  `# ./configure-nfs`

  `# mount -t nfs -o nolock 10.17.136.53:dropzone/aurora_dev/aurora42_cons /soft/BO`

7. change user to install XI

  `# sudo - qaunix `
8. set environment variable

  `$ export LANG=en_US.utf8`

  `$ export LC_ALL=en_US.utf8`
9. XI installation

  `$ /soft/BO/./setup.sh - r /soft/response.ini`

  => if message: Finished, return code is 0 = your BI CMC is ready
10. To check the installation, on your workstation, open a browser:

  http://dockerhost:port/BOE/BI

  ex: http://dewdftv00483.dhcp.pgdev.sap.corp:10001/BOE/BI

#### To run multiple containers

You cannot run 2 or more containers with the same ports openned!

Container 1

  `$ docker run -it --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /run:/run:ro -p 6400:6400 -p 6404:6404 -p 6001:6001 -p 2638:2638 -p 3690:3690 -p 10001:10001 -p 10002:10002 -p 10003:10003 -p 10004:10004 --name=aurora-container aurora-image /bin/bash`

Container 2

  `$ docker run -it --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /run:/run:ro -p 36400:6400 -p 36404:6404 -p 36001:6001 -p 32638:2638 -p 33690:3690 -p 11001:10001 -p 11002:10002 -p 11003:10003 -p 11004:10004 --name=aurora-container2 aurora-image /bin/bash`

#### Saving a container "XI" as an image

syntax:
  `docker commit <container_id> <image_name>`
