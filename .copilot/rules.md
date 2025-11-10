# Regulile Proiectului GeniusSuite pentru Agentul Copilot

Aceste reguli definesc comportamentul și ghidurile pentru agentul Copilot (Grok Code) în proiectul GeniusSuite. Agentul trebuie să le urmeze pentru a menține consistența și calitatea codului.

## Stack Tehnologic și Convenții
- **Limbaj:** TypeScript strict (noUncheckedIndexedAccess, exactOptionalPropertyTypes).
- **Frontend:** React 19 LTS, tRPC 3.1.0, Tailwind CSS.
- **Backend:** Node.js 24 LTS, Fastify v5.6.1, Drizzle ORM latest.
- **Bază de date:** PostgreSQL 18.
- **Monorepo:** NX workspace cu pnpm.
- **Containerizare:** Docker Compose (model hibrid).
- **Auth:** SuperTokens + OIDC + RBAC.
- **BPM:** Temporal TS SDK.
- **Broker:** Apache Kafka.
- **Observabilitate:** OpenTelemetry, Prometheus, Grafana.

## Convenții de Cod
- **Naming:** kebab-case pentru directoare, PascalCase pentru componente React, camelCase pentru funcții/variabile.
- **Imports:** Barrel exports (index.ts) pentru fiecare subdirector.
- **Error Handling:** Folosește ProblemDetails (RFC7807) în API-uri.
- **Testing:** Jest pentru unit, Playwright pentru e2e, k6 pentru load.
- **Linting:** ESLint + Prettier + TypeScript strict.

## Arhitectură Specifică
- **Micro-Frontends:** Module Federation în suite-shell pentru încărcare dinamică.
- **Data Mesh:** Aplicațiile produc "Produse de Date" pe Kafka; cerniq consumă pentru BI.
- **Multi-Tenant:** Subdomenii per tenant, RLS pe DB, entitlements per plan.
- **Securitate:** PKCE→OIDC→JWT, RBAC/ABAC, entitlements.
- **Model Hibrid:** Compose per-app + orchestrator root.

## Comenzi Comune
- **Instalare:** `pnpm install`
- **Dezvoltare:** `pnpm run dev --app <app>`
- **Build:** `pnpm nx build <app>`
- **Testare:** `pnpm nx test <app>`
- **DB:** `pnpm run db:migrate --app <app>`
- **Compose:** `pnpm run compose:up --app <app>`

## Ghiduri pentru Copilot
- Când generezi cod, respectă tipurile din `shared/types/`.
- Folosește hooks React pentru state management (Zustand pentru complex).
- În API-uri, folosește tRPC routers cu Zod pentru validare.
- Pentru DB, folosește Drizzle ORM cu schema.ts.
- Evită cod duplicat; reutilizează din `shared/`.
- Documentează funcții complexe cu JSDoc.
- Prioritizează securitatea: validează input-uri, folosește guards pentru auth.

## Resurse
- Plan detaliat: `Plan/GeniusERP_Suite_Plan_v1.0.5.md`
- Docs: `https://docs.geniuserp.app`
- Status: `https://status.geniuserp.app`