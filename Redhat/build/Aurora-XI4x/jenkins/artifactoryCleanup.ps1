#*************************************************************************
# Author: gerald.braunwarth@sap.com			- April 2016 -
# Purpose : Cleanup Artifactory keeping 3 last versions of each build type
#*************************************************************************

# WORKAROUND : http://social.technet.microsoft.com/wiki/contents/articles/29863.powershell-rest-api-invoke-restmethod-gotcha.aspx

# parameters: aurora  3

if ($args.Count -ne 2) {
  Write-Host "Expected argument: <SuiteName> <NbVersionsToKeep>"
  Write-host "Example: artifactoryCleanup.ps1  aurora  3"
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

Write-Host "Retrieving images list from Artifactory folder 'virtual_docker'"
$html = Invoke-RestMethod -Method Get -Header $header -Uri "$($registry):50002/artifactory/api/storage/xmake_allrepos/$suite"

if (-not $html.children.Count) {
  Write-Host 'Failed to retrieve Aurora images list from Artifactory server'
  exit 1 }

$href = $html.children | select uri | where { $_ -match $suite } | sort -Property uri

foreach ($build in $AllBuild) {
  
  Write-Host
  Write-Host "Build '$build'"
  
  [System.Collections.ArrayList]$versions = $href | where { $_.uri -match "$($build)_([0-9])"  }
  $NbDelete = $versions.Count - $max
  
  for ($i = 0; $i -lt $NbDelete; $i++) {

	$version = $versions[0].uri
	$version = $version.Substring(1, $version.Length - 1)

	Write-Host "    Version '$version'"

	for ($j = 0; $j -lt 2; $j++) {

	  Write-Host "      Delete from folder '$($repos[$j])'"

	  $uri = "$($registry):$($ports[$j])/artifactory/$($repos[$j])/$suite/$version"
	  $ServicePoint = [System.Net.ServicePointManager]::FindServicePoint($uri)
	  
	  try {
		Invoke-RestMethod -Method Delete -Header $header -Uri $uri }
	  catch {
	    if ($_.Exception.Response.StatusCode.value__ -ne 404) {
		  Write-Host "          $_.Exception.Response.StatusDescription" }}

	  $dummy = $ServicePoint.CloseConnectionGroup("") }

    $versions.RemoveAt(0) }}

## Cannot empty TrashCan, NO NGINX PORT
# Empty Recycle Bin
#Write-Host
#Write-Host "Empty Trash Can"
#foreach ($repo in $repos) {
#  $result = Invoke-RestMethod -Method Delete -Header $header -Uri "$($registry)/artifactory/api/trash/clean/$repo/$suite" }

# JFROG
#$result = Invoke-RestMethod -Method Delete -Header $header -Uri "$($registry):$($ports[$j])/artifactory/api/docker/$($repos[$j])/v2/$suite/$version/manifests/latest"  }

