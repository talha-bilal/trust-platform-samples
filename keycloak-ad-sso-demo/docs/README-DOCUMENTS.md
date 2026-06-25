# Documents guide — two audiences

## 1. For SecureLink (from you) — **send this to win the work**

| File | Purpose |
|------|---------|
| **[Talha-Bilal-SecureLink-Delivery-Offer.pdf](./Talha-Bilal-SecureLink-Delivery-Offer.pdf)** | Your **implementation plan + your cost** to SecureLink |
| [subcontractor/talha-delivery-offer.html](./subcontractor/talha-delivery-offer.html) | Edit source (pricing, days, contact) |

**Your offer in this PDF:** **SAR 76,000** fixed (remote delivery, Phases 1–6).  
SecureLink adds their margin when pricing the end customer.

Regenerate:

```powershell
python scripts/generate_subcontractor_pdf.py
```

---

## 2. For SecureLink’s end customer (optional — they may already have scope doc)

| File | Purpose |
|------|---------|
| [SecureLink-Customer-Implementation-Proposal.pdf](./SecureLink-Customer-Implementation-Proposal.pdf) | Customer-facing proposal SecureLink *may* use (SAR 138,000 template) |
| [proposal/securelink-proposal.html](./proposal/securelink-proposal.html) | Edit if SecureLink asks you to refresh their customer pack |

```powershell
python scripts/generate_proposal_pdf.py
```

---

## 3. Technical appendix (supporting either call)

| File | Purpose |
|------|---------|
| [IAM-OIDC-AD-Flow.pdf](./IAM-OIDC-AD-Flow.pdf) | OIDC + AD technical deep-dive |
| [../DEMO-WALKTHROUGH.md](../DEMO-WALKTHROUGH.md) | Live demo script |

---

## What to email SecureLink

> Subject: Keycloak IAM delivery — implementation plan & commercial offer (250–300 users)  
>  
> Attach: **Talha-Bilal-SecureLink-Delivery-Offer.pdf**  
>  
> Short note: you align to their customer approval scope; this is **your** plan and **your** subcontractor price — not a replacement for their customer document.
