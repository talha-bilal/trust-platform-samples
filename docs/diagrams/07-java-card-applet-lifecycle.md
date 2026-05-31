# Java Card applet lifecycle

On-card secure element: **GlobalPlatform** lifecycle, key generation, and host-driven signing ceremonies.

```mermaid
flowchart TB
  subgraph host [Host application]
    PCSC[PC/SC driver]
    Issuance[Issuance tool]
    SignHost[Signing host]
  end

  subgraph card [Java Card]
    GP[GlobalPlatform runtime]
    Applet[PKI / Signing applet]
    Mem[(Secure memory)]
    GP --> Applet
    Applet --> Mem
  end

  subgraph ops [On-card operations]
    GEN[Generate key pair]
    SIGN[Sign hash]
    PIN[PIN verify]
  end

  Issuance --> PCSC
  SignHost --> PCSC
  PCSC -->|APDU| GP
  Applet --> GEN
  Applet --> SIGN
  SIGN --> PIN
```

```mermaid
sequenceDiagram
  autonumber
  participant H as Host
  participant C as Java Card applet
  participant CA as CA service

  H->>C: SELECT applet
  H->>C: INIT UPDATE / SCP03 secure channel
  H->>C: INSTALL + register applet
  H->>C: GENERATE KEY PAIR (RSA/ECDSA)
  C-->>H: Public key / CSR template
  H->>CA: Submit CSR
  CA-->>H: Signed X.509 certificate
  H->>C: STORE CERT + init PKCS#15
  Note over H,C: Card ready for ceremonies

  H->>C: VERIFY PIN
  H->>C: SIGN HASH
  C-->>H: Signature bytes
```

## Lifecycle states

```mermaid
stateDiagram-v2
  [*] --> Provisioned: GP install
  Provisioned --> Personalized: Keys + cert loaded
  Personalized --> Active: PIN set
  Active --> Active: Sign ceremonies
  Active --> Blocked: PIN lockout
  Blocked --> [*]: Card replaced
  Personalized --> Revoked: Cert revoked in CA
  Revoked --> [*]
```

## Security properties

| Property | Implementation |
|----------|----------------|
| Private key non-export | Key never leaves secure memory |
| PIN gate | Signing requires verified PIN |
| Channel security | GP SCP03 for personalization |
| Audit | Host logs APDU command + card serial |

## Related docs

- [Use case: Java Card issuance](../use-cases/05-java-card-issuance.md)
- [Platform overview](./01-platform-overview.md)
