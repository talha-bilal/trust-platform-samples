# Keycloak PKI Authenticator (Sample SPI)

Minimal Keycloak **Authenticator SPI** demonstrating how certificate-oriented login gates can plug into a realm flow.

> Portfolio sample only. Replace demo header checks with real X.509 validation, trust stores, and OCSP/CRL policies in production.

## What it shows

- `AuthenticatorFactory` + `Authenticator` implementation
- Service loader registration (`META-INF/services/...`)
- Maven build against Keycloak 24 SPI artifacts
- Packaging as a provider JAR for `providers/` directory

## Demo behavior

During login, the authenticator expects HTTP header:

```http
X-Demo-Cert-Subject: CN=demo-user,O=Portfolio Sample
```

If the header is missing or blank → login challenge fails.  
Use only in **dev** realms with a reverse proxy or test client injecting the header.

## Build

```bash
mvn -q package
```

Output: `target/keycloak-pki-authenticator-sample.jar`

## Deploy (Keycloak 24+, Quarkus distribution)

```bash
cp target/keycloak-pki-authenticator-sample.jar $KEYCLOAK_HOME/providers/
$KEYCLOAK_HOME/bin/kc.sh build
$KEYCLOAK_HOME/bin/kc.sh start-dev
```

In Admin Console → Authentication → flow → add execution **Demo Certificate Subject Gate**.

## Production notes

Real PKI-backed flows typically combine:

- Client certificate termination at gateway
- Mapped subject/serial attributes into Keycloak
- User Storage SPI or federated identity linking
- Protocol mappers for signing service claims

See portfolio case study: *Keycloak IAM with PKI-backed authentication*.
