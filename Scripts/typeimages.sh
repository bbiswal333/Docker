#!/bin/sh
#set -x
DIRREG=/net/derotvi0127.pgdev.sap.corp/derotvi0127e_bobj/q_unix/Imagesdck
DIRREPO=$DIRREG/repositories
DIRIMG=$DIRREG/images
#LISTTAGIMG=( $(ls $DIRIMG) )
#echo $LISTIMAGES
#Norep=`ls -d $DIRREPO/repositories/* | wc -l`
Reponame=dockerdevregistry


echo "Please give the image id"
read imid

function Getnumberimages
{

	Noimages=`ls -d $DIRREPO/* | wc -l`

	echo $Noimages
	
}

function ImageExist

{

ls $DIRIMG/"$1"* > /dev/null 2>&1

if [ $? != 0 ]
then
return 1
else
return 0
fi
}

function TagExist
{

tempfile=/tmp/list.txt

ImageExist $1

if [ $? = 1 ]
then
exit 1
else
find $DIRREG/repositories/ -name tag_latest  >> $tempfile
fi

for i in `cat $tempfile`
do
cat $i | grep "$1" > /dev/null 2>&1

if [ $? = 0 ]
then
return 0
echo $i
else
return 1
fi
done

}



function TagImage
{
ImageExist $1 

if [ $? = 1 ]
then
exit 1
fi

TagExist $1

if [ $? = 1 ]
then
echo "The image hasn't tag"
fi


ocur=0
for i in `ls -d $DIRREPO/*/*/`
do

#	if [ ! -f $i/tag_latest ]
#	then
#	return 1
#	fi
	cat $i/tag_latest | grep $1  > /dev/null 2>&1
	if [ $? = 0 ]
	then
	echo "The image name is $i"	
	ocur=$((ocur+1))
	fi	
done

#if [ $ocur -gt 0 ]
#then
#echo "The image is present in the registry and it has $ocur tag"
#return 0
#else
#return 1
#fi

}

function ImageParent
{
ImageExist $1
	if [ $? = 1 ]
	then
	exit 1
	fi
Depend=`cat $DIRIMG/$1*/ancestry | jq '.[]' | wc -l`  > /dev/null 2>&1
Depend=$((Depend-1))
echo "The image has $Depend images that depends on"
	if [ $Depend -gt 1 ]
	then
	return 1
	else
	return 0
	fi
}


ImageExist $imid

if [ $? = 1 ]
then
echo "Image $imid doesn't exist"
exit 1
fi

TagImage $imid

ImageParent $imid
