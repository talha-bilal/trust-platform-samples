# Keycloak + PKI authentication

Certificate-terminated login with **custom SPI** bridging X.509 attributes to Keycloak sessions.

```mermaid
sequenceDiagram
  autonumber
  participant User as User browser
  participant GW as Reverse proxy
  participant KC as Keycloak
  participant SPI as Custom Authenticator SPI
  participant US as User Storage SPI
  participant App as Signing application

  User->>GW: HTTPS + client certificate
  GW->>GW: Validate chain, extract subject/serial
  GW->>KC: Forward login + X-Demo-Cert-Subject (or cert headers)
  KC->>SPI: Execute authenticator
  alt Subject present and policy OK
    SPI->>US: Lookup federated user by cert DN
    US-->>SPI: UserModel
    SPI-->>KC: SUCCESS
  else Missing or invalid cert
    SPI-->>KC: INVALID_CREDENTIALS
  end
  KC-->>User: OIDC authorization code / tokens
  User->>App: API call with access_token
  App->>App: Validate JWT, map tenant + signing roles
```

## SPI types commonly involved

| SPI | Purpose in PKI platforms |
|-----|--------------------------|
| **Authenticator** | Gate login on certificate presence/policy |
| **User Storage** | Map cert identity → Keycloak user |
| **Protocol Mapper** | Add `signing_profile`, `tenant_id` claims |
| **Event Listener** | Audit login for compliance |

Sample code: [keycloak-pki-authenticator](../../keycloak-pki-authenticator/).
