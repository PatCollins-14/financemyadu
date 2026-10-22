# Builds the dev site and serves it on http://localhost:8771/ (opens your default browser). Close the window or press Ctrl+C to stop.
param([int]$Port = 8771, [switch]$NoOpen)
$root = Split-Path -Parent $PSScriptRoot
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'build.ps1')
if ($LASTEXITCODE -ne 0) { Write-Host 'Build failed.'; exit 1 }
if (-not $NoOpen) { Start-Process "http://localhost:$Port/" }
Write-Host "Preview running at http://localhost:$Port/  (Ctrl+C to stop)"
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'serve.ps1') -Dir (Join-Path $root 'dist') -Port $Port
