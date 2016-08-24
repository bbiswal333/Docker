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

# RED HAT only:
# 'no_proxy' variable configured by old Chef recipes are too poor for the alias 'docker.wdf.sap.corp'
registry=docker.wdf.sap.corp
no_proxy=$registry,$no_proxy

if ! curl -s -H X-JFrog-Art-Api:$1 -X DELETE https://$registry:51010/artifactory/refapps/hanaxsshine/weekstone/$2/$3; then
  echo "Failed to delete image"
  exit 1; fi
