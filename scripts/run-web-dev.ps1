# Run Verified Glam web locally (any browser — Chrome, Edge, Cursor Simple Browser)
param(
  [string[]]$ExtraArgs = @()
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$EnvFile = Join-Path $Root ".env"

if (-not (Test-Path $EnvFile)) {
  Write-Error "Missing .env - copy .env.example to .env and fill in values."
}

$vars = @{}
Get-Content $EnvFile | ForEach-Object {
  $line = $_.Trim()
  if ($line -eq "" -or $line.StartsWith("#")) { return }
  $idx = $line.IndexOf("=")
  if ($idx -lt 1) { return }
  $key = $line.Substring(0, $idx).Trim()
  $val = $line.Substring($idx + 1).Trim()
  $vars[$key] = $val
}

foreach ($required in @("SUPABASE_URL", "SUPABASE_ANON_KEY")) {
  if (-not $vars.ContainsKey($required) -or [string]::IsNullOrWhiteSpace($vars[$required])) {
    Write-Error "Missing $required in .env"
  }
  if ($vars[$required] -match "your_") {
    Write-Error "Replace placeholder $required in .env before running."
  }
}

$flutter = "C:\Users\zenit\flutter\bin\flutter.bat"
if (-not (Test-Path $flutter)) {
  $flutter = "flutter"
}

$supabaseUrl = $vars["SUPABASE_URL"]
$supabaseKey = $vars["SUPABASE_ANON_KEY"]

$flutterArgs = @(
  "run",
  "-d",
  "chrome",
  "--web-port=8080",
  "--web-hostname=127.0.0.1",
  "-t",
  "lib/main_web.dart",
  "--dart-define=SUPABASE_URL=$supabaseUrl",
  "--dart-define=SUPABASE_ANON_KEY=$supabaseKey",
  "--dart-define=VG_USE_SUPABASE=true",
  "--dart-define=VG_USE_MOCK_ANALYSIS=false"
)

if ($vars.ContainsKey("GOOGLE_WEB_CLIENT_ID") -and $vars["GOOGLE_WEB_CLIENT_ID"] -notmatch "your_") {
  $flutterArgs += "--dart-define=GOOGLE_WEB_CLIENT_ID=$($vars['GOOGLE_WEB_CLIENT_ID'])"
}

$flutterArgs += $ExtraArgs

Write-Host ""
Write-Host "Chrome will open automatically (wait 1-3 min on first compile):"
Write-Host "  http://127.0.0.1:8080"
Write-Host "  http://localhost:8080"
Write-Host ""
Write-Host "Alternative (faster, release build): .\\scripts\\build-web.ps1 then .\\scripts\\serve-web.ps1"
Write-Host ""
Write-Host "Running web dev with Supabase: $supabaseUrl"
Set-Location $Root
& $flutter @flutterArgs
