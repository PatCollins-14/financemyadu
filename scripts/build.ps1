# Static build for the ADU funnel (Asset A) and education hub (Asset B). Windows PowerShell 5.1.
#   run.cmd build        -> dev build (placeholders highlighted, draft banners on, all pages)
#   run.cmd production   -> production build: only APPROVED pages (compliance/REVIEW-CHECKLIST.md), no highlighting
param([switch]$Production)
. "$PSScriptRoot\lib.ps1"
Add-Type -AssemblyName System.Drawing
$root = Get-Root
$cfg = Get-Config
$idn = Read-Json (Join-Path $root 'src\data\identity.json')
$srcs = Read-Json (Join-Path $root 'src\data\sources.json')
$pagesCfg = Read-Json (Join-Path $root 'config\pages.json')
$approvals = Get-Approvals
$today = [string]$cfg['BUILD_DATE']
$dist = Join-Path $root 'dist'
if (Test-Path $dist) { Remove-Item $dist -Recurse -Force }
$hubBase = ([string]$cfg['HUB_BASE_URL']).TrimEnd('/')
$funnelBase = ([string]$cfg['FUNNEL_BASE_URL']).TrimEnd('/')
$sourceUse = New-Object System.Collections.ArrayList
$built = New-Object System.Collections.ArrayList
$skipped = New-Object System.Collections.ArrayList

function NiceDate([string]$d) { [datetime]::ParseExact($d, 'yyyy-MM-dd', [Globalization.CultureInfo]::InvariantCulture).ToString('MMMM d, yyyy', [Globalization.CultureInfo]::InvariantCulture) }
function Depth([string]$path) { @($path.Trim('/').Split('/') | Where-Object { $_ -ne '' }).Count }
function Rel([string]$from, [string]$to) { ('../' * (Depth $from)) + $to.TrimStart('/') }
# In dev/preview builds, links to pages we build point at the local copy; production keeps absolute URLs.
function CrumbHref([string]$u, [string]$from) {
  if ($Production) { return $u }
  foreach ($p in @('/adu-financing/', '/about/pat-collins/')) { if ($u -eq ($hubBase + $p)) { return (Rel $from $p) } }
  return $u
}
function ImgSize([string]$file) {
  $img = [System.Drawing.Image]::FromFile($file)
  try { return @{ w = $img.Width; h = $img.Height } } finally { $img.Dispose() }
}
function Apply-Conditionals([string]$html) {
  foreach ($flag in @('SHOW_REVERSE_SECTION', 'SHOW_EXAMPLE')) {
    $on = [bool]$cfg[$flag]
    $html = [regex]::Replace($html, "(?s)<!--IF:$flag-->(.*?)<!--/IF-->", { param($m) if ($on) { $m.Groups[1].Value } else { '' } })
  }
  return $html
}
function Add-Source([string]$page, [string]$url, [string]$what) { [void]$sourceUse.Add([pscustomobject]@{ page = $page; url = $url; what = $what }) }

# ---------- assets ----------
$eho = ImgSize (Join-Path $root 'assets\equal-housing-opportunity.png')
function Copy-Assets([string]$outDir) {
  $a = Join-Path $outDir 'assets'
  New-Item -ItemType Directory -Force -Path $a | Out-Null
  Copy-Item (Join-Path $root 'src\assets\site.css') $a
  Copy-Item (Join-Path $root 'assets\equal-housing-opportunity.png') $a
  Copy-Item (Join-Path $root 'assets\lthm-logo-orange.png') $a
}

# ---------- JSON-LD ----------
function New-Graph([string]$base, [string]$pageUrl, [string]$pageType, [string]$name, [string]$headline, [string]$desc, [string]$datePub, [string]$dateMod, $crumbs, $faq, [bool]$withAuthorUrl) {
  $orgId = "$base/#org"; $personId = "$base/#pat"
  $org = [ordered]@{
    '@type' = 'Organization'; '@id' = $orgId; name = $idn.company.name
    address = [ordered]@{ '@type' = 'PostalAddress'; streetAddress = '3750 S. Susan Street'; addressLocality = 'Santa Ana'; addressRegion = 'CA'; postalCode = '92704'; addressCountry = 'US' }
    identifier = [ordered]@{ '@type' = 'PropertyValue'; propertyID = 'NMLS ID'; value = $idn.company.nmls }
  }
  $person = [ordered]@{
    '@type' = 'Person'; '@id' = $personId; name = $idn.person.shortName; alternateName = $idn.person.fullName
    jobTitle = $idn.person.jobTitle
    identifier = [ordered]@{ '@type' = 'PropertyValue'; propertyID = 'NMLS ID'; value = $idn.person.nmls }
    worksFor = [ordered]@{ '@id' = $orgId }
    telephone = $idn.contact.phone; email = $idn.contact.email
    sameAs = @($idn.social.sameAs)
  }
  if ($withAuthorUrl) { $person['url'] = "$hubBase/about/pat-collins/" }
  $site = [ordered]@{ '@type' = 'WebSite'; '@id' = "$base/#website"; url = "$base/"; name = $(if ($base -eq $funnelBase) { 'ADU Financing with Pat Collins' } else { "Let's Talk Home Mortgage: ADU financing guide" }); publisher = [ordered]@{ '@id' = $orgId } }
  $page = [ordered]@{ '@type' = $pageType; '@id' = "$pageUrl#page"; url = $pageUrl; name = $name; description = $desc; isPartOf = [ordered]@{ '@id' = "$base/#website" } }
  if ($pageType -eq 'Article') {
    $page['headline'] = $headline
    $page['author'] = [ordered]@{ '@id' = $personId }
    $page['publisher'] = [ordered]@{ '@id' = $orgId }
    $page['datePublished'] = $datePub
    $page['dateModified'] = $dateMod
    $page['mainEntityOfPage'] = $pageUrl
  } elseif ($pageType -eq 'ProfilePage') {
    $page['mainEntity'] = [ordered]@{ '@id' = $personId }
    $page['dateModified'] = $dateMod
  }
  $graph = New-Object System.Collections.ArrayList
  [void]$graph.Add($org); [void]$graph.Add($person); [void]$graph.Add($site); [void]$graph.Add($page)
  if ($crumbs) {
    $items = @(); $pos = 1
    foreach ($c in $crumbs) { $items += [ordered]@{ '@type' = 'ListItem'; position = $pos; name = $c.name; item = $c.url }; $pos++ }
    [void]$graph.Add([ordered]@{ '@type' = 'BreadcrumbList'; '@id' = "$pageUrl#crumbs"; itemListElement = $items })
  }
  if ($faq) {
    $qs = @()
    foreach ($f in $faq) { $qs += [ordered]@{ '@type' = 'Question'; name = $f.q; acceptedAnswer = [ordered]@{ '@type' = 'Answer'; text = $f.a } } }
    [void]$graph.Add([ordered]@{ '@type' = 'FAQPage'; '@id' = "$pageUrl#faq"; mainEntity = $qs })
  }
  $obj = [ordered]@{ '@context' = 'https://schema.org'; '@graph' = @($graph) }
  return '<script type="application/ld+json">' + ($obj | ConvertTo-Json -Depth 12 -Compress) + '</script>'
}

