# Play Store / production build with same Supabase dart-defines as run-dev.ps1.
# MCP and SUPABASE_ACCESS_TOKEN are NOT used — only public URL + anon key in the bundle.
param(
  [ValidateSet("apk", "appbundle")]
  [string]$Target = "appbundle"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$EnvFile = Join-Path $Root ".env"

if (-not (Test-Path $EnvFile)) {
  Write-Error "Missing .env - copy .env.example to .env and fill SUPABASE_URL + SUPABASE_ANON_KEY."
}

$vars = @{}
Get-Content $EnvFile | ForEach-Object {
  $line = $_.Trim()
  if ($line -eq "" -or $line.StartsWith("#")) { return }
  $idx = $line.IndexOf("=")
  if ($idx -lt 1) { return }
  $vars[$line.Substring(0, $idx).Trim()] = $line.Substring($idx + 1).Trim()
}

foreach ($required in @("SUPABASE_URL", "SUPABASE_ANON_KEY")) {
  if (-not $vars.ContainsKey($required) -or [string]::IsNullOrWhiteSpace($vars[$required])) {
    Write-Error "Missing $required in .env"
  }
  if ($vars[$required] -match "your_") {
    Write-Error "Replace placeholder $required in .env before release build."
  }
}

$flutter = "C:\Users\zenit\flutter\bin\flutter.bat"
if (-not (Test-Path $flutter)) { $flutter = "flutter" }

$cmd = if ($Target -eq "appbundle") { "build appbundle" } else { "build apk --release" }
$flutterArgs = @(
  ($cmd.Split(" ") + @("--no-tree-shake-icons"))
  "--dart-define=SUPABASE_URL=$($vars['SUPABASE_URL'])"
  "--dart-define=SUPABASE_ANON_KEY=$($vars['SUPABASE_ANON_KEY'])"
  "--dart-define=VG_USE_SUPABASE=true"
  "--dart-define=VG_USE_MOCK_ANALYSIS=false"
) | ForEach-Object { $_ }

if ($vars.ContainsKey("GOOGLE_WEB_CLIENT_ID") -and $vars["GOOGLE_WEB_CLIENT_ID"] -notmatch "your_") {
  $flutterArgs += "--dart-define=GOOGLE_WEB_CLIENT_ID=$($vars['GOOGLE_WEB_CLIENT_ID'])"
}

Write-Host "Release build ($Target) with Supabase: $($vars['SUPABASE_URL'])" -ForegroundColor Cyan
Write-Host "FCM: google-services.json is bundled from android/app/; push secrets stay on Supabase Edge Functions."
Set-Location $Root
& $flutter @flutterArgs

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "Done. Upload appbundle from build/app/outputs/bundle/release/ to Play Console."
