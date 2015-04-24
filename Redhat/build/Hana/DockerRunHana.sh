
###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com
#
###############################################################################

if [ ! "${1}" ]; then
  echo "Usage: DockerRunHana.sh <InstanceNumber>"
  exit 1; fi


 docker run  -it  --name=hana094-$1    --privileged  --net=host  -v /etc/localtime:/etc/localtime -v /docker/build/hana:/docker    dockerdevregistry:5000/hana/hana094  /bin/sh -c "/docker/StartHana.sh $1"
#docker run  -it  --name=hana094-test  --privileged  --net=host  -v /etc/localtime:/etc/localtime -v /docker/build/hana:/scripts   dewdftzlidck:5000/hana/hana094       /bin/sh
#docker run  -it  --name=hana094-test  --privileged  --net=host  -v /etc/localtime:/etc/localtime -v /docker/build/hana:/scripts   dockerdevregistry:5000/hana/hana094  /bin/sh
