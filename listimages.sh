###############################################################################
#
#  AUTHOR: veronica.andreescu@sap.com
#
###############################################################################


#!/bin/bash
DIRREPO=/net/derotvi0127.pgdev.sap.corp/derotvi0127e_bobj/q_unix/Imagesdck
Norep=`ls -d $DIRREPO/repositories/* | wc -l`
reponame=dewdftzlidck
#export LS_COLORS=$LS_COLORS:fi=94
unset LS_COLORS
echo ""
if [ -d $DIR ]
then
echo "**********************************"
echo  -e "Number of repository $Norep : List of repository name :"
echo "**********************************"
#ls $DIRREPO/repositories
#ls -l -Q $DIRREPO/repositories  | awk '{print $9}' | sort
export LS_COLORS="di=33":$LS_COLORS
ls -1C -Q --color=always $DIRREPO/repositories 
else 
echo -e "Check if autofs is started"
fi
echo "**********************************"
echo -e "List of images name: "
echo "**********************************"
for i in `ls $DIRREPO/repositories`
do
echo ""
echo -e "In the repository ''$i'' : \t"
unset LS_COLORS
export LS_COLORS="di=45":$LS_COLORS
ls -1 -Q --color=always $DIRREPO/repositories/$i #|  awk '{print $9}'
echo "**********************************"
done
echo "---------------------------------------------"
echo "To copy an images launch : "
echo "docker pull $reponame:5000/repository_name/repository_image_name"
echo "---------------------------------------------"