function Get-Head([string]$title, [string]$desc, [string]$canonical, [string]$robots, [string]$jsonld, [string]$cssHref, [string]$ogType) {
  $t = Esc $title; $d = Esc $desc
  return @"
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$t</title>
<meta name="description" content="$d">
<link rel="canonical" href="$canonical">
<meta name="robots" content="$robots">
<meta property="og:title" content="$t">
<meta property="og:description" content="$d">
<meta property="og:url" content="$canonical">
<meta property="og:type" content="$ogType">
<meta property="og:site_name" content="Pat Collins, E Mortgage Capital Inc.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Hanken+Grotesk:wght@300;400;500;600&display=swap">
<link rel="stylesheet" href="$cssHref">
$jsonld
"@
}

function Get-Footer([string]$assetPrefix, [bool]$isFunnel, [string]$hubRoot) {
  $p = $idn.person; $c = $idn.company; $k = $idn.contact; $l = $idn.siteLinks
  $trade = ''
  if ($isFunnel) { $trade = '<p>[PAT: confirm "FinanceMyADU" is an approved trade name for E Mortgage Capital and that compliance approves its use]</p>' }
  return @"
<footer class="footer">
  <div class="wrap">
    <div class="footer-grid">
      <div><h4>$(Esc $p.shortName)</h4><ul>
        <li><a href="$hubRoot/about/pat-collins/">About Pat</a></li>
        <li><a href="$($l.contact)" rel="noopener">Contact</a></li>
        <li><a href="$(Esc ([string]$cfg['BOOKING_URL']))" rel="noopener">Book a call</a></li></ul></div>
      <div><h4>Learn</h4><ul>
        <li><a href="$hubRoot/adu-financing/">ADU financing guide</a></li>
        <li><a href="$hubRoot/adu-financing/questions-to-ask-your-lender/">Questions to ask</a></li>
        <li><a href="$hubRoot/adu-financing/faq/">ADU FAQ</a></li></ul></div>
      <div><h4>More</h4><ul>
        <li><a href="$($l.home)" rel="noopener">Mortgages</a></li>
        <li><a href="$($l.articles)" rel="noopener">Articles</a></li></ul></div>
      <div class="legal">
        <!-- SOURCE: https://letstalkhomemortgage.com/ | retrieved $today -->
        <p><strong>$(Esc $p.shortName)</strong>, $(Esc $p.jobTitle) &middot; NMLS #$($p.nmls) &middot; DRE $($p.dre)</p>
        <p>$(Esc $c.name) &middot; NMLS #$($c.nmls) &middot; $(Esc $c.address)</p>
        <p><a href="$($k.phoneTel)">$(Esc $k.phone)</a> &middot; <a href="mailto:$($k.email)">$(Esc $k.email)</a> &middot; <a href="$($k.nmlsConsumerAccess)" rel="noopener">NMLS Consumer Access</a></p>
        <div class="eho"><img src="${assetPrefix}equal-housing-opportunity.png" alt="Equal Housing Opportunity" width="$($eho.w)" height="$($eho.h)" loading="lazy"><span>Equal Housing Opportunity</span></div>
        <p>$(Esc $idn.disclosure.standard)</p>
        <p>$(Esc $idn.disclosure.adu)</p>
        $trade
      </div>
    </div>
    <div class="footer-bottom">
      <span>&copy; $($today.Substring(0,4)) $(Esc $p.shortName), NMLS #$($p.nmls) &middot; $(Esc $c.name), NMLS #$($c.nmls) &middot; $(Esc $c.brand), powered by $(Esc $c.poweredBy)</span>
      <span><a href="$($l.privacy)" rel="noopener">Privacy Policy</a> &middot; <a href="$($l.terms)" rel="noopener">Terms &amp; Conditions</a> &middot; <a href="$($l.accessibility)" rel="noopener">Accessibility</a></span>
    </div>
  </div>
</footer>
"@
}

