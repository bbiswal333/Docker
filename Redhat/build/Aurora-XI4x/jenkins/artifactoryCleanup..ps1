﻿#*************************************************************************
# Author: gerald.braunwarth@sap.com			- April 2016 -
# Purpose : Cleanup Artifactory keeping 3 last versions of each build type
#*************************************************************************

# parameters: aurora  3

if ($args.Count -ne 2) {
  Write-Host "Expected argument: <SuiteName> <NbVersionsToKeep>"
  Write-host "Example artifactoryCleanup.ps1  aurora  3"
  exit 1 }

$suite = $args[0]
$max = $args[1]

## DEBUG
#cls
#$suite = 'aurora'
#$max = 3
## ENDDEBUG

$AllBuild = 'aurora_pi_aolap', 'aurora_pi_po', 'aurora_pi_tp', 'aurora_rel_cs', 'aurora42_cons', 'aurora42_cons_ml'

$registry = 'https://docker.wdf.sap.corp'
$ports    = '51003', '51020'
$repos    = 'cidemo', 'xmake_snapshot'

$apiKey = 'AKCp2UNNGgbwi9YrxsAXiGdtMN8FLaTumzzMNiXs2xELzfEDGp9NnqsHhQPK9EXJM8vTsHDC9'
$header = @{"X-Jfrog-Art-Api" = $apiKey}

$html = Invoke-WebRequest -Uri "$registry/artifactory/virtual_docker/$suite"

if (-not $html.AllElements.Count) {
  Write-Host 'Failed to retrieve Aurora images list from Artifactory server'
  exit 1 }

$href = $html.AllElements | select href | where { $_ -match $suite } | sort -Property href

foreach ($build in $AllBuild) {
  
  [System.Collections.ArrayList]$versions = $href | where { $_.href -match "$($build)_([0-9])"  }
  $NbDelete = $versions.Count - $max
  
  for ($i = 0; $i -lt $NbDelete; $i++) {
    for ($j = 0; $j -lt 2; $j++) {
	  $result = Invoke-RestMethod -ErrorVariable Err -ErrorAction SilentlyContinue -Method Delete -Header $header -Uri "$($registry):$($ports[$j])/artifactory/$($repos[$j])/$suite/$($versions[0].href)" }
    $versions.RemoveAt(0) }}

# Empty Recycle Bin
foreach ($repo in $repos) {
  $result = Invoke-RestMethod -ErrorVariable Err -ErrorAction SilentlyContinue -Method Delete -Header $header -Uri "$($registry)/artifactory/api/trash/clean/$repo/$suite" }