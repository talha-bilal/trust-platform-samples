# HSM signing via PKCS#11

How signing services avoid direct HSM coupling by using a **PKCS#11 microservice**.

```mermaid
flowchart LR
  subgraph services [Signing services]
    CSC[CSC API]
    PDF[PDF service]
    SMIME[S/MIME service]
  end

  subgraph p11svc [PKCS#11 service]
    API[REST API]
    Pool[Session pool]
    RBAC[Key handle RBAC]
  end

  subgraph vendors [HSM backends]
    AWS[AWS CloudHSM]
    UTI[Utimaco]
    SOFT[SoftHSM2 dev]
  end

  CSC --> API
  PDF --> API
  SMIME --> API
  API --> Pool
  Pool --> RBAC
  RBAC --> AWS
  RBAC --> UTI
  RBAC --> SOFT
```

```mermaid
sequenceDiagram
  participant S as Signing service
  participant P as PKCS#11 service
  participant H as HSM

  S->>P: POST /sessions (tenant, keyLabel)
  P->>H: C_OpenSession
  H-->>P: session handle
  P-->>S: sessionId

  S->>P: POST /sign {sessionId, mechanism, hash}
  P->>H: C_SignInit + C_Sign
  H-->>P: signature
  P-->>S: signature (base64)

  S->>P: DELETE /sessions/{id}
  P->>H: C_CloseSession
```

## Design decisions

- **Pooled sessions** reduce `C_OpenSession` latency under burst signing.
- **Per-tenant key labels** enforce isolation on shared HSM partitions.
- **Structured errors** (`HSM_TIMEOUT`, `INVALID_MECHANISM`) speed up on-call.
