# API-level E2E for all 10 web AI tools against live analyze-scan Edge Function.
# Requires .env: SUPABASE_URL, SUPABASE_ANON_KEY, TEST_USER_EMAIL, TEST_USER_PASSWORD
param(
  [switch]$SkipSlow,
  [int]$TimeoutSec = 180
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$EnvFile = Join-Path $Root ".env"

function Load-EnvFile($path) {
  $vars = @{}
  if (-not (Test-Path $path)) { return $vars }
  Get-Content $path | ForEach-Object {
    $line = $_.Trim()
    if ($line -eq "" -or $line.StartsWith("#")) { return }
    $idx = $line.IndexOf("=")
    if ($idx -lt 1) { return }
    $key = $line.Substring(0, $idx).Trim()
    $val = $line.Substring($idx + 1).Trim()
    $vars[$key] = $val
  }
  return $vars
}

$vars = Load-EnvFile $EnvFile
foreach ($required in @("SUPABASE_URL", "SUPABASE_ANON_KEY")) {
  if (-not $vars.ContainsKey($required) -or [string]::IsNullOrWhiteSpace($vars[$required])) {
    Write-Error "Missing $required in .env - copy from .env.example and fill in values."
  }
  if ($vars[$required] -match "your_") {
    Write-Error "Replace placeholder $required in .env before running."
  }
}

$useEphemeralUser = $false
if (-not $vars.ContainsKey("TEST_USER_EMAIL") -or [string]::IsNullOrWhiteSpace($vars["TEST_USER_EMAIL"]) -or $vars["TEST_USER_EMAIL"] -match "your_") {
  $useEphemeralUser = $true
  $vars["TEST_USER_EMAIL"] = "vg-web-e2e-$(Get-Random)@test.verifiedglam.local"
  $vars["TEST_USER_PASSWORD"] = "TestPass123!E2E"
  Write-Host "TEST_USER_* not set - using ephemeral account $($vars['TEST_USER_EMAIL'])"
}

$supabaseUrl = $vars["SUPABASE_URL"].TrimEnd("/")
$anonKey = $vars["SUPABASE_ANON_KEY"]
$email = $vars["TEST_USER_EMAIL"]
$password = $vars["TEST_USER_PASSWORD"]

$singleFaceFixture = Join-Path $Root "images\vg\upload_selfie_portrait.png"
$twoFaceFixture = Join-Path $Root "images\vg\guidelines\face_comparison_good_bad.png"
foreach ($f in @($singleFaceFixture, $twoFaceFixture)) {
  if (-not (Test-Path $f)) {
    Write-Error "Missing fixture image: $f"
  }
}

function Get-ContentType([string]$path) {
  switch ([IO.Path]::GetExtension($path).ToLower()) {
    ".png" { return "image/png" }
    ".webp" { return "image/webp" }
    default { return "image/jpeg" }
  }
}

function Invoke-SupabaseAuth {
  $body = @{ email = $email; password = $password } | ConvertTo-Json
  $headers = @{
    apikey        = $anonKey
    Authorization = "Bearer $anonKey"
    "Content-Type" = "application/json"
  }
  if ($useEphemeralUser) {
    try {
      $signup = Invoke-RestMethod -Uri "$supabaseUrl/auth/v1/signup" -Method Post -Headers $headers -Body $body
      if ($signup.access_token) { return $signup }
    } catch { }
  }
  return Invoke-RestMethod -Uri "$supabaseUrl/auth/v1/token?grant_type=password" -Method Post -Headers $headers -Body $body
}

function Upload-ScanPhoto {
  param([string]$Jwt, [string]$UserId, [string]$LocalPath, [string]$ObjectName)
  $storagePath = "$UserId/$ObjectName"
  $bytes = [IO.File]::ReadAllBytes($LocalPath)
  $mime = Get-ContentType $LocalPath
  $headers = @{
    apikey        = $anonKey
    Authorization = "Bearer $Jwt"
    "Content-Type" = $mime
    "x-upsert"    = "true"
  }
  $uri = "$supabaseUrl/storage/v1/object/scan-photos/$storagePath"
  Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $bytes | Out-Null
  return $storagePath
}

function Invoke-AnalyzeScan {
  param(
    [string]$Jwt,
    [string]$FeatureType,
    [string]$StoragePath,
    [object[]]$DetectedFaces = @()
  )
  $body = @{
    featureType   = $FeatureType
    storagePath   = $StoragePath
    detectedFaces = $DetectedFaces
    profile       = @{}
  } | ConvertTo-Json -Depth 6

  $headers = @{
    apikey        = $anonKey
    Authorization = "Bearer $Jwt"
    "Content-Type" = "application/json"
  }

  $sw = [Diagnostics.Stopwatch]::StartNew()
  try {
    $response = Invoke-WebRequest -Uri "$supabaseUrl/functions/v1/analyze-scan" -Method Post -Headers $headers -Body $body -TimeoutSec $TimeoutSec -UseBasicParsing
    $sw.Stop()
    $json = $response.Content | ConvertFrom-Json
    return @{
      Status    = [int]$response.StatusCode
      ErrorCode = $null
      Duration  = $sw.Elapsed.TotalSeconds
      Payload   = $json
    }
  } catch {
    $sw.Stop()
    $status = 0
    $errorCode = "REQUEST_FAILED"
    $message = $_.Exception.Message
    if ($_.Exception.Response) {
      $status = [int]$_.Exception.Response.StatusCode.value__
      try {
        $reader = New-Object IO.StreamReader($_.Exception.Response.GetResponseStream())
        $raw = $reader.ReadToEnd()
        $reader.Close()
        $parsed = $raw | ConvertFrom-Json
        if ($parsed.errorCode) { $errorCode = $parsed.errorCode }
        if ($parsed.error) { $message = $parsed.error }
      } catch { }
    }
    return @{
      Status    = $status
      ErrorCode = $errorCode
      Duration  = $sw.Elapsed.TotalSeconds
      Message   = $message
    }
  }
}

# Feature map: type -> slug (mirrors lib/web/vg_feature_slugs.dart)
$tools = @(
  @{ Type = "FACE_BEAUTY_ANALYSIS"; Slug = "face-beauty-analysis"; Fixture = "single" }
  @{ Type = "COLOR_ANALYSIS"; Slug = "seasonal-color-palette"; Fixture = "single" }
  @{ Type = "GLOW_UP_GUIDE"; Slug = "beauty-routine-challenge"; Fixture = "single" }
  @{ Type = "BEAUTY_TIPS"; Slug = "beauty-tips"; Fixture = "single" }
  @{ Type = "CELEBRITY_LOOKALIKE"; Slug = "celebrity-look-alike"; Fixture = "single"; Slow = $true }
  @{ Type = "FACIAL_SYMMETRY"; Slug = "facial-symmetry"; Fixture = "single" }
  @{ Type = "BEAUTY_SCORE_SHOWDOWN"; Slug = "beauty-score-showdown"; Fixture = "single"; Slow = $true }
  @{ Type = "FACIAL_RESEMBLANCE"; Slug = "face-comparison"; Fixture = "two" }
  @{ Type = "FACE_READING"; Slug = "attractiveness-test"; Fixture = "single" }
  @{ Type = "GOLDEN_RATIO"; Slug = "face-golden-ratio"; Fixture = "single" }
)

Write-Host "Authenticating test user..."
$auth = Invoke-SupabaseAuth
$jwt = $auth.access_token
$userId = $auth.user.id
if ([string]::IsNullOrWhiteSpace($userId)) {
  Write-Error "Auth succeeded but user id missing."
}
Write-Host "Signed in as $userId"

$scanId = [guid]::NewGuid().ToString()
$singleStorage = Upload-ScanPhoto -Jwt $jwt -UserId $userId -LocalPath $singleFaceFixture -ObjectName "e2e-single-$scanId.jpg"
$twoStorage = Upload-ScanPhoto -Jwt $jwt -UserId $userId -LocalPath $twoFaceFixture -ObjectName "e2e-two-$scanId.jpg"
Write-Host "Uploaded fixtures: $singleStorage, $twoStorage"
Write-Host ""

$results = @()
$failures = 0

foreach ($tool in $tools) {
  if ($SkipSlow -and $tool.Slow) {
    Write-Host ("{0,-28} {1,-28} SKIP (slow)" -f $tool.Type, $tool.Slug)
    continue
  }

  $storage = if ($tool.Fixture -eq "two") { $twoStorage } else { $singleStorage }
  $r = Invoke-AnalyzeScan -Jwt $jwt -FeatureType $tool.Type -StoragePath $storage
  $ok = $r.Status -eq 200
  if (-not $ok) { $failures++ }

  $line = "{0,-28} {1,-28} {2,4} {3,-22} {4,6:N1}s" -f `
    $tool.Type, $tool.Slug, $r.Status, $(if ($ok) { "OK" } else { $r.ErrorCode }), $r.Duration
  if (-not $ok -and $r.Message) {
    $line += " - $($r.Message)"
  }
  Write-Host $line
  $results += [pscustomobject]@{
    FeatureType = $tool.Type
    Slug        = $tool.Slug
    Status      = $r.Status
    ErrorCode   = $r.ErrorCode
    DurationSec = [math]::Round($r.Duration, 1)
    Pass        = $ok
  }
}

Write-Host ""
$passed = ($results | Where-Object { $_.Pass }).Count
$total = $results.Count
Write-Host "Result: $passed / $total passed"

if ($failures -gt 0) {
  exit 1
}
