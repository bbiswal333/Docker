#!/bin/bash

###############################################################################
#
#  AUTHOR: gerald.braunwarth@sap.com    - July 2016 -
#  PURPOSE: builds the Dockerfile of image hana-xsa-shine-req
#
###############################################################################

#set -x

echo "Create folder 'build'"
if [ -d build ]; then
  rm -rf build; fi
mkdir build

echo "Getting Dockerfile from Github"
if ! curl -s -k https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Hana-XSA/hana-xsa-shine-req/Dockerfile > build/Dockerfile; then
  echo "Failed to curl Dockerfile"
  exit 1; fi

echo "Running 'docker build'"
echo
image="docker.wdf.sap.corp:51010/hanaxsshine/weekstone/hana-xsa-shine-req"
if ! docker build -t $image build; then
  echo "Failed to build Dockerfile"
  exit 1; fi
