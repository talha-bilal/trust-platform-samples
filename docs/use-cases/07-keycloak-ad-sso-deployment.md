# Use case 07: On-prem Keycloak with Active Directory & OIDC SSO

## Client requirement

Small or mid-size organization wants:

- **On-prem Keycloak** (identity stays in their network)
- **Active Directory** as the user directory (no duplicate accounts)
- **OIDC single sign-on** into multiple internal web applications
- Installation documentation and optional support

## Runnable demo

Full stack with presenter script:

**[keycloak-ad-sso-demo](../../keycloak-ad-sso-demo/)**

| Demo piece | Represents |
|------------|------------|
| OpenLDAP | Active Directory (LDAP federation) |
| Keycloak + PostgreSQL | Production IAM tier |
| HR + Finance portals | Client business applications |
| SSO across tabs | Employee single login experience |

## Sequence

See [PROJECT.md](../../keycloak-ad-sso-demo/PROJECT.md) in the demo folder.

## Related

- [Keycloak + PKI authentication](./02-keycloak-pki-authentication.md) — advanced SPI flows
- [Document signing workspace](./06-document-signing-workspace.md) — OIDC in a larger platform
