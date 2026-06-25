# Deploy challenge push Edge Functions (FCM HTTP v1 + dispatch cron target).
param(
  [string]$ProjectRef = "qmivgvctmxvpnbouqslj",
  [string]$SupabaseUrl = "https://qmivgvctmxvpnbouqslj.supabase.co",
  [string]$AccessToken = ""
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
. (Join-Path $Root "scripts\_Load-SupabaseToken.ps1") -AccessToken $AccessToken -Root $Root
Assert-SupabaseAccessToken

$envPath = Join-Path $Root ".env"
if (Test-Path $envPath) {
  Get-Content $envPath | ForEach-Object {
    if ($_ -match '^SUPABASE_URL=(.+)$') {
      $v = $matches[1].Trim()
      if ($v -notmatch "your_") { $SupabaseUrl = $v }
    }
  }
}

Set-Location $Root
Write-Host "Deploying send-challenge-push and dispatch-challenge-notifications to $ProjectRef ..."
npx --yes supabase functions deploy send-challenge-push dispatch-challenge-notifications `
  --project-ref $ProjectRef `
  --use-api

if ($LASTEXITCODE -ne 0) {
  Write-Error "Deploy failed with exit code $LASTEXITCODE"
}

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

$headers = @{}
if ($anon) { $headers["apikey"] = $anon }

foreach ($name in @("send-challenge-push", "dispatch-challenge-notifications")) {
  $uri = "$SupabaseUrl/functions/v1/$name"
  try {
    $r = Invoke-WebRequest -Uri $uri -Method OPTIONS -Headers $headers -UseBasicParsing
    Write-Host "  $name OPTIONS $($r.StatusCode)"
  } catch {
    Write-Warning "OPTIONS $name failed: $($_.Exception.Message)"
  }
}

Write-Host "Push functions deployed."
