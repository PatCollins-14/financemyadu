# Builds measurement/question-panel.csv from measurement/questions.txt (25 questions x 5 platforms).
. "$PSScriptRoot\lib.ps1"
$root = Get-Root
$qs = (Read-Text (Join-Path $root 'measurement\questions.txt')) -split "`r?`n" | Where-Object { $_.Trim() }
$plats = @('ChatGPT', 'Gemini', 'Claude', 'Perplexity', 'Google AI Mode')
$rows = foreach ($q in $qs) { foreach ($p in $plats) { [pscustomobject]@{ question = $q; platform = $p; run_number = ''; date = ''; mentioned = ''; cited_url = ''; notes = '' } } }
$rows | Export-Csv -Path (Join-Path $root 'measurement\question-panel.csv') -NoTypeInformation -Encoding UTF8
Write-Host "question-panel.csv: $($rows.Count) rows ($($qs.Count) questions x $($plats.Count) platforms). Columns: mentioned = Y/N; run several times per platform."
