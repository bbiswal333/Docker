#!/bin/bash

###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - february 2016 -
#  PURPOSE: detects the image push of the daily drop version, in an Artifactory repository
#
#  WARNING: The file prevCurl.txt must exists, it contains the previous repositories list before changes
#
###############################################################################

#set -x

# $1 suite = aurora
# $2 folder = aurora42_cons
# $3 xmakerepo = aurora4xInstall


if [ $# -ne 3 ]; then
  echo "Expected parameter <Suite> <Folder>"
  echo "Example: artifactoryTrigger.sh  aurora  aurora42_cons"
  exit 1; fi

if [ ! -f 'prevCurl.txt' ]; then
   curl -s -k 'https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Aurora-XI4x/jenkins/prevCurl.txt' > prevCurl.txt
  if [ ! -f 'prevCurl.txt' ]; then
    echo 'Failed to get file prevCurl.txt from GitHub'
    exit 1; fi; fi

artirepo="https://dewdftv01813.dhcp.pgdev.sap.corp/artifactory/api/storage/devinfrafr/$1/?lastModified"
version=$(curl -s -k https://github.wdf.sap.corp/raw/AuroraXmake/$3/master/version.txt)

if [ ! "${version}" ]; then
  echo "Failed to retrieve version from xMake Github repo"
  exit 1; fi

curl -s -k $artirepo | grep artifactory > newCurl.txt

fgrep -vf prevCurl.txt newCurl.txt | grep $1_$version
status=$?

rm -f prevCurl.txt
mv  newCurl.txt prevCurl.txt

exit $status
