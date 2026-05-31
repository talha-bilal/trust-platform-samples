# CSC Remote Signing API (OpenAPI Sample)

Simplified [Cloud Signature Consortium](https://cloudsignatureconsortium.org/) style REST API for **remote signing** — suitable for portfolio review and client SDK generation.

> Illustrative paths and schemas; align with your CSC provider version and credential profiles in production.

## Contents

- `openapi.yaml` — OpenAPI 3.0.3
- Core flows: service info, OAuth token, credentials list, authorize, `signHash`, timestamps

## View spec

- Paste `openapi.yaml` into [Swagger Editor](https://editor.swagger.io/)
- Or: `npx @redocly/cli preview-docs openapi.yaml`

## Related portfolio work

Production CSC services typically sit behind OAuth/OIDC (often Keycloak) and delegate crypto to PKCS#11 / HSM layers.
