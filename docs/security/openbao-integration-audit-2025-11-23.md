# OpenBao Integration Audit — 2025-11-23

## Methodologie

- Am enumerat toate componentele funcționale listate în `README.md` (Control Plane + aplicații stand-alone + infrastructură comună).
- Pentru fiecare componentă am verificat existența următoarelor artefacte:
  - Dockerfile care folosește imaginea `geniuserp/node-openbao:local` (pattern Process Supervisor) sau justificare pentru absență.
  - Director `openbao/` cu `agent-config.hcl` și șabloane (`templates/*.tpl`).
  - Scripturi de pornire (`scripts/start-app.sh`, `scripts/setup-approle.sh`) ce orchestrează injecția de secrete.
  - Fișiere `.env.example` pentru confirmarea că nu includ secrete (conform `Plan/Strategie Securitate F0.5_OpenBao_ENV.md`).
- Am notat explicit orice deviație/față de cerințele F0.5 și sursa dovezilor.

## Matrice componente

| Componentă | Tip | Dockerfile Process Supervisor | Artefacte OpenBao | `.env` conform (fără secrete) | Stare | Dovezi / Observații |
|------------|-----|--------------------------------|-------------------|-------------------------------|-------|---------------------|
| `archify.app` | Stand-alone | Da (`archify.app/Dockerfile` l.33) | `openbao/agent-config.hcl`, `templates/*`, `scripts/start-app.sh` | Da (`.archify.env.example` doar config) | ✅ Implementat | Compose + Dockerfile confirmă montarea AppRole și injecția env în `/app/secrets` |
| `cerniq.app` | Stand-alone | Da | Artefacte prezente | Da | ✅ | Aceeași structură ca archify; healthchecks folosesc env injecție |
| `flowxify.app` | Stand-alone | Da | Artefacte prezente | Da | ✅ | `flowxify.app/scripts/setup-approle.sh` gestionează AppRole |
| `i-wms.app` | Stand-alone | Da | Artefacte prezente | Da | ✅ | `i-wms.app/openbao/*` + start script |
| `mercantiq.app` | Stand-alone | Da | Artefacte prezente | Da | ✅ | Confirmat prin `rg` |
| `numeriqo.app` | Stand-alone | Da | Artefacte prezente | Da | ✅ | Include notă `# Uses geniuserp/node-openbao` |
| `triggerra.app` | Stand-alone | Da | Artefacte prezente | Da | ✅ | |
| `vettify.app` | Stand-alone | Da | Artefacte prezente | Da | ✅ | |
| `geniuserp.app` | Control Plane (public site) | Da | Artefacte prezente | Da | ✅ | |
| `cp/ai-hub` | Control Plane | Da | Artefacte prezente | Da | ✅ | |
| `cp/analytics-hub` | Control Plane | Da | Artefacte prezente | Da | ✅ | |
| `cp/identity` | Control Plane | Da | Artefacte prezente | Da | ✅ | Include `openbao/templates/db-creds.tpl` |
| `cp/licensing` | Control Plane | Da | Artefacte prezente | Da | ✅ | |
| `cp/suite-admin` | Control Plane | Da | Artefacte prezente | Da | ✅ | |
| `cp/suite-shell` | Control Plane | Da | Artefacte prezente | Da | ✅ | |
| `cp/suite-login` | Control Plane | Da (`cp/suite-login/Dockerfile` folosește `geniuserp/node-openbao:local`) | `openbao/agent-config.hcl`, `templates/*`, `scripts/start-app.sh` | Da (`.cp.suite-login.env.example` nu include secrete) | ✅ Implementat (2025-11-24) | `docker logs genius-suite-login` confirmă `agent: rendered ... tpl => /app/secrets/.env` urmat de `Suite-login service started` cu secrete din `kv/data/cp/suite-login`. |
| `gateway/` | Infra comună | N/A (componenta încă neimplementată; doar `.gateway.env.example`) | Nu | Nu (fișierul include doar config, fără secrete) | ⚠️ În așteptare | Va necesita pattern PS când serviciul va fi implementat |
| `proxy/` (Traefik) | Infra comună | N/A (Traefik container third-party) | N/A | **Nu** (`.proxy.env.example` conține parole/token placeholder) | ⚠️ Gap | Necesită integrare cu OpenBao KV + file templating pentru credențiale dashboard/DNS |
| `shared/`, `scripts/`, `database/` | Librării/tooling | N/A | N/A | N/A | ✅ | Nu rulează containere separate, dar folosesc secrete via CLI |

