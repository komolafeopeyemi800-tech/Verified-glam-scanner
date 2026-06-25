# Verify FCM push readiness (functions, tokens, optional test send).
param(
  [string]$ProjectRef = "qmivgvctmxvpnbouqslj",
  [switch]$SendTest
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
. (Join-Path $Root "scripts\_Load-SupabaseToken.ps1") -Root $Root

$SupabaseUrl = "https://$ProjectRef.supabase.co"
foreach ($file in @(".env", ".env.example")) {
  $p = Join-Path $Root $file
  if (-not (Test-Path $p)) { continue }
  Get-Content $p | ForEach-Object {
    if ($_ -match '^SUPABASE_URL=(.+)$') {
      $v = $matches[1].Trim()
      if ($v -notmatch "your_") { $SupabaseUrl = $v }
    }
  }
}

Write-Host "=== Push readiness ===" -ForegroundColor Cyan

$anon = $null
foreach ($file in @(".env", ".env.example")) {
  $p = Join-Path $Root $file
  if (-not (Test-Path $p)) { continue }
  Get-Content $p | ForEach-Object {
    if ($_ -match '^SUPABASE_ANON_KEY=(.+)$') {
      $v = $matches[1].Trim()
      if ($v -notmatch "your_") { $anon = $v }
    }
  }
}
if (-not $anon) { Write-Error "Set SUPABASE_ANON_KEY in .env" }

foreach ($name in @("send-challenge-push", "dispatch-challenge-notifications")) {
  $uri = "$SupabaseUrl/functions/v1/$name"
  try {
    $r = Invoke-WebRequest -Uri $uri -Method OPTIONS -Headers @{ apikey = $anon } -UseBasicParsing
    Write-Host "[OK] $name OPTIONS $($r.StatusCode)" -ForegroundColor Green
  } catch {
    Write-Host "[FAIL] $name not reachable" -ForegroundColor Red
  }
}

if (Test-SupabaseAccessToken) {
  $mgmtHeaders = @{ Authorization = "Bearer $env:SUPABASE_ACCESS_TOKEN"; "Content-Type" = "application/json" }
  $tokenQuery = @"
select count(*)::int as active_tokens from public.device_push_tokens where is_active = true;
"@
  $tokens = Invoke-RestMethod -Uri "https://api.supabase.com/v1/projects/$ProjectRef/database/query" `
    -Method POST -Headers $mgmtHeaders -Body (@{ query = $tokenQuery } | ConvertTo-Json)
  $count = if ($tokens -is [array]) { $tokens[0].active_tokens } else { $tokens.active_tokens }
  Write-Host "Active FCM tokens: $count"
  if ([int]$count -lt 1) {
    Write-Host "WARN: No device tokens. Sign in on phone and allow notifications." -ForegroundColor Yellow
  }

  $jobQuery = @"
select status, count(*)::int as n from public.challenge_notification_jobs group by status order by status;
"@
  $jobs = Invoke-RestMethod -Uri "https://api.supabase.com/v1/projects/$ProjectRef/database/query" `
    -Method POST -Headers $mgmtHeaders -Body (@{ query = $jobQuery } | ConvertTo-Json)
  Write-Host "Notification jobs:"
  $jobs | ForEach-Object { Write-Host "  $($_.status): $($_.n)" }
} else {
  Write-Host "Skip DB checks (add SUPABASE_ACCESS_TOKEN to .env for token/job counts)." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Dispatch test:"
& (Join-Path $Root "tools\test-challenge-push-dispatch.ps1")

if ($SendTest) {
  Write-Host ""
  Write-Host "Test push to latest token:"
  & (Join-Path $Root "tools\test-send-push.ps1")
}

Write-Host ""
Write-Host "Reminder: schedule cron on dispatch-challenge-notifications every 10 minutes in Dashboard."
