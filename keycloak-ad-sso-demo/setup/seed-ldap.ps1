# Seeds demo users/groups into OpenLDAP after the container starts.
# Avoids bind-mount issues on Windows Docker Desktop.

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$ldif = Join-Path $root "ldap\bootstrap.ldif"
Push-Location $root

$ldap = docker compose ps -q openldap
if (-not $ldap) { throw "OpenLDAP container not found" }

Write-Host "Waiting for OpenLDAP on port 1389 ..."
$ready = $false
for ($i = 0; $i -lt 40; $i++) {
  try {
    $tcp = New-Object System.Net.Sockets.TcpClient
    $tcp.Connect("localhost", 1389)
    $tcp.Close()
    $ready = $true
    break
  } catch {}
  Start-Sleep -Seconds 2
}
if (-not $ready) { throw "OpenLDAP not ready" }

$prevEa = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$check = docker exec $ldap ldapsearch -x -H ldap://localhost -b "ou=users,dc=company,dc=local" -D "cn=admin,dc=company,dc=local" -w admin "(uid=ahmed)" dn 2>&1 | Out-String
$ErrorActionPreference = $prevEa
if ($check -match "dn:\s*uid=ahmed") {
  Write-Host "LDAP demo users already seeded."
  Pop-Location
  exit 0
}

Write-Host "Seeding demo users and groups into OpenLDAP..."
docker cp $ldif "${ldap}:/tmp/bootstrap.ldif"

$prevEa = $ErrorActionPreference
$ErrorActionPreference = "Continue"
docker exec $ldap ldapadd -x -D "cn=admin,dc=company,dc=local" -w admin -c -f /tmp/bootstrap.ldif 2>&1 | Out-Null
$ErrorActionPreference = $prevEa

Write-Host "LDAP seed complete (ahmed / Demo@123)."
Pop-Location