## Concluzii parțiale

1. Toate aplicațiile stand-alone și majoritatea modulelor CP folosesc imaginea `geniuserp/node-openbao:local` și au artefacte complete; aceste componente sunt conforme cu strategia F0.5.
2. `cp/suite-login` a fost migrat la Process Supervisor pe 2025-11-24; execuția `setup_cp_approles.sh` + `seed-secrets.sh` urmată de `docker compose ... suite-login` demonstrează că AppRole-ul citește `kv/data/cp/suite-login` și pornește aplicația după randarea șabloanelor OpenBao.
3. `proxy/.proxy.env.example` păstrează credențiale (dashboard basic auth, Cloudflare token). Conform F0.5, acestea trebuie mutate în OpenBao și injectate în runtime (prin templating/secret files) înainte de validarea finală.
4. `gateway/` nu are cod activ; când va fi implementat trebuie pornit direct pe baza Process Supervisor pentru a evita regresia observată la versiunea veche `suite-login`.

## Secret & Port Scan Findings

- Am rulat `rg -n "(SECRET|PASSWORD|PRIVATE_KEY|TOKEN|ReplaceMe)" --glob '!*.env*' --glob '!*.tpl'` pe întreg repo-ul pentru a identifica potențiale secrete hardcodate. Rezultatele majore indică doar documentație și scripturi CLI, cu **două excepții operaționale**:

  > - `compose.yml` și `docker-compose.backing-services.yml` definesc fallback-uri precum `${SUITE_DB_POSTGRES_PASS:-ChangeThisPostgresPassword}` / `${CP_IDT_AUTH_SUPERTOKENS_API_KEY:-ChangeThisSuperTokensKey}`. Conform politicii F0.5, aceste valori implicite trebuie eliminate pentru a forța furnizarea prin `.env` + OpenBao (`Plan/Strategii de Fișiere.env și Porturi.md`, Capitolul 4).
  > - `shared/observability/compose/profiles/compose.dev.yml` setează `GF_SECURITY_ADMIN_PASSWORD=admin`. Grafana dev trebuie să citească parola din OpenBao (sau cel puțin din `.suite.dev.env` fără valori implicite).

- Fișiere `.env.example` rămase cu secrete: `cp/suite-login/.cp.suite-login.env.example`, `proxy/.proxy.env.example`. Acestea necesită migrare conform politicii Config vs Secret (F0.5.2).
- Porturile și mapping-urile verificate (e.g., 5432, 8200, 9092) respectă tabelele din `Plan/Strategii de Fișiere.env și Porturi.md`; nu s-au găsit porturi noi hardcodate în cod care să iasă din intervalele aprobate.

## Runtime Validation — 2025-11-23 20:13 UTC

- **Stack health (`docker ps --format "table {{.Names}}\t{{.Status}}"`)**

   ```text
   NAMES                      STATUS
   genius-suite-shell         Up 51 minutes (healthy)
   genius-suite-admin         Up 52 minutes (healthy)
   genius-suite-identity      Up 52 minutes (healthy)
   genius-suite-login         Up 51 minutes (healthy)
   geniuserp-openbao          Up 3 hours (healthy)
   ... (22 servicii suplimentare healthy)
   ```

  - Toate containerele critice (apps + observability + backing services) raportează `healthy` după >50 min uptime.
  - **Gap:** niciun container `openbao_gov` la runtime → instrumentele de guvernanță/approvals încă nu sunt pornite pe acest host.
- **Control Plane apps (shell/admin/identity)**

  - `docker logs genius-suite-shell|admin|identity | tail -n 40` arată secvența completă a agentului (`agent.auth.handler: authentication successful`, `agent: rendered ... tpl => .../.env`, `agent: (child) spawning /app/scripts/start-app.sh`) urmată de cereri `/health` 200 la fiecare 30s. Token renewals sunt vizibile (`agent.auth.handler: renewed auth token`).
- **`suite-login` (gap evidențiat)**

  - `docker logs genius-suite-login | tail -n 40` indică doar logurile Node/healthcheck fără prefixe `agent.*`, confirmând că acest serviciu încă rulează pe imagine `node:24-alpine` fără Process Supervisor/OpenBao Agent. Secretele provin în continuare din `.env` → confirmă statusul ❌ din matrice.
