# Run Verified Glam on a connected device with Supabase credentials from .env
param(
  [string]$DeviceId = ""
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
  "--dart-define=SUPABASE_URL=$supabaseUrl",
  "--dart-define=SUPABASE_ANON_KEY=$supabaseKey",
  "--dart-define=VG_USE_SUPABASE=true",
  "--dart-define=VG_USE_MOCK_ANALYSIS=false"
)

if ($vars.ContainsKey("GOOGLE_WEB_CLIENT_ID") -and $vars["GOOGLE_WEB_CLIENT_ID"] -notmatch "your_") {
  $flutterArgs += "--dart-define=GOOGLE_WEB_CLIENT_ID=$($vars['GOOGLE_WEB_CLIENT_ID'])"
}

if ($DeviceId -ne "") {
  $flutterArgs += "-d"
  $flutterArgs += $DeviceId
}

Write-Host "Running with Supabase: $supabaseUrl"
Set-Location $Root
& $flutter @flutterArgs
