# Builds a copy of the dev preview that can be published as a shareable link (dist-share/).
# Differences from dist/: analytics off (ANALYTICS_ID=NONE), every directory link ends in index.html
# (hosts that publish plain files do not serve folder indexes), and index.html has no <html>/<head>/<body> wrapper
# (the publishing tool adds its own). Prints the file map for the publish call.
. "$PSScriptRoot\lib.ps1"
$root = Get-Root
$env:ANALYTICS_ID = 'NONE'
try { & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'build.ps1') | Out-Null }
finally { Remove-Item Env:ANALYTICS_ID -ErrorAction SilentlyContinue }
$src = Join-Path $root 'dist'; $dst = Join-Path $root 'dist-share'
if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
Copy-Item $src $dst -Recurse
foreach ($f in (Get-ChildItem $dst -Recurse -Filter '*.html')) {
  $h = Read-Text $f.FullName
  $h = [regex]::Replace($h, '(?i)(\bhref=")((?!https?:|mailto:|tel:|#|data:|javascript:)[^"#]*/)(")', '${1}${2}index.html${3}')
  $h = [regex]::Replace($h, '(?i)(\bhref=")((?!https?:|mailto:|tel:|#|data:|javascript:)[^"#]*/)(#[^"]*")', '${1}${2}index.html${3}')
  if ($f.FullName -eq (Join-Path $dst 'index.html')) {
    $h = [regex]::Replace($h, '(?is)^\s*<!doctype html>\s*<html[^>]*>\s*<head>', '')
    $h = [regex]::Replace($h, '(?is)</head>\s*<body>', '')
    $h = [regex]::Replace($h, '(?is)</body>\s*</html>\s*$', '')
    $h = $h.Replace('<title>Preview: ADU funnel and hub (not live)</title>', '<title>ADU Funnel Preview</title>')
  }
  Write-Text $f.FullName $h
}
$files = Get-ChildItem $dst -Recurse -File | Where-Object { $_.FullName -ne (Join-Path $dst 'index.html') -and $_.Extension -ne '.txt' -and $_.Name -ne 'sitemap.xml' }
$map = [ordered]@{}
foreach ($f in $files) { $map[$f.FullName.Substring($dst.Length + 1).Replace('\', '/')] = $f.FullName }
Write-Text (Join-Path $root 'dist-share\_files.json') (($map | ConvertTo-Json))
Write-Host "dist-share ready: $($map.Count) supporting files plus index.html"
# restore the normal local preview build (analytics bar on)
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'build.ps1') | Out-Null
