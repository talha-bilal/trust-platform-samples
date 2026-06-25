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

$prevEa = $ErrorActionPreference
$ErrorActionPreference = "Continue"

foreach ($app in $apps) {
  $cid = $app.clientId
  if (Test-KcClientExists -ClientId $cid) {
    Write-Host "  [skip] $cid already registered"
    $internalId = Get-KcClientInternalId -ClientId $cid
    $secret = $null
    if ($app.protocol -eq "oidc" -and -not $app.publicClient) {
      $secret = Get-KcClientSecret -InternalId $internalId
    }
    Write-IntegrationPack -App $app -InternalId $internalId -ClientSecret $secret
    continue
  }

  $kc = Get-KcContainer
  $tmpLocal = Join-Path $env:TEMP "kc-client-$cid.json"

  if ($app.protocol -eq "oidc") {
    $public = if ($null -ne $app.publicClient) { $app.publicClient } else { $true }
    $origins = if ($app.webOrigins) { @($app.webOrigins) } else { @("+") }
    $payload = [ordered]@{
      clientId                 = $cid
      name                     = $app.name
      enabled                  = $true
      protocol                 = "openid-connect"
      publicClient             = $public
      standardFlowEnabled      = $true
      directAccessGrantsEnabled = $false
      redirectUris             = @($app.redirectUris)
      webOrigins               = $origins
      attributes               = @{ "pkce.code.challenge.method" = "S256" }
    }
    $json = $payload | ConvertTo-Json -Depth 6
    [System.IO.File]::WriteAllText($tmpLocal, $json)
    $null = docker cp $tmpLocal "${kc}:/tmp/kc-client.json" 2>&1
    $null = docker exec $kc /opt/keycloak/bin/kcadm.sh create clients -r company -f /tmp/kc-client.json 2>&1
    Write-Host "  [oidc] Created $cid"
  } elseif ($app.protocol -eq "saml") {
    $root = if ($app.rootUrl) { $app.rootUrl } else { "https://placeholder.company.local" }
    $payload = [ordered]@{
      clientId    = $cid
      name        = $app.name
      enabled     = $true
      protocol    = "saml"
      redirectUris = @($app.redirectUris)
      rootUrl     = $root
      attributes  = @{ "saml.assertion.signature" = "false" }
    }
    $json = $payload | ConvertTo-Json -Depth 6
    [System.IO.File]::WriteAllText($tmpLocal, $json)
    $null = docker cp $tmpLocal "${kc}:/tmp/kc-client.json" 2>&1
    $null = docker exec $kc /opt/keycloak/bin/kcadm.sh create clients -r company -f /tmp/kc-client.json 2>&1
    Write-Host "  [saml] Created $cid"
  } else {
    throw "Unknown protocol for $cid : $($app.protocol)"
  }

  Remove-Item $tmpLocal -ErrorAction SilentlyContinue

  $internalId = Get-KcClientInternalId -ClientId $cid
  if (-not $internalId) { throw "Could not resolve internal id for $cid" }
  $secret = $null
  if ($app.protocol -eq "oidc" -and -not $app.publicClient) {
    docker exec $kc /opt/keycloak/bin/kcadm.sh create "clients/$internalId/client-secret" -r company | Out-Null
    $secret = Get-KcClientSecret -InternalId $internalId
  }
  Write-IntegrationPack -App $app -InternalId $internalId -ClientSecret $secret
}

$ErrorActionPreference = $prevEa

Write-Host ""
Write-Host "All clients processed. Integration packs in: integration-packs/"
Write-Host "View in admin: http://localhost:8080 -> realm company -> Clients"
