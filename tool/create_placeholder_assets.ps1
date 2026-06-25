# Creates minimal placeholder files for Verified Glam assets if missing.
$pngBase64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
$bytes = [Convert]::FromBase64String($pngBase64)
$root = Join-Path $PSScriptRoot "..\images"

$assets = @(
  "model_one.jpg", "model_two.jpg", "model_three.jpg",
  "verified_glam_logo.png", "welcome.png", "notification.png",
  "google_logo.png", "ic_apple.png",
  "flag\ic_us.png", "flag\ic_hi.png", "flag\ic_ar.png", "flag\ic_fr.png"
)

New-Item -ItemType Directory -Force -Path $root | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $root "flag") | Out-Null

foreach ($name in $assets) {
  $path = Join-Path $root $name
  if (-not (Test-Path $path)) {
    [IO.File]::WriteAllBytes($path, $bytes)
    Write-Host "Created $path"
  }
}

Write-Host "Placeholder asset generation complete."
