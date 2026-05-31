# Run CSC demo against local Spring mock (http://localhost:8081/csc/v1)
$BASE = "http://localhost:8081/csc/v1"

Write-Host "=== Info ===" -ForegroundColor Cyan
Invoke-RestMethod "$BASE/info" | ConvertTo-Json

Write-Host "`n=== Token ===" -ForegroundColor Cyan
$tokenBody = @{
  grant_type    = "client_credentials"
  client_id     = "demo-client"
  client_secret = "demo-secret"
  scope         = "service"
}
$token = Invoke-RestMethod -Method Post -Uri "$BASE/oauth2/token" -Body $tokenBody -ContentType "application/x-www-form-urlencoded"
$token | ConvertTo-Json
$headers = @{ Authorization = "Bearer $($token.access_token)" }

Write-Host "`n=== Credentials list ===" -ForegroundColor Cyan
Invoke-RestMethod -Method Post -Uri "$BASE/credentials/list" -Headers $headers -Body "{}" -ContentType "application/json" | ConvertTo-Json

Write-Host "`n=== Authorize ===" -ForegroundColor Cyan
$auth = Invoke-RestMethod -Method Post -Uri "$BASE/credentials/authorize" -Headers $headers -ContentType "application/json" -Body (@{
  credentialID = "cred-9f2a"
  numSignatures = 1
  hashAlgorithm = "SHA-256"
} | ConvertTo-Json)
$auth | ConvertTo-Json

Write-Host "`n=== Sign hash ===" -ForegroundColor Cyan
Invoke-RestMethod -Method Post -Uri "$BASE/signatures/signHash" -Headers $headers -ContentType "application/json" -Body (@{
  credentialID = "cred-9f2a"
  SAD = $auth.SAD
  hash = "dGVzdGhhc2gxMjM="
  signAlgo = "RSA_PKCS1_SHA256"
} | ConvertTo-Json) | ConvertTo-Json

Write-Host "`nDone." -ForegroundColor Green
