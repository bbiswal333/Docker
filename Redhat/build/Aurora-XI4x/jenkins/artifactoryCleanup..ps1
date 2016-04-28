#*************************************************************************
# Author: gerald.braunwarth@sap.com
# Purpose : Cleanup Artifactory keeping 3 last versions of each build type
#*************************************************************************

#  aurora  3

#if ($args.Count -ne 2) {
#  Write-Host "Expected argument: <SuiteName> <NbVersionsToKeep>
#  Write-host "Example artifactoryCleanup.ps1  aurora  3"
#  return 1 }

$suite = $args[0]
$max = $args[1]

## DEBUG
cls
$suite = 'aurora'
$max = 3
## ENDDEBUG

$AllBuild = 'aurora_pi_aolap', 'aurora_pi_po', 'aurora_pi_tp', 'aurora_rel_cs', 'aurora42_cons', 'aurora42_cons_ml'

$apiKey = 'AKCp2UNNGgbwi9YrxsAXiGdtMN8FLaTumzzMNiXs2xELzfEDGp9NnqsHhQPK9EXJM8vTsHDC9'
$header = @{"X-Jfrog-Art-Api" = $apiKey}

$registry		= 'https://docker.wdf.sap.corp'
$virtualdocker	= "$registry/artifactory/virtual_docker/$suite"
$reposURL		= '51003/artifactory/cidemo', '51020/artifactory/xmake_snapshot'

$html = Invoke-WebRequest -Uri $virtualdocker

if (-not $html.AllElements.Count) {
  Write-Host 'Failed to retrieve Aurora images list from Artifactory server'
  return 1 }

$href = $html.AllElements | select href | where { $_ -match $suite } | sort -Property href

foreach ($build in $AllBuild) {
  
  [System.Collections.ArrayList]$versions = $href | where { $_.href -match "$($build)_([0-9])"  }
  $NbDelete = $versions.Count - $max
  
  for ($i = 0; $i -lt $NbDelete; $i++) {
	$result = Invoke-RestMethod -ErrorVariable Err -ErrorAction SilentlyContinue -Method Delete -Header $header -Uri "$($registry):$($reposURL[0])/$suite/$($versions[0].href)"
	$result = Invoke-RestMethod -ErrorVariable Err -ErrorAction SilentlyContinue -Method Delete -Header $header -Uri "$($registry):$($reposURL[1])/$suite/$($versions[0].href)"
    $versions.RemoveAt(0) }}

# Empty Recycle Bin
$result = Invoke-RestMethod -ErrorVariable Err -ErrorAction SilentlyContinue -Method Delete -Header $header -Uri "$($registry)/api/trash/cidemo/$suite"
$result = Invoke-RestMethod -ErrorVariable Err -ErrorAction SilentlyContinue -Method Delete -Header $header -Uri "$($registry)/api/trash/xmake_snapshot/$suite"
