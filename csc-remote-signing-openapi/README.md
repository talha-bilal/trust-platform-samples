# CSC Remote Signing API (OpenAPI Sample)

Simplified [Cloud Signature Consortium](https://cloudsignatureconsortium.org/) style REST API.

## Contents

| Path | Description |
|------|-------------|
| [openapi.yaml](./openapi.yaml) | OpenAPI 3.0.3 — import to Swagger Editor |
| [demo/](./demo/) | **Step-by-step demo**: curl, JSON payloads, Postman collection |
| [../docs/diagrams/02-csc-remote-signing-sequence.md](../docs/diagrams/02-csc-remote-signing-sequence.md) | Sequence diagram |
| [../docs/use-cases/01-csc-remote-signing.md](../docs/use-cases/01-csc-remote-signing.md) | Full use case narrative |

## Endpoints (summary)

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/info` | Service metadata |
| POST | `/oauth2/token` | OAuth2 token |
| POST | `/credentials/list` | List signing credentials |
| POST | `/credentials/authorize` | Obtain SAD |
| POST | `/signatures/signHash` | Remote signature |
| POST | `/timestamps` | RFC 3161 timestamp |

## Quick start

```bash
# View spec
npx @redocly/cli preview-docs openapi.yaml

# Run demo walkthrough
cd demo && cat README.md
```
