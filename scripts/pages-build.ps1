# Builds the draft site for GitHub Pages into dist-pages/ (served at https://financemyadu.io/).
# Draft build: placeholders and DRAFT banners stay visible, analytics is off (no tracking, no consent bar), the form
# is not connected, and every page is hidden from search with a meta noindex tag (never Disallow).
# Layout: /funnel/ is the funnel, /hub/ holds the draft guide pages, and / redirects to /funnel/.
# Replace this with `run.cmd production` once compliance has approved the pages and the form endpoint is set.
. "$PSScriptRoot\lib.ps1"
$root = Get-Root
$env:ANALYTICS_ID = 'NONE'
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'build.ps1') | Out-Null
$src = Join-Path $root 'dist'; $out = Join-Path $root 'dist-pages'
if (Test-Path $out) { Remove-Item $out -Recurse -Force }
New-Item -ItemType Directory -Force -Path $out | Out-Null
Copy-Item (Join-Path $src 'funnel') (Join-Path $out 'funnel') -Recurse
Copy-Item (Join-Path $src 'hub') (Join-Path $out 'hub') -Recurse
foreach ($junk in @('hub\sitemap.xml', 'hub\robots.txt')) { $p = Join-Path $out $junk; if (Test-Path $p) { Remove-Item $p -Force } }
foreach ($f in (Get-ChildItem (Join-Path $out 'hub') -Recurse -Filter '*.html')) {
  $h = Read-Text $f.FullName
  $h = $h.Replace('<meta name="robots" content="index, follow">', '<meta name="robots" content="noindex, nofollow">')
  Write-Text $f.FullName $h
}
Copy-Item (Join-Path $src 'funnel\robots.txt') (Join-Path $out 'robots.txt')
Write-Text (Join-Path $out 'index.html') '<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>FinanceMyADU</title><meta name="robots" content="noindex, follow"><meta http-equiv="refresh" content="0; url=funnel/"></head><body><p>Opening the <a href="funnel/">FinanceMyADU page</a>.</p></body></html>'
Write-Text (Join-Path $out '404.html') '<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Page not found</title><meta name="robots" content="noindex"></head><body style="font-family:system-ui,sans-serif;padding:32px"><h1>Page not found</h1><p><a href="/funnel/">Go to the FinanceMyADU page</a>.</p></body></html>'
Write-Text (Join-Path $out 'CNAME') 'financemyadu.io'
Write-Text (Join-Path $out '.nojekyll') ''
$n = (Get-ChildItem $out -Recurse -File | Measure-Object).Count
Write-Host "dist-pages ready: $n files"
