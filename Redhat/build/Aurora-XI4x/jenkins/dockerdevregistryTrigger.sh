#!/bin/bash

###############################################################################
#
#  AUTHOR: simon.gomez@sap.com
#          gerald.braunwarth@sap.com    - february 2015 -
#  PURPOSE: detects the image push of the daily drop version, in an Artifactory repository
#
#  WARNING: The file lastrepo.txt must exists, it contains the previous repositories list before changes
#
###############################################################################

#set -x


if [ $# -ne 3 ]; then
  echo 'Expected parameter <suite>  <ProductFolder>  <xMakeRepo>'
  echo 'Example: dockerdevregistryTrigger.sh  aurora  aurora42_cons  aurora4xInstall'
  exit 1
fi

dockerrepo="/net/derotvi0127.pgdev.sap.corp/derotvi0127e_bobj/q_unix/Imagesdck/repositories/$1"

if [ ! -f 'lastrepo.txt' ]; then
   curl -s -k 'https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Aurora-XI4x/jenkins/lastrepo.txt' > lastrepo.txt
  if [ ! -f 'lastrepo.txt' ]; then
    echo 'Failed to get file lastrepo.txt from GitHub'
    exit 1; fi; fi

version="$(curl -s -k https://github.wdf.sap.corp/raw/AuroraXmake/$3/master/version.txt)"

if [ -z "${version}" ]; then
  echo 'Failed to retrieve version from xMake Github repo'
  exit 1; fi

ls "${dockerrepo}" > newrepo.txt

fgrep -vf lastrepo.txt newrepo.txt | grep $2_${version}
status="$?"

rm -f lastrepo.txt
mv newrepo.txt lastrepo.txt

exit "${status}"
