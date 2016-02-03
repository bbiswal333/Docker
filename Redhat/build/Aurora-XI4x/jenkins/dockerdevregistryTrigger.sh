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

dockerrepo="/net/derotvi0127.pgdev.sap.corp/derotvi0127e_bobj/q_unix/Imagesdck/repositories/aurora"

if [ $# -ne 1 ]; then
  echo "Expected parameter <ProductFolder>"
  echo "Example: dockerdevregistryTrigger.sh  aurora_42"
  exit 1; fi

if [ ! -f lastrepo.txt ]; then
  echo "Missing file 'lastrepo.txt' that contains the previous inventory to be compared"
  exit 1; fi

version=`curl -s -k https://github.wdf.sap.corp/raw/AuroraXmake/aurora4xInstall/master/version.txt`

if [ ! "${version}" ]; then
  echo "Failed to retrieve version from xMake Github repo"
  exit 1; fi
  
ls $dockerrepo>newrepo.txt

fgrep -vf lastrepo.txt newrepo.txt | grep $1_${version}
status=$?

rm -f lastrepo.txt
mv  newrepo.txt lastrepo.txt

exit $status
