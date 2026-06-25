# Apply streak notification kind migration (007) via Supabase CLI.
param(
  [string]$ProjectRef = "qmivgvctmxvpnbouqslj",
  [string]$AccessToken = ""
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
. (Join-Path $Root "scripts\_Load-SupabaseToken.ps1") -AccessToken $AccessToken -Root $Root

$sqlPath = Join-Path $Root "supabase\migrations\007_notification_streak_kind.sql"
if (-not (Test-Path $sqlPath)) {
  Write-Error "Migration file not found: $sqlPath"
}

if (-not (Test-SupabaseAccessToken)) {
  Write-Host "No SUPABASE_ACCESS_TOKEN - paste this SQL in Supabase Dashboard -> SQL Editor:" -ForegroundColor Yellow
  Write-Host ""
  Get-Content $sqlPath -Raw | Write-Host
  Write-Host ""
  Write-Host "Add SUPABASE_ACCESS_TOKEN to .env and rerun, or run the SQL above manually." -ForegroundColor Yellow
  exit 1
}

Set-Location $Root
$configPath = Join-Path $Root "supabase\.temp\project-ref"
$tempDir = Split-Path $configPath -Parent
if (-not (Test-Path $tempDir)) { New-Item -ItemType Directory -Force -Path $tempDir | Out-Null }
Set-Content -Path $configPath -Value $ProjectRef -NoNewline

Write-Host "Pushing migrations to $ProjectRef ..."
npx --yes supabase db push --yes 2>&1

if ($LASTEXITCODE -ne 0) {
  Write-Host "db push failed - run this SQL in Dashboard -> SQL Editor:" -ForegroundColor Yellow
  Get-Content $sqlPath -Raw | Write-Host
  exit $LASTEXITCODE
}

Write-Host "Migration 007 applied (or already up to date)."
