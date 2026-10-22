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
