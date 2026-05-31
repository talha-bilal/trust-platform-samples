# PKI certificate lifecycle

```mermaid
stateDiagram-v2
  [*] --> Pending: CSR submitted
  Pending --> Issued: CA signs + publishes
  Issued --> Renewed: Auto-renewal job
  Renewed --> Issued
  Issued --> Revoked: Admin or policy
  Revoked --> [*]
  Issued --> Expired: Not renewed
  Expired --> [*]

  state Issued {
    [*] --> OCSP_good
    OCSP_good --> OCSP_unknown: Propagation delay
  }
```

```mermaid
flowchart TB
  CSR[CSR ingestion] --> Policy[Policy engine]
  Policy --> HSM[HSM sign CSR]
  HSM --> Cert[Certificate record]
  Cert --> OCSP[OCSP responder]
  Cert --> CRL[CRL distribution]
  Cert --> Notify[Tenant webhook]
```

## Operational checks

| Check | Frequency |
|-------|-----------|
| OCSP responder latency | Continuous |
| CRL freshness | Hourly |
| Renewal window (e.g. T-30 days) | Daily batch |
| HSM capacity for issuance spikes | Weekly review |
