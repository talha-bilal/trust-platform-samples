# SecureLink customer proposal (template)

**For SecureLink internal use before sending to end customer.**

## Files

| File | Purpose |
|------|---------|
| [SecureLink-Customer-Implementation-Proposal.md](./SecureLink-Customer-Implementation-Proposal.md) | Full proposal — edit customer name & pricing |
| [SecureLink-Customer-Implementation-Proposal.pdf](./SecureLink-Customer-Implementation-Proposal.pdf) | PDF for distribution |

## Before sending to the client

1. Replace `[Customer organization name]` and `[Customer name]` throughout  
2. Confirm **SAR 138,000** with SecureLink commercial team (adjust if needed)  
3. Confirm final **8 applications** from discovery list  
4. Add SecureLink signatory block  
5. Regenerate PDF:

```powershell
python scripts/generate_flow_pdf.py docs/SecureLink-Customer-Implementation-Proposal.md
```

## Related

- [IAM-OIDC-AD-Flow.pdf](./IAM-OIDC-AD-Flow.pdf) — technical education appendix  
- [DEMO-WALKTHROUGH.md](../DEMO-WALKTHROUGH.md) — live demo script  
