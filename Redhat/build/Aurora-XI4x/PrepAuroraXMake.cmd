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
  goto :eof
)

set product=aurora
set folder=%3
set xmakeProj=aurora4xInstall
set dropzone=\\10.17.136.53\dropzone\aurora_dev\%folder%

git config --global http.sslVerify false
git clone https://%Username%:%Password%@github.wdf.sap.corp/AuroraXmake/aurora4xInstall.git

call :AccessFile %dropzone%\version.txt
call :AccessFile %xmakeProj%\DockerCommands

for /f "tokens=1"   %%i in (%dropzone%\version.txt)     do set version=%%i
for /f "tokens=1-2" %%i in (%xmakeProj%\DockerCommands) do set runprivileged=%%i && set script=%%j

set version=%version: =%
set runprivileged=%runprivileged: =%

echo %runprivileged% %script% %3/%version%> %xmakeProj%\DockerCommands
echo %version%> %xmakeProj%\version.txt

if exist %xmakeProj%\cfg\xmake-OLD.cfg del /q %xmakeProj%\cfg\xmake-OLD.cfg
ren %xmakeProj%\cfg\xmake.cfg xmake-OLD.cfg

for /f %%i in (%xmakeProj%\cfg\xmake-OLD.cfg) do call :replaceAidGid %1 %2 %version% "%%i"


cd %xmakeProj%

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


:AccessFile
if not exist %1 (
  echo Cannot access %1
  exit 1 )
goto :eof


:replaceAidGid
::%1 = aurora
::%2 = aurora42
::%3 = version
::%4 = line

set file=%xmakeProj%\cfg\xmake.cfg

set var=%4
set aid=%var:aid=%
set gid=%var:gid=%
set plugin=%var:buildplugin=%

if %var% neq %aid% (
  echo aid=%2_%3>>%file%
  goto :eof )

if %var% neq %gid% (
  echo gid=%1>>%file%
  goto :eof )

if %var% neq %plugin% (
  echo.>>%file% )

echo %~4>>%file%

goto :eof
