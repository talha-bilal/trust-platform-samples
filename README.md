# Trust Platform Engineering Samples

Public, **sanitized** samples for [Talha Bilal's portfolio](https://talha-bilal.github.io/portfolio/) — PKI, CSC remote signing, Keycloak SPI, HSM, and Java Card architecture.

> Portfolio samples — not production deployments. Safe for interviews and design reviews.

## Repository map

| Area | Description |
|------|-------------|
| [**docs/**](./docs/) | **6 architecture diagrams** + **5 detailed use cases** |
| [keycloak-pki-authenticator](./keycloak-pki-authenticator/) | Keycloak Authenticator SPI + **Docker demo** |
| [csc-remote-signing-openapi](./csc-remote-signing-openapi/) | OpenAPI 3 spec + **curl/Postman demo** |
| [csc-mock-server](./csc-mock-server/) | **Spring Boot** runnable CSC mock API |
| [signing-platform-architecture](./signing-platform-architecture/) | Platform overview (links to full diagram set) |

## Start here

1. **Diagrams** — [docs/diagrams/](./docs/diagrams/) (platform, CSC, Keycloak, HSM, PKI, deployment)
2. **Use cases** — [docs/use-cases/](./docs/use-cases/) (CSC mobile signing, PDF workflow, multi-tenant CA, Java Card, IAM)
3. **Run demos** — [CSC mock server](./csc-mock-server/) · [CSC curl demo](./csc-remote-signing-openapi/demo/) · [Keycloak SPI](./keycloak-pki-authenticator/demo/)

## Complex use cases (index)

| # | Title | Doc |
|---|-------|-----|
| 1 | CSC remote signing for mobile/web | [01-csc-remote-signing.md](./docs/use-cases/01-csc-remote-signing.md) |
| 2 | Keycloak + PKI custom SPI | [02-keycloak-pki-authentication.md](./docs/use-cases/02-keycloak-pki-authentication.md) |
| 3 | PDF workflow + HSM | [03-pdf-workflow-hsm-signing.md](./docs/use-cases/03-pdf-workflow-hsm-signing.md) |
| 4 | Multi-tenant PKI / CA | [04-multi-tenant-pki.md](./docs/use-cases/04-multi-tenant-pki.md) |
| 5 | Java Card issuance ceremony | [05-java-card-issuance.md](./docs/use-cases/05-java-card-issuance.md) |

## Diagram gallery

| Diagram | File |
|---------|------|
| Platform overview | [01-platform-overview.md](./docs/diagrams/01-platform-overview.md) |
| CSC sequence | [02-csc-remote-signing-sequence.md](./docs/diagrams/02-csc-remote-signing-sequence.md) |
| Keycloak + PKI | [03-keycloak-pki-login.md](./docs/diagrams/03-keycloak-pki-login.md) |
| PKCS#11 / HSM | [04-hsm-pkcs11-signing.md](./docs/diagrams/04-hsm-pkcs11-signing.md) |
| PKI lifecycle | [05-pki-lifecycle.md](./docs/diagrams/05-pki-lifecycle.md) |
| Deployment | [06-deployment-topology.md](./docs/diagrams/06-deployment-topology.md) |
| Java Card lifecycle | [07-java-card-applet-lifecycle.md](./docs/diagrams/07-java-card-applet-lifecycle.md) |

## License

MIT — use freely for learning; attribution appreciated.
