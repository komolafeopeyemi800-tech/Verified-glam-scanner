# Chain: CLI pre-flight, 10-feature E2E, FCM dispatch check.
param(
  [string]$AccessToken = "",
  [switch]$SkipFcmSetup,
  [switch]$SkipE2e,
  [switch]$SkipDispatch
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

$failed = @()

if (-not $SkipFcmSetup) {
  try {
    if ($AccessToken) {
      & (Join-Path $Root "scripts\setup-fcm-push.ps1") -AccessToken $AccessToken
      & (Join-Path $Root "scripts\apply-migration-007.ps1") -AccessToken $AccessToken
    } else {
      & (Join-Path $Root "scripts\check-supabase-cli-ready.ps1")
      & (Join-Path $Root "scripts\setup-fcm-push.ps1")
      & (Join-Path $Root "scripts\apply-migration-007.ps1")
    }
  } catch {
    $failed += "fcm-setup"
    Write-Host "FCM setup failed (deploy secret or use Dashboard): $($_.Exception.Message)" -ForegroundColor Yellow
  }
}

if (-not $SkipE2e) {
  try {
    & (Join-Path $Root "tools\e2e-test-supabase.ps1")
  } catch {
    $failed += "e2e-10-features"
    throw
  }
}

if (-not $SkipDispatch) {
  try {
    & (Join-Path $Root "tools\test-challenge-push-dispatch.ps1")
  } catch {
    $failed += "fcm-dispatch"
    Write-Host "Dispatch check failed (deploy push functions + FCM secret)." -ForegroundColor Yellow
  }
}

if ($failed.Count -gt 0) {
  Write-Host "Partial pass. Failed steps: $($failed -join ', ')" -ForegroundColor Yellow
  exit 1
}
Write-Host "Full verification passed." -ForegroundColor Green
