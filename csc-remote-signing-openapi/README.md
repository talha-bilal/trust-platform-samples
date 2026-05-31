# CSC Remote Signing Service

**Portfolio project** — Cloud Signature Consortium style remote signing API.

> **Full documentation (diagrams, use case, mock server, demos):** **[PROJECT.md](./PROJECT.md)**

## Quick links

| Section | Location |
|---------|----------|
| Architecture & use case | [PROJECT.md](./PROJECT.md) |
| OpenAPI contract | [openapi.yaml](./openapi.yaml) |
| curl / Postman demo | [demo/](./demo/) |
| Spring mock server | [../csc-mock-server/](../csc-mock-server/) |

## Run mock API locally

```bash
cd ../csc-mock-server && mvn spring-boot:run
# Base URL: http://localhost:8081/csc/v1
cd demo && powershell -File run-against-mock.ps1
```

MIT — portfolio sample.
