# Keycloak + Active Directory + application SSO — client demo

Runnable lab that mirrors a **typical integrator client ask**:

> On-prem Keycloak · directory (Active Directory) for users · OIDC single sign-on across internal applications.

**OpenLDAP in this demo = stand-in for Active Directory.** Keycloak uses the same **LDAP user federation** settings in production; only the connection URL, bind DN, and attribute names change.

## What you can show the client (5 minutes)

| Step | Show |
|------|------|
| 1 | Employee opens **HR Portal** → redirected to **Keycloak** login |
| 2 | User signs in with **directory password** (`ahmed` / `Demo@123`) — not a separate app password |
| 3 | User lands in HR app with OIDC token (name, email claims) |
| 4 | Open **Finance Portal** in new tab → **already signed in** (SSO) |
| 5 | Keycloak admin → Users imported from directory; two OIDC clients registered |

Full presenter script: **[DEMO-WALKTHROUGH.md](./DEMO-WALKTHROUGH.md)**

**Detailed PDF guide (AD + OIDC flows):** [docs/IAM-OIDC-AD-Flow.pdf](./docs/IAM-OIDC-AD-Flow.pdf)  

**Customer proposal (professional PDF with diagrams):** [docs/SecureLink-Customer-Implementation-Proposal.pdf](./docs/SecureLink-Customer-Implementation-Proposal.pdf) — edit [docs/proposal/securelink-proposal.html](./docs/proposal/securelink-proposal.html) then run `python scripts/generate_proposal_pdf.py`

## Architecture

```mermaid
flowchart TB
  subgraph users [Employees]
    U[Browser]
  end

  subgraph apps [Business applications]
    HR[HR Portal :3001]
    FIN[Finance Portal :3002]
  end

  subgraph iam [On-prem IAM]
    KC[Keycloak :8080]
    PG[(PostgreSQL)]
  end

  subgraph directory [Company directory]
    LDAP[(OpenLDAP demo\n= Active Directory in prod)]
  end

  U --> HR
  U --> FIN
  HR -->|OIDC login| KC
  FIN -->|OIDC login| KC
  KC --> PG
  KC -->|LDAP federation| LDAP
```

## Quick start (Windows)

```powershell
cd keycloak-ad-sso-demo
docker compose up -d
# wait ~60s for Keycloak
powershell -File setup/configure-ldap.ps1
```

Open:

| URL | Purpose |
|-----|---------|
| http://localhost:3001 | HR Portal (login first) |
| http://localhost:3002 | Finance Portal (SSO) |
| http://localhost:8080 | Keycloak admin (`admin` / `admin`) |

**Demo users** (directory):

| Username | Password | Groups |
|----------|----------|--------|
| `ahmed` | `Demo@123` | employees |
| `sara` | `Demo@123` | employees, hr-team |

## Map demo → client production

| Demo | Client production |
|------|-------------------|
| OpenLDAP container | **Active Directory** domain controller |
| `ldap://openldap:389` | `ldap://dc.company.local:389` or **LDAPS :636** |
| `cn=admin,dc=company,dc=local` | Service account `CN=kc-bind,OU=Service Accounts,...` |
| `uid` / `inetOrgPerson` | `sAMAccountName` / `user` object classes |
| HR + Finance HTML apps | Client’s real web apps (Spring, .NET, etc.) |
| `start-dev` Keycloak | Hardened on-prem install + TLS + backups |

## Deliverables this demo represents

- Keycloak on infrastructure with PostgreSQL  
- Directory federation (users + groups)  
- OIDC client per application  
- SSO session across apps  
- Admin console + sync + handover documentation  

## Files

```
keycloak-ad-sso-demo/
  docker-compose.yml      # Keycloak, Postgres, LDAP, two demo apps
  ldap/bootstrap.ldif     # Demo employees & groups
  keycloak/import/        # Realm + OIDC clients
  demo-apps/              # HR & Finance portals
  setup/configure-ldap.*  # Attach LDAP federation + sync users
  DEMO-WALKTHROUGH.md     # Call / presentation script
  PROJECT.md              # Client-facing summary
```

MIT — portfolio demonstration only.
