#*************************************************************************
# Author: gerald.braunwarth@sap.com			- August 2016 -
# Purpose : check drops arrivals in dropZones : xsrt / hrtt / di / webide
#*************************************************************************

#XSRunTimeUrl =    http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.releases.xmake/com/sap/xs/onpremise/runtime/xs.onpremise.runtime.hanainstallation_linuxx86_64/
#AdminToolUrl =    http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.milestones.xmake/com/sap/xsa/admin/sap-xsac-admin/
#JobSchedulerUrl = http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.milestones.xmake/com/sap/xs/jobscheduler/jobscheduler-assembly/
#ShineUrl=         http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.milestones.xmake/com/sap/refapps/sap-xsac-shine/
#HRTTUrl=          http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.milestones/com/sap/xsa/hrtt/sap-xsac-hrtt/
#DIUrl=            http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.milestones/com/sap/di/sap-xsac-di/
#WebIDEUrl=        http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.milestones/com/sap/devx/sap-xsac-webide/


# --------------------------------
FUNCTION historize($name) {
  Move-Item -Force $name diff\$name }


# --------------------------------
#FUNCTION BuildMask ($masks) {
#  $mask = ""
#  foreach ($item in $masks) {
#    $mask += "|$item" }
#  $mask = $mask.Remove(0,1)
#  return $mask }

FUNCTION CreateUploadList($zone, $release) {
  $list = Invoke-WebRequest "$rootUrl/$($zone.url)/$release"
  $files = $list.Links | foreach { $_.outerText } | where { $_ -notmatch 'parent' }
#  $mask = BuildMask $zone.mask
  $limit = if ($zone.mask.Count -gt 1) {$zone.mask.Count-1} else {0}
  $installers = $files | where { $_ -like "$($zone.mask[0])" -or $_ -like "$($zone.mask[$limit])" }
  
  foreach ($file in $installers) {
    "$rootUrl/$($zone.url)/$file" | Out-File "upload-$($zone.name).txt" -Append }}

# Get-EventLog Security | ?{$_.Username -notmatch '^user1$|^.*user$'}

#********************************************************************************************
#      MAIN
#********************************************************************************************

$rootUrl = "http://nexus.wdf.sap.corp:8081/nexus/content/repositories"

$dropzones = [pscustomobject] @{name = "xsrt";     upload="RT";   mask = @("xs.onpremise.runtime.hanainstallation*[0-9].SAR"); url = "deploy.releases.xmake/com/sap/xs/onpremise/runtime/xs.onpremise.runtime.hanainstallation_linuxx86_64"},
             [pscustomobject] @{name = "admin";    upload="XSA";  mask = @("*MONITORING*[0-9].zip");                           url = "deploy.milestones.xmake/com/sap/xsa/admin/sap-xsac-admin"},
             [pscustomobject] @{name = "schedule"; upload="root"; mask = @("jobscheduler-assembly*[0-9].zip");                 url = "deploy.milestones.xmake/com/sap/xs/jobscheduler/jobscheduler-assembly"},
#            [pscustomobject] @{name = "shine";    upload="XSA";  mask = @("XSACSHINE*[0-9].zip");                             url = "deploy.milestones.xmake/com/sap/refapps/sap-xsac-shine"},
             [pscustomobject] @{name = "hrtt";     upload="XSA";  mask = @("sap-xsac-hrtt*[0-9].zip");                         url = "deploy.milestones/com/sap/xsa/hrtt/sap-xsac-hrtt"},
             [pscustomobject] @{name = "di";       upload="XSA";  mask = @("*XSACDICORE*[0-9].zip","*[0-9].mtaext");           url = "deploy.milestones/com/sap/di/sap-xsac-di"},
             [pscustomobject] @{name = "webide";   upload="XSA";  mask = @("*XSACSAPWEBIDE[0-9]*.zip","*[0-9].mtaext");        url = "deploy.milestones/com/sap/devx/sap-xsac-webide"}
cls
Set-Location (Split-Path $MyInvocation.MyCommand.Path)

if (-not (Test-Path diff)) {
  mkdir diff }
 
foreach ($zone in $dropzones) {

	$releaseTxt = "release-$($zone.name).txt"

	Invoke-WebRequest "$rootUrl/$($zone.url)/maven-metadata.xml" -OutFile $releaseTxt
	
	if (-not (Test-Path $releaseTxt)) {
	  Write-Host "Failed to download '$rootUrl/$($zone.url)/maven-metadata.xml'"
	  exit 1 }

	$content = Get-Content $releaseTxt
	$release = ($content | where { $_ -match 'release' }) -replace '</release>','' -replace '<release>','' -replace ' ',''
	
	$release | Out-File $releaseTxt

	if ((Test-Path diff\$releaseTxt)) {		# First exec : consider last drop as a new drop
      if ((Get-Content $releaseTxt) -eq (Get-Content diff\$releaseTxt)) {
        continue }}

    CreateUploadList $zone $release
    historize $releaseTxt }


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
