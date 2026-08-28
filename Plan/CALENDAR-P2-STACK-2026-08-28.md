# Calendar P2 — stack (nu în sprint-ul 28.08.2026)

Sursă de adevăr: verificări registry/GitHub/Docker Hub la **28.08.2026**. P0/P1 sunt aplicate în repo. Acestea rămân planificate.

| Când | Componentă | În repo acum | Țintă | Motivul amânării |
| --- | --- | --- | --- | --- |
| Sprint următor (bridge) | TypeScript | 5.9.3 | **6.0.3** apoi tsgo în CI | TS 7.0.2 e latest, dar fără API programatic stabil (așteptat în 7.1). `typescript-eslint@8.68.0` cere `typescript >=4.8.4 <6.1.0`. Săritul peste TS 6 e greșeala comună. |
| După TS 7.1 | TypeScript 7 / tsgo | — | 7.1+ | Compilator Go (~8–12×). Mută typescript-eslint când suportă API-ul. |
| La GA Drizzle v1 | Drizzle ORM | 0.45.2 / kit 0.31.10 (docs) | v1.0 GA | v1 e RC5 la 28.08.2026 — rămânem pe 0.45.x. |
| Q4 2026 | PostgreSQL 19 | 18.6 | 19.x GA | GA estimat sep–oct 2026. |
| După 28 oct 2026 | Node.js 26 | 24 LTS (`@types/node` 24.13.3) | 26 Active LTS | 26 nu e încă Active LTS. **Corepack:** din Node.js 25 nu mai e livrat în imagine; pe 24 rămâne. La upgrade: în Dockerfile, bootstrap Corepack separat (`npm install -g corepack` — **singura** excepție npm, doar ca să existe binarul `corepack`), apoi tot `corepack enable && corepack prepare pnpm@…`; alternativ, pnpm standalone (get.pnpm.io) fără npm. Nu reveni la `npm ci`. |
| După Nx 22.7.8 stabil în CI | Nx 23 | 22.7.8 | 23.1.2 | Major. `@nx/eslint@22.7.8` suportă deja ESLint 10, deci 23 nu e blocant pentru ESLint. Rulează `pnpm exec nx migrate 23.1.2`. |
| Evaluare | pnpm 11 | 10.34.5 | 11.24.0 | Major. 11 cere Node `>=22.13`. Bump în 10 e fără risc; 11 separat. |
| Când k3s preia 1.37 | Kubernetes | — (nu e în compose-ul curent) | kind v0.33.0 local; k3s v1.36.4+k3s1 server; upstream 1.37.0 recent | Nu instala 1.37 pe k3s până există tag k3s. |
| Continuu | OTel Collector | **0.159.0** (pinuit azi) | următorul **stabil** de pe [releases](https://github.com/open-telemetry/opentelemetry-collector-releases/releases) | Nightly 0.160.0 nu se pinuiește. |
| Sprint metrics | prom-client | 15.1.3 (latest, **deprecated**) | `@prometheus-io/client` | npm: „prom-client has been replaced by @prometheus-io/client”. Nu e swap drop-in — migrație API. |
| După 1.32 GA | Temporal server | 1.31.2 | 1.32.x GA | La 28.08.2026: GitHub latest stable = v1.31.2; `temporalio/server:1.32.0` = 404. |
| După Loki 3.7 images pentru Promtail | Promtail | 3.6.4 | aliniere cu Loki 3.7.7 | `grafana/promtail:3.7.7` nu exista pe Docker Hub (3.6.4 era ultimul 3.6.x verificat). |

## Node 26 — Corepack lipsește din imagine

Din **Node.js 25**, Corepack **nu mai e distribuit** în binarul oficial; rămâne inclus doar în Node 24 și mai vechi. Dockerfile-urile actuale (`node:24-alpine` + `corepack enable && corepack prepare pnpm@…`) sunt corecte **azi**.

La upgrade-ul P2 la Node 26, `corepack` din imagine va lipsi. Alege una:

1. **Bootstrap Corepack, apoi pnpm** (preferat dacă vrei să păstrezi `packageManager` din `package.json`):
   ```dockerfile
   RUN npm install -g corepack \
     && corepack enable \
     && corepack prepare pnpm@10.34.5 --activate
   ```
   `npm install -g corepack` e **singura** excepție npm: instalează binarul Corepack, nu dependențele aplicației. După asta: exclusiv pnpm. Nu `npm ci`.
2. **pnpm standalone** (fără npm): scriptul oficial get.pnpm.io / imaginile `pnpm` — tot pin pe versiunea din `packageManager`.

Nu presupune că `corepack` există pe `node:26-alpine`.

## Nx 23 — evaluare (28.08.2026)

- Latest: **23.1.2**.
- Decizie sprint: **rămânem pe 22.7.8** (cerința „întâi `nx migrate 22.7.8`”).
- ESLint 10.9.1 este compatibil cu `@nx/eslint@22.7.8` (peer `eslint: ^8 \|\| ^9 \|\| ^10`) și cu `typescript-eslint@8.68.0` (peer `eslint: ^8.57 \|\| ^9 \|\| ^10`, `typescript <6.1.0`).
- Următorul pas: `pnpm exec nx migrate 23.1.2` pe un branch separat, după ce CI e verde pe 22.7.8.

## Pachete neinstalate încă (doar documentate)

Nu există în `package.json` (skeleton): React, tRPC, Zod, Temporal SDK, SuperTokens Node SDK, Drizzle. Versiunile din README sunt țintele când se adaugă dependența, nu pachete ghost.
