# Platform overview

High-level view of a **digital trust platform**: IAM, CSC remote signing, PKI, and HSM crypto.

```mermaid
flowchart TB
  subgraph external [External]
    Users[End users]
    Partners[B2B partners]
    Admins[Tenant admins]
  end

  subgraph edge [Edge layer]
    LB[Load balancer]
    GW[API gateway / WAF]
    MTLS[mTLS termination]
  end

  subgraph apps [Application plane]
    Portal[Signing Portal SPA]
    SignAPI[Document & workflow APIs]
    CSC[CSC service]
    PKI[PKI / CA API]
  end

  subgraph iam [Identity plane]
    KC[Keycloak cluster]
    SPI[Custom SPI providers]
  end

  subgraph crypto [Crypto plane]
    P11[PKCS#11 service]
    CC[Crypto-Core]
    TSA[TSA RFC 3161]
    HSM[(HSM cluster)]
  end

  subgraph data [Data plane]
    PG[(PostgreSQL)]
    Redis[(Redis)]
    MQ[RabbitMQ]
    Audit[(Audit store)]
  end

  Users --> LB
  Partners --> LB
  Admins --> LB
  LB --> GW
  GW --> MTLS
  MTLS --> Portal
  MTLS --> SignAPI
  MTLS --> CSC
  MTLS --> PKI
  SignAPI --> KC
  CSC --> KC
  Portal --> KC
  KC --> SPI
  CSC --> P11
  PKI --> P11
  SignAPI --> P11
  CC --> P11
  P11 --> HSM
  PKI --> PG
  CSC --> Audit
  apps --> PG
  apps --> Redis
  apps --> MQ
```

## Planes explained

| Plane | Responsibility |
|-------|----------------|
| Edge | TLS, rate limits, tenant routing, optional client certificates |
| Identity | OIDC tokens, realms, SPI extensions for PKI-backed users |
| Signing | Portal UX, CSC, PDF workflows, editor/field APIs, state machines |
| Crypto | HSM sessions, key handles, algorithm policy enforcement |
| PKI | Issuance, revocation, OCSP/CRL, certificate profiles |
| Data | Tenant metadata, audit, async jobs, cache |
