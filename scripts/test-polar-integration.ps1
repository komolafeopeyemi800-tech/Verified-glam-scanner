# Smoke-test Polar Edge Functions (OPTIONS + auth gate). Full E2E requires Polar sandbox secrets.
param(
  [string]$SupabaseUrl = "https://qmivgvctmxvpnbouqslj.supabase.co"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Load-EnvFile($path) {
  if (-not (Test-Path $path)) { return }
  Get-Content $path | ForEach-Object {
    $line = $_.Trim()
    if ($line -eq "" -or $line.StartsWith("#")) { return }
    if ($line -match '^SUPABASE_URL=(.+)$') {
      $v = $matches[1].Trim()
      if ($v -notmatch "your_") { $script:SupabaseUrl = $v }
    }
    if ($line -match '^SUPABASE_ANON_KEY=(.+)$') {
      $v = $matches[1].Trim()
      if ($v -notmatch "your_") { $script:Anon = $v }
    }
  }
}

Load-EnvFile (Join-Path $Root ".env")
Load-EnvFile (Join-Path $Root ".env.example")

$headers = @{}
if ($Anon) { $headers["apikey"] = $Anon }

Write-Host "Polar integration smoke test ($SupabaseUrl)"
Write-Host ""

foreach ($name in @("polar-create-checkout", "polar-customer-portal", "polar-webhook")) {
  $uri = "$SupabaseUrl/functions/v1/$name"
  try {
    $r = Invoke-WebRequest -Uri $uri -Method OPTIONS -Headers $headers -UseBasicParsing
    $ver = $r.Headers["X-Function-Version"]
    Write-Host "  [OK] OPTIONS $name -> $($r.StatusCode) (version=$ver)"
  } catch {
    Write-Error "OPTIONS $name failed: $($_.Exception.Message)"
  }
}

Write-Host ""
Write-Host "Authenticated checkout should return 401 without JWT:"
try {
  $r = Invoke-WebRequest -Uri "$SupabaseUrl/functions/v1/polar-create-checkout" `
    -Method POST -Headers (@{ "Content-Type" = "application/json" } + $headers) `
    -Body '{"planId":"annual"}' -UseBasicParsing
  Write-Warning "Expected 401, got $($r.StatusCode)"
} catch {
  if ($_.Exception.Response.StatusCode.value__ -eq 401) {
    Write-Host "  [OK] polar-create-checkout rejects unauthenticated POST"
  } else {
    Write-Error "Unexpected response: $($_.Exception.Message)"
  }
}

Write-Host ""
Write-Host "Manual sandbox E2E (after Polar secrets + webhook):"
Write-Host "  1. Web checkout Yearly -> profiles.credits_balance = 200"
Write-Host "  2. Same user on Android -> is_pro true without repaying"
Write-Host "  3. Pro weekly -> 30 credits, 5 per scan"
Write-Host "  4. Cancel in Polar portal -> webhook updates subscription_status"
Write-Host "  5. Renewal order -> credits refresh"
Write-Host ""
Write-Host "See docs/SUPABASE_SETUP.md for webhook URL and secret setup."
