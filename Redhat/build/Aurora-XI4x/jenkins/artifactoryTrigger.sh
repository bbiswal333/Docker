#!/bin/bash

###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - february 2016 -
#  PURPOSE: detects the image push of the daily drop version, in an Artifactory repository
#
###############################################################################

# $1 suite = aurora
# $2 folder = aurora42_cons
# $3 xmakerepo = aurora4xInstall

#--------------------------------------
function OnFailed {
  echo $1
  exit 1; }


function OnUnchanged {
  if [ $1 -eq 0 ]; then
    rm -f newCurl-$2.txt
  	exit 1; fi; }

#---------------  MAIN

# params  aurora  aurora42_cons  aurora4xInstall
#set -x

if [ $# -ne 3 ]; then
  echo "Expected parameter <Suite>  <Folder>  <xMakeRepo>"
  OnFailed "Example: artifactoryTrigger.sh  aurora  aurora42_cons  aurora42_cons"; fi

if [ ! -f prevCurl-$2.txt ]; then
   curl -s -k https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Aurora-XI4x/jenkins/prevCurl/prevCurl-$2.txt > prevCurl-$2.txt
  if [ ! -f prevCurl-$2.txt ]; then
    OnFailed "Failed to retrieve 'prevCurl-$2.txt' from GitHub"; fi; fi

version=$(curl -s https://github.wdf.sap.corp/raw/AuroraXmake/$3/master/version.txt)

if [ ! "${version}" ]; then
  OnFailed 'Failed to retrieve version from xMake Github repo'; fi

virtualdocker=https://docker.wdf.sap.corp/artifactory/virtual_docker/$1/$2_$version-snapshot/latest/

curl -s $virtualdocker > newCurl-$2.txt

if [ $? -ne 0 ]; then
   OnFailed "Command 'curl' failed to connect to Artifactory server"; fi

cat newCurl-$2.txt | grep errors
OnUnchanged $? $2

diff prevCurl-$2.txt newCurl-$2.txt
OnUnchanged $? $2

mv -f newCurl-$2.txt prevCurl-$2.txt
