# Serve the static marketing site locally (default http://localhost:3000)
param(
  [int]$Port = 3000
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Website = Join-Path $Root "website"

Write-Host "Marketing site: http://localhost:$Port"
Write-Host "Flutter web app: run .\scripts\run-web-dev.ps1 in another terminal (http://localhost:8080)"
Set-Location $Website
npx --yes serve -l $Port
