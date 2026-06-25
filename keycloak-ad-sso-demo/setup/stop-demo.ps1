# Stop demo containers (keeps data).
$root = Split-Path -Parent $PSScriptRoot
Push-Location $root
docker compose down
Write-Host "Demo stopped. Data volumes kept — run start-demo.ps1 to resume."
Pop-Location
