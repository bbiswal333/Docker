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

if [ ! $# -ne 2 ]; then
  echo "Expected parameters: <MajorName> <ProductFolder>"
  echo "Example: ./deploy.sh  aurora  aurora42"
  exit 1; fi

export version=`curl -s -k https://github.wdf.sap.corp/raw/AuroraXmake/aurora4xInstall/master/version.txt`
if [ ! "${version}" ]; then
  echo "Failed to retrieve version from Github file 'version.txt'"
  exit 1; fi
export access="https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/swarm/automation"
export image="dockerdevregistry.wdf.sap.corp:5000/$1/$2_$version-snapshot"

echo
if [ ! -f swarm-request.ini ]; then
  GetScript swarm-request.ini; fi
GetScript swarmHA-run.sh
GetScript swarm-listnodes.sh

./swarmHA-run.sh	2   "$image"
./swarm-listnodes.sh	    "$image"

if [ -f nodesList.txt ]; then
  echo
  echo "Deployed Swarm nodes:"
  cat nodesList.txt
  echo; fi


pth=/var/jenkins/workspace

if [ -f connectinfo.ini ]; then

  if [ -f $pth/connectinfo.ini ]; then
    rm -f $pth/connectinfo.ini; fi

  mv connectinfo.ini $pth/

  echo
  echo "Connexion info"
  cat $pth/connectinfo.ini
  echo; fi
