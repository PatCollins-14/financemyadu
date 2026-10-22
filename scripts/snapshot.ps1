# Saves a dated copy of every built page and every ad into compliance/snapshots/<date>/ with a SHA-256 manifest.
. "$PSScriptRoot\lib.ps1"
$root = Get-Root
$date = Get-DateStamp
$dest = Join-Path $root "compliance\snapshots\$date"
if (Test-Path $dest) { $dest = $dest + '-' + (Get-Date).ToString('HHmm') }
New-Item -ItemType Directory -Force -Path $dest | Out-Null
$manifest = New-Object System.Collections.ArrayList
$dist = Join-Path $root 'dist'
if (Test-Path $dist) {
  foreach ($f in (Get-ChildItem $dist -Recurse -File -Include '*.html', 'robots.txt', 'sitemap.xml')) {
    $rel = $f.FullName.Substring($dist.Length + 1)
    $to = Join-Path (Join-Path $dest 'pages') $rel
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $to) | Out-Null
    Copy-Item $f.FullName $to
    [void]$manifest.Add("$((Get-FileHash $f.FullName -Algorithm SHA256).Hash)  pages/$($rel -replace '\\','/')")
  }
}
foreach ($a in @('ads\ad-copy.md', 'ads\ad-copy.csv')) {
  $p = Join-Path $root $a
  if (Test-Path $p) {
    $to = Join-Path (Join-Path $dest 'ads') (Split-Path -Leaf $p)
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $to) | Out-Null
    Copy-Item $p $to
    [void]$manifest.Add("$((Get-FileHash $p -Algorithm SHA256).Hash)  ads/$(Split-Path -Leaf $p)")
  }
}
$cl = Join-Path $root 'compliance\REVIEW-CHECKLIST.md'
if (Test-Path $cl) { Copy-Item $cl (Join-Path $dest 'REVIEW-CHECKLIST.md'); [void]$manifest.Add("$((Get-FileHash $cl -Algorithm SHA256).Hash)  REVIEW-CHECKLIST.md") }
Write-Text (Join-Path $dest 'MANIFEST.txt') ("Snapshot taken $(Get-Date -Format 'yyyy-MM-dd HH:mm') (local time)`n" + ($manifest -join "`n") + "`n")
Write-Host "Snapshot saved: $dest ($($manifest.Count) files)"
