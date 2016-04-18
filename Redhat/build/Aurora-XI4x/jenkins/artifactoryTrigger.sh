#!/bin/bash

###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - february 2016 -
#  PURPOSE: detects the image push of the daily drop version, in an Artifactory repository
#
###############################################################################

set -x

# $1 suite = aurora
# $2 folder = aurora42_cons
# $3 xmakerepo = aurora4xInstall

if [ $# -ne 3 ]; then
  echo "Expected parameter <Suite>  <Folder>  <xMakeRepo>"
  echo "Example: artifactoryTrigger.sh  aurora  aurora42_cons  aurora42_cons"
  exit 1; fi

if [ ! -f prevCurl-$2.txt ]; then
   curl -s -k https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Aurora-XI4x/jenkins/prevCurl/prevCurl-$2.txt > prevCurl-$2.txt
  if [ ! -f prevCurl-$2.txt ]; then
    echo "Failed to retrieve 'prevCurl-$2.txt' from GitHub"
    exit 1; fi; fi

version=$(curl -s -k https://github.wdf.sap.corp/raw/AuroraXmake/$3/master/version.txt)

if [ ! "${version}" ]; then
  echo 'Failed to retrieve version from xMake Github repo'
  exit 1; fi

artirepo=https://docker.wdf.sap.corp:10443/artifactory/list/cidemo/$1/
artibuild=https://docker.wdf.sap.corp:50000/artifactory/api/storage/cidemo/$1/$2_${version}-snapshot

curl -s $artirepo | grep -i 'snapshot' > newCurl-$2.txt

if [ $? -ne 0 ]; then
  echo "Failed to retrieve '$1' images list from Artifactory"
  exit 1; fi

grep -vf prevCurl-$2.txt newCurl-$2.txt | grep $2_$version-snapshot
status=$?

if [ $status -eq 0 ]; then
  curl -s ${artirepo}/$2_${version}-snapshot/latest | grep -i 'path'
  status=$?
  if [ $status -eq 0 ]; then
	  rm -f prevCurl-$2.txt
  	mv  newCurl-$2.txt prevCurl-$2.txt
  fi
fi

exit $status
