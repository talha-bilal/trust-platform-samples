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
docker compose up -d

& "$PSScriptRoot/seed-ldap.ps1"
& "$PSScriptRoot/configure-ldap.ps1"
& "$PSScriptRoot/register-clients-from-intake.ps1"

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
Write-Host "  Presenter script : DEMO-WALKTHROUGH.md"
Write-Host "  Full setup guide : DEMO-SETUP-GUIDE.md"
Write-Host ""

Pop-Location
