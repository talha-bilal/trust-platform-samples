# Keycloak SPI demo (local)

Run Keycloak 24 with the **Demo Certificate Subject Gate** authenticator JAR.

## 1. Build provider

```bash
cd ..
mvn -q package
```

## 2. Start Keycloak

```bash
cd demo
docker compose up -d
```

Wait for http://localhost:8080 (admin / admin from compose file).

## 3. Configure realm

1. Create realm `portfolio-demo`.
2. Create client `test-app` (public, standard flow).
3. **Authentication** → Browser flow → **Duplicate** → add execution **Demo Certificate Subject Gate** (REQUIRED) after cookie or at start of forms.

## 4. Simulate certificate header

Keycloak receives `X-Demo-Cert-Subject` from a reverse proxy. For local test, use curl:

```bash
curl -s -o /dev/null -w "%{http_code}" \
  -H "X-Demo-Cert-Subject: CN=demo-user,O=Portfolio Sample" \
  "http://localhost:8080/realms/portfolio-demo/protocol/openid-connect/auth?client_id=test-app&response_type=code&scope=openid&redirect_uri=http://localhost:3000/callback"
```

Expect redirect or 302 — not 401 from authenticator failure.

## 5. Flow diagram

See [docs/diagrams/03-keycloak-pki-login.md](../../docs/diagrams/03-keycloak-pki-login.md).

## Teardown

```bash
docker compose down -v
```
