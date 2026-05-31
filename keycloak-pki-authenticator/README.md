# Keycloak IAM Integration

**Portfolio project** — custom Keycloak SPI for certificate-aware authentication in a PKI/signing platform.

> **Full documentation (diagrams, use case, demo):** see **[PROJECT.md](./PROJECT.md)** below, or start here.

## Quick links

| Section | Document |
|---------|----------|
| Architecture & use case | [PROJECT.md](./PROJECT.md) |
| Build & deploy SPI | This file → [Build](#build--deploy) |
| Docker demo | [demo/README.md](./demo/README.md) |
| Source | `src/main/java/...` |

---

## Build & deploy

```bash
mvn -q package
cp target/keycloak-pki-authenticator-sample.jar $KEYCLOAK_HOME/providers/
$KEYCLOAK_HOME/bin/kc.sh build && $KEYCLOAK_HOME/bin/kc.sh start-dev
```

## Demo behavior

Expects header `X-Demo-Cert-Subject` (portfolio sample only). See [demo/README.md](./demo/README.md).

## License

MIT — portfolio / learning use.
