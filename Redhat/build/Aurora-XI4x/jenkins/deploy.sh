#set -x

#--------------------------------------
function GetScript {

  echo "Getting script $1"
  curl -s -k $access/$1 > $1
  
  if [ ! -f $1 ]; then
    echo "Failed to git pull '$1' from github"
    exit 1; fi

  chmod +x $1; }


#---------------  MAIN

if [ ! "${1}" ]; then
  echo "Expected parameter <ProductFolder>"
  echo "Example: ./deploy.sh  aurora42"
  exit 1; fi

export version=`curl -s -k https://github.wdf.sap.corp/raw/AuroraXmake/aurora4xInstall/master/version.txt`
if [ ! "${version}" ]; then
  echo "Failed to retrieve version from Github file 'version.txt'"
  exit 1; fi
export access="https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/swarm/automation"
export image="dockerdevregistry:5000/aurora/$1_$version-snapshot"

echo
if [ ! -f swarm-request.ini ]; then
  GetScript swarm-request.ini; fi
GetScript swarmHA-run.sh
GetScript swarm-listnodes.sh

./swarmHA-run.sh		2   "$image"
./swarm-listnodes.sh		"$image"

if [ -f nodesList.txt ]; then
  echo
  echo "Deployed Swarm nodes:"
  cat nodesList.txt
  echo; fi
