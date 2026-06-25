# Shared Keycloak admin helpers for demo setup scripts.
# Dot-source from other scripts: . "$PSScriptRoot/_keycloak.ps1"

$script:DemoRoot = Split-Path -Parent $PSScriptRoot
$script:KcBaseUrl = "http://localhost:8080"
$script:KcRealm = "company"

function Test-DockerRunning {
  # docker info writes WARNING lines to stderr; with $ErrorActionPreference = "Stop"
  # those become terminating errors and falsely report Docker as down.
  $prev = $ErrorActionPreference
  try {
    $ErrorActionPreference = "Continue"
    $null = docker version --format "{{.Server.Version}}" 2>$null
    return $LASTEXITCODE -eq 0
  } finally {
    $ErrorActionPreference = $prev
  }
}

function Get-KcContainer {
  Push-Location $script:DemoRoot
  try {
    $id = docker compose ps -q keycloak 2>$null
    if (-not $id) { throw "Keycloak container not found. Run: docker compose up -d" }
    return $id.Trim()
  } finally {
    Pop-Location
  }
}

function Wait-KeycloakReady {
  param([int]$MaxAttempts = 60)
  Write-Host "Waiting for Keycloak at $script:KcBaseUrl ..."
  for ($i = 0; $i -lt $MaxAttempts; $i++) {
    try {
      $r = Invoke-WebRequest -Uri "$script:KcBaseUrl/health/ready" -UseBasicParsing -TimeoutSec 3
      if ($r.StatusCode -eq 200) { return }
    } catch {}
    Start-Sleep -Seconds 3
  }
  throw "Keycloak not ready. Start Docker Desktop, then: docker compose up -d"
}

function Connect-KcAdmin {
  $kc = Get-KcContainer
  if (Test-Path (Join-Path $script:DemoRoot "setup/Read-DemoEnv.ps1")) {
    . (Join-Path $script:DemoRoot "setup/Read-DemoEnv.ps1") | Out-Null
    $demoEnv = Get-DemoEnv -Root $script:DemoRoot
    $adminUser = $demoEnv.KEYCLOAK_ADMIN_USER
    $adminPass = $demoEnv.KEYCLOAK_ADMIN_PASSWORD
  } else {
    $adminUser = "admin"
    $adminPass = "admin"
  }
  $prev = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  try {
    docker exec $kc /opt/keycloak/bin/kcadm.sh config credentials `
      --server $script:KcBaseUrl --realm master --user $adminUser --password $adminPass 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "kcadm login failed" }
  } finally {
    $ErrorActionPreference = $prev
  }
  return $kc
}

function Invoke-Kcadm {
  param(
    [Parameter(Mandatory)][string[]]$Args,
    [string]$Realm = $script:KcRealm
  )
  $kc = Get-KcContainer
  $all = @("/opt/keycloak/bin/kcadm.sh") + $Args
  if ($Realm -and ($Args -notcontains "-r") -and ($Args[0] -notmatch "^(config|create|get|update|delete)")) {
    # no-op; callers pass -r explicitly
  }
  $output = docker exec $kc @all 2>&1
  if ($LASTEXITCODE -ne 0) {
    throw "kcadm failed: $($Args -join ' ')`n$output"
  }
  return $output
}

function Test-KcClientExists {
  param([string]$ClientId)
  $kc = Get-KcContainer
  $prev = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  try {
    $out = docker exec $kc /opt/keycloak/bin/kcadm.sh get clients -r $script:KcRealm -q clientId=$ClientId --fields id 2>&1 | Out-String
    return ($out -match '"id"')
  } finally {
    $ErrorActionPreference = $prev
  }
}

function Get-KcClientInternalId {
  param([string]$ClientId)
  $kc = Get-KcContainer
  $prev = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  try {
    $out = docker exec $kc /opt/keycloak/bin/kcadm.sh get clients -r $script:KcRealm -q clientId=$ClientId --fields id 2>&1 | Out-String
    $m = $out | Select-String -Pattern '"id"\s*:\s*"([^"]+)"'
    if ($m) { return $m.Matches[0].Groups[1].Value }
    return $null
  } finally {
    $ErrorActionPreference = $prev
  }
}

function Get-KcClientSecret {
  param([string]$InternalId)
  $kc = Get-KcContainer
  $prev = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  try {
    $out = docker exec $kc /opt/keycloak/bin/kcadm.sh get "clients/$InternalId/client-secret" -r $script:KcRealm 2>&1 | Out-String
    $m = $out | Select-String -Pattern '"value"\s*:\s*"([^"]+)"'
    if ($m) { return $m.Matches[0].Groups[1].Value }
    return $null
  } finally {
    $ErrorActionPreference = $prev
  }
}

function Write-IntegrationPack {
  param(
    [object]$App,
    [string]$InternalId = $null,
    [string]$ClientSecret = $null
  )
  $packDir = Join-Path $script:DemoRoot "integration-packs"
  New-Item -ItemType Directory -Force -Path $packDir | Out-Null

  $issuer = "$script:KcBaseUrl/realms/$script:KcRealm"
  $pack = [ordered]@{
    applicationName = $App.name
    clientId        = $App.clientId
    protocol        = $App.protocol.ToUpper()
    realm           = $script:KcRealm
    generatedAt     = (Get-Date).ToString("o")
  }

  if ($App.protocol -eq "oidc") {
    $pack.issuer = $issuer
    $pack.discoveryUrl = "$issuer/.well-known/openid-configuration"
    $pack.authorizationEndpoint = "$issuer/protocol/openid-connect/auth"
    $pack.tokenEndpoint = "$issuer/protocol/openid-connect/token"
    $pack.endSessionEndpoint = "$issuer/protocol/openid-connect/logout"
    $pack.redirectUris = $App.redirectUris
    $pack.scopes = @("openid", "profile", "email")
    $pack.publicClient = [bool]$App.publicClient
    if ($ClientSecret) { $pack.clientSecret = $ClientSecret }
    $pack.instructions = "Give this pack to the application team. They configure their app with discovery URL and client ID."
  } else {
    $pack.samlMetadataUrl = "$issuer/protocol/saml/descriptor"
    $pack.entityId = $issuer
    $pack.redirectUris = $App.redirectUris
    $pack.instructions = "Import IdP metadata XML from samlMetadataUrl into the vendor admin console (ServiceDesk, Temenos, etc.)."
  }

  $path = Join-Path $packDir "$($App.clientId).json"
  $pack | ConvertTo-Json -Depth 6 | Set-Content -Path $path -Encoding UTF8
  Write-Host "  Integration pack: $path"
}
