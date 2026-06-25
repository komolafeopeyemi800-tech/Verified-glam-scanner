# Schedule dispatch-challenge-notifications via pg_cron (every 10 minutes).
param(
  [string]$ProjectRef = "qmivgvctmxvpnbouqslj",
  [string]$AccessToken = ""
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
. (Join-Path $Root "scripts\_Load-SupabaseToken.ps1") -AccessToken $AccessToken -Root $Root

$SupabaseUrl = "https://$ProjectRef.supabase.co"
$anon = $null
foreach ($file in @(".env", ".env.example")) {
  $p = Join-Path $Root $file
  if (-not (Test-Path $p)) { continue }
  Get-Content $p | ForEach-Object {
    if ($_ -match '^SUPABASE_URL=(.+)$') {
      $v = $matches[1].Trim()
      if ($v -notmatch "your_") { $SupabaseUrl = $v }
    }
    if ($_ -match '^SUPABASE_ANON_KEY=(.+)$') {
      $v = $matches[1].Trim()
      if ($v -notmatch "your_") { $anon = $v }
    }
  }
}
if (-not $anon) { Write-Error "Set SUPABASE_ANON_KEY in .env" }
if (-not (Test-SupabaseAccessToken)) {
  Write-Error "Set SUPABASE_ACCESS_TOKEN in .env"
}

$anonEsc = $anon -replace "'", "''"
$headers = @{ Authorization = "Bearer $env:SUPABASE_ACCESS_TOKEN"; "Content-Type" = "application/json" }

$enableExt = @"
create extension if not exists pg_cron with schema pg_catalog;
create extension if not exists pg_net with schema extensions;
"@

$scheduleSql = @"
select cron.unschedule(jobid) from cron.job where jobname = 'dispatch-challenge-notifications';
select cron.schedule(
  'dispatch-challenge-notifications',
  '*/10 * * * *',
  `$`$
  select net.http_post(
    url := '$SupabaseUrl/functions/v1/dispatch-challenge-notifications',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'apikey', '$anonEsc',
      'Authorization', 'Bearer $anonEsc'
    ),
    body := '{}'::jsonb
  ) as request_id;
  `$`$
);
"@

function Invoke-Sql($query) {
  $body = @{ query = $query } | ConvertTo-Json -Compress
  return Invoke-RestMethod -Uri "https://api.supabase.com/v1/projects/$ProjectRef/database/query" `
    -Method POST -Headers $headers -Body $body
}

Write-Host "Enabling pg_cron + pg_net ..."
Invoke-Sql $enableExt | Out-Null

Write-Host "Scheduling dispatch-challenge-notifications every 10 minutes ..."
Invoke-Sql $scheduleSql | Out-Null

$check = '{"query":"select jobid, jobname, schedule, active from cron.job where jobname = ''dispatch-challenge-notifications'';"}'
$jobs = Invoke-RestMethod -Uri "https://api.supabase.com/v1/projects/$ProjectRef/database/query" `
  -Method POST -Headers $headers -Body $check
if ($jobs -is [array] -and $jobs.Count -gt 0) {
  Write-Host "[OK] Cron scheduled: $($jobs[0].schedule) (active=$($jobs[0].active))" -ForegroundColor Green
} else {
  Write-Host "WARN: Could not confirm cron job row." -ForegroundColor Yellow
}
