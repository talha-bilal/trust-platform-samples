# CSC Mock Server (Spring Boot)

Minimal **runnable** CSC-style API for local demos and portfolio reviewers. Implements the same paths as [OpenAPI spec](../csc-remote-signing-openapi/openapi.yaml).

> Mock signatures only — no real HSM or crypto.

## Run

```bash
mvn spring-boot:run
```

Base URL: **http://localhost:8081/csc/v1**

Default OAuth client: `demo-client` / `demo-secret`

## Quick test

```bash
# Info
curl -s http://localhost:8081/csc/v1/info | jq .

# Token
TOKEN=$(curl -s -X POST http://localhost:8081/csc/v1/oauth2/token \
  -d "grant_type=client_credentials&client_id=demo-client&client_secret=demo-secret" \
  | jq -r .access_token)

# List credentials
curl -s -X POST http://localhost:8081/csc/v1/credentials/list \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d '{}' | jq .

# Authorize
SAD=$(curl -s -X POST http://localhost:8081/csc/v1/credentials/authorize \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"credentialID":"cred-9f2a","numSignatures":1,"hashAlgorithm":"SHA-256"}' \
  | jq -r .SAD)

# Sign hash
curl -s -X POST http://localhost:8081/csc/v1/signatures/signHash \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d "{\"credentialID\":\"cred-9f2a\",\"SAD\":\"$SAD\",\"hash\":\"dGVzdA==\",\"signAlgo\":\"RSA_PKCS1_SHA256\"}" | jq .
```

## Endpoints

| Method | Path | Behavior |
|--------|------|----------|
| GET | `/info` | Service metadata |
| POST | `/oauth2/token` | Returns mock Bearer token |
| POST | `/credentials/list` | `cred-9f2a`, `cred-1b88` |
| POST | `/credentials/authorize` | Issues one-time `SAD` (5 min TTL) |
| POST | `/signatures/signHash` | Consumes SAD, returns Base64 mock signature |
| POST | `/timestamps` | Mock RFC 3161-style token |

## Error simulation

| Condition | HTTP |
|-----------|------|
| Wrong client secret | 401 |
| Unknown credential | 403 |
| Reused / expired SAD | 409 |
| Bad `signAlgo` | 400 |

## Related

- [CSC demo payloads](../csc-remote-signing-openapi/demo/)
- [Sequence diagram](../docs/diagrams/02-csc-remote-signing-sequence.md)
- [Use case 01](../docs/use-cases/01-csc-remote-signing.md)

## Requirements

- Java 17+
- Maven 3.9+
