#!/bin/bash

###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - February 2016 -
#  PURPOSE: deploy containers and write testing parameters in a file
#
###############################################################################


#--------------------------------------
function CheckParam {
  if [ $1 -ne 4 ]; then
    echo "Expected parameters, example: ./deploy.sh  aurora  aurora42_cons  aurora4xInstall  2"
    exit 1; fi; }


#--------------------------------------
function InitVars { # aurora, aurora42_cons, aurora4xInstall

  export request="swarm-request.ini"
  export swarmrun="swarmHA-run.sh"
  export versionTxt="version.txt"
  export response="response.ini"

  export gitSwarm="https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/swarm/automation"
  export gitResponse="https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Aurora-XI4x"
  export gitVersion=https://github.wdf.sap.corp/raw/AuroraXmake/$3/master

  export version=$(curl -s -k $gitVersion/$versionTxt)

  if [ ! "${version}" ]; then
    echo "Failed to curl file '$versionTxt' from Github"
    exit 1; fi

  export registry="docker.wdf.sap.corp:50000"
  export image="$1/$2_$version-snapshot"; }


#--------------------------------------
function GetFromGithub {

  echo "Getting file $2 from Github"
  curl -s -k $1/$2 > $3/$2

  if [ ! -f $3/$2 ]; then
    echo "Failed to get '$2' from github"
    exit 1; fi; }


#--------------------------------------
function DeployContainers { # NbContainers

  echo

  if [ ! -f ../$request ]; then
    GetFromGithub $gitSwarm $request ..; fi

  GetFromGithub $gitSwarm $swarmrun .

  echo
  echo "Deploying containers"

  chmod +x $swarmrun
  ./$swarmrun  $registry  $image  $1

  if [ $? -ne 0 ]; then
    exit 1; fi; }


#--------------------------------------
function checkSource {

  if [ ! -f $1 ]; then
    echo "File '$1' is missing"
    exit 1; fi

  source $1; }


#--------------------------------------
function RetrieveHost { # aurora42_cons_2000

  checkSource ../$request

  arrManagers=${managers//,/ }
  for manager in $arrManagers; do
    docker -H $manager:$managerport version &> /dev/null
    if [ $? -ne 0 ]; then
      echo "'$manager' doesn't respond, trying next cluster member"
      continue; fi
    result=$(docker -H $manager:$managerport ps -a | grep $1)
    status=1
    break
  done

  if [ ! "${status}" ]; then
    echo "No alive Swarm manager member found. Cannot retrieve deployed nodes"
    exit 1; fi

  if [ ! "${result}" ]; then
    echo "No '$1' deployed container retrieved"
    exit 1; fi

  arrNodes=${nodes//,/ }
  for nodeFQDN in $arrNodes; do
    node="${nodeFQDN%%.*}"
    dummy=$(echo $result | grep $node)
    if [ $? -eq 0 ]; then
      host=$nodeFQDN
      break; fi
  done

  if [ ! "${host}" ]; then
    echo "Failed to retrieve the host of '$1' container"
    exit 1; fi

  echo $host; }


#--------------------------------------
function RetrieveIP { # hostFQDN

  ping=$(ping -c 1 $1 2>&1 | grep "(")
  if [ ! "${ping}" ]; then
    echo "Failed to retrieve $1 IP"
    exit 1; fi
  IP=$(echo $ping | awk '$3 { print $3 }')
  IP=${IP/(/}
  IP=${IP/)/}
  echo $IP; }


#--------------------------------------
function TestingParameters {  # aurora42_cons, 2000

  echo
  echo
  GetFromGithub $gitResponse $response .
  source $response

  echo
  echo "Retrieving Docker node FQDN"
  hostFQDN=$(RetrieveHost $1_$version)

  if [ $? -ne 0 ]; then
    exit 1; fi

  echo "Retrieving Docker node IP"
  hostIP=$(RetrieveIP $hostFQDN)

  if [ $? -ne 0 ]; then
    exit 1; fi

  echo "Writing testing parameters file '../TestingParameters.txt'"
  (
    echo buildType=$1
    echo version=$version
    echo hostFQDN=$hostFQDN
    echo hostIP=$hostIP
    echo SshPort=32770
    echo user=root
    echo password=root
    echo tomcatPort=$TomcatConnectionPort
    echo cmsPort=$CMSPort
  ) > ../TestingParameters.txt


  echo
  echo "Waiting for /BOE/CMC area to mount"
  elapsed=0
  while [ $elapsed -lt 10 ] && ! curl -s -I http://$hostFQDN:10001/BOE/CMC | grep OK; do
    echo "  Retry in 1 minute"
    elapsed=$((elapsed+1))
    sleep 1m; done

  if [ $elapsed -ne 10 ]; then msg="mounted"; else msg="not mounted"; fi
  echo "/BOE/CMC is" $msg
  echo; }


#---------------  MAIN
# params  aurora  aurora42_cons  aurora4xInstall  NbContainers
set -x

CheckParam $#
InitVars $1 $2 $3
DeployContainers $4
TestingParameters $2 $version
