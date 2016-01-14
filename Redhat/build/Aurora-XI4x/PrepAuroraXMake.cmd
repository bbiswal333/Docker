::****************************************************************
:: Project: Jenkins integration
:: Author: gerald.braunwarth@sap.com
::****************************************************************

:: %1 = aurora
:: %2 = aurora42
:: %3 = aurora42_cons

cls

if "%3" equ "" (
  echo Expected parameters: ^<MajorName^> ^<ImageName^> ^<BuildFolder^>. Example: PrepAuroraRepo.cmd  aurora aurora42 aurora42_cons
  goto :eof )

set product=aurora
set folder=%3
set xmakeProj=aurora4xInstall
set dropzone=\\10.17.136.53\dropzone\aurora_dev\%folder%

git config --global http.sslVerify false
git clone https://%Username%:%Password%@github.wdf.sap.corp/AuroraXmake/aurora4xInstall.git

cd %xmakeProj%

call :AccessFile %dropzone%\version.txt
call :AccessFile DockerCommands

for /f "tokens=1"   %%i in (%dropzone%\version.txt) do set version=%%i
for /f "tokens=1-2" %%i in (DockerCommands)         do set runprivileged=%%i && set script=%%j

set version=%version: =%
set runprivileged=%runprivileged: =%

echo %runprivileged% %script% %3/%version%> DockerCommands
echo %version%> version.txt

set fileOLD=cfg\xmake-OLD.cfg
set file=cfg\xmake.cfg

if exist %fileOLD% del /q %fileOLD%
ren %file% xmake-OLD.cfg

for /f %%i in (%fileOLD%) do call :replaceAidGid %1 %2 %version% "%%i"
del /q %fileOLD%


if exist Dockerfile del /q Dockerfile
..\wget https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Aurora-XI4x/Dockerfile

if %errorlevel% neq 0 (
  echo Failed to download reference Dockerfile
  exit 1 )

git add --all
git config --global user.name %Username%
git config --global user.email %email%
git config --global push.default matching
git commit -m"New version"
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

rem aid=aurora42_1930
if %var% neq %aid% (
  echo aid=%2_%3>>%file%
  goto :eof )

rem gid=aurora
if %var% neq %gid% (
  echo gid=%1>>%file%
  goto :eof )

rem NL before [buildplugin] 
if %var% neq %plugin% (
  echo.>>%file% )

rem any other unchanged line
echo %~4>>%file%

goto :eof
