# Documentation hub

Deep-dive material for trust platform engineering: **diagrams**, **use cases**, and **step-by-step demos**.

## Diagrams

| Document | Contents |
|----------|----------|
| [diagrams/01-platform-overview.md](./diagrams/01-platform-overview.md) | End-to-end platform (C4-style) |
| [diagrams/02-csc-remote-signing-sequence.md](./diagrams/02-csc-remote-signing-sequence.md) | CSC OAuth → authorize → signHash |
| [diagrams/03-keycloak-pki-login.md](./diagrams/03-keycloak-pki-login.md) | Certificate-aware IAM + SPI |
| [diagrams/04-hsm-pkcs11-signing.md](./diagrams/04-hsm-pkcs11-signing.md) | PKCS#11 session pool → HSM |
| [diagrams/05-pki-lifecycle.md](./diagrams/05-pki-lifecycle.md) | CA, OCSP/CRL, renewal |
| [diagrams/06-deployment-topology.md](./diagrams/06-deployment-topology.md) | Runtime deployment view |
| [diagrams/07-java-card-applet-lifecycle.md](./diagrams/07-java-card-applet-lifecycle.md) | Java Card / GlobalPlatform lifecycle |

## Complex use cases

| # | Scenario | Document |
|---|----------|----------|
| 1 | CSC remote signing (mobile/web client) | [use-cases/01-csc-remote-signing.md](./use-cases/01-csc-remote-signing.md) |
| 2 | Keycloak + PKI custom SPI login | [use-cases/02-keycloak-pki-authentication.md](./use-cases/02-keycloak-pki-authentication.md) |
| 3 | HSM-backed PDF workflow signing | [use-cases/03-pdf-workflow-hsm-signing.md](./use-cases/03-pdf-workflow-hsm-signing.md) |
| 4 | Multi-tenant CA issuance & OCSP | [use-cases/04-multi-tenant-pki.md](./use-cases/04-multi-tenant-pki.md) |
| 5 | Java Card issuance ceremony | [use-cases/05-java-card-issuance.md](./use-cases/05-java-card-issuance.md) |

## Runnable demos

| Demo | Location |
|------|----------|
| CSC API walkthrough (curl + JSON) | [csc-remote-signing-openapi/demo/](../csc-remote-signing-openapi/demo/) |
| **CSC Spring mock server** | [csc-mock-server/](../csc-mock-server/) |
| Keycloak SPI local run | [keycloak-pki-authenticator/demo/](../keycloak-pki-authenticator/demo/) |
