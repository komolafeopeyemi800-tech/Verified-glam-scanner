# Serve production-like build/web (static Tier 1 + Flutter 404 fallback for /app/*)
param(
  [int]$Port = 8080
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Out = Join-Path $Root "build\web"
$ServerScript = Join-Path $Root "scripts\local-web-server.mjs"

if (-not (Test-Path (Join-Path $Out "pricing\index.html"))) {
  Write-Error "Missing static pages in build/web. Run .\scripts\build-web.ps1 first."
}

Write-Host "Static-first web: http://127.0.0.1:$Port"
Write-Host "Tier 1 pages (/, /pricing, tool slugs) = instant HTML"
Write-Host "/app/* uses Flutter shell via 404.html (internal rewrite, no proxy loop)"
Write-Host "Credits dashboard: http://127.0.0.1:$Port/app/profile"
Write-Host ""
Write-Host "If login shows HTTP 431, clear site data for 127.0.0.1 in your browser."
Write-Host ""
Write-Host "Press Ctrl+C to stop."

foreach ($procId in @(
    Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue |
      ForEach-Object { $_.OwningProcess } | Where-Object { $_ -gt 0 } | Select-Object -Unique
  )) {
  Write-Host "Stopping existing listener on port $Port (PID $procId)..."
  Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
}
Start-Sleep -Milliseconds 400

$env:PORT = "$Port"
$env:HOST = "127.0.0.1"
$env:NODE_OPTIONS = "--max-http-header-size=65536"

Push-Location $Out
try {
  node $ServerScript
} finally {
  Pop-Location
}
