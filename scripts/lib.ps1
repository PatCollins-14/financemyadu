# Shared helpers for build.ps1, preflight.ps1, snapshot.ps1 (Windows PowerShell 5.1).
$ErrorActionPreference = 'Stop'
$script:Utf8 = New-Object System.Text.UTF8Encoding($false)

function Get-Root { Split-Path -Parent $PSScriptRoot }

function Read-Text([string]$Path) { [System.IO.File]::ReadAllText($Path, $script:Utf8) }

function Write-Text([string]$Path, [string]$Content) {
  $dir = Split-Path -Parent $Path
  if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  [System.IO.File]::WriteAllText($Path, $Content, $script:Utf8)
}

function Read-Json([string]$Path) { (Read-Text $Path) | ConvertFrom-Json }

# Config: config/site.json, overridden by environment variables with the same name.
function Get-Config {
  $root = Get-Root
  $cfg = Read-Json (Join-Path $root 'config\site.json')
  $out = @{}
  foreach ($p in $cfg.PSObject.Properties) {
    if ($p.Name.StartsWith('_')) { continue }
    $val = $p.Value
    $envVal = [Environment]::GetEnvironmentVariable($p.Name)
    if ($envVal) {
      if ($val -is [bool]) { $val = ($envVal -eq 'true') } else { $val = $envVal }
    }
    $out[$p.Name] = $val
  }
  return $out
}

function Esc([string]$s) {
  if ($null -eq $s) { return '' }
  [System.Net.WebUtility]::HtmlEncode($s)
}

# Visible-text version of an HTML string (used for preflight and JSON-LD matching).
function Get-VisibleText([string]$html) {
  $h = [regex]::Replace($html, '(?is)<(script|style|template|noscript)\b.*?</\1>', ' ')
  $h = [regex]::Replace($h, '(?s)<!--.*?-->', ' ')
  $h = [regex]::Replace($h, '(?i)</(p|div|li|h[1-6]|tr|section|ul|ol|table|blockquote|summary|details)>', "`n")
  $h = [regex]::Replace($h, '<[^>]+>', ' ')
  $h = [System.Net.WebUtility]::HtmlDecode($h)
  $h = [regex]::Replace($h, '[ \t ]+', ' ')
  $h = [regex]::Replace($h, '\s*\n\s*', "`n")
  return $h.Trim()
}

# Replace {{key}} tokens from a hashtable. Unknown tokens are left visible so they get noticed.
function Expand-Tokens([string]$tpl, [hashtable]$vars) {
  return [regex]::Replace($tpl, '\{\{([a-zA-Z0-9_\.\-]+)\}\}', {
    param($m)
    $k = $m.Groups[1].Value
    if ($vars.ContainsKey($k)) { return [string]$vars[$k] } else { return $m.Value }
  })
}

# Wrap [PAT: ...] placeholders so they are easy to see in dev builds.
function Mark-Placeholders([string]$html) {
  return [regex]::Replace($html, '\[PAT:[^\]]*\]', { param($m) '<mark class="pat">' + $m.Value + '</mark>' })
}

function Get-DateStamp { (Get-Date).ToString('yyyy-MM-dd') }

# Parse compliance/REVIEW-CHECKLIST.md rows: | id | page | status | date | reviewer |
function Get-Approvals {
  $path = Join-Path (Get-Root) 'compliance\REVIEW-CHECKLIST.md'
  $map = @{}
  if (-not (Test-Path $path)) { return $map }
  foreach ($line in (Read-Text $path) -split "`n") {
    if ($line -match '^\|\s*`?([a-z0-9\-]+)`?\s*\|[^|]*\|\s*([A-Za-z\- ]+?)\s*\|\s*([0-9\-]*)\s*\|') {
      $map[$Matches[1]] = @{ status = $Matches[2].Trim(); date = $Matches[3].Trim() }
    }
  }
  return $map
}

function Test-Approved($approvals, [string]$id) {
  return ($approvals.ContainsKey($id) -and $approvals[$id].status -eq 'APPROVED' -and $approvals[$id].date -match '^\d{4}-\d{2}-\d{2}$')
}

# Parse a hub content file: "---json\n{...}\n---\n" front matter, then <!--section:id|Heading--> blocks.
function Read-HubFile([string]$Path) {
  $raw = Read-Text $Path
  $m = [regex]::Match($raw, '(?s)^\s*---json\s*(\{.*?\})\s*\n---\s*\n(.*)$')
  if (-not $m.Success) { throw "Bad front matter in $Path" }
  $meta = $m.Groups[1].Value | ConvertFrom-Json
  $body = $m.Groups[2].Value
  $sections = @()
  $marks = [regex]::Matches($body, '(?m)^<!--section:([a-z0-9\-]+)(?:\|([^>]*?))?-->[ \t]*\r?$')
  for ($i = 0; $i -lt $marks.Count; $i++) {
    $start = $marks[$i].Index + $marks[$i].Length
    $end = $(if ($i + 1 -lt $marks.Count) { $marks[$i + 1].Index } else { $body.Length })
    $sections += [pscustomobject]@{ id = $marks[$i].Groups[1].Value; heading = $marks[$i].Groups[2].Value; html = $body.Substring($start, $end - $start).Trim() }
  }
  return [pscustomobject]@{ meta = $meta; sections = $sections }
}
