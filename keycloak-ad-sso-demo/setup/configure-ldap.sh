#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

echo "Waiting for Keycloak..."
for i in $(seq 1 60); do
  if curl -sf http://localhost:8080/health/ready >/dev/null 2>&1; then break; fi
  sleep 3
done

KC=$(docker compose ps -q keycloak)
docker exec "$KC" /opt/keycloak/bin/kcadm.sh config credentials \
  --server http://localhost:8080 --realm master --user admin --password admin

if ! docker exec "$KC" /opt/keycloak/bin/kcadm.sh get components -r company -q name=company-ldap --fields id 2>/dev/null | grep -q '"id"'; then
  REALM_ID=$(docker exec "$KC" /opt/keycloak/bin/kcadm.sh get realms/company --fields id | grep -o '"id" *: *"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
  docker exec "$KC" /opt/keycloak/bin/kcadm.sh create components -r company \
    -s name=company-ldap \
    -s providerId=ldap \
    -s providerType=org.keycloak.storage.UserStorageProvider \
    -s parentId="$REALM_ID" \
    -s 'config.enabled=["true"]' \
    -s 'config.priority=["0"]' \
    -s 'config.editMode=["READ_ONLY"]' \
    -s 'config.syncRegistrations=["false"]' \
    -s 'config.vendor=["other"]' \
    -s 'config.usernameLDAPAttribute=["uid"]' \
    -s 'config.rdnLDAPAttribute=["uid"]' \
    -s 'config.uuidLDAPAttribute=["entryUUID"]' \
    -s 'config.userObjectClasses=["inetOrgPerson, organizationalPerson"]' \
    -s 'config.connectionUrl=["ldap://openldap:389"]' \
    -s 'config.usersDn=["ou=users,dc=company,dc=local"]' \
    -s 'config.bindDn=["cn=admin,dc=company,dc=local"]' \
    -s 'config.bindCredential=["admin"]' \
    -s 'config.searchScope=["1"]' \
    -s 'config.importEnabled=["true"]' \
    -s 'config.pagination=["true"]'
fi

ID=$(docker exec "$KC" /opt/keycloak/bin/kcadm.sh get components -r company -q name=company-ldap --fields id | grep -o '"id" *: *"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
docker exec "$KC" /opt/keycloak/bin/kcadm.sh create "user-storage/${ID}/sync" -r company -s action=triggerFullSync

echo "Demo ready — http://localhost:3001 (ahmed / Demo@123)"
