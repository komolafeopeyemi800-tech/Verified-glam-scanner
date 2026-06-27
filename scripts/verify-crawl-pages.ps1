# Verify static marketing pages exist in build/web for crawler/Polar review.
param(
  [string]$BuildDir = ""
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
if ([string]::IsNullOrWhiteSpace($BuildDir)) {
  $BuildDir = Join-Path $Root "build\web"
}

$required = @(
  "index.html",
  "pricing\index.html",
  "about\index.html",
  "privacy\index.html",
  "terms\index.html",
  "login\index.html",
  "register\index.html",
  "tools\index.html",
  "face-beauty-analysis\index.html",
  "seasonal-color-palette\index.html",
  "beauty-routine-challenge\index.html",
  "beauty-tips\index.html",
  "celebrity-look-alike\index.html",
  "facial-symmetry\index.html",
  "beauty-score-showdown\index.html",
  "face-comparison\index.html",
  "attractiveness-test\index.html",
  "face-golden-ratio\index.html",
  "404.html",
  "_redirects",
  "sitemap.xml",
  "robots.txt",
  "llms.txt"
)

$missing = @()
foreach ($rel in $required) {
  $path = Join-Path $BuildDir $rel
  if (-not (Test-Path $path)) {
    $missing += $rel
  }
}

if ($missing.Count -gt 0) {
  Write-Error "Missing static files in ${BuildDir}:`n$($missing -join "`n")`nRun: .\scripts\build-web.ps1"
}

$index = Get-Content (Join-Path $BuildDir "index.html") -Raw
if ($index -match 'flutter_bootstrap\.js') {
  Write-Error "build/web/index.html is the Flutter shell. Run sync-static-site after flutter build web."
}
if ($index -notmatch 'Verified Glam Scanner') {
  Write-Error "build/web/index.html does not contain marketing content."
}

Write-Host "Crawl check passed: $($required.Count) static paths present in $BuildDir"
