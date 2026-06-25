# Send a one-off test push to the most recently active device token.
# Requires SUPABASE_ACCESS_TOKEN in .env (Management API + Edge Function auth).
param(
  [string]$UserId = "",
  [string]$Title = "Verified Glam test",
  [string]$Body = "Push setup is working on your device.",
  [string]$ProjectRef = "qmivgvctmxvpnbouqslj"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
. (Join-Path $Root "scripts\_Load-SupabaseToken.ps1") -Root $Root
Assert-SupabaseAccessToken

$mgmtHeaders = @{ Authorization = "Bearer $env:SUPABASE_ACCESS_TOKEN"; "Content-Type" = "application/json" }

if (-not $UserId) {
  $rows = Invoke-RestMethod -Uri "https://api.supabase.com/v1/projects/$ProjectRef/database/query" `
    -Method POST -Headers $mgmtHeaders `
    -Body (@{
      query = @"
select user_id, fcm_token, last_seen_at
from public.device_push_tokens
where is_active = true
order by last_seen_at desc
limit 1
"@
    } | ConvertTo-Json)
  if (-not $rows -or $rows.Count -lt 1) {
    Write-Error "No active FCM tokens. Open app on phone, sign in, tap Allow Notifications."
  }
  $UserId = $rows[0].user_id
  Write-Host "Using latest token for user $UserId (last seen $($rows[0].last_seen_at))"
}

$keys = Invoke-RestMethod -Uri "https://api.supabase.com/v1/projects/$ProjectRef/api-keys" -Headers @{ Authorization = "Bearer $env:SUPABASE_ACCESS_TOKEN" }
$serviceKey = ($keys | Where-Object { $_.name -eq 'service_role' -and $_.type -eq 'legacy' }).api_key
$anon = ($keys | Where-Object { $_.type -eq 'publishable' }).api_key
if (-not $serviceKey -or -not $anon) {
  Write-Error "Could not load project API keys from Management API."
}

$supabaseUrl = "https://$ProjectRef.supabase.co"
foreach ($file in @(".env", ".env.example")) {
  $p = Join-Path $Root $file
  if (-not (Test-Path $p)) { continue }
  Get-Content $p | ForEach-Object {
    if ($_ -match '^SUPABASE_URL=(.+)$') {
      $v = $matches[1].Trim()
      if ($v -notmatch "your_") { $supabaseUrl = $v }
    }
  }
}

$payload = @{
  userId = $UserId
  title  = $Title
  body   = $Body
  data   = @{
    deepLink    = "/challenge/day1"
    kind        = "unlock"
    day         = "1"
    challengeId = "test"
  }
} | ConvertTo-Json -Depth 5

Write-Host "POST $supabaseUrl/functions/v1/send-challenge-push"
$r = Invoke-WebRequest -Uri "$supabaseUrl/functions/v1/send-challenge-push" -Method POST `
  -Headers @{
    apikey        = $anon
    Authorization = "Bearer $serviceKey"
    "Content-Type" = "application/json"
  } `
  -Body $payload `
  -UseBasicParsing

Write-Host "Status: $($r.StatusCode)"
Write-Host $r.Content
$result = $r.Content | ConvertFrom-Json
if ($result.sent -lt 1) {
  Write-Error "Push not delivered. Errors: $($result.errors -join '; ')"
}
Write-Host "Check your phone for the notification." -ForegroundColor Green
