# Presenter script — client discovery / sales call

Use this on a **screen share** with SecureLink or the end client. Total time: **5–7 minutes**.

## Before the call

```powershell
cd keycloak-ad-sso-demo
docker compose up -d
powershell -File setup/configure-ldap.ps1
```

Test once: http://localhost:3001 → login `ahmed` / `Demo@123` → http://localhost:3002 (no second login).

---

## 1. Set the scene (30 sec)

> “You asked for **on-prem Keycloak**, **Active Directory** for users, and **single sign-on** into your business applications. This demo shows that exact pattern. We use a directory server here instead of your real AD — Keycloak connects the same way in production.”

Show architecture diagram from [README](./README.md).

---

## 2. The employee experience (2 min)

1. Open **http://localhost:3001** (HR Portal).  
   > “This is any internal web app — HR, documents, operations.”

2. Browser redirects to **Keycloak** (`company` realm).  
   > “Users never get a separate password per app. Keycloak is the single login point.”

3. Login: **`ahmed`** / **`Demo@123`**.  
   > “Credentials are validated against the **company directory** — in your case Active Directory over LDAP.”

4. Show token claims on the page (username, email).  
   > “The app receives standard **OIDC tokens** — identity, roles, audit subject.”

5. Open **http://localhost:3002** (Finance Portal) in a **new tab**.  
   > “Second application, same realm — **no second login**. That’s SSO.”

---

## 3. The IT / admin view (2 min)

1. Open **http://localhost:8080** → Admin Console → realm **`company`**.  
2. **Users** → show `ahmed`, `sara` imported from directory.  
   > “IT keeps managing people in AD. Keycloak federates and syncs.”

3. **Clients** → `hr-portal`, `finance-portal`.  
   > “Each business application is registered once — redirect URLs, OIDC settings.”

4. **User federation** → `company-ldap`.  
   > “Production: point this to your **domain controller**, service account, and group mappers for roles.”

---

## 4. What we deliver for your project (1 min)

| Phase | Deliverable |
|-------|-------------|
| 1 | Keycloak on your servers (VM/Docker) + PostgreSQL + TLS |
| 2 | **AD/LDAP federation** — users, groups, role mapping |
| 3 | **OIDC integration** per application (as many as scoped) |
| 4 | Runbooks: backup, restore, add user, add app |
| 5 | Optional support / upgrades |

> “I run this stack in production today. This demo is the same architecture at small scale.”

---

## 5. Questions to ask after the demo

- How many applications need SSO in phase one?  
- On-prem AD only, or hybrid with Microsoft 365?  
- Approximate user count?  
- Single server or HA?  
- Who provides server access and AD service account?

---

## Troubleshooting live

| Issue | Fix |
|-------|-----|
| Login fails | Re-run `setup/configure-ldap.ps1` |
| Keycloak not up | `docker compose logs keycloak` — wait 60s |
| SSO loop | Clear cookies; use incognito |
| Port in use | Change ports in `docker-compose.yml` |

---

## After the call

Send: portfolio link, this repo folder link, and a short scope email with phases above.
