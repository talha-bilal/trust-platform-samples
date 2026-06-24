# SecureLink customer proposal

**Deliverable:** professional PDF with diagrams, generated from HTML (not markdown).

## Customer files

| File | Use |
|------|-----|
| [proposal/securelink-proposal.html](./proposal/securelink-proposal.html) | **Source** — edit content, branding, pricing |
| [SecureLink-Customer-Implementation-Proposal.pdf](./SecureLink-Customer-Implementation-Proposal.pdf) | **Send to client** (after replacing `[Customer Organization]`) |

## Regenerate PDF (high quality)

```powershell
pip install -r requirements-proposal.txt
python -m playwright install chromium
python scripts/generate_proposal_pdf.py
```

Uses headless Chrome — proper page layout, SVG diagrams, tables, and cover page.

## Before external distribution

1. Replace `[Customer Organization]` on cover  
2. Confirm **SAR 138,000** with SecureLink commercial team  
3. Add SecureLink logo on cover (optional — edit HTML `.cover-brand` section)  
4. Regenerate PDF and review all 13 pages in Adobe / browser  

## Appendix

| File | Audience |
|------|----------|
| [IAM-OIDC-AD-Flow.pdf](./IAM-OIDC-AD-Flow.pdf) | Technical deep-dive (OIDC + AD) |
| [../DEMO-WALKTHROUGH.md](../DEMO-WALKTHROUGH.md) | Live demo script |

**Do not** use `generate_flow_pdf.py` for the customer proposal — that path is for the technical appendix only.
