#!/bin/bash

###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - March 2016 -
#  PURPOSE: Customize script values  and run SmokeTest script
#
###############################################################################

echo
echo "Runnning Smoke Test"


file="../TestingParameters.txt"

if [ ! -f $file ]; then
  echo "File '$file' is missing"
  exit 1; fi

source $file

template=RunSmokeTest.sh
fileName=RunSmt-$buildType.sh

curl -s -k https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Aurora-XI4x/jenkins/$template > $template

if [ ! -f $template ]; then
  echo "Failed to curl file '$template' from Github"
  exit 1; fi

sed "
  / ARCHITECTURE=/s/=.*/=64/
  / BUILD_INI_FILE=/s/=.*/=$buildType.ini/
  / BUILD_VERSION=/s/=.*/=$version/
# / SMTMACHINE=/s/=.*/=$hostFQDN/
  / SMTMACHINE=/s/=.*/=localhost/
  / SMTMACHINE_IP=/s/=.*/=$hostIP/
  / TOMCATPORT=/s/=.*/=$tomcatPort/
  / CMSPORT=/s/=.*/=$cmsPort/
  s/Buildpl_SMT.log/Buildpl_SMT-$buildType.log/
  " $template > $fileName

buildMachine="dewdftvu1018.wdf.sap.corp"
user="pblack"

chmod +x $fileName
scp -oStrictHostKeyChecking=no ./$fileName $user@$buildMachine:/build/$user/tmp/$fileName

if [ $? -ne 0 ]; then
  echo "Failed to scp '$fileName' to build machine '$buildMachine'"
  exit 1; fi

ssh $user@$buildMachine -oStrictHostKeyChecking=no /build/$user/tmp/$fileName
status=$?

echo $filename "returned exit code" $status

exit 0
