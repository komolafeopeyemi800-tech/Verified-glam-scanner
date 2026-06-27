# Full production build + crawl verification (run before Cloudflare deploy / Polar appeal).
param(
  [switch]$Deploy
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

Write-Host "==> Flutter web build + static marketing overlay"
& (Join-Path $Root "scripts\build-web.ps1")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "==> Verify crawl-ready pages"
& (Join-Path $Root "scripts\verify-crawl-pages.ps1")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if ($Deploy) {
  Write-Host "==> Deploy with Wrangler"
  Set-Location $Root
  npx wrangler deploy
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
  Write-Host "Deploy complete."
} else {
  Write-Host "Build verified. Deploy with: npx wrangler deploy"
  Write-Host "Or push to GitHub so Cloudflare runs: bash scripts/cloudflare-build.sh"
}
