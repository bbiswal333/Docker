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
FUNCTION historize($new, $old) {
  Move-Item -Force $new diff\$old }


# --------------------------------
FUNCTION OnNewVersion($folder, $fileName) {
  $folders[$folders.Count-1] -replace '/','' | Out-File $fileName }


#********************************************************************************************
#      MAIN
#********************************************************************************************

$rootUrl = "http://nexus.wdf.sap.corp:8081/nexus/content/repositories"
$prefix  = "dropZone"

$dropzones = [pscustomobject] @{name = "xsrt";     url = "deploy.releases.xmake/com/sap/xs/onpremise/runtime/xs.onpremise.runtime.hanainstallation_linuxx86_64"},
             [pscustomobject] @{name = "admin";    url = "deploy.milestones.xmake/com/sap/xsa/admin/sap-xsac-admin"},
             [pscustomobject] @{name = "schedule"; url = "deploy.milestones.xmake/com/sap/xs/jobscheduler/jobscheduler-assembly"},
             [pscustomobject] @{name = "shine";    url = "deploy.milestones.xmake/com/sap/refapps/sap-xsac-shine"},
             [pscustomobject] @{name = "hrtt";     url = "deploy.milestones/com/sap/xsa/hrtt/sap-xsac-hrtt"},
             [pscustomobject] @{name = "di";       url = "deploy.milestones/com/sap/di/sap-xsac-di"},
             [pscustomobject] @{name = "webide";   url = "deploy.milestones/com/sap/devx/sap-xsac-webide"}
cls
Set-Location (Split-Path $MyInvocation.MyCommand.Path)

Remove-Item "newVersion-*.txt" -ErrorAction SilentlyContinue

if (-not (Test-Path diff)) {
  mkdir diff }

foreach ($zone in $dropzones) {

	$name = "$prefix-$($zone.name)"
	$OLD = "$name-OLD.txt"
	$NEW = "$name-NEW.txt"
	$newVersion = "newVersion-$($zone.name).txt"

	$html = Invoke-WebRequest "$rootUrl/$($zone.url)"
	$folders = $html.AllElements | where { $_.tagName -EQ "A" -and $_.outerText -match "/" } | select outerText | foreach { $_.outerText } | sort
	
	$folders | Out-File $NEW

    # First exec : consider last drop as a new drop
	if (-not (Test-Path diff\$OLD)) {
	  OnNewVersion $folders $newVersion
	  historize $NEW $OLD
	  continue }

	$diff = @(Compare-Object (get-Content diff\$OLD) (get-Content $NEW))
	$diff = $diff | where { $_.SideIndicator -eq '=>' }

	if ($diff.Count) {
	  if ($diff.Count -gt 1) {
	    $diff = $diff | sort -Property InputObject }
	  OnNewVersion $folders $newVersion }
	
    historize $NEW $OLD }


#	$folders = $html.ParsedHtml.body.getElementsByTagName("TR") | select outerText | where {$_.outerText -match "/" } | foreach { $_.outerText }

    # Component dropZone is empty !
#	if (-not $folders.Count) {
#	  historize $NEW $OLD
#	  continue 	}
