# Applies company display name to Keycloak realm (login page + admin).
. "$PSScriptRoot/_keycloak.ps1"
. "$PSScriptRoot/Read-DemoEnv.ps1"

Wait-KeycloakReady
Connect-KcAdmin | Out-Null
$kc = Get-KcContainer
$env = Get-DemoEnv
$realm = $env.REALM_NAME
$name = $env.COMPANY_DISPLAY_NAME

$prev = $ErrorActionPreference
$ErrorActionPreference = "Continue"
docker exec $kc /opt/keycloak/bin/kcadm.sh update "realms/$realm" `
  -s "displayName=$name" 2>&1 | Out-Null
$ErrorActionPreference = $prev

Write-Host "Realm '$realm' branding set to: $name"
Write-Host "Change anytime in Admin -> Realm settings -> General"
