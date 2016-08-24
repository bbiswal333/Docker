#!/bin/bash

###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - August 2016 -
#  PURPOSE: delete a xsa / shine image from Artifactory
#
###############################################################################


set -x

if [ $# -ne 3 ]; then
  echo "Expected parameters: <ApiKey> <Image> <Tag>"
  echo "Example: ./delete-xsa.sh  <ApiKey>  hana-xsa  latest"
  exit 1; fi

if ! curl -H X-JFrog-Art-Api:$1 -X DELETE https://docker.wdf.sap.corp:51010/artifactory/refapps/hanaxsshine/weekstone/$2/$3; then
  echo "Failed to delete image"
  exit 1; fi
