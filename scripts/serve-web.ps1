# Serve release build/web (fastest for local testing — run build-web.ps1 first if stale)
param(
  [int]$Port = 8080
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Out = Join-Path $Root "build\web"

if (-not (Test-Path (Join-Path $Out "main.dart.js"))) {
  Write-Error "Missing build/web. Run .\scripts\build-web.ps1 first."
}

Write-Host "Flutter web (release build): http://127.0.0.1:$Port"
Write-Host "SPA mode: deep links like /login and /facial-symmetry fall back to index.html"
Write-Host "Homepage: Flutter header + original HTML embed at / (no public /marketing/ URLs)"
Write-Host "Legal pages: Flutter routes at /about, /privacy, /terms"
Write-Host "First load may take 10-20 seconds while the browser parses main.dart.js"
Set-Location $Out
& (Join-Path $Root "scripts\sync-marketing-web.ps1")
$staticDest = Join-Path $Out "_static\home"
$legacyMarketing = Join-Path $Out "marketing"
if (Test-Path $legacyMarketing) { Remove-Item $legacyMarketing -Recurse -Force }
if (Test-Path $staticDest) { Remove-Item $staticDest -Recurse -Force }
New-Item -ItemType Directory -Path (Split-Path $staticDest) -Force | Out-Null
Copy-Item (Join-Path $Root "web\_static\home") $staticDest -Recurse
foreach ($seoFile in @("_redirects", "robots.txt", "sitemap.xml", "llms.txt")) {
  $src = Join-Path $Root "website\$seoFile"
  if (Test-Path $src) {
    Copy-Item -Force $src (Join-Path $Out $seoFile)
  }
}
$serveJson = Join-Path $Root "web\serve.json"
if (Test-Path $serveJson) {
  Copy-Item -Force $serveJson (Join-Path $Out "serve.json")
}
if ((Test-Path (Join-Path $Out "app_shell.html")) -and -not (Test-Path (Join-Path $Out "index.html"))) {
  Copy-Item -Force (Join-Path $Out "app_shell.html") (Join-Path $Out "index.html")
}
npx --yes serve -s -l $Port
