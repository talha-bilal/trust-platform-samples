# Enables TOTP (authenticator app) on the browser login flow.
# Optional for live demos — use -SkipMfa on start-demo.ps1 to skip.
# Usage: powershell -File setup/configure-mfa.ps1

$ErrorActionPreference = "Stop"
. "$PSScriptRoot/_keycloak.ps1"

Wait-KeycloakReady
Connect-KcAdmin | Out-Null
$kc = Get-KcContainer

Write-Host "Configuring MFA (TOTP) policy on realm company..."

docker exec $kc /opt/keycloak/bin/kcadm.sh update realms/company `
  -s otpPolicyType=totp `
  -s otpPolicyAlgorithm=HmacSHA1 `
  -s otpPolicyDigits=6 `
  -s otpPolicyPeriod=30 `
  -s otpPolicyLookAheadWindow=1 | Out-Null

# Add OTP step to browser flow if not already present
$executions = docker exec $kc /opt/keycloak/bin/kcadm.sh get authentication/flows/browser/executions -r company 2>&1
if ($executions -match "auth-otp-form") {
  Write-Host "OTP execution already in browser flow."
} else {
  Write-Host "Adding OTP Form to browser authentication flow (CONDITIONAL)..."
  docker exec $kc /opt/keycloak/bin/kcadm.sh create authentication/flows/browser/executions/execution -r company `
    -s provider=auth-otp-form `
    -s requirement=CONDITIONAL | Out-Null
  Write-Host "OTP added. To require MFA for a user: Admin -> Users -> Credentials -> Configure OTP"
  Write-Host "Or assign Required Action CONFIGURE_TOTP for first-login enrollment."
}

Write-Host ""
Write-Host "MFA ready. Demo tip: enroll ahmed with Google/Microsoft Authenticator during the call,"
Write-Host "or show OTP policy under Realm settings -> Authentication -> Policies."
