# Local preview server (dev utility). Usage: powershell -File scripts\serve.ps1 -Dir dist\funnel -Port 8771
param([string]$Dir = 'dist', [int]$Port = 8771)
$root = (Resolve-Path $Dir).Path
$mime = @{ '.html'='text/html; charset=utf-8'; '.css'='text/css'; '.js'='application/javascript'; '.png'='image/png'; '.webp'='image/webp'; '.xml'='application/xml'; '.txt'='text/plain; charset=utf-8'; '.json'='application/json' }
$l = New-Object System.Net.HttpListener
$l.Prefixes.Add("http://localhost:$Port/")
$l.Start()
while ($l.IsListening) {
  $c = $l.GetContext()
  $p = [Uri]::UnescapeDataString($c.Request.Url.LocalPath).TrimStart('/')
  # Dev utility: POST /__save/<name> writes the body to $env:SAVE_DIR\<name> (safe file names only, localhost only).
  if ($c.Request.HttpMethod -eq 'POST' -and $p -like '__save/*' -and $env:SAVE_DIR) {
    $n = $p.Substring(7)
    if ($n -match '^[A-Za-z0-9._-]+$') {
      $sr = New-Object System.IO.StreamReader($c.Request.InputStream, [Text.Encoding]::UTF8)
      [IO.File]::WriteAllText((Join-Path $env:SAVE_DIR $n), $sr.ReadToEnd(), (New-Object Text.UTF8Encoding($false)))
      $c.Response.StatusCode = 200
    } else { $c.Response.StatusCode = 400 }
    $c.Response.AddHeader('Access-Control-Allow-Origin', '*')
    $c.Response.Close(); continue
  }
  if ($c.Request.HttpMethod -eq 'OPTIONS') { $c.Response.AddHeader('Access-Control-Allow-Origin', '*'); $c.Response.AddHeader('Access-Control-Allow-Methods', 'POST'); $c.Response.AddHeader('Access-Control-Allow-Headers', '*'); $c.Response.StatusCode = 204; $c.Response.Close(); continue }
  $f = Join-Path $root $p
  if (Test-Path $f -PathType Container) { $f = Join-Path $f 'index.html' }
  if (Test-Path $f -PathType Leaf) {
    $b = [IO.File]::ReadAllBytes($f)
    $ext = [IO.Path]::GetExtension($f).ToLower()
    $c.Response.ContentType = $(if ($mime.ContainsKey($ext)) { $mime[$ext] } else { 'application/octet-stream' })
    $c.Response.OutputStream.Write($b, 0, $b.Length)
  } else { $c.Response.StatusCode = 404 }
  $c.Response.Close()
}
