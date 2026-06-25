#!/usr/bin/env bash
# One-command demo startup (Linux / macOS)
set -euo pipefail
cd "$(dirname "$0")/.."

echo "=== Keycloak AD + SSO Demo ==="

if ! docker info >/dev/null 2>&1; then
  echo "Docker is not running. Start Docker and retry."
  exit 1
fi

RESET=false
SKIP_MFA=false
for arg in "$@"; do
  case $arg in
    -Reset) RESET=true ;;
    -SkipMfa) SKIP_MFA=true ;;
  esac
done

if $RESET; then
  docker compose down -v
fi

docker compose up -d
bash setup/configure-ldap.sh
# PowerShell required for full client registration on Linux unless pwsh installed:
if command -v pwsh >/dev/null 2>&1; then
  pwsh -File setup/register-clients-from-intake.ps1
  if ! $SKIP_MFA; then pwsh -File setup/configure-mfa.ps1 || true; fi
else
  echo "Install PowerShell (pwsh) to run client registration and MFA scripts."
  echo "Or run demo with realm-imported clients only."
fi

echo ""
echo "Demo ready:"
echo "  http://localhost:3000  Application launcher"
echo "  http://localhost:3001  HR Portal"
echo "  http://localhost:3002  Finance Portal"
echo "  http://localhost:8080  Keycloak admin (admin/admin)"
echo "  Login: ahmed / Demo@123"
