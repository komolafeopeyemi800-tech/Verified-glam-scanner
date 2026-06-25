# Verify which Firebase JSON file is for Supabase vs Android (no secrets uploaded).
param(
  [string]$AdminSdkPath = "C:\Users\zenit\Downloads\verified-glam-firebase-adminsdk-fbsvc-0e18943006.json",
  [string]$GoogleServicesPath = "C:\Users\zenit\Downloads\google-services (1).json"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$repoGoogle = Join-Path $Root "android\app\google-services.json"

Write-Host "FCM credential check" -ForegroundColor Cyan

if (Test-Path $AdminSdkPath) {
  $a = Get-Content $AdminSdkPath -Raw | ConvertFrom-Json
  if ($a.type -eq "service_account") {
    Write-Host "[OK] Admin SDK -> Supabase FCM_SERVICE_ACCOUNT_JSON" -ForegroundColor Green
    Write-Host "     project_id=$($a.project_id)"
    Write-Host "     $($AdminSdkPath)"
  } else {
    Write-Host "[FAIL] Not a service account JSON" -ForegroundColor Red
  }
} else {
  Write-Host "[MISSING] Admin SDK: $AdminSdkPath" -ForegroundColor Red
}

if (Test-Path $GoogleServicesPath) {
  $g = Get-Content $GoogleServicesPath -Raw | ConvertFrom-Json
  if ($g.project_info -and $g.client) {
    $pkg = $g.client[0].client_info.android_client_info.package_name
    Write-Host "[OK] google-services -> android/app only (package=$pkg)" -ForegroundColor Green
  }
} else {
  Write-Host "[SKIP] google-services not at $GoogleServicesPath" -ForegroundColor Yellow
}

if (Test-Path $repoGoogle) {
  Write-Host "[OK] Repo android/app/google-services.json present" -ForegroundColor Green
}

Write-Host ""
Write-Host "Next: add SUPABASE_ACCESS_TOKEN to .env, then .\scripts\setup-fcm-push.ps1"
