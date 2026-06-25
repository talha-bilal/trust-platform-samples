# Fresh install: wipe data, deploy stack, seed directory, register clients, apply branding.
# Usage:
#   1. Copy .env.example to .env and edit (company name, cloud URL, passwords)
#   2. powershell -ExecutionPolicy Bypass -File setup/fresh-deploy.ps1
#   3. powershell -ExecutionPolicy Bypass -File setup/fresh-deploy.ps1 -SkipMfa

param([switch]$SkipMfa)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
. "$PSScriptRoot/_keycloak.ps1"
. "$PSScriptRoot/Read-DemoEnv.ps1"

Push-Location $root

if (-not (Test-Path ".env")) {
  Copy-Item ".env.example" ".env"
  Write-Host "Created .env from .env.example — edit COMPANY_DISPLAY_NAME and PUBLIC_HOST, then run again."
  Pop-Location
  exit 0
}

if (-not (Test-DockerRunning)) {
  Write-Host "Start Docker Desktop first."
  Pop-Location
  exit 1
}

Write-Host "=== Fresh deploy (all data wiped) ===" -ForegroundColor Cyan
docker compose down -v

& "$PSScriptRoot/render-tenant-config.ps1"

Write-Host "Starting containers..."
docker compose --env-file .env up -d

& "$PSScriptRoot/seed-ldap.ps1"
& "$PSScriptRoot/configure-ldap.ps1"

$genIntake = Join-Path $PSScriptRoot "apps-intake.generated.json"
& "$PSScriptRoot/register-clients-from-intake.ps1" -IntakeFile $genIntake

& "$PSScriptRoot/configure-branding.ps1"

if (-not $SkipMfa) {
  try { & "$PSScriptRoot/configure-mfa.ps1" } catch { Write-Host "MFA setup skipped: $_" }
}

$urls = Get-DemoUrls
$env = Get-DemoEnv

Write-Host ""
Write-Host "=== Deploy complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "  App launcher  $($urls.Launcher)"
Write-Host "  Keycloak admin $($urls.Keycloak)  ($($env.KEYCLOAK_ADMIN_USER) / see .env)"
Write-Host ""
Write-Host "  Admin operations: ADMIN-OPERATIONS-GUIDE.md"
Write-Host "  Cloud guide:      CLOUD-DEPLOYMENT.md"
Write-Host "  Login test user:  ahmed / Demo@123"
Write-Host ""

Pop-Location
