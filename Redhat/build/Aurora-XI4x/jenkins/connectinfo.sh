#!/bin/bash

###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - March 2016 -
#  PURPOSE: write connection info to containers for Testing activities
#
###############################################################################

file="../TestingParameters.txt"

if [ ! -f $file ]; then
  echo "File '$file' is missing"
  exit 1; fi

source $file

echo
echo "Connexion info file:"
connectinfo="../connectinfo.ini"

{
  echo BUILD_STREAM=$buildType
  echo BUILD_NUMBER=$version
  echo ip=$hostFQDN
  echo user=$user
  echo password=$password
  echo tomcat_port=$tomcatPort
  echo cms_port=$cmsPort
} > $connectinfo

cat $connectinfo
echo
