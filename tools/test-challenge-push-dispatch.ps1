# Invoke dispatch-challenge-notifications once (for testing without waiting for cron).
# Requires SUPABASE_ANON_KEY in .env (dispatch has verify_jwt = false but still needs apikey header).

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$SupabaseUrl = "https://qmivgvctmxvpnbouqslj.supabase.co"
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

if (-not $anon) {
  Write-Error "Set SUPABASE_ANON_KEY in .env"
}

$uri = "$SupabaseUrl/functions/v1/dispatch-challenge-notifications"
Write-Host "POST $uri"
try {
  $r = Invoke-WebRequest -Uri $uri -Method POST `
    -Headers @{ apikey = $anon; Authorization = "Bearer $anon" } `
    -ContentType "application/json" `
    -Body "{}" `
    -UseBasicParsing
  Write-Host "Status: $($r.StatusCode)"
  Write-Host $r.Content
} catch {
  if ($_.Exception.Response.StatusCode.value__ -eq 404) {
    Write-Host "404 = dispatch-challenge-notifications not deployed yet." -ForegroundColor Yellow
    Write-Host "Fix: add SUPABASE_ACCESS_TOKEN to .env, then .\scripts\setup-fcm-push.ps1"
    Write-Host "Or deploy manually in Supabase Dashboard -> Edge Functions."
  }
  throw
}
