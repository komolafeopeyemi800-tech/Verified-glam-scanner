# Copy website/ → web/marketing/ for Flutter web (exact HTML marketing homepage).
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$src = Join-Path $Root "website"
$dest = Join-Path $Root "web\marketing"

if (-not (Test-Path $src)) {
  Write-Error "Missing website/ folder."
}

if (Test-Path $dest) {
  Remove-Item $dest -Recurse -Force
}

Copy-Item $src $dest -Recurse

# Integrated Flutter web: same-origin login/register (not a separate port).
$configPath = Join-Path $dest "js\config.js"
@"
/**
 * Flutter web app (integrated) — Log in / Sign up stay on http://127.0.0.1:8080
 * Standalone marketing site uses website/js/config.js (port 3000 → 8080).
 */
window.VG_APP_URL = "/login";
window.VG_REGISTER_URL = "/register";
window.VG_INTEGRATED_APP = true;
"@ | Set-Content -Path $configPath -Encoding UTF8

# Allow same-origin iframe on app.verifiedglam.com (Flutter shell at /).
$headersPath = Join-Path $dest "_headers"
@"
/marketing/*
  X-Frame-Options: SAMEORIGIN
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: camera=(), microphone=(), geolocation=()

/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: camera=(), microphone=(), geolocation=()
"@ | Set-Content -Path $headersPath -Encoding UTF8

Write-Host "Synced marketing site to web/marketing/"
