# Upload Firebase Admin SDK JSON to Supabase secret FCM_SERVICE_ACCOUNT_JSON.
# Uses Node to minify JSON (PowerShell ConvertTo-Json can corrupt private_key).
# Requires SUPABASE_ACCESS_TOKEN in .env OR npx supabase login.
#   .\scripts\set-fcm-service-account-secret.ps1 -JsonPath "C:\path\to\verified-glam-firebase-adminsdk-....json"
param(
  [Parameter(Mandatory = $true)]
  [string]$JsonPath,
  [string]$ProjectRef = "qmivgvctmxvpnbouqslj",
  [string]$AccessToken = ""
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
. (Join-Path $Root "scripts\_Load-SupabaseToken.ps1") -AccessToken $AccessToken -Root $Root
Assert-SupabaseAccessToken

if (-not (Test-Path $JsonPath)) {
  Write-Error "File not found: $JsonPath"
}

$parsed = Get-Content $JsonPath -Raw | ConvertFrom-Json
if ($parsed.type -ne "service_account") {
  Write-Error @"
Expected Firebase service account JSON (type=service_account).
Do NOT use this script for the legacy Cloud Messaging Server key string.
Legacy API is disabled — use HTTP v1 with this Admin SDK JSON only.
"@
}

if ($parsed.project_id -ne "verified-glam") {
  Write-Warning "project_id is '$($parsed.project_id)' but android/app/google-services.json uses 'verified-glam'. Mismatch will break push."
}

$envFile = Join-Path $env:TEMP "vg-fcm-secret-$([guid]::NewGuid().ToString('N')).env"
try {
  $node = Get-Command node -ErrorAction SilentlyContinue
  if ($node) {
    $escapedPath = $JsonPath.Replace("\", "\\").Replace("'", "\'")
    $minified = node -e "process.stdout.write(JSON.stringify(JSON.parse(require('fs').readFileSync('$escapedPath','utf8'))))"
  } else {
    Write-Warning "Node not found; using PowerShell JSON minify (verify OAuth after deploy)."
    $minified = ($parsed | ConvertTo-Json -Compress -Depth 10)
  }

  Set-Content -Path $envFile -Value "FCM_SERVICE_ACCOUNT_JSON=$minified" -Encoding UTF8 -NoNewline
  Write-Host "Setting FCM_SERVICE_ACCOUNT_JSON on project $ProjectRef (HTTP v1) ..."
  npx --yes supabase secrets set --env-file $envFile --project-ref $ProjectRef
  if ($LASTEXITCODE -ne 0) {
    Write-Error @"
supabase secrets set failed.
- Add SUPABASE_ACCESS_TOKEN to .env (https://supabase.com/dashboard/account/tokens), or
- npx supabase login
- Or paste JSON manually: Dashboard -> Edge Functions -> Secrets -> FCM_SERVICE_ACCOUNT_JSON
"@
  }
  Write-Host "Secret set. Redeploy push functions:"
  Write-Host "  .\scripts\deploy-challenge-push-functions.ps1"
} finally {
  if (Test-Path $envFile) { Remove-Item $envFile -Force }
}
