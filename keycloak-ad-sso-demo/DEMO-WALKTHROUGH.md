# Presenter script — client discovery / sales call

Use this on a **screen share** with SecureLink or the end client. Total time: **8–10 minutes**.

## Before the call

```powershell
cd d:\Portfolio\senior\trust-platform-samples\keycloak-ad-sso-demo
powershell -ExecutionPolicy Bypass -File setup/start-demo.ps1 -SkipMfa
```

Test once: http://localhost:3000 → login `ahmed` / `Demo@123` → HR + Finance without second login.

**Full setup details:** [DEMO-SETUP-GUIDE.md](./DEMO-SETUP-GUIDE.md)

---

## 1. Set the scene (30 sec)

> “You asked for **on-prem Keycloak**, **Active Directory** for users, **MFA**, and **single sign-on** into your business applications — up to eight apps in your scope. This demo runs that exact pattern. We use a directory server here instead of your real AD — Keycloak connects the same way in production.”

Show architecture diagram from [README](./README.md).

---

## 2. The employee experience (3 min)

1. Open **http://localhost:3000** (Application launcher).  
   > “This is the employee view — one place to reach all company applications.”

2. Browser redirects to **Keycloak** (`company` realm).  
   > “Users never get a separate password per app. Keycloak is the single login point.”

3. Login: **`ahmed`** / **`Demo@123`**.  
   > “Credentials are validated against the **company directory** — in your case Active Directory over LDAPS.”

4. Show **8 application tiles** — Dynamics, ServiceDesk Plus, Temenos, etc.  
   > “All eight are registered in Keycloak. Two run live in this lab; the rest receive an **integration pack** for the vendor to configure — same as your project.”

5. Open **HR Portal** → show token claims.  
6. Open **Finance Portal** in a **new tab** → **no second login**.  
   > “That’s SSO across your application estate.”

---

## 3. The IT / admin view (3 min)

1. Open **http://localhost:8080** → Admin Console → realm **`company`**.  
2. **User federation** → `company-ldap`.  
   > “Production: point this to your **domain controller**, service account, and group mappers.”

3. **Users** → `ahmed`, `sara` imported from directory.  
4. **Clients** → eight applications (`hr-portal`, `dynamics-365`, `servicedesk-plus`, …).  
5. **Authentication** → OTP / MFA policy.  
6. Open **`integration-packs/dynamics-365.json`** in VS Code / Notepad.  
   > “Each app team gets this — discovery URL or SAML metadata — no manual guesswork.”

---

## 4. Automated onboarding (2 min)

```powershell
notepad setup\apps-intake.example.json
powershell -File setup\register-clients-from-intake.ps1
```

> “New app? Add one JSON entry, run the script — Keycloak Admin API registers the client and generates the integration pack. Minutes on our side; app owner configures their product.”

---

## 5. What we deliver for your project (1 min)

| Phase | Deliverable |
|-------|-------------|
| 1 | Keycloak on your servers + PostgreSQL + TLS |
| 2 | **AD/LDAPS federation** — users, groups, role mapping |
| 3 | **MFA** (TOTP authenticator) |
| 4 | **SSO** per application (OIDC / SAML) + integration packs |
| 5 | Runbooks: backup, restore, add app, add user |
| 6 | Knowledge transfer |

> “I run this stack in production today. This demo is the same architecture at lab scale.”

---

## 6. Questions to ask after the demo

- Confirm the eight applications and protocol per app (OIDC vs SAML)?  
- On-prem AD only, or hybrid with Microsoft 365?  
- HA requirement (single node vs cluster)?  
- Who provides server access and AD service account?  
- UAT window per application owner?

---

## Troubleshooting live

| Issue | Fix |
|-------|-----|
| Docker not running | Start Docker Desktop |
| Login fails | `powershell -File setup/configure-ldap.ps1` |
| Keycloak not up | Wait 60s; `docker compose logs keycloak` |
| SSO loop | Clear cookies; use incognito |
| Port in use | Change ports in `docker-compose.yml` |

---

## After the call

Send: portfolio link, repo link, [IAM-OIDC-AD-Flow.pdf](./docs/IAM-OIDC-AD-Flow.pdf), implementation plan PDF.
