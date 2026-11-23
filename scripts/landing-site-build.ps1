# Builds the live www.financemyadu.io site from the one-page landing (landing/) into dist-pages/.
# Since D92 (2026-11-21) this replaces pages-build.ps1 in the GitHub Pages workflow.
# Expects landing/index.html to be freshly built (the workflow runs `node landing/build.mjs` first).
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$src = Join-Path $root 'landing'
$out = Join-Path $root 'dist-pages'
if (Test-Path $out) { Remove-Item $out -Recurse -Force }
New-Item -ItemType Directory -Force $out | Out-Null

function Write-Text($path, $text) { [System.IO.File]::WriteAllText($path, $text, (New-Object System.Text.UTF8Encoding($false))) }

# Only the page and the files it loads; never the source, build script or README
Copy-Item (Join-Path $src 'index.html') $out
Copy-Item (Join-Path $src 'img') (Join-Path $out 'img') -Recurse
Copy-Item (Join-Path $src 'assets') (Join-Path $out 'assets') -Recurse
# Favicons at the root too, for browsers that ask for /favicon.ico
Copy-Item (Join-Path $src 'assets\favicon.ico') $out
Copy-Item (Join-Path $src 'assets\favicon.svg') $out

Write-Text (Join-Path $out 'CNAME') 'www.financemyadu.io'
# Never block crawlers in robots.txt (CLAUDE.md rule 10); the page itself carries noindex
Write-Text (Join-Path $out 'robots.txt') "User-agent: *`nAllow: /`n"
# Old funnel and hub addresses (/funnel/, /hub/...) land on the new page
Write-Text (Join-Path $out '404.html') '<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>FinanceMyADU</title><meta name="robots" content="noindex"><meta http-equiv="refresh" content="0; url=/"><link rel="canonical" href="https://www.financemyadu.io/"></head><body><p><a href="/">Go to FinanceMyADU</a></p></body></html>'
Write-Text (Join-Path $out '.nojekyll') ''

$n = (Get-ChildItem $out -Recurse -File).Count
Write-Host "dist-pages ready: $n files"
