# Use case 05: Java Card issuance

## Scenario

High-assurance users receive a **smart card** with on-card key pair for signing. Host application drives **GlobalPlatform** lifecycle and PKCS#15 directory setup.

## Ceremony flow

```mermaid
sequenceDiagram
  participant Op as Issuance operator
  participant Host as Host application
  participant Card as Java Card applet
  participant CA as CA service

  Op->>Host: Start ceremony (tenant, user)
  Host->>Card: SELECT applet + INIT UPDATE
  Host->>Card: INSTALL / personalize
  Card->>Card: Generate RSA key pair on-card
  Card-->>Host: Public key / CSR material
  Host->>CA: Submit CSR
  CA-->>Host: Signed certificate
  Host->>Card: Load cert + PKCS#15 structure
  Host-->>Op: Ceremony complete + audit ID
```

## Applet responsibilities (typical)

| Function | On-card |
|----------|---------|
| Key generation | RSA/ECDSA key pair in secure memory |
| Sign | Small hash signing with PIN verification |
| PIN policy | Retry counter, block after N failures |

## Complex considerations

| Topic | Detail |
|-------|--------|
| GP keys | Secure channel with diversified keys per batch |
| Applet versioning | Upgrade path without bricking issued cards |
| Host drivers | PC/SC on Windows/Linux; consistent APDU logging |
| Backup keys | Policy: no export of private key — ever |

## Sample reference

- Architecture and ceremony flow in this document
- Related platform context: [Platform overview](../diagrams/01-platform-overview.md)

> Production Java Card applet source is typically proprietary; this repo documents **flows, APDU patterns, and GP lifecycle** for interviews.
