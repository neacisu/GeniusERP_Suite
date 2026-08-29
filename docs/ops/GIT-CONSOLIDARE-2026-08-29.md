# Git consolidare — 2026-08-29

**Host:** hz2.65  
**Repo:** `neacisu/GeniusERP_Suite`  
**Secrete:** nicio valoare în acest fișier.

## Faza A — audit + plasă

- Snapshot: 5 heads pe origin (`master`, `dev`, `staging`, `feat/F0.5_Securitate_OpenBao_ENV`, `feat/docker-containers`); default `master`.
- Local `chore/stack-upgrade-2026-08-28` = 3 ahead / 0 behind (`dc2bb00`, `89de1e1`, `ba3d200`) înainte de B1; `docs/ops/RUNBOOK-hz2.md` dirty.
- Bundle: `/opt/backups/git/GeniusERP_Suite-ALL-2026-08-28.bundle` — `git bundle verify` OK (istoric complet, 9 refs).
- Restic: adăugat `EXTRA_PATHS=/opt/backups` în `/opt/secrets/restic-nou.env` (chei existente: `BACKUP_PATH`, `BACKUP_TAG`, `KEEP_DAILY`, `LOG`).
- Docker snapshot A: 38 containere (ID+Names+Image salvate).

## Faza B — linia de bază pe master

- B1: commit `253c246` `docs: runbook restic scope + off-host password note` (scan secrete OK).
- B2: push `chore/stack-upgrade-2026-08-28`.
- B3: PR [#25](https://github.com/neacisu/GeniusERP_Suite/pull/25) merged (FF).
- B4: `origin/master` → `253c246` (include `ba3d200` + runbook).
- B5: CI Validation pe PR = verde (changeset + validate). `Release Packages` pe push master = **roșu** (vezi issue mai jos). Nu a blocat C–D.

## Faza C — tag-uri de arhivă

| Branch | Tag | Tip SHA | Ahead/behind vs master la arhivare |
|---|---|---|---|
| `dev` | `archive/dev-2026-08-29` | `d4bcebf` | 33 ahead / 5 behind |
| `staging` | `archive/staging-2026-08-29` | `2bcb945` | 0 ahead / 1 behind (ancestor) |
| `feat/docker-containers` | `archive/feat-docker-containers-2026-08-29` | `7a01eaf` | 25 ahead / 5 behind |
| `feat/F0.5_Securitate_OpenBao_ENV` | `archive/feat-F0.5_Securitate_OpenBao_ENV-2026-08-29` | `18b2ea8` | 69 ahead / 5 behind |
| `chore/stack-upgrade-2026-08-28` | `archive/chore-stack-upgrade-2026-08-28-2026-08-29` | `253c246` | 0 behind (în master) |

Confirmare: `git ls-remote --tags origin | grep archive/` = 5 tag-uri peeled.

## Faza D — port dirijat F0.5

Branch `integrare/F0.5-hz2` → PR [#26](https://github.com/neacisu/GeniusERP_Suite/pull/26) merge commit `68b29b7`.

### Matrice (rezumat)

- **Câștigă master:** compose/Dockerfile CP+produs existente, start/stop-suite, proxy/traefik-în-suită, CI existent.
- **Portat:** `geniuserp.app` (6050/6051, Traefik `geniuserp.app|www`, 4 rețele hz2, fără env_file, fără Process Supervisor); inject + policies; template-uri KV; docs F0.5 cu notă platformă; pgcrypto SQL (nerulat); OIDC scripts cu `BAO_ADDR=http://openbao:8200`.
- **Arhivat:** node-openbao, agent-config, start-app.sh, `ci-f05-validation.yml`, evidence JSON, database/roles, compose.yml root F0.5.

### Acoperire element → commit / motiv

| Element | Rezultat |
|---|---|
| geniuserp.app stub hz2 | portat `4340b3b` |
| KV templates per app | portat `4340b3b` |
| inject.ts/sh + policies | portat `4340b3b` + retarget `d740a26`/`7f86d1b` |
| F0.5 docs + pgcrypto SQL | portat `4340b3b` + note `d740a26` |
| pnpm-lock geniuserp | `189ed35` |
| Process Supervisor / node-openbao | arhivat (`archive/feat-F0.5_…`) |
| ci-f05-validation.yml | arhivat (ar porni proxy/OpenBao în CI) |
| evidence JSON | arhivat (nu copiat) |
| gateway | în afara task-ului |
| compose up geniuserp | în afara task-ului |

Validare locală: lint OK, jest 250 passed, `nx build @genius-suite/geniuserp.app` OK, `docker build` OK (fără compose up). CI PR #26 validate = success.

## Faza E — curățare

Înainte de delete: fiecare tip = ancestor al master **sau** match pe tag `archive/*` (dovedit în log).

Șterse pe origin: `dev`, `staging`, `feat/docker-containers`, `feat/F0.5_Securitate_OpenBao_ENV`, `chore/stack-upgrade-2026-08-28`, `integrare/F0.5-hz2`.

- `nx.json` `defaultBase: "master"`.
- `.gitignore`: `.env.local`, `.env.production`, `.env.*.local`, `.pnpm-store/`, `*.pem`, `id_rsa*`, `*.bundle`, plus `.env.*` / `!.env.*.example` (corecție: `*.env` nu acoperea `cp/.env.geniussuite`).
- Untracked: `configs-backup-20251113-115126.zip`, `cp/.env.geniussuite` → păstrat ca `cp/.env.geniussuite.example`.
- Commits: `d6878bb`, `3189da2`.
- Workflow-uri `auto-pr-dev-to-staging` / `auto-pr-staging-to-master`: rămân în repo, trigger pe `dev` = moarte (notat, nesterse).

## Faza F — token-uri

Mutate în `/opt/platform.env` (fără valori aici): `GITHUB_TOKEN_NX`, `GITHUB_TOKEN_FDI_ERP`, `GITHUB_TOKEN_FLOWXIFY`, `GITHUB_RECOVERY_01..16`.  
Rămas în `/opt/stacks/.env`: doar `GITHUB_TOKEN_STOREFRONT` (401 — de revocat din UI GitHub).  
`gh-hz2` citește `GITHUB_TOKEN_NX` din `platform.env`. Probe: `gh-hz2 api user` → `neacisu`; `git ls-remote` → 1 head.

**Acțiune operator (UI):** revocă STOREFRONT; evaluează fine-grained PAT (`contents:write`, `pull_requests:write`) pe acest repo.

## Faza G — validare

- Local: doar `master`. Remote heads: doar `origin/master`. Tag-uri `archive/*`: 5.
- `git fsck --full`: fără erori de integritate; doar dangling commits din lint-staged stash (normal).
- Docker: aceleași 38 ID+Names+Image ca la A (doar textul „Up N minutes” a avansat).
- CI: PR Validation verde (#25, #26). Release Packages pe master **roșu** — cauza: changesets rezolvă greșit `neacisu/GeniusSuite` (nu `GeniusERP_Suite`). Issue creat pe repo.

## Rămas deliberat în afara acestui task

1. Implementarea `gateway` (de la zero).
2. Pornirea containerului `geniuserp-app`.
3. Rularea pgcrypto pe bazele live.
4. Activarea OIDC GHA pe platformă (scripturi portate; fără workflow care pornește OpenBao/Traefik în CI).
5. Fix Release Packages / changesets repo name (issue deschis).
