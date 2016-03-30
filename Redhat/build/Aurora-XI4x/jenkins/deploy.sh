#!/bin/bash

###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - February 2016 -
#  PURPOSE: 
#      - writes into 'nodesList.txt' the swarm nodes list deployed with the image
#      - write into connectinfo.ini the connexion info for the first node
#
###############################################################################


#--------------------------------------
function CheckParam {
  if [ $1 -ne 4 ]; then
    echo "Expected parameters, example: ./deploy.sh  aurora  aurora42_cons  aurora4xInstall  2"
    exit 1; fi; }


#--------------------------------------
function InitVars {

  export request="swarm-request.ini"
  export swarmrun="swarmHA-run.sh"
  export versionTxt="version.txt"
  export response="response.ini"

  export gitSwarm="https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/swarm/automation"
  export gitResponse="https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Aurora-XI4x"
  export gitVersion="https://github.wdf.sap.corp/raw/AuroraXmake/$3/master"

  export version=$(curl -s -k $gitVersion/$versionTxt)

  if [ ! "${version}" ]; then
    echo "Failed to retrieve version from Github file '$versionTxt'"
    exit 1; fi

  export image="dockerdevregistry.wdf.sap.corp:5000/$1/$2_$version-snapshot"
  export nodeone=.; }


#--------------------------------------
function GetFromGithub {

  echo "Getting file $2 from Github"
  curl -s -k $1/$2 > $3/$2

  if [ ! -f $3/$2 ]; then
    echo "Failed to get '$2' from github"
    exit 1; fi; }


#--------------------------------------
function DeployContainers {

  echo

  if [ ! -f ../$request ]; then
    GetFromGithub $gitSwarm $request ..; fi
  GetFromGithub $gitSwarm $swarmrun .

  echo
  echo "Deploying containers"

  chmod +x $swarmrun
  ./$swarmrun	 $1  "$image"; }


#--------------------------------------
function RetrieveDeployedNodes {

  nodesInstall="nodesInstall.txt"
  nodesList="nodesList.txt"

  if [ -f $nodesList ]; then
    rm -f $nodesList; fi

  source "../$request"

  arrManagers=${managers//,/ }
  for manager in $arrManagers; do
    docker -H $manager:$managerport ps &> /dev/null
    if [ $? -ne 0 ]; then
      echo "'$manager' doesn't respond, trying next cluster member"
      continue; fi
    docker -H $manager:$managerport ps -a | grep $1 > $nodesInstall
    status=1
    break
  done

  if [ ! ${status} ]; then
    echo "No alive Swarm manager member found. Cannot retrieve deployed nodes"
    exit 1; fi


  echo
  echo "Deployed Swarm nodes:"

  arrNodes=${nodes//,/ }
  for nodeFQDN in $arrNodes; do
    node="${nodeFQDN%%.*}"
    grep $node $nodesInstall
    if [ $? -eq 0 ]; then
      if [ $nodeone = . ]; then
        nodeone=$nodeFQDN; fi
      printf "$node\n" >> $nodesList; fi
  done

  rm -f $nodesInstall

  if [ $nodeone = . ]; then
      echo "No deployed node retrieved. Quitting"
    exit 1; fi

  cat $nodesList
  echo; }


#--------------------------------------
function WriteConnnectionFile {

  # Write file connectinfo.ini
  echo
  GetFromGithub $gitResponse $response .

  echo
  echo "Connexion info file:"

  connectinfo="../connectinfo.ini"

  source $response

  {
    echo BUILD_NUMBER=$version
    echo BUILD_STREAM=$1
    echo ip=$nodeone
    echo user=root
    echo password=root
    echo tomcat_port=$TomcatConnectionPort
    echo cms_port=$CMSPort
  } > $connectinfo

  cat $connectinfo
  echo; }


#--------------------------------------
function SmokeTest {

  # retrieve nodeone IP
  ping=$(ping -c 1 $nodeone 2>&1 | grep "(")
  if [ ! "${ping}" ]; then
    echo "Failed to retrieve $nodeone IP"
    exit 1; fi
  IP=$(echo $ping | awk '$3 { print $3 }')
  IP=${IP/(/}
  IP=${IP/)/}


  template=RunSmokeTest.sh
  fileName=RunSmt-$1.sh

  curl -s -k https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Aurora-XI4x/jenkins/$template > $filename

  if [ ! -f $filename ]; then
    echo "Failed to curl file '$template' from Github"
    exit 1; fi

  sed "
    / ARCHITECTURE=/s/=.*/=64/
    / BUILD_INI_FILE=/s/=.*/=$1.ini/
    / BUILD_VERSION=/s/=.*/=$version/
    / SMTMACHINE=/s/=.*/=$nodeone/
    / SMTMACHINE_IP=/s/=.*/=$IP/
    / TOMCATPORT=/s/=.*/=$TomcatConnectionPort/
    / CMSPORT=/s/=.*/=$CMSPort/
    s/Buildpl_SMT.log/Buildpl_SMT-$1.log/
    " $template > $fileName


#  {
#    echo "#!/bin/sh"
#    echo
#    echo "## -------------------------------------------------------------------"
#    echo "## Encapsulate the trigerring of the RM script Build.pl"
#    echo "## ------------------------------------------------------------------"
#    echo
#    echo "export RM_TOOL_HOME=/build/pblack/core.build.tools"
#    echo
#    echo "## Variables used by the perl script to generate qrs file :"
#    echo "export ARCHITECTURE=64"
#    echo "export BUILD_INI_FILE=$1.ini"
#    echo "export BUILD_VERSION=$version"
#    echo "export SMTMACHINE=$nodeone"
#    echo "export SMTMACHINE_IP=$IP"
#    echo "export TOMCATPORT=$TomcatConnectionPort"
#    echo "export CMSPORT=$CMSPort"
#    echo
#    echo "cd \$RM_TOOL_HOME"
#    echo
#    echo "#Set Build Ini File"
#    echo "RM_TOOL_INI=\$RM_TOOL_HOME/export/shared/contexts/\${BUILD_INI_FILE}"
#    echo "echo RM Ini file used : \$RM_TOOL_INI"
#    echo
#    echo "#Launch Build.pl script => launch smoke test"
#    echo "perl \$RM_TOOL_HOME/export/shared/Build.pl -\$ARCHITECTURE -dashboard -warning=0 -i=\$RM_TOOL_INI -v=\$BUILD_VERSION -S 1> \${RM_TOOL_HOME}/Buildpl_SMT.log 2>&1"
#  } > $fileName

  buildMachine="dewdftvu1018.wdf.sap.corp"
  user="pblack"

  chmod +x $fileName
  scp -oStrictHostKeyChecking=no ./$fileName $user@$buildMachine:/build/$user/tmp/$fileName

  if [ $? -ne 0 ]; then
    echo "Failed to scp '$fileName' to build machine '$buildMachine'"
    exit 1; fi

echo  ssh $user@$buildMachine -oStrictHostKeyChecking=no /build/$user/tmp/$fileName; }


#---------------  MAIN
# params  aurora  aurora42_cons  aurora4xInstall  NbContainers

CheckParam $#
InitVars $1 $2 $3
DeployContainers $4
RetrieveDeployedNodes "$2_$version"
WriteConnnectionFile $2
SmokeTest $2
