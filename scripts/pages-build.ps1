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
Copy-Item (Join-Path $root 'assets\favicon.ico') (Join-Path $out 'favicon.ico')
Copy-Item (Join-Path $root 'assets\favicon.svg') (Join-Path $out 'favicon.svg')
Write-Text (Join-Path $out 'index.html') '<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>FinanceMyADU</title><meta name="robots" content="noindex, follow"><meta http-equiv="refresh" content="0; url=funnel/"></head><body><p>Opening the <a href="funnel/">FinanceMyADU page</a>.</p></body></html>'
Write-Text (Join-Path $out '404.html') '<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Page not found</title><meta name="robots" content="noindex"></head><body style="font-family:system-ui,sans-serif;padding:32px"><h1>Page not found</h1><p><a href="/funnel/">Go to the FinanceMyADU page</a>.</p></body></html>'
Write-Text (Join-Path $out 'CNAME') 'financemyadu.io'
Write-Text (Join-Path $out '.nojekyll') ''

# Off switch (Pat, 2026-11-05: spam was coming in through the form). With SITE_OFFLINE true in config/site.json, every
# page is replaced by a short "back soon" page with no form and no scripts. Set it to false and push to bring the site back.
$cfg = Get-Config
if ($cfg['SITE_OFFLINE']) {
  $hold = '<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>FinanceMyADU</title><meta name="robots" content="noindex, nofollow"><link rel="icon" href="/favicon.svg" type="image/svg+xml"><style>body{margin:0;min-height:100vh;display:grid;place-items:center;background:#f6f9fd;color:#223d78;font-family:system-ui,-apple-system,Segoe UI,sans-serif;text-align:center;padding:24px}h1{font-size:clamp(28px,5vw,44px);margin:0 0 10px}p{margin:0;color:#4a5b78;font-size:17px}</style></head><body><main><h1>FinanceMyADU</h1><p>This page is being updated. Please check back&nbsp;soon.</p></main></body></html>'
  foreach ($f in (Get-ChildItem $out -Recurse -File)) {
    if ($f.Extension -eq '.html') { Write-Text $f.FullName $hold }
    elseif ($f.Extension -in @('.js', '.json', '.xml', '.css')) { Remove-Item $f.FullName -Force }
  }
  Write-Text (Join-Path $out 'index.html') $hold
  Write-Text (Join-Path $out '404.html') $hold
  Write-Host 'SITE_OFFLINE: every page replaced by the holding page'
}
$n = (Get-ChildItem $out -Recurse -File | Measure-Object).Count
Write-Host "dist-pages ready: $n files"
