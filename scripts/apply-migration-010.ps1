# Apply credit transactions migration (010) via Supabase CLI SQL query.
param(
  [string]$ProjectRef = "qmivgvctmxvpnbouqslj",
  [string]$AccessToken = ""
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
. (Join-Path $Root "scripts\_Load-SupabaseToken.ps1") -AccessToken $AccessToken -Root $Root

$sqlPath = Join-Path $Root "supabase\migrations\010_credit_transactions.sql"
if (-not (Test-Path $sqlPath)) {
  Write-Error "Migration file not found: $sqlPath"
}

if (-not (Test-SupabaseAccessToken)) {
  Write-Host "No SUPABASE_ACCESS_TOKEN - paste this SQL in Supabase Dashboard -> SQL Editor:" -ForegroundColor Yellow
  Write-Host "https://supabase.com/dashboard/project/$ProjectRef/sql/new" -ForegroundColor Cyan
  Write-Host ""
  Get-Content $sqlPath -Raw | Write-Host
  exit 1
}

Set-Location $Root
$configPath = Join-Path $Root "supabase\.temp\project-ref"
$tempDir = Split-Path $configPath -Parent
if (-not (Test-Path $tempDir)) { New-Item -ItemType Directory -Force -Path $tempDir | Out-Null }
Set-Content -Path $configPath -Value $ProjectRef -NoNewline

Write-Host "Applying 010_credit_transactions.sql to $ProjectRef ..."
npx --yes supabase db query --linked -f $sqlPath 2>&1

if ($LASTEXITCODE -ne 0) {
  Write-Host "Query failed - run SQL manually:" -ForegroundColor Yellow
  Write-Host "https://supabase.com/dashboard/project/$ProjectRef/sql/new" -ForegroundColor Cyan
  Get-Content $sqlPath -Raw | Write-Host
  exit $LASTEXITCODE
}

Write-Host "Verifying credit_transactions table ..."
$verifySql = @"
select column_name
from information_schema.columns
where table_schema = 'public'
  and table_name = 'credit_transactions'
order by column_name;
"@
npx --yes supabase db query --linked $verifySql 2>&1

Write-Host "Migration 010 applied (uses IF NOT EXISTS - safe to rerun)."