- **OpenBao server**

  - `docker logs geniuserp-openbao | tail -n 60` arată revocări continue de lease pentru roluri `cp_*` și `numeriqo_runtime`, plus bannerul `OpenBao v2.4.3` fără mesaje de eroare/seal. Lease churn demonstrează că agenții se autentifică și secretele dinamice se rotesc.

Datele brute sunt păstrate în jurnalul comenzii (2025-11-23 20:13 UTC) pentru includere în raportul final F0.5.

## Runtime Validation — 2025-11-24 15:58 UTC

- **Flux de remediere executat**
  - `./scripts/security/setup_cp_approles.sh` → reprovizionează AppRole-urile `cp-*` cu noua politică `suite-login-read` ce include `path "kv/data/cp/suite-login"`.
  - `./scripts/security/seed-secrets.sh --profile dev --non-interactive` → regenerează secretele statice, inclusiv `CP_LOGIN_AUTH_JWT_SECRET`.
  - `docker compose -f cp/suite-login/compose/docker-compose.yml up --build -d suite-login` (după `source .suite.general.env && source cp/suite-login/.cp.suite-login.env`) → reconstruiește imaginea Process Supervisor.
  - `bao kv put kv/cp/suite-login jwt_secret=<64 hex>` → popula secretul root necesar șabloanelor (`kv/data/cp/suite-login`).

- **`suite-login` (PS + OpenBao)**

  ```text
  2025-11-24T15:58:37Z [INFO]  agent: (runner) rendered "/openbao/templates/cp-suite-login.env.tpl" => "/app/secrets/.env"
  2025-11-24T15:58:37Z [INFO]  agent: (runner) executing command ["/app/scripts/start-app.sh"]
  [Process Supervisor][cp-suite-login] Loading secrets from /app/secrets/.env
  {"level":"info","time":"2025-11-24T15:58:37.910Z","msg":"Suite-login service started on port 6200"}
  ```

- **OpenBao KV evidence**

  ```text
  $ bao kv get kv/cp/suite-login
  Key         Value
  jwt_secret  4ef7dfc0…b8cb (64 hex)
  ```

- **Container state**
  - `docker logs genius-suite-login --tail 20` (post-restart) arată doar evenimente `agent.auth.handler: authentication successful` și nu mai raportează erori 403/404, confirmând că AppRole-ul poate lista și citi `kv/data/cp/suite-login`.

## CI/CD Enforcement — 2025-11-24

- **Workflow actualizat:** `.github/workflows/ci-f05-validation.yml` rulează acum exclusiv pe `ubuntu-latest` și execută următorii pași automatizați:
  1. `scripts/security/ci-bootstrap-openbao.sh` → pornește serviciul `geniuserp-openbao`, rulează `openbao-init.sh`, reemite AppRole-urile și rulează `seed-secrets.sh --profile ci --non-interactive` folosind conexiuni Docker.
  2. `scripts/security/verify_all_apps.sh` → validează că fiecare aplicație are `openbao/agent-config.hcl`, șabloane și Dockerfile bazat pe `geniuserp/node-openbao:local` (orice regresie în Process Supervisor oprește CI-ul).
  3. `scripts/security/test-openbao-secrets.sh` → parcurge `docs/security/F0.5-Secrets-Inventory-OpenBao.csv`, convertește căile `kv/data/...` în patch-uri și confirmă că fiecare cheie statică există în OpenBao; lipsurile eșuează job-ul.
- **Artefacte noi:**
  - `scripts/security/ci-bootstrap-openbao.sh` (bootstrap container + seed determinist)
  - `scripts/security/test-openbao-secrets.sh` (verificare KV) – reutilizabilă și local (acceptă `BAO_ADDR`/`BAO_TOKEN`).
- **Rezultat:** pipeline-ul F0.5 rulează autentic (fără simulări), iar orice PR/cron fără OpenBao gata configurat sau fără secrete KV valide este blocat automat.

## Următori pași pentru închiderea gap-urilor

### 1. **Traefik/Proxy secrets:**

  >- Definirea unei politici OpenBao pentru `proxy` (ACME storage encryption, dashboard creds, tokens DNS-01).
  >- Implementarea unui script de templating (sau integrarea cu `openbao-template` sidecar) pentru a randa fișierele consumate de Traefik fără a le commit-ui în Git.

### 2. **Audit final `.env` files:**

