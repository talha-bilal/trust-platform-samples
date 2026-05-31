# Signing Platform (full stack)

End-to-end **digital trust platform**: a multi-tenant **Signing Portal** (React SPA), identity plane, document workflow APIs, CSC remote signing, PKI, and HSM-backed cryptography.

> Architecture below is derived from a production signing workspace UI (routes, modules, API boundaries). All product and company names are **generic** portfolio labels.

## System context

```mermaid
flowchart TB
  subgraph users [Users]
    OrgUser[Organization members]
    GuestSigner[External signers]
    PartnerApp[Partner applications]
  end

  subgraph portal [Signing Portal SPA]
    SPA[React + Vite + TypeScript]
    SPA --> AuthUX[OIDC / passkey / smart-card UX]
    SPA --> DocUX[Documents · folders · templates]
    SPA --> FlowUX[Upload → signers → prepare → editor]
    SPA --> GuestUX[Guest wait · sign · thanks]
    SPA --> EmbedUX[Client embed entry]
  end

  subgraph edge [Edge]
    LB[Load balancer]
    GW[API gateway]
  end

  subgraph services [Backend services]
    AuthAPI[Auth & session API]
    DocAPI[Documents & workflows]
    EditorAPI[PDF editor & fields]
    OrgAPI[Organizations & RBAC]
    CSC[CSC remote signing]
    PKI[PKI / CA API]
  end

  subgraph iam [Identity]
    KC[Identity provider + custom SPI]
  end

  subgraph crypto [Crypto]
    P11[PKCS#11 service]
    HSM[(HSM)]
  end

  subgraph data [Data]
    PG[(PostgreSQL)]
    Redis[(Redis)]
  end

  OrgUser --> SPA
  GuestSigner --> SPA
  PartnerApp --> EmbedUX
  SPA --> LB
  LB --> GW
  GW --> AuthAPI
  GW --> DocAPI
  GW --> EditorAPI
  GW --> OrgAPI
  AuthAPI --> KC
  DocAPI --> KC
  DocAPI --> CSC
  DocAPI --> PKI
  CSC --> P11
  PKI --> P11
  P11 --> HSM
  services --> PG
  services --> Redis
```

## Signing Portal — functional areas

| Area | Purpose |
|------|---------|
| **Home & dashboard** | Activity summary after login |
| **Documents & folders** | Library, move/rename, download options |
| **Templates** | Reusable layouts (RBAC-gated module) |
| **Upload & workflow** | PDF upload, single vs multi-signer choice, recipient list |
| **Prepare & editor** | Place signature/date/text fields on PDF pages |
| **Send & track** | Workflow status, void, password-protected docs |
| **Guest signing** | Email link → wait/exchange code → sign without full account |
| **Signer link** | Public `/sign/:code` route for invited recipients |
| **Settings** | Account, security, signature appearance, notifications |
| **Organization admin** | Users, roles, branding, billing, business apps, org profile |
| **Integrations** | iframe/embed entry via client token + workflow id |
| **Trust methods** | CSC OAuth popup callback, smart-card popup, WebAuthn passkey enrollment |

## Document send flow (authenticated)

```mermaid
sequenceDiagram
  participant U as Org user
  participant P as Signing Portal
  participant A as Document API
  participant E as Editor API
  participant I as Identity provider

  U->>P: Upload PDF
  P->>A: Create document / workflow
  U->>P: Choose single or multi-signer
  U->>P: Add recipients & order
  P->>E: Load prepare / editor session
  U->>P: Place fields & send
  P->>A: Submit workflow
  A-->>U: Notifications to signers
```

## Guest signer flow

```mermaid
sequenceDiagram
  participant S as External signer
  participant P as Signing Portal
  participant A as Document API

  S->>P: Open email link (doc code)
  P->>A: Exchange code for guest session
  A-->>P: Guest bearer + workflow context
  P->>P: Redirect to prepare / sign UI
  S->>P: Sign (drawn signature or qualified path)
  P->>A: Complete signature step
  P->>S: Thanks / optional account CTA
```

## Qualified / remote signing (CSC)

When policy requires **advanced** or **qualified** signatures, the editor opens an OAuth popup to a **CSC-compatible provider**. The portal hosts a dedicated **redirect callback route** that returns the authorization code to the opener via same-origin storage (popup-safe pattern).

See [CSC Remote Signing](../csc-remote-signing-openapi/) and [diagram 02](../docs/diagrams/02-csc-remote-signing-sequence.md).

## Frontend ↔ API map (sanitized)

| Portal concern | Backend service boundary |
|----------------|-------------------------|
| Login, refresh, OTT callback | Auth API |
| Branding, feature flags | App settings API |
| Document list, void, guest token | Documents API |
| Field placement, page render | Editor API |
| Folders | Folders API |
| Templates CRUD | Templates API |
| Org users, roles, quotas | Organization API |
| Signer session (public link) | Signer API |
| Passkey enroll action | Passkey enrollment API |
| User preferences | User settings API |

## Signature policy (tenant RBAC)

Roles can cap which signature **levels** are allowed (electronic, advanced, qualified), whether users may **send** or only **request** signatures, template usage, and per-level **quotas**. Organization owners bypass restrictions for operational safety.

## Deployment topology

```mermaid
flowchart TB
  internet[Internet] --> ingress[Ingress / CDN]
  ingress --> spa[Signing Portal static host]
  ingress --> gw[API gateway]
  gw --> svc[Stateless API pods]
  svc --> idp[Identity cluster]
  svc --> crypto[Crypto tier]
  svc --> db[(PostgreSQL / Redis)]
  crypto --> hsm[(HSM)]
```

## Deeper reading

| Topic | Link |
|-------|------|
| Portal user journeys (diagrams) | [docs/diagrams/08-signing-portal-flows.md](../docs/diagrams/08-signing-portal-flows.md) |
| Document workspace use case | [docs/use-cases/06-document-signing-workspace.md](../docs/use-cases/06-document-signing-workspace.md) |
| Platform overview | [docs/diagrams/01-platform-overview.md](../docs/diagrams/01-platform-overview.md) |
| All use cases | [docs/use-cases/](../docs/use-cases/) |

## Sample projects in this repo

| Capability | Folder |
|------------|--------|
| Keycloak IAM | [keycloak-pki-authenticator](../keycloak-pki-authenticator/) |
| CSC remote signing | [csc-remote-signing-openapi](../csc-remote-signing-openapi/) |
| PKI Server | [pki-server](../pki-server/) |
| PKCS#11 HSM | [pkcs11-hsm-service](../pkcs11-hsm-service/) |
| Java Card | [java-card-applets](../java-card-applets/) |

MIT — portfolio reference only.
