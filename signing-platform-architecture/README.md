# Signing & Trust Platform Architecture (Reference)

Reference architecture for **PKI**, **CSC remote signing**, **HSM**, and **Keycloak IAM** — aligned with [Talha Bilal's portfolio](https://talha-bilal.github.io/portfolio/).

```mermaid
flowchart TB
  subgraph clients [Clients]
    Web[Web apps]
    Mobile[Mobile SDKs]
    Partners[Partner integrations]
  end

  subgraph edge [Edge]
    GW[API Gateway / mTLS]
  end

  subgraph iam [Identity]
    KC[Keycloak OIDC]
    SPI[Custom SPIs]
    KC --- SPI
  end

  subgraph signing [Signing plane]
    CSC[CSC API service]
    PDF[PDF / workflow]
    SMIME[S/MIME service]
    TSA[TSA RFC 3161]
  end

  subgraph crypto [Crypto plane]
    CC[Crypto-Core]
    P11[PKCS#11 service]
    HSM[(AWS CloudHSM / Utimaco / SoftHSM2)]
  end

  subgraph pki [PKI plane]
    CA[CA / lifecycle]
    OCSP[OCSP / CRL]
  end

  subgraph data [Data]
    DB[(PostgreSQL)]
    MQ[RabbitMQ]
    Redis[(Redis)]
  end

  clients --> GW
  GW --> KC
  GW --> CSC
  GW --> PDF
  KC --> SPI
  CSC --> P11
  PDF --> P11
  SMIME --> P11
  CC --> P11
  P11 --> HSM
  CA --> P11
  CA --> OCSP
  CSC --> TSA
  signing --> DB
  signing --> MQ
  signing --> Redis
  pki --> DB
```

## Service responsibilities

| Component | Role |
|-----------|------|
| **Keycloak** | SSO/OIDC, tenant realms, custom SPIs for certificate-aware login |
| **CSC API** | Standard remote signing for apps (`credentials`, `signHash`, timestamps) |
| **PKCS#11 layer** | Vendor-neutral HSM access, pooled sessions, RBAC |
| **PKI / CA** | Issuance, renewal, OCSP/CRL, policy per tenant |
| **Crypto-Core** | Shared key generation, CSR, encrypt/decrypt |
| **Java Card** | Edge credentials & secure elements (issuance ceremonies) |

## Typical remote signing path

1. Client obtains OAuth token (Keycloak or CSC client credentials).
2. CSC `credentials/list` + `authorize` → Signature Activation Data (SAD).
3. Client sends hash to `signatures/signHash`.
4. CSC service uses PKCS#11 → HSM for signature generation.
5. Optional RFC 3161 timestamp from TSA service.
6. Audit event persisted per tenant.

## Security controls (production)

- mTLS or gateway-terminated client certificates
- Per-tenant realm isolation and HSM key partitioning
- Immutable audit logs for signing and IAM events
- Rate limits on CSC authorize/sign endpoints
- No private keys outside HSM except Java Card secure elements

## Samples in this repository

- [Keycloak Authenticator SPI](../keycloak-pki-authenticator/)
- [CSC OpenAPI](../csc-remote-signing-openapi/)
