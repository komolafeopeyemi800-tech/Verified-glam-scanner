# One-shot FCM HTTP v1 setup: secret, deploy push functions, migration hint, cron reminder.
# Prerequisite: SUPABASE_ACCESS_TOKEN in .env (https://supabase.com/dashboard/account/tokens)
#
# Usage:
#   .\scripts\setup-fcm-push.ps1
#   .\scripts\setup-fcm-push.ps1 -JsonPath "C:\Users\zenit\Downloads\verified-glam-firebase-adminsdk-fbsvc-0e18943006.json"
param(
  [string]$JsonPath = "C:\Users\zenit\Downloads\verified-glam-firebase-adminsdk-fbsvc-0e18943006.json",
  [string]$ProjectRef = "qmivgvctmxvpnbouqslj",
  [string]$AccessToken = "",
  [switch]$SkipSecret,
  [switch]$SkipDeploy
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root
. (Join-Path $Root "scripts\_Load-SupabaseToken.ps1") -AccessToken $AccessToken -Root $Root
if (-not $SkipSecret -and -not $SkipDeploy) {
  & (Join-Path $Root "scripts\check-supabase-cli-ready.ps1") -AccessToken $AccessToken
} elseif (-not $SkipDeploy -and $SkipSecret) {
  . (Join-Path $Root "scripts\_Load-SupabaseToken.ps1") -AccessToken $AccessToken -Root $Root
  if (-not (Test-SupabaseAccessToken)) {
    Write-Error "Deploy requires SUPABASE_ACCESS_TOKEN in .env or -AccessToken"
  }
}

Write-Host "=== FCM push setup (verified-glam) ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Credential files:"
Write-Host "  USE for Supabase:  $JsonPath  (type=service_account)"
Write-Host "  NOT for Supabase:  google-services.json  -> android/app only (already in repo)"
Write-Host ""

if (-not $SkipSecret) {
  if (-not (Test-Path $JsonPath)) {
    Write-Error "Admin SDK JSON not found: $JsonPath`nDownload from Firebase -> Service accounts -> Generate new private key."
  }
  & (Join-Path $Root "scripts\set-fcm-service-account-secret.ps1") -JsonPath $JsonPath -ProjectRef $ProjectRef -AccessToken $AccessToken
} else {
  Write-Host "Skipped secret upload (-SkipSecret)." -ForegroundColor Yellow
}

if (-not $SkipDeploy) {
  & (Join-Path $Root "scripts\deploy-challenge-push-functions.ps1") -ProjectRef $ProjectRef -AccessToken $AccessToken
} else {
  Write-Host "Skipped deploy (-SkipDeploy)." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Manual steps (Dashboard) ===" -ForegroundColor Cyan
Write-Host "1. If secret upload failed: Edge Functions -> Secrets -> FCM_SERVICE_ACCOUNT_JSON"
Write-Host "   Paste full contents of: $JsonPath"
Write-Host "2. SQL Editor: run supabase/migrations/007_notification_streak_kind.sql"
Write-Host "   Or: .\scripts\apply-migration-007.ps1"
Write-Host "3. Edge Functions -> dispatch-challenge-notifications -> Schedules -> every 10 minutes"
Write-Host "4. Device test: .\tools\test-challenge-push-dispatch.ps1  then mark a day done on phone"
Write-Host ""
Write-Host "See docs/FCM_PUSH_SETUP.md for the full checklist."
