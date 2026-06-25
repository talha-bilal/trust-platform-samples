# Cloud deployment — fresh install for Saudi / reseller demos

Deploy a **clean, rebrandable IAM demo** on any cloud VM (AWS, Azure, GCP, Oracle, local Saudi hosting) so SecureLink can present to different end customers.

---

## Architecture

One virtual machine runs Docker Compose:

- Keycloak + PostgreSQL  
- Demo directory (OpenLDAP → replace with real AD later)  
- App launcher + 2 live OIDC demo apps  
- 6 additional clients pre-registered (integration packs)  

**Admin panel:** Keycloak Admin Console (sessions, clients, branding).  
See **[ADMIN-OPERATIONS-GUIDE.md](./ADMIN-OPERATIONS-GUIDE.md)**.

---

## VM requirements

| Resource | Minimum |
|----------|---------|
| CPU | 4 vCPU |
| RAM | 8 GB (16 GB recommended) |
| Disk | 64 GB |
| OS | Ubuntu 22.04 / Windows Server with Docker |
| Ports inbound | 3000, 3001, 3002, 8080 (restrict admin to VPN/IP) |

---

## Fresh deploy (from zero)

### 1. Clone on the cloud VM

```bash
git clone https://github.com/talha-bilal/trust-platform-samples.git
cd trust-platform-samples/keycloak-ad-sso-demo
```

### 2. Configure for this customer

```bash
cp .env.example .env
nano .env
```

**Edit at minimum:**

```env
COMPANY_DISPLAY_NAME=Customer Bank IAM Demo
PUBLIC_HOST=http://203.0.113.50
KEYCLOAK_ADMIN_PASSWORD=StrongPasswordHere
```

Use the VM **public IP** or DNS name in `PUBLIC_HOST` (no trailing slash).

### 3. Deploy (wipes previous data)

**Windows:**

```powershell
powershell -ExecutionPolicy Bypass -File setup/fresh-deploy.ps1 -SkipMfa
```

**Linux (Docker + PowerShell):**

```bash
docker compose version
# install pwsh if needed, then:
pwsh -File setup/fresh-deploy.ps1 -SkipMfa
```

Or manually:

```bash
docker compose --env-file .env down -v
pwsh -File setup/render-tenant-config.ps1
docker compose --env-file .env up -d
pwsh -File setup/seed-ldap.ps1
pwsh -File setup/configure-ldap.ps1
pwsh -File setup/register-clients-from-intake.ps1 -IntakeFile setup/apps-intake.generated.json
pwsh -File setup/configure-branding.ps1
```

### 4. Open firewall / security group

Allow TCP: **3000**, **3001**, **3002**, **8080** from presenter network.

### 5. Test

| URL | Purpose |
|-----|---------|
| `http://VM_IP:3000` | App launcher (employees) |
| `http://VM_IP:8080` | Admin console |
| Login | `ahmed` / `Demo@123` |

---

## Rebrand for the next customer

1. `docker compose down -v` (or `fresh-deploy.ps1` again)  
2. Edit `.env` → new `COMPANY_DISPLAY_NAME`, `PUBLIC_HOST`  
3. Run `fresh-deploy.ps1`  
4. Or only change name in Admin → Realm settings → Display name  

---

## Production path (real AD)

1. Keep Keycloak on cloud / on-prem VM  
2. **User federation** → disable demo LDAP → add **Active Directory** (LDAPS)  
3. Point `PUBLIC_HOST` to HTTPS reverse proxy (nginx + TLS)  
4. Change all passwords in `.env`  

---

## HTTPS (recommended for real demos)

Put **nginx** or cloud load balancer in front:

- `https://iam-demo.securelink.sa` → Keycloak :8080  
- `https://apps.securelink.sa` → launcher :3000  

Update `.env` `PUBLIC_HOST` to `https://iam-demo.securelink.sa` and re-run `render-tenant-config.ps1` + `register-clients-from-intake.ps1`.

---

## Files generated per deploy

| File | Purpose |
|------|---------|
| `.env` | Secrets + branding + URLs (do not commit) |
| `demo-apps/config/tenant.json` | App launcher titles + Keycloak URL |
| `setup/apps-intake.generated.json` | Client redirect URIs for this host |
| `integration-packs/*.json` | Hand to app vendors |

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Apps redirect to localhost | Re-run `render-tenant-config.ps1` with correct `PUBLIC_HOST` |
| SSO loop | Check client redirect URIs match `PUBLIC_HOST` ports |
| Admin login fails | Check `KEYCLOAK_ADMIN_*` in `.env` matches compose |
| Blank launcher | Ensure `tenant.json` exists under `demo-apps/config/` |

---

*One command fresh install: `setup/fresh-deploy.ps1`*
