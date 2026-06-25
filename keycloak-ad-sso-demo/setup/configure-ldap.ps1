# Waits for Keycloak, attaches LDAP federation (AD-style), syncs demo users.
# Run from keycloak-ad-sso-demo/ after: docker compose up -d

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$ldapJson = Join-Path $PSScriptRoot "ldap-federation.json"
Push-Location $root

Write-Host "Waiting for Keycloak on http://localhost:8080 ..."
$ready = $false
for ($i = 0; $i -lt 60; $i++) {
  try {
    $r = Invoke-WebRequest -Uri "http://localhost:8080/health/ready" -UseBasicParsing -TimeoutSec 3
    if ($r.StatusCode -eq 200) { $ready = $true; break }
  } catch {}
  Start-Sleep -Seconds 3
}
if (-not $ready) { throw "Keycloak not ready. Check: docker compose logs keycloak" }

$kc = docker compose ps -q keycloak
if (-not $kc) { throw "Keycloak container not found. Run docker compose up -d first." }

$prevEa = $ErrorActionPreference
$ErrorActionPreference = "Continue"

Write-Host "Configuring admin credentials..."
. "$PSScriptRoot/Read-DemoEnv.ps1" | Out-Null
$demoEnv = Get-DemoEnv -Root $root
docker exec $kc /opt/keycloak/bin/kcadm.sh config credentials `
  --server http://localhost:8080 --realm master --user $demoEnv.KEYCLOAK_ADMIN_USER --password $demoEnv.KEYCLOAK_ADMIN_PASSWORD 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) { throw "kcadm login failed" }

$existing = docker exec $kc /opt/keycloak/bin/kcadm.sh get components -r company -q name=company-ldap --fields id 2>&1 | Out-String
if ($existing -match '"id"\s*:') {
  Write-Host "LDAP federation already exists - syncing users..."
} else {
  Write-Host "Creating LDAP user federation (same model as Active Directory)..."
  $null = docker cp $ldapJson "${kc}:/tmp/ldap-federation.json" 2>&1
  docker exec $kc /opt/keycloak/bin/kcadm.sh create components -r company -f /tmp/ldap-federation.json 2>&1 | Out-Null
  if ($LASTEXITCODE -ne 0) { throw "LDAP federation create failed. Check: docker compose logs keycloak" }
}

$json = docker exec $kc /opt/keycloak/bin/kcadm.sh get components -r company -q name=company-ldap --fields id 2>&1 | Out-String
$id = ($json | Select-String -Pattern '"id"\s*:\s*"([^"]+)"').Matches[0].Groups[1].Value
if (-not $id) { throw "Could not resolve LDAP component id" }

Write-Host "Syncing directory users into Keycloak..."
docker exec $kc /opt/keycloak/bin/kcadm.sh create "user-storage/$id/sync" -r company -s action=triggerFullSync 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
  Write-Host "  Bulk sync skipped (users still import on first login with importEnabled=true)."
}

$ErrorActionPreference = $prevEa

Write-Host ""
Write-Host "Demo ready."
Write-Host "  Application hub : http://localhost:3000  (start here - 8 apps)"
Write-Host "  Keycloak admin  : http://localhost:8080  (admin / admin)"
Write-Host "  HR Portal       : http://localhost:3001  (login: ahmed / Demo@123)"
Write-Host "  Finance Portal  : http://localhost:3002  (SSO - no second login)"
Write-Host ""
Write-Host "Full guide: DEMO-SETUP-GUIDE.md"
Write-Host "Presenter:  DEMO-WALKTHROUGH.md"

Pop-Location
