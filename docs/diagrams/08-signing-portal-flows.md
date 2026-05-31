# Signing Portal — user flows

Generic routes and modules aligned with a production **document signing workspace** SPA (React, OIDC, multi-tenant RBAC). No proprietary product names.

## Authenticated application map

```mermaid
flowchart LR
  login[Login / OIDC] --> home[Home]
  home --> docs[Documents]
  home --> folders[Folders]
  home --> templates[Templates]
  docs --> upload[Upload PDF]
  upload --> method{Single or multi signer?}
  method --> signers[Add signers]
  signers --> prepare[Prepare document]
  prepare --> editor[Field editor]
  editor --> sent[Workflow sent]
  home --> settings[User settings]
  home --> orgset[Organization settings]
```

## Organization admin tabs (permission-gated)

```mermaid
flowchart TB
  orgset[Organization settings]
  orgset --> org[Organization profile]
  orgset --> users[Users]
  orgset --> apps[Business applications]
  orgset --> brand[Branding]
  orgset --> bill[Billing]
  orgset --> roles[Roles & signature policy]
```

## Public / low-trust routes

```mermaid
flowchart TB
  subgraph public [No full session required]
    guestWait[Guest wait — doc code exchange]
    guestSign[Signer link — invitation code]
    thanks[Post-sign thanks]
    embed[Client embed — partner token]
    cscCb[CSC OAuth callback popup]
    scCb[Smart-card callback popup]
    oidcCb[OIDC authorization callback]
    ottCb[One-time token callback]
    passkeyCb[Passkey enrollment callback]
  end

  guestWait --> editorGuest[Prepare / sign UI]
  guestSign --> signUI[Signer experience]
  embed --> prepare
  cscCb --> editorGuest
```

## Authentication methods

```mermaid
flowchart TB
  start[User opens portal] --> kc[Identity provider login]
  kc --> oidcCb[OIDC callback establishes session]
  kc --> sc[Smart-card popup optional]
  kc --> pk[Passkey enroll via provider action]
  oidcCb --> onboard[Post-register onboarding]
  onboard --> profile[Profile setup invited users]
```

## CSC qualified signing in editor

```mermaid
sequenceDiagram
  participant E as Editor view
  participant P as Portal popup
  participant C as CSC provider
  participant API as Signing API

  E->>P: Open OAuth popup
  P->>C: User authorizes
  C->>P: Redirect to callback route with code
  P->>E: Code via same-origin storage
  E->>API: Sign hash with CSC credential
  API-->>E: Signature value embedded in PDF
```

## Integration embed

```mermaid
sequenceDiagram
  participant B as Partner business app
  participant P as Signing Portal embed route
  participant API as Document API

  B->>P: iframe URL with client token + workflow id
  P->>API: Verify embed token
  API-->>P: Workflow authorized
  P->>P: Navigate to prepare or editor target
```

## Related

- [Platform overview](./01-platform-overview.md)
- [CSC sequence](./02-csc-remote-signing-sequence.md)
- [Signing platform README](../../signing-platform-architecture/README.md)
