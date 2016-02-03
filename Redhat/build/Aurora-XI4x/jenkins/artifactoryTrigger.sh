###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - february 2015 -
#  PURPOSE: detects the image push of the daily drop version, in an Artifactory repository
#
###############################################################################

#set -x

if [ $# -ne 1 ]; then
  echo "Expected parameter <ProductFolder>"
  echo "Example: artifactoryTrigger.sh  aurora_42"
  exit 1; fi

artirepo="https://dewdftv01813.dhcp.pgdev.sap.corp/artifactory/api/storage/devinfrafr/simon/?lastModified"

version=`curl -s -k https://github.wdf.sap.corp/raw/AuroraXmake/aurora4xInstall/master/version.txt`
if [ ! "${version}" ]; then
  echo "Failed to retrieve version from xMake Github repo"
  exit 1; fi

curl -s -k $artirepo | grep $1_$version

exit $?
