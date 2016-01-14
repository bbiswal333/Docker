
		version=`curl -k https://github.wdf.sap.corp/raw/AuroraXmake/aurora4xInstall/master/version.txt`
		if [ ! -f swarm-request.ini ]; then
		    	curl -k https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/swarm/automation/swarm-request.ini > swarm-request.ini; fi
		curl -k https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/swarm/automation/swarmHA-run.sh > swarmHA-run.sh
		curl -k https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/swarm/automation/swarm-listnodes.sh > swarm-listnodes.sh
		
		chmod +x swarmHA-run.sh
		chmod +x swarm-listnodes.sh
		chmod +r swarm-request.ini
		
		image="dockerdevregistry:5000/aurora/aurora42_${version}-snapshot"

		./swarmHA-run.sh 2   "$image"
		./swarm-listnodes.sh "$image"

		cat nodesList.txt


