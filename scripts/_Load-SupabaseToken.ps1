# Dot-source: loads SUPABASE_ACCESS_TOKEN from param, existing env, or .env
param(
  [string]$AccessToken = "",
  [string]$Root = ""
)

if ([string]::IsNullOrWhiteSpace($Root)) {
  $Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
}

if (-not [string]::IsNullOrWhiteSpace($AccessToken)) {
  $env:SUPABASE_ACCESS_TOKEN = $AccessToken.Trim()
}

if ([string]::IsNullOrWhiteSpace($env:SUPABASE_ACCESS_TOKEN)) {
  foreach ($file in @(".env", ".env.local")) {
    $path = Join-Path $Root $file
    if (-not (Test-Path $path)) { continue }
    Get-Content $path | ForEach-Object {
      $line = $_.Trim()
      if ($line -match '^SUPABASE_ACCESS_TOKEN=(.+)$') {
        $val = $matches[1].Trim()
        if ($val -and $val -notmatch "your_" -and $val -notmatch "paste_your") {
          $env:SUPABASE_ACCESS_TOKEN = $val
        }
      }
    }
  }
}

function Test-SupabaseAccessToken {
  if ([string]::IsNullOrWhiteSpace($env:SUPABASE_ACCESS_TOKEN)) {
    return $false
  }
  return $true
}

function Assert-SupabaseAccessToken {
  if (-not (Test-SupabaseAccessToken)) {
    Write-Error @"
Missing SUPABASE_ACCESS_TOKEN.

Add to beauty-free/.env (gitignored, dev machine only):
  SUPABASE_ACCESS_TOKEN=sbp_...

Get token: https://supabase.com/dashboard/account/tokens

Or run once without saving:
  .\scripts\setup-fcm-push.ps1 -AccessToken 'sbp_...'
"@
  }
}
