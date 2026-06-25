# Registers OIDC/SAML clients from JSON intake and writes integration packs.
# Run after Keycloak is up and LDAP is configured.
# Usage: powershell -File setup/register-clients-from-intake.ps1
#        powershell -File setup/register-clients-from-intake.ps1 -IntakeFile setup/apps-intake.example.json

param(
  [string]$IntakeFile = (Join-Path $PSScriptRoot "apps-intake.example.json")
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot/_keycloak.ps1"

if (-not (Test-Path $IntakeFile)) { throw "Intake file not found: $IntakeFile" }

Wait-KeycloakReady
Connect-KcAdmin | Out-Null

$apps = Get-Content $IntakeFile -Raw | ConvertFrom-Json
Write-Host "Registering $($apps.Count) applications from intake..."

foreach ($app in $apps) {
  $cid = $app.clientId
  if (Test-KcClientExists -ClientId $cid) {
    Write-Host "  [skip] $cid already registered"
    $kc = Get-KcContainer
    $json = docker exec $kc /opt/keycloak/bin/kcadm.sh get clients -r company -q clientId=$cid --fields id
    $internalId = ($json | Select-String '"id"\s*:\s*"([^"]+)"').Matches[0].Groups[1].Value
    $secret = $null
    if ($app.protocol -eq "oidc" -and -not $app.publicClient) {
      $secret = Get-KcClientSecret -InternalId $internalId
    }
    Write-IntegrationPack -App $app -InternalId $internalId -ClientSecret $secret
    continue
  }

  $kc = Get-KcContainer
  if ($app.protocol -eq "oidc") {
    $public = if ($null -ne $app.publicClient) { $app.publicClient } else { $true }
    $redirects = ($app.redirectUris | ForEach-Object { $_ }) -join '","'
    $origins = if ($app.webOrigins) { ($app.webOrigins | ForEach-Object { $_ }) -join '","' } else { "+" }

    docker exec $kc /opt/keycloak/bin/kcadm.sh create clients -r company `
      -s clientId=$cid `
      -s name="$($app.name)" `
      -s enabled=true `
      -s protocol=openid-connect `
      -s publicClient=$($public.ToString().ToLower()) `
      -s standardFlowEnabled=true `
      -s directAccessGrantsEnabled=false `
      -s "redirectUris=[`"$redirects`"]" `
      -s "webOrigins=[`"$origins`"]" `
      -s 'attributes.pkce.code.challenge.method=S256' | Out-Null

    Write-Host "  [oidc] Created $cid"
  } elseif ($app.protocol -eq "saml") {
    $redirects = ($app.redirectUris | ForEach-Object { $_ }) -join '","'
    $root = if ($app.rootUrl) { $app.rootUrl } else { "https://placeholder.company.local" }

    docker exec $kc /opt/keycloak/bin/kcadm.sh create clients -r company `
      -s clientId=$cid `
      -s name="$($app.name)" `
      -s enabled=true `
      -s protocol=saml `
      -s "redirectUris=[`"$redirects`"]" `
      -s rootUrl=$root `
      -s 'attributes.saml.assertion.signature=false' | Out-Null

    Write-Host "  [saml] Created $cid"
  } else {
    throw "Unknown protocol for $cid : $($app.protocol)"
  }

  $json = docker exec $kc /opt/keycloak/bin/kcadm.sh get clients -r company -q clientId=$cid --fields id
  $internalId = ($json | Select-String '"id"\s*:\s*"([^"]+)"').Matches[0].Groups[1].Value
  $secret = $null
  if ($app.protocol -eq "oidc" -and -not $app.publicClient) {
    docker exec $kc /opt/keycloak/bin/kcadm.sh create "clients/$internalId/client-secret" -r company | Out-Null
    $secret = Get-KcClientSecret -InternalId $internalId
  }
  Write-IntegrationPack -App $app -InternalId $internalId -ClientSecret $secret
}

Write-Host ""
Write-Host "All clients processed. Integration packs in: integration-packs/"
Write-Host "View in admin: http://localhost:8080 -> realm company -> Clients"
