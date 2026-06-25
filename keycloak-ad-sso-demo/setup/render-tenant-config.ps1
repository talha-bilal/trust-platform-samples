# Writes demo-apps/config/tenant.json and apps-intake.generated.json from .env + intake template.
. "$PSScriptRoot/Read-DemoEnv.ps1"

$root = Split-Path -Parent $PSScriptRoot
$urls = Get-DemoUrls
$env = Get-DemoEnv
$configDir = Join-Path $root "demo-apps\config"
New-Item -ItemType Directory -Force -Path $configDir | Out-Null

$intakeTemplate = Join-Path $PSScriptRoot "apps-intake.example.json"
$intake = Get-Content $intakeTemplate -Raw | ConvertFrom-Json

$liveMap = @{
  "app-launcher"   = @{ live = $true; url = "$($urls.Launcher)/" }
  "hr-portal"      = @{ live = $true; url = "$($urls.HrPortal)/" }
  "finance-portal" = @{ live = $true; url = "$($urls.FinancePortal)/" }
}

$displayApps = @()
$generatedIntake = @()

foreach ($app in $intake) {
  $cid = $app.clientId
  $isLive = $liveMap.ContainsKey($cid)
  $liveInfo = if ($isLive) { $liveMap[$cid] } else { $null }

  if ($isLive) {
    $port = switch ($cid) {
      "app-launcher" { $env.APP_LAUNCHER_PORT }
      "hr-portal" { $env.HR_PORTAL_PORT }
      "finance-portal" { $env.FINANCE_PORTAL_PORT }
      default { "3000" }
    }
    $base = "$($env.PUBLIC_HOST.TrimEnd('/'))`:$port"
    $app.redirectUris = @("$base/*")
    $app.webOrigins = @($base)
  }

  $generatedIntake += $app

  if ($cid -eq "app-launcher") { continue }

  $displayApps += [ordered]@{
    name     = $app.name
    protocol = $app.protocol.ToUpper()
    clientId = $cid
    live     = [bool]$isLive
    url      = if ($liveInfo) { $liveInfo.url } else { $null }
  }
}

$tenant = [ordered]@{
  companyName  = $urls.CompanyName
  realm        = $urls.Realm
  keycloakUrl  = $urls.Keycloak
  launcherUrl  = $urls.Launcher
  apps         = $displayApps
}

$tenantPath = Join-Path $configDir "tenant.json"
[System.IO.File]::WriteAllText($tenantPath, ($tenant | ConvertTo-Json -Depth 6))

$genIntakePath = Join-Path $PSScriptRoot "apps-intake.generated.json"
[System.IO.File]::WriteAllText($genIntakePath, ($generatedIntake | ConvertTo-Json -Depth 6))

Write-Host "Generated: $tenantPath"
Write-Host "Generated: $genIntakePath"
Write-Host "  Keycloak URL : $($urls.Keycloak)"
Write-Host "  Company name : $($urls.CompanyName)"
