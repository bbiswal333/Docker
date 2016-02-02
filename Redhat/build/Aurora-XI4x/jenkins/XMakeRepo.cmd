::****************************************************************
:: Project: Jenkins integration
:: Author: gerald.braunwarth@sap.com
::****************************************************************

:: %1 = aurora
:: %2 = aurora42
:: %3 = aurora42_cons

cls

if "%3" equ "" (
  echo Expected parameters: ^<MajorName^> ^<ImageName^> ^<BuildFolder^>
  echo Example: PrepAuroraRepo.cmd  aurora  aurora42  aurora42_cons
  echo.
  exit 1 )

set drop=\\10.17.136.53\dropzone\aurora_dev\%3\version.txt
set xmakeProj=aurora4xInstall
set cfgOLD=cfg\xmake-OLD.cfg
set cfg=cfg\xmake.cfg

git config --global http.sslVerify false
git clone https://%token%@github.wdf.sap.corp/AuroraXmake/aurora4xInstall.git

cd %xmakeProj%

call :AccessFile %drop%
call :AccessFile DockerCommands
call :AccessFile %cfg%

for /f "tokens=1"   %%i in (%drop%)         do set version=%%i
for /f "tokens=1-2" %%i in (DockerCommands) do set runprivileged=%%i && set script=%%j

set version=%version: =%
set runprivileged=%runprivileged: =%

echo %runprivileged% %script% %3/%version%> DockerCommands
echo %version%> version.txt


if exist %cfgOLD% del /q %cfgOLD%
ren %cfg% xmake-OLD.cfg

for /f %%i in (%cfgOLD%) do call :replaceAidGid %1 %2 %version% "%%i"
del /q %cfgOLD%


if exist Dockerfile del /q Dockerfile
..\wget --no-check-certificate https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Aurora-XI4x/Dockerfile

if %errorlevel% neq 0 (
  echo Failed to download reference Dockerfile
  exit 1 )

call :GetFullName

git add --all
git config --global user.name "%username%@%FullName%"
git config --global push.default matching
git commit -m "Drop version %version%"
git push -q

cd ..\
rmdir /s/q %xmakeProj%

goto :eof


::--------------------------------------
:AccessFile
if not exist %1 (
  echo Cannot access %1
  exit 1 )
goto :eof


::--------------------------------------
:replaceAidGid

::%1 = aurora
::%2 = aurora42
::%3 = version
::%4 = line

set var=%4
set aid=%var:aid=%
set gid=%var:gid=%
set plugin=%var:buildplugin=%

:: aid=aurora42_1930
if %var% neq %aid% (
  echo aid=%2_%3>>%cfg%
  goto :eof )

:: gid=aurora
if %var% neq %gid% (
  echo gid=%1>>%cfg%
  goto :eof )

:: NL before [buildplugin] 
if %var% neq %plugin% (
  echo.>>%cfg% )

:: Unchanged line
echo %~4>>%cfg%

goto :eof


::--------------------------------------
:GetFullName
for /F "tokens=2" %%i in ('ping localhost') do set FullName=%%i&& goto :endLoop
:endLoop

if not defined FullName (
  echo "Failed to retrieve %computername% Full Name"
  exit 1 )

goto :eof
