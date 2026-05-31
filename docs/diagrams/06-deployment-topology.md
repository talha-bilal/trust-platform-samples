# Deployment topology

Example **production-style** layout (Kubernetes or VM-based).

```mermaid
flowchart TB
  subgraph internet [Internet]
    Clients[Clients]
  end

  subgraph dmz [DMZ]
    Ingress[Ingress / API GW]
  end

  subgraph app_tier [Application tier]
    KC[Keycloak replicas]
    CSC[CSC API pods]
    PKI[PKI API pods]
    WF[Workflow pods]
  end

  subgraph crypto_tier [Restricted tier]
    P11[PKCS#11 service]
    HSM[(HSM — no outbound)]
  end

  subgraph data_tier [Data tier]
    PG[(PostgreSQL HA)]
    Redis[(Redis)]
  end

  Clients --> Ingress
  Ingress --> KC
  Ingress --> CSC
  Ingress --> PKI
  Ingress --> WF
  CSC --> P11
  PKI --> P11
  WF --> P11
  P11 --> HSM
  app_tier --> PG
  app_tier --> Redis
```

## Network rules (summary)

- Crypto tier: **no** direct internet egress.
- HSM: allow only PKCS#11 service security group.
- Audit logs: ship to SIEM via sidecar / forwarder.
