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
  if [ $1 -ne 3 ]; then
    echo "3 expected parameters, example: ./deploy.sh  aurora  aurora42  aurora42_cons"
    exit 1; fi; }


#--------------------------------------
function InitVars {

  export request="swarm-request.ini"
  export swarmrun="swarmHA-run.sh"
  export versionTxt="version.txt"
  export response="response.ini"

  export gitSwarm="https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/swarm/automation"
  export gitResponse="https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Aurora-XI4x"
  export gitVersion="https://github.wdf.sap.corp/raw/AuroraXmake/aurora4xInstall/master"

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
  ./$swarmrun	 2  "$image"; }


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

  cat $nodesList
  echo

  if [ $nodeone = . ]; then
      echo "No deployed node retrieved. Quitting"
    exit 1; fi; }


#--------------------------------------
function WriteConnnectionFile {

  ## retrieve nodeone IP 
  #ping=`ping -c 1 $nodeone 2>&1 | grep "("`
  #if [ ! "${ping}" ]; then
  #  echo "Failed to retrieve $nodeone IP"
  #  exit 1; fi
  #IP=`echo $ping | awk '$3 { print $3 }'`
  #IP=${IP/(/}
  #IP=${IP/)/}


  ## WRITE connectinfo.ini
  echo
  GetFromGithub $gitResponse $response .

  echo
  echo "Connexion info file:"

  connectinfo="../connectinfo.ini"

  source $response

  echo BUILD_NUMBER=$version              >  $connectinfo
  echo BUILD_STREAM=$1                    >> $connectinfo
  echo ip=$nodeone                        >> $connectinfo
  echo user=root                          >> $connectinfo
  echo password=root                      >> $connectinfo
  echo tomcat_port=$TomcatConnectionPort  >> $connectinfo
  echo cms_port=$CMSPort                  >> $connectinfo

  cat $connectinfo
  echo; }


#---------------  MAIN

set -x

CheckParam $#
InitVars $1 $2
DeployContainers
RetrieveDeployedNodes "$2_$version"
WriteConnnectionFile $3
