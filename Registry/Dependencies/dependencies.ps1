
# --------------------------------
FUNCTION logHeader($header) {
  log '--------------------------------'
  log $header
  log '' }


# --------------------------------
FUNCTION log($message) {
  Add-Content $log $message }


# --------------------------------
FUNCTION Repositories([ref]$inventory) {

	logHeader 'REPOSITORIES'

	$FldRepos = Get-ChildItem $PathRepositories | Where { $_.PSIsContainer }
	foreach ($rep in $FldRepos) {
    
		$FldImages = Get-ChildItem $PathRepositories\$rep | Where { $_.PSIsContainer }
		foreach ($img in $FldImages) {

			$IdFile = @(Get-ChildItem "$PathRepositories\$rep\$img\tag_*")

			if (-not $IdFile.Count) {
				log "Missing file '$PathRepositories\$rep\$img\tag_???'"
				continue }

			foreach ($f in $IdFile) {
				$tag = $f.Name -replace 'tag_'
				$id = Get-Content $f

				$image = [pscustomobject] @{
				  name = "$rep/$img`:$tag"
				  id   = $id }

				$inventory.Value += $image }}}}


# --------------------------------
FUNCTION Images([ref]$nodes) {

  $folders = Get-ChildItem $PathImages | Where { $_.PSIsContainer }

  logHeader 'IMAGES\json'

  foreach ($f in $folders) {
    json      $f $nodes }

## VERIFIED WITH ONE EXECUTION: REDUNDANT WITH json
#  logHeader 'IMAGES\ancestry'
#
#  foreach ($f in $folders) {
#    ancestry  $f $nodes }}

}


# --------------------------------
FUNCTION json($folder, $nodes) {

  $lines = Get-Content -Raw "$($folder.PSPath)\json"
  $json = ConvertFrom-Json $lines -ErrorVariable error -ErrorAction SilentlyContinue
  
  if ($json) {
    $key = ImageName $json.id
	if ($json.parent) {
      $name = ImageName $json.parent
	  $key += " -> $name" }
#	$key += ';'
    if ($nodes.Value -contains $key) {
      return }
    $nodes.Value += $key
    return }

  log "'$($folder.name)' skipped: json-convert failed "
  return

#  $json = ConvertFrom-Csv $lines -ErrorAction SilentlyContinue
#  if ($json) {
#    return }
#
#  $parent = $json -match 'parent'
#  if (-not $parent.Count) {
#      return }
  
}


FUNCTION ImageName($id) {
  
  $match = @($inventory | where { $_.id -eq $id} | select name)

  if ($match.Count) {
    foreach ($n in $match) {
      $names += "$($n.name)\n" }}

  $names = '"' + $names + (TruncateID $id) + '"'

  return $names }


FUNCTION TruncateID($id) {
  return $id.Substring(0,12) }


# --------------------------------
#FUNCTION ancestry($folder, $nodes) {
#
#  $remove = '\[','\]',' "','"'
#
#  $lines = Get-Content -Raw "$($folder.PSPath)\ancestry"
#  
#  foreach ($char in $remove) {
#    $lines = $lines -replace $char,'' }
#
#  $array = $lines.Split(',')
#  for ($i = 0; $i -lt $array.Count; $i++) {
#
#	$key = ImageName $array[$i]
#
#	if ($i -lt $array.Count - 1) {
#	  $name = ImageName $array[$i + 1]
#	  $key += " -> $name" }
#
#	if ($nodes.Value -contains $key) {
#	  continue }
#
#    log "$key added by ancestry"
#	$nodes.Value += $key }}


# --------------------------------
FUNCTION InitLog() {
  if (Test-Path $log) {
    Remove-Item $log }}


# --------------------------------
FUNCTION Output($nodes) {
  Set-Content $output 'digraph {'
  Add-Content $output $nodes
  Add-Content $output '}' }


#********************************************************************************************
#      MAIN
#********************************************************************************************

cls

$PathSource       = '\\derotvi0127.pgdev.sap.corp\unix\Imagesdck'
$PathRepositories = "$PathSource\repositories"
$PathImages       = "$PathSource\images"

$log    = 'dependencies.log'
$output = 'dependencies.txt'

$inventory = @()
$nodes     = @()

set-location (split-path $MyInvocation.MyCommand.Path)

InitLog

Repositories ([ref]$inventory)
Images       ([ref]$nodes)

Output       $nodes
