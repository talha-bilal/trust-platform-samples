# Keycloak PKI Authenticator (Sample SPI)

Minimal Keycloak **Authenticator SPI** for certificate-subject gating — portfolio / interview reference.

## Documentation

| Resource | Link |
|----------|------|
| Login sequence diagram | [03-keycloak-pki-login.md](../docs/diagrams/03-keycloak-pki-login.md) |
| Use case (enterprise console) | [02-keycloak-pki-authentication.md](../docs/use-cases/02-keycloak-pki-authentication.md) |
| **Local Docker demo** | [demo/README.md](./demo/README.md) |

## Build & deploy

```bash
mvn -q package
cp target/keycloak-pki-authenticator-sample.jar $KEYCLOAK_HOME/providers/
$KEYCLOAK_HOME/bin/kc.sh build && $KEYCLOAK_HOME/bin/kc.sh start-dev
```

## SPI classes

| Class | Role |
|-------|------|
| `CertificateSubjectAuthenticatorFactory` | Registers provider `demo-certificate-subject-gate` |
| `CertificateSubjectAuthenticator` | Validates `X-Demo-Cert-Subject` header |

## Production extensions (not in sample)

- Trust store validation + OCSP/CRL check on client cert
- User Storage SPI mapping DN → tenant user
- Protocol mappers for `tenant_id`, signing roles
