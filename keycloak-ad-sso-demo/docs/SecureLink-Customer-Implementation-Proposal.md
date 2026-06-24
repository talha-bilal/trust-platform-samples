# Secure Identity Platform

## On-Premises Keycloak IAM for Active Directory, SSO & MFA

**Implementation proposal & delivery plan**

---

| | |
|---|---|
| **Prepared for** | [Customer organization name] |
| **Prepared by** | [SecureLink Arabia](https://www.securelink.sa/) — IAM & cybersecurity services |
| **Technical delivery** | Talha Bilal — Senior Java / Keycloak IAM engineer |
| **User scope** | 250–300 employees |
| **Document version** | 1.0 |
| **Validity** | 90 days from issue date |
| **Classification** | Customer confidential |

---

## Table of contents

1. [Executive summary](#1-executive-summary)  
2. [Why this investment matters](#2-why-this-investment-matters)  
3. [Proposed solution](#3-proposed-solution)  
4. [What you will gain — benefits](#4-what-you-will-gain--benefits)  
5. [Scope of work](#5-scope-of-work)  
6. [Implementation plan — how we achieve it](#6-implementation-plan--how-we-achieve-it)  
7. [Application SSO — integration approach](#7-application-sso--integration-approach)  
8. [Technical prerequisites — your responsibilities](#8-technical-prerequisites--your-responsibilities)  
9. [Security, operations & compliance](#9-security-operations--compliance)  
10. [Deliverables](#10-deliverables)  
11. [Project timeline](#11-project-timeline)  
12. [Commercial proposal](#12-commercial-proposal)  
13. [Optional services](#13-optional-services)  
14. [Assumptions, exclusions & change control](#14-assumptions-exclusions--change-control)  
15. [Approval](#15-approval)  

---

## 1. Executive summary

[Customer name] requires a **locally hosted Identity and Access Management (IAM)** platform for approximately **250–300 users**, integrated with your existing **Microsoft Active Directory**, enabling **Single Sign-On (SSO)** and **Multi-Factor Authentication (MFA)** across your business applications — with all identity infrastructure remaining **inside your approved environment in Saudi Arabia**.

**SecureLink Arabia** proposes to design, implement, test, and hand over a production-grade solution based on **Keycloak**, the industry-standard open IAM platform supporting **OpenID Connect, OAuth 2.0, and SAML 2.0**.

### Summary of the offer

| Item | Proposal |
|------|----------|
| Identity platform | Keycloak (on-prem) + PostgreSQL |
| User directory | Active Directory via LDAPS (AD remains source of truth) |
| Authentication | Centralized login + MFA (authenticator app / OTP) |
| Application access | SSO for up to **8 applications** (standard protocols) |
| Delivery period | **4–6 weeks** from kickoff (subject to readiness) |
| Investment | **SAR 138,000** fixed professional services (see Section 12) |

This document explains **what will be delivered**, **how we will implement it step by step**, **what your team must provide**, and **the business value** you should expect. It is intended for technical and business reviewers before project approval.

---

## 2. Why this investment matters

### 2.1 Challenges without centralized IAM

| Challenge | Business impact |
|-----------|-----------------|
| Separate login for every application | Password fatigue, help-desk load, weak passwords |
| Manual user setup per system | Slow onboarding; ex-employees may retain access |
| No unified MFA policy | Higher risk of account takeover |
| Fragmented audit trails | Difficult investigations and compliance evidence |
| Identity data leaving KSA | Regulatory and data-residency concerns |

### 2.2 Strategic drivers

- **Security posture** — One place to enforce MFA, lockout, and session policies  
- **Operational efficiency** — IT manages users once in Active Directory  
- **Employee experience** — One login for HR, service desk, dashboards, and line-of-business tools  
- **Data sovereignty** — IAM hosted on **your** servers in Saudi Arabia  
- **Future readiness** — Standard protocols (OIDC/SAML) for new applications  

---

## 3. Proposed solution

### 3.1 Architecture overview

```
                    +-----------------------------+
                    |     Employees (250-300)      |
                    +--------------+--------------+
                                   | HTTPS
                                   v
                    +-----------------------------+
                    |   auth.[your-domain].com    |
                    |   (TLS / reverse proxy)     |
                    +--------------+--------------+
                                   |
          +------------------------+------------------------+
          |                        |                        |
          v                        v                        v
   +-------------+        +---------------+        +------------------+
   |  Keycloak   |<------>|  PostgreSQL   |        |  Business apps   |
   |  (on-prem)  |        |  (database)   |        |  (up to 8)       |
   +------+------+        +---------------+        +---------+--------+
          |                                                    ^
          | LDAPS                                              | OIDC / SAML
          v                                                    |
   +-------------+                                            |
   |   Active    |                                            |
   |  Directory  |--------------------------------------------+
   | (existing)  |         SSO — users sign in once
   +-------------+
```

### 3.2 Component roles

| Component | Role |
|-----------|------|
| **Active Directory** | Master list of employees, groups, passwords — unchanged as your HR/IT process |
| **Keycloak** | Login page, SSO session, MFA, application trust, audit events |
| **PostgreSQL** | Production database for Keycloak configuration and sessions |
| **Reverse proxy + TLS** | Secure public URL for authentication (HTTPS only) |
| **Each business application** | Trusts Keycloak instead of local passwords |

### 3.3 Identity flow (what employees experience)

1. Employee opens an application (e.g. service desk, internal portal).  
2. Application redirects to **Keycloak** (no local login screen).  
3. Employee enters **Active Directory username and password**.  
4. Keycloak prompts for **MFA** (authenticator app) if policy requires it.  
5. Employee is returned to the application — **already signed in**.  
6. Opening a second application **does not require logging in again** (SSO).  

### 3.4 What stays in Active Directory

- Creating and disabling user accounts  
- Group membership (e.g. Finance, IT, Operations)  
- Password policy and lockout (as today)  

Keycloak **reads** AD over LDAPS and **authenticates** users; it does not replace your directory.

---

## 4. What you will gain — benefits

### 4.1 Security benefits

| Benefit | Description |
|---------|-------------|
| **Centralized MFA** | OTP/authenticator enforced at one policy point |
| **Reduced credential sprawl** | Fewer application-specific passwords |
| **Consistent session control** | Timeouts and logout behaviour aligned |
| **Brute-force protection** | Keycloak lockout policies on login endpoint |
| **Audit visibility** | Login success/failure events in IAM platform |
| **On-prem control** | No dependency on foreign public identity clouds for core auth |

### 4.2 Operational benefits

| Benefit | Description |
|---------|-------------|
| **Faster onboarding** | New AD user + group → access to SSO apps after sync |
| **Faster offboarding** | Disable AD account → access removed across integrated apps |
| **Single admin model** | Application owners focus on app roles; IT owns identity |
| **Documented runbooks** | Backup, restore, add application, MFA support procedures |

### 4.3 Business & user benefits

| Benefit | Description |
|---------|-------------|
| **Productivity** | Less time lost to password resets and repeated logins |
| **Professional experience** | Branded login consistent across applications |
| **Scalability** | Add applications via standard SSO protocols |
| **Predictable project** | Fixed scope, phased delivery, clear sign-off |

### 4.4 Return on investment (qualitative)

For 250–300 users, organizations typically recover project cost through:

- Reduced **help-desk password tickets** (often 15–30% of tier-1 volume is access-related)  
- **Lower breach risk** from MFA and deprovisioning consistency  
- **Faster vendor/app onboarding** when SSO is already in place  
- **Avoided custom auth development** in each new internal tool  

*Quantitative ROI depends on your ticket volumes and audit requirements; we can assist with a simple baseline during discovery.*

---

## 5. Scope of work

### 5.1 In scope (base package)

| # | Area | Detail |
|---|------|--------|
| 1 | **User capacity** | Up to **300** synchronized users |
| 2 | **Platform** | Keycloak deployment on customer infrastructure |
| 3 | **Database** | PostgreSQL integration (external DB server) |
| 4 | **Directory** | Active Directory integration via **LDAPS** |
| 5 | **MFA** | Authenticator application / **TOTP OTP** (baseline) |
| 6 | **SSO** | Up to **8 applications** supporting OIDC, OAuth 2.0, or SAML 2.0 |
| 7 | **Security** | HTTPS, admin roles, brute-force, session policies |
| 8 | **Documentation** | Design, admin guide, backup/restore, test summary |
| 9 | **Knowledge transfer** | Administrator training session |
| 10 | **Support during project** | Implementation and UAT assistance through sign-off |

### 5.2 Applications proposed for validation

Final list confirmed in **Week 1 discovery**. Candidate applications from your requirements:

| # | Application | Typical SSO protocol* |
|---|-------------|------------------------|
| 1 | Microsoft Dynamics | OIDC / SAML (version-dependent) |
| 2 | ManageEngine ServiceDesk Plus | SAML / OIDC |
| 3 | ManageEngine Endpoint Central | SAML / OIDC |
| 4 | Internal dashboard / portal | OIDC (recommended) |
| 5 | Temenos | SAML (common) |
| 6 | Tookitaki | OIDC / SAML (to confirm) |
| 7 | SAS | SAML / OIDC |
| 8 | Hungerstation application | OIDC (to confirm) |
| 9 | Spine | To confirm with vendor |

\*Protocol confirmed per application during discovery. **Eight (8)** applications included in base commercial package; ninth or additional apps are optional.

### 5.3 Out of scope (unless separately quoted)

- Custom connector development or application **source code** changes  
- Applications **without** SAML, OIDC, or OAuth support  
- SMS/email MFA gateway **charges** (OTP app is in scope)  
- Hardware, Windows/Linux licences, database licences  
- Load balancer / **full HA cluster** (optional add-on)  
- 24×7 managed support (optional add-on)  
- Company-wide end-user training for all 300 staff  
- IGA, PAM, or full HR-driven lifecycle automation  

---

## 6. Implementation plan — how we achieve it

SecureLink will execute the project in **six phases**. Each phase has clear **entry criteria**, **activities**, **your involvement**, and **exit criteria** before the next phase starts.

---

### Phase 1 — Discovery & design (Week 1)

**Objective:** Confirm reality on the ground before any production change.

| Step | Activity | Owner | Your action required |
|------|----------|-------|----------------------|
| 1.1 | Kickoff workshop (2–3 hours) | SecureLink | Nominate IT lead, AD admin, app owners |
| 1.2 | Inventory Active Directory (domains, OUs, groups) | SecureLink + IT | Provide AD read-only overview |
| 1.3 | Confirm LDAPS connectivity path & service account | SecureLink + IT | Create `svc-keycloak` bind account |
| 1.4 | Application readiness assessment (8 apps) | SecureLink + app owners | Complete SSO readiness questionnaire |
| 1.5 | Confirm VMs, DNS name, SSL certificate plan | SecureLink + IT | Provision or schedule servers |
| 1.6 | Publish solution design & firewall matrix | SecureLink | Review and approve design |
| 1.7 | Publish detailed implementation plan | SecureLink | Approve go-live window |

**Exit criteria:** Signed design summary, confirmed app list (8), prerequisites checklist accepted.

---

### Phase 2 — Platform deployment (Week 2)

**Objective:** Running Keycloak platform ready for directory integration.

| Step | Activity | Detail |
|------|----------|--------|
| 2.1 | OS hardening baseline | Customer VM access via approved admin network |
| 2.2 | Install PostgreSQL (if not pre-installed) | Dedicated DB server per sizing guide |
| 2.3 | Deploy Keycloak | Production-oriented configuration (not dev mode) |
| 2.4 | Configure JDBC to PostgreSQL | Connection pooling, credentials secured |
| 2.5 | Configure TLS | Customer-provided certificate on `auth.[domain]` |
| 2.6 | Create production realm | Security headers, password policy alignment |
| 2.7 | Configure admin roles | Least-privilege admin accounts |
| 2.8 | Enable brute-force detection | Lockout thresholds per policy |
| 2.9 | Platform smoke test | Admin console, health endpoints, backup snapshot |

**Recommended server sizing (baseline single-node):**

| Server | vCPU | RAM | Disk |
|--------|------|-----|------|
| Keycloak application | 4 | 16 GB | 64 GB |
| PostgreSQL database | 4 | 8 GB | 64 GB |

**Exit criteria:** Keycloak reachable on HTTPS; database backed up; admin access verified.

---

### Phase 3 — Active Directory integration (Week 2)

**Objective:** Employees authenticate with AD credentials through Keycloak.

| Step | Activity | Instruction / detail |
|------|----------|----------------------|
| 3.1 | Import LDAPS CA trust | Keycloak trusts domain controller certificate |
| 3.2 | Configure user federation | Connection URL: `ldaps://dc.[domain]:636` |
| 3.3 | Configure bind DN | e.g. `CN=svc-keycloak,OU=Service Accounts,DC=...` |
| 3.4 | Set user LDAP filters | Users DN, username attribute (`sAMAccountName` or UPN) |
| 3.5 | Configure group mapper | AD groups → Keycloak groups/roles |
| 3.6 | Sync users | Import up to 300 users; validate sample accounts |
| 3.7 | Test authentication | Test users: login, lockout, disabled AD account |
| 3.8 | Document sync behaviour | How AD changes propagate (periodic sync / on login) |

**Validation tests you will witness:**

- Valid AD user → login success  
- Wrong password → login failure (audited)  
- Disabled AD account → login denied  
- User added to AD group → mapped role available after sync  

**Exit criteria:** 10+ representative users authenticate via AD through Keycloak.

---

### Phase 4 — MFA configuration (Week 3)

**Objective:** Add second factor using authenticator applications (Google/Microsoft Authenticator, etc.).

| Step | Activity | Detail |
|------|----------|--------|
| 4.1 | Define MFA policy | All users or selected groups (agreed in discovery) |
| 4.2 | Configure OTP (TOTP) | Keycloak required action / conditional MFA |
| 4.3 | Pilot enrollment | IT team enrolls first; test QR setup flow |
| 4.4 | Rollout communication template | SecureLink provides admin guide for end users |
| 4.5 | Test MFA success and failure paths | Valid OTP, invalid OTP, lost device procedure |
| 4.6 | Document MFA administration | Reset OTP, exempt break-glass accounts (if any) |

**Exit criteria:** MFA enforced per agreed policy; admin reset procedure documented.

---

### Phase 5 — Application SSO integration (Weeks 3–4)

**Objective:** Connect up to eight applications to Keycloak.

#### Standard integration procedure (each application)

| Step | Activity |
|------|----------|
| 5.x.1 | Confirm protocol (OIDC or SAML) with vendor documentation |
| 5.x.2 | Register client in Keycloak (client ID, redirect URLs, scopes) |
| 5.x.3 | Exchange metadata (SAML XML or OIDC discovery URL) |
| 5.x.4 | Map claims / attributes (email, name, groups → app roles) |
| 5.x.5 | Configure logout URL (single logout where supported) |
| 5.x.6 | Test in staging or agreed test window |
| 5.x.7 | UAT with application owner sign-off |
| 5.x.8 | Production cutover during change window |

**Per-application time allowance:** 1–2 business days (simple OIDC web app) to 3–5 days (complex SAML + attribute mapping) — included in bundle for standard integrations.

**Exit criteria:** Eight applications signed off by owners; SSO and logout verified.

---

### Phase 6 — Testing, handover & sign-off (Weeks 5–6)

| Step | Activity |
|------|----------|
| 6.1 | Integrated test plan execution |
| 6.2 | AD + MFA + SSO regression |
| 6.3 | Backup and restore drill (database + realm export) |
| 6.4 | Administrator training (half-day remote or on-site) |
| 6.5 | Deliver documentation pack |
| 6.6 | Final implementation report |
| 6.7 | Customer sign-off |

**Exit criteria:** Signed acceptance; project closed; optional support contract starts if purchased.

---

## 7. Application SSO — integration approach

### 7.1 OpenID Connect (OIDC) — preferred for modern apps

**When used:** Internal portals, modern SaaS, mobile-friendly apps.

**How it works (simplified):**

1. App redirects browser to Keycloak.  
2. User authenticates (AD + MFA).  
3. Keycloak returns authorization code to app.  
4. App exchanges code for **ID token** (identity) and **access token** (API).  

**Application owner provides:**

- Redirect URI(s) (e.g. `https://portal.company.com/callback`)  
- Logout URL  
- Test account  

**We configure:** Client ID, scopes (`openid profile email`), role mappers.

### 7.2 SAML 2.0 — common for enterprise products

**When used:** ServiceDesk Plus, many ERP/banking tools, legacy enterprise SSO.

**How it works (simplified):**

1. App redirects to Keycloak SAML endpoint.  
2. User authenticates.  
3. Keycloak posts signed **SAML assertion** to application.  

**Application owner provides:**

- SAML metadata XML or ACS URL + entity ID  
- Attribute requirements (NameID format, role attribute)  

**We configure:** Keycloak SAML client, signing certificates, attribute mappers.

### 7.3 SSO readiness checklist (per application)

| Question | Answer |
|----------|--------|
| Application name & version? | |
| Protocol supported (OIDC / SAML / OAuth)? | |
| Staging environment available? | |
| Vendor SSO documentation link? | |
| Application administrator contact? | |
| Required user attributes / roles? | |
| Planned go-live date? | |

*SecureLink will provide this checklist as an Excel/Word appendix at kickoff.*

---

## 8. Technical prerequisites — your responsibilities

Implementation cannot start until the following are assigned and scheduled.

| # | Prerequisite | Owner | Required by |
|---|--------------|-------|-------------|
| 1 | Keycloak VM (4 vCPU, 16 GB, 64 GB) | Customer IT | Week 1 |
| 2 | PostgreSQL VM (4 vCPU, 8 GB, 64 GB) | Customer IT | Week 1 |
| 3 | OS admin access (SSH/RDP) via VPN | Customer IT | Week 1 |
| 4 | FQDN e.g. `auth.company.com` | Customer IT | Week 1 |
| 5 | Public or internal DNS record | Customer IT | Week 2 |
| 6 | TLS certificate + chain | Customer IT | Week 2 |
| 7 | AD service account (read users/groups) | Customer AD team | Week 1 |
| 8 | LDAPS allowed firewall rule KC → DC | Customer network | Week 2 |
| 9 | HTTPS allowed users → Keycloak | Customer network | Week 2 |
| 10 | Application owner contacts (×8) | Customer PM | Week 1 |
| 11 | Change windows for cutovers | Customer PM | Week 3+ |
| 12 | Project sponsor for approvals | Customer executive | Week 1 |

---

## 9. Security, operations & compliance

| Area | Our approach |
|------|--------------|
| **Encryption in transit** | HTTPS for users; LDAPS for AD |
| **Admin access** | Role-based; no shared admin passwords |
| **Secrets** | Bind passwords and DB credentials in secure vault / env |
| **Audit** | Keycloak login events retained per platform policy |
| **Backup** | Daily PostgreSQL backup + realm JSON export procedure |
| **Restore** | Documented restore drill before sign-off |
| **Session management** | Idle and max session timeouts configured |
| **KSA hosting** | All IAM components on customer-approved infrastructure |

SecureLink’s broader cybersecurity and GRC practice can extend to compliance advisory (NCA, SAMA, PDPL) as a **separate engagement** if required.

---

## 10. Deliverables

| # | Deliverable | Format |
|---|-------------|--------|
| 1 | Technical prerequisites checklist | PDF / Excel |
| 2 | Solution design document | PDF |
| 3 | Deployment architecture diagram | PDF / Visio |
| 4 | Keycloak production deployment | Live environment |
| 5 | AD/LDAPS federation configuration | Config + documentation |
| 6 | MFA policy configuration | Config + user guide |
| 7 | SSO integration for 8 approved applications | Live + per-app notes |
| 8 | Test summary report | PDF |
| 9 | Administrator guide | PDF |
| 10 | Backup and restore procedure | PDF |
| 11 | Final implementation report | PDF |
| 12 | Knowledge transfer session | Remote session (recorded if agreed) |

**Reference technical guide (OIDC + AD flows):** available from implementation team for reviewer education prior to kickoff.

---

## 11. Project timeline

**Indicative duration: 4–6 weeks** from kickoff, subject to prerequisite readiness and application owner availability.

| Week | Focus | Key milestones |
|------|-------|----------------|
| **1** | Discovery & design | Kickoff, app validation, design approved |
| **2** | Platform + AD | Keycloak live, AD authentication working |
| **3** | MFA + apps 1–3 | MFA enforced; first integrations in UAT |
| **4** | Apps 4–8 | Remaining SSO integrations |
| **5** | Testing & UAT | Issue resolution, regression |
| **6** | Handover | Training, documentation, sign-off |

**Critical dependency:** If application owners or firewall approvals delay beyond 5 business days, timeline extends accordingly (see Section 14).

---

## 12. Commercial proposal

### 12.1 Professional services — fixed price

| Line item | Description | Amount (SAR) |
|-----------|-------------|--------------|
| **A** | Phase 1 — Discovery & solution design | 12,000 |
| **B** | Phase 2 — Keycloak platform deployment (incl. PostgreSQL integration, TLS, hardening) | 28,000 |
| **C** | Phase 3 — Active Directory / LDAPS integration (up to 300 users) | 18,000 |
| **D** | Phase 4 — MFA (TOTP authenticator) configuration & pilot | 10,000 |
| **E** | Phase 5 — Application SSO integration (**8 applications**, standard OIDC/SAML) | 56,000 |
| **F** | Phase 6 — Testing, documentation, training & sign-off | 14,000 |
| | **Total professional services** | **SAR 138,000** |

*All amounts exclude VAT. VAT will be applied per applicable Saudi regulations.*

### 12.2 What the price includes

- Remote implementation by SecureLink and specialist Keycloak engineer  
- Configuration labour for items in Section 5.1  
- Project management and technical leadership through sign-off  
- Administrator documentation and one knowledge-transfer session  

### 12.3 What the price excludes

- Customer hardware, virtualisation, OS, and database licensing  
- SSL certificate procurement (customer-provided)  
- SMS/email MFA gateway fees  
- Travel/on-site days in KSA (quoted separately if required)  
- Applications beyond eight (see optional services)  
- Post go-live support beyond warranty period  

### 12.4 Payment milestones

| Milestone | % | Amount (SAR) | Trigger |
|-----------|---|--------------|---------|
| Project kickoff & design approval | 30% | 41,400 | Signed order + kickoff complete |
| AD integration & MFA live in UAT | 30% | 41,400 | Phase 3–4 exit criteria met |
| Application integrations complete (UAT) | 30% | 41,400 | Phase 5 exit criteria met |
| Final sign-off | 10% | 13,800 | Phase 6 complete |
| **Total** | **100%** | **138,000** | |

### 12.5 Warranty

**30 calendar days** from sign-off: defect correction for delivered configuration (not new applications or scope changes).

---

## 13. Optional services

| Option | Description | Indicative price (SAR) |
|--------|-------------|----------------------|
| **9th application SSO** | Additional standard-protocol app | 7,500 per app |
| **High availability (2nd Keycloak node)** | Active/passive or shared DB pattern | 35,000 |
| **Annual IAM support** | 8×5, next-business-day, 80 hours/year | 42,000 / year |
| **On-site kickoff or training (KSA)** | Per day + expenses | 4,500 / day |
| **SMS OTP MFA** | If gateway available | Quote after vendor selection |

---

## 14. Assumptions, exclusions & change control

### 14.1 Assumptions

- All eight applications support SAML 2.0, OIDC, or OAuth 2.0 without code modification  
- Customer provides infrastructure and access within **10 business days** of kickoff  
- Active Directory is healthy, replicated, and reachable via LDAPS from Keycloak subnet  
- Application owners participate in UAT within agreed windows  
- Staging or test instances exist where production cutover risk requires it  

### 14.2 Change requests

Any work outside Section 5.1 will be documented as a **change request** with impact on timeline and cost, approved in writing before execution.

### 14.3 Delay policy

Customer-caused delays (access, firewall, app owner unavailability) may shift the schedule without penalty to SecureLink. Extended delays beyond 15 business days may trigger re-planning or standby charges if resources are reserved.

---

## 15. Approval

By signing below, [Customer name] approves the **scope**, **approach**, **timeline**, and **commercial terms** in this proposal, enabling SecureLink to proceed to contract and kickoff scheduling.

| | |
|---|---|
| **Customer organization** | _________________________________ |
| **Authorized signatory** | _________________________________ |
| **Title** | _________________________________ |
| **Signature** | _________________________________ |
| **Date** | _________________________________ |

| | |
|---|---|
| **SecureLink Arabia** | _________________________________ |
| **Authorized signatory** | _________________________________ |
| **Title** | _________________________________ |
| **Signature** | _________________________________ |
| **Date** | _________________________________ |

---

### Contact

**SecureLink Arabia**  
Website: https://www.securelink.sa/  
Email: support@securelink.sa  

**Technical delivery lead:** Talha Bilal  
Portfolio: https://talha-bilal.github.io/portfolio/  

---

*This proposal is confidential and intended solely for the named customer. Pricing and scope valid 90 days from document date.*
