# Pre-push production gate - mirrors Cloudflare build checks without deploying.
param(
  [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

Write-Host "=== Production readiness check ===" -ForegroundColor Cyan

if (-not $SkipBuild) {
  & (Join-Path $Root "scripts\deploy-cloudflare.ps1")
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

$buildWeb = Join-Path $Root "build\web"
$authConfig = Join-Path $buildWeb "js\auth-config.js"

if (-not (Test-Path $authConfig)) {
  Write-Error "Missing build/web/js/auth-config.js - run build first."
}

$cfg = Get-Content $authConfig -Raw
$bad = @()
if ($cfg -match '__SUPABASE_URL__') { $bad += '__SUPABASE_URL__' }
if ($cfg -match '__SUPABASE_ANON_KEY__') { $bad += '__SUPABASE_ANON_KEY__' }
if ($cfg -match '__POLAR_CHECKOUT_LINK_ANNUAL__') { $bad += '__POLAR_CHECKOUT_LINK_ANNUAL__' }
if ($cfg -match '__POLAR_CHECKOUT_LINK_PRO_WEEKLY__') { $bad += '__POLAR_CHECKOUT_LINK_PRO_WEEKLY__' }
if ($bad.Count -gt 0) {
  Write-Error "auth-config.js has unresolved placeholders: $($bad -join ', ')"
}

if (Test-Path (Join-Path $buildWeb "_redirects")) {
  Write-Error "build/web/_redirects exists - wrangler will loop (error 100324)."
}
if (Test-Path (Join-Path $buildWeb "serve.json")) {
  Write-Error "build/web/serve.json exists - wrangler converts redirects and loops (error 100324)."
}

Write-Host ""
Write-Host "Cloudflare dashboard env (Production):" -ForegroundColor Yellow
Write-Host "  SUPABASE_URL, SUPABASE_ANON_KEY (required)"
Write-Host "  GOOGLE_WEB_CLIENT_ID (optional)"
Write-Host "  POLAR_CHECKOUT_LINK_ANNUAL / PRO_WEEKLY (optional - defaults from .env.example)"
Write-Host ""
Write-Host "Build command: bash scripts/cloudflare-build.sh"
Write-Host "Deploy command: npx wrangler deploy"
Write-Host ""
Write-Host "Supabase Edge secrets in Dashboard not in Git:" -ForegroundColor Yellow
Write-Host "  POLAR_ACCESS_TOKEN, POLAR_WEBHOOK_SECRET, POLAR_ENV=production, etc."
Write-Host "  Webhook: https://qmivgvctmxvpnbouqslj.supabase.co/functions/v1/polar-webhook"
Write-Host ""
& (Join-Path $Root "scripts\test-polar-integration.ps1")
Write-Host ""
Write-Host "=== Ready for Git push + Cloudflare ===" -ForegroundColor Green
