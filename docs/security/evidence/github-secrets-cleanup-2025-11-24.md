# GitHub Secrets Cleanup — 2025-11-24

- Operator: GitHub CLI (workspace token)
- Repository: `neacisu/GeniusERP_Suite`
- Command: `./scripts/security/github-secrets-cleanup.sh --delete --evidence docs/security/evidence/github-secrets-cleanup-2025-11-24.json`
- Evidence JSON: `docs/security/evidence/github-secrets-cleanup-2025-11-24.json`
- CLI log: stored in local run history (`gh secret delete` output inline)

| Secret | Result | Notes |
|--------|--------|-------|
| BAO_TOKEN | Absent (no action) | OIDC handles auth |
| GH_PAT_TOKEN | Deleted | Confirmed removal via `gh secret delete` |
| NPM_TOKEN | Absent (no action) | Already migrated to OpenBao |
| DB_PASSWORD | Absent (no action) | Dynamic DB engine |
| JWT_SECRET | Absent (no action) | Stored per service in OpenBao |
| DOCKER_USERNAME / DOCKER_PASSWORD | Absent (no action) | Deployments use OpenBao vault-injected creds |

See JSON snapshot for authoritative state at execution time.
