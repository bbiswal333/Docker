#!/bin/sh

## -------------------------------------------------------------------
## Encapsulate the trigerring of the RM script Build.pl
## ------------------------------------------------------------------

export RM_TOOL_HOME=/build/pblack/core.build.tools

## Variables used by the perl script to generate qrs file :
export ARCHITECTURE=64
export BUILD_INI_FILE=aurora42_cons.ini
export BUILD_VERSION=2000
export SMTMACHINE=mo-4c15f6e46.mo.sap.corp
export SMTMACHINE_IP=10.97.147.21
export TOMCATPORT=10001
export CMSPORT=10004

cd $RM_TOOL_HOME

#Set Build Ini File
RM_TOOL_INI=$RM_TOOL_HOME/export/shared/contexts/${BUILD_INI_FILE}
echo RM Ini file used : $RM_TOOL_INI

#Launch Build.pl script => launch smoke test
perl $RM_TOOL_HOME/export/shared/Build.pl -$ARCHITECTURE -dashboard -warning=0 -i=$RM_TOOL_INI -v=$BUILD_VERSION -S 1> ${RM_TOOL_HOME}/Buildpl_SMT.log 2>&1
