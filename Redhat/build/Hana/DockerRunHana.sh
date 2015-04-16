
###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com
#
###############################################################################

#docker run  -it  --name=hana094-00    --privileged  --net=host  -v /etc/localtime:/etc/localtime -v /root/docker/build/hana/StartHana.sh:/StartHana.sh   dewdftzlidck:5000/hana/hana094  /bin/sh -c "/StartHana.sh $1"
 docker run  -it  --name=hana094-test  --privileged  --net=host  -v /etc/localtime:/etc/localtime -v /docker/build/hana:/scripts   dewdftzlidck:5000/hana/hana094  /bin/sh
