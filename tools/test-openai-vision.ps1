# Local OpenAI vision probe — same API shape as analyze-scan Edge Function.
# Usage: set OPENAI_API_KEY in .env, then: .\tools\test-openai-vision.ps1
param(
  [string]$Model = "",
  [string]$Fixture = ""
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$EnvFile = Join-Path $Root ".env"
$FixturePath = if ($Fixture) { $Fixture } else { Join-Path $Root "tools\fixtures\test-face.jpg" }

function Read-EnvKey($key) {
  if (-not (Test-Path $EnvFile)) { return $null }
  foreach ($line in Get-Content $EnvFile) {
    $t = $line.Trim()
    if ($t -match "^$key=(.+)$") { return $matches[1].Trim() }
  }
  return $null
}

$apiKey = $env:OPENAI_API_KEY
if ([string]::IsNullOrWhiteSpace($apiKey)) {
  $apiKey = Read-EnvKey "OPENAI_API_KEY"
}
if ([string]::IsNullOrWhiteSpace($apiKey) -or $apiKey -match "sk-your") {
  Write-Error "Set OPENAI_API_KEY in .env or environment (Edge Function secret value for testing)."
}

if (-not (Test-Path $FixturePath)) {
  Write-Error "Missing fixture: $FixturePath — run from repo root after fixtures are created."
}

$model = if ($Model) { $Model } else { Read-EnvKey "OPENAI_MODEL" }
if ([string]::IsNullOrWhiteSpace($model) -or $model -match "your_") {
  $model = "gpt-4o-mini"
}

$bytes = [IO.File]::ReadAllBytes($FixturePath)
$b64 = [Convert]::ToBase64String($bytes)
Write-Host "Fixture: $FixturePath ($($bytes.Length) bytes), model: $model"
Write-Host ""

$baseSystem =
  "You are a facial analysis assistant for Verified Glam. Output ONLY valid JSON. " +
  "Focus on neutral visual observations. No medical claims. " +
  "For normalized face coordinates use 0-1."

$schemas = @{
  GOLDEN_RATIO = 'Return: { "overallScore", "goldenRatioIndex", "ratingLabel", "measurements", "landmarks", "harmonyPercent" }'
  FACE_BEAUTY_ANALYSIS = 'Return: { "beautyScore": number, "subscores": { "symmetry", "featureBalance", "skinQuality", "youthfulCues", "overallBeauty" }, "annotations": [{ "text", "anchor": {x,y}, "labelSide" }] }'
  BEAUTY_TIPS = 'Return: { "spots": [{ "id", "categoryId", "label", "anchor": {x,y}, "severity", "labelSide" }], "findings": [], "summary", "globalDisclaimer" }'
  COLOR_ANALYSIS = 'Return: { "season": string, "skin": hex, "palette": [hex...], "description": string }'
}

$features = @("GOLDEN_RATIO", "FACE_BEAUTY_ANALYSIS", "BEAUTY_TIPS", "COLOR_ANALYSIS")
$failed = 0

foreach ($feature in $features) {
  Write-Host "=== $feature ===" -ForegroundColor Cyan
  $system = "$baseSystem`n`nFeature: $feature`nSchema: $($schemas[$feature])"
  $userText = "Analyze this portrait for $feature. Return JSON only."

  $body = @{
    model = $model
    response_format = @{ type = "json_object" }
    messages = @(
      @{ role = "system"; content = $system }
      @{
        role = "user"
        content = @(
          @{ type = "text"; text = $userText }
          @{
            type = "image_url"
            image_url = @{
              url = "data:image/jpeg;base64,$b64"
              detail = "low"
            }
          }
        )
      }
    )
    max_tokens = 2048
  } | ConvertTo-Json -Depth 10 -Compress

  try {
    $res = Invoke-RestMethod -Uri "https://api.openai.com/v1/chat/completions" `
      -Method POST `
      -Headers @{
        Authorization = "Bearer $apiKey"
        "Content-Type" = "application/json"
      } `
      -Body $body

    $choice = $res.choices[0]
    $content = $choice.message.content
    $finish = $choice.finish_reason
    $refusal = $choice.message.refusal

    if ([string]::IsNullOrWhiteSpace($content)) {
      Write-Host "FAIL: empty content finish_reason=$finish refusal=$refusal" -ForegroundColor Red
      $failed++
      continue
    }

    $null = $content | ConvertFrom-Json
    $preview = if ($content.Length -gt 120) { $content.Substring(0, 120) + "..." } else { $content }
    Write-Host "PASS finish_reason=$finish len=$($content.Length)" -ForegroundColor Green
    Write-Host "  $preview"
  } catch {
    Write-Host "FAIL: $($_.Exception.Message)" -ForegroundColor Red
    $failed++
  }
  Write-Host ""
}

if ($failed -gt 0) {
  Write-Error "$failed feature(s) failed. Fix OpenAI key/model/billing before phone testing."
}
Write-Host "All $($features.Count) features passed." -ForegroundColor Green
