# IAM Demo Deploy Package

**One package — test on your laptop, then deploy on SecureLink cloud.**

Repository folder: `keycloak-ad-sso-demo/`  
GitHub: `github.com/talha-bilal/trust-platform-samples/tree/main/keycloak-ad-sso-demo`

---

## What is in the package

| Component | Purpose |
|-----------|---------|
| **Keycloak 24** | IAM, MFA, SSO, admin console |
| **PostgreSQL** | Keycloak database |
| **OpenLDAP** | Demo directory (replace with real AD in production) |
| **App launcher** | Employee hub — 8 applications |
| **HR + Finance portals** | Live OIDC SSO demo |
| **Setup scripts** | Fresh install, LDAP, clients, branding |
| **Integration packs** | JSON per app for vendor SSO setup |

**Admin panel:** Keycloak Admin Console (sessions, revoke, new clients, branding).  
No separate admin app required.

---

## Part 1 — Test on this machine (30 minutes)

### Prerequisites

- [ ] Docker Desktop **Running**
- [ ] Ports free: **3000, 3001, 3002, 8080, 1389**
- [ ] Git + PowerShell

### Step 1 — Get the package

```powershell
cd D:\Portfolio\senior\trust-platform-samples\keycloak-ad-sso-demo
git pull
```

### Step 2 — Configure (local)

```powershell
copy .env.example .env
notepad .env
```

**Local values (defaults are fine):**

```env
COMPANY_DISPLAY_NAME=SecureLink IAM Demo
PUBLIC_HOST=http://localhost
KEYCLOAK_ADMIN_PASSWORD=changeme
```

### Step 3 — Fresh install

```powershell
powershell -ExecutionPolicy Bypass -File setup\fresh-deploy.ps1 -SkipMfa
```

Wait ~2–3 minutes (first run downloads Docker images).

### Step 4 — Verify

```powershell
powershell -ExecutionPolicy Bypass -File setup\package-verify.ps1
```

### Step 5 — Manual test checklist

| # | Test | URL / action |
|---|------|----------------|
| 1 | App launcher | http://localhost:3000 |
| 2 | Login | `ahmed` / `Demo@123` |
| 3 | SSO | Open http://localhost:3001 — no second login |
| 4 | Admin | http://localhost:8080 — `admin` / password from `.env` |
| 5 | Realm | Select **`company`** (top-left) |
| 6 | Sessions | Users → ahmed → Sessions — see active clients |
| 7 | Revoke | Sign out all sessions → HR asks login again |
| 8 | Rebrand | Realm settings → Display name → change → Save |
| 9 | New client | Clients → Create client (OIDC) |

**Guides:**

- Presenter script: `DEMO-WALKTHROUGH.md`
- Admin operations: `ADMIN-OPERATIONS-GUIDE.md`
- Full local setup: `DEMO-SETUP-GUIDE.md`

### Step 6 — Optional MFA test

```powershell
powershell -File setup\configure-mfa.ps1
```

Admin → Users → ahmed → Required actions → **Configure OTP** → login again with authenticator app.

---

## Part 2 — Deploy on SecureLink cloud

### What you need from SecureLink IT

| Item | Example |
|------|---------|
| Linux or Windows VM | 4 vCPU, 8–16 GB RAM, 64 GB disk |
| Public IP or DNS | `203.0.113.50` or `iam-demo.securelink.sa` |
| Firewall | Open TCP **3000, 3001, 3002, 8080** (restrict 8080 to office VPN) |
| SSH/RDP access | For install |
| Docker installed | Docker Engine or Docker Desktop |

### Step 1 — Copy package to cloud VM

**Option A — Git (recommended)**

```bash
git clone https://github.com/talha-bilal/trust-platform-samples.git
cd trust-platform-samples/keycloak-ad-sso-demo
```

**Option B — Zip from your machine**

```powershell
# On your PC — zip the folder (exclude .git if large)
Compress-Archive -Path D:\Portfolio\senior\trust-platform-samples\keycloak-ad-sso-demo -DestinationPath D:\iam-demo-package.zip
```

