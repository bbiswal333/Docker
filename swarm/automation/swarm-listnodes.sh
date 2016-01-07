
###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - November 2015 -
#  PURPOSE: writes the swarm cluster nodes list into file 'nodeslist.txt'
#
###############################################################################


#---------------  MAIN
clear
set -x

scriptpath=$(dirname $(readlink -e $0))
request="$scriptpath/swarm-request.ini"
listnodes="$scriptpath/listnodes.txt"

if [ ! -f $request ]; then
  echo "File '$request' not found"
  exit 1; fi

if [ -f $listnodes ]; then
  rm -f $listnodes; fi

source "$request"

arrNodes=${nodes//,/ }
for node in $arrNodes; do
  printf "$node\n" >> $listnodes
done
