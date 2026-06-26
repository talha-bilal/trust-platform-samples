# Verifies the deploy package is healthy after fresh-deploy or start-demo.
# Usage: powershell -File setup/package-verify.ps1

$ErrorActionPreference = "Continue"
. "$PSScriptRoot/Read-DemoEnv.ps1"

$root = Split-Path -Parent $PSScriptRoot
$urls = Get-DemoUrls
$demoCfg = Get-DemoEnv
$ok = 0
$fail = 0

function Test-Endpoint {
  param([string]$Name, [string]$Url, [int]$ExpectStatus = 200)
  try {
    $r = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 10
    if ($r.StatusCode -eq $ExpectStatus) {
      Write-Host "[OK]   $Name - $Url" -ForegroundColor Green
      $script:ok++
    } else {
      Write-Host "[FAIL] $Name - $Url (status $($r.StatusCode))" -ForegroundColor Red
      $script:fail++
    }
  } catch {
    Write-Host "[FAIL] $Name - $Url ($($_.Exception.Message))" -ForegroundColor Red
    $script:fail++
  }
}

Write-Host "=== IAM Demo Package Verification ===" -ForegroundColor Cyan
Write-Host "Company : $($urls.CompanyName)"
Write-Host "Realm   : $($urls.Realm)"
Write-Host ""

Push-Location $root
try {
  . "$PSScriptRoot/_keycloak.ps1" | Out-Null
  if (Test-DockerRunning) {
    Write-Host "[OK]   Docker running" -ForegroundColor Green
    $ok++
    $ps = docker compose ps --format json 2>$null | ConvertFrom-Json
    $running = @($ps | Where-Object { $_.State -eq "running" }).Count
    Write-Host "       Containers running: $running"
  } else {
    Write-Host "[FAIL] Docker not running" -ForegroundColor Red
    $fail++
  }
} catch {
  Write-Host "[FAIL] Docker check - $_" -ForegroundColor Red
  $fail++
}
Pop-Location

$tenantFile = Join-Path $root "demo-apps\config\tenant.json"
if (Test-Path $tenantFile) {
  Write-Host "[OK]   tenant.json exists" -ForegroundColor Green
  $ok++
} else {
  Write-Host "[FAIL] tenant.json missing - run render-tenant-config.ps1" -ForegroundColor Red
  $fail++
}

Test-Endpoint "Keycloak health" "$($urls.Keycloak)/health/ready"
Test-Endpoint "App launcher" "$($urls.Launcher)/"
Test-Endpoint "HR Portal" "$($urls.HrPortal)/"
Test-Endpoint "Finance Portal" "$($urls.FinancePortal)/"
Test-Endpoint "Tenant config" "$($urls.Launcher)/config/tenant.json"

Write-Host ""
if ($fail -eq 0) {
  Write-Host "All checks passed - $ok OK." -ForegroundColor Green
  Write-Host ""
  Write-Host "  Launcher : $($urls.Launcher)"
  $adminUser = $demoCfg.KEYCLOAK_ADMIN_USER
  Write-Host "  Admin    : $($urls.Keycloak)  (user: $adminUser)"
  Write-Host "  Login    : ahmed / Demo@123"
  exit 0
} else {
  Write-Host "$fail check(s) failed. Run fresh-deploy.ps1 with -SkipMfa" -ForegroundColor Yellow
  exit 1
}
