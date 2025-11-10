# GeniusSuite – Suită Modulară Enterprise (PERN, NX Monorepo, Docker)

GeniusSuite este o suită modulară de aplicații enterprise, construită pe stack modern: **React 19 LTS**, **Node.js 24 LTS**, **TypeScript latest**, **Fastify v5.6.1**, **Drizzle ORM**, **PostgreSQL 18**, **NX monorepo**, **Docker Compose** (model hibrid). Este vândută fie ca suită completă **GeniusERP.app**, fie ca aplicații stand-alone: **archify.app**, **cerniq.app**, **flowxify.app**, **i-wms.app**, **mercantiq.app**, **numeriqo.app**, **triggerra.app**, **vettify.app**.

## Stack Principal

* **Monorepo:** Nx + pnpm workspaces
* **Language:** TypeScript (strict)
* **Tooling:** ESLint, Prettier, Husky, lint-staged, commitlint

## Module Principale

### Control Plane (CP)
- **geniuserp.app** – Orchestrator suitei, portal public, customer portal, status & docs.
- **suite-shell** – Micro-frontend host pentru MF remote loading.
- **suite-admin** – Portal administrare centrală (users, roles, tenants, licenses).
- **suite-login** – PKCE + OIDC login.
- **identity** – SuperTokens + OIDC provider + RBAC + multi-tenant.
- **licensing** – Entitlements, metering, billing (Stripe/Revolut).
- **analytics-hub** – BI pentru suită (ingestion Kafka → warehouse → semantic layer).
- **ai-hub** – Servicii AI centralizate (inference, RAG, assistants).

### Aplicații Stand-Alone
- **archify.app** – Document Management (DMS): upload, OCR, versionare, ACL, șabloane, e-semnătură, workflows.
- **cerniq.app** – Advanced BI & Data Mesh: consumator "Produse de Date", semantic layer, dashboards, governance.
- **flowxify.app** – BPM + Collaboration + iPaaS: Temporal workflows, AI agents (CrewAI/LangGraph), MCP server.
- **i-wms.app** – Warehouse & Inventory: multi-depozit, AI slotting, picking optimization, WES, 3PL billing.
- **mercantiq.app** – Commerce & Sales Ops: cataloage, cotații B2B, checkout, orders, AI recommendations.
- **numeriqo.app** – Accounting (RO) + HR/Payroll: partidă dublă, TVA, SAF-T, CIM, D112, e-Factura.
- **triggerra.app** – Marketing Automation: CDP, journeys (Temporal), attribution (MTA/MMM), clean rooms.
- **vettify.app** – CRM & Firmographics: leads/accounts/contacts, enrichment (RO/EU), scoring ML, outreach.

### Infrastructură Comună
- **shared/** – Librării comune: UI design system, auth-client, types, integrations, observability.
- **gateway/** – API Gateway + BFF: agregare tRPC/OpenAPI, policy enforcement (RBAC + entitlements), caching, rate-limit.
- **proxy/** – Traefik edge proxy: TLS ACME, routing, forward-auth, WAF, observabilitate.
- **scripts/** – DevOps tooling: bootstrap, compose orchestration, DB lifecycle, QA (e2e/load/security), CI/CD.

## Stack Tehnologic

- **Frontend:** React 19 LTS, TypeScript latest, tRPC 3.1.0, Tailwind CSS.
- **Backend:** Node.js 24 LTS, Fastify v5.6.1, Drizzle ORM latest + Drizzle-kit, PostgreSQL 18.
- **Auth:** SuperTokens 11.2.0 LTS (PKCE → JWT), OIDC, RBAC, multi-tenant.
- **BPM:** Temporal TS SDK 1.13.1.
- **Broker:** Apache Kafka 4.1.0 LTS.
- **Observabilitate:** OpenTelemetry, Prometheus, Grafana, Loki, Tempo.
- **Containerizare:** pnpm, NX, Docker Compose (model hibrid: per-app + orchestrator root).

## Arhitectură Generală

- **Model Hibrid:** Compose per aplicație (izolare, ownership clar) + compose orchestrator root (rețele shared, Traefik, observability).
- **Micro-Frontends:** Module Federation pentru încărcare dinamică în suite-shell.
- **Data Mesh:** Aplicațiile produc "Produse de Date" pe Kafka; cerniq consumă pentru BI unificat.
- **Multi-Tenant:** Subdomenii per tenant, RLS pe DB, entitlements per plan.
- **Securitate:** PKCE→OIDC→JWT, RBAC/ABAC, entitlements, observabilitate completă.

## Instalare și Pornire

### Cerințe
- Node.js 24 LTS
- pnpm latest
- Docker & Docker Compose
- PostgreSQL 18 (sau via Docker)

### Initialization
```bash
pnpm install
```

### Common Commands
```bash
# Run linting on all projects
pnpm lint

# Check formatting (without modifying files)
pnpm format:check

# Apply formatting to the entire monorepo
pnpm format:write
```

### Pornire Suită
```bash
# Pornire core (proxy + gateway + CP + geniuserp)
pnpm run compose:up --profile core

# Sau întreaga suită
pnpm run compose:up --app all
```

Accesează la `https://geniuserp.app` (portal public) sau `https://app.geniuserp.app` (customer portal).

## Dezvoltare

- **NX Monorepo:** `pnpm nx run <app>:<task>` pentru build/test per app.
- **Hot Reload:** `pnpm run dev --app <app>` pentru dezvoltare locală.
- **Testare:** Unit (Jest), integration, e2e (Playwright), load (k6), security (ZAP/Semgrep).
- **Linting:** ESLint, Prettier, TypeScript strict.

## Contribuții

1. Fork repo-ul.
2. Creează branch feature: `git checkout -b feature/nume-feature`.
3. Commit conventional: `git commit -m "feat: descriere"`.
4. Push și PR.

Vezi `scripts/README.md` pentru tooling complet.

## Licență

Proprietate privată – contactați echipa pentru licențiere.

## Suport

- Docs: `https://docs.geniuserp.app`
- Status: `https://status.geniuserp.app`
- Contact: admin@geniuserp.app