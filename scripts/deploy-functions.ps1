# Deploy Supabase Edge Functions (requires Supabase Personal Access Token)
param(
  [string]$ProjectRef = "qmivgvctmxvpnbouqslj",
  [string]$SupabaseUrl = "https://qmivgvctmxvpnbouqslj.supabase.co"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Load-EnvFile($path) {
  if (-not (Test-Path $path)) { return }
  Get-Content $path | ForEach-Object {
    $line = $_.Trim()
    if ($line -eq "" -or $line.StartsWith("#")) { return }
    if ($line -match '^([A-Za-z_][A-Za-z0-9_]*)=(.*)$') {
      $key = $matches[1]
      $val = $matches[2].Trim()
      if ($key -eq "SUPABASE_ACCESS_TOKEN" -and [string]::IsNullOrWhiteSpace($env:SUPABASE_ACCESS_TOKEN)) {
        if ($val -notmatch "your_") {
          $env:SUPABASE_ACCESS_TOKEN = $val
        }
      }
      if ($key -eq "SUPABASE_URL" -and $val -notmatch "your_") {
        $script:SupabaseUrl = $val
      }
    }
  }
}

Load-EnvFile (Join-Path $Root ".env")
Load-EnvFile (Join-Path $Root ".env.example")

if ([string]::IsNullOrWhiteSpace($env:SUPABASE_ACCESS_TOKEN)) {
  Write-Error @"
Missing SUPABASE_ACCESS_TOKEN.
Add your Personal Access Token from https://supabase.com/dashboard/account/tokens to .env:
SUPABASE_ACCESS_TOKEN=sbp_...
"@
}

Set-Location $Root
Write-Host "Deploying analyze-scan and guide-recommendations to $ProjectRef ..."
npx supabase functions deploy analyze-scan guide-recommendations `
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

Write-Host "Verifying deployed endpoints..."
$headers = @{}
if ($anon) { $headers["apikey"] = $anon }

foreach ($name in @("analyze-scan", "guide-recommendations")) {
  $uri = "$SupabaseUrl/functions/v1/$name"
  try {
    $r = Invoke-WebRequest -Uri $uri -Method OPTIONS -Headers $headers -UseBasicParsing
    $ver = $r.Headers["X-Function-Version"]
    Write-Host "  $name OPTIONS $($r.StatusCode) X-Function-Version=$ver"
    if ($r.StatusCode -ne 200) {
      Write-Error "$name returned $($r.StatusCode)"
    }
  } catch {
    Write-Error "OPTIONS $name failed: $($_.Exception.Message)"
  }
}

Write-Host "Deploy complete. Set OPENAI_API_KEY in Dashboard -> Edge Functions -> Secrets."
Write-Host "Run: .\tools\test-openai-vision.ps1 (with OPENAI_API_KEY in .env for local probe)"
