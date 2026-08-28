# Regulile Proiectului GeniusSuite pentru Agentul Copilot

Aceste reguli definesc comportamentul și ghidurile pentru agentul Copilot (Grok Code) în proiectul GeniusSuite. Agentul trebuie să le urmeze pentru a menține consistența și calitatea codului.

## Stack Tehnologic și Convenții
- **Limbaj:** TypeScript 5.9.3 strict (noUncheckedIndexedAccess, exactOptionalPropertyTypes).
- **Frontend:** React 19.2.8, tRPC 11.18.0, Zod 4.5.1, Tailwind CSS.
- **Backend:** Node.js 24 LTS, Fastify 5.12.1, Drizzle ORM 0.45.2.
- **Bază de date:** PostgreSQL 18.6.
- **Monorepo:** NX 22.7.8 cu pnpm 10.34.5 (exclusiv pnpm).
- **Containerizare:** Docker Compose (model hibrid). Backing services: `shared/backing-services/`.
- **Auth:** SuperTokens Core 12.1.1 + OIDC + RBAC.
- **BPM:** Temporal server 1.31.2, Temporal TS SDK 1.23.0.
- **Broker:** Apache Kafka 4.3.1.
- **Edge:** Traefik v3.7.12. Secrets: OpenBao 2.6.2.
- **Observabilitate:** OpenTelemetry Collector 0.159.0, Prometheus v3.14.0, Grafana 13.2.0, Loki 3.7.7.

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
- **Model Hibrid:** Compose per-app + backing services în `shared/backing-services/` (nu root) + Traefik `proxy/compose/` + observability.

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