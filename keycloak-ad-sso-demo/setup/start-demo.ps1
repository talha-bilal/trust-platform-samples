# One-command demo startup (Windows).
# Usage:
#   powershell -File setup/start-demo.ps1
#   powershell -File setup/start-demo.ps1 -SkipMfa
#   powershell -File setup/start-demo.ps1 -Reset

param(
  [switch]$SkipMfa,
  [switch]$Reset
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
. "$PSScriptRoot/_keycloak.ps1"

Push-Location $root

Write-Host "=== Keycloak AD + SSO Demo ===" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-DockerRunning)) {
  Write-Host "Docker is not running." -ForegroundColor Red
  Write-Host "1. Start Docker Desktop"
  Write-Host "2. Wait until it shows 'Running'"
  Write-Host "3. Run this script again"
  Pop-Location
  exit 1
}

if ($Reset) {
  Write-Host "Resetting demo (removes volumes)..."
  docker compose down -v
}

Write-Host "Starting containers (Keycloak, PostgreSQL, LDAP, demo apps)..."
if (Test-Path (Join-Path $root ".env")) {
  docker compose --env-file .env up -d
  & "$PSScriptRoot/render-tenant-config.ps1"
} else {
  docker compose up -d
  & "$PSScriptRoot/render-tenant-config.ps1"
}

& "$PSScriptRoot/seed-ldap.ps1"
& "$PSScriptRoot/configure-ldap.ps1"
$intakeFile = "$PSScriptRoot/apps-intake.example.json"
if (Test-Path "$PSScriptRoot/apps-intake.generated.json") {
  $intakeFile = "$PSScriptRoot/apps-intake.generated.json"
}
& "$PSScriptRoot/register-clients-from-intake.ps1" -IntakeFile $intakeFile

if (Test-Path (Join-Path $root ".env")) {
  try { & "$PSScriptRoot/configure-branding.ps1" } catch {}
}

if (-not $SkipMfa) {
  try {
    & "$PSScriptRoot/configure-mfa.ps1"
  } catch {
    Write-Host "MFA setup skipped (non-fatal): $_" -ForegroundColor Yellow
  }
}

Write-Host ""
Write-Host "=== Demo is ready ===" -ForegroundColor Green
Write-Host ""
Write-Host "  START HERE     http://localhost:3000   Application launcher (8 apps)"
Write-Host "  HR Portal      http://localhost:3001"
Write-Host "  Finance Portal http://localhost:3002"
Write-Host "  Keycloak admin http://localhost:8080   admin / admin"
Write-Host ""
Write-Host "  Login user     ahmed / Demo@123  (directory password)"
Write-Host "  Alt user       sara  / Demo@123"
Write-Host ""
Write-Host "  Cloud deploy:     CLOUD-DEPLOYMENT.md"
Write-Host "  Admin panel:      ADMIN-OPERATIONS-GUIDE.md"
Write-Host "  Fresh reinstall:  setup/fresh-deploy.ps1"
Write-Host ""

Pop-Location
