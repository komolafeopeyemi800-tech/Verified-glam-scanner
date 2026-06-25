# End-to-end test: auth -> storage upload -> analyze-scan (all features) -> guide-recommendations
# Requires SUPABASE_URL and SUPABASE_ANON_KEY in .env (same as Flutter app).
param(
  [string]$Fixture = ""
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$EnvFile = Join-Path $Root ".env"
$FixturePath = if ($Fixture) { $Fixture } else { Join-Path $Root "tools\fixtures\test-face.jpg" }

function Read-EnvKey($key) {
  if (-not (Test-Path $EnvFile)) { return $null }
  foreach ($line in Get-Content $EnvFile) {
    if ($line -match "^$key=(.+)$") {
      $v = $matches[1].Trim()
      if ($v -notmatch "your_") { return $v }
    }
  }
  return $null
}

$baseUrl = Read-EnvKey "SUPABASE_URL"
$anon = Read-EnvKey "SUPABASE_ANON_KEY"
if ([string]::IsNullOrWhiteSpace($baseUrl) -or [string]::IsNullOrWhiteSpace($anon)) {
  Write-Error "Set SUPABASE_URL and SUPABASE_ANON_KEY in .env"
}
if (-not (Test-Path $FixturePath)) {
  Write-Error "Missing fixture $FixturePath"
}

Write-Host "E2E against $baseUrl"
$headers = @{ apikey = $anon; "Content-Type" = "application/json" }
$email = "vg-e2e-$(Get-Random)@test.verifiedglam.local"
$pass = "TestPass123!E2E"

$signup = Invoke-RestMethod -Uri "$baseUrl/auth/v1/signup" -Method POST -Headers $headers `
  -Body (@{ email = $email; password = $pass } | ConvertTo-Json)
$token = $signup.access_token
if (-not $token) {
  $signin = Invoke-RestMethod -Uri "$baseUrl/auth/v1/token?grant_type=password" -Method POST -Headers $headers `
    -Body (@{ email = $email; password = $pass } | ConvertTo-Json)
  $token = $signin.access_token
}
if (-not $token) { Write-Error "Could not obtain auth token" }

$user = Invoke-RestMethod -Uri "$baseUrl/auth/v1/user" -Headers @{
  apikey = $anon; Authorization = "Bearer $token"
}
$userId = $user.id
Write-Host "Test user: $email ($userId)"

$bytes = [IO.File]::ReadAllBytes($FixturePath)
$uploadHeaders = @{
  apikey = $anon
  Authorization = "Bearer $token"
  "Content-Type" = "image/jpeg"
  "x-upsert" = "true"
}
$fnHeaders = @{
  apikey = $anon
  Authorization = "Bearer $token"
  "Content-Type" = "application/json"
}

$features = @(
  "FACE_BEAUTY_ANALYSIS", "COLOR_ANALYSIS", "BEAUTY_TIPS", "GLOW_UP_GUIDE",
  "CELEBRITY_LOOKALIKE", "FACIAL_SYMMETRY", "BEAUTY_SCORE_SHOWDOWN",
  "FACIAL_RESEMBLANCE", "FACE_READING", "GOLDEN_RATIO"
)
$failed = @()

foreach ($f in $features) {
  $scanId = [guid]::NewGuid().ToString()
  $storagePath = "$userId/$scanId.jpg"
  Invoke-RestMethod -Uri "$baseUrl/storage/v1/object/scan-photos/$storagePath" `
    -Method POST -Headers $uploadHeaders -Body $bytes | Out-Null
  $body = @{
    featureType = $f
    storagePath = $storagePath
    detectedFaces = @()
    profile = @{ age = 25; skinType = "combination" }
  } | ConvertTo-Json

  try {
    $sw = [Diagnostics.Stopwatch]::StartNew()
    $res = Invoke-WebRequest -Uri "$baseUrl/functions/v1/analyze-scan" -Method POST `
      -Headers $fnHeaders -Body $body -UseBasicParsing -TimeoutSec 120
    $sw.Stop()
    $ver = $res.Headers["X-Function-Version"]
    $json = $res.Content | ConvertFrom-Json
    if ($ver -ne "4") {
      Write-Warning "$f deployed version is $ver (expected 4)"
    }
    $payload = $json.payload
    switch ($f) {
      "FACIAL_SYMMETRY" {
        if ($payload.regions -isnot [System.Array]) { throw "FACIAL_SYMMETRY: regions must be array" }
        if ($payload.annotations -isnot [System.Array]) { throw "FACIAL_SYMMETRY: annotations must be array" }
      }
      "FACIAL_RESEMBLANCE" {
        if ($payload.faces -isnot [System.Array]) { throw "FACIAL_RESEMBLANCE: faces must be array" }
        if ($payload.sharedTraits -isnot [System.Array]) { throw "FACIAL_RESEMBLANCE: sharedTraits must be array" }
      }
      "GOLDEN_RATIO" {
        if ($payload.measurements -isnot [System.Array]) { throw "GOLDEN_RATIO: measurements must be array" }
      }
    }
    Write-Host "PASS $f ($($sw.ElapsedMilliseconds)ms) v=$ver"
  } catch {
    $failed += $f
    Write-Host "FAIL $f : $($_.ErrorDetails.Message)" -ForegroundColor Red
  }
}

try {
  $gbody = @{
    profile = @{
      age = 25
      skinType = "oily"
      skinConcerns = @("acne")
      beautyGoals = @("clear skin")
    }
  } | ConvertTo-Json
  $gres = Invoke-WebRequest -Uri "$baseUrl/functions/v1/guide-recommendations" -Method POST `
    -Headers $fnHeaders -Body $gbody -UseBasicParsing
  $gtips = ($gres.Content | ConvertFrom-Json).tips.Count
  Write-Host "PASS guide-recommendations tips=$gtips"
} catch {
  $failed += "guide-recommendations"
  Write-Host "FAIL guide-recommendations: $($_.ErrorDetails.Message)" -ForegroundColor Red
}

if ($failed.Count -gt 0) {
  Write-Error "Failed: $($failed -join ', ')"
}
Write-Host "All E2E tests passed. Safe to test on phone with run-dev.ps1" -ForegroundColor Green
