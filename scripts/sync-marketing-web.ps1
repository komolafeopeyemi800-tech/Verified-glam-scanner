# Copy homepage-only bundle from website/ → web/_static/home/ (iframe embed; not public /marketing/).
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$src = Join-Path $Root "website"
$dest = Join-Path $Root "web\_static\home"

if (-not (Test-Path $src)) {
  Write-Error "Missing website/ folder."
}

if (Test-Path $dest) {
  Remove-Item $dest -Recurse -Force
}
New-Item -ItemType Directory -Path $dest -Force | Out-Null

foreach ($item in @("index.html", "css", "assets", "js")) {
  $from = Join-Path $src $item
  if (-not (Test-Path $from)) {
    Write-Error "Missing website/$item"
  }
  Copy-Item $from (Join-Path $dest $item) -Recurse
}

$configPath = Join-Path $dest "js\config.js"
@"
/**
 * Flutter web app (integrated) — Log in / Sign up stay on same origin.
 */
window.VG_APP_URL = "/login";
window.VG_REGISTER_URL = "/register";
window.VG_INTEGRATED_APP = true;
"@ | Set-Content -Path $configPath -Encoding UTF8

$headersPath = Join-Path $dest "_headers"
@"
/_static/*
  X-Frame-Options: SAMEORIGIN
  X-Robots-Tag: noindex, nofollow
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: camera=(), microphone=(), geolocation=()

/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: camera=(), microphone=(), geolocation=()
"@ | Set-Content -Path $headersPath -Encoding UTF8

# Remove legacy public marketing folder.
$legacyMarketing = Join-Path $Root "web\marketing"
if (Test-Path $legacyMarketing) {
  Remove-Item $legacyMarketing -Recurse -Force
}

Write-Host "Synced homepage embed to web/_static/home/"
