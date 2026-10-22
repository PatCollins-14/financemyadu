# Checks links in dist/. Internal (relative or same-base) links must resolve to a built file.
# -External also requests each unique external URL once per second (GET, browser-like user agent) and expects HTTP 2xx/3xx.
param([switch]$External)
. "$PSScriptRoot\lib.ps1"
$root = Get-Root
$cfg = Get-Config
$dist = Join-Path $root 'dist'
$bad = New-Object System.Collections.ArrayList
$ext = @{}
$count = 0
$bases = @{ funnel = ([string]$cfg['FUNNEL_BASE_URL']).TrimEnd('/'); hub = ([string]$cfg['HUB_BASE_URL']).TrimEnd('/') }
foreach ($f in (Get-ChildItem $dist -Recurse -File -Filter '*.html')) {
  $html = Read-Text $f.FullName
  $area = $(if ($f.FullName -like '*\dist\funnel\*') { 'funnel' } else { 'hub' })
  $outRoot = Join-Path $dist $area
  foreach ($m in [regex]::Matches($html, '(?i)<(?:a|link|img|script)\b[^>]*?\b(?:href|src)="([^"]+)"')) {
    $u = [System.Net.WebUtility]::HtmlDecode($m.Groups[1].Value)
    $count++
    if ($u -match '^(mailto:|tel:|#|data:|javascript:)') { continue }
    if ($u -match '^https?://') {
      $hubOwned = ($area -eq 'funnel') -or ($u.StartsWith($bases[$area] + '/adu-financing/')) -or ($u.StartsWith($bases[$area] + '/about/pat-collins/'))
      if ($u.StartsWith($bases[$area] + '/') -and $hubOwned) {
        # same-base absolute link: map to dist file
        $p = $u.Substring($bases[$area].Length).Split('#')[0].Split('?')[0]
        $target = Join-Path $outRoot ($p.TrimStart('/').Replace('/', '\'))
        if ((Test-Path $target -PathType Container)) { $target = Join-Path $target 'index.html' }
        if ($p -eq '/' -and $area -eq 'hub') { continue }  # hub home belongs to the main WordPress site
        if (-not (Test-Path $target -PathType Leaf)) { [void]$bad.Add("$($f.Name): same-site link not built: $u") }
      } else { if (-not $u.StartsWith('https://fonts.')) { $ext[$u.Split('#')[0]] = $f.Name } }
      continue
    }
    $rel = $u.Split('#')[0].Split('?')[0]
    if (-not $rel) { continue }
    $target = [System.IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $f.FullName) ($rel.Replace('/', '\'))))
    if (Test-Path $target -PathType Container) { $target = Join-Path $target 'index.html' }
    if (-not (Test-Path $target -PathType Leaf)) { [void]$bad.Add("$($f.FullName.Substring($dist.Length + 1)): broken relative link: $u") }
  }
}
Write-Host "Checked $count link/asset references in dist; internal problems: $($bad.Count)"
$bad | ForEach-Object { Write-Host "  $_" }
if ($External) {
  Write-Host "Checking $($ext.Count) unique external URLs (1 per second)..."
  foreach ($u in ($ext.Keys | Sort-Object)) {
    $code = & curl.exe -sL -o NUL -w '%{http_code}' -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/124.0 Safari/537.36' --max-time 25 $u
    $flag = $(if ($code -match '^[23]') { 'ok ' } else { 'BAD' })
    Write-Host ("  [$flag] $code $u")
    Start-Sleep -Seconds 1
  }
}
if ($bad.Count) { exit 1 }
