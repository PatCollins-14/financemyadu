# Draws the FinanceMyADU favicon set from the same shapes as assets/favicon.svg:
# favicon.ico (16, 32, 48), apple-touch-icon.png (180), icon-192.png and icon-512.png into assets/.
Add-Type -AssemblyName System.Drawing
. "$PSScriptRoot\lib.ps1"
$root = Get-Root; $out = Join-Path $root 'assets'
function New-Color([string]$hex) { [System.Drawing.ColorTranslator]::FromHtml($hex) }
function Draw-Icon([int]$size, [bool]$rounded) {
  $ss = 8; $S = $size * $ss; $k = $S / 64.0
  $bmp = New-Object System.Drawing.Bitmap($S, $S, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($bmp); $g.SmoothingMode = 'AntiAlias'; $g.PixelOffsetMode = 'HighQuality'
  function P([double[]]$xy) { $pts = @(); for ($i = 0; $i -lt $xy.Length; $i += 2) { $pts += New-Object System.Drawing.PointF([single]($xy[$i] * $k), [single]($xy[$i + 1] * $k)) }; return , $pts }
  # background
  $rect = New-Object System.Drawing.RectangleF(0, 0, $S, $S)
  $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, (New-Color '#2c4d95'), (New-Color '#1a2f5f'), 45)
  if ($rounded) {
    $r = 14 * $k; $gp = New-Object System.Drawing.Drawing2D.GraphicsPath
    $gp.AddArc(0, 0, 2 * $r, 2 * $r, 180, 90); $gp.AddArc($S - 2 * $r, 0, 2 * $r, 2 * $r, 270, 90)
    $gp.AddArc($S - 2 * $r, $S - 2 * $r, 2 * $r, 2 * $r, 0, 90); $gp.AddArc(0, $S - 2 * $r, 2 * $r, 2 * $r, 90, 90); $gp.CloseFigure()
    $g.FillPath($bg, $gp)
  } else { $g.FillRectangle($bg, 0, 0, $S, $S) }
  $white = New-Object System.Drawing.SolidBrush((New-Color '#ffffff')); $navy = New-Color '#223d78'; $navyB = New-Object System.Drawing.SolidBrush($navy)
  $gold = New-Object System.Drawing.Drawing2D.LinearGradientBrush((New-Object System.Drawing.RectangleF((34 * $k), (29 * $k), (26 * $k), (25 * $k))), (New-Color '#f6c443'), (New-Color '#dfa529'), 45)
  # main home
  $g.FillPolygon($white, (P @(6, 33, 24, 15, 42, 33)))
  $g.FillRectangle($white, (10 * $k), (32 * $k), (28 * $k), (22 * $k))
  $g.FillRectangle($navyB, (20 * $k), (40 * $k), (8 * $k), (14 * $k))
  # ADU
  $pen = New-Object System.Drawing.Pen($navy, [single](2 * $k)); $pen.LineJoin = 'Round'
  $g.FillPolygon($gold, (P @(34, 42, 47, 29, 60, 42))); $g.DrawPolygon($pen, (P @(34, 42, 47, 29, 60, 42)))
  $g.FillRectangle($gold, (37 * $k), (41 * $k), (20 * $k), (13 * $k)); $g.DrawRectangle($pen, (37 * $k), (41 * $k), (20 * $k), (13 * $k))
  $g.FillRectangle($navyB, (44 * $k), (46 * $k), (6 * $k), (8 * $k))
  $g.Dispose()
  $small = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g2 = [System.Drawing.Graphics]::FromImage($small); $g2.InterpolationMode = 'HighQualityBicubic'; $g2.SmoothingMode = 'HighQuality'; $g2.PixelOffsetMode = 'HighQuality'
  $g2.DrawImage($bmp, 0, 0, $size, $size); $g2.Dispose(); $bmp.Dispose()
  return $small
}
function Save-Png($bmp, [string]$path) { $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png) }
Save-Png (Draw-Icon 180 $false) (Join-Path $out 'apple-touch-icon.png')
Save-Png (Draw-Icon 192 $true) (Join-Path $out 'icon-192.png')
Save-Png (Draw-Icon 512 $true) (Join-Path $out 'icon-512.png')
# favicon.ico with PNG-compressed 16, 32 and 48 px images
$sizes = 16, 32, 48; $blobs = @()
foreach ($s in $sizes) { $ms = New-Object System.IO.MemoryStream; (Draw-Icon $s $true).Save($ms, [System.Drawing.Imaging.ImageFormat]::Png); $blobs += , $ms.ToArray() }
$ico = New-Object System.IO.MemoryStream; $w = New-Object System.IO.BinaryWriter($ico)
$w.Write([uint16]0); $w.Write([uint16]1); $w.Write([uint16]$sizes.Count)
$offset = 6 + 16 * $sizes.Count
for ($i = 0; $i -lt $sizes.Count; $i++) { $s = $sizes[$i]; $w.Write([byte]$s); $w.Write([byte]$s); $w.Write([byte]0); $w.Write([byte]0); $w.Write([uint16]1); $w.Write([uint16]32); $w.Write([uint32]$blobs[$i].Length); $w.Write([uint32]$offset); $offset += $blobs[$i].Length }
foreach ($b in $blobs) { $w.Write($b) }
[System.IO.File]::WriteAllBytes((Join-Path $out 'favicon.ico'), $ico.ToArray())
Write-Host 'favicon set written to assets/'
