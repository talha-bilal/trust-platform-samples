# Keycloak Admin — operations guide (demo & cloud)

**Important:** You do **not** need a separate custom admin app for this scope. **Keycloak Admin Console** already provides:

- Configurable company / realm name  
- Register new OIDC/SAML clients  
- View active sessions **per user** and **per client application**  
- Revoke individual sessions or sign out everywhere  

This is what SecureLink operators use in production.

---

## 1. Open the admin panel

| Item | Value |
|------|--------|
| URL | `http://YOUR-HOST:8080` (from `.env` → `PUBLIC_HOST` + `KEYCLOAK_PORT`) |
| Username | `KEYCLOAK_ADMIN_USER` in `.env` (default `admin`) |
| Password | `KEYCLOAK_ADMIN_PASSWORD` in `.env` |
| Realm | Select **`company`** in the top-left (not `master`) |

`master` realm = platform admin only.  
`company` realm = customer demo (users, apps, sessions).

---

## 2. Change company / customer name (rebrand for each demo)

### Option A — Admin UI (recommended for sales demos)

1. Realm **`company`** → **Realm settings** → **General**  
2. **Display name** → e.g. `Al Rajhi Bank IAM Demo` or `SecureLink Showcase`  
3. **Save**

Login page and admin header update immediately.

### Option B — `.env` + redeploy script

1. Edit `.env` → `COMPANY_DISPLAY_NAME=Your Customer Name`  
2. Run:

```powershell
powershell -File setup/configure-branding.ps1
powershell -File setup/render-tenant-config.ps1
docker compose restart app-launcher hr-portal finance-portal
```

---

## 3. Register a new application (client)

### From Admin UI (no code)

1. Realm **`company`** → **Clients** → **Create client**  
2. **Client type:** OpenID Connect (or SAML for legacy apps)  
3. **Client ID:** e.g. `new-portal`  
4. **Next** → enable **Standard flow**  
5. **Valid redirect URIs:** `https://app.customer.sa/*`  
6. **Web origins:** `https://app.customer.sa`  
7. **Save**

**Integration pack for vendor:**

- OIDC: **Realm settings** → **General** → copy **OpenID Endpoint Configuration** link  
- Or **Clients** → client → **Client details** → note Client ID, scopes  

### From script (bulk / repeatable)

Edit `setup/apps-intake.example.json`, then:

```powershell
powershell -File setup/render-tenant-config.ps1
powershell -File setup/register-clients-from-intake.ps1 -IntakeFile setup/apps-intake.generated.json
```

Output: `integration-packs/<clientId>.json`

---

## 4. View active sessions (which apps are logged in)

### All sessions in the realm

1. Realm **`company`** → **Sessions**  
2. Lists active SSO sessions (users online)

### Sessions for one user (see each app / client)

1. **Users** → click user (e.g. `ahmed`)  
2. Tab **Sessions**  
3. Shows **each client** where that user has an active session:
   - `hr-portal`
   - `finance-portal`
   - `app-launcher`
   - etc.

This answers: *“Which websites is this user signed into right now?”*

### Sessions for one application

1. **Clients** → e.g. `hr-portal`  
2. Tab **Sessions** (if enabled) or use **Users** → Sessions as above

---

## 5. Revoke sessions (force logout)

### Revoke one user’s session on one app

1. **Users** → user → **Sessions**  
2. Click **Sign out** next to the client session  

### Revoke all sessions for a user (all apps)

1. **Users** → user → **Sessions**  
2. **Sign out all sessions**

### Revoke from realm sessions list

1. **Sessions** → select session → **Logout**

User must log in again (password + MFA if enabled) on next app visit.

---

## 6. MFA administration

| Task | Where |
|------|--------|
| OTP policy | **Authentication** → **Policies** → **OTP Policy** |
| User enroll MFA | **Users** → user → **Required actions** → Configure OTP |
| Reset lost phone | **Users** → user → **Credentials** → delete OTP |
| Require MFA for all | **Authentication** → **Flows** → **browser** → OTP Form → **Required** |

---

## 7. Directory (AD) federation

| Task | Where |
|------|--------|
| Demo LDAP | **User federation** → `company-ldap` |
| Real AD (production) | Replace with new LDAP provider → Active Directory vendor, LDAPS URL, bind DN |

Demo users: `ahmed` / `Demo@123`. Production: real AD accounts.

---

## 8. What is NOT in Keycloak admin (future optional)

| Feature | Status |
|---------|--------|
| Custom SecureLink-branded portal | Optional separate project (calls Admin API) |
| Per-customer multi-tenant SaaS | Use **one realm per customer** or separate deployments |
| MFA status in AD | Lives in Keycloak, not AD (see prior discussion) |

For Saudi cloud resale demos: **one VM per demo customer**, edit realm display name + clients in admin — fast and standard.

---

## 9. Quick demo script for end customer

1. Show **app launcher** — branded name in header  
2. Login as employee → SSO to HR + Finance  
3. Open **Admin** → **Users** → `ahmed` → **Sessions** — show 3 clients active  
4. **Sign out all sessions** → refresh HR tab → asked to login again  
5. **Clients** → **Create client** — “this is how we onboard your 8th application”

---

*Keycloak 24 Admin Console — same UI in demo and production.*
