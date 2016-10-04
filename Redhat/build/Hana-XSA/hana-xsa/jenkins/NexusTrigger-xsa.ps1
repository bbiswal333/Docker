#*************************************************************************
# Author: gerald.braunwarth@sap.com			- August 2016 -
# Purpose : check drops arrivals in dropZones : xsrt / hrtt / di / webide
#*************************************************************************

#$Hdbclm =         \\production.wdf.sap.corp\makeresults\newdb\POOL\HANA_WS_COR\released_weekstones\LastWS\lcm\linuxx86_64"
#$HanaDb =         \\production.wdf.sap.corp\makeresults\newdb\POOL\HANA_WS_COR\released_weekstones\LastWS\server\linuxx86_64"
#XSRunTimeUrl =    http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.releases.xmake/com/sap/xs/onpremise/runtime/xs.onpremise.runtime.hanainstallation_linuxx86_64/
#AdminToolUrl =    http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.milestones.xmake/com/sap/xsa/admin/sap-xsac-admin/
#JobSchedulerUrl = http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.milestones.xmake/com/sap/xs/jobscheduler/jobscheduler-assembly/
#ShineUrl=         http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.milestones.xmake/com/sap/refapps/sap-xsac-shine/
#HRTTUrl=          http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.milestones/com/sap/xsa/hrtt/sap-xsac-hrtt/
#DIUrl=            http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.milestones/com/sap/di/sap-xsac-di/
#WebIDEUrl=        http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.milestones/com/sap/devx/sap-xsac-webide/

# Get-EventLog Security | ?{$_.Username -notmatch '^user1$|^.*user$'}


# --------------------------------
#FUNCTION BuildMask ($masks) {
#  $mask = ""
#  foreach ($item in $masks) {
#    $mask += "|$item" }
#  $mask = $mask.Remove(0,1)
#  return $mask }

#  $mask = BuildMask $zone.mask


# --------------------------------
FUNCTION OnBadParameter() {
  Write-Host "Expected argument: <zone> with values = xsa or shine"
  Write-host "Example: ./NexusDropsTrigger xsa"
  exit 1 }


FUNCTION AddUploadLine($zone, $url, $file) {
  $line = "$($zone.name);$($zone.upload);$url;$file"
  $line | Out-File "upload-$($zone.upload).txt" -Append }


# --------------------------------
FUNCTION historize($release, $releaseTxt) {
  $release | Out-File diff\$releaseTxt }


#********************************************************************************************
#      MAIN
#********************************************************************************************
cls

# DEBUG
#if ($args.Count -ne 1) {
#  OnBadParameter }
#ENDDEBUG

$type = $args[0]
$type = 'shine'
$index = [Array]::IndexOf(('xsa','shine'), $type)

if ( $index -lt 0) {
  OnBadParameter }

$dropzones = @(
  @([pscustomobject] @{name = "lcm";      upload="root"; mask = @("SAP_HANA_LCM*");                              url = "\\production.wdf.sap.corp\makeresults\newdb\POOL\HANA_WS_COR\released_weekstones\LastWS\lcm\linuxx86_64"},
    [pscustomobject] @{name = "hanaDb";   upload="root"; mask = @("SAP_HANA_DATABASE*.SAR");                     url = "\\production.wdf.sap.corp\makeresults\newdb\POOL\HANA_WS_COR\released_weekstones\LastWS\server\linuxx86_64"},
    [pscustomobject] @{name = "xsrt";     upload="RT";   mask = @("*.runtime.hanainstallation*[0-9].SAR");       url = "http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.releases.xmake/com/sap/xs/onpremise/runtime/xs.onpremise.runtime.hanainstallation_linuxx86_64"},
    [pscustomobject] @{name = "schedule"; upload="root"; mask = @("jobscheduler-assembly*[0-9].zip");            url = "http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.milestones.xmake/com/sap/xs/jobscheduler/jobscheduler-assembly"},
    [pscustomobject] @{name = "admin";    upload="XSA";  mask = @("*MONITORING*[0-9].zip");                      url = "http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.milestones.xmake/com/sap/xsa/admin/sap-xsac-admin"},
    [pscustomobject] @{name = "hrtt";     upload="XSA";  mask = @("sap-xsac-hrtt*[0-9].zip");                    url = "http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.milestones/com/sap/xsa/hrtt/sap-xsac-hrtt"},
    [pscustomobject] @{name = "di";       upload="XSA";  mask = @("*XSACDICORE*[0-9].zip","*[0-9].mtaext");      url = "http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.milestones/com/sap/di/sap-xsac-di"},
    [pscustomobject] @{name = "webide";   upload="XSA";  mask = @("*XSACSAPWEBIDE[0-9]*.zip","*[0-9].mtaext");   url = "http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.milestones/com/sap/devx/sap-xsac-webide"}),

  @([pscustomobject] @{name = "shine";    upload="root"; mask = @("*XSACSHINE[0-9]*.zip",,"*[0-9].mtaext");      url = "http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.milestones.xmake/com/sap/refapps/sap-xsac-shine"}))

