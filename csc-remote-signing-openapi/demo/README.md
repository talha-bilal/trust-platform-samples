# CSC API demo walkthrough

Hands-on **request/response examples** for the CSC-style API. Use against your own implementation or import into Postman.

## Prerequisites

- Running CSC base URL (replace `BASE` below), **or** local mock: [csc-mock-server](../csc-mock-server/) → `http://localhost:8081/csc/v1`
- OAuth client credentials (`demo-client` / `demo-secret` for mock)
- `curl` or PowerShell

### One-command demo against mock (Windows)

```powershell
# Terminal 1: start mock — cd ../csc-mock-server && mvn spring-boot:run
# Terminal 2:
./run-against-mock.ps1
```

## Variables

```bash
export BASE=https://signing.example.com/csc/v1
export CLIENT_ID=demo-client
export CLIENT_SECRET=demo-secret
```

```powershell
$BASE = "https://signing.example.com/csc/v1"
$CLIENT_ID = "demo-client"
$CLIENT_SECRET = "demo-secret"
```

## Step 0 — Service info

```bash
curl -s "$BASE/info" | jq .
```

Expected shape: [responses/00-info.json](./responses/00-info.json)

## Step 1 — OAuth token

```bash
curl -s -X POST "$BASE/oauth2/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&scope=service" \
  | tee responses/01-token-live.json | jq .
```

Reference: [requests/01-token-request.txt](./requests/01-token-request.txt), [responses/01-token.json](./responses/01-token.json)

## Step 2 — List credentials

```bash
export TOKEN=<access_token from step 1>
curl -s -X POST "$BASE/credentials/list" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d @requests/02-credentials-list.json | jq .
```

## Step 3 — Authorize credential

```bash
curl -s -X POST "$BASE/credentials/authorize" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d @requests/03-authorize.json | jq .
```

Save `SAD` from response for step 4.

## Step 4 — Sign hash

```bash
curl -s -X POST "$BASE/signatures/signHash" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d @requests/04-signHash.json | jq .
```

Replace `SAD` in `04-signHash.json` with value from step 3.

## Step 5 — Timestamp (optional)

```bash
curl -s -X POST "$BASE/timestamps" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d @requests/05-timestamp.json | jq .
```

## Error catalog (common)

| HTTP | Meaning | Typical fix |
|------|---------|-------------|
| 401 | Invalid/expired token | Refresh OAuth token |
| 403 | Credential not allowed for client | Check tenant binding |
| 409 | SAD expired | Re-run authorize |
| 503 | HSM busy | Retry with backoff |

## Postman

Import [postman-collection.json](./postman-collection.json) and set collection variables `baseUrl`, `clientId`, `clientSecret`.
