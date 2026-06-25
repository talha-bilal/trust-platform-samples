# Waits for Keycloak, attaches LDAP federation (AD-style), syncs demo users.
# Run from keycloak-ad-sso-demo/ after: docker compose up -d

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
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

Write-Host "Configuring admin credentials..."
docker exec $kc /opt/keycloak/bin/kcadm.sh config credentials `
  --server http://localhost:8080 --realm master --user admin --password admin | Out-Null

$existing = docker exec $kc /opt/keycloak/bin/kcadm.sh get components -r company -q name=company-ldap --fields id 2>$null
if ($existing -match '"id"') {
  Write-Host "LDAP federation already exists — syncing users..."
} else {
  Write-Host "Creating LDAP user federation (same model as Active Directory)..."
  $realmJson = docker exec $kc /opt/keycloak/bin/kcadm.sh get realms/company --fields id
  $realmId = ($realmJson | Select-String '"id"\s*:\s*"([^"]+)"').Matches[0].Groups[1].Value
  docker exec $kc /opt/keycloak/bin/kcadm.sh create components -r company `
    -s name=company-ldap `
    -s providerId=ldap `
    -s providerType=org.keycloak.storage.UserStorageProvider `
    -s parentId=$realmId `
    -s 'config.enabled=["true"]' `
    -s 'config.priority=["0"]' `
    -s 'config.editMode=["READ_ONLY"]' `
    -s 'config.syncRegistrations=["false"]' `
    -s 'config.vendor=["other"]' `
    -s 'config.usernameLDAPAttribute=["uid"]' `
    -s 'config.rdnLDAPAttribute=["uid"]' `
    -s 'config.uuidLDAPAttribute=["entryUUID"]' `
    -s 'config.userObjectClasses=["inetOrgPerson, organizationalPerson"]' `
    -s 'config.connectionUrl=["ldap://openldap:389"]' `
    -s 'config.usersDn=["ou=users,dc=company,dc=local"]' `
    -s 'config.bindDn=["cn=admin,dc=company,dc=local"]' `
    -s 'config.bindCredential=["admin"]' `
    -s 'config.searchScope=["1"]' `
    -s 'config.importEnabled=["true"]' `
    -s 'config.pagination=["true"]' | Out-Null
}

$json = docker exec $kc /opt/keycloak/bin/kcadm.sh get components -r company -q name=company-ldap --fields id
$id = ($json | Select-String '"id"\s*:\s*"([^"]+)"').Matches[0].Groups[1].Value
if (-not $id) { throw "Could not resolve LDAP component id" }

Write-Host "Syncing directory users into Keycloak..."
docker exec $kc /opt/keycloak/bin/kcadm.sh create "user-storage/$id/sync" -r company -s action=triggerFullSync | Out-Null

Write-Host ""
Write-Host "Demo ready."
Write-Host "  Application hub : http://localhost:3000  (start here — 8 apps)"
Write-Host "  Keycloak admin  : http://localhost:8080  (admin / admin)"
Write-Host "  HR Portal       : http://localhost:3001  (login: ahmed / Demo@123)"
Write-Host "  Finance Portal  : http://localhost:3002  (SSO — no second login)"
Write-Host ""
Write-Host "Full guide: DEMO-SETUP-GUIDE.md"
Write-Host "Presenter:  DEMO-WALKTHROUGH.md"

Pop-Location
