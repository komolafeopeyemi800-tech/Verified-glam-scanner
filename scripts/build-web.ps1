# Shared helpers for Flutter web build/run (dart-defines from .env)
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
    Write-Error "Replace placeholder $required in .env before building."
  }
}

$flutter = "C:\Users\zenit\flutter\bin\flutter.bat"
if (-not (Test-Path $flutter)) {
  $flutter = "flutter"
}

$supabaseUrl = $vars["SUPABASE_URL"]
$supabaseKey = $vars["SUPABASE_ANON_KEY"]

$flutterArgs = @(
  "build",
  "web",
  "--release",
  "--no-wasm-dry-run",
  "--no-tree-shake-icons",
  "--dart-define=SUPABASE_URL=$supabaseUrl",
  "--dart-define=SUPABASE_ANON_KEY=$supabaseKey",
  "--dart-define=VG_USE_SUPABASE=true",
  "--dart-define=VG_USE_MOCK_ANALYSIS=false"
)

if ($vars.ContainsKey("GOOGLE_WEB_CLIENT_ID") -and $vars["GOOGLE_WEB_CLIENT_ID"] -notmatch "your_") {
  $flutterArgs += "--dart-define=GOOGLE_WEB_CLIENT_ID=$($vars['GOOGLE_WEB_CLIENT_ID'])"
}

$flutterArgs += $ExtraArgs

Write-Host "Building web with Supabase: $supabaseUrl"
Set-Location $Root
& (Join-Path $Root "scripts\sync-marketing-web.ps1")
& $flutter @flutterArgs
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# Disable service worker in local/release static serves (avoids infinite loading on localhost).
$bootstrap = Join-Path $Root "build\web\flutter_bootstrap.js"
if (Test-Path $bootstrap) {
  $content = Get-Content $bootstrap -Raw
  $content = $content -replace 'serviceWorkerSettings:\s*\{[^}]+\}', 'serviceWorkerSettings: null'
  $tmp = "$bootstrap.patch.tmp"
  Set-Content -Path $tmp -Value $content -NoNewline
  Move-Item -Force $tmp $bootstrap
}

# SPA fallback for static serve (deep links like /facial-symmetry).
$serveJson = Join-Path $Root "web\serve.json"
if (Test-Path $serveJson) {
  Copy-Item -Force $serveJson (Join-Path $Root "build\web\serve.json")
}

# Marketing HTML (exact website/) inside release output.
$marketingSrc = Join-Path $Root "web\marketing"
$marketingDest = Join-Path $Root "build\web\marketing"
if (Test-Path $marketingSrc) {
  if (Test-Path $marketingDest) { Remove-Item $marketingDest -Recurse -Force }
  Copy-Item $marketingSrc $marketingDest -Recurse
}

Write-Host "Output: build/web/"
