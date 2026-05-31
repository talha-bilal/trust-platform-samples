# Use case 01: CSC remote signing

## Scenario

A **mobile banking app** must sign PDF loan agreements. Keys never leave the HSM; the app only sends a **hash** to a CSC-compliant API after user authorization.

## Actors

| Actor | Role |
|-------|------|
| Mobile app | Obtains token, drives CSC calls |
| CSC service | Implements credentials + signHash |
| PKCS#11 service | Executes HSM operations |
| TSA (optional) | Adds RFC 3161 timestamp |

## Preconditions

- Tenant onboarded with HSM key label `tenant-42-signing-rsa`
- OAuth client `mobile-loans` registered
- User credential `cred-9f2a` bound to signing certificate

## Happy path (step by step)

1. **Authenticate** — `POST /oauth2/token` → `access_token` (see [demo payloads](../../csc-remote-signing-openapi/demo/)).
2. **Discover credentials** — `POST /credentials/list` → `["cred-9f2a"]`.
3. **Authorize** — `POST /credentials/authorize` with `numSignatures: 1` → receive `SAD`.
4. **Sign hash** — `POST /signatures/signHash` with document SHA-256 → CMS signature.
5. **Timestamp** (optional) — `POST /timestamps` for long-term validation.
6. **Audit** — CSC service emits `SIGN_HASH_SUCCESS` with tenant, credential, algo.

## Complex considerations

| Topic | Detail |
|-------|--------|
| **OTP / step-up** | `authorize` may require out-of-band approval before SAD is issued |
| **Algorithm policy** | Server rejects `RSA_PKCS1_SHA256` if profile mandates ECDSA P-256 |
| **Quota** | `numSignatures` decrements per successful sign; SAD invalidated at zero |
| **Idempotency** | Clients pass `transactionId` to survive network retries |

## Diagram

[Sequence diagram](../diagrams/02-csc-remote-signing-sequence.md)

## Artifacts in this repo

- [OpenAPI spec](../../csc-remote-signing-openapi/openapi.yaml)
- [Interactive demo (curl)](../../csc-remote-signing-openapi/demo/README.md)
