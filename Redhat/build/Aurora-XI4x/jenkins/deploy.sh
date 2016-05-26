#!/bin/bash

###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - February 2016 -
#  PURPOSE: deploy containers and write testing parameters in a file
#
###############################################################################


#--------------------------------------
function OnError {

  echo
  echo $1
  echo

  exit 1; }


#--------------------------------------
function CheckParam {

  if [ $1 -ne 4 ]; then
    OnError "Expected parameters, example: ./deploy.sh  aurora  aurora42_cons  aurora4xInstall  2"; fi; }


#--------------------------------------
function OnMissingFile {

  if [ ! -f $1 ]; then
    OnError "File '$1' is missing"; fi; }


#--------------------------------------
function OnFailed {

  if [ $1 -ne 0 ]; then
    exit 1; fi; }


#--------------------------------------
function GetFromGithub {

  echo "Getting file '$2' from Github"
  curl -s -k $1/$2 > $3/$2

  if [ ! -f $3/$2 ]; then
    OnError "Failed to get '$2' from github"; fi; }


#--------------------------------------
function Init { # aurora, aurora42_cons, aurora4xInstall

  gitUndeploy="https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Aurora-XI4x/jenkins"
  export undeploy="undeploy.sh"

  gitSwarm="https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/swarm/automation"
  export swarmrun="swarmHA-run.sh"

  gitResponse="https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Aurora-XI4x"
  export response="response.ini"

  gitVersion=https://github.wdf.sap.corp/raw/AuroraXmake/$3/master
  versionTxt="version.txt"
  export version=$(curl -s -k $gitVersion/$versionTxt)

  if [ ! "${version}" ]; then
    OnError "Failed to curl file '$versionTxt' from Github"; fi

  export request="swarm-request.ini"
  export registry="docker.wdf.sap.corp:50000"
  export image="$1/$2_$version-snapshot"

  OnMissingFile ../$request

  GetFromGithub $gitUndeploy $undeploy .
  GetFromGithub $gitSwarm $swarmrun .
  GetFromGithub $gitResponse $response .

  chmod +x $undeploy
  chmod +x $swarmrun; }


#--------------------------------------
function CleanUp {

  ./$undeploy $1_[0-9][0-9]*; }


#--------------------------------------
function DeployContainers { # NbContainers

  echo
  echo "Deploying containers"

  ./$swarmrun  $registry  $image  $1
  OnFailed $?; }


#--------------------------------------
function RetrieveHost { # aurora42_cons_2000

  source ../$request

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
    OnError "No alive Swarm manager member found. Cannot retrieve deployed nodes"; fi

  if [ ! "${result}" ]; then
    OnError "No '$1' deployed container retrieved"; fi

  arrNodes=${nodes//,/ }
  for nodeFQDN in $arrNodes; do
    node="${nodeFQDN%%.*}"
    dummy=$(echo $result | grep $node)
    if [ $? -eq 0 ]; then
      host=$nodeFQDN
      break; fi
  done

  if [ ! "${host}" ]; then
    OnError "Failed to retrieve the host of '$1' container"; fi

  echo $host; }


#--------------------------------------
function RetrieveIP { # hostFQDN

  ping=$(ping -c 1 $1 2>&1 | grep "(")
  if [ ! "${ping}" ]; then
    OnError "Failed to retrieve $1 IP"; fi
  IP=$(echo $ping | awk '$3 { print $3 }')
  IP=${IP/(/}
  IP=${IP/)/}
  echo $IP; }


#--------------------------------------
function TestingParameters {  # aurora42_cons

  source $response

  echo
  echo "Retrieving Docker node FQDN"
  hostFQDN=$(RetrieveHost $1_$version)
  OnFailed $?

  echo "Retrieving Docker node IP"
  hostIP=$(RetrieveIP $hostFQDN)
  OnFailed $?

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
# Parameters:  aurora  aurora42_cons  aurora4xInstall  NbContainers

#set -x

CheckParam $#
Init $1 $2 $3
CleanUp $2
DeployContainers $4
TestingParameters $2
