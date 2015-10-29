# Aurora XI4.x container on Rhel7

* **Dockerfile**: create a base image that contains system requirements to install XI, download "docker build" scripts and "XI installation" scripts

These files are downloaded in the image by the Dockerfile build:
* **installAurora.sh:** performs an XI silent installation
* **response.ini:** response file for the silent installation.
Change options before continuing (as installdir, product key...ports )
 - ex: InstallDir=/usr/sap/XI42

#### Building the **aurora-prereq** image
1. Create a build folder on the Docker host.
2. Download **Dockerfile** inside
3. Run the build:

`docker build -t dockerdevregistry:5000/aurora/aurora-prereq .`

#### Running the XI installation in silent mode in a container 

##### Starting the container

The container is alone on the host: don't mind the ports publication, publish all with -P

The parameter expected by **installAurora.sh** is the buildnum folder in the path "10.17.136.53:/dropzone/aurora_dev/aurora42_cons/**1853_previous**/win64_x64/release/packages/BusinessObjectsServer"

`docker run -it --privileged -P dockerdevregistry:5000/aurora/aurora-prereq /bin/sh -c "/mnt/installAurora.sh 1853_previous"`

Several containers cohabits: personalize published ports

`docker run -it --privileged -p 6400:6400 -p 6404:6404 -p 6001:6001 -p 2638:2638 -p 3690:3690 -p 10001:10001 -p 10002:10002 -p 10003:10003 -p 10004:10004 dockerdevregistry:5000/aurora/aurora-prereq /bin/sh -c /mnt/installAurora.sh`

##### Testing the installation

  http://dockerhost:port/BOE/BI

  ex: http://dewdftv00483.dhcp.pgdev.sap.corp:10001/BOE/BI

#### Running multiple containers on the same host

** TODO:** run "restart all servers" script at startup

`docker run -it --privileged  -p 6400:6400 -p 6404:6404 -p 6001:6001 -p 2638:2638 -p 3690:3690 -p 10001:10001 -p 10002:10002 -p 10003:10003 -p 10004:10004 --name=container1 dockerdevregistry:5000/aurora/aurora-prereq/bin/sh`
  
`docker run -it --privileged -p 36400:6400 -p 36404:6404 -p 36001:6001 -p 32638:2638 -p 33690:3690 -p 11001:10001 -p 11002:10002 -p 11003:10003 -p 11004:10004 --name=container2 dockerdevregistry:5000/aurora/aurora-prereq/bin/sh`

#### Saving a container "XI" as an image

syntax:

`docker commit <container_id> <image_name>`
