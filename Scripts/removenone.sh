#!/bin/sh

# DONT USE THIS SCRIPT WITHOUT TESTING IT BEFORE. YOU CAN LOOSE USEFULL DATA !

# Use by giving as parameters  the Image Id of the image <none> thant you want to delete. 
# Get the image Id by typing "docker images"
#Ex : ./removenone.sh 1234abcd12ab 1212aabb1234



DIRREG=/var/lib/docker



function gettagim
{
set -x
var=`docker images | grep $1 | cut -d" " -f1`

	if [[ $var = \<none\>  ]] 
	then
	return 0
	else
	return 1
	fi
}

#Test if there you forgot the argument
if [ "$#" = 0 ]
then
	echo "Please give a image name or several image name"
	exit 0
fi

# Delete the folder corresponding only of none images

for i in "$@"
do
gettagim $i
	if [ $? = 0 ]
	then
	find $DIRREG  -name "$i"* | xargs rm -rf 
	fi
done 
