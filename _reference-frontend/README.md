# Reference frontend (local only — do not commit)

Architecture docs are refreshed from an **external read-only folder** on this machine:

`D:\products\public`

Copying files into this directory is optional. The agent reads `D:\products\public` directly when updating diagrams and use cases.

## What we infer (never published verbatim)

- Route map and user journeys (upload → signers → prepare → editor)
- API service boundaries under `src/api/services/`
- Organization modules and signature policy flags
- Auth flows: OIDC, guest links, CSC callback, smart-card, passkey

## Sanitization rules

- No company, product, or customer names in GitHub docs
- Generic labels only: **Signing Portal**, **Document API**, **Identity provider**, etc.
- No `.env`, keys, or internal hostnames

## After updates

Only **documentation** in `trust-platform-samples` is committed — not `D:\products\public`.
