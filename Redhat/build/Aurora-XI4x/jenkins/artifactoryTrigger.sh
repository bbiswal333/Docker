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
    echo "Failed to get file prevCurl-$2.txt from GitHub"
    exit 1; fi; fi

artirepo="https://docker.wdf.sap.corp/artifactory/api/storage/cidemo/$1/"
version=$(curl -s -k https://github.wdf.sap.corp/raw/AuroraXmake/$3/master/version.txt)

if [ ! "${version}" ]; then
  echo 'Failed to retrieve version from xMake Github repo'
  exit 1; fi

curl -s -k $artirepo | grep uri > newCurl-$2.txt

fgrep -vf prevCurl-$2.txt newCurl-$2.txt | grep $2_$version-snapshot
status=$?

rm -f prevCurl-$2.txt
mv  newCurl-$2.txt prevCurl-$2.txt

exit $status
