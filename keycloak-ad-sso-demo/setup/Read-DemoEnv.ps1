# Load variables from .env in the demo root (simple KEY=VALUE parser).
# Usage: . "$PSScriptRoot/Read-DemoEnv.ps1"

function Get-DemoEnv {
  param([string]$Root = (Split-Path -Parent $PSScriptRoot))
  $file = Join-Path $Root ".env"
  $defaults = @{
    COMPANY_DISPLAY_NAME = "IAM Demo"
    REALM_NAME           = "company"
    PUBLIC_HOST          = "http://localhost"
    KEYCLOAK_PORT        = "8080"
    APP_LAUNCHER_PORT    = "3000"
    HR_PORTAL_PORT       = "3001"
    FINANCE_PORTAL_PORT  = "3002"
    KEYCLOAK_ADMIN_USER  = "admin"
    KEYCLOAK_ADMIN_PASSWORD = "admin"
    LDAP_ORGANISATION    = "Demo Company"
    LDAP_DOMAIN          = "company.local"
    LDAP_ADMIN_PASSWORD  = "admin"
    POSTGRES_PASSWORD    = "keycloak"
  }
  if (-not (Test-Path $file)) { return $defaults }
  foreach ($line in Get-Content $file) {
    if ($line -match '^\s*#' -or $line -notmatch '=') { continue }
    $k, $v = $line -split '=', 2
    $defaults[$k.Trim()] = $v.Trim().Trim('"')
  }
  return $defaults
}

function Get-DemoUrls {
  $e = Get-DemoEnv
  $publicHost = $e.PUBLIC_HOST.TrimEnd('/')
  return @{
    Keycloak      = "${publicHost}:$($e.KEYCLOAK_PORT)"
    Launcher      = "${publicHost}:$($e.APP_LAUNCHER_PORT)"
    HrPortal      = "${publicHost}:$($e.HR_PORTAL_PORT)"
    FinancePortal = "${publicHost}:$($e.FINANCE_PORTAL_PORT)"
    Realm         = $e.REALM_NAME
    CompanyName   = $e.COMPANY_DISPLAY_NAME
  }
}
