#You need to have a "lastrepo.txt" file on your workspace

set -x
version=`curl -k https://github.wdf.sap.corp/raw/AuroraXmake/aurora4xInstall/master/version.txt`
ls /net/derotvi0127.pgdev.sap.corp/derotvi0127e_bobj/q_unix/Imagesdck/repositories/aurora > newrepo.txt
fgrep -vf lastrepo.txt newrepo.txt > temp.txt
cat temp.txt
cat newrepo.txt > lastrepo.txt
grep aurora42_${version} temp.txt
if [ $? -eq 0 ];  then 
	
			if [ ! -f swarm-request.ini ]; then
		    	curl -k https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/swarm/automation/swarm-request.ini > swarm-request.ini; fi
		curl -k https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/swarm/automation/swarmHA-run.sh > swarmHA-run.sh
		curl -k https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/swarm/automation/swarm-listnodes.sh > swarm-listnodes.sh
		
		chmod +x swarmHA-run.sh
		chmod +x swarm-listnodes.sh
		chmod +r swarm-request.ini
		
		image="dockerdevregistry:5000/aurora/aurora42_${version}-snapshot"
		/bin/bash ${WORKSPACE}/swarmHA-run.sh 2   "$image"
		/bin/bash ${WORKSPACE}/swarm-listnodes.sh "$image"
		cat nodesList.txt; fi 


