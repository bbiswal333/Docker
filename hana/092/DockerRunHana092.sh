
###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com
#
###############################################################################

docker run  -it  --name=hana092-00  --privileged  --net=host  -v etc/localtime:/etc/localtime -v /root/docker/build/hana/092/StartHana.sh:/StartHana.sh   dewdftzlidck:5000/hana/hana092  /bin/sh -c /StartHana.sh

