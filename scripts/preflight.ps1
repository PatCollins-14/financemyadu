# Preflight gate. Exits non-zero on ANY failure. With -Dev the same findings are reported as warnings and the exit code is 0.
#   run.cmd preflight       -> production gate (expected to fail until placeholders are filled and compliance approves)
#   run.cmd preflight-dev   -> same checks, warnings only
param([switch]$Dev, [int]$Max = 6)
. "$PSScriptRoot\lib.ps1"
$root = Get-Root
$cfg = Get-Config
$banned = Read-Json (Join-Path $root 'config\banned-phrases.json')
$pagesCfg = Read-Json (Join-Path $root 'config\pages.json')
$idn = Read-Json (Join-Path $root 'src\data\identity.json')
$approvals = Get-Approvals
$dist = Join-Path $root 'dist'
$findings = New-Object System.Collections.ArrayList
function Add-F([string]$id, [string]$file, [string]$msg) { [void]$findings.Add([pscustomobject]@{ id = $id; file = $file; msg = $msg }) }
function NiceDate([string]$d) { [datetime]::ParseExact($d, 'yyyy-MM-dd', [Globalization.CultureInfo]::InvariantCulture).ToString('MMMM d, yyyy', [Globalization.CultureInfo]::InvariantCulture) }
function Norm([string]$s) { ([regex]::Replace([System.Net.WebUtility]::HtmlDecode($s), '\s+', ' ')).Trim() }

