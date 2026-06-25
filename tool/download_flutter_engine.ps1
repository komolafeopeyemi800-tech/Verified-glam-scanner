$ErrorActionPreference = "Stop"
$engine = "4c525dac5ebe5971c5708ef73558ed8edcf4a362"
$base = "https://storage.googleapis.com/flutter_infra_release/flutter/$engine"
$cache = "C:\Users\zenit\flutter\bin\cache"
$tmp = Join-Path $env:TEMP "flutter_engine_dl"

New-Item -ItemType Directory -Force -Path $tmp | Out-Null
New-Item -ItemType Directory -Force -Path "$cache\pkg" | Out-Null
New-Item -ItemType Directory -Force -Path "$cache\artifacts\engine" | Out-Null

function Download-File($url, $out) {
  for ($i = 1; $i -le 5; $i++) {
    try {
      Write-Host "GET $url (attempt $i)"
      curl.exe -fL --retry 5 --retry-delay 3 -o $out $url
      if (Test-Path $out) { return }
    } catch {
      Write-Warning $_.Exception.Message
      Start-Sleep -Seconds 3
    }
  }
  throw "Failed to download $url"
}

function Expand-ZipTo($zip, $dest) {
  if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
  New-Item -ItemType Directory -Force -Path $dest | Out-Null
  Expand-Archive -Path $zip -DestinationPath $dest -Force
}

$packages = @("sky_engine", "flutter_gpu")
foreach ($pkg in $packages) {
  $dest = Join-Path "$cache\pkg" $pkg
  if (Test-Path (Join-Path $dest "pubspec.yaml")) { Write-Host "Skip $pkg (exists)"; continue }
  $zip = Join-Path $tmp "$pkg.zip"
  Download-File "$base/$pkg.zip" $zip
  Expand-ZipTo $zip $dest
}

$bins = @(
  @("common", "flutter_patched_sdk.zip"),
  @("common", "flutter_patched_sdk_product.zip"),
  @("windows-x64", "windows-x64/artifacts.zip")
)
foreach ($b in $bins) {
  $dir = Join-Path "$cache\artifacts\engine" $b[0]
  if ($b[0] -eq "common" -and (Test-Path (Join-Path $dir "flutter_patched_sdk"))) {
    Write-Host "Skip $($b[1])"
    continue
  }
  if ($b[0] -eq "windows-x64" -and (Test-Path (Join-Path $dir "flutter.exe"))) {
    Write-Host "Skip $($b[1])"
    continue
  }
  $zip = Join-Path $tmp ($b[1] -replace '/', '_')
  Download-File "$base/$($b[1])" $zip
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  Expand-ZipTo $zip $dir
}

Write-Host "Engine artifacts download complete."
