# CSC remote signing sequence

Typical **Cloud Signature Consortium** style flow: token → credential discovery → authorization → `signHash`.

```mermaid
sequenceDiagram
  autonumber
  participant App as Client app
  participant OAuth as OAuth / Keycloak
  participant CSC as CSC API
  participant P11 as PKCS#11 service
  participant HSM as HSM

  App->>OAuth: POST /token (client_credentials or auth code)
  OAuth-->>App: access_token

  App->>CSC: POST /credentials/list (Bearer)
  CSC-->>App: credentialIDs[]

  App->>CSC: POST /credentials/authorize
  Note over App,CSC: credentialID, numSignatures, hashAlgorithm
  CSC-->>App: SAD (Signature Activation Data)

  App->>CSC: POST /signatures/signHash
  Note over App,CSC: hash, SAD, signAlgo
  CSC->>P11: open session, sign with key handle
  P11->>HSM: C_Sign
  HSM-->>P11: signature bytes
  P11-->>CSC: CMS / raw signature
  CSC-->>App: signature

  opt Timestamp
    App->>CSC: POST /timestamps
    CSC-->>App: RFC 3161 token
  end
```

## Failure modes to handle in production

| Step | Risk | Mitigation |
|------|------|------------|
| authorize | Brute force / credential stuffing | Rate limit per client_id + IP |
| SAD | Replay of activation data | Short TTL, one-time use, bind to client session |
| signHash | Algorithm downgrade | Server-side allow-list for signAlgo |
| HSM | Session exhaustion | Pool sizing, timeouts, circuit breaker |

See [use case 01](../use-cases/01-csc-remote-signing.md) and [CSC demo](../../csc-remote-signing-openapi/demo/).
