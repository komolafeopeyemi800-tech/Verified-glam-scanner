# Pre-flight before FCM setup / deploy scripts.
param([string]$AccessToken = "")

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
. (Join-Path $Root "scripts\_Load-SupabaseToken.ps1") -AccessToken $AccessToken -Root $Root

$ok = $true
Write-Host "Supabase CLI pre-flight" -ForegroundColor Cyan

if (Test-SupabaseAccessToken) {
  Write-Host "[OK] SUPABASE_ACCESS_TOKEN loaded" -ForegroundColor Green
} else {
  Write-Host "[FAIL] SUPABASE_ACCESS_TOKEN missing" -ForegroundColor Red
  $envPath = Join-Path $Root ".env"
  if (Test-Path $envPath) {
    $raw = Get-Content $envPath -Raw
    if ($raw -match '(?m)^#\s*SUPABASE_ACCESS_TOKEN=') {
      Write-Host "  Fix: In .env, remove the # at the start of the SUPABASE_ACCESS_TOKEN line and paste your real sbp_ token." -ForegroundColor Yellow
    } elseif ($raw -match '(?m)^SUPABASE_ACCESS_TOKEN=sbp_paste') {
      Write-Host "  Fix: Replace the placeholder value with your real token from Account -> Tokens." -ForegroundColor Yellow
    }
  }
  Write-Host "  Token URL: https://supabase.com/dashboard/account/tokens (NOT the project anon key)" -ForegroundColor Yellow
  $ok = $false
}

$envPath = Join-Path $Root ".env"
if (Test-Path $envPath) {
  $content = Get-Content $envPath -Raw
  if ($content -match "SUPABASE_URL=https://qmivgvctmxvpnbouqslj") {
    Write-Host "[OK] SUPABASE_URL in .env" -ForegroundColor Green
  }
  if ($content -match "SUPABASE_ANON_KEY=sb_") {
    Write-Host "[OK] SUPABASE_ANON_KEY in .env" -ForegroundColor Green
  }
} else {
  Write-Host "[FAIL] .env missing" -ForegroundColor Red
  $ok = $false
}

$adminSdk = "C:\Users\zenit\Downloads\verified-glam-firebase-adminsdk-fbsvc-0e18943006.json"
if (Test-Path $adminSdk) {
  Write-Host "[OK] Firebase Admin SDK JSON found" -ForegroundColor Green
} else {
  Write-Host "[WARN] Admin SDK not at default Downloads path" -ForegroundColor Yellow
}

if (-not $ok) { exit 1 }
Write-Host "Ready for .\scripts\setup-fcm-push.ps1"
