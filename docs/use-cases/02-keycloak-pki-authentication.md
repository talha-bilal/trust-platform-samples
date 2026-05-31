# Use case 02: Keycloak + PKI authentication

## Scenario

Enterprise admins authenticate to the **signing console** with **client certificates** issued by the platform CA. Keycloak issues OIDC tokens with tenant and signing-role claims via **custom SPIs**.

## Flow summary

1. Browser presents client certificate at reverse proxy.
2. Proxy forwards distinguished name to Keycloak (header or mutual TLS attribute).
3. **Authenticator SPI** validates certificate policy (issuer, EKU, revocation).
4. **User Storage SPI** maps DN → Keycloak user in tenant realm.
5. **Protocol Mapper** adds claims: `tenant_id`, `signing_admin`, `cert_serial`.
6. SPA uses access token to call PKI and CSC APIs.

## Complex considerations

| Topic | Detail |
|-------|--------|
| Multi-realm | One realm per enterprise tenant — SPI must not leak users across realms |
| Cert renewal | Mapper reads fresh serial after re-issuance; storage SPI updates linkage |
| Break-glass | Optional local Keycloak user for disaster recovery only |
| Audit | Event listener logs cert subject + fingerprint on each login |

## Diagram

[Keycloak + PKI sequence](../diagrams/03-keycloak-pki-login.md)

## Sample implementation

- [Certificate Subject Authenticator SPI](../../keycloak-pki-authenticator/)
- [Local demo with Docker](../../keycloak-pki-authenticator/demo/README.md)
