###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - february 2016 -
#  PURPOSE: detects the image push of the daily drop version, in an Artifactory repository
#
#  WARNING: The file prevCurl.txt must exists, it contains the previous repositories list before changes
#
###############################################################################

#set -x

artirepo="https://dewdftv01813.dhcp.pgdev.sap.corp/artifactory/api/storage/devinfrafr/simon/?lastModified"

if [ $# -ne 1 ]; then
  echo "Expected parameter <ProductFolder>"
  echo "Example: artifactoryTrigger.sh  aurora_42"
  exit 1; fi

if [ ! -f prevCurl.txt ]; then
  echo "Missing file 'prevCurl.txt' that contains the previous inventory to be compared"
  exit 1; fi

version=`curl -s -k https://github.wdf.sap.corp/raw/AuroraXmake/aurora4xInstall/master/version.txt`

if [ ! "${version}" ]; then
  echo "Failed to retrieve version from xMake Github repo"
  exit 1; fi

curl -s -k $artirepo | grep artifactory > newCurl.txt

fgrep -vf prevCurl.txt newCurl.txt | grep $1_$version
status=$?

rm -f prevCurl.txt
mv  newCurl.txt prevCurl.txt

exit $status
