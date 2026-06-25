# Demo setup & presentation guide

Complete instructions to run the **on-prem Keycloak + directory (AD) + MFA + application SSO** lab on your Windows machine and present it to SecureLink or the end customer.

This environment mirrors what you will deliver in production. OpenLDAP stands in for **Active Directory**; HR and Finance portals stand in for real business applications; six additional apps are **registered in Keycloak** with integration packs (same process as Dynamics, ServiceDesk Plus, Temenos, etc.).

---

## 1. What this demo proves

| Customer requirement | What you show locally |
|---------------------|------------------------|
| On-prem Keycloak + PostgreSQL | Docker stack — same components, production-hardened on their VMs |
| Active Directory users | OpenLDAP with `ahmed` / `sara` — **same LDAP federation** settings as AD |
| MFA (TOTP authenticator) | OTP policy + optional enrollment in Keycloak admin |
| SSO for multiple applications | Login once at launcher → open HR + Finance with no second password |
| Up to 8 applications | 8 clients registered via automated intake script + integration packs |
| Repeatable onboarding | `apps-intake.example.json` → `register-clients-from-intake.ps1` |

---

## 2. Prerequisites

| Requirement | Details |
|-------------|---------|
| **OS** | Windows 10/11 (scripts are PowerShell; Linux: use `.sh` variants) |
| **Docker Desktop** | [Install Docker Desktop](https://www.docker.com/products/docker-desktop/) — must show **Running** |
| **RAM** | 8 GB minimum (16 GB recommended while Docker runs) |
| **Ports free** | 3000, 3001, 3002, 8080, 1389 |
| **Browser** | Chrome or Edge (incognito useful for clean SSO tests) |
| **Repo path** | `d:\Portfolio\senior\trust-platform-samples\keycloak-ad-sso-demo` |

### Verify Docker

```powershell
docker info
```

If you see `error during connect` → open **Docker Desktop** and wait until the whale icon is steady.

---

## 3. Quick start (one command)

```powershell
cd d:\Portfolio\senior\trust-platform-samples\keycloak-ad-sso-demo
powershell -ExecutionPolicy Bypass -File setup/start-demo.ps1
```

First run downloads images (~2–5 minutes). Keycloak needs **~60 seconds** after containers start.

**Skip MFA** (faster repeat demos):

```powershell
powershell -ExecutionPolicy Bypass -File setup/start-demo.ps1 -SkipMfa
```

**Full reset** (wipe database and start fresh):

```powershell
powershell -ExecutionPolicy Bypass -File setup/reset-demo.ps1
```

---

## 4. What `start-demo.ps1` does

| Step | Script | Action |
|------|--------|--------|
| 1 | `docker compose up -d` | Starts Keycloak, PostgreSQL, OpenLDAP, 3 demo apps |
| 2 | `configure-ldap.ps1` | Attaches LDAP federation, syncs directory users |
| 3 | `register-clients-from-intake.ps1` | Registers 8 SSO clients, writes `integration-packs/*.json` |
| 4 | `configure-mfa.ps1` | TOTP policy + OTP step on login flow (unless `-SkipMfa`) |

---

## 5. URLs and credentials

### Applications (open in browser)

| URL | Purpose |
|-----|---------|
| **http://localhost:3000** | **Start here** — application launcher (8 apps) |
| http://localhost:3001 | HR Portal (live OIDC demo) |
| http://localhost:3002 | Finance Portal (live OIDC — tests SSO) |
| http://localhost:8080 | Keycloak Admin Console |

### Keycloak admin

| Field | Value |
|-------|-------|
| URL | http://localhost:8080 |
| Username | `admin` |
| Password | `admin` |
| Realm | `company` (not `master`) |

### Directory users (employee login)

| Username | Password | Groups |
|----------|----------|--------|
| `ahmed` | `Demo@123` | employees |
| `sara` | `Demo@123` | employees, hr-team |

Password is validated against the **directory** (LDAP), not stored separately in Keycloak.

---

## 6. Manual setup (if you prefer step by step)

```powershell
cd d:\Portfolio\senior\trust-platform-samples\keycloak-ad-sso-demo

# 1. Start infrastructure
docker compose up -d

# 2. Wait until Keycloak is healthy (~60s), then:
powershell -File setup/configure-ldap.ps1

# 3. Register all application clients + generate integration packs
powershell -File setup/register-clients-from-intake.ps1

# 4. Optional — MFA
powershell -File setup/configure-mfa.ps1
```

### Stop demo

```powershell
powershell -File setup/stop-demo.ps1
```

---

## 7. Verify everything works (checklist)

Before a customer call, run through this list:

- [ ] http://localhost:8080/health/ready returns OK
- [ ] http://localhost:3000 redirects to Keycloak login
- [ ] Login `ahmed` / `Demo@123` succeeds
- [ ] Launcher shows 8 application tiles
- [ ] http://localhost:3001 opens **without** second login (SSO)
- [ ] http://localhost:3002 opens **without** second login
- [ ] Keycloak Admin → realm `company` → **Users** → `ahmed`, `sara` present
- [ ] Keycloak Admin → **Clients** → 8+ clients listed
- [ ] Keycloak Admin → **User federation** → `company-ldap` connected
- [ ] Folder `integration-packs/` contains JSON files per app

---

## 8. Presentation flow (10 minutes)

Full script: **[DEMO-WALKTHROUGH.md](./DEMO-WALKTHROUGH.md)**

### A. Architecture (1 min)

> “You asked for on-prem Keycloak, Active Directory, MFA, and SSO into your business applications. This lab runs the same architecture. We use a directory server instead of your AD — Keycloak connects identically in production.”

Show diagram in [README.md](./README.md).

### B. Employee experience (3 min)

1. Open **http://localhost:3000** (application launcher).
2. Sign in: `ahmed` / `Demo@123`.
3. Point out **8 applications** — same pattern as your scope (Dynamics, ServiceDesk, etc.).
4. Open **HR Portal** → already authenticated.
5. Open **Finance Portal** in a new tab → **no second login** (SSO).
6. Show token claims on HR or Finance page.

### C. IT / admin view (3 min)

1. http://localhost:8080 → Admin → realm **`company`**.
2. **User federation** → `company-ldap` → “Production: your domain controller + LDAPS.”
3. **Users** → federated users from directory.
4. **Clients** → all 8 applications registered.
5. **Authentication** → OTP policy (MFA).
6. Open `integration-packs/dynamics-365.json` → “This is what each app team receives.”

### D. Automated onboarding (2 min)

> “We don’t click through the admin UI for every new app. We use a standard intake file and a script that calls Keycloak’s Admin API.”

```powershell
# Show intake file
notepad setup\apps-intake.example.json

# Re-run registration (idempotent)
powershell -File setup\register-clients-from-intake.ps1
```

### E. Production mapping (1 min)

| Demo | Customer production |
|------|---------------------|
| OpenLDAP `:1389` | Active Directory LDAPS `:636` |
| `ldap://openldap:389` | `ldaps://dc.company.local:636` |
| `uid` attribute | `sAMAccountName` or UPN |
| HTTP localhost | HTTPS `https://auth.company.com` |
| 2 live HTML apps | Their real apps (vendor configures using integration pack) |
| Docker Compose | VMs or Kubernetes on-prem |

---

## 9. Integration packs (for app owners)

After `register-clients-from-intake.ps1`, each app has a JSON file in **`integration-packs/`**.

**OIDC example** (`hr-portal.json`):

- `discoveryUrl` — app team plugs into Spring Security, .NET, etc.
- `clientId`, `redirectUris`, `scopes`
- `clientSecret` — only for confidential clients (e.g. Dynamics)

**SAML example** (`servicedesk-plus.json`):

- `samlMetadataUrl` — import into ManageEngine / vendor admin
- `entityId`, ACS URLs

**Important:** Your script registers the client in Keycloak. Each **application vendor** still configures their product using this pack — that is normal and expected.

---

## 10. Adding a new application (practice)

1. Edit `setup/apps-intake.example.json` — add an entry:

```json
{
  "name": "New Internal App",
  "clientId": "new-internal-app",
  "protocol": "oidc",
  "publicClient": true,
  "redirectUris": ["https://newapp.company.local/*"],
  "webOrigins": ["https://newapp.company.local"]
}
```

2. Run:

```powershell
powershell -File setup/register-clients-from-intake.ps1
```

3. Send `integration-packs/new-internal-app.json` to the app owner.

---

## 11. MFA demo options

| Option | How |
|--------|-----|
| Show policy only | Realm settings → Authentication → Policies → OTP |
| Enroll during call | Users → `ahmed` → Credentials → Set up Authenticator application |
| First-login enrollment | Users → `ahmed` → Required user actions → Configure OTP |

For repeat demos without scanning QR each time, use `-SkipMfa` when starting.

---

## 12. Troubleshooting

| Problem | Solution |
|---------|----------|
| `Docker is not running` | Start Docker Desktop; wait 30s; retry |
| Keycloak not ready | `docker compose logs keycloak` — wait 60–90s |
| Login fails for ahmed | `powershell -File setup/configure-ldap.ps1` |
| SSO redirect loop | Clear cookies or use incognito |
| Port already in use | Change ports in `docker-compose.yml` |
| Clients missing | `powershell -File setup/register-clients-from-intake.ps1` |
| Stale state | `powershell -File setup/reset-demo.ps1` |

### Useful commands

```powershell
docker compose ps
docker compose logs -f keycloak
docker compose down          # stop
docker compose down -v       # stop + wipe data
```

---

## 13. Files reference

```
keycloak-ad-sso-demo/
  DEMO-SETUP-GUIDE.md          ← this document
  DEMO-WALKTHROUGH.md          ← short presenter script
  README.md                    ← overview
  docker-compose.yml           ← full stack definition
  setup/
    start-demo.ps1             ← one-command start
    stop-demo.ps1 / reset-demo.ps1
    configure-ldap.ps1         ← directory federation
    configure-mfa.ps1          ← TOTP setup
    register-clients-from-intake.ps1
    apps-intake.example.json   ← 8-app customer scope template
    _keycloak.ps1              ← shared admin helpers
  integration-packs/           ← generated per-app SSO packs
  keycloak/import/             ← realm bootstrap
  ldap/bootstrap.ldif          ← demo users
  demo-apps/                   ← launcher + HR + Finance
  docs/                        ← PDF guides & proposals
```

---

## 14. Materials to send after the call

| Item | Path / link |
|------|-------------|
| Portfolio | https://talha-bilal.github.io/portfolio |
| This demo repo | github.com/talha-bilal/trust-platform-samples/tree/main/keycloak-ad-sso-demo |
| Technical PDF | docs/IAM-OIDC-AD-Flow.pdf |
| Your implementation plan | Talha-Bilal-SecureLink-Delivery-Offer.pdf |

---

*Portfolio demonstration — no customer data. MIT license.*
