# Reference frontend (local only — do not commit)

Drop a **copy** of frontend files here so portfolio docs can be aligned with the real product flow.

## What to copy

Enough to infer architecture (routes, modules, API clients, feature areas):

- `src/` (or `app/`) — pages, routes, layouts, services
- `package.json` — dependencies only (no private registry tokens)
- Optional: env **example** files with keys renamed (no real URLs/secrets)

## What to omit

- `.env`, credentials, API keys, internal hostnames
- Company/product branding assets if identifiable
- Customer names, tenant IDs, production config
- Anything under NDA you are not allowed to export

## After you drop files

Tell the agent: **“reference frontend is ready”**. It will:

1. Read structure and flows from this folder
2. Update `signing-platform-architecture/`, `docs/diagrams/`, `docs/use-cases/`, and project READMEs
3. Use **generic names** only (e.g. “Admin Portal”, “Tenant Console”, “Signing API”)
4. **Never** copy proprietary strings into GitHub
5. Delete or leave this folder local — it stays gitignored