$metadataXml = "maven-metadata.xml"
$status = 1,0
$bChange = $false

Set-Location (Split-Path $MyInvocation.MyCommand.Path)

Remove-Item "$metadataXml", "upload-*.txt" -ErrorAction SilentlyContinue
if (-not (Test-Path diff)) {
  mkdir diff }

foreach ($zone in $dropzones[$index]) {

  # '=lcm' or '=hanaDb'
  if (($dropzones[0][0].name,$dropzones[0][1].name) -contains $zone.name) {
    $release = Get-ChildItem -filter $($zone.mask) -Path $($zone.url) | foreach { $_.name} }

  # '=lcm'
  if ($zone.name -eq $dropzones[0][0].name) {
    AddUploadLine $zone $zone.url $release
    continue }
  
  #  '<>hanaDb'
  if ($zone.name -ne $dropzones[0][1].name) {
    $remoteFile = "$($zone.url)/$metadataXml"
  	Invoke-WebRequest $remoteFile -OutFile $metadataXml
  	
  	if (-not (Test-Path $metadataXml)) {
  	  Write-Host "Failed to download '$remoteFile'"
  	  exit 1 }

  	$metadata = Get-Content $metadataXml
  	$release = ($metadata | where { $_ -match 'release' }) -replace '</release>','' -replace '<release>','' -replace ' ','' }

  $releaseTxt = "release-$($zone.name).txt"

	if ((Test-Path diff\$releaseTxt)) {		# First exec : consider last drop as a new drop
      if ($release -ne (Get-Content diff\$releaseTxt)) {
        $bChange = $true }}
  
  # '=hanaDb'
  if ($zone.name -eq $dropzones[0][1].name) {
    AddUploadLine $zone $zone.url $release }
  else {
    $list = Invoke-WebRequest "$($zone.url)/$release"
    $files = $list.Links | foreach { $_.outerText } | where { $_ -notmatch 'parent' }
    $limit = if ($zone.mask.Count -gt 1) {$zone.mask.Count-1} else {0}
    $installers = $files | where { $_ -like "$($zone.mask[0])" -or $_ -like "$($zone.mask[$limit])" }

    foreach ($file in $installers) {
      AddUploadLine $zone "$($zone.url)/$release" $file }}

    historize $release $releaseTxt }

return $status[$bChange]


# --------------------------------
#FUNCTION OnNewVersion($url, $folders) {
#
#  $version = $folders[$folders.Count-1]
#  $FullUrl = "$rootUrl/$url/$version"
#
#  $html = Invoke-WebRequest "$FullUrl"
#  $files = $html | foreach { $_.Links.OuterText } | where {$_ -ne 'Parent Directory'} }


#foreach ($zone in $dropzones) {
#
#	$name = "$prefix-$($zone.name)"
#	$OLD = "$name-OLD.txt"
#	$NEW = "$name-NEW.txt"
#	$newVersion = "newVersion-$($zone.name).txt"
#
#	$html = Invoke-WebRequest "$rootUrl/$($zone.url)/
#	$folders = $html.AllElements | where { $_.tagName -EQ "A" -and $_.outerText -match "/" } | select outerText | foreach { $_.outerText } | sort
#	
#	$folders | Out-File $NEW
#
#    # First exec : consider last drop as a new drop
#	if (-not (Test-Path diff\$OLD)) {
#	  OnNewVersion $folders $newVersion
#	  historize $NEW $OLD
#	  continue }
#
#	$diff = @(Compare-Object (get-Content diff\$OLD) (get-Content $NEW))
#	$diff = @($diff | where { $_.SideIndicator -eq '=>' })
#
#	if ($diff.Count) {
#	  if ($diff.Count -gt 1) {
#	    $diff = $diff | sort -Property InputObject }
#	  OnNewVersion $zone.url $folders }
#	
#    historize $NEW $OLD }


#	$folders = $html.ParsedHtml.body.getElementsByTagName("TR") | select outerText | where {$_.outerText -match "/" } | foreach { $_.outerText }
