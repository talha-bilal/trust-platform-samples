# IAM + PAM Architecture Note (No Active Directory)

**Prepared for:** SecureLink Arabia — new customer lead  
**Author:** Talha Bilal (Technical delivery partner)  
**Date:** July 2026  
**Status:** Pre-discovery architecture & commercial outline  

---

## 1. Executive summary

The customer needs **Identity & Access Management (IAM)** and **Privileged Access Management (PAM)**, and **does not have Microsoft Active Directory**.

| Capability | Covered by Keycloak? | Recommendation |
|------------|----------------------|----------------|
| User login, MFA, SSO (OIDC/SAML) | **Yes — IAM** | Keycloak (on-prem) |
| Privileged account vaulting, session recording, JIT admin | **No — PAM** | Separate PAM stack |

**Keycloak alone is not enough.** Propose **IAM + PAM** as complementary layers, with an optional lightweight directory if group/org structure is needed without Microsoft AD.

---

## 2. What IAM vs PAM solve

### IAM (Keycloak)

- Employee / contractor identities  
- Multi-factor authentication (TOTP / policy-based)  
- Single sign-on into business applications (OIDC / SAML)  
- Roles and group-based access to apps  
- Central logout and session policy  

### PAM (separate product)

- Shared / privileged account passwords (root, Domain Admin equivalents, DBA)  
- Just-in-time elevation and approval workflows  
- Session recording / audit for SSH, RDP, database, Kubernetes  
- Secrets rotation and break-glass procedures  
- Least privilege for infrastructure admins  

---

## 3. Target architecture (no Active Directory)

```
                    ┌─────────────────────────────┐
                    │     Users / Employees       │
                    └─────────────┬───────────────┘
                                  │
                    ┌─────────────▼───────────────┐
                    │   Keycloak (IAM / IdP)      │
                    │   MFA · OIDC/SAML · Roles   │
                    └──────┬──────────────┬───────┘
                           │              │
              ┌────────────▼───┐    ┌─────▼──────────────┐
              │ Business apps  │    │ Privileged users   │
              │ (SSO)          │    │ (admin personas)   │
              └────────────────┘    └─────┬──────────────┘
                                          │
                              ┌───────────▼──────────────┐
                              │  PAM layer               │
                              │  Vault + Teleport /      │
                              │  Boundary  (or CyberArk) │
                              └───────────┬──────────────┘
                                          │
                    ┌─────────────────────┼─────────────────────┐
                    ▼                     ▼                     ▼
               Servers/SSH            Databases              Cloud / K8s
```

### Recommended stack (cost-conscious, on-prem / private cloud)

| Layer | Component | Role |
|-------|-----------|------|
| **IAM** | Keycloak 24+ | IdP, MFA, SSO, realm policies |
| **Directory (optional)** | OpenLDAP or FreeIPA | Groups / org units *without* Microsoft AD |
| **Secrets** | HashiCorp Vault | Privileged credentials, PKI secrets engine (optional) |
| **Privileged sessions** | Teleport **or** HashiCorp Boundary | SSH/K8s/DB access + audit |
| **Commercial PAM (alt.)** | CyberArk / BeyondTrust / Delinea | If customer prefers enterprise support & compliance packaging |

**Identity without AD:** Keycloak can use its **internal user database**, or federate OpenLDAP/FreeIPA. Microsoft AD is **not required**.

---

## 4. Discovery questions (ask the customer)

1. How many users (employees) and how many **privileged** admins?  
2. Privileged targets: SSH Linux, Windows RDP, databases, Kubernetes, cloud consoles (AWS/Azure/GCP)?  
3. Preferred hosting: on-prem Saudi, private cloud, or public cloud?  
4. Compliance needs: audit logs, session recording retention, NCA / ISO / SOC2?  
5. Budget preference: open-source stack vs commercial PAM license?  
6. Existing apps to SSO (list + OIDC/SAML capability)?  
7. Who creates/disables users today (HR, IT spreadsheet, Google Workspace)?  

---

## 5. Delivery phases (commercial scope)

### Phase 0 — Discovery & design (1 week)

**Deliverables**

- Current-state & target architecture diagram  
- IAM vs PAM scope matrix  
- Product recommendation (open-source vs commercial PAM)  
- High-level effort & timeline  

### Phase 1 — IAM foundation (Keycloak)

**Deliverables**

- Keycloak deployment (HA as agreed) + PostgreSQL  
- Realm design, MFA policy, admin handover  
- Optional: OpenLDAP/FreeIPA if directory structure is required  
- SSO for **pilot applications** (typically 2–3 apps)  
- Runbooks: backup, user onboarding, client registration  

**Demo available:** existing SecureLink Keycloak lab (SSO + MFA pattern).

### Phase 2 — PAM foundation

**Deliverables**

- Privileged access path for agreed targets (e.g. SSH + one DB or K8s)  
- Secrets storage / rotation model (Vault or commercial PAM)  
- Session audit / recording where product supports it  
- Break-glass procedure documented  
- Integration: privileged users authenticate via Keycloak where applicable  

### Phase 3 — Rollout & hardening

**Deliverables**

- Remaining SSO apps (agreed backlog)  
- Expanded PAM targets  
- Monitoring / alerting hooks  
- Knowledge transfer + optional hypercare (2–4 weeks)  

---

## 6. Indicative commercial packaging (for SecureLink)

Use as a **discussion frame** — final quote after discovery.

| Package | Scope | Notes |
|---------|--------|--------|
| **A — IAM only** | Keycloak + MFA + pilot SSO (2–3 apps) | Fastest path; PAM deferred |
| **B — IAM + PAM starter** | Package A + Vault/Teleport (or Boundary) for core privileged paths | Recommended for this lead |
| **C — Enterprise PAM** | Package A + CyberArk / BeyondTrust licensed stack | Higher license cost; stronger compliance story |

**Subcontractor delivery (Talha)** can cover architecture, Keycloak IAM, open-source PAM integration, documentation, and demo — same engagement model as the previous AD/SSO lead. Commercial PAM license sales remain SecureLink’s product line if chosen.

---

## 7. Messaging for SecureLink → customer

> You asked for IAM and PAM without Active Directory. We recommend **Keycloak for IAM** (central login, MFA, and SSO). **PAM is a separate layer** for admin/privileged access (vaulting and audited sessions). They work together: Keycloak proves *who* you are; PAM controls *what privileged systems* you may touch and records that access. Active Directory is optional — we can use Keycloak’s own directory or OpenLDAP/FreeIPA.

---

## 8. Next step

1. SecureLink confirms customer interest and answers discovery questions (§4).  
2. Talha delivers a **customer-facing one-pager** (branded) and effort estimate for Package A or B.  
3. Optional: 30-minute architecture call + Keycloak demo.

---

*Contact: Talha Bilal · talha.at43@gmail.com · +92 304 374 2912 · https://talha-bilal.github.io/portfolio/*