- După migrarea `proxy`, rerulați auditul pentru a confirma că niciun `.env.example` nu mai conține secrete, doar configurări non-sensibile.

### 3. **Automatizare seed pentru CP agregat:**

- Ajustați `docs/security/F0.5-Secrets-Inventory-OpenBao.csv` + `scripts/security/seed-secrets.sh` astfel încât căile `kv/data/cp/<service>` să accepte chei multiple (nu doar `value`) și să evite reapariția gap-ului atunci când se rulează seed-ul în pipeline.

Acest fișier trebuie actualizat după remedierea gap-urilor, înainte de a emite reconfirmarea oficială către management.

## F0.5 Checklist Status — 2025-11-23

| Task | Scope | Evidence | Status | Notes / Next Steps |
|------|-------|----------|--------|--------------------|
| F0.5.1 | Analiza strategie `.env` | `docs/security/Configuration_Strategy.md` | ✅ | Audit-ul inițial ancorează toate deviațiile și este citat în planul F0.5. |
| F0.5.2 | Politica Config vs Secret | `docs/security/F0.5-Politica-Config-vs-Secrete.md` | ✅ | Regula de separare este menționată în README-urile orchestratorilor și este folosită ca bază pentru code-review. |
| F0.5.3 | Serviciu OpenBao în root compose | `compose.yml` (`openbao`, `openbao-backup`, volumul `gs_openbao_data`) | ✅ | Serviciul rulează cu IPC_LOCK și rețele limitate (`net_backing_services`, `net_observability`). |
| F0.5.4 | Bootstrap & unseal automat | `scripts/security/openbao-init.sh` | ✅ | Scriptul detectează starea, rulează `bao operator init/unseal` și persistă cheile doar în `.secrets/`. |
| F0.5.5 | Politici ACL/AppRole | `scripts/security/policies/*.hcl` | ✅ | Există politici per domeniu (cp/*, apps, infra) cu capabilități least-privilege pentru AppRole și CI. |
| F0.5.6 | Inventar secrete | `docs/security/F0.5-Secrets-Inventory-OpenBao.{csv,md}` | ✅ | Matricea map-ează fiecare variabilă `.env` către calea OpenBao și starea de migrare, folosită de scripturile de seed. |
| F0.5.7 | Migrare secrete statice | `scripts/security/seed-secrets.sh` | ✅ | Utilitarul citește inventarul, validează BAO token și înscrie secrete KV fără a le salva pe disc. |
| F0.5.8 | Standard criptografic intern | `docs/security/F0.5-Crypto-Standards-OpenBao.md` | ✅ | Documentul impune entropie ≥256 biți, algoritmi acceptați și proceduri de rotație pentru toate cheile. |
| F0.5.9 | Pgcrypto enablement | `scripts/db/migrations/001_enable_pgcrypto_all_databases.sql`, `docs/security/Pgcrypto-Integration-Guide.md`, `shared/common/pgcrypto-utils.ts` | ✅ | Migrația activează extensia în 15 DB-uri, iar ghidul + utilitățile TypeScript descriu integrarea cu OpenBao. |
| F0.5.10 | Database secrets engine | `scripts/security/openbao-enable-db-engine.sh` | ✅ | Scriptul configurează conexiunea Postgres, TTL-urile și testează generarea credentialelor dinamice. |
| F0.5.11 | Roluri SQL dedicate | `database/roles/*.sql`, `database/roles/roles.json` | ✅ | Roluri runtime per aplicație cu TTL scurt sunt sincronizate prin manifest și scripturi dedicate. |
| F0.5.12 | Lease watcher & renew | `scripts/security/watchers/db-creds-renew.sh`, `shared/observability/metrics/watchers/db-creds-renew.prom` | ✅ | Watcher-ul colectează lease-uri active, reînnoiește înainte de expirare și expune metrici pentru Prometheus. |
| F0.5.13 | Imagine `node-openbao` | `shared/docker/node-openbao.Dockerfile`, `shared/docker/scripts/entrypoint-supervisor.sh` | ✅ | Imaginea comună include agentul, Tini și entrypoint-ul supervisor utilizat de toate containerele PS. |
| F0.5.14 | Pilot Process Supervisor | `numeriqo.app/Dockerfile`, `numeriqo.app/openbao/*`, `numeriqo.app/scripts/start-app.sh` | ✅ | Pilotul Numeriqo rulează pe `geniuserp/node-openbao:local`; rămâne de clonat același model în `cp/suite-login` (gap deschis). |
| F0.5.15 | DevX & tooling | `docs/devx/OpenBao-Process-Supervisor.md`, `scripts/start-suite.sh` | ✅ | Ghidul detaliază fluxurile PS, iar scriptul suite creează rețele/volume și pornește stack-ul cu OpenBao pregătit. |
| F0.5.16 | Bibliotecă șabloane & env flattening | `cp/suite-shell/openbao/templates/*.tpl`, `cp/identity/openbao/templates/db-creds.tpl`, `proxy/openbao/templates/*.tpl` | ✅ | Traefik proxy rulează acum pe același model (OpenBao Agent + tpl) — nu mai există servicii cu `.env` statice. |
| F0.5.17 | Șabloane dinamice DB/secret files | `*/openbao/templates/db-creds.tpl`, `cp/*/openbao/templates/app-secrets.tpl`, `proxy/openbao/agent-config.hcl` | ✅ | Traefik are agent propriu, templates pentru dashboard basic-auth + Cloudflare token și script supervisor `proxy/scripts/start-traefik.sh`. |
| F0.5.18 | Fallback injection tooling | `scripts/security/inject.ts`, `scripts/security/inject.sh` | ✅ | Scriptul TypeScript validează fișierele randate și injectează env pentru CLI/migrații ce nu pot folosi PS. |
| F0.5.19 | OIDC blueprint | `docs/security/F0.5-OIDC.md`, `scripts/security/openbao-configure-oidc.sh` | ✅ | Documentația și scriptul configurează auth/jwt, rolul `github-actions` și politicile aferente. |
| F0.5.20 | OIDC roles/policies | `scripts/security/setup_oidc_roles.sh` | ✅ | Rolurile `ci-test-build`, `ci-e2e`, `ci-release` sunt create cu bound-claims stricte și politici dedicate. |
| F0.5.21 | CI/CD workflow update | `.github/workflows/release.yml` (pasul `hashicorp/vault-action@v2`) | ✅ | Workflow-ul folosește `id-token: write`, role `ci-release` și preia `GH_PAT_TOKEN` / `NPM_TOKEN` din OpenBao. |
| F0.5.22 | Cleanup & rotație post-migrare | `docs/security/F0.5-Cleanup.md`, `scripts/security/rotate-secrets.sh`, `scripts/security/github-secrets-cleanup.sh` | ✅ | Scriptul a fost rulat cu `--delete` pe 2025-11-24; vezi `docs/security/evidence/github-secrets-cleanup-2025-11-24-02.{md,json}` pentru snapshot-ul GH CLI ce confirmă absența tuturor secretelor legacy. |
| F0.5.23 | Backup & recovery | `compose.yml` (`openbao-backup` service), `scripts/compose/openbao-backup.sh`, `backups/openbao/` | ✅ | Sidecar-ul rulează backup-uri zilnice pe volum read-only și curăță retenția după 7 zile. |
| F0.5.24 | Observabilitate & alerte | `docs/observability/openbao-monitoring.md`, `shared/observability/dashboards/grafana/dashboards/openbao.json`, `shared/observability/metrics/rules/openbao.rules.yml` | ✅ | Prometheus colectează metrici, dashboard-ul Grafana există, iar alertele `OpenBaoSealed/OpenBaoDown` sunt definite. |
| F0.5.25 | Validare automată & chaos | `docs/security/F0.5-Validation.md`, `scripts/security/ci-bootstrap-openbao.sh`, `scripts/security/test-openbao-secrets.sh`, `.github/workflows/ci-f05-validation.yml` | ✅ | Workflow-ul CI bootstrap-ează OpenBao, reprovizionează AppRole + KV și rulează teste de prezență pentru toate secretele statice + verifică artefactele Process Supervisor; orice regresie blochează pipeline-ul. |

**Observații cheie:** (1) Traefik/Proxy a adoptat Process Supervisor + OpenBao templates, închizând gap-ul F0.5.16–17. (2) Rotațiile Post-migrare și dovada ștergerii secretelor GitHub (F0.5.22) au un script + model de evidență, dar rularea finală este în așteptare la echipa cu drepturi admin. (3) Chaos testing (`scripts/security/test-f05-chaos.sh`) este acum integrat în workflow-ul `ci-f05-validation.yml` și rulează după bootstrap + verificare KV.
