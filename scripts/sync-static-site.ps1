# Overlay static marketing site on Flutter build/web output.
# Called after flutter build web from build-web.ps1 / cloudflare-build.sh.
param(
  [string]$EnvFile = ""
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$BuildWeb = Join-Path $Root "build\web"

if (-not (Test-Path $BuildWeb)) {
  Write-Error "Missing build/web - run flutter build web first."
}

$dart = "C:\Users\zenit\flutter\bin\dart.bat"
if (-not (Test-Path $dart)) { $dart = "dart" }

Write-Host "==> Generate static HTML pages"
Set-Location $Root
& $dart run tool/generate_marketing_html.dart
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# Save Flutter SPA shell before overwriting root index.html
$flutterShell = Join-Path $BuildWeb "_flutter\index.html"
New-Item -ItemType Directory -Path (Split-Path $flutterShell) -Force | Out-Null
Copy-Item -Force (Join-Path $BuildWeb "index.html") $flutterShell
Copy-Item -Force $flutterShell (Join-Path $BuildWeb "404.html")

Write-Host "==> Copy marketing assets"
$assetSrc = Join-Path $Root "images\vg\marketing"
$assetDest = Join-Path $BuildWeb "assets"
if (Test-Path $assetSrc) {
  New-Item -ItemType Directory -Path $assetDest -Force | Out-Null
  Copy-Item -Path (Join-Path $assetSrc "*") -Destination $assetDest -Recurse -Force
}
foreach ($sub in @("css", "js")) {
  $from = Join-Path $Root "website\$sub"
  $to = Join-Path $BuildWeb $sub
  if (Test-Path $from) {
    if (Test-Path $to) { Remove-Item $to -Recurse -Force }
    Copy-Item $from $to -Recurse -Force
  }
}

# Inject Supabase config into auth-config.js
if ([string]::IsNullOrWhiteSpace($EnvFile)) {
  $EnvFile = Join-Path $Root ".env"
}
$vars = @{}
if (Test-Path $EnvFile) {
  Get-Content $EnvFile | ForEach-Object {
    $line = $_.Trim()
    if ($line -eq "" -or $line.StartsWith("#")) { return }
    $idx = $line.IndexOf("=")
    if ($idx -lt 1) { return }
    $vars[$line.Substring(0, $idx).Trim()] = $line.Substring($idx + 1).Trim()
  }
}
$supabaseUrl = $vars["SUPABASE_URL"]
$supabaseKey = $vars["SUPABASE_ANON_KEY"]
$googleId = $vars["GOOGLE_WEB_CLIENT_ID"]
if (-not $supabaseUrl) { $supabaseUrl = $env:SUPABASE_URL }
if (-not $supabaseKey) { $supabaseKey = $env:SUPABASE_ANON_KEY }
if (-not $googleId) { $googleId = $env:GOOGLE_WEB_CLIENT_ID }

$authConfig = Join-Path $BuildWeb "js\auth-config.js"
if (Test-Path $authConfig) {
  $cfg = Get-Content $authConfig -Raw
  if ($supabaseUrl) { $cfg = $cfg -replace '__SUPABASE_URL__', $supabaseUrl }
  if ($supabaseKey) { $cfg = $cfg -replace '__SUPABASE_ANON_KEY__', $supabaseKey }
  if ($googleId) { $cfg = $cfg -replace '__GOOGLE_WEB_CLIENT_ID__', $googleId }
  Set-Content -Path $authConfig -Value $cfg -NoNewline
}

Write-Host "==> Copy static pages"
Copy-Item -Force (Join-Path $Root "website\index.html") (Join-Path $BuildWeb "index.html")

$generated = Join-Path $Root "website\generated"
if (Test-Path $generated) {
  Get-ChildItem $generated -Directory | ForEach-Object {
    $dest = Join-Path $BuildWeb $_.Name
    if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
    Copy-Item $_.FullName $dest -Recurse -Force
  }
}

foreach ($seoFile in @("sitemap.xml", "robots.txt", "llms.txt", "_redirects")) {
  $src = Join-Path $Root "website\$seoFile"
  if (Test-Path $src) {
    Copy-Item -Force $src (Join-Path $BuildWeb $seoFile)
  }
}

# Remove legacy iframe embed
$legacyStatic = Join-Path $BuildWeb "_static"
if (Test-Path $legacyStatic) { Remove-Item $legacyStatic -Recurse -Force }
$legacyMarketing = Join-Path $BuildWeb "marketing"
if (Test-Path $legacyMarketing) { Remove-Item $legacyMarketing -Recurse -Force }

Write-Host "Static overlay complete."