# ---- build the list of pages to check ----
$targets = @()
$targets += [pscustomobject]@{ id = 'funnel'; kind = 'funnel'; path = '/'; file = (Join-Path $dist 'funnel\index.html'); allow = @(); gate = $false; base = ([string]$cfg['FUNNEL_BASE_URL']).TrimEnd('/') }
foreach ($p in $pagesCfg.hub) {
  $hf = Read-HubFile (Join-Path $root ('src\hub\pages\' + $p.file))
  $allow = @(); if ($hf.meta.PSObject.Properties.Name -contains 'allowTerms') { $allow = @($hf.meta.allowTerms) }
  $gate = [bool]($p.PSObject.Properties.Name -contains 'gate' -and $p.gate)
  $targets += [pscustomobject]@{ id = $p.id; kind = 'hub'; path = $p.path; file = (Join-Path (Join-Path $dist 'hub') (($p.path.Trim('/')).Replace('/', '\') + '\index.html')); allow = $allow; gate = $gate; base = ([string]$cfg['HUB_BASE_URL']).TrimEnd('/'); meta = $hf.meta }
}
$sourceMap = ''; $smPath = Join-Path $root 'docs\SOURCE-MAP.md'
if (Test-Path $smPath) { $sourceMap = Read-Text $smPath }

foreach ($t in $targets) {
  $name = $t.id
  # 11. approval
  if (-not (Test-Approved $approvals $t.id)) { Add-F 'approval' $name 'not marked APPROVED (with a date) in compliance/REVIEW-CHECKLIST.md' }
  if (-not (Test-Path $t.file)) { Add-F 'built' $name 'page not present in dist (not built, for example skipped as unapproved)'; continue }
  $html = Read-Text $t.file
  $approved = Test-Approved $approvals $t.id
  $head = [regex]::Match($html, '(?is)<head>(.*?)</head>').Groups[1].Value
  $bodyHtml = [regex]::Replace($html, '(?is)<head>.*?</head>', '')
  $text = Get-VisibleText $bodyHtml

  # 1. placeholders
  $phCount = ([regex]::Matches($html, '\[PAT:')).Count
  if ($phCount -gt 0) { Add-F 'placeholder' $name "$phCount [PAT: ...] placeholder(s) remain" }

  # 2. banned phrases (intake <select> options, placeholders and required disclosure sentences are excluded)
  $scan = [regex]::Replace($bodyHtml, '(?is)<select\b.*?</select>', ' ')
  $scan = Get-VisibleText $scan
  $scan = [regex]::Replace($scan, '\[PAT:[^\]]*\]', ' ')
  $title = [regex]::Match($head, '(?is)<title>(.*?)</title>').Groups[1].Value
  $desc = [regex]::Match($head, '(?is)<meta name="description" content="(.*?)">').Groups[1].Value
  $scan = $scan + "`n" + (Norm $title) + "`n" + (Norm $desc)
  $skip = @($banned.allowedExact) + @($t.allow) | Sort-Object { $_.Length } -Descending
  foreach ($a in $skip) { $scan = [regex]::Replace($scan, [regex]::Escape([string]$a), ' ', 'IgnoreCase') }
  foreach ($b in $banned.patterns) {
    foreach ($m in [regex]::Matches($scan, [string]$b.re, 'IgnoreCase')) {
      $s = [Math]::Max(0, $m.Index - 25); $len = [Math]::Min(70, $scan.Length - $s)
      Add-F 'banned-phrase' $name ("[$($b.id)] '" + $m.Value + "' near: ..." + (($scan.Substring($s, $len)) -replace '\s+', ' ') + '...')
    }
  }

  # 3. footer identifiers
  foreach ($need in @("NMLS #$($idn.person.nmls)", "NMLS #$($idn.company.nmls)", 'Equal Housing Opportunity', 'nmlsconsumeraccess.org', 'DRE')) {
    if ($html -notmatch [regex]::Escape($need)) { Add-F 'footer' $name "footer is missing '$need'" }
  }
  if ($html -notmatch '(?i)<img[^>]*equal-housing-opportunity[^>]*>') { Add-F 'footer' $name 'Equal Housing Opportunity logo image missing' }

  # 4. noindex rules
  $robotsMeta = [regex]::Match($head, '(?i)<meta name="robots" content="([^"]*)"').Groups[1].Value
  if ($t.kind -eq 'funnel') {
    if ($robotsMeta -notmatch 'noindex') { Add-F 'noindex' $name 'funnel page lacks meta noindex' }
  } else {
    if ($t.gate -and -not $approved -and $robotsMeta -notmatch 'noindex') { Add-F 'noindex' $name 'COMPLIANCE-GATE page not yet approved must be noindex' }
    if (-not ($t.gate -and -not $approved) -and $robotsMeta -match 'noindex') { Add-F 'noindex' $name 'hub page must be indexable (no noindex)' }
  }

  # 7. title, description, canonical, one H1
  if (-not (Norm $title)) { Add-F 'meta' $name 'missing <title>' } elseif ((Norm $title).Length -gt 60) { Add-F 'meta-length' $name ("title is $((Norm $title).Length) characters (aim under about 60)") }
  if (-not (Norm $desc)) { Add-F 'meta' $name 'missing meta description' } elseif ((Norm $desc).Length -gt 155) { Add-F 'meta-length' $name ("description is $((Norm $desc).Length) characters (aim under about 155)") }
  $canon = [regex]::Match($head, '(?i)<link rel="canonical" href="([^"]+)"').Groups[1].Value
  if (-not $canon) { Add-F 'meta' $name 'missing canonical' } elseif ($canon -ne ($t.base + $t.path)) { Add-F 'meta' $name "canonical '$canon' does not equal base + path" }
  $h1s = [regex]::Matches($html, '(?is)<h1[\s>].*?</h1>')
  if ($h1s.Count -ne 1) { Add-F 'h1' $name "expected exactly 1 <h1>, found $($h1s.Count)" }

  # 8. JSON-LD parses and matches visible text
  $lds = [regex]::Matches($head, '(?is)<script type="application/ld\+json">(.*?)</script>')
  if ($lds.Count -eq 0) { Add-F 'jsonld' $name 'no JSON-LD block' }
  foreach ($ld in $lds) {
    try { $obj = $ld.Groups[1].Value | ConvertFrom-Json } catch { Add-F 'jsonld' $name 'JSON-LD does not parse'; continue }
    $normText = Norm $text
    foreach ($n in $obj.'@graph') {
      switch ($n.'@type') {
        'Article' {
          $h1txt = Norm ([regex]::Replace($h1s[0].Value, '<[^>]+>', ''))
          if ((Norm $n.headline) -ne $h1txt) { Add-F 'jsonld' $name "Article headline does not match visible H1" }
          if ($normText -notmatch [regex]::Escape((NiceDate $n.dateModified))) { Add-F 'jsonld' $name "dateModified $($n.dateModified) is not shown as 'Last reviewed' text" }
        }
        'Person' { if ($normText -notmatch [regex]::Escape($n.name)) { Add-F 'jsonld' $name "Person name '$($n.name)' is not visible on the page" } }
        'Organization' { if ($normText -notmatch [regex]::Escape($n.name)) { Add-F 'jsonld' $name "Organization name '$($n.name)' is not visible on the page" } }
        'WebPage' { if ((Norm $n.name) -ne (Norm $title)) { Add-F 'jsonld' $name 'WebPage name does not match <title>' } }
        'FAQPage' {
          foreach ($q in $n.mainEntity) {
            if ($normText -notmatch [regex]::Escape((Norm $q.name))) { Add-F 'jsonld' $name "FAQ question not visible: $($q.name)" }
            if ($normText -notmatch [regex]::Escape((Norm $q.acceptedAnswer.text))) { Add-F 'jsonld' $name "FAQ answer not visible for: $($q.name)" }
          }
        }
        { $_ -in @('Review', 'AggregateRating') } { Add-F 'jsonld' $name "$_ markup is not allowed" }
      }
    }
  }

  # 9. raw HTML has H1 and body text (no JavaScript needed)
  $mainText = Get-VisibleText ([regex]::Match($html, '(?is)<main.*?</main>').Value)
  $words = @($mainText -split '\s+' | Where-Object { $_ }).Count
  $minWords = $(if ($t.kind -eq 'funnel') { 350 } else { 200 })
  if ($words -lt $minWords) { Add-F 'raw-html' $name "only $words words of body text in raw HTML (expected at least $minWords)" }

  # 10. image alt text
  foreach ($im in [regex]::Matches($html, '(?i)<img\b[^>]*>')) { if ($im.Value -notmatch '(?i)\salt="[^"]*"') { Add-F 'alt' $name 'image without alt attribute' } }

  # 12. SOURCE comments need entries in SOURCE-MAP.md
  foreach ($sc in [regex]::Matches($html, '<!-- SOURCE: (\S+) \| retrieved (\S+) -->')) {
    if ($sourceMap -notmatch [regex]::Escape($sc.Groups[1].Value)) { Add-F 'source-map' $name "SOURCE comment URL not in docs/SOURCE-MAP.md: $($sc.Groups[1].Value)" }
  }

  # draft banner must match approval state
  $hasDraft = $html -match 'DRAFT: not yet reviewed by compliance'
  if ($t.kind -eq 'hub') {
    if ($approved -and $hasDraft) { Add-F 'draft-banner' $name 'approved page still shows the DRAFT banner' }
    if (-not $approved -and -not $hasDraft) { Add-F 'draft-banner' $name 'unapproved page is missing the DRAFT banner' }
  }
  # funnel-specific
  if ($t.kind -eq 'funnel') {
    if (-not $cfg['SHOW_REVERSE_SECTION']) {
      if ($html -match 'COMPLIANCE-GATE: reverse-mortgage' -or $text -match '\bHECM\b') { Add-F 'gate' $name 'reverse mortgage content present while SHOW_REVERSE_SECTION is false' }
    }
    if (-not $cfg['SHOW_EXAMPLE'] -and $html -match 'id="example"') { Add-F 'gate' $name 'worked example present while SHOW_EXAMPLE is false' }
    if (-not [string]$cfg['FORM_ENDPOINT']) { Add-F 'form-endpoint' $name 'FORM_ENDPOINT is not set (the form is not connected)' }
    # The form is deliberately minimal (Pat, 2026-10-23/24): name, email and phone only. No file upload.
    $formHtml = [regex]::Match($html, '(?is)<form id="leadForm".*?</form>').Value
    if (-not $formHtml) { Add-F 'form-fields' $name 'lead form (id="leadForm") not found' }
    else {
      $allowedNames = @('name', 'email', 'phone', 'utm_source', 'utm_medium', 'utm_campaign', 'utm_content')
      foreach ($m in [regex]::Matches($formHtml, '(?i)<(?:input|select|textarea)\b[^>]*\bname="([^"]+)"')) { if ($allowedNames -notcontains $m.Groups[1].Value) { Add-F 'form-fields' $name "unexpected form field '$($m.Groups[1].Value)'" } }
      foreach ($req in @('name', 'email', 'phone')) { if ($formHtml -notmatch "name=`"$req`"") { Add-F 'form-fields' $name "form is missing the '$req' field" } }
      if ($formHtml -match '(?i)<select\b|type="checkbox"') { Add-F 'form-fields' $name 'form contains a select or checkbox' }
      if ($formHtml -match '(?i)type="file"|enctype="multipart') { Add-F 'form-fields' $name 'form has a file upload (removed by Pat, 2026-10-24)' }
    }
    # No checkbox, so consent is a statement under the button with the privacy link.
    if ($html -notmatch 'By providing my phone number, I agree to receive text messages' -or $html -notmatch 'Privacy Policy') { Add-F 'consent' $name 'consent statement or privacy link missing near the form' }
  }
  if ($html -match 'sg-host\.com') { Add-F 'staging-url' $name 'contains a sg-host.com staging URL' }
}

# 5. robots.txt
$robotFiles = @(@{ n = 'funnel'; f = (Join-Path $dist 'funnel\robots.txt'); need = @('OAI-AdsBot', 'OAI-SearchBot', 'Googlebot') }, @{ n = 'hub'; f = (Join-Path $dist 'hub\robots.txt'); need = @('OAI-SearchBot', 'Googlebot') })
foreach ($r in $robotFiles) {
  if (-not (Test-Path $r.f)) { Add-F 'robots' $r.n 'robots.txt missing'; continue }
  $rt = Read-Text $r.f
  $agent = ''
  foreach ($line in ($rt -split "`n")) {
    $l = $line.Trim()
    if ($l -match '^(?i)User-agent:\s*(.+)$') { $agent = $Matches[1].Trim() }
    elseif ($l -match '^(?i)Disallow:\s*/\s*$') {
      if (-not ($agent -eq 'GPTBot' -and -not $cfg['ALLOW_GPTBOT'])) { Add-F 'robots' $r.n "Disallow: / for user-agent '$agent'" }
    }
  }
  foreach ($n in $r.need) { if ($rt -notmatch "(?im)^User-agent:\s*$n\s*$") { Add-F 'robots' $r.n "no explicit allow group for $n" } }
  if ($r.n -eq 'hub' -and $rt -notmatch '(?im)^Sitemap:') { Add-F 'robots' $r.n 'robots.txt does not reference the sitemap' }
}
# 6. sitemap
$smFile = Join-Path $dist 'hub\sitemap.xml'
if (-not (Test-Path $smFile)) { Add-F 'sitemap' 'hub' 'sitemap.xml missing' }
else {
  $locs = @([regex]::Matches((Read-Text $smFile), '<loc>([^<]+)</loc>') | ForEach-Object { $_.Groups[1].Value })
  foreach ($t in ($targets | Where-Object { $_.kind -eq 'hub' })) {
    if (-not (Test-Path $t.file)) { continue }
    $hh = Read-Text $t.file
    $rm = [regex]::Match($hh, '(?i)<meta name="robots" content="([^"]*)"').Groups[1].Value
    $url = $t.base + $t.path
    if ($rm -match 'noindex' -and $locs -contains $url) { Add-F 'sitemap' $t.id 'sitemap lists a noindex page' }
    if ($rm -notmatch 'noindex' -and $locs -notcontains $url) { Add-F 'sitemap' $t.id 'indexable page missing from sitemap' }
  }
}
if (Test-Path (Join-Path $dist 'funnel\sitemap.xml')) { Add-F 'sitemap' 'funnel' 'funnel is noindex and should not have a sitemap' }
if (Get-ChildItem $dist -Recurse -Filter 'llms.txt' -ErrorAction SilentlyContinue) { Add-F 'llms' 'dist' 'llms.txt must not be added' }

# ---- report ----
$label = $(if ($Dev) { 'WARN' } else { 'FAIL' })
Write-Host ''
Write-Host ("Preflight (" + $(if ($Dev) { 'dev: warnings only' } else { 'PRODUCTION gate' }) + ")")
Write-Host ('=' * 60)
if ($findings.Count -eq 0) { Write-Host 'All checks passed.'; exit 0 }
$groups = $findings | Group-Object id | Sort-Object Name
foreach ($g in $groups) {
  Write-Host ("[$label] $($g.Name): $($g.Count)")
  foreach ($f in ($g.Group | Select-Object -First $Max)) { Write-Host ("    " + $f.file + ': ' + $f.msg) }
  if ($g.Count -gt $Max) { Write-Host ("    ... and " + ($g.Count - $Max) + ' more') }
}
Write-Host ('=' * 60)
Write-Host ("Total findings: " + $findings.Count)
if ($Dev) { exit 0 } else { exit 1 }
