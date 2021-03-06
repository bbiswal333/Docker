                                Aurora installation via Swarm API (Ubuntu)
        https://github.wdf.sap.corp/Dev-Infra-Levallois/Docker/tree/master/Redhat/build/Aurora-XI4x



		   I	We need a swarm cluster
        
https://wiki.wdf.sap.corp/wiki/display/tipinfra/Docker+Swarm+API
On each node, Docker is configured (--insecure-registry dockerdevregistry:5000  and –s devicemapper) 

		II	Installation

Two solutions:

		II.1 With the build of the Dockerfile

On the client:

curl -k https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Aurora-XI4x/api-build.sh > api-build.sh

chmod 777 api-build.sh

./api-build.sh <SwarmManagerSrv-FQDN>

curl -v -H "Accept: application/json" -H "Content-type: application/json" -X POST -d  '{"Hostname": "","User": "","Memory": 0,"MemorySwap": 0,"AttachStdin": true,"AttachStdout": true,"PortSpecs":null,"AttachStderr": false,"Tty": true,"OpenStdin": true,"StdinOnce": false,"Env": null,"Cmd":[ "/bin/bash","/mnt/installAurora.sh","aurora42_cons/1859" ],"Image": "aurora-image", "WorkingDir": "","DisableNetwork": false,"ExposedPorts": {"22/tcp": {} }, "HostConfig": { "Privileged": true,"NetworkMode": "host" } }' <SwarmManagerSrv-FQDN>:4000/containers/create

curl -v -H "Accept: application/json" -H  "Content-type: application/json" -X POST <SwarmManagerSrv-FQDN>:4000/containers/<container-ID>/start


		II.2 With the pull of the image

On the client:

curl -v -H "Accept: application/json" -H "Content-type: application/json" -X POST -d  '{"Hostname": "","User": "","Memory": 0,"MemorySwap": 0,"AttachStdin": true,"AttachStdout": true,"PortSpecs":null,"AttachStderr": false,"Tty": true,"OpenStdin": true,"StdinOnce": false,"Env": null,"Cmd":[ "/bin/bash","/mnt/installAurora.sh", "aurora42_cons/1859"],"Image": "dockerdevregistry:5000/aurora/aurora-prereq", "WorkingDir": "","DisableNetwork": false,"ExposedPorts": {"22/tcp": {} }, "HostConfig": { "Privileged": true,"NetworkMode": "host" } }' <SwarmManagerSrv-FQDN>:4000/containers/create

curl -v -H "Accept: application/json" -H  "Content-type: application/json" -X POST <SwarmManagerSrv-FQDN>:4000/containers/<container-ID>/start

Notes: 
•	For II.1 and II.2, the installation begins when the container is launched.

•	When the installation is finished, the container stop automatically.



		III	Commit the new image (aurora is installed)


curl -v -H "Accept: application/json" -H "Content-type: application/json" -X POST -d  '{"Hostname": "","User": "","Memory": 0,"MemorySwap": 0,"AttachStdin": false,"AttachStdout": true,"AttachStderr": true,"Tty": true,"OpenStdin": false,"PortSpecs":null,"StdinOnce": false,"Env": ["http_proxy=http://proxy.wdf.sap.corp:8080","https_proxy=http://proxy.wdf.sap.corp:8080"],"Cmd":[""],"Volumes":{ "/tmp": {} },"WorkingDir": "","DisableNetwork": false,"ExposedPorts": {"22/tcp": {} } }' <SwarmManagerSrv-FQDN>:4000/commit?container=<container-ID>\&repo=dockerdevregistry:5000/aurora/aurora-test:v1


		IV	Remove the existing container (optional)


curl -v -H "Accept: application/json" -H "Content-type: application/json" -X DELETE <SwarmManagerSrv-FQDN>:4000/containers/<continer-ID>?v=1\&force=1


		V	Run the new image (and start aurora)

curl -v -H "Accept: application/json" -H "Content-type: application/json" -X POST -d  '{
"Hostname": "","User": "","Memory": 0,"MemorySwap": 0,"AttachStdin": true,"AttachStdout": true,"PortSpecs":null,"AttachStderr": false,"Tty": true,"OpenStdin": true,"StdinOnce": false,"Env": null,"Cmd":[ "/bin/bash","/mnt/startAurora.sh"],"Image": "<image-ID>", "WorkingDir": "","DisableNetwork": false,"ExposedPorts": {"22/tcp": {} }, "HostConfig": { "NetworkMode": "host" } }' <SwarmManagerSrv-FQDN>:4000/containers/create

curl -v -H "Accept: application/json" -H  "Content-type: application/json" -X POST <SwarmManagerSrv-FQDN>:4000/containers/<container-ID>/start


		VI	Test

http://dockerhost:port/BOE/BI