Upload `iam-demo-package.zip` to the VM and unzip.

### Step 2 — Configure for cloud

```bash
cp .env.example .env
nano .env   # or notepad .env on Windows VM
```

**Cloud values:**

```env
COMPANY_DISPLAY_NAME=Customer Name IAM Demo
PUBLIC_HOST=http://203.0.113.50
KEYCLOAK_ADMIN_PASSWORD=UseAStrongPasswordHere
POSTGRES_PASSWORD=UseAStrongPasswordHere
```

Use the VM **public IP** or `https://your-dns` in `PUBLIC_HOST` (no trailing slash).

### Step 3 — Deploy

**Windows VM:**

```powershell
powershell -ExecutionPolicy Bypass -File setup\fresh-deploy.ps1 -SkipMfa
```

**Linux VM (with Docker + PowerShell):**

```bash
sudo apt install -y docker.io docker-compose-plugin
# Install PowerShell: https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu
pwsh -File setup/fresh-deploy.ps1 -SkipMfa
```

### Step 4 — Verify from your browser

Replace `VM_IP` with the real address:

| URL | Purpose |
|-----|---------|
| http://VM_IP:3000 | Employee launcher |
| http://VM_IP:3001 | HR Portal |
| http://VM_IP:8080 | Admin console |

Login: `ahmed` / `Demo@123`

### Step 5 — Hand to SecureLink sales

Send them:

1. Employee URL: `http://VM_IP:3000`
2. Admin URL + credentials (secure channel)
3. `ADMIN-OPERATIONS-GUIDE.md`
4. Test user: `ahmed` / `Demo@123`

---

## Part 3 — Next customer demo (rebrand)

**Fast (name only):** Admin → Realm settings → Display name

**Full reset:**

```powershell
# Edit .env → new COMPANY_DISPLAY_NAME
powershell -ExecutionPolicy Bypass -File setup\fresh-deploy.ps1 -SkipMfa
```

---

## Part 4 — Production path (real AD)

1. Keep same package on customer infrastructure  
2. Admin → **User federation** → replace demo LDAP with **Active Directory** (LDAPS)  
3. Add HTTPS reverse proxy in front of Keycloak  
4. Change all passwords in `.env`  

Technical reference: `docs/IAM-OIDC-AD-Flow.pdf`

---

## Commands reference

| Task | Command |
|------|---------|
| Fresh install | `setup\fresh-deploy.ps1 -SkipMfa` |
| Start (keep data) | `setup\start-demo.ps1 -SkipMfa` |
| Stop | `setup\stop-demo.ps1` |
| Health check | `setup\package-verify.ps1` |
| Enable MFA | `setup\configure-mfa.ps1` |

---

## Package file map

```
keycloak-ad-sso-demo/
  DEPLOY-PACKAGE.md          ← this file (start here)
  .env.example               ← copy to .env
  CLOUD-DEPLOYMENT.md        ← cloud details
  ADMIN-OPERATIONS-GUIDE.md  ← sessions, clients, revoke
  DEMO-WALKTHROUGH.md        ← sales call script
  docker-compose.yml
  setup/
    fresh-deploy.ps1         ← one-command install
    package-verify.ps1       ← health check
  demo-apps/                 ← launcher + portals
  integration-packs/         ← per-app SSO packs
  docs/                      ← PDF proposals + technical guide
```

---

## Support checklist if something fails

| Problem | Fix |
|---------|-----|
| Docker not running | Start Docker Desktop |
| `tenant.json` missing | `powershell -File setup\render-tenant-config.ps1` |
| SSO redirects to localhost on cloud | Fix `PUBLIC_HOST` in `.env`, re-run `fresh-deploy.ps1` |
| Login fails | `powershell -File setup\seed-ldap.ps1` then `configure-ldap.ps1` |
| Port in use | Change ports in `.env` |

---

*Package version: Keycloak 24 · OIDC/SAML · TOTP MFA ready*
