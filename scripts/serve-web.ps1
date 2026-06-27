# Serve production-like build/web (static Tier 1 + Flutter 404 fallback for /app/*)
param(
  [int]$Port = 8080
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Out = Join-Path $Root "build\web"

if (-not (Test-Path (Join-Path $Out "pricing\index.html"))) {
  Write-Error "Missing static pages in build/web. Run .\scripts\build-web.ps1 first."
}

Write-Host "Static-first web: http://127.0.0.1:$Port"
Write-Host "Tier 1 pages (/, /pricing, tool slugs) = instant HTML"
Write-Host "/app/* uses Flutter shell via 404.html fallback"
Write-Host "Tip: use http://127.0.0.1:$Port/ (not /web/) — homepage is at /"

# Explicit path + listen URI — avoids serve showing a directory listing at /
& npx --yes serve $Out --listen "tcp://127.0.0.1:$Port"
