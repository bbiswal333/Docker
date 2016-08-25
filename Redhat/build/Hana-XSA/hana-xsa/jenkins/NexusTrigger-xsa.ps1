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

foreach ($zone in $dropzones) {

	$html = Invoke-WebRequest "$rootUrl/$($zone.url)"
#	$folders = $html.ParsedHtml.body.getElementsByTagName("TR") | select outerText | where {$_.outerText -match "/" } | foreach { $_.outerText }
	$folders = $html.AllElements | where { $_.tagName -EQ "A" -and $_.outerText -match "/" } | select outerText | foreach { $_.outerText } | sort

	$name = "$prefix-$($zone.name)"
	$OLD = "$name-OLD.txt"
	$NEW = "$name-NEW.txt"
	
	$folders | Out-File $NEW
#	$diff = @(Compare-Object (get-Content $OLD) (get-Content $NEW))
#	
	if ($diff.Count -and $diff.Count -gt 1) {
	  $diff = $diff | sort -Property InputObject
	  $diff.RemoveAt(0)
	}
}
