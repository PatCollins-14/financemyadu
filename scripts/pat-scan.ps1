# Lists every [PAT: ...] placeholder in the source files (file and line) and writes the table into docs/PAT-INPUTS.md
# between the PAT-SCAN markers.
. "$PSScriptRoot\lib.ps1"
$root = Get-Root
$rows = New-Object System.Collections.ArrayList
$scan = @('src\funnel', 'src\hub\pages', 'src\data', 'src\assets', 'scripts\build.ps1', 'ads', 'config')
foreach ($s in $scan) {
  $p = Join-Path $root $s
  if (-not (Test-Path $p)) { continue }
  $files = @(); if ((Get-Item $p).PSIsContainer) { $files = Get-ChildItem $p -Recurse -File -Include '*.html', '*.json', '*.md', '*.js', '*.css', '*.csv' } else { $files = @(Get-Item $p) }
  foreach ($f in $files) {
    $n = 0
    foreach ($line in (Get-Content $f.FullName -Encoding UTF8)) {
      $n++
      foreach ($m in [regex]::Matches($line, '\[PAT:[^\]]*\]')) {
        $rel = $f.FullName.Substring($root.Length + 1).Replace('\', '/')
        [void]$rows.Add([pscustomobject]@{ file = $rel; line = $n; text = $m.Value })
      }
    }
  }
}
$byFile = $rows | Group-Object file | Sort-Object Name
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("Total placeholders in source: **$($rows.Count)** across $($byFile.Count) files (a placeholder in a shared footer or template shows on every page that uses it).")
[void]$sb.AppendLine('')
[void]$sb.AppendLine('| Count | File |')
[void]$sb.AppendLine('|---|---|')
foreach ($g in $byFile) { [void]$sb.AppendLine("| $($g.Count) | $($g.Name) |") }
[void]$sb.AppendLine('')
[void]$sb.AppendLine('| File | Line | Placeholder |')
[void]$sb.AppendLine('|---|---|---|')
foreach ($r in ($rows | Sort-Object file, line)) { [void]$sb.AppendLine("| $($r.file) | $($r.line) | $(($r.text -replace '\|', '/')) |") }
$path = Join-Path $root 'docs\PAT-INPUTS.md'
$doc = Read-Text $path
$new = [regex]::Replace($doc, '(?s)<!-- PAT-SCAN:START -->.*?<!-- PAT-SCAN:END -->', ('<!-- PAT-SCAN:START -->' + "`n" + $sb.ToString() + '<!-- PAT-SCAN:END -->'))
Write-Text $path $new
Write-Host "PAT scan: $($rows.Count) placeholders in $($byFile.Count) files"