function Finish([string]$html) { if ($Production) { return $html } else { return (Mark-Placeholders $html) } }

# =========================================================
# ASSET A: FUNNEL
# =========================================================
function Build-Funnel {
  $id = 'funnel'
  $ok = Test-Approved $approvals $id
  if ($Production -and -not $ok) { [void]$skipped.Add("funnel (not APPROVED)"); return }
  $out = Join-Path $dist 'funnel'
  Copy-Assets $out
  Copy-Item (Join-Path $root 'src\assets\quiz.js') (Join-Path $out 'assets')
  $tpl = Read-Text (Join-Path $root 'src\funnel\index.html')
  $tpl = Apply-Conditionals $tpl

  # reviews
  $rv = New-Object System.Text.StringBuilder
  $gr = Read-Json (Join-Path $root 'src\data\google-reviews.json')
  foreach ($r in $gr.items) {
    $starGlyphs = ('&#9733;' * [int]$r.stars)
    [void]$rv.AppendLine("      <article class=`"g-card`"><div class=`"g-top`"><span class=`"stars`" role=`"img`" aria-label=`"$($r.stars) out of 5 stars`">$starGlyphs</span><span class=`"g-src`"><span class=`"g-badge`" aria-hidden=`"true`">G</span>Google</span></div>")
    [void]$rv.AppendLine("        <p>$(Esc $r.summary)</p>")
    [void]$rv.AppendLine("        <div class=`"g-author`"><span class=`"g-avatar`" aria-hidden=`"true`">$(Esc $r.initials)</span><div><b>$(Esc $r.name)</b><span>$(Esc $r.when)</span></div></div></article>")
  }
  Add-Source 'funnel' $gr.profileUrl 'Google rating and three review summaries for E Mortgage Capital, Inc. (seen 2026-10-24)'
  # faq
  $faq = Read-Json (Join-Path $root 'src\funnel\faq.json')
  $fq = New-Object System.Text.StringBuilder
  foreach ($f in $faq) {
    if ($f.source) { [void]$fq.AppendLine("      <!-- SOURCE: $($f.source) | retrieved $today -->") }
    [void]$fq.AppendLine("      <details class=`"faq`"><summary>$(Esc $f.q)</summary><div class=`"ans`">$(Esc $f.a)</div></details>")
  }
  $endpoint = [string]$cfg['FORM_ENDPOINT']
  $analytics = [string]$cfg['ANALYTICS_ID']
  $appLine = '[PAT: confirm application link for this campaign]'
  if ([string]$cfg['APPLICATION_URL']) { $appLine = '<a href="' + (Esc ([string]$cfg['APPLICATION_URL'])) + '" data-event="application_link_click" rel="noopener">Ready now? Start your application</a>' }
  $consentBar = ''
  if ($analytics) { $consentBar = '<div class="consent-bar" id="consentBar" role="region" aria-label="Cookie choices"><span>We would like to use Google Tag Manager to measure which pages help. It may set cookies. You can say no.</span><button type="button" class="btn" data-consent="granted">Accept</button><button type="button" class="btn btn-ghost" data-consent="denied">Deny</button></div>' }
  # comparison table (check = yes, cross = no, text = depends on the program)
  $yes = '<svg class="yes" viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-label="Yes" role="img"><path d="M4 10.5l4 4 8-9"/></svg>'
  $no = '<svg class="no" viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" aria-label="No" role="img"><path d="M6 6l8 8M14 6l-8 8"/></svg>'
  $ask = '<span class="ask">Ask</span>'; $var = '<span class="ask">Varies</span>'
  $cmpRows = @(
    @('Keeps your current first mortgage in place', 'What happens to my current mortgage?', @($yes, $yes, $no, $ask)),
    @('Replaces your current mortgage with a new loan', 'Would this replace my current loan?', @($no, $no, $yes, $ask)),
    @('Lets you borrow in stages as you need the money', 'Can I draw funds in stages?', @($yes, $no, $no, $ask)),
    @('Pays you one lump sum', 'Do I get the money all at once?', @($no, $yes, $yes, $ask)),
    @('Rate usually changes over time', 'Is the rate fixed, or can it change?', @($yes, $var, $var, $ask)),
    @('Secured by your home', 'What happens if I cannot repay?', @($yes, $yes, $yes, $yes))
  )
  $cmpHtml = New-Object System.Text.StringBuilder
  foreach ($row in $cmpRows) {
    [void]$cmpHtml.Append("          <tr><th scope=`"row`">$($row[0])</th><td class=`"col-ours`">$($row[1])</td>")
    foreach ($cell in $row[2]) { [void]$cmpHtml.Append("<td>$cell</td>") }
    [void]$cmpHtml.AppendLine('</tr>')
  }
  $k = $idn.contact; $l = $idn.siteLinks
  $vars = @{
    form_endpoint = (Esc $endpoint); analytics_id = (Esc $analytics)
    form_action_attr = $(if ($endpoint) { 'action="' + (Esc $endpoint) + '"' } else { '' })
    person_nmls = $idn.person.nmls; company_nmls = $idn.company.nmls
    phone = $k.phone; phone_tel = $k.phoneTel; email = $k.email
    booking_url = (Esc ([string]$cfg['BOOKING_URL'])); nmls_url = $k.nmlsConsumerAccess
    privacy_url = $l.privacy; terms_url = $l.terms; site_nonqm = $l.nonqm
    google_rating = (Esc $gr.rating); google_count = (Esc $gr.count); google_seen = (Esc $gr.seen); google_url = (Esc $gr.profileUrl); google_name = (Esc $gr.profileName)
    reviews_html = $rv.ToString(); faq_html = $fq.ToString()
    footer = (Get-Footer 'assets/' $true $(if ($Production) { $hubBase } else { '../hub' })); consent_bar = $consentBar; application_line = $appLine
    eho_w = $eho.w; eho_h = $eho.h; compare_rows = $cmpHtml.ToString()
  }
  # Casita Works illustrations (isometric ADUs, hero and closing scenes) and icons, captured from the template as static SVG
  $artDir = Join-Path $root 'src\funnel\art'
  foreach ($f in (Get-ChildItem $artDir -Filter '*.svg')) { $vars[($f.BaseName -replace '-', '_')] = (Read-Text $f.FullName) }
  $iconSet = Read-Json (Join-Path $artDir 'icons.json')
  foreach ($ip in $iconSet.PSObject.Properties) { $vars['icon_' + $ip.Name] = [string]$ip.Value }
  $vars['person_dre'] = [string]$idn.person.dre
  $body = Expand-Tokens $tpl $vars
  $title = 'ADU & Renovation Financing in California | Pat Collins'
  $desc = 'Compare ways to pay for an ADU or home renovation in California, from home equity to renovation loans, with mortgage professional Pat Collins.'
  $canonical = "$funnelBase/"
  $robots = $(if ($cfg['FUNNEL_NOINDEX']) { 'noindex, follow' } else { 'index, follow' })
  $crumbs = $null
  $ld = New-Graph $funnelBase $canonical 'WebPage' $title '' $desc '' $today $null $null $false
  $head = Get-Head $title $desc $canonical $robots $ld 'assets/site.css' 'website'
  # the funnel headline uses a cursive face for its second line
  $head = $head.Replace('family=Hanken+Grotesk:wght@300;400;500;600&display=swap', 'family=Hanken+Grotesk:wght@300;400;500;600&family=Dancing+Script:wght@700&display=swap')
  # head goes in untouched; body is marked
  $body = $body.Replace('{{head}}', $head)
  # mark placeholders only outside the head block
  $idx = $body.IndexOf('<body')
  $final = $body.Substring(0, $idx) + (Finish $body.Substring($idx))
  Write-Text (Join-Path $out 'index.html') $final
  Write-Text (Join-Path $out 'robots.txt') (@"
# Funnel (Asset A). Hidden from search with a meta noindex tag, NOT with Disallow, so ad and search crawlers can still fetch the page.
User-agent: *
Allow: /

User-agent: OAI-AdsBot
Allow: /

User-agent: OAI-SearchBot
Allow: /

User-agent: Googlebot
Allow: /
"@ + "`n")
  Add-Source 'funnel' 'https://letstalkhomemortgage.com/' 'Identifiers, About, process, FAQ answers, reviews, footer disclosure'
  Add-Source 'funnel' 'https://letstalkhomemortgage.com/heloc-loans/' 'HELOC and home equity loan explanation'
  Add-Source 'funnel' 'https://letstalkhomemortgage.com/refinance/' 'Cash-out refinance explanation, low first-mortgage rate note'
  if ($cfg['SHOW_REVERSE_SECTION']) { Add-Source 'funnel' 'https://letstalkhomemortgage.com/reverse-mortgage/' 'HECM obligations, counseling' }
  Add-Source 'funnel' $srcs.'fnma-adu'.url 'ADU definition and renovation loan option'
  Add-Source 'funnel' $srcs.'fnma-b3-3-8-02'.url 'ADU rental income rules'
  Add-Source 'funnel' $srcs.'cfpb-heloc'.url 'HELOC basics'
  [void]$built.Add('funnel')
}

# =========================================================
# ASSET B: HUB
# =========================================================
$stdHeadings = @{ fits = 'Who this fits'; notfits = 'Who this does not fit'; tradeoffs = 'Trade-offs'; ask = 'What to ask a lender'; real = 'What I see in real ADU financing' }
$stdOrder = @('fits', 'notfits', 'tradeoffs', 'ask', 'real')
$hubPages = @{}
$pathToId = @{}
foreach ($p in $pagesCfg.hub) { $hubPages[$p.id] = $p; $pathToId[[string]$p.path] = $p.id }
$hubData = @{}
foreach ($p in $pagesCfg.hub) {
  $hf = Read-HubFile (Join-Path $root ('src\hub\pages\' + $p.file))
  $hubData[$p.id] = $hf
}

function Build-HubPage($p) {
  $hf = $hubData[$p.id]; $m = $hf.meta
  $approved = Test-Approved $approvals $p.id
  if ($Production -and -not $approved) { [void]$skipped.Add("$($p.id) (not APPROVED)"); return }
  $gate = [bool]($p.PSObject.Properties.Name -contains 'gate' -and $p.gate)
  $noindex = ($gate -and -not $approved)
  $path = $p.path
  $url = $hubBase + $path
  $isAuthor = ($p.PSObject.Properties.Name -contains 'kind' -and $p.kind -eq 'author')
  $assetPrefix = (Rel $path 'assets/')
  $outDir = Join-Path (Join-Path $dist 'hub') ($path.Trim('/').Replace('/', '\'))
  $titleTag = [string]$m.title
  $desc = [string]$m.description
  $dateMod = [string]$m.lastReviewed
  $datePub = [string]$m.datePublished

  # --- sections
  $std = @{}; $custom = @()
  foreach ($s in $hf.sections) {
    # {{rel:/some/path/}} becomes a relative link from this page
    $s.html = [regex]::Replace($s.html, '\{\{rel:([^}]+)\}\}', { param($mm) Rel $path $mm.Groups[1].Value })
    $s.html = $s.html.Replace('{{booking_url}}', (Esc ([string]$cfg['BOOKING_URL'])))
    if ($stdOrder -contains $s.id) { $std[$s.id] = $s } else { $custom += $s }
  }
  $toc = @()
  $secHtml = New-Object System.Text.StringBuilder
  foreach ($s in $custom) {
    $h = $s.heading; $anchor = $s.id
    [void]$secHtml.AppendLine("<h2 id=`"$anchor`">$(Esc $h)</h2>"); [void]$secHtml.AppendLine($s.html)
    $toc += @{ id = $anchor; text = $h }
  }
  foreach ($sid in $stdOrder) {
    if ($isAuthor -and $sid -ne 'real') { if (-not $std.ContainsKey($sid)) { continue } }
    if ($std.ContainsKey($sid)) {
      $s = $std[$sid]; $h = $(if ($s.heading) { $s.heading } else { $stdHeadings[$sid] })
      if ($sid -eq 'real') {
        [void]$secHtml.AppendLine("<div class=`"real`"><h2 id=`"$sid`">$(Esc $h)</h2>$($s.html)</div>")
      } else {
        [void]$secHtml.AppendLine("<h2 id=`"$sid`">$(Esc $h)</h2>"); [void]$secHtml.AppendLine($s.html)
      }
      $toc += @{ id = $sid; text = $h }
    } elseif ($sid -eq 'real' -and -not $isAuthor -and -not ($m.PSObject.Properties.Name -contains 'noReal')) {
      $h = $stdHeadings[$sid]
      [void]$secHtml.AppendLine("<div class=`"real`"><h2 id=`"real`">$(Esc $h)</h2><p>[PAT: real scenario from my files; numbers as ranges; what went wrong or surprised me; what I would tell a homeowner in this exact situation]</p></div>")
      $toc += @{ id = 'real'; text = $h }
    }
  }
  # faq page: visible Q&A
  $faqData = $null
  if ($m.PSObject.Properties.Name -contains 'faq') {
    $faqData = @($m.faq)
    $fq = New-Object System.Text.StringBuilder
    foreach ($f in $faqData) {
      [void]$fq.AppendLine("<h3>$(Esc $f.q)</h3>"); [void]$fq.AppendLine("<p>$(Esc $f.a)</p>")
      if ($f.PSObject.Properties.Name -contains 'link' -and $f.link) { [void]$fq.AppendLine("<p><a href=`"$(Rel $path $f.link)`">Read the full guide: $(Esc $hubData[$pathToId[[string]$f.link]].meta.h1)</a></p>") }
    }
    $secHtml.Insert(0, "<h2 id=`"questions`">Questions and answers</h2>`n$($fq.ToString())") | Out-Null
  }

  # --- related
  $rel = New-Object System.Text.StringBuilder
  $relLinksForMeta = @()
  if ($m.related) {
    [void]$rel.AppendLine('<ul>')
    foreach ($rid in $m.related) {
      $rp = $hubPages[$rid]; $rm = $hubData[$rid].meta
      $anchorText = $(if ($rm.PSObject.Properties.Name -contains 'anchor') { $rm.anchor } else { $rm.h1 })
      [void]$rel.AppendLine("<li><a href=`"$(Rel $path $rp.path)`">$(Esc $anchorText)</a></li>")
      $relLinksForMeta += @{ text = $anchorText; url = ($hubBase + $rp.path) }
    }
    [void]$rel.AppendLine('</ul>')
  }
  $siteLinksHtml = ''
  if ($m.PSObject.Properties.Name -contains 'siteLinks' -and $m.siteLinks) {
    $siteLinksHtml = '<p>On Pat''s main site:</p><ul>'
    foreach ($sl in $m.siteLinks) { $siteLinksHtml += "<li><a href=`"$($sl.url)`" rel=`"noopener`">$(Esc $sl.text)</a></li>"; $relLinksForMeta += @{ text = $sl.text; url = $sl.url } }
    $siteLinksHtml += '</ul>'
  }

  # --- sources
  $srcHtml = New-Object System.Text.StringBuilder
  foreach ($sid in @($m.sources)) {
    if ($sid.StartsWith('[PAT')) { [void]$srcHtml.AppendLine("<li>$(Esc $sid)</li>"); continue }
    $so = $srcs.$sid
    if (-not $so) { throw "Unknown source id '$sid' in $($p.id)" }
    [void]$srcHtml.AppendLine("<!-- SOURCE: $($so.url) | retrieved $($so.accessed) -->")
    [void]$srcHtml.AppendLine("<li><a href=`"$($so.url)`" rel=`"noopener`">$(Esc $so.title)</a>. Accessed $($so.accessed) ($(Esc $so.pageDate)).</li>")
    Add-Source $p.id $so.url $so.supports
  }
  # always cite Pat's own identity source
  Add-Source $p.id 'https://letstalkhomemortgage.com/' 'Identifiers, About Pat, footer disclosure'

  # --- header, breadcrumbs, byline
  $pillarRel = Rel $path '/adu-financing/'; $faqRel = Rel $path '/adu-financing/faq/'; $aboutRel = Rel $path '/about/pat-collins/'
  $funnelLink = "$funnelBase/?utm_source=adu-hub&utm_medium=organic&utm_campaign=hub-cta"
  if (-not $Production) { $funnelLink = ('../' * ((Depth $path) + 1)) + 'funnel/' }   # preview: link to the local funnel
  $header = @"
<header class="header">
  <div class="wrap">
    <a class="logo" href="$pillarRel" aria-label="Pat Collins, ADU financing guide">Pat Collins</a>
    <nav class="pill-nav" aria-label="Guide"><a href="$pillarRel">ADU guide</a><a href="$faqRel">FAQ</a><a href="$aboutRel">About Pat</a></nav>
    <div class="header__right"><a class="btn btn-sm" href="$funnelLink" rel="noopener">See my options</a></div>
  </div>
</header>
"@
  $crumbList = @(@{ name = "Let's Talk Home Mortgage"; url = "$hubBase/" })
  if ($isAuthor) { $crumbList += @{ name = 'About'; url = "$hubBase/about/pat-collins/" }; $crumbList += @{ name = 'Pat Collins'; url = $url } }
  elseif ($p.id -eq 'pillar') { $crumbList += @{ name = 'ADU financing'; url = $url } }
  else { $crumbList += @{ name = 'ADU financing'; url = "$hubBase/adu-financing/" }; $crumbList += @{ name = $m.h1; url = $url } }
  $crumbHtml = '<nav class="crumbs" aria-label="Breadcrumb">' + (($crumbList | ForEach-Object { if ($_.url -eq $url -or $_.url -eq "$hubBase/") { Esc $_.name } else { '<a href="' + (CrumbHref $_.url $path) + '">' + (Esc $_.name) + '</a>' } }) -join ' &rsaquo; ') + '</nav>'

  $byline = ''
  if (-not $isAuthor) {
    $byline = "<div class=`"byline`"><span>By <a href=`"$aboutRel`"><b>Pat Collins</b></a></span><span>NMLS #$($idn.person.nmls) &middot; DRE $($idn.person.dre)</span><span>Last reviewed: $(NiceDate $dateMod)</span></div>"
  } else {
    $byline = "<div class=`"byline`"><span>NMLS #$($idn.person.nmls) &middot; DRE $($idn.person.dre)</span><span>Last reviewed: $(NiceDate $dateMod)</span></div>"
  }
  $draft = ''
  if (-not $approved) { $draft = '<div class="draft-banner" role="note">DRAFT: not yet reviewed by compliance</div>' }
  $tocHtml = ''
  if ($toc.Count -ge 4) { $tocHtml = '<nav class="toc" aria-label="On this page"><strong>On this page</strong><ul>' + (($toc | ForEach-Object { '<li><a href="#' + $_.id + '">' + (Esc $_.text) + '</a></li>' }) -join '') + '</ul></nav>' }
  $answerHtml = "<div class=`"answer`"><b>Short answer</b>$(Esc $m.answer)</div>"

  $relBlock = ''
  if ($rel.Length -gt 0 -or $siteLinksHtml) { $relBlock = "<section class=`"related`" aria-labelledby=`"relq`"><h2 id=`"relq`">Related questions</h2>$($rel.ToString())$siteLinksHtml</section>" }
  $cta = "<aside class=`"cta-block`"><h2>Want to talk through your options?</h2><p>Answer a few questions and Pat will review the choices that fit your home and your project.</p><a class=`"btn btn-white`" href=`"$funnelLink`" rel=`"noopener`">See my financing options</a></aside>"
  $disc = "<p class=`"sources`" style=`"margin-top:28px`">$(Esc $idn.disclosure.standard) $(Esc $idn.disclosure.adu) This page is general education, not a quote or a commitment to lend.</p>"

  $articleInner = "$byline`n$tocHtml`n$answerHtml`n$($secHtml.ToString())`n$relBlock`n<section class=`"sources`" aria-labelledby=`"srcs`"><h2 id=`"srcs`">Sources</h2><ol>$($srcHtml.ToString())</ol></section>"
  $mainHtml = "<main id=`"main`"><article class=`"article`"><div class=`"narrow`">$crumbHtml<h1>$(Esc $m.h1)</h1>`n$articleInner`n$cta`n$disc</div></article></main>"

  # --- structured data
  $ptype = $(if ($isAuthor) { 'ProfilePage' } else { 'Article' })
  $ld = New-Graph $hubBase $url $ptype $titleTag ([string]$m.h1) $desc $datePub $dateMod $crumbList $faqData $true
  $robots = $(if ($noindex) { 'noindex, follow' } else { 'index, follow' })
  $head = Get-Head $titleTag $desc $url $robots $ld ($assetPrefix + 'site.css') $(if ($isAuthor) { 'profile' } else { 'article' })

  $bodyHtml = $draft + "`n" + $header + "`n" + $mainHtml + "`n" + (Get-Footer $assetPrefix $false ('../' * (Depth $path)).TrimEnd('/'))
  if ($gate) { $bodyHtml = "<!-- COMPLIANCE-GATE: $($p.gate) -->`n" + $bodyHtml }
  $page = "<!doctype html>`n<html lang=`"en`">`n<head>`n$head`n</head>`n<body>`n" + (Finish $bodyHtml) + "`n</body>`n</html>`n"
  Write-Text (Join-Path $outDir 'index.html') $page

  # --- WordPress export (body only, absolute links)
  $slug = ($path.Trim('/').Split('/') | Select-Object -Last 1)
  $wpBody = ($articleInner -replace 'href="(\.\./)+', ('href="' + $hubBase + '/'))
  $wpBody = "<article>`n$wpBody`n<aside><p>$(Esc $idn.disclosure.standard) $(Esc $idn.disclosure.adu)</p></aside>`n</article>"
  $wpBody = Finish $wpBody
  $wpDir = Join-Path $root 'hub\wordpress-ready'
  if (-not $Production) {
    Write-Text (Join-Path $wpDir ($slug + '.html')) $wpBody
    $ldJson = [regex]::Match($ld, '(?s)<script[^>]*>(.*)</script>').Groups[1].Value
    $metaObj = [ordered]@{ id = $p.id; title = $titleTag; metaDescription = $desc; slug = $slug; path = $path; canonical = $url; robots = $robots; lastReviewed = $dateMod; status = $(if ($approved) { 'approved' } else { 'draft: not yet reviewed by compliance' }); jsonLd = ($ldJson | ConvertFrom-Json); internalLinks = $relLinksForMeta }
    Write-Text (Join-Path $wpDir ($slug + '.meta.json')) ($metaObj | ConvertTo-Json -Depth 14)
  }
  [void]$built.Add($p.id)
  return @{ id = $p.id; path = $path; lastmod = $dateMod; noindex = $noindex }
}

function Build-Hub {
  $hubOut = Join-Path $dist 'hub'
  Copy-Assets $hubOut
  $entries = @()
  foreach ($p in $pagesCfg.hub) { $r = Build-HubPage $p; if ($r) { $entries += $r } }
  # sitemap (indexable pages only)
  $sm = New-Object System.Text.StringBuilder
  [void]$sm.AppendLine('<?xml version="1.0" encoding="UTF-8"?>')
  [void]$sm.AppendLine('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">')
  foreach ($e in $entries) { if (-not $e.noindex) { [void]$sm.AppendLine("  <url><loc>$hubBase$($e.path)</loc><lastmod>$($e.lastmod)</lastmod></url>") } }
  [void]$sm.AppendLine('</urlset>')
  Write-Text (Join-Path $hubOut 'sitemap.xml') $sm.ToString()
  $gpt = $(if ($cfg['ALLOW_GPTBOT']) { "User-agent: GPTBot`nAllow: /" } else { "User-agent: GPTBot`nDisallow: /" })
  Write-Text (Join-Path $hubOut 'robots.txt') (@"
# Hub (Asset B). Public and indexable. If the hub is deployed inside the main WordPress site, merge these rules into that site's robots.txt and add these URLs to its sitemap.
User-agent: *
Allow: /

User-agent: OAI-SearchBot
Allow: /

User-agent: Googlebot
Allow: /

$gpt

Sitemap: $hubBase/sitemap.xml
"@ + "`n")
}

Build-Funnel
Build-Hub

# ---------- preview index (dev builds only; never part of production) ----------
function Build-PreviewIndex {
  $rows = New-Object System.Text.StringBuilder
  $items = @([pscustomobject]@{ id = 'funnel'; title = 'Funnel page (financemyadu.io, noindex)'; href = 'funnel/'; group = 'Asset A: Funnel' })
  foreach ($p in $pagesCfg.hub) { $items += [pscustomobject]@{ id = $p.id; title = [string]$hubData[$p.id].meta.h1; href = ('hub' + $p.path); group = 'Asset B: Education hub' } }
  $lastGroup = ''
  foreach ($it in $items) {
    if ($it.group -ne $lastGroup) { [void]$rows.AppendLine("<tr><th colspan=`"3`" style=`"background:#eef3fa;text-align:left;padding:10px`">$($it.group)</th></tr>"); $lastGroup = $it.group }
    $file = Join-Path $dist (($it.href.Trim('/')).Replace('/', '\') + '\index.html')
    $ph = 0; if (Test-Path $file) { $ph = ([regex]::Matches((Read-Text $file), '\[PAT:')).Count }
    $gate = ''; if ($it.id -eq 'reverse-mortgage-for-adu') { $gate = ' <em>(compliance gate: noindex until approved)</em>' }
    $status = $(if (Test-Approved $approvals $it.id) { 'APPROVED' } else { 'DRAFT' })
    [void]$rows.AppendLine("<tr><td><a href=`"$($it.href)`">$(Esc $it.title)</a>$gate</td><td>$status</td><td>$ph</td></tr>")
  }
  $html = @"
<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Preview: ADU funnel and hub (not live)</title>
<meta name="robots" content="noindex, nofollow">
<style>body{font-family:Inter,system-ui,Segoe UI,sans-serif;max-width:900px;margin:32px auto;padding:0 20px;color:#172338;line-height:1.55}
h1{font-family:Georgia,serif}table{border-collapse:collapse;width:100%;margin:16px 0}td,th{border:1px solid #dbe3ee;padding:9px 12px}
.note{background:#fff6e0;border:1px solid #e8c26a;border-radius:8px;padding:12px 16px}a{color:#223d78}</style></head><body>
<h1>Preview: ADU funnel and education hub</h1>
<p class="note"><strong>Not live.</strong> Local draft build for review. Yellow highlights are <code>[PAT: ...]</code> placeholders waiting for your input. Nothing here is approved by compliance, and the form is not connected.</p>
<table><thead><tr><th style="text-align:left">Page</th><th>Status</th><th>Open placeholders</th></tr></thead><tbody>
$($rows.ToString())</tbody></table>
<p>Flags in this build: reverse mortgage section <strong>$(if ($cfg['SHOW_REVERSE_SECTION']) { 'shown' } else { 'hidden' })</strong>, worked example <strong>$(if ($cfg['SHOW_EXAMPLE']) { 'shown' } else { 'hidden' })</strong>, analytics <strong>$(if ([string]$cfg['ANALYTICS_ID']) { 'configured but off until a visitor accepts' } else { 'not configured' })</strong>. Built $today.</p>
</body></html>
"@
  Write-Text (Join-Path $dist 'index.html') $html
}
if (-not $Production) { Build-PreviewIndex }

# ---------- docs/SOURCE-MAP.md (regenerated every build) ----------
$sm = New-Object System.Text.StringBuilder
[void]$sm.AppendLine('# Source map')
[void]$sm.AppendLine('')
[void]$sm.AppendLine("Generated by `scripts/build.ps1` on every build. Every fact filled from Pat's website or an outside official source is listed here with its URL and retrieval date. Preflight fails if a `<!-- SOURCE: url | retrieved date -->` comment in the output has no matching entry.")
[void]$sm.AppendLine('')
[void]$sm.AppendLine('## Filled from letstalkhomemortgage.com (retrieved 2026-10-23)')
[void]$sm.AppendLine('| Fact | Value | Source URL | Retrieved |')
[void]$sm.AppendLine('|---|---|---|---|')
$rows = @(
  @('Individual NMLS', $idn.person.nmls, 'https://letstalkhomemortgage.com/'),
  @('Company and NMLS', "$($idn.company.name), NMLS $($idn.company.nmls)", 'https://letstalkhomemortgage.com/'),
  @('Company address', $idn.company.address, 'https://letstalkhomemortgage.com/'),
  @('Phone', $idn.contact.phone, 'https://letstalkhomemortgage.com/contact-us/'),
  @('Email', $idn.contact.email, 'https://letstalkhomemortgage.com/contact-us/'),
  @('Booking link', $idn.contact.bookingUrl, 'https://letstalkhomemortgage.com/contact-us/'),
  @('Application link (not used until Pat confirms)', $idn.contact.applicationUrl, 'https://letstalkhomemortgage.com/contact-us/'),
  @('NMLS Consumer Access link', $idn.contact.nmlsConsumerAccess, 'https://letstalkhomemortgage.com/'),
  @('Facebook profile (sameAs)', $idn.social.facebook, 'https://letstalkhomemortgage.com/'),
  @('Footer disclosure text', 'This is not a commitment to lend...', 'https://letstalkhomemortgage.com/'),
  @('About Pat, audiences, principles, process, FAQ answers', 'see source/extract.json', 'https://letstalkhomemortgage.com/'),
  @('Logo, Equal Housing and AIME images', 'assets/ folder', 'https://letstalkhomemortgage.com/')
)
foreach ($r in $rows) { [void]$sm.AppendLine("| $($r[0]) | $($r[1]) | $($r[2]) | 2026-10-23 |") }
[void]$sm.AppendLine('| Google rating and three review summaries (E Mortgage Capital, Inc.) | rating, review count, initials, relative dates, paraphrased summaries (src/data/google-reviews.json) | Google Maps profile, opened in the browser | 2026-10-24 |')
[void]$sm.AppendLine('')
[void]$sm.AppendLine('## Stated by Pat in the build brief (not on the website)')
[void]$sm.AppendLine('- "30+ years in mortgages" and "Licensed in California" in the trust strip (brief section 7). The website says "decades in business, sales, real estate".')
[void]$sm.AppendLine('- Renovation financing: Pat does offer it (chat 2026-10-23: "I do renovations"). The website lists no renovation or construction loan. Which programs Pat offers is still a placeholder.')
[void]$sm.AppendLine('- DRE #02143449: confirmed by Pat in chat on 2026-10-23 (the website footer shows the same number with the label "BRE"). Compliance to confirm the label.')
[void]$sm.AppendLine('- Analytics: reuse Google Tag Manager container GTM-TQ8C7WLM (Pat, chat 2026-10-23; the ID is visible in the website source). GPTBot: allow (Pat, chat 2026-10-23).')
[void]$sm.AppendLine('')
[void]$sm.AppendLine('## Sources used per page')
[void]$sm.AppendLine('| Page | Source URL | What it supports | Retrieved |')
[void]$sm.AppendLine('|---|---|---|---|')
foreach ($u in ($sourceUse | Sort-Object page, url -Unique)) { [void]$sm.AppendLine("| $($u.page) | $($u.url) | $($u.what) | 2026-10-23 |") }
[void]$sm.AppendLine('')
[void]$sm.AppendLine('## Official sources registry')
foreach ($prop in $srcs.PSObject.Properties) { if ($prop.Name.StartsWith('_')) { continue }; $s = $prop.Value; [void]$sm.AppendLine("- **$($prop.Name)**: [$($s.title)]($($s.url)), accessed $($s.accessed), $($s.pageDate).") }
Write-Text (Join-Path $root 'docs\SOURCE-MAP.md') $sm.ToString()

Write-Host ("Built: " + ($built -join ', '))
if ($skipped.Count) { Write-Host ("Skipped in production: " + ($skipped -join '; ')) }
Write-Host ("Mode: " + $(if ($Production) { 'PRODUCTION' } else { 'DEV' }))
