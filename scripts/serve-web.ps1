# Serve release build/web (static marketing + Flutter app on /app/*)
param(
  [int]$Port = 8080
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Out = Join-Path $Root "build\web"

if (-not (Test-Path (Join-Path $Out "main.dart.js"))) {
  Write-Host "No build/web — running build-web.ps1 first..."
  & (Join-Path $Root "scripts\build-web.ps1")
}

Write-Host "Static marketing + Flutter app: http://127.0.0.1:$Port"
Write-Host "Tier 1 pages (/, /tools, tool slugs, legal) = instant static HTML"
Write-Host "App routes (/app/*) = Flutter (prefetched from marketing pages)"
Set-Location $Out
npx --yes serve -s -l $Port
