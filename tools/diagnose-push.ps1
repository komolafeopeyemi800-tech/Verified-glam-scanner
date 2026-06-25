# Diagnose FCM push: secret upload, deploy, dispatch test with error details.
param(
  [string]$JsonPath = "C:\Users\zenit\Downloads\verified-glam-firebase-adminsdk-fbsvc-0e18943006.json"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

Write-Host "=== Push diagnosis (FCM HTTP v1 only, legacy API disabled) ===" -ForegroundColor Cyan
Write-Host ""

& (Join-Path $Root "scripts\set-fcm-service-account-secret.ps1") -JsonPath $JsonPath
& (Join-Path $Root "scripts\deploy-challenge-push-functions.ps1")

Write-Host ""
Write-Host "Running dispatch test..." -ForegroundColor Cyan
& (Join-Path $Root "tools\test-challenge-push-dispatch.ps1")

Write-Host ""
Write-Host "If failed > 0 and lastFailure shows 'No active FCM tokens':" -ForegroundColor Yellow
Write-Host "  1. Open app on physical Android device, sign in, tap Allow Notifications"
Write-Host "  2. Confirm row in Supabase Table Editor -> device_push_tokens (is_active=true)"
Write-Host "  3. Re-run this script or wait for cron on dispatch-challenge-notifications"
Write-Host ""
Write-Host "If errors mention PERMISSION_DENIED / 403:" -ForegroundColor Yellow
Write-Host "  Enable 'Firebase Cloud Messaging API' in Google Cloud Console for project verified-glam"
Write-Host ""
Write-Host "Schedule cron: Dashboard -> dispatch-challenge-notifications -> every 10 minutes"
