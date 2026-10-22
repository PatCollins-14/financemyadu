@echo off
REM Wrapper for the PowerShell build scripts. Usage: run.cmd build | preflight | preflight-dev | production | snapshot | adcheck | identity | preview
setlocal
set "PS=powershell -NoProfile -ExecutionPolicy Bypass -File"
set "S=%~dp0scripts"
if /I "%1"=="build" %PS% "%S%\build.ps1" & goto :eof
if /I "%1"=="preview" %PS% "%S%\preview.ps1" & goto :eof
if /I "%1"=="preflight" %PS% "%S%\preflight.ps1" & goto :eof
if /I "%1"=="preflight-dev" %PS% "%S%\preflight.ps1" -Dev & goto :eof
if /I "%1"=="production" (%PS% "%S%\build.ps1" -Production && %PS% "%S%\preflight.ps1") & goto :eof
if /I "%1"=="snapshot" %PS% "%S%\snapshot.ps1" & goto :eof
if /I "%1"=="adcheck" %PS% "%S%\ad-check.ps1" & goto :eof
if /I "%1"=="identity" %PS% "%S%\make-identity.ps1" & goto :eof
echo Usage: run.cmd build ^| preview ^| preflight ^| preflight-dev ^| production ^| snapshot ^| adcheck ^| identity
