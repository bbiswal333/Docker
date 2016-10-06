#*************************************************************************
# Author: gerald.braunwarth@sap.com			- August 2016 -
# Purpose : check drops arrivals in dropZones : xsrt / hrtt / di / webide
#*************************************************************************

#sapcar =          http://nexus.wdf.sap.corp:8081/nexus/content/groups/build.milestones/com/sap/tools/sapcar/linuxx86_64/opt/sapcar/
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
  Write-Host "Expected arguments: <GitHubtoken>  <trigger> with values = xsa or shine"
  Write-host "Example: ./NexusShineTrigger.ps1  <MyIUserGithubToken> xsa"
  exit 1 }


FUNCTION AddUploadLine($trigger, $zone, $url, $file) {
  $line = "$($zone.name);$($zone.upload);$url;$file"
  $line | Out-File -Encoding ASCII "trigger-$trigger.txt" -Append }


# --------------------------------
FUNCTION historize($release, $releaseTxt) {
  $release | Out-File diff\$releaseTxt }


#********************************************************************************************
#      MAIN
#********************************************************************************************
cls

if ($args.Count -ne 2) {
  OnBadParameter }

$token   = $args[0]
$trigger = $args[1]

$index = [Array]::IndexOf(('xsa','shine'), $trigger)
if ((0,1) -notcontains $index) {
  OnBadParameter }

$metadataXml = "maven-metadata.xml"
$sapcar = 'sapcar'
$lcm = 'lcm'
$hanadb = 'hanadb'
$dropzones = @(
  @([pscustomobject] @{name = $sapcar;    upload="installer";     mask = @("sapcar*.bin");                              url = "http://nexus.wdf.sap.corp:8081/nexus/content/groups/build.milestones/com/sap/tools/sapcar/linuxx86_64/opt/sapcar"},
    [pscustomobject] @{name = $lcm;       upload="installer";     mask = @("SAP_HANA_LCM*");                            url = "\\production.wdf.sap.corp\makeresults\newdb\POOL\HANA_WS_COR\released_weekstones\LastWS\lcm\linuxx86_64"},
    [pscustomobject] @{name = $hanadb;    upload="installer";     mask = @("SAP_HANA_DATABASE*.SAR");                   url = "\\production.wdf.sap.corp\makeresults\newdb\POOL\HANA_WS_COR\released_weekstones\LastWS\server\linuxx86_64"},
    [pscustomobject] @{name = "xsrt";     upload="installer/RT";  mask = @("*.runtime.hanainstallation*[0-9].SAR");     url = "http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.releases.xmake/com/sap/xs/onpremise/runtime/xs.onpremise.runtime.hanainstallation_linuxx86_64"},
    [pscustomobject] @{name = "jobsched"; upload="installer";     mask = @("jobscheduler-assembly*[0-9].zip");          url = "http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.milestones.xmake/com/sap/xs/jobscheduler/jobscheduler-assembly"},
    [pscustomobject] @{name = "admin";    upload="installer/XSA"; mask = @("*MONITORING*[0-9].zip");                    url = "http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.milestones.xmake/com/sap/xsa/admin/sap-xsac-admin"},
    [pscustomobject] @{name = "hrtt";     upload="installer/XSA"; mask = @("*XSACHRTT*[0-9].zip");                      url = "http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.milestones/com/sap/xsa/hrtt/sap-xsac-hrtt"},
    [pscustomobject] @{name = "di";       upload="installer/XSA"; mask = @("*XSACDICORE*[0-9].zip","*[0-9].mtaext");    url = "http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.milestones/com/sap/di/sap-xsac-di"},
    [pscustomobject] @{name = "webide";   upload="installer/XSA"; mask = @("*XSACSAPWEBIDE[0-9]*.zip","*[0-9].mtaext"); url = "http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.milestones/com/sap/devx/sap-xsac-webide"}),
  @([pscustomobject] @{name = "shine";    upload="installer";     mask = @("*XSACSHINE[0-9]*.zip",,"*[0-9].mtaext");    url = "http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.milestones.xmake/com/sap/refapps/sap-xsac-shine"}))

Set-Location (Split-Path $MyInvocation.MyCommand.Path)

Remove-Item "trigger-*", "$metadataXml" -ErrorAction SilentlyContinue
if (-not (Test-Path diff)) {
  mkdir diff }

foreach ($zone in $dropzones[$index]) {

  # 'lcm' or 'hanaDb'
  if (($lcm,$hanadb) -contains $zone.name) {
    $release = Get-ChildItem -filter $($zone.mask) -Path $($zone.url) | foreach { $_.name} }

  # 'lcm'
  if ($zone.name -eq $lcm) {
    AddUploadLine $trigger $zone $zone.url $release
    continue }
  
  #  '<>hanaDb'
  if ($zone.name -ne $hanadb) {
    $remoteFile = "$($zone.url)/$metadataXml"
  	Invoke-WebRequest $remoteFile -OutFile $metadataXml
  	
  	if (-not (Test-Path $metadataXml)) {
  	  Write-Host "Failed to download '$remoteFile'"
  	  exit 1 }

  	$metadata = Get-Content $metadataXml
  	$release = ($metadata | where { $_ -match 'release' }) -replace '</release>','' -replace '<release>','' -replace ' ',''
    Remove-Item $metadataXml }

  #'<>sapcar'
  if ($zone.name -ne $sapcar) {

    $releaseTxt = "release-$($zone.name).txt"
    $bChange = -not (Test-Path diff\$releaseTxt)

    if (-not $bChange) {		# First exec : consider last drop as a new drop
        if ($release -ne (Get-Content diff\$releaseTxt)) {
          $bChange = $true }}}
  
  # 'hanadb'
  if ($zone.name -eq $hanadb) {
    AddUploadLine $trigger $zone $zone.url $release }
  else {
    $list = Invoke-WebRequest "$($zone.url)/$release"
    $files = $list.Links | foreach { $_.outerText } | where { $_ -notmatch 'parent' }
    $limit = if ($zone.mask.Count -gt 1) {$zone.mask.Count-1} else {0}
    $installers = $files | where { $_ -like "$($zone.mask[0])" -or $_ -like "$($zone.mask[$limit])" }

    foreach ($file in $installers) {
      AddUploadLine $trigger $zone "$($zone.url)/$release" $file }}

  #'<>sapcar'
  if ($zone.name -ne $sapcar) {
    historize $release $releaseTxt }}

# upload Trigger manifest in Github
$StartFrom = "$($Env:USERPROFILE)\AppData\Local\GitHub"
$EndPoint = Get-ChildItem -Name git.exe -Path "$StartFrom" -Recurse | Where-Object { $_.Contains("cmd") } 
$git = "$StartFrom\$EndPoint"

$upper = $trigger.ToUpper()

invoke-expression "$git config --global http.sslVerify false"
invoke-expression "$git remote set-url origin https://$token@github.wdf.sap.corp/Dev-Infra-Levallois/Docker.git"
invoke-expression "$git config --global user.name $Env:USERNAME"
Invoke-Expression "$git add trigger-$trigger.txt"
Invoke-Expression "$git commit -m '$upper drops change detected'"
Invoke-Expression "$git push -q"

return (1,0)[$bChange]


# 'sapcar'
#  if ($zone.name -eq $dropzones[0][0].name) {
#    $html = Invoke-WebRequest $zone.url
#    $folders = @($html | foreach { $_.Links.OuterText } | where {$_ -ne 'Parent Directory'})
#    $release = $folders[$folders.Count - 1] -replace '/','' }


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
