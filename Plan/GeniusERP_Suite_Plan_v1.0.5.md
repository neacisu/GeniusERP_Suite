# GeniusERP Suite Plan

Add Headings (Format > Paragraph styles) and they will appear in your table of contents.

## Capitolul 1 - GeniusSuite – Plan general

### 1) Descriere generală

GeniusSuite este o suită modulară de aplicații enterprise (PERN, NX monorepo, Docker) vândută fie ca suita completă **GeniusERP.app**, fie ca aplicații stand‑alone: **archify.app, cerniq.app, flowxify.app, geniuserp.app, i-wms.app, mercantiq.app, numeriqo.app, triggerra.app, vettify.app**. Fiecare aplicație rulează în containere proprii, cu rețele Docker interne, SSO comun și control centralizat al licențelor.

### 2) Distribuția modulelor pe domenii

- **geniuserp.app** – Control Plane (admin, auth, settings, analytics, audit, ai, integrations, shared, users)
- **archify.app** – Document Management (documents, OCR, versionare, registru)
- **cerniq.app** – Platformă Data Mesh & BI (consumator de "Produse de Date", semantic layer, dashboards, governance)
- **flowxify.app** – BPM + Collaboration + Mesagerie internă & Intranet
- **i-wms.app** – Warehouse & Inventory (multi‑gestiune, curieri, POS)
- **mercantiq.app** – Commerce & Sales Ops (sales, ecommerce, quotes assist)
- **numeriqo.app** – Accounting (RO) + HR & Payroll + Invoicing (pro)
- **triggerra.app** – Marketing Automation (campanii, journeys, comms)
- **vettify.app** – CRM & Relații + Firmographics (CUI/ANAF/Termene)

### 3) Stack tehnologic

- **Frontend:** React 19 LTS, TypeScript (latest), tRPC 3.1.0, Tailwind
- **Backend:** Node.js 24 LTS, Fastify v5.6.1, Drizzle ORM (latest) + Drizzle‑kit, PostgreSQL 18
- **Auth:** SuperTokens 11.2.0 LTS (PKCE → JWT), OIDC, RBAC, multi‑tenant
- **BPM:** Temporal TS SDK 1.13.1
- **Broker:** Apache Kafka 4.1.0 LTS
- **Observabilitate:** OpenTelemetry, Prometheus, Grafana, Loki, Tempo
- **Containerizare:** pnpm, NX, Docker Compose (model hibrid)

### 4) Control Plane (CP)

- **suite-shell** – orchestrator micro‑frontend (routing, registry, runtime)
- **suite-admin** – portal administrare centrală
- **suite-login** – portal PKCE + OIDC
- **identity** – SuperTokens + OIDC provider + RBAC + tenants
- **licensing** – licențe, entitlement & metering, billing
- **analytics-hub** – Hub de Evenimente & Data Mesh (colectare stream-uri Kafka, publicare "Produse de Date" ale suitei)
- **ai-hub** – servicii AI (inference, RAG, assistants)

### 5) Structură directoare (radăcină + 2 niveluri)

```text
/var/www/GeniusSuite/                       # rădăcina monorepo‑ului NX + orchestrator
├── shared/                                  # librării comune reutilizabile
│   ├── ui-design-system/                    # componente UI, layouts, tokens
│   ├── feature-flags/                       # SDK flags server/client + API admin
│   ├── auth-client/                         # PKCE/OIDC/JWT client + hooks React
│   ├── types/                               # tipuri TS: domain, api, events, security
│   ├── common/                              # utils, config, constants, logger
│   ├── integrations/                        # conectori: ANAF, BNR, Revolut, Shopify…
│   └── observability/                       # logs/metrics/traces, dashboards, alerts
├── cp/                                      # Control Plane (suita centrală)
│   ├── suite-shell/                         # host MF (container + web + BFF)
│   ├── suite-admin/                         # portal administrare (web + api)
│   ├── suite-login/                         # login PKCE/OIDC (web + pkce + oidc)
│   ├── identity/                            # SuperTokens + OIDC provider + RBAC
│   ├── licensing/                           # entitlement/metering/billing + SDK
│   ├── analytics-hub/            # Hub Data Mesh (stream consumers, data products, semantics)
│   └── ai-hub/                              # inference, embeddings, RAG, assistants
├── archify.app/                             # DMS stand‑alone (web/api/db)
│   ├── web/                                 # frontend
│   ├── api/                                 # BFF/REST/tRPC
│   └── compose/                             # docker‑compose al aplicației
├── cerniq.app/ # Platformă Data Mesh & BI stand‑alone
│   ├── consumers/             # Conectori/Consumatori pt. "Data Products"
│   ├── semantics/              # Semantic layer (metrici, KPIs)
│   ├── dashboards/           # Vizualizări (Grafana, etc.) 
│   └── compose/               # orchestrare BI
├── flowxify.app/                            # BPM + Collaboration + Intranet
│   ├── web/
│   ├── api/
│   └── compose/
├── i-wms.app/                               # Warehouse & Inventory
│   ├── web/
│   ├── api/
│   └── compose/
├── mercantiq.app/                           # Commerce & Sales Ops
│   ├── web/
│   ├── api/
│   └── compose/
├── numeriqo.app/                            # Accounting + HR/Payroll + Invoicing
│   ├── web/
│   ├── api/
│   └── compose/
├── triggerra.app/                           # Marketing Automation
│   ├── web/
│   ├── api/
│   └── compose/
├── vettify.app/                             # CRM + Firmographics
│   ├── web/
│   ├── api/
│   └── compose/
├── geniuserp.app/                           # website suita (public site)
│   ├── web/
│   └── compose/
├── gateway/                                 # BFF/API gateway + agregare OpenAPI
│   ├── bff/
│   ├── api-gateway/
│   └── compose/
├── proxy/                                   # Traefik/Caddy, TLS, routing
│   ├── traefik/
│   └── compose/
├── scripts/                                 # bootstrap, db, ci, qa, compose helpers
│   ├── bootstrap/
│   ├── db/
│   └── compose/
├── docs/                                    # arhitectură, securitate, runbooks
│   ├── architecture/
│   ├── security/
│   └── ops/
└── compose.proxy.yml                        # orchestrator root (rețele, Traefik, observability)
```

**Notă orchestrare (model hibrid):**

- Compose **per aplicație** (`*/compose/docker-compose.yml`) → izolare, rulare rapidă, ownership clar.
- Compose **orchestrat la rădăcină** (`/var/www/GeniusSuite/compose.proxy.yml`) → pornește suita/subseturi, gestionează Traefik, rețelele partajate și observability.

### 6) Licențiere & Deployment

- Stand‑alone sau suită completă; licențiere și entitlement centralizate în **CP/licensing**.
- SSO PKCE→JWT comun (SuperTokens/identity), multi‑tenant la nivel de subdomeniu.
- Pipeline CI/CD pe profiluri (dev/staging/prod) + observabilitate unificată.

## Capitolul 2 `shared/` – modul comun al suitei (arhitectură și structuri detaliate)

> Scop: oferă biblioteci, tipuri, utilitare, SDK‑uri și observabilitate comune tuturor aplicațiilor și Control Plane‑ului. Standardizează API‑urile, erorile, contractele de evenimente și UX‑ul.

### 1) `ui-design-system/`

Structură pe 6–7 niveluri până la fișiere, cu comentarii pentru fiecare element.

```text
shared/ui-design-system/
├── package.json                      # pachet npm intern, sideEffects: false
├── tsconfig.json                     # strictețe TS pentru librării
├── index.ts                          # barrel exports → components, hooks, themes
├── README.md                         # ghid design tokens, theming, contribuții
├── components/                       # componente compuse (fără Radix leaks)
│   ├── inputs/
│   │   ├── button/
│   │   │   ├── Button.tsx            # componentă principală
│   │   │   ├── ButtonIcon.tsx        # comp. auxiliară pentru icon‑only
│   │   │   ├── types.ts              # variante, dimensiuni, intent
│   │   │   ├── styles.css            # stiluri locale (CSS modules)
│   │   │   ├── index.ts              # exporturi locale
│   │   │   └── __tests__/Button.test.tsx
│   │   ├── input/
│   │   │   ├── Input.tsx
│   │   │   ├── types.ts
│   │   │   ├── validators.ts         # pattern‑uri comune
│   │   │   ├── index.ts
│   │   │   └── __tests__/Input.test.tsx
│   │   └── select/
│   │       ├── Select.tsx
│   │       ├── Combobox.tsx
│   │       ├── adapters/
│   │       │   ├── http.adapter.ts   # fetch JSON → options
│   │       │   └── trpc.adapter.ts   # tRPC query → options
│   │       ├── types.ts
│   │       ├── index.ts
│   │       └── __tests__/Select.test.tsx
│   ├── data-display/
│   │   ├── badge/
│   │   │   ├── Badge.tsx
│   │   │   ├── types.ts
│   │   │   └── index.ts
│   │   └── tooltip/
│   │       ├── Tooltip.tsx
│   │       ├── provider.tsx          # TooltipProvider cu portal & delay group
│   │       └── index.ts
│   ├── overlays/
│   │   ├── dialog/
│   │   │   ├── Dialog.tsx            # modal a11y‑compliant
│   │   │   ├── ConfirmDialog.tsx     # pattern confirm
│   │   │   └── index.ts
│   │   └── drawer/
│   │       ├── Drawer.tsx
│   │       └── index.ts
│   ├── tables/
│   │   ├── table/
│   │   │   ├── Table.tsx
│   │   │   ├── TableHeader.tsx
│   │   │   ├── TableRow.tsx
│   │   │   └── index.ts
│   │   └── datagrid/
│   │       ├── DataGrid.tsx
│   │       ├── columns/
│   │       │   ├── Column.ts
│   │       │   ├── column.types.ts
│   │       │   └── index.ts
│   │       ├── hooks/
│   │       │   ├── useVirtual.ts
│   │       │   ├── useSort.ts
│   │       │   ├── useFilter.ts
│   │       │   └── usePagination.ts
│   │       └── index.ts
│   └── forms/
│       ├── form/
│       │   ├── Form.tsx               # provider + context
│       │   ├── FormSection.tsx
│       │   └── index.ts
│       └── field/
│           ├── Field.tsx              # label + control + error
│           ├── helpers.ts
│           └── index.ts
├── primitives/                        # wrappers peste Radix/shadcn v3.5.0
│   ├── radix/
│   │   ├── Dialog.tsx
│   │   ├── Popover.tsx
│   │   ├── DropdownMenu.tsx
│   │   ├── Tooltip.tsx
│   │   └── index.ts
│   ├── form/
│   │   ├── Label.tsx
│   │   ├── HelperText.tsx
│   │   ├── ErrorText.tsx
│   │   └── index.ts
│   └── accessible/
│       ├── FocusRing.tsx
│       ├── VisuallyHidden.tsx
│       ├── SkipToContent.tsx
│       └── index.ts
├── layouts/
│   ├── app-layout/
│   │   ├── AppLayout.tsx              # shell general: Header + Sidebar + Content
│   │   ├── Header.tsx
│   │   ├── Sidebar.tsx
│   │   ├── Content.tsx
│   │   ├── Footer.tsx
│   │   └── index.ts
│   └── auth-layout/
│       ├── AuthLayout.tsx
│       └── index.ts
├── hooks/
│   ├── useTheme.ts
│   ├── useBreakpoint.ts
│   ├── usePortal.ts
│   └── __tests__/useTheme.test.ts
├── contexts/
│   ├── ThemeContext.tsx
│   ├── ToastContext.tsx
│   ├── DialogContext.tsx
│   └── Providers.tsx
├── icons/
│   ├── svg/
│   │   ├── actions/
│   │   ├── navigation/
│   │   ├── status/
│   │   ├── optimize/svgo.config.js
│   │   └── LICENSES/
│   └── react/
│       ├── generated/                 # <IconName.tsx> auto‑generate
│       ├── scripts/build-icons.ts
│       └── index.ts
├── styles/
│   ├── tailwind/
│   │   ├── tailwind.config.ts
│   │   ├── postcss.config.cjs
│   │   ├── plugins/animations.ts
│   │   └── presets/theming.ts
│   ├── tokens.css
│   ├── reset.css
│   └── index.css
├── tokens/
│   ├── colors.json
│   ├── spacing.json
│   ├── motion.json
│   └── generators/build.ts            # style‑dictionary → CSS vars/TS
├── storybook/
│   ├── .storybook/main.ts
│   ├── .storybook/preview.ts
│   └── stories/components/Button.stories.mdx
├── tests/
│   ├── jest.config.ts
│   ├── setupTests.ts
│   └── visual/playwright.config.ts
└── build/
├── tsup.config.ts
├── scripts/release.ts
└── scripts/changelog.ts
```

### 2) `feature-flags/` SDK server/client + API admin, cu DB și openapi

```text
shared/feature-flags/
├── package.json
├── drizzle/
│   ├── schema.ts                 # Flags, Segments, Overrides, Audits
│   └── migrations/
├── src/
│   ├── server/
│   │   ├── providers/
│   │   │   ├── file.provider.ts      # flags din fișier (dev)
│   │   │   ├── drizzle.provider.ts    # flags din DB (prod) │   │   │   └── http.provider.ts      # flags din service extern
│   │   ├── strategies/
│   │   │   ├── percentage.ts         # rollout % pe user/org
│   │   │   ├── timeWindow.ts         # activare în intervale orare/date
│   │   │   └── targeting.ts          # expresii condiții
│   │   ├── middlewares/fastify.ts    # injectează contextul de evaluare
│   │   └── sdk.ts                    # evaluateFlag(), getVariant()
│   ├── client/
│   │   ├── sdk.ts                    # getFlag() browser + cache + SSE
│   │   ├── storage/
│   │   │   ├── local.ts
│   │   │   └── memory.ts
│   │   └── transport/sse.ts          # live updates
│   ├── types/
│   │   ├── flag.ts
│   │   └── index.ts
│   └── utils/hash.ts
├── api/
│   ├── routers/
│   │   ├── flags.router.ts           # CRUD flags/variants
│   │   ├── segments.router.ts
│   │   ├── overrides.router.ts
│   │   └── index.ts
│   ├── schemas/
│   │   ├── flag.schema.ts
│   │   └── segment.schema.ts
│   ├── openapi/spec.ts               # generează OpenAPI din Zod
│   └── guards/require-admin.ts       # authN/authZ pentru admin flags
└── README.md
```

### 3) `auth-client/` PKCE → OIDC → JWT, hooks React, guards RBAC/ABAC, multi‑tenant routing

```text
shared/auth-client/
├── package.json
├── src/
│   ├── pkce/
│   │   ├── generators/
│   │   │   ├── verifier.ts            # createCodeVerifier()
│   │   │   └── challenge.ts           # createCodeChallenge(S256)
│   │   ├── crypto/
│   │   │   ├── sha256.ts              # WebCrypto shim
│   │   │   └── base64url.ts
│   │   ├── storage/pkce.store.ts      # persistă state/verifier
│   │   └── utils.ts                   # nonce/state helpers
│   ├── oidc/
│   │   ├── discovery/fetchConfig.ts   # .well-known/openid-configuration
│   │   ├── endpoints/
│   │   │   ├── authorize.ts
│   │   │   ├── token.ts               # code → tokens
│   │   │   ├── refresh.ts             # refresh token rotation
│   │   │   ├── revoke.ts
│   │   │   └── userinfo.ts
│   │   └── jwks/
│   │       ├── fetchJwks.ts
│   │       └── selectKey.ts
│   ├── session/
│   │   ├── tokens/
│   │   │   ├── parse.ts               # decode fără verify
│   │   │   └── verify.ts              # verify + exp/nbf/aud
│   │   ├── manager/sessionManager.ts  # lifecycle: persist/refresh/clear
│   │   ├── storage/{cookie,web}.ts
│   │   └── clock.ts                   # drift compensation
│   ├── guards/
│   │   ├── rbac.ts                    # role‑based
│   │   ├── abac.ts                    # attribute‑based
│   │   └── entitlement.ts             # integrare CP/licensing
│   ├── tenants/
│   │   ├── resolver.ts                # subdomain → tenant
│   │   └── mapping.ts                 # tenant → issuer/client/scopes
│   ├── interceptors/
│   │   ├── fetch.ts                   # attach Authorization + retry 401
│   │   └── axios.ts
│   ├── hooks/
│   │   ├── useAuth.ts
│   │   ├── useSession.ts
│   │   ├── useTenant.ts
│   │   └── usePKCE.ts
│   └── react/
│       ├── AuthProvider.tsx
│       ├── RequireAuth.tsx
│       └── WithPermissions.tsx
├── tests/
│   ├── pkce.test.ts
│   ├── oidc.test.ts
│   └── session.test.ts
└── README.md
```

### 4) `types/` Tipuri cross‑domain: domain/api/events/security/ui/validation/dto/errors/utils

```text
shared/types/
├── index.ts
├── domain/
│   ├── crm/{Lead.ts,Contact.ts,Account.ts,Opportunity.ts,index.ts}
│   ├── sales/{Quote.ts,Order.ts,Deal.ts,PipelineStage.ts,index.ts}
│   ├── accounting/{Invoice.ts,JournalEntry.ts,Account.ts,Tax.ts,index.ts}
│   ├── hr/{Employee.ts,Contract.ts,PayrollRun.ts,Leave.ts,index.ts}
│   ├── inventory/{Product.ts,Sku.ts,Stock.ts,Warehouse.ts,Batch.ts,index.ts}
│   ├── documents/{Document.ts,Version.ts,Tag.ts,Signature.ts}
│   └── common/{User.ts,Company.ts,Tenant.ts,Address.ts,Currency.ts,index.ts}
├── api/
│   ├── requests/{pagination.ts,filters.ts,search.ts,index.ts}
│   ├── responses/{pagination.ts,result.ts,index.ts}
│   └── contracts/{auth.ts,crm.ts,accounting.ts,inventory.ts,index.ts}
├── events/
│   ├── topics/{crm.topics.ts,accounting.topics.ts,inventory.topics.ts,index.ts}
│   ├── schemas/
│   │   ├── crm/{lead-created.v1.json,lead-updated.v1.json,index.ts}
│   │   ├── accounting/{invoice-issued.v1.json,index.ts}
│   │   ├── inventory/{stock-changed.v1.json,index.ts}
│   │   └── common/{metadata.ts,index.ts}
│   ├── versions/{crm/,accounting/,inventory/,index.ts}
│   ├── producers/
│   └── consumers/
├── security/{roles.ts,permissions.ts,policies.ts,claims.ts,entitlements.ts,index.ts}
├── ui/{table.ts,form.ts,layout.ts,theme.ts,index.ts}
├── validation/{primitives/{email.ts,uuid.ts,cui.ts,iban.ts,phone.ts},business/,address.ts,currency.ts,index.ts}
├── dto/{import/{csv.ts,xlsx.ts,index.ts},export/{csv.ts,xlsx.ts,index.ts},index.ts}
├── errors/{codes.ts,http.ts,domain.ts,retryable.ts,index.ts}
└── utils/{result.ts,option.ts,branded.ts,ids.ts,index.ts}
```

### 5) `common/` Utilitare, config centralizat, logger, middleware și mapare erori

```text
shared/common/
├── index.ts
├── utils/{date.ts,number.ts,string.ts,crypto.ts,env.ts,index.ts}
├── config/{default.ts,dev.ts,staging.ts,prod.ts}
├── constants/{index.ts,featureKeys.ts,limits.ts}
├── middleware/{requestId.ts,errorBoundary.ts,rateLimit.ts,cors.ts}
├── error-handling/{problem.ts,errorMapper.ts}
└── logger/{pino.ts,formatters.ts,index.ts}
```

### 6) `integrations/` Conectori oficiali (BNR, ANAF, Revolut, Shopify, Stripe, PandaDoc, e‑mail/SMS/WA, Graph, OpenAI, ElevenLabs, curieri)

```text
shared/integrations/
├── finance/{bnr/{client.ts,types.ts,index.ts},revolut/{client.ts,webhooks.ts,index.ts}}
├── gov/{anaf/{client.ts,auth.ts,schemas/,index.ts},termene/{client.ts,mappers.ts,index.ts}}
├── commerce/{shopify/{client.ts,webhooks.ts,index.ts},stripe/{client.ts,webhooks.ts,index.ts}}
├── docs/pandadoc/{client.ts,index.ts}
├── comms/{email/{client.ts,index.ts},whatsapp/{client.ts,index.ts},sms/{client.ts,index.ts}}
├── identity/microsoft-graph/{client.ts,index.ts}
├── ai/{openai/{chat.ts,embeddings.ts,index.ts},elevenlabs/{tts.ts,index.ts}}
└── logistics/{sameday/{client.ts,index.ts},fancourier/{client.ts,index.ts},cargus/{client.ts,index.ts}}
```

### 7) `observability/` Stack complet: logs/metrics/traces + dashboards, alerts și OTEL collector

```text
shared/observability/
├── logs/{ingestion/,parsers/,processors/,retention/,sinks/,dashboards/,README.md}
├── metrics/{exporters/,recorders/,rules/,dashboards/,README.md}
├── traces/{pipelines/,samplers/,processors/,exporters/,README.md}
├── dashboards/{grafana/,tempo/,prometheus/,README.md}
├── alerts/{rules/,notifiers/,runbooks/,README.md}
├── exporters/{otlp/,webhooks/,s3/,README.md}
├── otel-config/{apps/{vettify.yaml,numeriqo.yaml,cerniq.yaml,default.yaml},processors/,receivers/,exporters/,README.md}
├── compose/{docker-compose.yml,profiles/{compose.dev.yml,compose.staging.yml,compose.prod.yml},README.md}
├── scripts/{install.sh,validate.sh,smoke.sh,README.md}
└── docs/{architecture.md,how-to-add-app.md,dashboards.md,runbooks.md}
```

### Convenții generale

- **Naming:** `kebab-case` pentru directoare, `PascalCase.tsx` pentru componente, `camelCase.ts` pentru utilitare.
- **Barrel exports:** fiecare subdirector expune `index.ts` pentru API clar și tree‑shaking.
- **Strict TS:** `"strict": true`, `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`.
- **Testare:** unit (Jest), vizual (Playwright), e2e acolo unde are sens (component stories).
- **Versionare:** changeset pe pachetele `shared/*` + release automat în registry intern.

## Capitolul 3 - `cp/` – Control Plane (arhitectură și structuri detaliate)

> Scop: găzduiește serviciile centrale ale suitei: orchestrator MF, admin, login PKCE/OIDC, identitate (SuperTokens + OIDC provider + RBAC), licențiere & metering, analytics hub (BI pentru suită) și AI hub. Toate serviciile sunt containerizate și pot rula independent sau orchestrate la rădăcină.

### 1) `suite-shell/` – orchestrator micro‑frontend (Module Federation host)

```text
cp/suite-shell/
├── package.json
├── tsconfig.json
├── vite.config.ts                      # MF host config + remote preloading
├── src/
│   ├── mf-container/                   # MF runtime/container
│   │   ├── router/
│   │   │   ├── routes.config.ts        # declarativ: path → remote/module → guards
│   │   │   ├── RouteGuard.ts           # requireAuth/entitlement/role
│   │   │   ├── NotFound.tsx
│   │   │   └── index.ts
│   │   ├── registry/
│   │   │   ├── remotes.manifest.json   # {id,url,version,checksum,exposes}
│   │   │   ├── loaders.ts              # dynamic import + fallback
│   │   │   ├── integrity.ts            # SRI/checksum verify
│   │   │   └── index.ts
│   │   └── runtime/
│   │       ├── errorBoundary.tsx       # isolation pentru remotes
│   │       ├── suspenseFallback.tsx
│   │       └── index.ts
│   ├── web/                            # UI shell global
│   │   ├── pages/
│   │   │   ├── Home.tsx
│   │   │   ├── Catalog.tsx             # listă remotes + capabilities
│   │   │   └── Settings.tsx
│   │   ├── components/
│   │   │   ├── GlobalNav.tsx
│   │   │   ├── UserMenu.tsx
│   │   │   ├── TenantSwitcher.tsx
│   │   │   └── Footer.tsx
│   │   └── assets/
│   │       ├── logo.svg
│   │       └── styles.css
│   ├── api/                            # BFF/gateway pt. shell
│   │   ├── gateway/
│   │   │   ├── proxies.ts              # proxy către sub‑apps
│   │   │   ├── authz.ts                # compose guards (RBAC + entitlement)
│   │   │   └── index.ts
│   │   └── health/
│   │       ├── liveness.ts
│   │       └── readiness.ts
│   ├── configs/
│   │   ├── tenants/                    # config per tenant
│   │   │   ├── default.json
│   │   │   └── acme.json
│   │   └── routes/                     # route maps per env
│   │       ├── routes.dev.json
│   │       ├── routes.staging.json
│   │       └── routes.prod.json
│   ├── main.tsx
│   └── index.html
├── public/
│   └── manifest.webmanifest
├── compose/
│   ├── docker-compose.yml
│   ├── Dockerfile
│   └── nginx.conf                      # static host pt. assets/shell
└── README.md
```

### 2) `suite-admin/` – portal administrare centrală

```text
cp/suite-admin/
├── package.json
├── tsconfig.json
├── apps/
│   ├── web/                             # frontend admin
│   │   ├── src/
│   │   │   ├── pages/
│   │   │   │   ├── Users.tsx            # CRUD users
│   │   │   │   ├── Roles.tsx            # role designer
│   │   │   │   ├── Orgs.tsx             # companii/tenants
│   │   │   │   ├── Licenses.tsx         # plans, entitlements, usage
│   │   │   │   ├── Flags.tsx            # feature flags console (re‑use shared)
│   │   │   │   ├── Audit.tsx            # audit viewer (filters/export)
│   │   │   │   └── SystemHealth.tsx     # status CP & sub‑apps
│   │   │   ├── components/
│   │   │   │   ├── UserForm.tsx
│   │   │   │   ├── RoleMatrix.tsx
│   │   │   │   ├── TenantForm.tsx
│   │   │   │   └── QuotaCard.tsx
│   │   │   ├── hooks/
│   │   │   │   ├── useAdminApi.ts
│   │   │   │   └── useMetrics.ts
│   │   │   ├── api/
│   │   │   │   └── client.ts            # tRPC/OpenAPI client
│   │   │   └── main.tsx
│   │   └── vite.config.ts
│   └── api/                             # backend admin
│       ├── src/
│       │   ├── trpc/
│       │   │   ├── index.ts
│       │   │   ├── users.router.ts
│       │   │   ├── roles.router.ts
│       │   │   ├── tenants.router.ts
│       │   │   ├── licensing.router.ts
│       │   │   ├── feature-flags.router.ts
│       │   │   └── audit.router.ts
│       │   ├── openapi/
│       │   │   ├── spec.ts             # generează OpenAPI din Zod
│       │   │   └── docs.ts             # serve UI (Scalar/Swagger)
│       │   ├── services/
│       │   │   ├── users.service.ts
│       │   │   ├── roles.service.ts
│       │   │   ├── tenants.service.ts
│       │   │   ├── licensing.service.ts
│       │   │   └── audit.service.ts
│       │   ├── db/
│       │   │   ├── drizzle/             # schema.ts + migrations │       │   │   └── seeds.ts
│       │   ├── auth/
│       │   │   ├── guards.ts           # requireScope/role/entitlement
│       │   │   └── session.ts          # verify JWT
│       │   ├── index.ts                # Fastify v5.6.1 bootstrap
│       │   └── health.ts
│       └── Dockerfile
├── compose/
│   └── docker-compose.yml
└── README.md
```

### 3) `suite-login/` – portal PKCE + OIDC

```text
cp/suite-login/
├── package.json
├── tsconfig.json
├── web/
│   ├── src/
│   │   ├── pages/
│   │   │   ├── SignIn.tsx
│   │   │   ├── SignUp.tsx
│   │   │   ├── ForgotPassword.tsx
│   │   │   ├── ResetPassword.tsx
│   │   │   ├── Mfa.tsx                 # OTP/Authenticator/WebAuthn
│   │   │   └── Consent.tsx             # OAuth consent screen
│   │   ├── components/
│   │   │   ├── SignInForm.tsx
│   │   │   ├── PasswordMeter.tsx
│   │   │   ├── OtpInput.tsx
│   │   │   └── SocialButtons.tsx
│   │   ├── hooks/
│   │   │   ├── usePKCE.ts
│   │   │   └── useLoginFlow.ts
│   │   ├── api/client.ts               # apeluri către identity/oidc-provider
│   │   └── main.tsx
│   └── vite.config.ts
├── pkce/
│   ├── code-verifier.ts                # generează/verifică code_verifier
│   ├── code-challenge.ts               # calculează S256 challenge
│   ├── storage.ts                      # persist state/nonce/verifier
│   └── state.ts                        # handshake state machine
├── oidc/
│   ├── discovery.ts                    # fetch .well-known openid-configuration
│   ├── authorize.ts                    # build URL authorize (PKCE)
│   ├── token.ts                        # exchange code → tokens
│   ├── userinfo.ts
│   └── revoke.ts
├── compose/
│   ├── docker-compose.yml
│   └── Dockerfile
└── README.md
```

### 4) `identity/` – SuperTokens + OIDC provider + RBAC + tenants

```text
cp/identity/
├── package.json
├── tsconfig.json
├── src/
│   ├── supertokens/
│   │   ├── config/
│   │   │   ├── appInfo.ts              # domain, apiDomain, websiteDomain
│   │   │   ├── cookie.ts               # secure, sameSite, anti-CSRF
│   │   │   └── cors.ts
│   │   ├── recipes/
│   │   │   ├── emailpassword.ts
│   │   │   ├── passwordless.ts
│   │   │   ├── session.ts
│   │   │   └── multitenancy.ts         # org realms
│   │   └── adapters/
│   │       ├── db.adapter.ts           # Drizzle/PG adapter │   │       ├── email.adapter.ts        # SMTP provider
│   │       └── sms.adapter.ts          # SMS provider
│   ├── oidc-provider/
│   │   ├── jwks.json                   # chei publice (rotate periodic)
│   │   ├── discovery.ts                # /.well-known/openid-configuration
│   │   ├── authorize.handler.ts        # authorization_code (PKCE)
│   │   ├── token.handler.ts            # code → tokens (JWT)
│   │   ├── userinfo.handler.ts
│   │   └── introspect.handler.ts
│   ├── rbac/
│   │   ├── roles.ts                    # Role definitions
│   │   ├── permissions.ts              # Permission catalog
│   │   ├── policies.ts                 # Policy builders (RBAC/ABAC)
│   │   └── grants.ts                   # default grants per plan
│   ├── tenants/
│   │   ├── resolver.ts                 # subdomain → tenant
│   │   ├── mapping.ts                  # tenant → clientId/issuer/scopes
│   │   └── sso.ts                      # SAML/OIDC brokers (federare)
│   ├── db/
│   │   ├── drizzle/
│   │   │   ├── schema.ts           # Users, Sessions, Tenants, Orgs
│   │   │   └── migrations/
│   │   └── seeds.ts
│   ├── api/
│   │   ├── users.controller.ts
│   │   ├── sessions.controller.ts
│   │   ├── tenants.controller.ts
│   │   └── index.ts                    # Fastify v5.6.1 bootstrap
│   ├── middlewares/
│   │   ├── requireAuth.ts
│   │   ├── requireScope.ts
│   │   └── errorHandler.ts
│   └── index.ts
├── compose/
│   ├── docker-compose.yml
│   └── Dockerfile
└── README.md
```

### 5) `licensing/` – licențe, entitlements, metering, billing

```text
cp/licensing/
├── package.json
├── tsconfig.json
├── src/
│   ├── service/                        # servicii centrale
│   │   ├── entitlements/
│   │   │   ├── models.ts               # Plan, Feature, Entitlement, Limit
│   │   │   ├── rules.ts                # mapping plan → features → limits
│   │   │   ├── evaluator.ts            # checkAccess(tenant, feature)
│   │   │   └── index.ts
│   │   ├── metering/
│   │   │   ├── collectors/             # http/kafka/webhooks → usage events
│   │   │   ├── aggregator.ts           # windowed aggregation
│   │   │   ├── quotas.ts               # soft/hard limits
│   │   │   └── index.ts
│   │   ├── billing/
│   │   │   ├── stripe.adapter.ts
│   │   │   ├── revolut.adapter.ts
│   │   │   └── invoices.ts             # generare facturi pt. overages
│   │   ├── keys/
│   │   │   ├── kms.ts                  # KMS/HSM wrapper
│   │   │   └── signer.ts               # semnare licențe JWT/JWS
│   │   └── api/
│   │       ├── licensing.router.ts     # verify, reportUsage, getPlan
│   │       └── index.ts
│   ├── clients/                        # SDK clienți pentru apps
│   │   ├── node/
│   │   │   └── index.ts                # checkAccess(), reportUsage()
│   │   └── browser/
│   │       └── index.ts
│   ├── db/
│   │   ├── drizzle/
│   │   │   ├── schema.ts           # plans, features, entitlements, usage
│   │   │   └── migrations/
│   │   └── seeds.ts
│   ├── jobs/
│   │   ├── reconcile.ts                # reconciliere usage vs billing
│   │   └── invoicing.ts                # generare facturi periodice
│   ├── index.ts                        # Fastify v5.6.1 bootstrap
│   └── health.ts
├── compose/
│   ├── docker-compose.yml
│   └── Dockerfile
└── README.md
```

### 6) `analytics-hub/` – BI pentru suită (ingestion → warehouse → semantic → APIs)

```text
cp/analytics-hub/
├── package.json
├── tsconfig.json
├── collectors/
│   ├── otel/
│   │   ├── traces.receiver.yaml
│   │   └── metrics.receiver.yaml
│   ├── http/
│   │   ├── events.controller.ts        # webhook ingestion
│   │   └── index.ts
│   ├── db/
│   │   ├── pg-logical-decoding.ts      # Debezium/CDC
│   │   └── index.ts
│   └── kafka/
│       ├── topics.ts                   # topics canonice
│       ├── consumers.ts                # handlers pentru payloaduri
│       └── index.ts
├── ingestion/
│   ├── pipelines/
│   │   ├── cdc-to-raw.ts               # CDC → raw zone
│   │   ├── http-to-raw.ts              # webhooks → raw
│   │   └── otel-to-metrics.ts
│   └── scheduler.ts                     # Temporal workflows pentru publicare Data Products
├── transforms/
│   ├── dbt/
│   │   ├── dbt_project.yml
│   │   ├── models/
│   │   │   ├── staging/
│   │   │   ├── marts/
│   │   │   └── snapshots/
│   │   └── seeds/
│   └── quality/
│       ├── expectations.yaml           # great_expectations/dq checks
│       └── anomalies.ts
├── semantics/
│   ├── metrics.yaml                    # definiții KPI (name, dims, fcts)
│   ├── dimensions.yaml
│   └── explorer.presets.yaml
├── apis/
│   ├── trpc/
│   │   ├── metrics.router.ts
│   │   ├── reports.router.ts
│   │   └── index.ts
│   ├── rest/
│   │   ├── reports.controller.ts
│   │   └── index.ts
│   └── sql-federation/
│       └── gateway.ts                  # federare către PG/ClickHouse
├── dashboards/
│   ├── grafana/
│   │   └── *.json
│   └── superset/
│       └── assets/
├── governance/
│   ├── rls/
│   │   ├── policies.sql                # row-level‑security
│   │   └── tests.sql
│   ├── contracts/
│   │   └── data-contracts.yaml
│   └── lineage/
│       └── marbles.yaml
├── compose/
│   ├── docker-compose.yml
│   └── Dockerfile
└── README.md
```

### 7) `ai-hub/` – servicii AI centralizate (inference, RAG, assistants)

```text
cp/ai-hub/
├── package.json
├── tsconfig.json
├── services/
│   ├── inference/
│   │   ├── chat.controller.ts          # /v1/chat/completions (proxy/policy)
│   │   ├── tools.registry.ts           # tool functions declarative
│   │   └── index.ts
│   ├── embeddings/
│   │   ├── embeddings.controller.ts
│   │   └── index.ts
│   ├── assistants/
│   │   ├── sales.assistant.ts          # agent vânzări
│   │   ├── support.assistant.ts        # agent suport
│   │   └── analytics.assistant.ts      # agent BI Q&A
│   └── rag/
│       ├── pipelines/
│       │   ├── chunk.ts                # splitter + metadata
│       │   ├── indexer.ts              # vector DB upsert
│       │   └── search.ts               # hybrid/bm25/vector
│       ├── datasources/
│       │   ├── web.ts
│       │   ├── files.ts
│       │   └── postgres.ts
│       ├── retrievers/
│       │   ├── hybrid.ts
│       │   └── vector.ts
│       └── evaluators/
│           └── quality.ts              # grounding/faithfulness checks
├── adapters/
│   ├── openai.adapter.ts
│   ├── elevenlabs.adapter.ts
│   └── whisper.adapter.ts
├── api/
│   ├── rate-limit.ts                   # per tenant/user/model
│   ├── quotas.ts                       # align cu licensing
│   └── index.ts
├── compose/
│   ├── docker-compose.yml
│   └── Dockerfile
└── README.md
```

### Convenții & operațional

- **Segregare clară** `apps/` vs `services/`, `web/` vs `api/` când e cazul.
- **AuthN/AuthZ** centralizate: toate rutele admin trec prin `identity` (JWT + scopes + entitlements).
- **Temporal**: workflows pentru ingestie (analytics-hub) și joburi programate (licensing.jobs).
- **Kafka**: topics canonice pentru evenimente cross‑app (publicate din apps ca "Data Products", consumate de cerniq și alte module).
- **Docker Compose** la nivel de serviciu + profiluri orchestrate la rădăcină.

## Capitolul 4 - `archify.app/` – Document Management (DMS) – arhitectură și structuri detaliate

> Scop: gestionare documente enterprise (upload, OCR, indexare, versionare, permisiuni granulare, registru intrări/ieșiri, șabloane, e‑semnătură, fluxuri de aprobare, retenție legală), integrată în suita GeniusERP sau vândută stand‑alone.

### 1) Structură generală (6–7 niveluri, până la fișier) – web + API + servicii

```text
archify.app/
├── package.json
├── tsconfig.json
├── nx.json
├── README.md
├── apps/
│   ├── web/                                   # Frontend React 19 (SPA/MF remote)
│   │   ├── vite.config.ts
│   │   ├── public/
│   │   │   └── manifest.webmanifest
│   │   └── src/
│   │       ├── main.tsx
│   │       ├── index.html
│   │       ├── routes/
│   │       │   ├── AppRoutes.tsx              # map pagini ↔ componente + guards
│   │       │   ├── paths.ts                   # constante URL (typed)
│   │       │   └── loaders.ts                 # pre‑fetch pentru pagini mari
│   │       ├── pages/
│   │       │   ├── Dashboard.tsx
│   │       │   ├── Documents.tsx              # listare + filtre + căutare
│   │       │   ├── DocumentView.tsx           # preview + versiuni + permisiuni
│   │       │   ├── Upload.tsx                 # dropzone + validări + antivirus
│   │       │   ├── Registry.tsx               # registru intrări/ieșiri
│   │       │   ├── Templates.tsx              # șabloane documente
│   │       │   ├── Workflows.tsx              # fluxuri aprobare
│   │       │   ├── Retention.tsx              # politici retenție/arhivare
│   │       │   ├── Audit.tsx                  # trail evenimente
│   │       │   └── Settings.tsx
│   │       ├── features/
│   │       │   ├── documents/
│   │       │   │   ├── components/
│   │       │   │   │   ├── DocumentTable.tsx
│   │       │   │   │   ├── FiltersBar.tsx
│   │       │   │   │   ├── BulkActions.tsx
│   │       │   │   │   ├── UploadDropzone.tsx
│   │       │   │   │   ├── VersionTimeline.tsx
│   │       │   │   │   └── ShareDialog.tsx
│   │       │   │   ├── hooks/
│   │       │   │   │   ├── useDocuments.ts     # tRPC queries + cache
│   │       │   │   │   ├── useUpload.ts        # resumable + progress
│   │       │   │   │   └── useShare.ts         # link secure, expirare
│   │       │   │   ├── state/
│   │       │   │   │   ├── selection.store.ts  # Zustand: selectare rânduri
│   │       │   │   │   └── filters.store.ts
│   │       │   │   └── index.ts
│   │       │   ├── search/
│   │       │   │   ├── components/
│   │       │   │   │   ├── SearchBox.tsx
│   │       │   │   │   ├── Facets.tsx
│   │       │   │   │   └── ResultItem.tsx
│   │       │   │   ├── hooks/useSearch.ts      # query builder, highlight
│   │       │   │   └── index.ts
│   │       │   ├── workflows/
│   │       │   │   ├── components/WorkflowDesigner.tsx  # canvas steps
│   │       │   │   ├── hooks/useWorkflows.ts
│   │       │   │   └── index.ts
│   │       │   └── index.ts
│   │       ├── api/
│   │       │   ├── client.ts                    # tRPC/OpenAPI client
│   │       │   └── interceptors.ts              # attach JWT, retry
│   │       ├── providers/
│   │       │   ├── AuthProvider.tsx             # utilizează shared/auth-client
│   │       │   ├── ThemeProvider.tsx
│   │       │   └── QueryProvider.tsx            # @tanstack/react-query
│   │       ├── i18n/
│   │       │   ├── ro/translation.json
│   │       │   ├── en/translation.json
│   │       │   └── i18n.ts
│   │       └── styles/index.css
│   └── api/                                   # Backend Fastify v5.6.1 + tRPC + OpenAPI
│       ├── src/
│       │   ├── index.ts                       # bootstrap, middlewares
│       │   ├── config/
│       │   │   ├── env.ts                     # zod schema + loader
│       │   │   └── security.ts                # CORS, helmet, rate‑limit
│       │   ├── auth/
│       │   │   ├── requireAuth.ts             # verify JWT (shared/auth-client verify)
│       │   │   ├── requireScope.ts
│       │   │   ├── requireEntitlement.ts      # integrare cp/licensing
│       │   │   └── rbac.ts                    # guards pe resurse/owner
│       │   ├── db/
│       │   │   ├── drizzle/
│       │   │   │   ├── schema.ts          # Documents, Files, Versions, Tags, ACL
│       │   │   │   └── migrations/
│       │   │   ├── drizzle/                   # opțional: shared schemas
│       │   │   └── index.ts                   # drizzle ORM + telemetry
│       │   ├── storage/
│       │   │   ├── adapters/
│       │   │   │   ├── s3.adapter.ts          # S3/MinIO
│       │   │   │   ├── local.adapter.ts       # dev/local
│       │   │   │   └── gcs.adapter.ts         # opțional
│       │   │   ├── antivirus/
│       │   │   │   ├── clamav.client.ts       # scan stream
│       │   │   │   └── policy.ts              # blocklist/allowlist extenșii
│       │   │   ├── presign/
│       │   │   │   ├── createUploadUrl.ts     # URL presigned + checksum
│       │   │   │   └── createDownloadUrl.ts
│       │   │   └── index.ts
│       │   ├── ocr/
│       │   │   ├── engines/
│       │   │   │   ├── tesseract.ts           # Tesseract worker pool
│       │   │   │   └── vision.ts              # Google/Azure Vision (adapter)
│       │   │   ├── pipelines/
│       │   │   │   ├── pdf.ts                 # pdf → images → OCR
│       │   │   │   ├── image.ts               # image → OCR
│       │   │   │   └── office.ts              # office → pdf → images → OCR
│       │   │   └── index.ts
│       │   ├── convert/
│       │   │   ├── office/
│       │   │   │   ├── libreoffice.ts         # headless convert → PDF
│       │   │   ├── pdf/
│       │   │   │   ├── pdfinfo.ts             # metadate, pagini
│       │   │   │   ├── thumbnails.ts          # generare thumbnails
│       │   │   │   └── split-merge.ts
│       │   │   └── index.ts
│       │   ├── indexer/
│       │   │   ├── pipelines/
│       │   │   │   ├── text-extract.ts        # din OCR/Native → text
│       │   │   │   ├── nlp.ts                 # detect limbă, PII
│       │   │   │   └── enrich.ts              # entități, keywords
│       │   │   ├── engines/
│       │   │   │   ├── pg.ts                  # PG full‑text (tsvector)
│       │   │   │   └── elastic.ts             # opțional: Elasticsearch/OpenSearch
│       │   │   └── index.ts
│       │   ├── search/
│       │   │   ├── query.builder.ts           # câmpuri, ponderi, highlight
│       │   │   ├── facets.ts                  # taguri, tipuri, owner, date
│       │   │   └── index.ts
│       │   ├── permissions/
│       │   │   ├── models.ts                  # ACL: owner, role, user, link
│       │   │   ├── evaluator.ts               # canRead/canWrite/canShare
│       │   │   ├── sharing.ts                 # link securizat + expirare
│       │   │   └── index.ts
│       │   ├── registry/
│       │   │   ├── inbound.controller.ts      # registru intrări
│       │   │   ├── outbound.controller.ts     # registru ieșiri
│       │   │   ├── numbering.ts               # serii/numere
│       │   │   └── index.ts
│       │   ├── templates/
│       │   │   ├── models.ts                  # Template, Placeholder, DataMap
│       │   │   ├── renderer.ts                # render → PDF/Docx
│       │   │   ├── variables.ts               # variabile comune (tenant/user)
│       │   │   └── index.ts
│       │   ├── workflows/                     # aprobare/semnare/route
│       │   │   ├── temporal/
│       │   │   │   ├── definitions.ts         # workflow & activities
│       │   │   │   ├── activities/
│       │   │   │   │   ├── requestApproval.ts
│       │   │   │   │   ├── waitForSign.ts
│       │   │   │   │   └── notifyStakeholders.ts
│       │   │   │   └── workers.ts             # Temporal worker bootstrap
│       │   │   └── index.ts
│       │   ├── esign/
│       │   │   ├── pandadoc.adapter.ts        # create, send, webhook
│       │   │   ├── webhooks.controller.ts
│       │   │   └── index.ts
│       │   ├── audit/
│       │   │   ├── model.ts
│       │   │   ├── publisher.ts               # Kafka producer (topic: dms.audit)
│       │   │   └── index.ts
│       │   ├── events/
│       │   │   ├── topics.ts                  # dms.document.created, …
│       │   │   ├── producers.ts
│       │   │   ├── consumers.ts               # reacții (thumbnail, OCR)
│       │   │   └── index.ts
│       │   ├── trpc/
│       │   │   ├── routers/
│       │   │   │   ├── documents.router.ts    # CRUD, versiuni, share
│       │   │   │   ├── registry.router.ts
│       │   │   │   ├── templates.router.ts
│       │   │   │   ├── search.router.ts
│       │   │   │   ├── workflows.router.ts
│       │   │   │   └── esign.router.ts
│       │   │   ├── context.ts
│       │   │   └── index.ts
│       │   ├── openapi/
│       │   │   ├── schemas/
│       │   │   │   ├── document.schema.ts
│       │   │   │   ├── registry.schema.ts
│       │   │   │   ├── search.schema.ts
│       │   │   │   └── esign.schema.ts
│       │   │   ├── spec.ts                     # generator (tRPC ↔ OpenAPI 3)
│       │   │   └── docs.ts                     # UI Scalar/Swagger
│       │   ├── health/
│       │   │   ├── liveness.ts
│       │   │   └── readiness.ts
│       │   ├── telemetry/
│       │   │   ├── otel.ts                     # OTEL SDK init
│       │   │   └── pino.ts                     # logger
│       │   └── server.ts
│       └── Dockerfile
├── services/                                   # workers pentru joburi grele
│   ├── thumbnailer/
│   │   ├── src/{index.ts, worker.ts}          # ascultă evenimente dms.file.uploaded
│   │   └── Dockerfile
│   ├── ocr-worker/
│   │   ├── src/{index.ts, worker.ts}          # procesează coada OCR
│   │   └── Dockerfile
│   ├── converter/
│   │   ├── src/{index.ts, worker.ts}          # office→pdf, split/merge
│   │   └── Dockerfile
│   └── antivirus/
│       ├── src/{index.ts, worker.ts}
│       └── Dockerfile
├── db/
│   ├── drizzle/
│   │   ├── schema.ts
│   │   └── migrations/
│   ├── seeds/
│   │   └── seed.ts
│   └── scripts/
│       ├── migrate.sh
│       └── reset.sh
├── storage/
│   ├── buckets/
│   │   ├── originals/                        # fișiere brute
│   │   ├── thumbnails/
│   │   └── previews/
│   └── policy/
│       ├── retention.yaml                    # reguli ștergere/archivare
│       └── lifecycle.yaml
├── env/
│   ├── .env.example
│   ├── vault.template.hcl
│   └── README.md
├── compose/
│   ├── docker-compose.yml                     # api, web, workers, db, minio, clamav
│   ├── profiles/
│   │   ├── compose.dev.yml
│   │   ├── compose.staging.yml
│   │   └── compose.prod.yml
│   ├── Dockerfile.api
│   ├── Dockerfile.web
│   └── Dockerfile.worker
├── logs/
│   ├── .gitkeep
│   └── README.md
└── tests/
├── unit/
│   ├── permissions.evaluator.test.ts
│   ├── search.query.builder.test.ts
│   └── ocr.pipeline.test.ts
├── integration/
│   ├── documents.router.test.ts
│   └── upload.presign.test.ts
├── e2e/
│   └── flows.spec.ts                     # upload → OCR → index → search → share
└── fixtures/
├── pdfs/
├── images/
└── office/
```

### 2) Fluxuri funcționale cheie (overview)

- **Upload** (web → presign → S3/MinIO) → **antivirus** → **thumbnailer** → **OCR** (dacă e cazul) → **indexer** → disponibil în listare/căutare.
- **Share**: link securizat cu expirare/număr accesări, politicile ACL sunt verificate la fiecare acces.
- **Workflows**: aprobări/semnături orchestrate prin Temporal; Webhooks PandaDoc sincronizează starea.
- **Registry**: intrări/ieșiri cu serii numerice per tenant, export CSV/PDF.
- **Retention**: politici declarative per tip document, executate de joburi programate.

### 3) Securitate & Observabilitate

- Auth: PKCE→OIDC→JWT (SuperTokens/identity), RBAC + entitlements din CP/licensing.
- RLS/CLS: filtre la nivel de tenant/utilizator pentru interogări și căutări.
- OTEL: trace pentru upload/OCR/indexare; logs structurate (pino) + metrics (durate OCR, rata erori, dimensiune fișiere).

### 4) Integrare cu suita

- MF remote: `web` poate fi încărcat în `cp/suite-shell`.
- API: expune tRPC + OpenAPI; gateway-ul global poate compune rute și policy‑uri.
- Evenimente (Data Mesh): Publică "Produse de Date" (ex. dms.document.created, dms.document.ocr_extracted) pe Kafka, disponibile pentru consum de către cerniq.app și ai-hub`.'

## Capitolul 5 - `cerniq.app/` – Advanced Business Intelligence Hub (arhitectură și structuri detaliate)

> Scop: platformă Data Mesh & BI. Acționează ca un **consumator** inteligent de "Produse de Date" publicate de celelalte module (archify, numeriqo, i-wms etc.). Nu deține datele brute. Unifică aceste date într-un semantic layer centralizat pentru dashboards, AI și analiză predictivă.

### 1) Structură generală (6–7 niveluri, până la fișiere) – collectors → ingestion → transforms → warehouse → semantics → apis → dashboards → governance

```text
cerniq.app/
├── package.json
├── tsconfig.json
├── nx.json
├── README.md
├── env/
│   ├── .env.example                     # variabile mediu pentru toate serviciile
│   ├── vault.template.hcl               # șablon Vault/KMS pentru secrete
│   └── README.md
├── compose/
│   ├── docker-compose.yml               # orchestrare aplicație BI (api, workers, db)
│   ├── profiles/
│   │   ├── compose.dev.yml
│   │   ├── compose.staging.yml
│   │   └── compose.prod.yml
│   ├── Dockerfile.api
│   ├── Dockerfile.worker
│   ├── Dockerfile.scheduler
│   └── networks.yaml                    # rețele partajate (kafka, warehouse)
├── db/
│   ├── migrations/                      # migrații pentru metastore intern
│   ├── seeds/
│   │   └── seed.ts                      # KPI demo, dashboarduri demo
│   ├── drizzle/
│   │   ├── schema.ts                # metastore: sources, datasets, metrics, models
│   │   └── migrations/
│   └── drizzle/                         # (opțional) scheme partajate
├── data-product-consumers/    # Conectori la Data Products (Kafka/API)
│   ├── schemas/                       # Registru de scheme (contracte de date)
│   ├── numeriqo.consumer.ts   # Consumator pt. date financiare
│   ├── archify.consumer.ts        # Consumator pt. date documente
│   ├── iwms.consumer.ts          # Consumator pt. date stoc
│   └── index.ts
├── analytics-engine/                 # Motorul BI (ex. Cube.js, dbt pe date agregate)
│   ├── models/                          # Modele de date agregate
│   ├── cache.ts                         # Management cache agregate
│   └── index.ts
├── semantics/                            # semantic layer: metrici, dimensiuni
│   ├── metrics.yaml                      # definiții KPI: name, dimensions, formula
│   ├── dimensions.yaml                   # dimensiuni shareable (date, client…)
│   ├── entities.yaml                     # entități semantice (Deal, Invoice…)
│   ├── explorer.presets.yaml             # preseturi pentru UI explorer
│   └── validators.ts                     # validare metrici/dimensiuni
├── apis/                                 # interfețe interogare & expunere
│   ├── trpc/
│   │   ├── routers/
│   │   │   ├── metrics.router.ts        # calc KPI cu filtre/dimensiuni
│   │   │   ├── reports.router.ts        # rapoarte predefinite
│   │   │   ├── datasets.router.ts       # CRUD datasets/metastore
│   │   │   ├── lineage.router.ts        # data lineage
│   │   │   └── governance.router.ts     # RLS/CLS policies
│   │   ├── context.ts
│   │   └── index.ts
│   ├── rest/
│   │   ├── controllers/
│   │   │   ├── query.controller.ts      # /v1/query → SQL/semantic
│   │   │   ├── reports.controller.ts
│   │   │   └── health.controller.ts
│   │   ├── middleware/
│   │   │   ├── auth.ts                  # verify JWT + scopes + tenant
│   │   │   └── rateLimit.ts
│   │   ├── openapi/
│   │   │   ├── spec.ts                  # generator OpenAPI (Zod → OAS3)
│   │   │   └── docs.ts                  # UI (Scalar/Swagger)
│   │   └── index.ts
│   ├── sql-federation/
│   │   ├── gateway.ts                   # federare către PG/CH/DuckDB
│   │   ├── connectors/
│   │   │   ├── postgres.ts
│   │   │   ├── clickhouse.ts
│   │   │   └── duckdb.ts
│   │   ├── caching/
│   │   │   ├── queryCache.ts            # cache semantic + SQL
│   │   │   └── invalidation.ts          # pe bază de evenimente CDC
│   │   └── security/
│   │       ├── rls.ts                   # row‑level security la gateway
│   │       └── masking.ts               # column masking/obfuscation
│   └── index.ts
├── dashboards/                           # preseturi vizualizare (importabile)
│   ├── grafana/
│   │   ├── suite-health.json
│   │   ├── sales-overview.json
│   │   └── finance-kpis.json
│   ├── metabase/
│   │   └── *.json
│   └── superset/
│       └── assets/
├── governance/                           # guvernanță date & conformitate
│   ├── rls/
│   │   ├── policies.sql                  # politici row‑level security
│   │   └── tests.sql
│   ├── cls/
│   │   ├── masking.rules.yaml            # data masking pe coloane
│   │   └── pii.dictionary.yaml           # clasificare PII
│   ├── contracts/
│   │   ├── data-contracts.yaml           # contracte între producători/consumatori
│   │   └── schemas/                      # schemă per dataset publicat
│   ├── lineage/
│   │   ├── marbles.yaml                  # hartă fluxuri de date
│   │   └── exporters/
│   │       └── openlineage.ts            # trimite spre OpenLineage/Marquez
│   ├── catalog/
│   │   ├── glossary.yaml                 # termeni business
│   │   └── ownership.yaml                # owners, stewards, DPO
│   └── auditors/
│       ├── access.reports.ts             # rapoarte acces (conform GDPR)
│       └── retention.policies.ts         # păstrare/ștergere
├── telemetry/                            # observabilitate specifică BI
│   ├── otel.ts                            # init OTEL SDK
│   ├── pino.ts                            # logger structurat
│   └── metrics.ts                         # KPIs runtime (latency, cache hit)
├── security/                             # interfață cu CP/identity & licensing
│   ├── authz.ts                           # scopes → routes, entitlements checks
│   ├── tenants.ts                         # rezolvare tenant din subdomeniu
│   └── policies.ts                        # policy builders (RBAC/ABAC)
├── services/                             # workers specifice BI
│   ├── dq-worker/
│   │   ├── src/{index.ts, worker.ts}     # validează expectations → alerts
│   │   └── Dockerfile
│   ├── lineage-worker/
│   │   ├── src/{index.ts, worker.ts}     # calculează lineage & impact
│   │   └── Dockerfile
│   └── cache-worker/
│       ├── src/{index.ts, worker.ts}     # warm cache pt. rapoarte populare
│       └── Dockerfile
├── api/                                  # bootstrap Fastify v5.6.1/tRPC
│   ├── src/
│   │   ├── index.ts                      # server init + middlewares
│   │   ├── health.ts                     # liveness/readiness
│   │   ├── config/
│   │   │   ├── env.ts                    # schema zod + loader
│   │   │   └── security.ts               # CORS, helmet, rate-limit
│   │   ├── routes.ts                     # montează apis/* module
│   │   └── telemetry.ts
│   └── Dockerfile
├── tests/
│   ├── unit/
│   │   ├── metrics.router.test.ts
│   │   ├── quality.anomalies.test.ts
│   │   └── rls.masking.test.ts
│   ├── integration/
│   │   ├── dbt.models.test.ts            # rulează dbt + verifică rezultate
│   │   ├── federation.gateway.test.ts
│   │   └── ingestion.pipeline.test.ts
│   ├── e2e/
│   │   └── dashboards.spec.ts            # calc KPI → cache → dashboard
│   └── fixtures/
│       ├── csv/
│       ├── json/
│       └── sql/
└── docs/
├── architecture.md                   # diagrame (C4), fluxuri, zone
├── semantic-layer.md                 # convenții KPI/dimensiuni
├── governance.md                     # RLS/CLS, contracts, lineage
├── federation.md                     # gateway & caching
└── runbooks.md                       # proceduri operaționale
```

### 2) Fluxuri cheie

- **Consum Data Mesh**: Se abonează la "Produse de Date" publicate de modulele operaționale (ex. wms.stock_changed, numeriqo.invoice.paid).
- **Guvernanță**: Validează la intrare contractele de date (schemas) ale produselor consumate.
- **Semantic Layer**: Unifică produsele de date într-un model semantic central (metrics, dimensions), fără a muta datele brute.
- **Semantic layer** definește KPI/dimensiuni și controlează consistența rapoartelor.
- **Federation gateway** randează SQL sau calcule semantice, cu cache + invalidare CDC.
- **Governance**: RLS/CLS, data contracts, lineage (OpenLineage), catalog & ownership.

### 3) Securitate, multi-tenant & licențiere

- Integrare `cp/identity` (PKCE→JWT, scopes) + `cp/licensing` (entitlements la nivel metric/raport).
- RLS per tenant, masking pentru PII, audit acces & query.

### 4) Observabilitate

- OTEL (traces pentru query & transformări), logs structurate (pino), metrics runtime: cache hit ratio, query latency p95, job failures.

## Capitolul 6 - flowxify.app/ – Platformă de Orchestrare Inteligentă (BPM, AI, iPaaS, Collab)

Scop: Platformă de orchestrare inteligentă bazată pe o **Arhitectură Hibridă Dublă**:

- Nivel 2 (Inteligență No-Code): Agenți AI (CrewAI/LangGraph via cp/ai-hub) și Server MCP (Model Context Protocol) pentru brainstorming și orchestrare dinamică a proceselor.
- Nivel 1 (Orchestrare Code-First): BPM Durabil (Temporal) pentru **toate** procesele stateful (SLA-uri, aprobări, procese de lungă durată) și pentru execuția **fluxurilor customizate (serviciu monetizabil "BPM on-request")**.

### 1) Structură generală (6–7 niveluri, până la fișiere) – web + API + serviciiflowxify.app/

```text
├── package.json
├── tsconfig.json
├── nx.json
├── README.md
├── apps/
│   ├── web/                                   # Frontend React 19 (MF remote)
│   │   ├── vite.config.ts
│   │   ├── public/
│   │   │   └── manifest.webmanifest
│   │   └── src/
│   │       ├── main.tsx
│   │       ├── index.html
│   │       ├── routes/
│   │       │   ├── AppRoutes.tsx              # map pagini ↔ componente + guards
│   │       │   ├── paths.ts                   # constante URL (typed)
│   │       │   └── loaders.ts                 # pre‑fetch pentru pagini mari
│   │       ├── pages/
│   │       │   ├── Home.tsx                   # overview personal
│   │       │   ├── Tasks.tsx                  # listă + board (Kanban)
│   │       │   ├── Projects.tsx               # proiecte & spații echipă
│   │       │   ├── Messages.tsx               # DM/Channels (threaded)
│   │       │   ├── Intranet.tsx               # portal, anunțuri, quick links
│   │       │   ├── Wiki.tsx                   # pagini knowledge base
│   │       │   ├── Calendar.tsx               # calendar echipă, PTO sync
│   │       │   ├── Approvals.tsx              # Nivel 1/HITL: taskuri BPM pentru aprobare
│   │       │   ├── Settings.tsx
│   │       │   └── Admin.tsx                  # admin spații, membri, permisiuni
│   │       ├── features/
│   │       │   ├── tasks/
│   │       │   │   ├── components/
│   │       │   │   │   ├── TaskCard.tsx
│   │       │   │   │   ├── TaskModal.tsx
│   │       │   │   │   ├── Board.tsx         # Kanban: columns, drag & drop
│   │       │   │   │   ├── FiltersBar.tsx
│   │       │   │   │   └── BulkActions.tsx
│   │       │   │   ├── hooks/
│   │       │   │   │   ├── useTasks.ts        # tRPC queries + cache
│   │       │   │   │   ├── useBoard.ts        # reorder, WIP limits
│   │       │   │   │   └── useSubtasks.ts
│   │       │   │   ├── state/
│   │       │   │   │   ├── board.store.ts     # Zustand state machine
│   │       │   │   │   └── filters.store.ts
│   │       │   │   └── index.ts
│   │       │   ├── messages/
│   │       │   │   ├── components/
│   │       │   │   │   ├── ChannelList.tsx
│   │       │   │   │   ├── Thread.tsx
│   │       │   │   │   ├── Composer.tsx  # @mentions, emoji, uploads, AI Brainstorming (Nivel 3)
│   │       │   │   │   └── PresenceAvatars.tsx
│   │       │   │   ├── hooks/
│   │       │   │   │   ├── useChannels.ts
│   │       │   │   │   ├── useThread.ts
│   │       │   │   │   └── usePresence.ts     # websockets presence updates
│   │       │   │   ├── state/
│   │       │   │   │   ├── message.store.ts
│   │       │   │   │   └── channel.store.ts
│   │       │   │   └── index.ts
│   │       │   ├── wiki/
│   │       │   │   ├── components/
│   │       │   │   │   ├── PageEditor.tsx     # tiptap/markdown + slash menu
│   │       │   │   │   ├── PageTree.tsx
│   │       │   │   │   └── History.tsx        # versionare + diff
│   │       │   │   ├── hooks/useWiki.ts
│   │       │   │   └── index.ts
│   │       │   ├── intranet/
│   │       │   │   ├── components/
│   │       │   │   │   ├── NewsFeed.tsx
│   │       │   │   │   ├── QuickLinks.tsx
│   │       │   │   │   └── OrgDirectory.tsx   # angajați + echipe (from numeriqo)
│   │       │   │   ├── hooks/useIntranet.ts
│   │       │   │   └── index.ts
│   │       │   ├── approvals/
│   │       │   │   ├── components/ApprovalList.tsx
│   │       │   │   ├── hooks/useApprovals.ts
│   │       │   │   └── index.ts
│   │       │   └── index.ts
│   │       ├── api/
│   │       │   ├── client.ts                    # tRPC/OpenAPI client
│   │       │   └── interceptors.ts              # attach JWT, retry
│   │       ├── providers/
│   │       │   ├── AuthProvider.tsx             # shared/auth-client
│   │       │   ├── ThemeProvider.tsx
│   │       │   └── QueryProvider.tsx
│   │       ├── i18n/
│   │       │   ├── ro/translation.json
│   │       │   ├── en/translation.json
│   │       │   └── i18n.ts
│   │       └── styles/index.css
│   └── api/                                   # Backend Fastify v5.6.1 + tRPC + OpenAPI
│       ├── src/
│       │   ├── index.ts                       # bootstrap, middlewares
│       │   ├── config/
│       │   │   ├── env.ts                     # zod schema + loader
│       │   │   └── security.ts                # CORS, helmet, rate‑limit
│       │   ├── auth/
│       │   │   ├── requireAuth.ts             # JWT verify (cp/identity)
│       │   │   ├── requireScope.ts
│       │   │   ├── requireEntitlement.ts      # cp/licensing integration
│       │   │   └── rbac.ts                    # guards pe resurse/owner
│       │   ├── db/
│       │   │   ├── drizzle/
│       │   │   │   ├── schema.ts          # Tasks, Projects, Channels, Messages, WikiPages
│       │   │   │   └── migrations/
│       │   │   └── index.ts                   # drizzle ORM + telemetry
│       │   ├── messaging/
│       │   │   ├── ws.gateway.ts              # WebSocket/SSE gateway
│       │   │   ├── presence.service.ts        # online/offline, typing
│       │   │   ├── attachments/
│       │   │   │   ├── s3.adapter.ts          # upload/virus scan via archify stack
│       │   │   │   └── policy.ts
│       │   │   └── index.ts
│       │   ├── collab/
│       │   │   ├── tasks.controller.ts        # CRUD task/subtask + board ops
│       │   │   ├── projects.controller.ts
│       │   │   ├── comments.controller.ts     # threaded comments
│       │   │   └── index.ts
│       │   ├── wiki/
│       │   │   ├── pages.controller.ts        # CRUD + versionare
│       │   │   ├── search.controller.ts       # full-text (PG tsvector)
│       │   │   └── index.ts
│       │   ├── intranet/
│       │   │   ├── news.controller.ts         # anunțuri, pinning, targeting
│       │   │   ├── directory.controller.ts    # employee directory (sync numeriqo)
│       │   │   └── links.controller.ts        # quick links per org
│       │   ├── approvals/
│       │   │   ├── tasks.controller.ts        # taskuri BPM (Nivel 1) waiting for user
│       │   │   └── index.ts
│       │   ├── agents/                            # NOU: Nivel 3 (Inteligență)
│       │   │   ├── mcp.server.ts                # Server MCP (Model Context Protocol)
│       │   │   ├── mcp.tools.ts                 # Definirea uneltelor (Tools)
│       │   │   ├── adapters/
│       │   │   │   ├── temporal.tool.ts         # tool_start_temporal_workflow
│       │   │   │   └── collab.tool.ts           # tool_create_human_task
│       │   │   └── index.ts
│       │   ├── trpc/
│       │   │   ├── routers/
│       │   │   │   ├── tasks.router.ts
│       │   │   │   ├── projects.router.ts
│       │   │   │   ├── messages.router.ts
│       │   │   │   ├── wiki.router.ts
│       │   │   │   ├── intranet.router.ts
│       │   │   │   ├── approvals.router.ts      # (Nivel 1/HITL)
│       │   │   │   ├── agents.router.ts         # (NOU: Nivel 3)
│       │   │   │   └── search.router.ts
│       │   │   ├── context.ts
│       │   │   └── index.ts
│       │   ├── openapi/
│       │   │   ├── schemas/
│       │   │   │   ├── task.schema.ts
│       │   │   │   ├── message.schema.ts
│       │   │   │   ├── wiki.schema.ts
│       │   │   │   ├── intranet.schema.ts
│       │   │   │   └── agent.schema.ts        # (NOU: Nivel 3)
│       │   │   ├── spec.ts                     # generator (tRPC ↔ OpenAPI 3)
│       │   │   └── docs.ts                     # UI Scalar/Swagger
│       │   ├── notifications/
│       │   │   ├── engine.ts                   # rules: @mention, assign, due soon
│       │   │   ├── channels/
│       │   │   │   ├── inapp.ts                # inbox intern
│       │   │   │   ├── email.ts                # via shared/integrations/comms
│       │   │   │   └── push.ts                 # web push
│       │   │   └── templates/                  # Handlebars MJML/HTML
│       │   ├── telemetry/
│       │   │   ├── otel.ts                     # OTEL SDK init
│       │   │   └── pino.ts                     # logger
│       │   └── server.ts
│       └── Dockerfile
├── bpm/                                         # Nivel 1: Procese & workflow‑uri (Temporal)
│   ├── definitions/
│   │   ├── approvals.workflow.ts                # generic approval (n‑steps)
│   │   ├── document.workflow.ts                 # arhivare/semnare (cu archify)
│   │   ├── onboarding.workflow.ts               # hire onboarding (numeriqo)
│   │   ├── incident.workflow.ts                 # incident mgmt (ops)
│   │   └── sla.workflow.ts                      # SLA watcher + escalations
│   ├── activities/
│   │   ├── notifyAssignee.ts
│   │   ├── waitForSignal.ts                     # Punctul de așteptare HITL
│   │   ├── fetchUserData.ts                     # din identity/numeriqo
│   │   ├── writeAuditEvent.ts                   # Kafka → cerniq
│   │   └── updateExternal.ts                    # webhook către apps externe
│   ├── workers/
│   │   ├── approvals.worker.ts                  # procesează taskuri approvals
│   │   ├── document.worker.ts
│   │   ├── onboarding.worker.ts
│   │   └── index.ts
│   ├── clients/
│   │   ├── temporal.client.ts                   # init Temporal connection
│   │   └── index.ts
│   └── README.md
├── services/                                     # worker services pentru realtime & jobs
│   ├── realtime-gateway/
│   │   ├── src/
│   │   │   ├── index.ts                         # WS/SSE entry (fanout)
│   │   │   ├── adapters/
│   │   │   │   ├── redis.pubsub.ts              # presence/fanout
│   │   │   │   └── kafka.ts                     # stream events → clients
│   │   │   ├── auth.ts                          # JWT validate (tenant aware)
│   │   │   └── telemetry.ts
│   │   └── Dockerfile
│   ├── notifications-worker/
│   │   ├── src/{index.ts, worker.ts}
│   │   └── Dockerfile
│   └── search-indexer/
│       ├── src/{index.ts, worker.ts}            # denormalize → PG FTS
│       └── Dockerfile
├── db/
│   ├── drizzle/
│   │   ├── schema.ts
│   │   └── migrations/
│   ├── seeds/
│   │   └── seed.ts
│   └── scripts/
│       ├── migrate.sh
│       └── reset.sh
├── env/
│   ├──.env.example
│   ├── vault.template.hcl
│   └── README.md
├── compose/
│   ├── docker-compose.yml                     # api, web, realtime, db, redis, temporal
│   ├── profiles/
│   │   ├── compose.dev.yml
│   │   ├── compose.staging.yml
│   │   └── compose.prod.yml
│   ├── Dockerfile.api
│   ├── Dockerfile.web
│   └── Dockerfile.worker
├── logs/
│   ├──.gitkeep
│   └── README.md
└── tests/
├── unit/
│   ├── tasks.board.test.ts
│   ├── messages.thread.test.ts
│   ├── wiki.versioning.test.ts
│   └── mcp.server.test.ts                 # NOU
├── integration/
│   ├── approvals.router.test.ts
│   ├── websocket.gateway.test.ts
│   └── temporal.activities.test.ts
├── e2e/
│   └── collab-flows.spec.ts              # create task → assign → @mention → approve
└── fixtures/
├── wiki/
├── messages/
└── tasks/
```

### 2) Fluxuri funcționale cheie (Arhitectură Hibridă Triplă)

- **Nivel 3: Brainstorming (No-Code AI)**:
Utilizatorul (în Collab/Chat 1) cere un proces ("Aprobare factură"). Agentul AI (din cp/ai-hub 1) interpretează cererea, folosește MCP pentru a apela tool_start_temporal_workflow, și pornește un workflow de Nivel 1.
- **Nivel 1: Execuție Durabilă (Code-First - Temporal)**:
Workflow-ul pornit la Nivelul 3 rulează. Acesta execută pași critici (ex. verifică suma în numeriqo.app).
- **Nivel 1 -> HITL (Human-in-the-Loop)**:
Workflow-ul Temporal ajunge la pasul de aprobare. Apelează tool_create_human_task (via MCP sau o activitate directă). Un task nou apare în Tasks.tsx (Kanban). Workflow-ul Temporal intră în "așteptare" (sleep).
- **HITL -> Nivel 1**:
Managerul aprobă task-ul în UI. Acțiunea trimite un semnal workflow-ului Temporal aflat în așteptare, care se "trezește" și continuă.
- **Unificarea Orchestrării Toate execuțiile**
Atât cele inițiate de AI-Nivel 3, cât și cele predefinite, rulează exclusiv pe motorul Temporal (Nivel 1). Integrările non-critice (ex. "Postează un mesaj pe Slack") sunt executate ca activități Temporal standard, nu printr-un sistem iPaaS separat, asigurând o orchestrare cu stare unificată.

### 3) Securitate & Multi‑tenant

- PKCE→OIDC→JWT (cp/identity), RBAC + entitlements (cp/licensing) pentru spații/proiecte/canale.
- RLS pe tabele (tenant_id + membership), audit evenimente (Kafka → cerniq).
- Serverul MCP aplică aceleași politici de autorizare, asigurând că agenții AI nu pot executa acțiuni nepermise utilizatorului.

### 4) Observabilitate flowxify

- OTEL (traces pentru WS, workflows, DB), logs structurate, metrics: message fanout latency, WS connections, task cycle time, approval SLA breachs.
- NOU: Metrics pentru Nivelul 3 (timp de răspuns agent AI, utilizare unelte MCP).

### 5) Integrare cu restul suitei

- MF remote: web poate fi încărcat în cp/suite-shell.
- API: tRPC + OpenAPI; gateway global compune rute și policies.Integrare AI (Nivel 3): Consumator principal al cp/ai-hub (Cap 3) (pt. agenți LangGraph/CrewAI). Expune un Server MCP cu "unelte" (tools) pentru a orchestra Nivelul 1 și 2.
- Servicii BPM On-Request: Expune API-uri pentru serviciul monetizabil de dezvoltare fluxuri customizate pe Temporal, permițând clienților să solicite și să monitorizeze noi automatizări.
- Evenimente: Kafka (collab.task.created, chat.message.posted, bpm.approval.pending, agent.flow.generated).

## Capitolul 7 - i-wms.app/ – Warehouse & Inventory (arhitectură și structuri detaliate)

Scop: WMS multi‑depozit, multi‑tenant, cu optimizare AI (slotting dinamic, prognoză cerere, planificare picking), orchestrare WES (roboți & forță de muncă), recepții (ASN), NIR românesc, putaway ghidat, picking (Single/Multi/Batch/Wave/Streaming), FEFO/FIFO, lot/serie/expirări, inventariere (cycle count), packing, etichetare (ZPL), expediții (curieri RO), transferuri inter‑depozit, 3PL billing și sincronizare e‑commerce/OMS/POS.

### 1) Structură generală (6–7 niveluri, până la fișiere) – web + API + servicii + RF

```text
i-wms.app/
├── package.json
├── tsconfig.json
├── nx.json
├── README.md
├── apps/
│   ├── web/                                   # Frontend React 19 (MF remote)
│   │   ├── vite.config.ts
│   │   ├── public/
│   │   │   └── manifest.webmanifest
│   │   └── src/
│   │       ├── main.tsx
│   │       ├── index.html
│   │       ├── routes/
│   │       │   ├── AppRoutes.tsx              # map pagini ↔ componente + guards
│   │       │   ├── paths.ts                   # constante URL (typed)
│   │       │   └── loaders.ts                 # pre‑fetch pentru pagini mari
│   │       ├── pages/
│   │       │   ├── Dashboard.tsx              # KPIs: inbound/outbound, SLAs, AI accuracy
│   │       │   ├── Inbound.tsx                # ASN, recepții, NIR
│   │       │   ├── Putaway.tsx                # taskuri putaway ghidat (AI suggested)
│   │       │   ├── Inventory.tsx              # stoc, loturi, serie, expirări
│   │       │   ├── SlottingAI.tsx             # recomandări optimizare AI (dinamic)
│   │       │   ├── WavePlanner.tsx            # planificare valuri / streaming AI
│   │       │   ├── Robotics.tsx               # NOU: monitorizare flotă WES
│   │       │   ├── Packing.tsx                # colete, volumetrie, etichete
│   │       │   ├── Shipping.tsx               # curieri, AWB, tracking
│   │       │   ├── Transfers.tsx              # inter‑warehouse
│   │       │   ├── CycleCount.tsx             # inventariere ciclică
│   │       │   ├── 3PLBilling.tsx             # tarife, servicii, invoice export
│   │       │   ├── Settings.tsx               # depozite, zone, locații, reguli AI
│   │       │   └── Admin.tsx                  # utilizatori, roluri, permisiuni
│   │       ├── features/
│   │       │   ├── inbound/
│   │       │   │   ├── components/
│   │       │   │   │   ├── AsnTable.tsx
│   │       │   │   │   ├── ReceiptForm.tsx    # recepție + generare NIR
│   │       │   │   │   ├── NIRPreview.tsx     # previzualizare NIR (RO)
│   │       │   │   │   └── SupplierSelect.tsx
│   │       │   │   ├── hooks/useInbound.ts
│   │       │   │   └── index.ts
│   │       │   ├── inventory/
│   │       │   │   ├── components/
│   │       │   │   │   ├── StockTable.tsx
│   │       │   │   │   ├── LotBadge.tsx
│   │       │   │   │   ├── SerialList.tsx
│   │       │   │   │   └── ExpiryGauge.tsx
│   │       │   │   ├── hooks/useInventory.ts
│   │       │   │   └── index.ts
│   │       │   ├── picking/
│   │       │   │   ├── components/
│   │       │   │   │   ├── WaveBoard.tsx      # vizualizare valuri/streaming
│   │       │   │   │   ├── PickList.tsx
│   │       │   │   │   ├── ScannerInput.tsx
│   │       │   │   │   └── ToteAssignment.tsx
│   │       │   │   ├── hooks/usePicking.ts
│   │       │   │   └── index.ts
│   │       │   ├── slotting/                  # NOU: feature UI pt. AI slotting
│   │       │   │   ├── components/
│   │       │   │   │   ├── SlottingHeatmap.tsx
│   │       │   │   │   ├── RecommendationList.tsx # recomandări de mutare
│   │       │   │   │   └── ModelInputs.tsx      # configurare (velocity, affinity)
│   │       │   │   ├── hooks/useSlottingAI.ts
│   │       │   │   └── index.ts
│   │       │   ├── packing/
│   │       │   │   ├── components/
│   │       │   │   │   ├── PackingStation.tsx
│   │       │   │   │   ├── DimWeightForm.tsx
│   │       │   │   │   └── LabelPreview.tsx
│   │       │   │   ├── hooks/usePacking.ts
│   │       │   │   └── index.ts
│   │       │   ├── shipping/
│   │       │   │   ├── components/
│   │       │   │   │   ├── ShipmentTable.tsx
│   │       │   │   │   ├── CarrierSelect.tsx
│   │       │   │   │   └── TrackingTimeline.tsx
│   │       │   │   ├── hooks/useShipping.ts
│   │       │   │   └── index.ts
│   │       │   └── index.ts
│   │       ├── api/
│   │       │   ├── client.ts                    # tRPC/OpenAPI client
│   │       │   └── interceptors.ts              # attach JWT, retry
│   │       ├── providers/
│   │       │   ├── AuthProvider.tsx             # shared/auth-client
│   │       │   ├── ThemeProvider.tsx
│   │       │   └── QueryProvider.tsx
│   │       ├── i18n/
│   │       │   ├── ro/translation.json
│   │       │   ├── en/translation.json
│   │       │   └── i18n.ts
│   │       └── styles/index.css
│   └── api/                                   # Backend Fastify v5.6.1 + tRPC + OpenAPI
│       ├── src/
│       │   ├── index.ts                       # bootstrap, middlewares
│       │   ├── config/
│       │   │   ├── env.ts                     # zod schema + loader
│       │   │   └── security.ts                # CORS, helmet, rate‑limit
│       │   ├── auth/
│       │   │   ├── requireAuth.ts             # JWT verify (cp/identity)
│       │   │   ├── requireScope.ts
│       │   │   ├── requireEntitlement.ts      # cp/licensing integration
│       │   │   └── rbac.ts                    # guards pe resurse/owner
│       │   ├── db/
│       │   │   ├── drizzle/
│       │   │   │   ├── schema.ts          # depozite, zone, locații, stoc, lot/serie, ASN, NIR, pick/pack/ship
│       │   │   │   └── migrations/
│       │   │   └── index.ts                   # drizzle ORM + telemetry
│       │   ├── domain/
│       │   │   ├── models/
│       │   │   │   ├── Warehouse.ts           # depozit, adrese, parametri
│       │   │   │   ├── Zone.ts                # recepție, stoc, picking, buffer
│       │   │   │   ├── Location.ts            # bin/raft, capacitate, dim
│       │   │   │   ├── Product.ts             # produs
│       │   │   │   ├── Sku.ts                 # SKU
│       │   │   │   ├── StockItem.ts           # stoc granular (lot/serie/exp)
│       │   │   │   ├── Batch.ts               # lot
│       │   │   │   ├── Serial.ts              # serie
│       │   │   │   ├── Asn.ts                 # aviz expediție furnizor
│       │   │   │   ├── Receipt.ts             # recepție
│       │   │   │   ├── Nir.ts                 # NIR (RO)
│       │   │   │   ├── PutawayTask.ts
│       │   │   │   ├── PickTask.ts
│       │   │   │   ├── Wave.ts                # (devine container pt. streaming)
│       │   │   │   ├── Shipment.ts
│       │   │   │   ├── CarrierLabel.ts        # etichete AWB
│       │   │   │   ├── Transfer.ts            # inter‑warehouse
│       │   │   │   ├── Adjustment.ts          # corecție stoc
│       │   │   │   ├── CycleCount.ts
│       │   │   │   ├── ReplenishmentRule.ts   # (include acum ML forecast)
│       │   │   │   ├── SlottingProfile.ts     # (include acum AI affinity)
│       │   │   │   └── index.ts
│       │   │   ├── rules/
│       │   │   │   ├── allocation.ts          # FEFO/FIFO/LIFO, lot/serie
│       │   │   │   ├── putaway.ai.ts          # AI: reguli plasare pe zone/locații (vs. static)
│       │   │   │   ├── picking.ai.ts          # AI: single/batch/streaming/zone (dynamic path)
│       │   │   │   ├── replenishment.ai.ts    # AI: ML forecast vs. min/max
│       │   │   │   ├── packing.ts             # cutii, volumetrie, multi‑order
│       │   │   │   └── slotting.ai.ts         # NOU: reguli AI (velocity, affinity, seasonality)
│       │   │   ├── services/
│       │   │   │   ├── asn.service.ts
│       │   │   │   ├── receipt.service.ts
│       │   │   │   ├── putaway.ai.service.ts  # (apelează AI-Slotting-Optimizer)
│       │   │   │   ├── picking.ai.service.ts  # (apelează AI-Wave-Planner)
│       │   │   │   ├── packing.service.ts
│       │   │   │   ├── shipping.service.ts
│       │   │   │   ├── cyclecount.service.ts
│       │   │   │   ├── replenishment.ai.service.ts # (apelează AI-Replenishment)
│       │   │   │   ├── slotting.ai.service.ts # (apelează AI-Slotting-Optimizer)
│       │   │   │   └── wes.service.ts         # NOU: (apelează WES-Orchestrator)
│       │   ├── documents/
│       │   │   ├── nir.renderer.ts            # generează NIR PDF (RO)
│       │   │   ├── aviz.renderer.ts           # aviz însoțire marfă (RO)
│       │   │   └── label.renderer.ts          # ZPL/ePL2
│       │   ├── integrations/
│       │   │   ├── ai/                          # NOU: Conector către AI Hub central
│       │   │   │   └── cp.ai-hub.adapter.ts   # (client pt. modele RAG/Agent/ML)
│       │   │   ├── carriers/
│       │   │   │   ├── sameday.adapter.ts
│       │   │   │   ├── fancourier.adapter.ts
│       │   │   │   ├── cargus.adapter.ts
│       │   │   │   └── dhl.adapter.ts         # extensibil
│       │   │   ├── commerce/
│       │   │   │   ├── shopify.adapter.ts     # sync comenzi/stoc
│       │   │   │   ├── woocommerce.adapter.ts
│       │   │   │   └── marketplace.adapter.ts # eMAG, Amazon (mapper)
│       │   │   ├── pos/
│       │   │   │   └── pos.adapter.ts         # integrare POS (read/write)
│       │   │   ├── erp/
│       │   │   │   └── numeriqo.adapter.ts    # documente & contabile
│       │   │   └── archify/
│       │   │       └── attachment.adapter.ts  # atașamente
│       │   ├── search/
│       │   │   ├── query.builder.ts           # FTS pentru SKU/lot/locații
│       │   │   └── index.ts
│       │   ├── trpc/
│       │   │   ├── routers/
│       │   │   │   ├── inbound.router.ts      # ASN, recepții, NIR
│       │   │   │   ├── inventory.router.ts    # stoc, lot, serie
│       │   │   │   ├── tasks.router.ts        # putaway/pick/pack
│       │   │   │   ├── shipping.router.ts     # AWB, tracking
│       │   │   │   ├── transfers.router.ts
│       │   │   │   ├── counts.router.ts       # cycle counts
│       │   │   │   ├── rules.router.ts        # (acum include reguli AI)
│       │   │   │   └── optimization.router.ts # NOU: (expune rezultate AI-Slotting/Wave)
│       │   │   ├── context.ts
│       │   │   └── index.ts
│       │   ├── openapi/
│       │   │   ├── schemas/
│       │   │   │   ├── inbound.schema.ts
│       │   │   │   ├── inventory.schema.ts
│       │   │   │   ├── shipping.schema.ts
│       │   │   │   ├── rules.schema.ts
│       │   │   │   └── optimization.schema.ts # NOU
│       │   │   ├── spec.ts                     # generator (tRPC ↔ OpenAPI 3)
│       │   │   └── docs.ts                     # UI Scalar/Swagger
│       │   ├── telemetry/
│       │   │   ├── otel.ts                     # OTEL SDK init
│       │   │   └── pino.ts                     # logger
│       │   ├── health/
│       │   │   ├── liveness.ts
│       │   │   └── readiness.ts
│       │   └── server.ts
│       └── Dockerfile
├── rf-terminal/                                # PWA RF (mânere/scaner) pentru operațiuni teren
│   ├── web/
│   │   ├── src/
│   │   │   ├── pages/
│   │   │   │   ├── SignIn.tsx
│   │   │   │   ├── Receive.tsx                 # recepție + scan
│   │   │   │   ├── Putaway.tsx                 # ghidat (AI optimized path)
│   │   │   │   ├── Pick.tsx                    # listă pick + validare scan (AI optimized path)
│   │   │   │   ├── Pack.tsx
│   │   │   │   └── Ship.tsx
│   │   │   ├── components/Scanner.tsx          # WebUSB/WebBluetooth/Keyboard wedge
│   │   │   ├── hooks/useScanner.ts
│   │   │   ├── hooks/useHaptics.ts             # feedback haptic (unde suportat)
│   │   │   └── main.tsx
│   │   └── vite.config.ts
│   └── api/
│       └── edge.ts                              # endpoints optimizate pt.
latență
├── services/                                    # workers specializați (ACTUALIZAT pt. AI)
│   ├── ai-wave-planner/                         # (fost: wave-planner)
│   │   ├── src/
│   │   │   ├── index.ts
│   │   │   ├── planner.ts                       # planificare dinamică (order streaming) vs. valuri statice
│   │   │   └── models/
│   │   │       └── cp.ai-hub.client.ts          # (client către cp/ai-hub)
│   │   └── Dockerfile
│   ├── ai-slotting-optimizer/                   # (fost: slotting-optimizer)
│   │   ├── src/
│   │   │   ├── index.ts
│   │   │   ├── optimizer.ts                     # rulează modele (affinity, velocity, seasonality)
│   │   │   └── models/
│   │   │       └── cp.ai-hub.client.ts          # (client către cp/ai-hub)
│   │   └── Dockerfile
│   ├── ai-replenishment/                        # (fost: replenishment)
│   │   ├── src/
│   │   │   ├── index.ts
│   │   │   ├── worker.ts                        # ML demand forecast vs. min/max
│   │   │   └── models/
│   │   │       └── cp.ai-hub.client.ts          # (client către cp/ai-hub)
│   │   └── Dockerfile
│   ├── wes-orchestrator/                        # NOU: Warehouse Execution System
│   │   ├── src/
│   │   │   ├── index.ts
│   │   │   ├── orchestrator.ts                  # orchestrator roboți & forță de muncă
│   │   │   └── agents/
│   │   │       └── supervisor.agent.ts          # Agent AI (via cp/ai-hub) pt. alocare dinamică
│   │   └── Dockerfile
│   ├── labeler/
│   │   ├── src/{index.ts, zpl.ts}              # șabloane ZPL + rasterizare
│   │   └── Dockerfile
│   ├── cyclecount/
│   │   ├── src/{index.ts, worker.ts}
│   │   └── Dockerfile
│   └── dispatcher/
│       ├── src/{index.ts, worker.ts}           # distribuie taskuri RF
│       └── Dockerfile
├── printers/                                    # drivere & spooler etichete
│   ├── zpl/
│   │   ├── templates/
│   │   │   ├── shipping.label.zpl
│   │   │   ├── tote.label.zpl
│   │   │   └── location.label.zpl
│   │   ├── encoder.ts                          # text → ZPL
│   │   └── index.ts
│   └── spooler/
│       ├── network.ts                           # TCP/9100 print
│       ├── usb.ts                                # WebUSB
│       └── index.ts
├── db/
│   ├── drizzle/
│   │   ├── schema.ts
│   │   └── migrations/
│   ├── seeds/
│   │   └── seed.ts
│   └── scripts/
│       ├── migrate.sh
│       └── reset.sh
├── analytics/
│   ├── kpis/                                    # definiri KPI pentru WMS
│   │   ├── inbound.yaml      # lead time recepții, acuratețe recepție
│   │   ├── outbound.yaml     # pick rate, order cycle time, OTIF
│   │   ├── inventory.yaml    # acuratețe stoc, shrinkage
│   │   ├── productivity.yaml # UPH, LPH, utilizare stații
│   │   └── ai-optimization.yaml # NOU: acuratețe forecast, % optimizare slotting
│   ├── exporters/
│   │   └── events.publisher.ts                  # Kafka → cerniq.app
│   └── dashboards/
│       └── grafana/*.json
├── env/
│   ├──.env.example
│   ├── vault.template.hcl
│   └── README.md
├── compose/
│   ├── docker-compose.yml                        # api, web, rf, db, redis, workers (AI)
│   ├── profiles/
│   │   ├── compose.dev.yml
│   │   ├── compose.staging.yml
│   │   └── compose.prod.yml
│   ├── Dockerfile.api
│   ├── Dockerfile.web
│   ├── Dockerfile.worker                         # (acum include AI workers)
│   └── Dockerfile.rf
├── logs/
│   ├──.gitkeep
│   └── README.md
└── tests/
├── unit/
│   ├── allocation.rules.test.ts
│   ├── putaway.ai.rules.test.ts             # ACTUALIZAT
│   ├── picking.ai.rules.test.ts             # ACTUALIZAT
│   ├── replenishment.ai.rules.test.ts       # NOU
│   ├── nir.renderer.test.ts
│   └── wes.orchestrator.test.ts             # NOU
├── integration/
│   ├── inbound.router.test.ts
│   ├── shipping.router.test.ts
│   ├── labels.zpl.test.ts
│   └── ai-hub.wms.adapter.test.ts           # NOU
├── e2e/
│   └── wms-ai-flows.spec.ts                 # ACTUALIZAT: ASN→AI-Putaway→AI-Pick→Pack→Ship
└── fixtures/
├── zpl/
├── csv/
└── json/
```

### 2) Fluxuri funcționale cheie (Actualizat cu AI)

- Inbound: ASN → recepție → NIR (RO) → putaway ghidat (AI slotting & capacități).
- Inventory: stoc granular (lot/serie/exp), RLS per tenant & depozit, transferuri, ajustări, cycle counts.
- Outbound: AI wave planning (order streaming) → picking optimizat (zone/batch/path) → packing (dim weight) → etichete curier → tracking.
- Replenishment: AI Demand Forecast (bazat pe cp/ai-hub ) vs. reguli min/max statice, tasking automat.
- Orchestrare WES: NOU: Alocare dinamică a taskurilor (roboți & operatori) prin Agent AI Supervisor (conectat la cp/ai-hub ).
- 3PL: servicii tarifabile, rate cards, export facturi către numeriqo.app.

### 3) Securitate & Multi‑tenant i-wms

- PKCE→OIDC→JWT (cp/identity), RBAC + entitlements (cp/licensing) pe depozit/zonă.
- Audit evenimente operaționale → Kafka (cerniq.app).

### 4) Observabilitate i-wms

OTEL (traces pentru RF, picking, carriers, AI models), logs structurate, metrics: UPH/LPH, lead time inbound/outbound, acuratețe stoc, acuratețe prognoză AI.

### 5) Integrare cu suita

- MF remote: apps/web poate fi încărcat în cp/suite-shell.
-API: tRPC + OpenAPI; gateway global compune rute și policies.
-Integrare AI: Consumator principal al cp/ai-hub (Cap 3)  pentru modele de prognoză, optimizare și agenți.
-Evenimente: Kafka (wms.inbound.received, wms.pick.completed, wms.shipped, wms.ai.recommendation.generated).

## Capitolul 8 - `mercantiq.app/` – Commerce & Sales Ops (arhitectură și structuri detaliate)

> Scop: aplicație stand‑alone pentru cataloage produse, cotații/ofertare B2B, coș/checkout, comenzi, plăți, promoții, prețuri dinamice, integrare marketplace & e‑commerce, sincron stoc (cu `i-wms.app`), facturare *lite* (export spre `numeriqo.app`), CRM & lead hand‑off (`vettify.app`), asistent AI pentru oferte și recomandări. Multi‑tenant, RBAC & entitlements prin `cp/identity`/`cp/licensing`.

### 1) Structură generală (6–7 niveluri, până la fișiere) – web + API + engines + services

```text
mercantiq.app/
├── package.json
├── tsconfig.json
├── nx.json
├── README.md
├── apps/
│   ├── web/                                   # Frontend React 19 (MF remote)
│   │   ├── vite.config.ts
│   │   ├── public/
│   │   │   └── manifest.webmanifest
│   │   └── src/
│   │       ├── main.tsx
│   │       ├── index.html
│   │       ├── routes/
│   │       │   ├── AppRoutes.tsx              # map pagini ↔ componente + guards
│   │       │   ├── paths.ts
│   │       │   └── loaders.ts
│   │       ├── pages/
│   │       │   ├── Catalog.tsx                # browsare produse + filtre
│   │       │   ├── Product.tsx                # PDP: preț, stoc, atribute
│   │       │   ├── Quotes.tsx                 # listă cotații + status
│   │       │   ├── QuoteBuilder.tsx           # configurator ofertă B2B
│   │       │   ├── Cart.tsx                   # coș, cupon, taxe, shipping
│   │       │   ├── Checkout.tsx               # checkout + 3DS, invoicing lite
│   │       │   ├── Orders.tsx                 # istoric comenzi
│   │       │   ├── Customers.tsx              # clienți B2B (sync cu Vettify)
│   │       │   ├── Analytics.tsx              # vânzări, conversii, funnel
│   │       │   ├── Settings.tsx               # plăți, taxe, shipping, canale
│   │       │   └── Admin.tsx                  # catalog mgmt, promoții, liste preț
│   │       ├── features/
│   │       │   ├── catalog/
│   │       │   │   ├── components/
│   │       │   │   │   ├── ProductCard.tsx
│   │       │   │   │   ├── FiltersBar.tsx
│   │       │   │   │   ├── VariantSelector.tsx
│   │       │   │   │   └── PriceBlock.tsx     # afișare preț (listă/negociat)
│   │       │   │   ├── hooks/useCatalog.ts
│   │       │   │   └── index.ts
│   │       │   ├── quote/
│   │       │   │   ├── components/
│   │       │   │   │   ├── QuoteLine.tsx
│   │       │   │   │   ├── DiscountEditor.tsx
│   │       │   │   │   ├── ShippingEstimator.tsx
│   │       │   │   │   └── ApprovalsTimeline.tsx
│   │       │   │   ├── hooks/useQuote.ts
│   │       │   │   └── index.ts
│   │       │   ├── cart/
│   │       │   │   ├── components/{CartTable.tsx,Summary.tsx,CouponBox.tsx}
│   │       │   │   ├── hooks/useCart.ts
│   │       │   │   └── index.ts
│   │       │   ├── checkout/
│   │       │   │   ├── components/{PaymentMethods.tsx,AddressForm.tsx}
│   │       │   │   ├── hooks/useCheckout.ts
│   │       │   │   └── index.ts
│   │       │   ├── customers/
│   │       │   │   ├── components/{CustomerTable.tsx,AccountForm.tsx}
│   │       │   │   ├── hooks/useCustomers.ts
│   │       │   │   └── index.ts
│   │       │   └── index.ts
│   │       ├── api/
│   │       │   ├── client.ts                    # tRPC/OpenAPI client
│   │       │   └── interceptors.ts              # attach JWT, retry
│   │       ├── providers/
│   │       │   ├── AuthProvider.tsx             # shared/auth-client
│   │       │   ├── ThemeProvider.tsx
│   │       │   └── QueryProvider.tsx
│   │       ├── i18n/
│   │       │   ├── ro/translation.json
│   │       │   ├── en/translation.json
│   │       │   └── i18n.ts
│   │       └── styles/index.css
│   └── api/                                   # Backend Fastify v5.6.1 + tRPC + OpenAPI
│       ├── src/
│       │   ├── index.ts                       # bootstrap, middlewares
│       │   ├── config/
│       │   │   ├── env.ts                     # zod schema + loader
│       │   │   └── security.ts                # CORS, helmet, rate‑limit
│       │   ├── auth/
│       │   │   ├── requireAuth.ts             # JWT verify (cp/identity)
│       │   │   ├── requireScope.ts
│       │   │   ├── requireEntitlement.ts      # cp/licensing integration
│       │   │   └── rbac.ts
│       │   ├── db/
│       │   │   ├── drizzle/
│       │   │   │   ├── schema.ts          # Catalog, PriceList, Promotion, Quote, Order
│       │   │   │   └── migrations/
│       │   │   └── index.ts                   # drizzle ORM + telemetry
│       │   ├── domain/
│       │   │   ├── catalog/
│       │   │   │   ├── models/
│       │   │   │   │   ├── Product.ts         # atribute, variante, media
│       │   │   │   │   ├── Category.ts
│       │   │   │   │   ├── PriceList.ts       # listă preț per segment/tenant
│       │   │   │   │   ├── Promotion.ts       # reguli promo (BOGO, % off)
│       │   │   │   │   ├── TaxClass.ts        # TVA, coduri fiscale
│       │   │   │   │   └── index.ts
│       │   │   │   ├── services/
│       │   │   │   │   ├── pricing.service.ts # calc preț final (+discounts)
│       │   │   │   │   ├── promotion.service.ts
│       │   │   │   │   ├── inventory.service.ts# stoc (bridge i-wms)
│       │   │   │   │   └── search.service.ts   # FTS PG + facets
│       │   │   │   └── index.ts
│       │   │   ├── sales/
│       │   │   │   ├── models/
│       │   │   │   │   ├── Quote.ts           # status: draft→sent→accepted
│       │   │   │   │   ├── QuoteLine.ts
│       │   │   │   │   ├── Order.ts           # state machine (payment/shipping)
│       │   │   │   │   ├── Payment.ts         # intent, 3DS, refunds
│       │   │   │   │   ├── Shipment.ts        # tracking
│       │   │   │   │   └── index.ts
│       │   │   │   ├── services/
│       │   │   │   │   ├── quote.service.ts   # generare/negociere/approve
│       │   │   │   │   ├── order.service.ts   # create→allocate→fulfill
│       │   │   │   │   ├── payment.service.ts # Stripe/Revolut intents
│       │   │   │   │   ├── invoice-lite.service.ts # export către numeriqo
│       │   │   │   │   └── customer.service.ts# sync cu Vettify
│       │   │   │   └── index.ts
│       │   ├── integrations/
│       │   │   ├── payments/
│       │   │   │   ├── stripe.adapter.ts      # intents, webhooks, refunds
│       │   │   │   ├── revolut.adapter.ts
│       │   │   │   └── index.ts
│       │   │   ├── commerce/
│       │   │   │   ├── shopify.adapter.ts     # sync catalog/orders
│       │   │   │   ├── woocommerce.adapter.ts
│       │   │   │   └── marketplace.adapter.ts # eMAG/Amazon mappers
│       │   │   ├── logistics/
│       │   │   │   ├── sameday.adapter.ts
│       │   │   │   ├── fancourier.adapter.ts
│       │   │   │   └── dhl.adapter.ts
│       │   │   ├── crm/
│       │   │   │   └── vettify.adapter.ts     # push leads/opportunities
│       │   │   └── erp/
│       │   │       └── numeriqo.adapter.ts    # invoice export + taxes
│       │   ├── trpc/
│       │   │   ├── routers/
│       │   │   │   ├── catalog.router.ts      # products, categories, search
│       │   │   │   ├── pricing.router.ts      # price lists, simulate price
│       │   │   │   ├── promotions.router.ts   # rules CRUD, coupons
│       │   │   │   ├── quotes.router.ts       # create/send/approve
│       │   │   │   ├── cart.router.ts         # add/remove/apply coupon
│       │   │   │   ├── checkout.router.ts     # start payment, confirm
│       │   │   │   ├── orders.router.ts       # list/detail/cancel/return
│       │   │   │   ├── customers.router.ts    # accounts + addresses
│       │   │   │   └── analytics.router.ts    # sales KPIs
│       │   │   ├── context.ts
│       │   │   └── index.ts
│       │   ├── openapi/
│       │   │   ├── schemas/
│       │   │   │   ├── product.schema.ts
│       │   │   │   ├── quote.schema.ts
│       │   │   │   ├── order.schema.ts
│       │   │   │   ├── payment.schema.ts
│       │   │   │   └── pricing.schema.ts
│       │   │   ├── spec.ts                     # generator (tRPC ↔ OpenAPI 3)
│       │   │   └── docs.ts                     # UI Scalar/Swagger
│       │   ├── notifications/
│       │   │   ├── engine.ts                   # email la quote sent/accepted
│       │   │   ├── channels/{inapp.ts,email.ts}
│       │   │   └── templates/{quote.mjml,order.mjml}
│       │   ├── telemetry/
│       │   │   ├── otel.ts                     # OTEL SDK init
│       │   │   └── pino.ts                     # logger
│       │   ├── health/{liveness.ts,readiness.ts}
│       │   └── server.ts
│       └── Dockerfile
├── engines/                                     # motoare de business separate
│   ├── pricing-engine/
│   │   ├── src/
│   │   │   ├── rules/
│   │   │   │   ├── list-price.ts               # bază
│   │   │   │   ├── price-list.ts               # per segment/tenant
│   │   │   │   ├── negotiated.ts               # discounturi contractuale
│   │   │   │   ├── tiered.ts                   # cantitate → preț
│   │   │   │   ├── geo-tax.ts                  # TVA & taxe zonale
│   │   │   │   └── coupon.ts                   # cupoane %+fix
│   │   │   ├── composer.ts                     # ordonarea regulilor
│   │   │   ├── calculator.ts                   # calc preț final + breakdown
│   │   │   ├── types.ts
│   │   │   └── index.ts
│   │   └── Dockerfile
│   ├── promotion-engine/
│   │   ├── src/{rules.ts, evaluator.ts, types.ts, index.ts}
│   │   └── Dockerfile
│   └── recommendation-engine/                   # AI asistare vânzări
│       ├── src/
│       │   ├── features/
│       │   │   ├── cross-sell.ts               # bundle/cross-sell
│       │   │   ├── upsell.ts                   # upsell pe categorie
│       │   │   └── reprice.ts                  # sugestii preț
│       │   ├── adapters/
│       │   │   ├── openai.ts                   # rezumat ofertă, email reply
│       │   │   └── cerniq.ts                   # semnale din BI (elasticitate)
│       │   ├── index.ts
│       │   └── types.ts
│       └── Dockerfile
├── services/                                    # workers & webhooks
│   ├── payments-webhooks/
│   │   ├── src/{index.ts, stripe.ts, revolut.ts}
│   │   └── Dockerfile
│   ├── inventory-sync/
│   │   ├── src/{index.ts, wms.adapter.ts}      # subscribe la i-wms events
│   │   └── Dockerfile
│   ├── orders-allocator/
│   │   ├── src/{index.ts, allocator.ts}        # logică multi-depozit
│   │   └── Dockerfile
│   └── feeds-generator/
│       ├── src/{index.ts, google.ts, facebook.ts}
│       └── Dockerfile
├── search/
│   ├── query.builder.ts                         # search + facets
│   ├── fts.pg.ts                                # tsvector indexes
│   └── index.ts
├── analytics/
│   ├── kpis/
│   │   ├── sales.yaml          # GMV, AOV, conversie
│   │   ├── funnel.yaml         # view→cart→checkout→paid
│   │   ├── products.yaml       # top sellers, margin
│   │   └── retention.yaml      # repeat rate, churn proxy
│   ├── exporters/events.publisher.ts            # Kafka → cerniq.app
│   └── dashboards/grafana/*.json
├── db/
│   ├── drizzle/
│   │   ├── schema.ts
│   │   └── migrations/
│   ├── seeds/seed.ts
│   └── scripts/{migrate.sh,reset.sh}
├── env/
│   ├── .env.example
│   ├── vault.template.hcl
│   └── README.md
├── compose/
│   ├── docker-compose.yml                        # api, web, engines, db, redis
│   ├── profiles/{compose.dev.yml,compose.prod.yml}
│   ├── Dockerfile.api
│   ├── Dockerfile.web
│   └── Dockerfile.engine
├── logs/
│   ├── .gitkeep
│   └── README.md
└── tests/
├── unit/
│   ├── pricing.calculator.test.ts
│   ├── promotion.evaluator.test.ts
│   └── checkout.flow.test.ts
├── integration/
│   ├── payments.webhooks.test.ts
│   ├── orders.router.test.ts
│   └── inventory.sync.test.ts
├── e2e/
│   └── b2b-quote-to-cash.spec.ts          # quote→checkout→payment→order
└── fixtures/{catalog/,orders/,payments/}
```

### 2) Fluxuri funcționale cheie

- **Catalog & Căutare**: atribute, variante, prețuri, dispo stoc (via `i-wms.app`), FTS + facete.
- **Cotații B2B**: generare, discounturi negociate, aprobare (integrare `flowxify`), conversie în comenzi.
- **Coș & Checkout**: cupoane, taxe, transport, intents de plată (Stripe/Revolut), 3DS, webhooks.
- **Comenzi**: alocare multi‑depozit, tracking transport, retururi; facturare *lite* → export `numeriqo`.
- **Recomandări/AI**: cross/upsell, reprice suggestions (semnale din `cerniq`).

### 3) Securitate & Multi‑tenant mercantiq

- PKCE→OIDC→JWT (cp/identity), RBAC + entitlements (cp/licensing) pe canale/segmente.
- RLS per tenant, audit evenimente vânzare → Kafka (`cerniq.app`).

### 4) Observabilitate mercantiq

- OTEL (traces pentru checkout, payment, sync), logs structurate, metrics: conversie, latency plăți, erori webhooks, out‑of‑stock rate.

### 5) Integrare cu restul suitei a mercantiq

- MF remote: `apps/web` încărcabil în `cp/suite-shell`.
- API: tRPC + OpenAPI; gateway global compune rute/policies.
- Evenimente: Kafka (`commerce.order.created`, `commerce.payment.succeeded`).

## Capitolul 9 - `numeriqo.app/` – Accounting, Tax (RO), HR & Payroll – arhitectură și structuri detaliate

> Scop: aplicație stand‑alone și modul al suitei pentru **contabilitate românească** (OMFP 1802/2014, plan de conturi, partidă dublă, registre, TVA – D300/D394/D390, SAF‑T D406), **facturare pro + e‑Factura**, **HR & Payroll** (contracte, REGES‑Online, D112), politici salarizare, pontaj, concedii, tichete, rețineri, exporte bancare, raportări către ANAF/BNR/IM. Multi‑tenant, RBAC, RLS pe entități contabile.

### 1) Structură generală (6–7 niveluri, până la fișiere) – web + API + domenii + servicii

```text
numeriqo.app/
├── package.json
├── tsconfig.json
├── nx.json
├── README.md
├── apps/
│   ├── web/                                   # Frontend React 19 (MF remote)
│   │   ├── vite.config.ts
│   │   ├── public/manifest.webmanifest
│   │   └── src/
│   │       ├── main.tsx
│   │       ├── index.html
│   │       ├── routes/
│   │       │   ├── AppRoutes.tsx              # mapare pagini ↔ componente + guards
│   │       │   ├── paths.ts
│   │       │   └── loaders.ts
│   │       ├── pages/
│   │       │   ├── Dashboard.tsx              # KPIs: venituri/cheltuieli, TVA, salarii
│   │       │   ├── Accounting.tsx             # registru jurnale, note contabile
│   │       │   ├── ChartOfAccounts.tsx        # plan de conturi (clase 1–9)
│   │       │   ├── Journals.tsx               # vânzări, cumpărări, casă, bancă
│   │       │   ├── FixedAssets.tsx            # imobilizări + amortizare
│   │       │   ├── VAT.tsx                    # D300/D394/D390, TVA la încasare
│   │       │   ├── SAFt.tsx                   # generare/validare D406
│   │       │   ├── Invoicing.tsx              # facturare pro + e‑Factura
│   │       │   ├── HR.tsx                     # angajați, contracte, state
│   │       │   ├── Payroll.tsx                # calcul salarii + D112
│   │       │   ├── Leaves.tsx                 # concedii, pontaj, zile libere
│   │       │   ├── Settings.tsx               # fiscalitate, perioade, conturi
│   │       │   └── Admin.tsx                  # org, roluri, permisiuni
│   │       ├── features/
│   │       │   ├── accounting/
│   │       │   │   ├── components/{EntryForm.tsx,TrialBalance.tsx,Ledger.tsx}
│   │       │   │   ├── hooks/{useEntries.ts,useAccounts.ts}
│   │       │   │   └── state/{filters.store.ts,posting.store.ts}
│   │       │   ├── vat/
│   │       │   │   ├── components/{D300Preview.tsx,D394Rec.tsx,D390Rec.tsx}
│   │       │   │   └── hooks/{useVATReturns.ts,useVATSettings.ts}
│   │       │   ├── saft/
│   │       │   │   ├── components/{SAFTWizard.tsx,ValidationReport.tsx}
│   │       │   │   └── hooks/{useSAFT.ts}
│   │       │   ├── hr/
│   │       │   │   ├── components/{EmployeeForm.tsx,ContractForm.tsx,Timesheet.tsx}
│   │       │   │   └── hooks/{useEmployees.ts,useContracts.ts}
│   │       │   └── payroll/
│   │       │       ├── components/{PayrollRun.tsx,Payslip.tsx,Adjustments.tsx}
│   │       │       └── hooks/{usePayroll.ts,useD112.ts}
│   │       ├── api/
│   │       │   ├── client.ts                    # tRPC/OpenAPI client
│   │       │   └── interceptors.ts              # attach JWT, retry, tenant
│   │       ├── providers/{AuthProvider.tsx,ThemeProvider.tsx,QueryProvider.tsx}
│   │       ├── i18n/{ro/en}/translation.json
│   │       └── styles/index.css
│   └── api/                                   # Backend Fastify v5.6.1 + tRPC + OpenAPI
│       ├── src/
│       │   ├── index.ts                       # bootstrap, middlewares
│       │   ├── config/
│       │   │   ├── env.ts                     # zod schema + loader
│       │   │   └── security.ts                # CORS, helmet, rate‑limit
│       │   ├── auth/
│       │   │   ├── requireAuth.ts             # JWT verify (cp/identity)
│       │   │   ├── requireScope.ts
│       │   │   ├── requireEntitlement.ts      # cp/licensing integration
│       │   │   └── rbac.ts                    # permisiuni pe entități contabile
│       │   ├── db/
│       │   │   ├── drizzle/
│       │   │   │   ├── schema.ts          # conturi, note, jurnale, TVA, asset, HR/Payroll
│       │   │   │   └── migrations/
│       │   │   └── index.ts                   # drizzle ORM + telemetry
│       │   ├── accounting/
│       │   │   ├── chart-of-accounts/
│       │   │   │   ├── coa.model.ts           # clase, grupe, conturi sintetice/analitice
│       │   │   │   ├── coa.ro.omfp1802.ts     # seed RO OMFP 1802/2014 (actualizat)
│       │   │   │   ├── mapper.ifrs.ts         # mapare RO→IFRS (opțional)
│       │   │   │   └── index.ts
│       │   │   ├── entries/
│       │   │   │   ├── entry.model.ts         # partidă dublă: debit/credit
│       │   │   │   ├── posting.service.ts     # validare, balancing, perioade
│       │   │   │   ├── templates/             # șabloane note pt. operațiuni uzuale
│       │   │   │   │   ├── purchase.vat.ts
│       │   │   │   │   ├── sale.vat.ts
│       │   │   │   │   ├── cash.receipt.ts
│       │   │   │   │   └── bank.payment.ts
│       │   │   │   └── index.ts
│       │   │   ├── journals/
│       │   │   │   ├── sales.ts               # Registru vânzări
│       │   │   │   ├── purchases.ts           # Registru cumpărări
│       │   │   │   ├── cash.ts                # Registru de casă
│       │   │   │   ├── bank.ts                # Registru de bancă
│       │   │   │   └── general.ts             # Jurnal general
│       │   │   ├── ledger/
│       │   │   │   ├── general-ledger.ts      # Carte Mare (conturi, rulaje)
│       │   │   │   └── trial-balance.ts       # Balanță de verificare
│       │   │   ├── vat/
│       │   │   │   ├── vat.model.ts           # cote, regimuri, TVA la încasare
│       │   │   │   ├── d300.generator.ts      # Decont TVA (D300)
│       │   │   │   ├── d394.generator.ts      # Declarație 394
│       │   │   │   ├── d390.generator.ts      # VIES 390
│       │   │   │   ├── rec.conciliator.ts     # reconciliere 300↔394↔390
│       │   │   │   └── validators.ts          # validări cod TVA, VIES, anexe
│       │   │   ├── saft/
│       │   │   │   ├── d406.builder.ts        # generare XML SAF‑T (RO D406)
│       │   │   │   ├── xsd/
│       │   │   │   │   ├── saft-ro.xsd        # schemă locală (read‑only)
│       │   │   │   ├── rules.ts               # consistențe/cerințe câmpuri
│       │   │   │   └── validator.ts           # validare + raport erori
│       │   │   ├── fixed-assets/
│       │   │   │   ├── fa.model.ts            # imobilizări, grupe, conturi 2xx
│       │   │   │   ├── depreciation.ts        # plan amortizare (liniar/degresiv)
│       │   │   │   └── fa.posting.ts          # note contabile automate
│       │   │   ├── invoicing/
│       │   │   │   ├── invoice.model.ts       # facturi clienți/furnizori
│       │   │   │   ├── efactura.adapter.ts    # ANAF e‑Factura (upload/status)
│       │   │   │   ├── templates/             # șabloane PDF/UBL
│       │   │   │   │   ├── classic.mjml
│       │   │   │   │   └── proforma.mjml
│       │   │   │   └── numbering.ts           # serii + reguli numerotare
│       │   │   └── reporting/
│       │   │       ├── balance-sheet.ts       # bilanț (classes 1–5)
│       │   │       ├── p&l.ts                 # cont de profit și pierdere (classe 6–7)
│       │   │       └── cash-flow.ts           # fluxuri de trezorerie
│       │   ├── hr/
│       │   │   ├── employees/
│       │   │   │   ├── employee.model.ts
│       │   │   │   ├── identity.validators.ts # CNP, CI, IBAN
│       │   │   │   └── directory.sync.ts      # sync cu Vettify (parteneri)
│       │   │   ├── contracts/
│       │   │   │   ├── contract.model.ts      # CIM, tip, normă, durată, salar
│       │   │   │   ├── revisions.ts           # acte adiționale
│       │   │   │   ├── templates/             # modele CIM (RO)
│       │   │   │   └── reges.export.ts        # export REGES‑Online (soluție hibrid & API)
│       │   │   ├── timesheets/
│       │   │   │   ├── timesheet.model.ts     # ore, sporuri, ture, WFH
│       │   │   │   └── timesheet.rules.ts     # coduri muncă, ore suplimentare
│       │   │   ├── leaves/
│       │   │   │   ├── leave.model.ts         # CO, medical, fără plată
│       │   │   │   └── accruals.ts            # reguli acumulare/consum
│       │   │   └── payroll/
│       │   │       ├── payroll.model.ts       # runde salarii, plăți, state
│       │   │       ├── payroll.engine.ts      # brut→net, contribuții, deduceri
│       │   │       ├── d112.generator.ts      # Declarația D112
│       │   │       ├── bank.export.sepa.ts    # fișiere plăți salarii (SEPA)
│       │   │       └── payslip.renderer.ts    # fluturași PDF
│       │   ├── integrations/
│       │   │   ├── anaf/
│       │   │   │   ├── efactura.client.ts
│       │   │   │   ├── saf-t.client.ts
│       │   │   │   ├── d300.client.ts
│       │   │   │   ├── d394.client.ts
│       │   │   │   └── d390.client.ts
│       │   │   ├── bnr/
│       │   │   │   └── fx.client.ts           # cursuri valutare BNR
│       │   │   ├── reges/
│       │   │   │   ├── export.builder.ts      # pachete REGES‑Online (soluție hibrid & API)
│       │   │   │   └── portal.adapter.ts      # automatizare upload REGES (manual & API)
│       │   │   └── identity/
│       │   │       └── rux.adapter.ts         # Microsoft Graph (opțional)
│       │   ├── trpc/
│       │   │   ├── routers/
│       │   │   │   ├── accounting.router.ts   # note, jurnale, bilanț, p&l
│       │   │   │   ├── vat.router.ts          # D300/D394/D390
│       │   │   │   ├── saft.router.ts         # D406 build/validate
│       │   │   │   ├── invoicing.router.ts    # facturi + e‑Factura
│       │   │   │   ├── hr.router.ts           # angajați, contracte
│       │   │   │   ├── payroll.router.ts      # runde salarii, D112, plăți
│       │   │   │   └── reporting.router.ts    # balanță, GL, cashflow
│       │   │   ├── context.ts
│       │   │   └── index.ts
│       │   ├── openapi/
│       │   │   ├── schemas/
│       │   │   │   ├── accounting.schema.ts
│       │   │   │   ├── vat.schema.ts
│       │   │   │   ├── saft.schema.ts
│       │   │   │   ├── invoicing.schema.ts
│       │   │   │   ├── hr.schema.ts
│       │   │   │   └── payroll.schema.ts
│       │   │   ├── spec.ts                     # generator (tRPC ↔ OpenAPI 3)
│       │   │   └── docs.ts                     # UI Scalar/Swagger
│       │   ├── telemetry/{otel.ts,pino.ts}
│       │   ├── health/{liveness.ts,readiness.ts}
│       │   └── server.ts
│       └── Dockerfile
├── domain-guides/                               # norme & implementare RO
│   ├── accounting.ro.md        # OMFP 1802: conturi active/pasive/bifuncționale
│   ├── journals.ro.md          # jurnale: vânzări, cumpărări, casă, bancă, general
│   ├── vat.ro.md               # cote TVA, regimuri, termene D300/D394/D390
│   ├── saft.ro.md              # structuri D406 + reguli de consistență
│   ├── reporting.ro.md         # bilanț, p&l, cashflow, trial balance
│   ├── hr.ro.md                # CIM, REGES‑Online, pontaj, concedii, D112
│   └── payroll.ro.md           # formule contribuții, deduceri, net, export bancar
├── seeds/
│   ├── accounting/
│   │   ├── coa.omfp1802.json                     # plan conturi RO (clase 1–9)
│   │   ├── vat-rates.ro.json                     # cote TVA actuale
│   │   └── templates/notes/*.json                # șabloane note uzuale
│   └── hr/
│       ├── allowances.json                       # sporuri, tichete, deduceri
│       └── calendars/ro/*.json                   # sărbători legale, programe
├── analytics/
│   ├── kpis/
│   │   ├── accounting.yaml    # marje, rotație creanțe/datorii, cash conversion
│   │   ├── vat.yaml           # TVA colectată/deductibilă, gap & reconciliere
│   │   └── payroll.yaml       # cost salarial, overtime, absențe
│   ├── exporters/events.publisher.ts            # Kafka → cerniq.app
│   └── dashboards/grafana/*.json
├── db/
│   ├── drizzle/
│   │   ├── schema.ts
│   │   └── migrations/
│   ├── seeds/seed.ts
│   └── scripts/{migrate.sh,reset.sh}
├── env/
│   ├── .env.example
│   ├── vault.template.hcl
│   └── README.md
├── compose/
│   ├── docker-compose.yml                        # api, web, db, workers
│   ├── profiles/{compose.dev.yml,compose.prod.yml}
│   ├── Dockerfile.api
│   ├── Dockerfile.web
│   └── Dockerfile.worker
├── logs/{.gitkeep,README.md}
└── tests/
├── unit/
│   ├── posting.service.test.ts
│   ├── vat.generators.test.ts
│   ├── saft.validator.test.ts
│   ├── payroll.engine.test.ts
│   └── d112.generator.test.ts
├── integration/
│   ├── accounting.router.test.ts
│   ├── invoicing.efactura.test.ts
│   ├── hr.payroll.router.test.ts
│   └── reges.export.test.ts
├── e2e/
│   └── ro-compliance-flows.spec.ts          # factură→jurnal→TVA→SAF-T→D112
└── fixtures/{invoices/,employees/,saft/}
```

### 2) Modele de date – esențiale (Drizzle)

- **Cont**: `code`, `name`, `type` (`asset|liability|equity|income|expense|bifunctional`), `parent`, `currency`, `isAnalytic`, `tenantId`.
- **NotaContabila**: `date`, `period`, `lines[]` (cont, debit, credit, descriere, VATLink?), `docRef` (factură/încasare/plată), `locked`.
- **Jurnal**: tip (`sales|purchases|cash|bank|general`), `sequence`, `documentNo`, legături la note.
- **VATDoc**: `regime`, `rate`, `base`, `tax`, mapări linii D300/D394/D390.
- **FixedAsset**: `class`, `method`, `lifetime`, `residual`, `startDate`, `depreciationPlan[]`.
- **Invoice**: `series`, `number`, `partner`, `lines[]` (cont venit/chelt., TVA), `due`, `status`, `ubl`.
- **Employee/Contract/Timesheet/PayrollRun/Payslip**: câmpuri standard + istorice.

### 3) Fluxuri funcționale cheie

- **Partidă dublă**: orice document generează **note contabile echilibrate** (debit=credit). Lock perioade la închidere.
- **TVA**: setări cote/regimuri, marcaj „TVA la încasare”, reconciliere D300↔D394↔D390, validări VIES.
- **SAF‑T (D406)**: builder XML pe schemele RO, validări de consistență și raport erori; export lunar/trimestrial/anual după categorie contribuabil.
- **HR**: gestionare CIM, reviste contracte, generare export hibrid REGES‑Online și integrare API; pontaj cu coduri muncă; politici concedii. - **Payroll**: motor brut→net (contribuții, impozit, deduceri), fluturași, fișiere bancare, D112.
- **Invoicing Pro**: e‑Factura (upload & status), serii numerotare, șabloane PDF/UBL.

### 4) Securitate & Multi‑tenant

- PKCE→OIDC→JWT (cp/identity), RBAC + entitlements (cp/licensing) pe entități (companie, jurnal, perioadă). RLS pe tabele cu `tenantId` + `companyId`.

### 5) Observabilitate

- OTEL (traces pentru posting, generatoare D‑forms, payroll), logs structurate, KPIs contabile, alerte reconciliere TVA și erori SAF‑T/D112.

### 6) Integrare cu suita

- MF remote: `apps/web` încărcabil în `cp/suite-shell`.
- API: tRPC + OpenAPI; gateway global compune rute și policies.
- Evenimente: Kafka (`acct.entry.posted`, `vat.return.generated`, `hr.payroll.closed`).

## Capitolul 10 - # `triggerra.app/` – Marketing Automation, Intelligence & Decisioning (state‑of‑the‑art)

> Scop: aplicație stand‑alone și modul de marketing al suitei. Concentrează **automation**, **CDP first‑party**, **analytics avansat** (MTA + MMM), **decisioning în timp real**, **journey orchestration** (Temporal), **SEO & Product Knowledge Graph** ca „source of truth”, **data clean rooms** și **server‑side tagging**. Integrare nativă cu `vettify.app` (CRM), `mercantiq.app` (commerce), `i-wms.app` (stoc/logistică), `numeriqo.app` (costuri/margini), `cerniq.app` (BI Hub).

### 1) Structură generală (6–7 niveluri, până la fișiere) – web + API + engines + analytics + services

```text
triggerra.app/
├── package.json
├── tsconfig.json
├── nx.json
├── README.md
├── apps/
│   ├── web/                                       # Frontend React 19 (MF remote)
│   │   ├── vite.config.ts
│   │   ├── public/manifest.webmanifest
│   │   └── src/
│   │       ├── main.tsx
│   │       ├── index.html
│   │       ├── routes/
│   │       │   ├── AppRoutes.tsx                  # mapare pagini ↔ componente + guards
│   │       │   ├── paths.ts
│   │       │   └── loaders.ts
│   │       ├── pages/
│   │       │   ├── Dashboard.tsx                  # KPIs marketing, ROAS, CAC, LTV
│   │       │   ├── Journeys.tsx                   # orchestrare campanii & pași (Temporal)
│   │       │   ├── Segments.tsx                   # segmente CDP + lookalikes
│   │       │   ├── Assets.tsx                     # bibliotecă creativă + versiuni
│   │       │   ├── Experiments.tsx                # A/B/n, bandits, uplift tests
│   │       │   ├── SEO.tsx                        # schema, feeds, coverage, health
│   │       │   ├── Reports.tsx                    # dashboards, MMM/MTA vizualizări
│   │       │   ├── Settings.tsx                   # surse date, privacy, tagging
│   │       │   └── Admin.tsx                      # permisiuni, API keys, webhooks
│   │       ├── features/
│   │       │   ├── journeys/
│   │       │   │   ├── components/{JourneyCanvas.tsx,NodeLibrary.tsx}
│   │       │   │   ├── hooks/{useJourneys.ts,useTemplates.ts}
│   │       │   │   └── index.ts
│   │       │   ├── segments/
│   │       │   │   ├── components/{SegmentBuilder.tsx,Conditions.tsx}
│   │       │   │   ├── hooks/{useSegments.ts,useTraits.ts}
│   │       │   │   └── index.ts
│   │       │   ├── experiments/
│   │       │   │   ├── components/{ExperimentForm.tsx,ResultsView.tsx}
│   │       │   │   ├── hooks/{useExperiments.ts,useBandits.ts}
│   │       │   │   └── index.ts
│   │       │   ├── seo/
│   │       │   │   ├── components/{SchemaEditor.tsx,FeedStatus.tsx}
│   │       │   │   ├── hooks/{useSchema.ts,useFeeds.ts}
│   │       │   │   └── index.ts
│   │       │   └── index.ts
│   │       ├── api/
│   │       │   ├── client.ts                        # tRPC/OpenAPI client
│   │       │   └── interceptors.ts                  # attach JWT, retry, tenant
│   │       ├── providers/{AuthProvider.tsx,ThemeProvider.tsx,QueryProvider.tsx}
│   │       ├── i18n/{ro/en}/translation.json
│   │       └── styles/index.css
│   └── api/                                       # Backend Fastify v5.6.1 + tRPC + OpenAPI
│       ├── src/
│       │   ├── index.ts                           # bootstrap, middlewares
│       │   ├── config/
│       │   │   ├── env.ts                         # zod schema + loader
│       │   │   └── security.ts                    # CORS, helmet, rate‑limit
│       │   ├── auth/
│       │   │   ├── requireAuth.ts                 # JWT verify (cp/identity)
│       │   │   ├── requireScope.ts
│       │   │   ├── requireEntitlement.ts          # cp/licensing integration
│       │   │   └── rbac.ts                        # permisiuni marketing/data
│       │   ├── db/
│       │   │   ├── drizzle/
│       │   │   │   ├── schema.ts              # CDP profiles, events, traits, consents
│       │   │   │   └── migrations/
│       │   │   └── index.ts                       # drizzle ORM + telemetry
│       │   ├── cdp/
│       │   │   ├── profile.model.ts               # profil unificat: identities + traits
│       │   │   ├── identity.graph.ts              # rezolvare identități (email, deviceId)
│       │   │   ├── traits.schema.ts               # atribute standardizate
│       │   │   ├── consent.model.ts               # TCF 2.2, preferințe canale
│       │   │   └── audiences.service.ts           # builder segmente + SQL gen
│       │   ├── tracking/
│       │   │   ├── sst.client.ts                  # server‑side tagging (GTM‑SS)
│       │   │   ├── collectors/{web.ts,app.ts,backend.ts}
│       │   │   └── enrichers/{geoip.ts,ua.ts,utm.ts}
│       │   ├── knowledge‑graph/
│       │   │   ├── product.schema.ts              # schema.org Product + Merchant spec
│       │   │   ├── generator.ts                   # JSON‑LD generator (sitewide)
│       │   │   ├── feeds/
│       │   │   │   ├── google.merchant.ts         # GMC feed (XML/TSV)
│       │   │   │   ├── meta.catalog.ts            # FB/IG Catalog
│       │   │   │   └── marketplace/*.ts           # eMAG/Amazon mappings
│       │   │   ├── reconciler.ts                  # aliniază PIM ↔ web ↔ marketplace
│       │   │   └── validators.ts                  # rich results & policy checks
│       │   ├── journeys/
│       │   │   ├── workflows/                     # Temporal workflows & activities
│       │   │   │   ├── welcome.series.ts
│       │   │   │   ├── cart.abandon.ts
│       │   │   │   ├── replenishment.ts
│       │   │   │   ├── lead.nurture.ts
│       │   │   │   └── winback.ts
│       │   │   ├── activities/
│       │   │   │   ├── send.email.ts              # email/SMS/WhatsApp adapters
│       │   │   │   ├── push.segment.ts            # către ad platforms/CDP extern
│       │   │   │   ├── branch.split.ts            # condiții (events/traits)
│       │   │   │   └── delay.wait.ts              # timers, backoff
│       │   │   └── orchestrator.ts                # registry workflows
│       │   ├── decisioning/
│       │   │   ├── bandits.ts                     # Thompson/UCB pentru creativ/landing
│       │   │   ├── uplift.ts                      # uplift modeling → targeting incremental
│       │   │   ├── propensity.ts                  # scor conversie/churn/LTV
│       │   │   ├── allocator.ts                   # bugete & cap la canal/campanie
│       │   │   └── experiments.ts                 # definire experimente + randomizare
│       │   ├── attribution/
│       │   │   ├── mta.model.ts                   # time‑decay, Markov, Shapley
│       │   │   ├── mmm.job.ts                     # MMM offline (Robyn/LightweightMMM)
│       │   │   └── budget.optimizer.ts            # optimizare mix pe constrângeri
│       │   ├── privacy/
│       │   │   ├── tcf.ts                         # IAB TCF v2.2 parsing & policy
│       │   │   ├── consent.guard.ts               # gating pentru tracking & activări
│       │   │   ├── sst.pii.rules.ts               # redaction + hashing
│       │   │   └── dcr.adapters.ts                # BigQuery/ADH clean‑room bridges
│       │   ├── integrations/
│       │   │   ├── adtech/
│       │   │   │   ├── google.ads.ts             # Google Ads/CM360/DV360
│       │   │   │   ├── meta.ads.ts               # Meta Marketing API
│       │   │   │   ├── tiktok.ads.ts
│       │   │   │   ├── linkedin.ads.ts
│       │   │   │   └── x.ads.ts
│       │   │   ├── analytics/
│       │   │   │   ├── ga4.s2s.ts                 # server‑to‑server GA4 (measurement)
│       │   │   │   └── gtm.ssv.ts                 # GTM Server container helpers
│       │   │   ├── cdp/
│       │   │   │   ├── segment.adapter.ts
│       │   │   │   └── rudderstack.adapter.ts
│       │   │   ├── commerce/
│       │   │   │   ├── mercantiq.adapter.ts      # events: view/cart/checkout/order
│       │   │   │   └── i‑wms.adapter.ts          # stoc pentru feed/availability
│       │   │   ├── crm/
│       │   │   │   └── vettify.adapter.ts        # segmente → campanii, scoruri
│       │   │   └── bi/
│       │   │       └── cerniq.adapter.ts         # export evenimente & modele
│       │   ├── trpc/
│       │   │   ├── routers/
│       │   │   │   ├── cdp.router.ts             # profiles, traits, audiences
│       │   │   │   ├── journeys.router.ts        # workflows CRUD + launch
│       │   │   │   ├── experiments.router.ts     # create/arm/metrics
│       │   │   │   ├── seo.router.ts             # schema/feeds management
│       │   │   │   ├── attribution.router.ts     # MTA/MMM queries
│       │   │   │   └── reports.router.ts         # dashboards pre‑compute
│       │   │   ├── context.ts
│       │   │   └── index.ts
│       │   ├── openapi/
│       │   │   ├── schemas/
│       │   │   │   ├── cdp.schema.ts
│       │   │   │   ├── journeys.schema.ts
│       │   │   │   ├── experiments.schema.ts
│       │   │   │   ├── seo.schema.ts
│       │   │   │   ├── attribution.schema.ts
│       │   │   │   └── reports.schema.ts
│       │   │   ├── spec.ts                         # generator (tRPC ↔ OpenAPI 3)
│       │   │   └── docs.ts                         # UI Scalar/Swagger
│       │   ├── telemetry/{otel.ts,pino.ts}
│       │   ├── health/{liveness.ts,readiness.ts}
│       │   └── server.ts
│       └── Dockerfile
├── engines/                                        # motoare separate
│   ├── mmm/                                        # Marketing Mix Modeling
│   │   ├── src/
│   │   │   ├── adapters/{robyn.ts,lightweightmmm.ts}
│   │   │   ├── preprocessors/{carryover.ts,saturation.ts}
│   │   │   ├── optimizer.ts                        # bugete & constrângeri
│   │   │   └── index.ts
│   │   └── Dockerfile
│   ├── mta/
│   │   ├── src/{markov.ts,shapley.ts,time‑decay.ts}
│   │   └── Dockerfile
│   ├── bandits/
│   │   ├── src/{thompson.ts,ucb.ts,epsilon.ts}
│   │   └── Dockerfile
│   └── nlp‑enrichment/
│       ├── src/{entity.extract.ts,topic.model.ts,competitor.diff.ts}
│       └── Dockerfile
├── analytics/
│   ├── kpis/
│   │   ├── acquisition.yaml           # CAC, CTR, CVR, CPA, ROAS
│   │   ├── retention.yaml             # repeat, churn proxy
│   │   ├── ltv.yaml                   # CLV modele, cashflow discounting
│   │   └── experiments.yaml           # uplift, MDE, power
│   ├── exporters/events.publisher.ts  # Kafka → cerniq.app (topics marketing.*)
│   └── dashboards/grafana/*.json
├── research/                                      # intel de piață & trenduri
│   ├── scrapers/                                  # (etic, robots.txt aware)
│   │   ├── products.crawler.ts                    # colectare specificații produs
│   │   ├── pricing.crawler.ts                     # intel preț & promo
│   │   └── content.crawler.ts                     # ghiduri, bloguri, PR
│   ├── enrichment/
│   │   ├── product.merge.ts                       # completează PIM cu web facts
│   │   ├── sources/
│   │   │   ├── schema.org.parser.ts               # parse JSON‑LD din web
│   │   │   ├── rss.atom.ts
│   │   │   └── sitemaps.ts
│   │   └── validators.ts                           # score calitate, trust, freshness
│   └── knowledge/base/                            # snapshoturi curate, citabile
├── privacy‑compliance/
│   ├── tcf/
│   │   ├── vendors.list.cache.json                # GVL cache
│   │   ├── cmp.api.ts                              # interfață CMP, TCF v2.2
│   │   └── policies.md                             # reguli per canal
│   ├── sst/
│   │   ├── server.config.ts                        # mapare clienți & destinații
│   │   └── pii.redaction.ts                        # hash/trim pentru payloads
│   └── dcr/
│       ├── adh.queries.sql                         # queries Ads Data Hub
│       ├── bq.cleanroom.templates.sql              # BigQuery DCR templates
│       └── governance.md                           # acces, agregări, k‑anonimity
├── db/
│   ├── drizzle/
│   │   ├── schema.ts
│   │   └── migrations/
│   ├── seeds/seed.ts
│   └── scripts/{migrate.sh,reset.sh}
├── env/
│   ├── .env.example
│   ├── vault.template.hcl
│   └── README.md
├── compose/
│   ├── docker-compose.yml                          # api, web, engines, db, redis
│   ├── profiles/{compose.dev.yml,compose.prod.yml}
│   ├── Dockerfile.api
│   ├── Dockerfile.web
│   └── Dockerfile.engine
├── logs/{.gitkeep,README.md}
└── tests/
├── unit/
│   ├── attribution.markov.test.ts
│   ├── bandits.thompson.test.ts
│   ├── tcf.parser.test.ts
│   └── schema.generator.test.ts
├── integration/
│   ├── journeys.temporal.test.ts
│   ├── ga4.s2s.test.ts
│   ├── adh.query.test.ts
│   └── feeds.gmc.test.ts
├── e2e/
│   └── full-funnel-journey.spec.ts            # ad→landing→lead→order→LTV
└── fixtures/{events/,schema/,feeds/,adh/}
```

### 2) Modele de date – esențiale (Drizzle) triggerra

- **Profile** (CDP): identități (email, phone, deviceId, cookieId), `traits` (JSONB tipizat), consimțământ (TCF 2.2), `tenantId`.
- **Events**: evenimente normalizate (view, add_to_cart, checkout, purchase, lead_submitted), sursă (web/app/backend), UTM, campaign/adset/ad, `profileId`.
- **Audiences**: reguli (inclusion/exclusion), dimensiune, refresh policy, export destinations (adtech/CDP extern).
- **Assets**: creativ, varianta, canal, budget cap, flight window.
- **Experiments**: design (A/B/n, bandit, uplift), `metrics` (primary/secondary), trafic alocat.
- **SEO/Feeds**: `productId`, schema JSON‑LD generată, stări feed (GMC/Meta/marketplace), erori validator.

### 3) Fluxuri funcționale cheie triggerra

- **CDP & Tagging**: colectare server‑side (GTM‑SS) → normalizare → îmbogățire (UTM/geo) → scriere în Events; rezolvare identități; consimțământ TCF aplicat înainte de activări.
- **Journeys**: templatizate (bun‑venit, abandon coș, replenishment, winback); orchestrare cu Temporal; canale: email/SMS/WhatsApp/ads audiences; throttling & frequency caps.
- **Attribution**: MTA (Markov/Shapley/time‑decay) pentru digital; MMM (Robyn/LightweightMMM) pentru mix cross‑canal + optimizator bugete.
- **Decisioning**: bandits pentru creativ/landing; uplift pentru targeting incremental; alocare buget pe constrângeri & ROI.
- **SEO & Source‑of‑Truth**: generator JSON‑LD (schema.org Product) + feeduri GMC/Meta; reconciliere PIM↔web; validare conform ghidurilor Google.
- **Research & Enrichment**: crawlers etici (robots.txt), parsare schema.org, agregare specificații/preturi; scor calitate + deduplicare; publică "Produse de Date" (ex. marketing.trends) consumabile de cerniq.app (Data Mesh).
- **Clean Rooms & Privacy**: Ads Data Hub / BigQuery DCR pentru analize agregate; PII redaction/hashing; guvernanță acces.

### 4) Securitate & Multi‑tenant triggerra

- PKCE→OIDC→JWT (cp/identity), RBAC + entitlements (cp/licensing). RLS pe `tenantId` + controale pe canale & destinații. Audit complet pentru activări & exporturi.

### 5) Observabilitate triggerra

- OTEL (traces pentru journeys, activări, MTA/MMM joburi), logs structurate, metrics: delivery, uplift, ROAS, cost per event, erori feeds.

### 6) Integrare în suita triggerra

- MF remote: `apps/web` încărcabil în `cp/suite-shell`.
- API: tRPC + OpenAPI; gateway global compune rute/policies.
- Evenimente: Kafka (`marketing.event.ingested`, `marketing.journey.sent`, `marketing.attribution.updated`).

## Capitolul 11 - `vettify.app/` – CRM, Relationships & Firmographics (EU‑grade)

> Scop: aplicație stand‑alone și modul CRM al suitei, axată pe **prospects/leads/clients/partners/suppliers**, **firmographics RO+UE (oficiale, GDPR‑compliant)**, **identity resolution**, **enrichment automat**, **lead scoring ML & ICP fit**, **sales funnels & pipeline automation**, **outreach multi‑canal**, **data quality & dedup**, **graph‑360 relații**. Integrare nativă cu `triggerra.app` (marketing CDP), `mercantiq.app` (sales orders & quotes), `numeriqo.app` (invoicing/account status), `cerniq.app` (BI) și `i‑wms.app` (livrări).

### 1) Structură generală (6–7 niveluri) – web + API + enrichment + graph + services

```text
vettify.app/
├── package.json
├── tsconfig.json
├── nx.json
├── README.md
├── apps/
│   ├── web/                                          # Frontend React 19 (MF remote)
│   │   ├── vite.config.ts
│   │   ├── public/manifest.webmanifest
│   │   └── src/
│   │       ├── main.tsx
│   │       ├── index.html
│   │       ├── routes/
│   │       │   ├── AppRoutes.tsx                     # mapare pagini ↔ componente + guards
│   │       │   ├── paths.ts
│   │       │   └── loaders.ts
│   │       ├── pages/
│   │       │   ├── Dashboard.tsx                     # KPIs CRM: MQL→SQL, win‑rate, TTV
│   │       │   ├── Leads.tsx                         # list + kanban + import CSV/XLSX
│   │       │   ├── Accounts.tsx                      # companii (firmographics + scoring)
│   │       │   ├── Contacts.tsx                      # persoane + preferințe + consimțământ
│   │       │   ├── Opportunities.tsx                 # pipeline, stadii, probabilități
│   │       │   ├── Activities.tsx                    # calls/emails/meetings/tasks
│   │       │   ├── Outreach.tsx                      # secvențe multi‑canal + throttling
│   │       │   ├── Dedupe.tsx                        # deduplicare interactivă (merge)
│   │       │   ├── Enrichment.tsx                    # stări & surse enrichment
│   │       │   ├── Graph360.tsx                      # vizualizare relații (Neo4j viz)
│   │       │   ├── Settings.tsx                      # mapping câmpuri, scoring, lead‑to‑account
│   │       │   └── Admin.tsx                         # roluri, permisiuni, webhooks
│   │       ├── features/
│   │       │   ├── leads/
│   │       │   │   ├── components/{LeadTable.tsx,LeadForm.tsx,LeadImport.tsx}
│   │       │   │   ├── hooks/{useLeads.ts,useLeadActions.ts}
│   │       │   │   └── state/{leads.store.ts,filters.store.ts}
│   │       │   ├── accounts/
│   │       │   │   ├── components/{AccountView.tsx,EnrichmentPanel.tsx}
│   │       │   │   ├── hooks/{useAccounts.ts,useFirmographics.ts}
│   │       │   │   └── state/{accounts.store.ts}
│   │       │   ├── opportunities/
│   │       │   │   ├── components/{PipelineBoard.tsx,EditDeal.tsx}
│   │       │   │   ├── hooks/{useOpportunities.ts,useForecast.ts}
│   │       │   │   └── state/{pipeline.store.ts}
│   │       │   ├── outreach/
│   │       │   │   ├── components/{SequenceBuilder.tsx,Mailbox.tsx}
│   │       │   │   ├── hooks/{useSequences.ts,useInbox.ts}
│   │       │   │   └── state/{sequences.store.ts}
│   │       │   ├── graph/
│   │       │   │   ├── components/{GraphView.tsx,RelationInspector.tsx}
│   │       │   │   └── hooks/{useGraph.ts}
│   │       │   └── index.ts
│   │       ├── api/
│   │       │   ├── client.ts                           # tRPC/OpenAPI client
│   │       │   └── interceptors.ts                     # attach JWT, retry, tenant
│   │       ├── providers/{AuthProvider.tsx,ThemeProvider.tsx,QueryProvider.tsx}
│   │       ├── i18n/{ro/en}/translation.json
│   │       └── styles/index.css
│   └── api/                                          # Backend Fastify v5.6.1 + tRPC + OpenAPI
│       ├── src/
│       │   ├── index.ts                              # bootstrap, middlewares
│       │   ├── config/
│       │   │   ├── env.ts                            # zod schema + loader
│       │   │   └── security.ts                       # CORS, helmet, rate‑limit
│       │   ├── auth/
│       │   │   ├── requireAuth.ts                    # JWT verify (cp/identity)
│       │   │   ├── requireScope.ts
│       │   │   ├── requireEntitlement.ts             # cp/licensing integration
│       │   │   └── rbac.ts                           # permisiuni CRM/data
│       │   ├── db/
│       │   │   ├── drizzle/
│       │   │   │   ├── schema.ts                     # leads, accounts, contacts, activities
│       │   │   │   └── migrations/
│       │   │   └── index.ts                          # drizzle ORM + telemetry
│       │   ├── graph/
│       │   │   ├── neo4j.client.ts                   # driver Neo4j, pooling
│       │   │   ├── graph.model.ts                    # noduri & relații (WORKS_AT, OWNS)
│       │   │   ├── graph.sync.ts                     # sync RDBMS → grafic (CDC)
│       │   │   └── queries.cypher.ts                 # interogări reutilizabile
│       │   ├── identity‑resolution/
│       │   │   ├── rules.ts                          # email/phone/domain/companyId
│       │   │   ├── matching.ts                       # fuzzy match (trigram, Jaro‑Winkler)
│       │   │   ├── merge.ts                          # lead→contact, contact→account
│       │   │   ├── survivorship.ts                   # câmp câștigător (freshness/trust)
│       │   │   └── lineage.ts                        # provenance & audit câmpuri
│       │   ├── enrichment/
│       │   │   ├── sources/
│       │   │   │   ├── termene.adapter.ts            # firmographics RO (CUI, bilanțuri)
│       │   │   │   ├── anaf.adapter.ts               # validări CUI/TVA, status fiscal
│       │   │   │   ├── dealfront.adapter.ts          # B2B EU signals (intent, tech)
│       │   │   │   ├── clearbit.adapter.ts           # alternate global enrichment
│       │   │   │   ├── hunter.adapter.ts             # email discovery/verif (etic)
│       │   │   │   ├── linkedin.public.ts            # public company pages (robots aware)
│       │   │   │   └── web.schema.parser.ts          # schema.org (JSON‑LD) parser
│       │   │   ├── orchestrator.ts                   # pipeline manager (Temporal tasks)
│       │   │   ├── scoring.ts                        # scor calitate sursă (trust, freshness)
│       │   │   ├── normalizers.ts                    # mapare la model intern + enums
│       │   │   └── policies.ts                       # GDPR: consimțământ, opt‑out, purpose
│       │   ├── outreach/
│       │   │   ├── channels/
│       │   │   │   ├── email.ts                      # SMTP/API (SES/Mailgun), templates
│       │   │   │   ├── whatsapp.ts                   # WhatsApp Business API
│       │   │   │   └── sms.ts                        # Twilio/others
│       │   │   ├── sequences/
│       │   │   │   ├── sequence.model.ts             # pași, delays, branch condiții
│       │   │   │   ├── throttling.ts                 # caps/limits per canal
│       │   │   │   └── compliance.ts                 # spam rules, quiet hours, DNC
│       │   │   └── mailbox/
│       │   │       ├── imap.client.ts                # citire răspunsuri, threading
│       │   │       └── reply.parser.ts               # detectare interes/obiecții/bounce
│       │   ├── scoring/
│       │   │   ├── icp.fit.ts                        # ICP fit pe firmographics & tech
│       │   │   ├── lead.score.ml.ts                  # ML features, pipeline, retrain
│       │   │   ├── intent.signals.ts                 # vizite, pricing views, events
│       │   │   └── routing.ts                        # assignment round‑robin/priority
│       │   ├── quality/
│       │   │   ├── dedupe.service.ts                 # hash keys, blocking keys, graph dupes
│       │   │   ├── validation.service.ts             # email/phone/domain checks
│       │   │   ├── email.verification.ts             # NeverBounce/ZeroBounce adapters
│       │   │   └── monitoring.ts                     # scor igienă bază (bounce%, spamtrap)
│       │   ├── integrations/
│       │   │   ├── triggerra.adapter.ts              # segmente ↔ campanii/journeys
│       │   │   ├── mercantiq.adapter.ts              # quotes/orders ↔ account health
│       │   │   ├── numeriqo.adapter.ts               # facturi, solduri, risc plăți
│       │   │   ├── cerniq.adapter.ts                 # export evenimente & modele
│       │   │   └── i‑wms.adapter.ts                  # SLA livrare, retururi
│       │   ├── trpc/
│       │   │   ├── routers/
│       │   │   │   ├── leads.router.ts               # CRUD, import, convert lead
│       │   │   │   ├── accounts.router.ts            # firmographics, enrichment, merge
│       │   │   │   ├── contacts.router.ts            # consimțământ, preferințe
│       │   │   │   ├── opportunities.router.ts       # pipeline, forecast
│       │   │   │   ├── outreach.router.ts            # sequences, inbox
│       │   │   │   ├── scoring.router.ts             # scoruri ML, ICP
│       │   │   │   └── reports.router.ts             # rapoarte CRM + sănătate date
│       │   │   ├── context.ts
│       │   │   └── index.ts
│       │   ├── openapi/
│       │   │   ├── schemas/
│       │   │   │   ├── lead.schema.ts
│       │   │   │   ├── account.schema.ts
│       │   │   │   ├── contact.schema.ts
│       │   │   │   ├── opportunity.schema.ts
│       │   │   │   ├── outreach.schema.ts
│       │   │   │   └── scoring.schema.ts
│       │   │   ├── spec.ts                            # generator (tRPC ↔ OpenAPI 3)
│       │   │   └── docs.ts                            # UI Scalar/Swagger
│       │   ├── telemetry/{otel.ts,pino.ts}
│       │   ├── health/{liveness.ts,readiness.ts}
│       │   └── server.ts
│       └── Dockerfile
├── models/                                           # definiri de domeniu & mappers
│   ├── Lead.ts                                       # lead entity + state machine
│   ├── Account.ts                                    # companie: dimensiuni, CAEN, CUI
│   ├── Contact.ts                                    # persoană + consimțământ canal
│   ├── Opportunity.ts                                # valoare, stadiu, probabilitate
│   ├── Activity.ts                                   # call/email/meeting/task
│   ├── Enrichment.ts                                 # sursă, scor, freshness
│   ├── Graph.ts                                      # noduri + relații, typesafe
│   └── index.ts
├── db/
│   ├── drizzle/
│   │   ├── schema.ts
│   │   └── migrations/
│   ├── seeds/seed.ts
│   └── scripts/{migrate.sh,reset.sh}
├── analytics/
│   ├── kpis/
│   │   ├── crm.yaml                                  # MQL→SQL, win rate, cycle len
│   │   ├── hygiene.yaml                              # bounce%, dupes, enrichment coverage
│   │   └── revenue.yaml                              # pipeline, forecast, LTV
│   ├── exporters/events.publisher.ts                 # Kafka → cerniq.app (crm.*)
│   └── dashboards/grafana/*.json
├── research/                                         # playbooks + surse (etic)
│   ├── playbooks/
│   │   ├── cold‑list‑warming.md                      # încălzire liste reci, etic & opt‑in
│   │   ├── enrichment‑rules.md                       # ordine surse, thresholds
│   │   ├── identity‑resolution.md                    # matching keys, merge rules
│   │   └── outreach‑sequences.md                     # cadente multi‑canal
│   ├── scrapers/
│   │   ├── robots.guard.ts                           # respect robots.txt & rate limits
│   │   ├── company.page.scraper.ts                   # pagini publice (about/careers)
│   │   ├── schema.ld.parser.ts                       # JSON‑LD → facts (name, sameAs)
│   │   └── sitemaps.fetcher.ts
│   └── sources/
│       ├── official.registers.md                     # registre UE + linkuri
│       ├── vendor.matrix.md                          # furnizori B2B data (EU‑first)
│       └── compliance.notes.md                       # DPIA, LIA, temei legal
├── privacy‑compliance/
│   ├── gdpr/
│   │   ├── dpia.template.md                          # Data Protection Impact Assessment
│   │   ├── lia.template.md                           # Legitimate Interest Assessment
│   │   ├── consent.policies.md                       # by channel & country
│   │   └── dpo.checklist.md
│   ├── tcf/
│   │   ├── cmp.api.ts                                # IAB TCF v2.2 integration
│   │   └── purpose.map.ts                            # mapare scopuri → activități
│   ├── pii/
│   │   ├── hashing.ts                                # SHA‑256/email/phone hashing
│   │   ├── redaction.ts                              # minimize payloads
│   │   └── residency.ts                              # EU data residency options
│   └── audit/
│       ├── access.logs.md
│       └── processing.activities.register.md
├── env/
│   ├── .env.example
│   ├── vault.template.hcl
│   └── README.md
├── compose/
│   ├── docker-compose.yml                             # api, web, db, redis, neo4j
│   ├── profiles/{compose.dev.yml,compose.prod.yml}
│   ├── Dockerfile.api
│   ├── Dockerfile.web
│   └── Dockerfile.worker
├── logs/{.gitkeep,README.md}
└── tests/
├── unit/
│   ├── identity.matching.test.ts
│   ├── enrichment.orchestrator.test.ts
│   ├── email.verification.test.ts
│   ├── dedupe.service.test.ts
│   └── lead.score.ml.test.ts
├── integration/
│   ├── accounts.router.test.ts
│   ├── outreach.router.test.ts
│   ├── neo4j.graph.sync.test.ts
│   └── termene.adapter.test.ts
├── e2e/
│   └── lead‑to‑opportunity.spec.ts               # import→enrich→route→close
└── fixtures/{leads/,accounts/,emails/}
```

### 2) Modele de date – esențiale (Drizzle + Graph)

- **Lead**: identități brute (email/phone/domain/url), sursă, `status`, `score`, `owner`, `tenantId`.
- **Account**: companie; CUI/TVA, CAEN, dimensiune, venituri, adrese, website, tehnologie (techgraph), `riskProfile`.
- **Contact**: persoană; consimțământ by‑channel, preferințe, job title, seniority, `gdprFlags`.
- **Opportunity**: pipeline/stadiu, forecastCategory, value, currency, expectedClose.
- **Activity**: tip (call/email/meeting/task), outcome, nextStep, linked entities.
- **EnrichmentSource**: vendor, fields coverage, trust score, freshness, provenance.
- **Graph (Neo4j)**: noduri `ACCOUNT`, `CONTACT`, `LEAD`, relații `WORKS_AT`, `OWNS`, `PARTNERS_WITH`, `CHILD_OF` (grupuri), `INTERACTED`.

### 3) Fluxuri funcționale cheie vettify

- **Identity Resolution & Dedupe**: matching determinist (email, domain+CUI) + fuzzy (nume, adresă) cu scor; **merge survivorship** pe reguli (freshness, trust, source priority) + audit lineage.
- **Firmographics EU‑grade**: prioritizare surse oficiale (RO: CUI/TVA, bilanțuri) + vendori EU (intent, tech install); reconciliere periodică & alerts diferențe.
- **Enrichment Orchestrator**: Temporal workflows: `enrich.lead` → `enrich.account` → `verify.email` → `score.icp` → `route.owner`. Timeouts & fallbacks per sursă; cache + TTL.
- **Email Discovery & Verification**: pattern‑guess + MX checks + API NeverBounce/ZeroBounce; hard‑bounce suppression & hygiene score; double‑opt‑in.
- **Outreach Sequences**: multi‑canal (email/SMS/WhatsApp) cu throttling, quiet hours, A/B, reply intent detect; auto‑stop la pozitiv/negativ.
- **Lead Scoring ML**: features din firmographics, intent signals, web events (Triggerra), istoric vânzări; model binar (close/won) + **uplift** pentru prescriptiv.
- **Graph360**: vizualizare grupuri, relații între conturi, parteneriate, shareholding; query „path to power” pentru stakeholders; recomandări next‑best‑account.

### 4) Securitate & Multi‑tenant vettify

- PKCE→OIDC→JWT (cp/identity), RBAC + entitlements (cp/licensing). RLS pe `tenantId`; mascare câmpuri sensibile; export guvernat cu registre de procesare.

### 5) Observabilitate vettify

- OTEL pentru enrichment/identity/outreach; KPIs: coverage, hygiene, conversion lift, reply rate; alerte pentru spike‑uri de bounce sau rate‑limit vendors.

### 6) Integrare cu restul suitei a vettify

- MF remote: `apps/web` încărcabil în `cp/suite-shell`.
- API: tRPC + OpenAPI; gateway global compune rute/policies.
- Evenimente: Kafka (`crm.lead.created`, `crm.account.enriched`, `crm.sequence.sent`).

### 7) Seeds & Playbooks (inițiale) vettify

- **ICP Templates** (SaaS/Manufacturing/Commerce) – câmpuri & greutăți scor.
- **Pipeline Defaults** – stadii + probabilități + SLA per stadiu.
- **Sequences** – cold outreach (etice, opt‑in), nurture, referral, re‑activation.

### 8) Config & Policies vettify

- **Field Mapping** (import CSV/XLSX, API) cu validatori CUI/IBAN/phone.
- **Source Priority** – matrice vendor×câmp (firm name, revenue, headcount, NAICS/CAEN etc.).
- **GDPR** – DPIA/LIA templates, residency EU, TCF v2.2 hooks pentru tracking/activation.

## Capitolul 12 - `geniuserp.app/` – Suite Orchestrator Surface & Tenant Operations

> Scop: aplicație stand‑alone (public website + customer portal) și „fața” suita **GeniusERP**. Nu dublează Control Plane (CP), ci îl **orchestrază și expune** pentru clienți: onboarding, SSO, management tenanți, abonamente & facturare (front), status & suport, documentație. Integrare strânsă cu `cp/identity`, `cp/licensing`, `gateway/`, `shared/feature-flags`, `shared/ui-design-system`.

- **Public site**: homepage, produse, prețuri, blog/docs, contact, legal.
- **Customer Portal**: workspace selector, provisioning subdomenii, SSO → **suite-shell**, gestionare licențe, plăți, invitații, audit bazic.
- **Status & Incidente**: status public, RSS/Atom, istorice incidente, SLO/SLA vizibile.
- **Docs**: ghiduri, changelog, API docs (agregat din `gateway/openapi`).

### 1) Structură generală (6–7 niveluri, până la fișiere)

```text
geniuserp.app/
├── package.json
├── tsconfig.json
├── nx.json
├── README.md
├── apps/
│   ├── web/                                         # Site public + marketing
│   │   ├── vite.config.ts
│   │   ├── public/
│   │   │   ├── manifest.webmanifest
│   │   │   ├── robots.txt                           # crawl policy
│   │   │   ├── sitemap.xml                          # SEO index
│   │   │   └── assets/
│   │   │       ├── images/
│   │   │       └── fonts/
│   │   └── src/
│   │       ├── main.tsx
│   │       ├── index.html
│   │       ├── routes/
│   │       │   ├── AppRoutes.tsx                    # mapare pagini publice
│   │       │   ├── paths.ts
│   │       │   └── loaders.ts
│   │       ├── pages/
│   │       │   ├── Home.tsx
│   │       │   ├── Products.tsx                     # listă aplicații & bundle-uri
│   │       │   ├── Pricing.tsx                      # planuri + feature matrix
│   │       │   ├── Showcase.tsx                     # studii de caz
│   │       │   ├── Blog.tsx                         # MDX blog
│   │       │   ├── Docs.tsx                         # agregator docs
│   │       │   ├── Contact.tsx
│   │       │   ├── Legal.tsx                        # ToS, Privacy, DPA
│   │       │   └── Status.tsx                       # embed status
│   │       ├── features/
│   │       │   ├── pricing/
│   │       │   │   ├── components/{PlanCard.tsx,FeatureMatrix.tsx}
│   │       │   │   ├── hooks/{usePlans.ts,useCheckout.ts}
│   │       │   │   └── state/{pricing.store.ts}
│   │       │   ├── docs/
│   │       │   │   ├── components/{DocPage.tsx,DocNav.tsx}
│   │       │   │   └── loaders/{mdx.loader.ts,openapi.loader.ts}
│   │       │   └── blog/
│   │       │       ├── components/{Post.tsx,PostList.tsx}
│   │       │       └── loaders/{mdx.loader.ts}
│   │       ├── api/
│   │       │   ├── client.ts                         # BFF gateway client
│   │       │   └── interceptors.ts                   # attach JWT (opțional), retry
│   │       ├── providers/{ThemeProvider.tsx,QueryProvider.tsx}
│   │       ├── i18n/{ro/en}/translation.json
│   │       └── styles/index.css
│   ├── portal/                                      # Customer Portal (app.geniuserp.app)
│   │   ├── vite.config.ts
│   │   ├── public/{manifest.webmanifest}
│   │   └── src/
│   │       ├── main.tsx
│   │       ├── index.html
│   │       ├── routes/
│   │       │   ├── AppRoutes.tsx                    # mapare pagini portal
│   │       │   ├── paths.ts
│   │       │   └── loaders.ts                       # pre‑încărcare tenant/org
│   │       ├── pages/
│   │       │   ├── Dashboard.tsx                    # overview tenant + acces rapid apps
│   │       │   ├── Workspaces.tsx                   # creare/renumire/ștergere
│   │       │   ├── Domains.tsx                      # subdomenii, DNS checks, TLS
│   │       │   ├── Users.tsx                        # invitații, roluri
│   │       │   ├── Licenses.tsx                     # planuri, seats, entitlements
│   │       │   ├── Billing.tsx                      # facturare, metode plată, istoric
│   │       │   ├── Security.tsx                     # SSO (SAML/OIDC), SCIM, MFA
│   │       │   ├── Audit.tsx                        # ultimele acțiuni notabile
│   │       │   └── Launch.tsx                       # hand‑off către suite‑shell
│   │       ├── features/
│   │       │   ├── workspaces/
│   │       │   │   ├── components/{WorkspaceList.tsx,WorkspaceForm.tsx}
│   │       │   │   ├── hooks/{useWorkspaces.ts,useProvision.ts}
│   │       │   │   └── state/{workspaces.store.ts}
│   │       │   ├── domains/
│   │       │   │   ├── components/{DomainForm.tsx,Verification.tsx}
│   │       │   │   └── hooks/{useDnsChecks.ts,useTLS.ts}
│   │       │   ├── licenses/
│   │       │   │   ├── components/{PlanPicker.tsx,SeatManager.tsx}
│   │       │   │   ├── hooks/{useEntitlements.ts,usePlans.ts}
│   │       │   │   └── state/{licenses.store.ts}
│   │       │   ├── billing/
│   │       │   │   ├── components/{PaymentMethod.tsx,InvoicesTable.tsx}
│   │       │   │   └── hooks/{useCheckout.ts,useBillingPortal.ts}
│   │       │   ├── users/
│   │       │   │   ├── components/{UserTable.tsx,InviteForm.tsx,RoleEditor.tsx}
│   │       │   │   └── hooks/{useUsers.ts,useRoles.ts}
│   │       │   └── security/
│   │       │       ├── components/{SSOConfig.tsx,SCIMConfig.tsx,MFAConfig.tsx}
│   │       │       └── hooks/{useSso.ts,useScim.ts,useMfa.ts}
│   │       ├── api/
│   │       │   ├── client.ts                         # tRPC/OpenAPI → gateway
│   │       │   └── interceptors.ts                   # PKCE→JWT attach, tenant header
│   │       ├── providers/{AuthProvider.tsx,QueryProvider.tsx,ThemeProvider.tsx}
│   │       ├── guards/{RequireAuth.tsx,RequireEntitlement.tsx}
│   │       ├── i18n/{ro/en}/translation.json
│   │       └── styles/index.css
│   ├── status/                                      # Public status page (status.geniuserp.app)
│   │   ├── vite.config.ts
│   │   └── src/
│   │       ├── main.tsx
│   │       ├── pages/{Status.tsx,History.tsx}
│   │       ├── api/client.ts                         # read‑only status API
│   │       └── rss/atom.ts                           # feed generator
│   └── docs/                                        # Docs (MDX) + API (OpenAPI)
│       ├── vite.config.ts
│       └── src/
│           ├── mdx/
│           │   ├── getting-started.mdx
│           │   ├── suite-architecture.mdx
│           │   ├── security.mdx
│           │   └── changelog.mdx
│           ├── api/
│           │   ├── openapi.loader.ts                 # agregare din gateway
│           │   └── components/{ApiSidebar.tsx,ApiPage.tsx}
│           └── pages/{Docs.tsx,Api.tsx}
├── api/                                            # BFF / Edge pentru web+portal+status
│   ├── src/
│   │   ├── index.ts                                 # bootstrap Fastify v5.6.1
│   │   ├── config/
│   │   │   ├── env.ts                               # zod schema + loader
│   │   │   └── security.ts                          # CORS, helmet, rate‑limit
│   │   ├── auth/
│   │   │   ├── pkce.guard.ts                        # enforce PKCE flow
│   │   │   ├── requireAuth.ts                       # JWT verify (cp/identity)
│   │   │   └── tenants.ts                           # resolve tenant din host
│   │   ├── adapters/
│   │   │   ├── identity.client.ts                   # bridge către cp/identity
│   │   │   ├── licensing.client.ts                  # bridge către cp/licensing
│   │   │   ├── billing.client.ts                    # Stripe/Revolut portal
│   │   │   ├── gateway.client.ts                    # gateway agregat
│   │   │   └── status.client.ts                     # citire status
│   │   ├── portal/
│   │   │   ├── tenants.router.ts                    # CRUD tenanți/workspaces
│   │   │   ├── domains.router.ts                    # verificări DNS/TLS
│   │   │   ├── users.router.ts                      # invitații/roluri (proxy cp)
│   │   │   ├── licenses.router.ts                   # planuri/seats/entitlements
│   │   │   ├── billing.router.ts                    # checkout/webhooks redirect
│   │   │   └── audit.router.ts                      # ultimele acțiuni (read‑only)
│   │   ├── web/
│   │   │   ├── pricing.router.ts                    # planuri publice + feature matrix
│   │   │   ├── contact.router.ts                    # formulare contact → CRM
│   │   │   └── sitemap.router.ts                    # sitemaps dinamic
│   │   ├── docs/
│   │   │   └── openapi.aggregate.ts                 # agregă din gateway
│   │   ├── telemetry/{otel.ts,pino.ts}
│   │   ├── health/{liveness.ts,readiness.ts}
│   │   └── server.ts
│   └── Dockerfile
├── workers/                                        # joburi asincrone pentru portal
│   ├── provisioning/
│   │   ├── create-tenant.ts                         # alocă tenant + DB/schema
│   │   ├── create-subdomain.ts                      # DNS API + certs (Traefik)
│   │   ├── seed-defaults.ts                         # roluri, plan trial, flags
│   │   └── notify-webhooks.ts                       # evenimente către apps
│   ├── billing/
│   │   ├── invoice.sync.ts                          # reconciliere cu procesator
│   │   └── dunning.ts                               # retry plăți & notificări
│   └── emails/
│       ├── templates/{welcome.mjml,invite.mjml}
│       └── sender.ts
├── db/
│   ├── drizzle/
│   │   ├── schema.ts                                # tenants, domains, plans, seats
│   │   └── migrations/
│   ├── seeds/seed.ts
│   └── scripts/{migrate.sh,reset.sh}
├── env/
│   ├── .env.example
│   ├── vault.template.hcl
│   └── README.md
├── compose/
│   ├── docker-compose.yml                           # api, web, portal, status, docs
│   ├── profiles/{compose.dev.yml,compose.prod.yml}
│   ├── Dockerfile.api
│   ├── Dockerfile.web
│   ├── Dockerfile.portal
│   ├── Dockerfile.status
│   └── Dockerfile.docs
├── logs/{.gitkeep,README.md}
└── tests/
├── unit/
│   ├── tenants.router.test.ts
│   ├── licenses.router.test.ts
│   ├── billing.client.test.ts
│   └── provisioning.create-tenant.test.ts
├── integration/
│   ├── pkce.guard.flow.test.ts
│   ├── identity.bridge.test.ts
│   ├── licensing.bridge.test.ts
│   └── openapi.aggregate.test.ts
├── e2e/
│   └── signup‑to‑launch.spec.ts                 # signup→provision→SSO→suite‑shell
└── fixtures/{plans/,tenants/,domains/}
```

### 2) Contracte & Evenimente (interfețe cu CP și suita)

- **Bridge CP**: `identity.client.ts` (creare utilizator/invitații, SSO settings), `licensing.client.ts` (planuri, entitlements, metering), `billing.client.ts` (checkout/portal), `gateway.client.ts` (OpenAPI union + service discovery).
- **Events (Kafka)**: `tenant.created`, `tenant.domain.verified`, `license.plan.changed`, `billing.payment.failed`, `user.invited`, `user.accepted`.

### 3) Fluxuri cheie geniuserp.app

- **Onboarding**: signup → verificare domeniu (opțional) → creare tenant → seed defaults → alegere plan trial → invitații → Launch (handoff la `cp/suite-shell`).
- **SSO Enterprise**: configurare OIDC/SAML, test conexiune, enforce SSO, SCIM provisionare automată.
- **Provisioning Subdomenii**: verificări DNS (TXT/CNAME), emitere certificate (Traefik ACME), mapare routes.
- **Billing & Licențe**: checkout, dunning, upgrade/downgrade, seat management, entitlements sincronizate în SDK‑urile app‑urilor.
- **Docs & API**: agregare OpenAPI din `gateway` + MDX docs, changelog sincronizat din monorepo tags.

### 4) Securitate & Multi‑tenant geniuserp.app

- PKCE→OIDC→JWT (via `cp/identity`). RLS pe `tenantId` în tabele portal. Guard pentru entitlement la nivel de rută UI + API. Audit trail la acțiuni critice.

### 5) Observabilitate geniuserp.app

- OTEL: traces pentru provisioning/billing; dashboards de funnel (signup→launch), alerte pentru eșec provisioning/dunning > N.

### 6) Integrare în suita generala a geniuserp.app

- „Launch” deschide `cp/suite-shell` cu tenant context + token SSO. Portalul devine sursa principală pentru operațiuni tenant (users, domains, licenses, billing) — CP rămâne intern (adminită de echipa noastră).

## Capitolul 13 - `gateway/` – API Gateway, BFF & Policy Enforcement (suite‑wide)

> Scop: layer unic de **intrare** în suită pentru UI‑uri (BFF), agregare API‑uri cross‑app (tRPC + OpenAPI), **policy enforcement** (authZ pe roluri + entitlements + tenant RLS), **rate‑limiting & caching**, observabilitate, **schema governance** și **service discovery**. Nu dublează CP; îl folosește (identity/licensing) și compune interfețe stabile pentru clienți interni/externi.

### 1) Structură generală (6–7 niveluri)

```text
gateway/
├── package.json
├── tsconfig.json
├── nx.json
├── README.md
├── bff/                                           # BFF (edge) pentru frontends (web, portal)
│   ├── src/
│   │   ├── index.ts                               # bootstrap Fastify v5.6.1 (PNPM workspace)
│   │   ├── server.ts                              # server + graceful shutdown
│   │   ├── config/
│   │   │   ├── env.ts                             # zod schema + loader (PORT, CORS…)
│   │   │   └── cors.ts                            # per-origin policies (tenants)
│   │   ├── security/
│   │   │   ├── pkce.guard.ts                      # impune PKCE la rute sensibile
│   │   │   ├── jwt.verify.ts                      # validate access token (cp/identity JWKS)
│   │   │   ├── tenant.context.ts                  # rezolvă tenant din host/header
│   │   │   ├── rbac.middleware.ts                 # role → permission map
│   │   │   └── entitlement.guard.ts               # verifică feature flags/licensing
│   │   ├── adapters/                              # proxiere către serviciile interne
│   │   │   ├── http.proxy.ts                      # http-proxy middlewares (timeouts, retries)
│   │   │   ├── services.registry.ts               # service discovery (static + health)
│   │   │   ├── identity.client.ts                 # cp/identity → OIDC/JWKS/Introspection
│   │   │   ├── licensing.client.ts                # cp/licensing → entitlements/metering
│   │   │   └── telemetry.client.ts                # observability hooks (OTEL)
│   │   ├── caching/
│   │   │   ├── key.builder.ts                     # cache key = route+tenant+claims
│   │   │   ├── redis.client.ts                    # Redis client + namespaces
│   │   │   └── policies.ts                        # TTL/STALE‑WHILE‑REVALIDATE per endpoint
│   │   ├── ratelimit/
│   │   │   ├── sliding.window.ts                  # algoritm per IP/user/tenant
│   │   │   ├── redis.store.ts                     # bucket storage
│   │   │   └── policies.ts                        # plan‑aware (free/pro/enterprise)
│   │   ├── compression/
│   │   │   └── brotli.gzip.ts                     # compresie condițională
│   │   ├── routers/
│   │   │   ├── portal.router.ts                   # rute portal (tenants, domains, users)
│   │   │   ├── public.router.ts                   # pricing, blog, sitemap (cacheable)
│   │   │   ├── status.router.ts                   # status public read‑only
│   │   │   ├── upload.router.ts                   # uploaduri semnate (S3/GCS presigned)
│   │   │   └── proxy.router.ts                    # /api/{app}/… → servicii interne
│   │   ├── middlewares/
│   │   │   ├── error.handler.ts                   # ProblemDetails (RFC7807)
│   │   │   ├── request.id.ts                      # correlationId, traceparent bridge
│   │   │   ├── request.log.ts                     # pino http logger + redaction
│   │   │   ├── health.ts                          # liveness/readiness
│   │   │   └── sane.defaults.ts                   # helmet, hsts, origin checks
│   │   ├── telemetry/{otel.ts,pino.ts}
│   │   └── tests/
│   │       ├── e2e/
│   │       │   └── bff.e2e.spec.ts                # flow: PKCE→JWT→proxy entitlement
│   │       ├── integration/{ratelimit.test.ts,cache.test.ts}
│   │       └── unit/{jwt.verify.test.ts}
│   └── Dockerfile
├── api-gateway/                                   # agregator servicii (stabilizează API public)
│   ├── src/
│   │   ├── index.ts                               # bootstrap (Fastify v5.6.1 acceptable)
│   │   ├── server.ts
│   │   ├── config/{env.ts,security.ts}
│   │   ├── auth/
│   │   │   ├── jwks.client.ts                     # JWKS (cp/identity) cu cache & rotate
│   │   │   ├── jwt.authz.ts                       # scope → policy → route binding
│   │   │   └── mTLS.ts                            # opțional: mTLS toward internal SVs
│   │   ├── validation/
│   │   │   ├── zod.middleware.ts                  # request/response schema checks
│   │   │   └── openapi.validator.ts               # sync cu spec generată
│   │   ├── policies/
│   │   │   ├── opa.engine.ts                      # OPA/REGO eval (bundles locale)
│   │   │   ├── rules/
│   │   │   │   ├── authz.rego                     # reguli role/permissions
│   │   │   │   ├── entitlements.rego              # reguli plan/feature
│   │   │   │   └── tenants.rego                   # RLS pe tenant
│   │   │   └── bundles/
│   │   │       ├── manifest.json                  # listează versiuni rules
│   │   │       └── *.tar.gz                       # pachete semnate cu KMS
│   │   ├── federation/
│   │   │   ├── trpc.compose.ts                    # compune routers din apps (remote)
│   │   │   ├── openapi.union.ts                   # unește OpenAPI (dedupe paths/tags)
│   │   │   ├── service.map.json                   # harta serviciilor + versiuni
│   │   │   └── health.poller.ts                   # poll health & ändpoints re‑load
│   │   ├── routers/
│   │   │   ├── public.router.ts                   # REST public (rate‑limited/cached)
│   │   │   ├── private.router.ts                  # REST private (JWT/OPA)
│   │   │   ├── trpc.router.ts                     # endpoint unic /trpc (merged)
│   │   │   └── graphql.router.ts                  # opțional: GraphQL stitching
│   │   ├── transforms/
│   │   │   ├── response.mask.ts                   # field masking per policy
│   │   │   └── pagination.normalizer.ts           # normalizează pagination
│   │   ├── plugins/
│   │   │   ├── caching.plugin.ts                  # decorators pt. cache control
│   │   │   ├── ratelimit.plugin.ts                # decorators pt. limit policies
│   │   │   └── idempotency.plugin.ts              # header Idempotency‑Key
│   │   ├── telemetry/{otel.ts,pino.ts}
│   │   └── tests/
│   │       ├── contract/
│   │       │   ├── openapi.contract.test.ts       # validare spec vs. implementare
│   │       │   └── trpc.contract.test.ts          # compatibilitate endpoints
│   │       ├── integration/{opa.test.ts,jwks.test.ts}
│   │       └── e2e/api-gateway.e2e.spec.ts        # authZ→policy→route→transform
│   └── Dockerfile
├── trpc-router/                                    # pachet TS: compozitor tRPC + client
│   ├── src/
│   │   ├── index.ts                                # export composeRouters(), infer types
│   │   ├── compose/
│   │   │   ├── loader.ts                           # încarcă meta routers din apps
│   │   │   ├── merge.ts                            # dedupe/namespace conflict aware
│   │   │   └── health.ts                           # handshake de compatibilitate
│   │   ├── client/
│   │   │   ├── createClient.ts                     # client multi‑service, auth aware
│   │   │   └── interceptors.ts                     # attach JWT, retry, tenant
│   │   ├── types/
│   │   │   ├── RouterMeta.ts                       # descriere routers (version, tags)
│   │   │   └── index.ts
│   │   └── tests/{merge.test.ts,types.test.ts}
│   ├── package.json
│   └── README.md
├── openapi/                                        # agregare OpenAPI 3 + UI (Scalar)
│   ├── src/
│   │   ├── loaders/
│   │   │   ├── fetch.from.apps.ts                  # colectează specs din apps
│   │   │   ├── normalize.ts                        # ref‑resolver, $id fix, tags
│   │   │   └── merge.ts                            # one big spec + per‑domain specs
│   │   ├── validators/
│   │   │   ├── spectral.ruleset.yaml               # calitate & styleguide
│   │   │   └── spectral.validate.ts
│   │   ├── publishers/
│   │   │   ├── save.bundle.ts                      # distribuie în /public/specs
│   │   │   └── s3.publish.ts                       # publish versiuni (immutable)
│   │   ├── ui/
│   │   │   ├── server.ts                           # serve Swagger/Scalar static
│   │   │   └── pages/{index.html,styles.css}
│   │   └── cli.ts                                   # `pnpm gateway:openapi build`
│   ├── public/specs/                                # output generat
│   └── Dockerfile
├── policies/                                       # politici declarative (OPA + JSON)
│   ├── rego/
│   │   ├── authz.rego                              # RBAC/ABAC
│   │   ├── entitlements.rego                       # plan/feature → allow/deny
│   │   ├── tenants.rego                            # scoping pe tenant/org
│   │   └── common.rego                             # helpers (time, strings)
│   ├── json/
│   │   ├── rbac.roles.json                         # roluri & permisiuni
│   │   ├── entitlements.map.json                   # mapping plans → features
│   │   └── routes.policies.json                    # rute → policy bindings
│   ├── bundles/
│   │   ├── build.ts                                # compilează & semnează bundle OPA
│   │   └── README.md
│   └── tests/{rego.unit.test.md,policies.e2e.md}
├── discovery/                                      # service discovery + health
│   ├── registry/
│   │   ├── services.yaml                           # static seed: apps & CP
│   │   ├── templates/
│   │   │   └── service.template.yaml               # schemă pentru noi servicii
│   │   └── sync.ts                                  # sync din compose/k8s
│   ├── health/
│   │   ├── poller.ts                               # verifică /health per service
│   │   ├── circuit.breaker.ts                      # degrade/disable on fail
│   │   └── status.cache.ts                         # cache status + TTL
│   └── tests/{registry.test.ts,health.test.ts}
├── schema-governance/                              # contracte API & versiuni
│   ├── events/                                     # topic schemas (JSON Schema/Avro)
│   │   ├── topics.map.ts                           # nume canonice topics
│   │   ├── jsonschema/                             # schema JSON per event
│   │   ├── avro/                                   # avro schema + compat
│   │   └── versions/                               # migratori v1→v2
│   ├── http/
│   │   ├── styleguide.md                           # convenții REST
│   │   ├── spectral.ruleset.yaml                   # reguli Spectral
│   │   └── lint.pipeline.ts                        # CI lint pt. specs
│   ├── trpc/
│   │   ├── meta.contract.ts                        # descriere routers + versioning
│   │   └── compat.check.ts                         # tests între gateway ↔ apps
│   └── README.md
├── security/                                       # chei, JWKS cache, KMS, secrets
│   ├── jwks.cache.ts                               # cache cu exp & background refresh
│   ├── kms.client.ts                               # semnare bundle/policies
│   ├── secrets.ts                                  # loader (Vault template aware)
│   └── README.md
├── observability/
│   ├── telemetry/{otel.ts,pino.ts}
│   ├── metrics/
│   │   ├── prometheus.ts                           # expune /metrics
│   │   └── histograms.ts                           # lat/size buckets
│   ├── logs/
│   │   └── redaction.ts                            # PII scrubbing în gateway
│   └── dashboards/
│       ├── grafana/{gateway.json,bff.json}
│       └── alerts/{p1.yaml,p2.yaml}
├── scripts/
│   ├── dev.sh                                      # run cu nodemon + watch merge
│   ├── smoke.sh                                    # sanity: auth→policy→route
│   ├── publish-openapi.sh                          # build + push specs
│   └── README.md
├── env/
│   ├── .env.example
│   ├── vault.template.hcl
│   └── README.md
├── compose/
│   ├── docker-compose.yml                          # bff + api-gateway + redis (cache+rl)
│   ├── profiles/{compose.dev.yml,compose.prod.yml}
│   ├── Dockerfile.bff
│   ├── Dockerfile.gateway
│   └── README.md
└── tests/
├── e2e/
│   └── signup-to-app.spec.ts                   # geniuserp.portal → suite-shell → app
├── integration/
│   ├── openapi.merge.test.ts
│   ├── trpc.compose.test.ts
│   └── policies.eval.test.ts
└── fixtures/{openapi/,trpc/,tokens/}
```

### 2) Fluxuri cheie gateway

- **AuthN/AuthZ**: PKCE→OIDC (via `cp/identity`) → JWT validat (JWKS cache) → RBAC + entitlements (via `cp/licensing`) → OPA policies.
- **BFF**: agregă rute pentru UI (portal, site, shell) și aplică caching+ratelimit atent la tenant/plan.
- **API Gateway**: unifică **tRPC** (federat) + **OpenAPI** (agregat) și oferă rute REST stabile; transformă răspunsurile și normalizează paginațiile.
- **Discovery & Health**: registry semiautomat din compose; poller degradează serviciile instabile (circuit breaker).
- **Schema Governance**: lint/validate specs, versionare evenimente (JSON Schema/Avro), compat check între apps și gateway.

### 3) Interfețe cu alte module

- `cp/identity` → JWKS, claims, OIDC; **bff/security/jwt.verify.ts** folosește cache + rotație chei.
- `cp/licensing` → entitlements & metering; **security/entitlement.guard.ts** blochează rutele fără drepturi.
- `shared/feature-flags` → toggles pentru rollout endpointuri noi.
- Aplicații stand‑alone → publică `trpc` routers și `openapi` specs; **federation/** le compune.

### 4) Observabilitate & SLO

- OTEL traces pe hop‑uri (BFF→Gateway→Service), Prometheus metrics (lat, err rate, pXX), dashboards grafana preset.
- Alarme: `5xx_rate>1%` 5m, `p95_latency>1s` 10m, `auth_fail_spike`.

### 5) Securitate

- Strict transport security (HSTS), CORS pe allowlist din tenants, rate‑limit adaptiv pe plan, redaction PII în logs, mTLS opțional spre servicii sensibile.

### 6) Deploy & CI

- Compose per modul + orchestrator root; job CI pentru **openapi build + spectral lint + publish**; contract tests pentru compatibilitate înainte de release.

## Capitolul 14 - `proxy/` – Edge Proxy, Ingress & Routing (Traefik primary, Caddy optional)

> Rol: stratul **edge** al suitei GeniusSuite. Face terminare TLS (ACME/LE), rutare pe domenii/subdomenii către serviciile interne (gateway, cp, apps), **forward‑auth** către `cp/identity` (PKCE→OIDC→JWT), **security headers/WAF**, **rate‑limit & buffering**, **HTTP/2 + HTTP/3 (QUIC)**, **WebSocket** pass‑through, **observabilitate**. Mode „hibrid”: *compose per app* + *compose orchestrator root*.

### 1) Structură director (6–7 niveluri) cu fișiere comentate

```text
proxy/
├── traefik/                                        # Stack Traefik (primar)
│   ├── static/                                     # Config static (cerut la boot)
│   │   ├── traefik.yml                             # entryPoints, providers, log, metrics
│   │   ├── dynamic-providers.yml                   # activare providers: file, docker
│   │   ├── access-log.yml                          # format JSON, redactare PII
│   │   └── telemetry.yml                           # Prometheus, OTEL exporter
│   ├── dynamic/                                    # Config dinamic (rute/middlewares)
│   │   ├── middlewares/                            # colecție middlewares reutilizabile
│   │   │   ├── security-headers.yml                # HSTS, CSP, XFO, Referrer-Policy
│   │   │   ├── compression.yml                     # gzip+brotli condițional
│   │   │   ├── ratelimit.yml                       # sliding window pe IP/tenant
│   │   │   ├── ip-allowlist.yml                    # allow CIDR pentru panouri admin
│   │   │   ├── oauth-forwardauth.yml               # forward auth → cp/identity
│   │   │   ├── cors.yml                            # CORS per origin (tenants)
│   │   │   ├── cache-headers.yml                   # Cache-Control pentru assets
│   │   │   ├── retry.yml                           # retry on idempotent, backoff
│   │   │   ├── buffering.yml                       # request/response buffering
│   │   │   └── circuit-breaker.yml                 # health‑aware CB
│   │   ├── routers/                                # definiri de rute per domeniu
│   │   │   ├── geniuserp.yml                       # site+portal+docs+status
│   │   │   ├── archify.yml
│   │   │   ├── cerniq.yml
│   │   │   ├── flowxify.yml
│   │   │   ├── iwms.yml
│   │   │   ├── mercantiq.yml
│   │   │   ├── numeriqo.yml
│   │   │   ├── triggerra.yml
│   │   │   └── vettify.yml
│   │   ├── services/                               # servicii interne (load balancers)
│   │   │   ├── gateway.yml                         # BFF/API Gateway backends
│   │   │   ├── cp.yml                              # suite-shell/admin/login/identity/licensing
│   │   │   ├── archify.yml
│   │   │   ├── cerniq.yml
│   │   │   ├── flowxify.yml
│   │   │   ├── iwms.yml
│   │   │   ├── mercantiq.yml
│   │   │   ├── numeriqo.yml
│   │   │   ├── triggerra.yml
│   │   │   └── vettify.yml
│   │   ├── tls/                                     # certs policies & mTLS intern
│   │   │   ├── certificates.yml                     # mapping wildcard/ACME certs
│   │   │   ├── options.yml                          # minVersion TLS1.2, curves, sni
│   │   │   └── mtls.yml                             # clientAuth req. pentru zone sensibile
│   │   └── dashboards/                              # expunere UI Traefik (protejat)
│   │       ├── dashboard.yml
│   │       └── whoami.yml                           # service de test routare
│   ├── acme/                                        # storage pentru ACME (persistență)
│   │   └── acme.json                                # certificare Let's Encrypt (600 perms)
│   ├── certificates/                                # certuri manuale (fallback/self‑signed)
│   │   ├── README.md
│   │   ├── fullchain.pem
│   │   └── privkey.pem
│   ├── files/                                       # config provider „file” (templating)
│   │   ├── tenants/                                 # fișiere generate per tenant
│   │   │   └── tenant-<id>.yml                      # host rules, middleware chain
│   │   └── templates/
│   │       ├── tenant.template.yml                  # șablon rute pentru tenant nou
│   │       └── service.template.yml                 # șablon service intern
│   ├── health/                                      # health endpoints & probes
│   │   ├── liveness.sh                              # shell checks pentru container
│   │   └── readiness.sh
│   ├── logs/
│   │   ├── access/                                  # loguri de acces (JSON)
│   │   └── traefik/                                 # loguri Traefik runtime
│   ├── compose/
│   │   ├── docker-compose.yml                       # serviciu traefik + rețele shared
│   │   ├── profiles/
│   │   │   ├── compose.dev.yml
│   │   │   ├── compose.staging.yml
│   │   │   └── compose.prod.yml
│   │   └── README.md
│   └── README.md                                    # ghid complet config Traefik
├── caddy/                                           # Stack Caddy (opțional / profil)
│   ├── Caddyfile                                    # declarativ: domenii→upstreams
│   ├── modules/                                     # extensii: rate‑limit, jwt, etc.
│   │   ├── ratelimit.json
│   │   ├── security.json
│   │   └── compress.json
│   ├── tls/
│   │   ├── acme.json                                # storage ACME Caddy
│   │   └── policies.json                            # curbe, cipher suites
│   ├── sites/                                       # split pe domenii
│   │   ├── geniuserp.caddy
│   │   ├── archify.caddy
│   │   ├── cerniq.caddy
│   │   ├── flowxify.caddy
│   │   ├── iwms.caddy
│   │   ├── mercantiq.caddy
│   │   ├── numeriqo.caddy
│   │   ├── triggerra.caddy
│   │   └── vettify.caddy
│   ├── compose/
│   │   └── docker-compose.yml
│   └── README.md
├── forward-auth/                                   # micro‑serviciu forwardAuth (fallback)
│   ├── src/
│   │   ├── index.ts                                 # Fastify v5.6.1: validează JWT vs JWKS
│   │   ├── config/env.ts                            # issuer, audience, cache jwks
│   │   ├── jwks/cache.ts                            # cache & rotație chei
│   │   ├── middlewares/requireAuth.ts               # 200/401/403 pe baza claims
│   │   ├── multi-tenant/tenant.resolver.ts          # host→tenant map
│   │   └── server.ts
│   ├── tests/
│   │   ├── jwks.test.ts
│   │   └── auth.flow.test.ts
│   ├── Dockerfile
│   └── README.md
├── waf/                                            # protecție L7: patterns & rules
│   ├── rules/                                       # OWASP CRS-like (Traefik plugin)
│   │   ├── sql-injection.yaml
│   │   ├── xss.yaml
│   │   ├── lfi-rfi.yaml
│   │   ├── bot-detection.yaml
│   │   └── dos.yaml
│   ├── anomaly-scoring.yml                          # praguri și acțiuni
│   └── README.md
├── middlewares/                                    # cod custom (dacă nu e posibil in YAML)
│   ├── request-id.ts                                # correlationId → traceparent bridge
│   ├── redact-headers.ts                            # scoate PII din logs
│   └── README.md
├── discovery/                                      # integrare cu registry-ul suitei
│   ├── services.map.yml                             # alias→url intern (gateway, apps)
│   ├── sync-from-compose.ts                         # citește compose root → map
│   └── README.md
├── observability/
│   ├── prometheus/traefik.rules.yml                 # rules & alerts Traefik
│   ├── grafana/dashboards/traefik.json              # panou Traefik
│   ├── logs/parsers/traefik.json                    # parser pentru access log JSON
│   └── README.md
├── scripts/
│   ├── generate-tenant-route.ts                     # produce tenants/*.yml din template
│   ├── smoke.sh                                     # curl scenarii: 200, 302 auth, 403
│   ├── rotate-acme.sh                               # backup & rotate acme.json
│   ├── reload.sh                                    # trigger reload dinamic configs
│   └── README.md
├── env/
│   ├── .env.example                                 # ACME email, domains, resolvers
│   └── README.md
├── compose/
│   ├── docker-compose.yml                           # Traefik/Caddy + forward-auth
│   ├── profiles/{compose.dev.yml,compose.prod.yml}
│   ├── networks.yml                                 # rețele: edge, internal, observability
│   ├── volumes.yml                                  # acme, logs, certs
│   └── README.md
└── README.md                                        # cum se folosește proxy-ul în suită
```

### 2) `traefik/static/traefik.yml` – conținut exemplificativ (comentat)

```yaml
entryPoints:
web:
address: ":80"
http:
redirections:
entryPoint:
to: websecure
scheme: https
websecure:
address: ":443"
http3: true                       # HTTP/3 (QUIC) activat
serversTransport:
insecureSkipVerify: false           # verifică certuri upstream (mTLS opțional)
api:
dashboard: true
insecure: false
providers:
file:
directory: "/etc/traefik/dynamic"  # map la traefik/dynamic
watch: true
docker:
endpoint: "unix:///var/run/docker.sock"
exposedByDefault: false
certificatesResolvers:
letsencrypt:
acme:
email: admin@geniuserp.app
storage: /acme/acme.json
httpChallenge:
entryPoint: web
log:
level: INFO
accessLog:
filePath: "/logs/access/access.log"
bufferingSize: 100
metrics:
prometheus:
addEntryPointsLabels: true
addServicesLabels: true
```

### 3) `traefik/dynamic/routers/geniuserp.yml` – rute (site, portal, status, docs)

```yaml
http:
routers:
site:
rule: "Host(`geniuserp.app`) || Host(`www.geniuserp.app`)"
entryPoints: [websecure]
middlewares: [security-headers, compression]
service: gateway-site
tls:
certResolver: letsencrypt
portal:
rule: "Host(`app.geniuserp.app`)"
entryPoints: [websecure]
middlewares: [oauth-forwardauth, security-headers, compression, ratelimit]
service: gateway-portal
tls:
certResolver: letsencrypt
status:
rule: "Host(`status.geniuserp.app`)"
entryPoints: [websecure]
middlewares: [security-headers, compression]
service: gateway-status
tls:
certResolver: letsencrypt
docs:
rule: "Host(`docs.geniuserp.app`)"
entryPoints: [websecure]
middlewares: [security-headers, compression]
service: gateway-docs
tls:
certResolver: letsencrypt
services:
gateway-site:
loadBalancer:
servers:
- url: "http://gateway-bff:8080"
gateway-portal:
loadBalancer:
servers:
- url: "http://gateway-bff:8080"
gateway-status:
loadBalancer:
servers:
- url: "http://geniuserp-status:8082"
gateway-docs:
loadBalancer:
servers:
- url: "http://geniuserp-docs:8083"
```

### 4) `traefik/dynamic/middlewares/oauth-forwardauth.yml` – forward auth (OIDC/JWT)

```yaml
http:
middlewares:
oauth-forwardauth:
forwardAuth:
address: "http://forward-auth:3000/check"   # validează JWT (cp/identity JWKS)
trustForwardHeader: true
authResponseHeaders: ["X-User-Id","X-User-Roles","X-Tenant-Id"]
```

### 5) Compose (root) – extras `proxy/compose/docker-compose.yml`

```yaml
version: "3.9"
services:
traefik:
image: traefik:v3.1
command:
- --providers.file.directory=/etc/traefik/dynamic
- --providers.docker=true
- --entrypoints.web.address=:80
- --entrypoints.websecure.address=:443
- --api.dashboard=true
- --certificatesresolvers.letsencrypt.acme.email=${ACME_EMAIL}
- --certificatesresolvers.letsencrypt.acme.storage=/acme/acme.json
- --certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web
- --log.level=INFO
- --metrics.prometheus=true
ports:
- "80:80"
- "443:443"
volumes:
- ../traefik/static:/etc/traefik
- ../traefik/dynamic:/etc/traefik/dynamic
- ../traefik/acme:/acme
- ../traefik/logs:/logs
- /var/run/docker.sock:/var/run/docker.sock:ro
networks:
- edge
- internal
forward-auth:
build: ../forward-auth
environment:
- IDP_ISSUER=${IDP_ISSUER}
- IDP_AUDIENCE=${IDP_AUDIENCE}
networks:
- internal
networks:
edge:
external: true
internal:
external: true
```

### 6) Integrare cu orchestratorul root & per‑app compose

- **Per‑app**: fiecare aplicație are etichete Docker `traefik.enable=true`, `traefik.http.routers.<app>.rule=Host(...)`, sau folosim **providerul file** (recomandat pentru multi‑tenant) → fișiere generate în `traefik/files/tenants/tenant-<id>.yml` via `scripts/generate-tenant-route.ts`.
- **Orchestrator root**: atașează toate serviciile pe rețelele `edge` și `internal`, expune Traefik pe 80/443, gestionează ACME centralizat, logs și metrics.

### 7) Securitate

- **Headers**: HSTS, CSP strict (nonce), Referrer‑Policy, X‑Frame‑Options deny pe portal/admin.
- **Auth**: `forwardAuth` obligatoriu pentru subdomeniile aplicațiilor (exceptând public/health).
- **mTLS intern**: pentru servicii sensibile (identity/licensing/gateway‑admin) conform `dynamic/tls/mtls.yml`.
- **Rate‑limit**: per plan/tenant, protecție DoS; **circuit‑breaker** pe servicii instabile.
- **Logs**: access log JSON cu redactare PII; trimise la `observability/` (Loki + dashboards).

### 8) Observabilitate & Testare

- **Metrics**: Prometheus scrape; dashboards Grafana predefinite.
- **Smoke tests**: `scripts/smoke.sh` execută rute critice (200/302/403) pentru fiecare domeniu.
- **Health**: liveness/readiness pentru container Traefik + probe pe upstreams.

### 9) Proceduri operaționale (README)

- Adăugare tenant: rulează `scripts/generate-tenant-route.ts`, verifică DNS, reload config.
- Rotație ACME: `scripts/rotate-acme.sh` (backup → rotate → reload); permisiuni 600 pe `acme.json`.
- Failover: profil **Caddy** – pornește `caddy/compose/docker-compose.yml` și dezactivează Traefik.

## Capitolul 15 - # `scripts/` – DevOps, CI/CD & Tooling for GeniusSuite (root‑level)

> Rol: colecție unificată de **scripturi operaționale** pentru bootstrap monorepo, orchestrare Docker (model hibrid), baze de date (Drizzle), build & release, QA (e2e, load, security), guvernanță API (OpenAPI + tRPC), provisioning tenanți, observabilitate, și siguranță (secrets, SBoM). Toate scripturile suportă target **global** sau **per‑aplicație** (`--app vettify.app`) și **per‑mediu** (`--env dev|staging|prod`).

### 1) Arhitectura directorului (6–7 niveluri + fișiere)

```text
scripts/
├── README.md                                  # ghid complet: convenții, cum rulezi
├── common/                                     # utilitare partajate între scripturi
│   ├── lib/
│   │   ├── args.ts                             # parse CLI: --app, --env, --select
│   │   ├── fs.ts                               # safe fs ops, yaml/json helpers
│   │   ├── exec.ts                             # exec promisified + pretty logs
│   │   ├── docker.ts                           # helpers: compose up/down, inspect
│   │   ├── k8s.ts                              # (future) kubectl/helm helpers
│   │   ├── env.ts                              # .env loader + schema (zod)
│   │   ├── nx.ts                               # nx run & affected graph utils
│   │   ├── drizzle.ts                          # drizzle ORM wrappers per app │   │   ├── drizzle-kit.ts                      # drizzle-kit wrappers per app │   │   ├── openapi.ts                          # merge/validate/publish specs
│   │   ├── trpc.ts                             # discovery & compose routers
│   │   ├── kafka.ts                            # topics create/check (Kafka 4.1)
│   │   ├── otel.ts                             # otel collector ping/validate
│   │   └── index.ts
│   ├── templates/
│   │   ├── .env.example.hbs                    # generator .env per app
│   │   ├── compose.app.hbs                     # compose per-app template
│   │   ├── compose.override.hbs                # overrides dev/staging/prod
│   │   ├── k6.script.hbs                       # load test template
│   │   ├── zap.policy.hbs                      # ZAP baseline
│   │   ├── openapi.header.hbs                  # info block for specs
│   │   └── README.md
│   └── types/
│       ├── AppId.ts                            # "vettify.app" | "numeriqo.app" | …
│       ├── Envs.ts                             # "dev" | "staging" | "prod"
│       ├── ComposeProfile.ts                   # profile keys per app
│       └── index.ts
├── bootstrap/                                  # inițializare monorepo & standarde
│   ├── init-monorepo.ts                        # pnpm, nx, workspace config
│   ├── git-hooks.ts                            # husky + lint-staged setup
│   ├── setup-commitlint.ts                     # conventional commits
│   ├── setup-semantic-release.ts               # release automation
│   ├── generate-env.ts                         # .env pentru root & apps din template
│   ├── verify-stack.ts                         # Node 24 LTS/PNPM/NX/TS/Drizzle versiuni │   ├── post-install.sh                         # sanity checks după pnpm i
│   └── README.md
├── compose/                                    # orchestrare Docker (hibrid)
│   ├── up.ts                                   # pornește subset sau suita întreagă
│   ├── down.ts                                 # oprește & curăță rețele/volumes opțional
│   ├── restart.ts                              # restart controlat (respect dependențe)
│   ├── logs.ts                                 # tail -f filtrat pe servicii
│   ├── ps.ts                                   # status + health colorizat
│   ├── sync-proxy.ts                           # regen Traefik file provider din compose
│   ├── networks.ts                             # creează/validează rețelele edge/internal
│   ├── volumes.ts                              # list/clean volumes by pattern
│   ├── profiles.ts                             # switch profile dev/staging/prod
│   ├── examples/
│   │   ├── start-core.sh                       # proxy + gateway + cp + geniuserp
│   │   ├── start-bi.sh                         # cerniq + warehouse + gateway
│   │   └── start-crm.sh                        # vettify + numeriqo deps minime
│   └── README.md
├── db/                                         # DB lifecycle (PostgreSQL/Drizzle) │   ├── create.ts                                # creează DB/schema per tenant/app
│   ├── migrate.ts                               # rulează drizzle-kit migrations │   ├── seed.ts                                  # seeds inițiale (roles, plans, demo)
│   ├── reset.ts                                 # drop + recreate (dev only, guard)
│   ├── verify.ts                                # health checks (connect, rls, ext)
│   ├── backups/
│   │   ├── pg-dump.ts                           # dump per app/tenant
│   │   ├── pg-restore.ts                        # restore controlat
│   │   └── rotate.ts                            # rotație + politică retenție
│   ├── tenants/
│   │   ├── create-tenant.ts                     # alocă schema/db + seed defaults
│   │   ├── delete-tenant.ts                     # cleanup complet cu protecții
│   │   └── list-tenants.ts                      # inventar + checks
│   ├── drizzle/
│   │   ├── generate.ts                          # pnpm -w drizzle-kit generate per app
│   │   ├── studio.ts                            # deschide Drizzle Studio targetat
│   │   └── validate.ts                          # sync schema.ts ↔ migrations
│   ├── drizzle/
│   │   ├── generate.ts                          # drizzle-kit generate (shared)
│   │   └── diff.ts                              # compară schemă vs. DB
│   └── README.md
├── api/                                        # guvernanță API: tRPC + OpenAPI
│   ├── trpc/
│   │   ├── discover.ts                          # descoperă routers expuse de apps
│   │   ├── compose.ts                           # compune routers + health contract
│   │   ├── typespec.ts                          # export tipuri combinate pentru clients
│   │   └── validate.ts                          # smoke tests pe rute critice
│   ├── openapi/
│   │   ├── collect.ts                           # fetch specs din apps & gateway
│   │   ├── normalize.ts                         # $ref, ids, tags, servers
│   │   ├── lint.ts                              # Spectral ruleset (style + quality)
│   │   ├── bundle.ts                            # one big spec + per‑domain bundles
│   │   ├── publish.ts                           # copy către geniuserp.docs + S3
│   │   └── README.md
│   └── contracts/
│       ├── events.sync.ts                        # JSON Schema/Avro sync către registry
│       ├── topics.ensure.ts                      # creează topics Kafka + ACL‑uri
│       └── README.md
├── qa/                                         # Quality gates: e2e, load, security
│   ├── e2e/
│   │   ├── run.ts                                # Playwright runner multi‑app
│   │   ├── report.ts                             # agregare rapoarte (html/junit)
│   │   ├── specs/
│   │   │   ├── signup-to-launch.spec.ts         # flow portal → suite‑shell
│   │   │   ├── entitlement-guard.spec.ts        # blocare acces fără licență
│   │   │   ├── tenancy-routing.spec.ts          # subdomeniu → tenant context
│   │   │   └── billing-dunning.spec.ts          # scenarii retry plăți
│   │   └── fixtures/                            # users, tenants, plans demo
│   ├── load/
│   │   ├── k6/
│   │   │   ├── smoke.js                          # smoke 1–5 rps
│   │   │   ├── ramping.js                        # ramp stratificat pe rute cheie
│   │   │   ├── soak.js                           # test anduranță
│   │   │   ├── thresholds.js                     # SLO checks p95/p99/error rate
│   │   │   └── helpers.js                        # auth token fetch, randomizers
│   │   ├── run.ts                                # orchestrator k6 (local/docker)
│   │   └── README.md
│   ├── security/
│   │   ├── zap/
│   │   │   ├── baseline.ts                       # ZAP baseline scan (auth aware)
│   │   │   └── policies/
│   │   │       └── baseline.policy               # tuning fals pozitive
│   │   ├── semgrep/
│   │   │   ├── rules.yaml                        # set reguli TS/Node 24 LTS/React
│   │   │   └── ci.sh                             # runner semgrep
│   │   ├── snyk/
│   │   │   ├── monitor.sh                        # SCA monitor
│   │   │   └── test.sh                           # SCA test
│   │   ├── deps/
│   │   │   ├── audit.sh                          # pnpm audit + raport JSON
│   │   │   └── license-checker.ts                # licențe third‑party allowlist
│   │   └── README.md
│   ├── accessibility/
│   │   ├── axe.run.ts                            # axe-core pe pagini cheie
│   │   └── README.md
│   └── README.md
├── ci/                                         # pipeline helpers (local + CI providers)
│   ├── versioning/
│   │   ├── bump.ts                               # semantic version (conventional commits)
│   │   ├── changelog.ts                          # generare CHANGELOG.md
│   │   ├── tag.ts                                # git tag & push
│   │   └── release.ts                            # orchestrare release (artefacte)
│   ├── docker/
│   │   ├── build.ts                              # build imagini per app + tags
│   │   ├── push.ts                               # push imagini (registry)
│   │   └── cache.ts                              # buildx cache management
│   ├── quality/
│   │   ├── lint.ts                               # eslint + stylelint + prettier check
│   │   ├── test.ts                               # unit/integration
│   │   ├── typecheck.ts                          # tsc --noEmit
│   │   └── bundle-size.ts                        # măsurare bundle FE
│   ├── artifacts/
│   │   ├── collect.ts                            # strânge rapoarte (junit/html/json)
│   │   └── publish.ts                            # upload artefacte la CI
│   └── README.md
├── provisioning/                               # provisioning tenanți & domenii
│   ├── tenants/
│   │   ├── create.ts                             # creează tenant + seed + subdomeniu
│   │   ├── verify-domain.ts                      # DNS checks + TLS (Traefik ACME)
│   │   ├── assign-plan.ts                        # plan & entitlements
│   │   ├── invite-users.ts                       # invitații inițiale
│   │   └── delete.ts                             # teardown sigur
│   ├── domains/
│   │   ├── add.ts                                # adaugă domeniu custom tenantului
│   │   ├── remove.ts                             # remove + certificate revoke
│   │   └── verify.ts                             # TXT/CNAME validation
│   └── README.md
├── observability/                              # tooling op: logs, metrics, traces
│   ├── grafana/                                  # API scripts pt. import dashboards
│   │   ├── import.ts
│   │   └── set-datasources.ts
│   ├── prometheus/
│   │   ├── reload.ts                              # HUP la Prometheus la change rules
│   │   └── verify.ts                              # rule lint
│   ├── loki/
│   │   ├── push-sample.ts                         # trimite loguri demo
│   │   └── query.ts                               # exemplu query LogQL
│   ├── tempo/
│   │   └── tracegen.ts                            # generează traces demo
│   └── README.md
├── security/                                   # secrete, semnături, SBoM
│   ├── vault/
│   │   ├── login.ts                               # auth la Vault
│   │   ├── inject.ts                              # șabloane → env files
│   │   └── rotate.ts                              # rotație chei/tokeni
│   ├   ├── kms/
│   │   ├── sign.ts                                # semnare bundle/policies
│   │   ├── verify.ts                              # verificare semnătură
│   │   └── keys.list.ts
│   ├── sbom/
│   │   ├── generate.ts                            # Syft/CycloneDX
│   │   └── scan.ts                                 # Grype scan imagini
│   └── README.md
├── codegen/                                    # generatoare cod (client SDKs etc.)
│   ├── clients/
│   │   ├── openapi.ts                             # generează clients TS din specs
│   │   ├── trpc.ts                                # clients strongly‑typed
│   │   └── graphql.ts                             # (opțional) codegen GraphQL
│   ├── ui/
│   │   └── icons.ts                               # generare React icons din SVG
│   ├── drizzle/
│   │   ├── types.ts                                # Drizzle types → DTOs
│   │   └── zod.ts                                  # Drizzle schema → Zod schemas
│   └── README.md
├── makefile/                                   # aliasuri GNU make pt. comenzi frecvente
│   ├── Makefile                                  # targeturi: up, down, test, build, db-*
│   └── README.md
└── bin/                                        # entrypoints executabile (npm scripts)
├── gs                                      # CLI unificat (Node 24 LTS shebang)
├── gs.cmd                                  # Windows shim
└── README.md
```

### 2) `bin/gs` – CLI unificat (schelet)

```bash
#!/usr/bin/env node
import("../common/lib/args.js").then(async ({ parseArgs }) => {
const { cmd, app, env, rest } = parseArgs(process.argv.slice(2));
const mod = await import(`../${cmd}/index.js`).catch(() => null);
if (!mod?.default) {
console.error(`Unknown command: ${cmd}`);
process.exit(1);
}
await mod.default({ app, env, rest });
});
```

### 3) Exemple de comenzi uzuale (README)

- **Pornește suita minimă pentru onboarding:** `scripts/bin/gs compose up --profile core`
- **Migrare DB pentru `numeriqo.app` în staging:** `gs db migrate --app numeriqo.app --env staging`
- **Agregă & publică OpenAPI:** `gs api openapi publish --env prod`
- **Rulează e2e critice:** `gs qa e2e run --select signup-to-launch`
- **Creează tenant demo:** `gs provisioning tenants create --plan pro --domain acme.geniuserp.app`

### 4) Convenții

- Fiecare script **nu scrie** în repo fără prompt (`--yes`) și loghează în `logs/`.
- Toate scripturile acceptă `--dry-run`.
- Selectoare: `--app`, `--tag` (nx affected), `--env`, `--profile` (compose), `--tenant`.

### 5) Integrare cu celelalte module

- **proxy/**: `compose/sync-proxy.ts` regenerează file-provider din compose‑urile active.
- **gateway/**: `api/openapi/*` colectează & validează specs; `api/trpc/*` compune routers.
- **cp/**: `provisioning/*` apelează `identity/licensing` pentru SSO & entitlements.
- **shared/**: `codegen/*` folosește types & contracts pentru generarea SDK‑urilor.

### 6) Roadmap

- Profil **k8s** (Helm charts + skaffold dev loop).
- `gs doctor` pentru sănătate sistem end‑to‑end.
- Generare **tenant blueprints** (seturi de module+feature‑flags).

## Capitolul 16 - Database Schema – GeniusSuite (v1 core)

> Obiectiv: schemă completă **PostgreSQL 18** pentru suita GeniusSuite, optimizată pentru vânzare ca **stand‑alone apps** și ca **suită**. Include tabele, coloane, tipuri ENUM, indici, chei, constrângeri și politici de multi‑tenancy.

### 0. Arhitectură date & multi‑tenancy

- **Model recomandat (profesional, flexibil):**
- **DB per aplicație** (ex: `db_vettify`, `db_numeriqo`, `db_cerniq`, …) → izolare clară pentru vânzarea stand‑alone.
- **Schema per tenant** în interiorul fiecărei DB (ex: `tenant_acme`, `tenant_beta`). Pentru resurse globale (config/metadata): schema `public`.
- **DB comune suita:** `db_identity` (SSO, utilizatori, organizații), `db_licensing` (licențe, entitlements, metering), `db_gateway` (policy cache, registry), `db_observability` (logs/metrics/traces metadate).
- **BI/Data Mesh (cerniq.app):** Nu are o bază de date de warehouse proprie (DB-less). Acționează ca un consumator al "Produselor de Date" publicate de celelalte aplicații. Stochează doar metadate, definiții semantice și cache-uri de agregare.
- **Chei primare:** `UUID v7` nativ PG18 (coloană `id uuid PRIMARY KEY DEFAULT uuidv7()`; ordonare temporală bună fără extensii).
- **Coloane standard (toate tabelele business):**
- `id`, `tenant_id uuid NOT NULL` (FK către `identity.tenants.id`), `created_at timestamptz NOT NULL DEFAULT now()`, `updated_at timestamptz NOT NULL DEFAULT now()`, `created_by uuid NULL`, `updated_by uuid NULL`, `version int NOT NULL DEFAULT 1` (optimistic locking), `is_deleted boolean NOT NULL DEFAULT false` (soft delete).
- **Audit & RLS:**
- **RLS ON** la toate tabelele tenant‑scoped. Politici: `USING (tenant_id = current_setting('app.tenant_id', true)::uuid)`; `WITH CHECK` similar.
- Trigger `updated_at` on update; trigger `insert_tenant_guard` pentru a impune `tenant_id`.

### 1. DB: `db_identity` (SSO, utilizatori, org, SAML/OIDC)

**Schemas:** `public` (global), `auth` (session/index), `admin` (audit).

#### 1.1 Tabele cheie

- `public.tenants`
- `id uuid PK`, `slug citext UNIQUE`, `name text NOT NULL`, `status enum_tenant_status NOT NULL DEFAULT 'active'`, `plan_id uuid NULL`, `created_at`, `updated_at`
- **Index:** `ix_tenants_slug` (unique), `ix_tenants_status`
- **ENUM:** `enum_tenant_status = ('active','suspended','closed')`
- `public.organizations` (alias pentru „companii/realms” ale unui tenant)
- `id uuid PK`, `tenant_id uuid FK → tenants.id`, `name text`, `cui text NULL`, `country char(2)`, `timezone text`, `logo_url text NULL`, `created_at`, `updated_at`
- **Index:** `(tenant_id, name)`
- `public.users`
- `id uuid PK`, `email citext UNIQUE`, `password_hash text NULL`, `status enum_user_status NOT NULL DEFAULT 'active'`, `mfa_enabled boolean DEFAULT false`, `created_at`, `updated_at`
- **ENUM:** `enum_user_status = ('active','invited','blocked','deleted')`
- `public.user_identities` (OIDC/SAML/Passwordless)
- `id uuid PK`, `user_id uuid FK → users.id`, `provider enum_idp_provider`, `provider_sub text`, `created_at`
- **UQ:** `(provider, provider_sub)`
- **ENUM:** `enum_idp_provider=('password','google','microsoft','github','saml','magiclink')`
- `public.memberships`
- `id uuid PK`, `tenant_id`, `org_id uuid FK → organizations.id`, `user_id uuid FK → users.id`, `role_id uuid FK → roles.id`, `status enum_membership_status DEFAULT 'active'`, `created_at`
- **Index:** `uq_membership UNIQUE (org_id,user_id)`; `ix_membership_tenant_user`
- **ENUM:** `enum_membership_status=('active','pending','disabled')`
- `public.roles`
- `id uuid PK`, `tenant_id`, `key text`, `name text`, `description text`, `created_at`
- **UQ:** `(tenant_id, key)`
- `public.permissions`
- `id uuid PK`, `key text UNIQUE`, `description text`
- `public.role_permissions`
- `role_id uuid FK → roles.id`, `permission_id uuid FK → permissions.id`, `tenant_id`, `created_at`
- **PK:** `(role_id, permission_id)`; **Index:** `(tenant_id, role_id)`
- `auth.sessions` (SuperTokens compat)
- `session_handle text PK`, `user_id uuid`, `refresh_token_hash_2 text`, `session_data jsonb`, `expiry_time bigint`, `created_at`.
- **Index:** `ix_sessions_user_id`
- `admin.audit_logs`
- `id uuid PK`, `tenant_id`, `actor_id uuid`, `action text`, `resource text`, `meta jsonb`, `ip inet`, `ua text`, `ts timestamptz DEFAULT now()`
- **Index:** `(tenant_id, ts DESC)`, GIN `meta jsonb_path_ops`

**RLS:** ON pentru `organizations`, `memberships`, `roles`, `role_permissions`, `audit_logs`.

---

### 2. DB: `db_licensing` (planuri, entitlements, metering, billing refs)

**Schema:** `public`

- `plans` — **planuri comerciale**
- `id uuid PK`, `key text UNIQUE`, `name text`, `period enum_billing_period`, `price_cents int`, `currency char(3)`, `max_seats int`, `meta jsonb`, `created_at`, `updated_at`
- **ENUM:** `enum_billing_period=('monthly','yearly')`
- `features`
- `id uuid PK`, `key text UNIQUE`, `name text`, `description text`, `created_at`
- `plan_features`
- `plan_id uuid FK`, `feature_id uuid FK`, `limit_value numeric NULL`, `enforced boolean DEFAULT true`, `created_at`
- **PK:** `(plan_id, feature_id)`
- `subscriptions`
- `id uuid PK`, `tenant_id uuid`, `plan_id uuid FK`, `provider enum_billing_provider`, `provider_sub_id text`, `status enum_sub_status`, `seats int`, `trial_end date NULL`, `current_period_end timestamptz`, `created_at`, `updated_at`
- **ENUM:** `enum_billing_provider=('stripe','revolut','manual')`, `enum_sub_status=('active','past_due','canceled','trialing')`
- **Index:** `(tenant_id)`, `(provider, provider_sub_id)`
- `entitlements`
- `id uuid PK`, `tenant_id`, `feature_key text`, `value numeric NULL`, `source enum_ent_source`, `valid_from timestamptz`, `valid_to timestamptz NULL`
- **ENUM:** `enum_ent_source=('plan','manual','promo','contract')`
- **Index:** `(tenant_id, feature_key)`
- `usage_events`
- `id uuid PK`, `tenant_id`, `feature_key text`, `amount numeric`, `ts timestamptz`, `source_service text`, `meta jsonb`
- **Index:** `(tenant_id, feature_key, ts DESC)`, GIN `meta`

**RLS:** ON (tenant scoping). Triggers de calcul `entitlements` on plan change.

---

### 3. DB: `db_vettify` (CRM + Firmographics)

**Schemas:** `public` (meta), `tenant_*` (date tenant). Mai jos: tabele tenant‑scoped.

- `accounts` (companii/organizații)
- `id uuid PK`, `tenant_id`, `name text NOT NULL`, `website text`, `industry enum_industry NULL`, `size enum_company_size NULL`, `country char(2)`, `city text`, `address text`, `cui text NULL`, `registration_no text NULL`, `source enum_data_source DEFAULT 'manual'`, `score int DEFAULT 0`, `owner_id uuid NULL`, `created_at`, `updated_at`
- **ENUM:** `enum_industry=('agri','manufacturing','retail','services','it','other')`, `enum_company_size=('1-10','11-50','51-200','201-500','500+')`, `enum_data_source=('manual','import','api_termene','api_anaf')`
- **Index:** `ix_accounts_tenant_name`, `ix_accounts_cui UNIQUE NULLS NOT DISTINCT` (per tenant); triggere normalizare CUI.
- `contacts`
- `id uuid PK`, `tenant_id`, `account_id uuid FK → accounts.id`, `first_name text`, `last_name text`, `email citext`, `phone text`, `role text`, `linkedin text`, `owner_id uuid`, `created_at`, `updated_at`
- **Index:** `(tenant_id, email)`, `(account_id)`
- `leads`
- `id uuid PK`, `tenant_id`, `account_id uuid NULL FK`, `contact_id uuid NULL FK`, `source enum_lead_source`, `status enum_lead_status`, `score int`, `tags text[]`, `meta jsonb`, `owner_id uuid`, `created_at`, `updated_at`
- **ENUM:** `enum_lead_source=('web','inbound','outbound','event','partner','import')`, `enum_lead_status=('new','qualified','won','lost','nurture')`
- **Index:** `(tenant_id, status)`, GIN `tags`, GIN `meta`
- `opportunities`
- `id uuid PK`, `tenant_id`, `account_id uuid`, `name text`, `stage enum_pipeline_stage`, `amount numeric(18,2)`, `currency char(3)`, `close_date date NULL`, `probability int`, `owner_id uuid`, `created_at`, `updated_at`
- **ENUM:** `enum_pipeline_stage=('prospect','qualified','proposal','negotiation','won','lost')`
- **Index:** `(tenant_id, stage)`, `(tenant_id, close_date)`
- `activities`
- `id uuid PK`, `tenant_id`, `related_type enum_activity_ref`, `related_id uuid`, `type enum_activity_type`, `subject text`, `body text`, `due_at timestamptz NULL`, `done_at timestamptz NULL`, `owner_id uuid`, `created_at`
- **ENUM:** `enum_activity_ref=('lead','contact','opportunity','account','ticket')`, `enum_activity_type=('call','email','meeting','note','task')`
- **Index:** `(tenant_id, related_type, related_id)`, `(owner_id, due_at)`
- `firmographics`
- `id uuid PK`, `tenant_id`, `account_id uuid FK`, `anaf jsonb NULL`, `termene jsonb NULL`, `financials jsonb NULL`, `last_sync timestamptz`, `created_at`
- **Index:** `(tenant_id, account_id)`, GIN `financials`
- `segments`
- `id uuid PK`, `tenant_id`, `name text`, `criteria jsonb`, `created_at`, `updated_at`
- **Index:** GIN `criteria`
- `comms_channels` (B2B outbound readiness)
- `id uuid PK`, `tenant_id`, `type enum_channel_type`, `value text`, `verified boolean DEFAULT false`, `owner_id uuid`, `created_at`
- **ENUM:** `enum_channel_type=('email','phone','whatsapp','linkedin')`
- `deals` (alias pentru opportunities dacă Mercantiq nu e instalat) – **opțional**

**Relații & constrângeri:** FK la `accounts` și `contacts`; `owner_id` referință la `identity.users` (cross‑db via app layer). **RLS ON**

---

### 4. DB: `db_numeriqo` (Accounting RO + HR & Payroll)

**Schemas:** `public` (metadata), `tenant_*` pentru contabilitate și HR.

#### 4.1 Accounting – tabele de bază (partida dublă, RO)

- `chart_of_accounts`
- `id uuid PK`, `tenant_id`, `code text NOT NULL`, `name text NOT NULL`, `type enum_account_type`, `vat_relevant boolean DEFAULT false`, `currency char(3) NULL`, `is_active boolean DEFAULT true`, `parent_id uuid NULL FK → chart_of_accounts.id`, `created_at`, `updated_at`
- **ENUM:** `enum_account_type=('asset','liability','equity','revenue','expense','bifunctional','offbalance')`
- **UQ:** `(tenant_id, code)`; **Index:** `(tenant_id, parent_id)`
- `journals` (registre: vânzări, cumpărări, bancă, casă etc.)
- `id uuid PK`, `tenant_id`, `key enum_journal_key`, `name text`, `description text`, `created_at`
- **ENUM:** `enum_journal_key=('general','sales','purchases','cash','bank','payroll','fixed_assets','vat')`
- **UQ:** `(tenant_id, key)`
- `journal_entries`
- `id uuid PK`, `tenant_id`, `journal_id uuid FK`, `doc_no text`, `doc_date date`, `posting_date date NOT NULL`, `currency char(3)`, `fx_rate numeric(12,6)`, `reference text`, `created_by`, `created_at`
- **Index:** `(tenant_id, journal_id, posting_date)`, `(tenant_id, doc_no)`
- `journal_lines`
- `id uuid PK`, `tenant_id`, `entry_id uuid FK → journal_entries.id ON DELETE CASCADE`, `account_id uuid FK → chart_of_accounts.id`, `description text`, `debit numeric(18,2) NOT NULL DEFAULT 0`, `credit numeric(18,2) NOT NULL DEFAULT 0`, `vat_code_id uuid NULL FK → vat_codes.id`, `department_id uuid NULL`, `project_id uuid NULL`, `created_at`
- **CHK:** `debit = 0 OR credit = 0`, **Index:** `(tenant_id, account_id)`, `(tenant_id, vat_code_id)`
- `vat_codes`
- `id uuid PK`, `tenant_id`, `code text`, `rate numeric(5,2)`, `type enum_vat_type`, `is_reverse_charge boolean DEFAULT false`, `created_at`
- **ENUM:** `enum_vat_type=('output','input','exempt','non_taxable')`
- **UQ:** `(tenant_id, code)`
- `customers`, `suppliers` (parteneri contabili)
- `id uuid PK`, `tenant_id`, `name`, `cui`, `country`, `address`, `iban`, `payment_terms enum_payment_terms`, `created_at`
- **ENUM:** `enum_payment_terms=('prepaid','net15','net30','net45','net60')`
- **Index:** `(tenant_id, cui)`
- `invoices` (vânzări/achiziții)
- `id uuid PK`, `tenant_id`, `type enum_invoice_type`, `series text`, `number text`, `issue_date date`, `due_date date`, `partner_id uuid`, `currency char(3)`, `total_no_vat numeric(18,2)`, `vat_total numeric(18,2)`, `grand_total numeric(18,2)`, `status enum_invoice_status`, `efactura_id text NULL`, `created_at`, `updated_at`
- **ENUM:** `enum_invoice_type=('sale','purchase')`, `enum_invoice_status=('draft','issued','sent','paid','canceled')`
- **UQ:** `(tenant_id, type, series, number)`; **Index:** `(tenant_id, partner_id)`
- `invoice_lines`
- `id uuid PK`, `tenant_id`, `invoice_id uuid FK`, `product_id uuid NULL`, `description text`, `qty numeric(18,3)`, `unit text`, `unit_price numeric(18,4)`, `vat_code_id uuid`, `line_total numeric(18,2)`, `created_at`
- **Index:** `(tenant_id, invoice_id)`
- `fixed_assets`, `fa_depreciation_runs`
- active imobilizate + rulări amortizare (plan liniar/accelerat)

**Registre:** jurnale vânzări/cumpărări/casă/bancă se pot obține din `journal_entries/lines` + vederi materializate.

#### 4.2 HR & Payroll (RO)

- `employees`
- `id uuid PK`, `tenant_id`, `person_no text`, `cnp text ENCRYPTED`, `first_name`, `last_name`, `email`, `phone`, `address jsonb`, `hire_date date`, `fire_date date NULL`, `status enum_emp_status`, `department_id uuid`, `position text`, `contract_type enum_contract_type`, `work_time enum_work_time`, `salary_base numeric(18,2)`, `currency char(3)`, `created_at`, `updated_at`
- **ENUM:** `enum_emp_status=('active','suspended','terminated')`, `enum_contract_type=('cdi','cdd','part-time','internship')`, `enum_work_time=('full','part')`
- **Index:** `(tenant_id, person_no) UNIQUE`, `(tenant_id, cnp)`
- `payroll_runs`
- `id uuid PK`, `tenant_id`, `period date` (prima zi din lună), `status enum_payroll_status`, `created_at`, `closed_at`
- **ENUM:** `enum_payroll_status=('draft','calculated','approved','exported')`
- **UQ:** `(tenant_id, period)`
- `payroll_items`
- `id uuid PK`, `tenant_id`, `run_id uuid FK → payroll_runs.id`, `employee_id uuid FK → employees.id`, `code enum_pay_item_code`, `amount numeric(18,2)`, `qty numeric(10,2) DEFAULT 1`, `taxable boolean`, `created_at`
- **ENUM (ex.):** `enum_pay_item_code=('SAL_BASE','SPOR_NOAPTE','BONUS','RETINERE_CU','RETINERE_NET','CONCEDIU','ORE_SUPL')`
- **Index:** `(tenant_id, run_id, employee_id)`
- `leave_requests`
- `id uuid PK`, `tenant_id`, `employee_id`, `type enum_leave_type`, `start_date date`, `end_date date`, `status enum_leave_status`, `created_at`, `approved_by uuid NULL`
- **ENUM:** `enum_leave_type=('odihna','medical','fara_plata','evenimente')`, `enum_leave_status=('pending','approved','rejected')`
- `reges-online_exports`
- `id uuid PK`, `tenant_id`, `run_id uuid NULL`, `file_path text`, `status enum_export_status`, `created_at`
- **ENUM:** `enum_export_status=('generated','uploaded','error')`

**RLS:** ON. **Conformitate RO:** mapări conturi implicite, TVA, declarații (prin exporte).

---

### 5. DB: `db_archify` (Document Management)

- `documents`
- `id uuid PK`, `tenant_id`, `title text`, `doc_type enum_doc_type`, `owner_id uuid`, `storage_key text`, `mime_type text`, `size_bytes bigint`, `hash sha256`, `created_at`, `updated_at`
- **ENUM:** `enum_doc_type=('contract','invoice','po','hr','other')`
- **Index:** `(tenant_id, doc_type)`, `(tenant_id, owner_id)`
- `document_versions`
- `id uuid PK`, `tenant_id`, `document_id uuid FK`, `version int`, `storage_key text`, `hash sha256`, `created_at`, `created_by`
- **UQ:** `(tenant_id, document_id, version)`
- `tags` & `document_tags` (m:n)
- `tags`: `id`, `tenant_id`, `name text`; **UQ:** `(tenant_id, name)`
- `document_tags`: `document_id uuid`, `tag_id uuid`, **PK:** `(document_id, tag_id)`
- `ocr_jobs`
- `id uuid PK`, `tenant_id`, `document_id`, `status enum_job_status`, `engine text`, `lang text[]`, `text jsonb`, `created_at`, `completed_at`
- **ENUM:** `enum_job_status=('queued','processing','done','error')`
- `signatures`
- `id uuid PK`, `tenant_id`, `document_id`, `provider enum_sign_provider`, `status enum_sign_status`, `created_at`, `completed_at`
- **ENUM:** `enum_sign_provider=('pandadoc','adobe','internal')`, `enum_sign_status=('draft','sent','signed','declined')`

---

### 6. DB: `db_flowxify` (BPM + Collaboration + Intranet)

- `workflows`
- `id uuid PK`, `tenant_id`, `key text`, `name text`, `version int`, `definition jsonb`, `status enum_wf_status`, `created_at`, `updated_at`
- **ENUM:** `enum_wf_status=('active','disabled')`; **UQ:** `(tenant_id, key, version)`
- `workflow_runs`
- `id uuid PK`, `tenant_id`, `workflow_id uuid FK`, `status enum_run_status`, `started_at`, `ended_at`, `input jsonb`, `result jsonb`
- **ENUM:** `enum_run_status=('running','completed','failed','canceled')`
- `tasks`
- `id uuid PK`, `tenant_id`, `run_id uuid FK`, `assignee_id uuid NULL`, `title text`, `status enum_task_status`, `due_at timestamptz NULL`, `created_at`
- **ENUM:** `enum_task_status=('todo','in_progress','done','blocked')`
- `threads`, `messages`, `attachments` (colaborare & intranet)
- `threads`: `id`, `tenant_id`, `channel enum_thread_channel`, `title`, `created_by`, `created_at`
- `messages`: `id`, `tenant_id`, `thread_id FK`, `author_id`, `content jsonb`, `created_at`; **Index:** `(thread_id, created_at)`
- **ENUM:** `enum_thread_channel=('general','team','project','private')`

---

### 7. DB: `db_iwms` (Warehouse & Inventory)

- `warehouses`
- `id uuid PK`, `tenant_id`, `code text`, `name text`, `address jsonb`, `created_at`
- **UQ:** `(tenant_id, code)`
- `products`
- `id uuid PK`, `tenant_id`, `sku text`, `name text`, `uom text`, `category_id uuid NULL`, `barcode text NULL`, `created_at`, `updated_at`
- **UQ:** `(tenant_id, sku)`; **Index:** `(tenant_id, barcode)`
- `stocks`
- `id uuid PK`, `tenant_id`, `warehouse_id uuid FK`, `product_id uuid FK`, `batch_id uuid NULL`, `qty numeric(18,3)`, `min_qty numeric(18,3) DEFAULT 0`, `max_qty numeric(18,3) NULL`, `updated_at`
- **UQ:** `(tenant_id, warehouse_id, product_id, coalesce(batch_id, '00000000-0000-0000-0000-000000000000'))`
- `batches`
- `id uuid PK`, `tenant_id`, `product_id`, `lot text`, `expire_on date NULL`, `created_at`
- **Index:** `(tenant_id, product_id, lot)`
- `stock_moves`
- `id uuid PK`, `tenant_id`, `from_wh uuid NULL`, `to_wh uuid NULL`, `product_id uuid`, `batch_id uuid NULL`, `qty numeric(18,3)`, `reason enum_move_reason`, `ref text`, `moved_at timestamptz`
- **ENUM:** `enum_move_reason=('receipt','shipment','transfer','adjustment')`

---

### 8. DB: `db_mercantiq` (Sales, Invoicing lite, E‑commerce)

- `quotes`
- `id uuid PK`, `tenant_id`, `account_id uuid`, `name text`, `status enum_quote_status`, `currency`, `total numeric(18,2)`, `created_at`, `updated_at`
- **ENUM:** `enum_quote_status=('draft','sent','accepted','rejected','expired')`
- `orders`
- `id uuid PK`, `tenant_id`, `account_id`, `status enum_order_status`, `currency`, `total`, `created_at`, `updated_at`
- **ENUM:** `enum_order_status=('new','confirmed','packed','shipped','delivered','canceled','returned')`
- `order_lines`
- `id uuid PK`, `tenant_id`, `order_id uuid FK`, `product_id uuid`, `qty numeric(18,3)`, `price numeric(18,4)`, `vat_code_id uuid NULL`, `created_at`
- `payments`
- `id uuid PK`, `tenant_id`, `order_id`, `provider enum_pay_provider`, `provider_payment_id text`, `amount numeric(18,2)`, `status enum_payment_status`, `paid_at timestamptz NULL`, `created_at`
- **ENUM:** `enum_pay_provider=('stripe','revolut','pos')`, `enum_payment_status=('pending','paid','failed','refunded')`

---

### 9. DB: `db_triggerra` (Marketing Automation)

- `campaigns`
- `id uuid PK`, `tenant_id`, `name`, `type enum_campaign_type`, `status enum_campaign_status`, `created_at`, `updated_at`
- **ENUM:** `enum_campaign_type=('email','sms','whatsapp','ads','mixed')`, `enum_campaign_status=('draft','running','paused','completed')`
- `segments` (marketing)
- `id uuid PK`, `tenant_id`, `name`, `definition jsonb`, `created_at`, `updated_at`
- `journeys`
- `id uuid PK`, `tenant_id`, `name`, `graph jsonb`, `status enum_journey_status`, `created_at`
- **ENUM:** `enum_journey_status=('active','disabled')`
- `events`
- `id uuid PK`, `tenant_id`, `user_ref uuid NULL`, `account_ref uuid NULL`, `type text`, `payload jsonb`, `ts timestamptz`
- **Index:** `(tenant_id, type, ts DESC)`, GIN `payload`

---

### 10. DB: db_cerniq (BI Metastore & Data Mesh Cache)

> Notă: db_cerniq nu stochează datele brute (care rămân în DB-urile aplicațiilor). Stochează doar definițiile și cache-ul semantic.

- **data_products** - id uuid PK, tenant_id, source_module text(ex. 'numeriqo'),product_name text(ex. 'invoices_paid'),kafka_topic text, schema_definition jsonb (contractul de date).
- **semantic_metrics** - id uuid PK, tenant_id, name text(ex. 'MRR'),calculation_logic text, source_products uuid(FK ladata_products.id).
- **query_cache** - id uuid PK, tenant_id, query_hash text, result jsonb, expires_at timestamptz.
- **governance_rules** - id uuid PK, tenant_id, product_id uuid FK, rule_type text, config jsonb.

---

### 11. DB: `db_gateway` (policy cache, service registry)

- `service_registry` — `id`, `name`, `version`, `endpoint`, `health`, `updated_at`
- `policy_cache` — `id`, `tenant_id`, `route`, `policy jsonb`, `etag`, `updated_at`

---

### 12. Indici, constrângeri & performanță (guidelines)

- **Indici compuși** pentru chei de filtrare uzuale: `(tenant_id, status)`, `(tenant_id, created_at DESC)`.
- **GIN** pentru `jsonb` (path_ops) pe coloane `meta/criteria/payload`.
- **Partial indexes** pentru stări frecvente: ex. `WHERE is_deleted = false`.
- **FK ON DELETE CASCADE/SET NULL** după caz (ex: `document_versions` CASCADE; `owner_id` SET NULL).
- **Vederi materializate** pentru registre contabile și rapoarte frecvente (refresh programat).
- **PG18 – Skip Scan pe B‑tree:** definiți **indici multi‑coloană** când filtrele încep pe a doua/treia coloană; plannerul poate sări peste prefixele lipsă.
- **PG18 – `JSON_TABLE`:** preferați views care expun coloane relaționale peste `jsonb` (ex. firmographics, events) pentru interogări mai curate și mai rapide.

---

### 13. Concluzie: DB comună vs. DB per aplicație

- **Per aplicație (RECOMANDAT):**
- ✅ Izolare clară → vânzare stand‑alone fără migrare dificilă.
- ✅ Scalare independentă (tuning, partiționare, failover pe app‑uri critice).
- ✅ Conformitate & backup la nivel de produs.
- ✅ Necesită analize cross‑app → rezolvat de **cerniq.app** (care implementează un **Data Mesh**, consumând "Produse de Date" de la fiecare aplicație).
- **DB comună (NU recomandat inițial):**
- ➕ Query cross‑domain mai ușor la început.
- ➖ Tight‑coupling, migrații riscante, performanță greu de separat, limitări pentru licențiere per app.

> **Decizie:** **DB per aplicație + schema per tenant**, cu **identity/licensing** comune și **cerniq (Data Mesh)** ca platformă de consum analitic unificată (DB-less).

---

### 14. Convenții denumire & tipuri

- Tabele `snake_case`, PK `id`, FK `<entity>_id`.
- Timpuri `timestamptz`. Bani `numeric(18,2)`; cantități `numeric(18,3/4)`.
- ENUM‑uri prefixate per domeniu (`enum_invoice_status`, `enum_wf_status`).
- Toate tabele tenant‑scoped au **RLS ON** + politici standard.

---

### 15. Extensii PostgreSQL necesare

`pgcrypto` (hash/encrypt), `citext`, `btree_gin`, `pg_trgm`, `pg_partman` (opțional), `postgis` (dacă e nevoie), `timescaledb` (opțional pentru events/time‑series).

> Notă: **`uuidv7()` este nativ în PostgreSQL 18**, nu mai este necesar `uuid-ossp`/`pg_uuidv7`. `JSON_TABLE` este disponibil fără extensii.

---

### 16. Migrate & seeds (Drizzle)

- Migrations versionate pe fiecare DB; seeds minime: roluri default, planuri, chart of accounts (RO), VAT codes, payroll pay items.

> Versiunea acestui schelet: **v1 core**. Pentru extindere (ex: e‑Factura detaliu, SAF‑T, modele HR avansate, E‑commerce complet) se pot adăuga sub‑canvasuri pe module.

## Capitolul 17 - Program de implementare pe faze – GeniusSuite

Structură generală de implementare, fiecare canvas = o fază. În fiecare fază avem subfaze (F1.1..Fn.m) care acoperă structura + scripturile din canvasul dedicat. Ordonarea ține cont de dependențe (Fundație/Auth/CP înaintea apps) și de livrabile incrementale (MVP → Hardening → GA).

### F0 - Faza 0 — Fundația: Guvernanță, DevEx, DB & Scripts

Obiectiv: fundație comună, baze de date și scripturi de bază pentru toate proiectele.

#### F0.1 Monorepo & Tooling: NX + pnpm, workspaces, standard TS/ESLint/Prettier, commit hooks

##### F0.1.1

```json
{
  "F0.1.1": {
    "denumire_task": "Creare Director Rădăcină Monorepo",
    "descriere_scurta_task": "Crearea directorului rădăcină /var/www/GeniusSuite.",
    "descriere_lunga_si_detaliata_task": "Acest task inițiază structura fizică pe disc. Vom crea directorul rădăcină pentru întregul monorepo GeniusSuite. Conform planului, calea standardizată este '/var/www/GeniusSuite'. Această comandă trebuie executată cu permisiunile necesare (posibil 'sudo') în funcție de mediul sistemului de operare.",
    "directorul_directoarele": [
      "/var/www/"
    ],
    "contextul_taskurilor_anterioare": "N/A. Acesta este primul task.",
    "contextul_general_al_aplicatiei": "Se inițiază structura de fișiere pentru monorepo-ul GeniusSuite, care va conține toate aplicațiile (vettify.app, numeriqo.app, etc.) și bibliotecile partajate (shared/), conform.",
    "contextualizarea_directoarelor_si_cailor": "Comanda 'mkdir -p /var/www/GeniusSuite' va crea directorul rădăcină. Toate task-urile următoare se vor desfășura în interiorul acestei căi.",
    "Restrictii_anti_halucinatie": null,
    "restrictii_de_iesire_din_contex": "Nu executa 'git init' sau alte comenzi. Doar creează directorul.",
    "validare": "Rulează 'ls -d /var/www/GeniusSuite'. Comanda trebuie să returneze cu succes calea directorului.",
    "outcome": "Directorul rădăcină '/var/www/GeniusSuite' există.",
    "componenta_de_CI_CD": "În CI, acest pas este de obicei înlocuit de 'git checkout' într-un director de lucru predefinit."
  }
}
```

##### F0.1.2

```json
{
  "F0.1.2": {
    "denumire_task": "Inițializare pnpm",
    "descriere_scurta_task": "Crearea fișierului 'package.json' la rădăcina monorepo-ului folosind 'pnpm init'.",
    "descriere_lunga_si_detaliata_task": "Intrăm în directorul rădăcină și inițiem managerul de pachete 'pnpm'.[1, 15] Comanda 'pnpm init' creează un fișier 'package.json' de bază. Acest fișier va servi drept manifest central pentru dependențele de dezvoltare ale întregului workspace (de ex. nx, typescript, eslint) și va defini script-urile de bază.",
    "directorul_directoarele": null,
    "contextul_taskurilor_anterioare": "F0.1.1: Directorul rădăcină a fost creat.",
    "contextul_general_al_aplicatiei": "pnpm este managerul de pachete ales pentru gestionarea eficientă a dependențelor într-un monorepo.[16]",
    "contextualizarea_directoarelor_si_cailor": "Comanda se execută în '/var/www/GeniusSuite/'. Va crea fișierul '/var/www/GeniusSuite/package.json'.",
    "restrictii_anti_halucinatie": null,
    "restrictii_de_iesire_din_contex": "Nu instala niciun pachet. Doar creează 'package.json'.",
    "validare": "Verifică existența fișierului '/var/www/GeniusSuite/package.json'.",
    "outcome": "Fișierul 'package.json' de rădăcină este creat.",
    "componenta_de_CI_CD": "N/A"
  }
}
```

##### F0.1.3

```json
{
  "F0.1.3": {
    "denumire_task": "Setare 'private: true' în 'package.json'",
    "descriere_scurta_task": "Editarea 'package.json' de la rădăcină pentru a seta 'private: true'.",
    "descriere_lunga_si_detaliata_task": "Este o practică standard pentru rădăcina unui monorepo să fie setată ca 'private: true'. Acest lucru previne publicarea accidentală a pachetului rădăcină în registrul npm. De asemenea, activează anumite funcționalități ale managerilor de pachete pentru workspaces.",
    "directorul_directoarele": "",
    "contextul_taskurilor_anterioare": "F0.1.2: 'package.json' a fost creat.",
    "contextul_general_al_aplicatiei": "Securizarea monorepo-ului împotriva publicării accidentale.",
    "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/package.json'.",
    "restrictii_anti_halucinatie": "",
    "restrictii_de_iesire_din_contex": "Nu modifica alte chei în 'package.json'.",
    "validare": "Conținutul 'package.json' include '\"private\": true'.",
    "outcome": "'package.json' este marcat ca privat.",
    "componenta_de_CI_CD": "N/A"
  }
}
```

##### F0.1.4

```json
{
  "F0.1.4": {
    "denumire_task": "Creare Fișier 'pnpm-workspace.yaml'",
    "descriere_scurta_task": "Crearea fișierului 'pnpm-workspace.yaml' pentru a defini pachetele din monorepo.",
    "descriere_lunga_si_detaliata_task": "Acesta este fișierul central de configurare pentru 'pnpm workspaces'.[15, 16, 17] Prin crearea acestui fișier, îi spunem lui 'pnpm' că acesta este un monorepo și unde să caute pachetele (sub-proiectele).",
    "directorul_directoarele": "",
    "contextul_taskurilor_anterioare": "F0.1.2: 'package.json' de rădăcină există.",
    "contextul_general_al_aplicatiei": "Definirea formală a structurii monorepo-ului pentru 'pnpm'.",
    "contextualizarea_directoarelor_si_cailor": "Creează fișierul '/var/www/GeniusSuite/pnpm-workspace.yaml'.",
    "restrictii_anti_halucinatie": "",
    "restrictii_de_iesire_din_contex": "Nu adăuga conținut în fișier. Acest lucru se va face în task-ul următor.",
    "validare": "Verifică existența fișierului '/var/www/GeniusSuite/pnpm-workspace.yaml'.",
    "outcome": "Fișierul 'pnpm-workspace.yaml' este creat.",
    "componenta_de_CI_CD": "Acest fișier este esențial pentru CI pentru a înțelege cum să instaleze dependențele (pnpm install)."
  }
}
```

##### F0.1.5

```json
{
  "F0.1.5": {
    "denumire_task": "Populare 'pnpm-workspace.yaml' (Critic)",
    "descriere_scurta_task": "Adăugarea căilor (glob patterns) în 'pnpm-workspace.yaml' conform structurii.",
    "descriere_lunga_si_detaliata_task": "Acest task definește 'inima' monorepo-ului. Bazat pe structura de directoare din  (Capitolul 1.5), trebuie să specificăm toate căile unde 'pnpm' și 'Nx' vor găsi proiecte (aplicații și biblioteci). Acest lucru include 'shared/', 'cp/', aplicațiile '.app' și directoarele de suport.",
    "directorul_directoarele": "",
    "contextul_taskurilor_anterioare": "F0.1.4: Fișierul 'pnpm-workspace.yaml' există.",
    "contextul_general_al_aplicatiei": "Alinierea definiției workspace-ului pnpm cu arhitectura.",
    "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/pnpm-workspace.yaml'.",
    "restrictii_anti_halucinatie": "",
    "restrictii_de_iesire_din_contex": "Nu folosi ghilimele duble în YAML. Folosește ghilimele simple. Nu inventa alte căi.",
    "validare": "Conținutul 'pnpm-workspace.yaml' corespunde exact specificației de mai sus.",
    "outcome": "pnpm este acum conștient de structura completă a monorepo-ului.",
    "componenta_de_CI_CD": "Acest fișier dictează modul în care 'pnpm install' descoperă și leagă pachetele locale."
  }
}
```

##### F0.1.6

```JSON
 {
    "F0.1.6": {
      "denumire_task": "Creare Structură Directoare (Partea 1 - Biblioteci)",
      "descriere_scurta_task": "Crearea directorului 'shared/' și a tuturor subdirectoarelor sale.",
      "descriere_lunga_si_detaliata_task": "Creăm directoarele fizice pentru bibliotecile partajate, conform 'pnpm-workspace.yaml' și. Acestea sunt necesare pentru ca 'nx init' (într-un task ulterior) să le poată descoperi.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.5: 'pnpm-workspace.yaml' este definit.",
      "contextul_general_al_aplicatiei": "Materializarea structurii de fișiere.",
      "contextualizarea_directoarelor_si_cailor": "Execută comenzi 'mkdir' în '/var/www/GeniusSuite/'.",
      "restrictii_anti_halucinatie": [
        "Execută 'mkdir -p shared/ui-design-system'",
        "Execută 'mkdir -p shared/feature-flags'",
        "Execută 'mkdir -p shared/auth-client'",
        "Execută 'mkdir -p shared/types'",
        "Execută 'mkdir -p shared/common'",
        "Execută 'mkdir -p shared/integrations'",
        "Execută 'mkdir -p shared/observability'"
      ],
      "restrictii_de_iesire_din_contex": "Nu crea fișiere în interiorul acestor directoare. Doar directoarele.",
      "validare": "Verifică existența celor 7 subdirectoare în 'shared/'.",
      "outcome": "Structura de directoare 'shared/' este creată.",
      "componenta_de_CI_CD": "N/A"
    }
  },
```

##### F0.1.7

```JSON
 {
    "F0.1.7": {
      "denumire_task": "Creare Structură Directoare (Partea 2 - Control Plane)",
      "descriere_scurta_task": "Crearea directorului 'cp/' (Control Plane) și a subdirectoarelor sale.",
      "descriere_lunga_si_detaliata_task": "Continuăm materializarea structurii. Creăm directoarele pentru serviciile centrale (Control Plane).",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.5: 'pnpm-workspace.yaml' este definit.",
      "contextul_general_al_aplicatiei": "Materializarea structurii de fișiere.",
      "contextualizarea_directoarelor_si_cailor": "Execută comenzi 'mkdir' în '/var/www/GeniusSuite/'.",
      "restrictii_anti_halucinatie": [
        "Execută 'mkdir -p cp/suite-shell'",
        "Execută 'mkdir -p cp/suite-admin'",
        "Execută 'mkdir -p cp/suite-login'",
        "Execută 'mkdir -p cp/identity'",
        "Execută 'mkdir -p cp/licensing'",
        "Execută 'mkdir -p cp/analytics-hub'",
        "Execută 'mkdir -p cp/ai-hub'"
      ],
      "restrictii_de_iesire_din_contex": "Nu crea fișiere în interiorul acestor directoare.",
      "validare": "Verifică existența celor 7 subdirectoare în 'cp/'.",
      "outcome": "Structura de directoare 'cp/' este creată.",
      "componenta_de_CI_CD": "N/A"
    }
  },
```

##### F0.1.8

```JSON
 {
    "F0.1.8": {
      "denumire_task": "Creare Structură Directoare (Partea 3 - Aplicații)",
      "descriere_scurta_task": "Crearea directoarelor pentru toate aplicațiile '.app'.",
      "descriere_lunga_si_detaliata_task": "Creăm directoarele de nivel superior pentru fiecare aplicație stand-alone (sau modul major) din suita GeniusSuite, conform.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.5: 'pnpm-workspace.yaml' este definit.",
      "contextul_general_al_aplicatiei": "Materializarea structurii de fișiere.",
      "contextualizarea_directoarelor_si_cailor": "Execută comenzi 'mkdir' în '/var/www/GeniusSuite/'.",
      "restrictii_anti_halucinatie": [
        "Execută 'mkdir -p archify.app'",
        "Execută 'mkdir -p cerniq.app'",
        "Execută 'mkdir -p flowxify.app'",
        "Execută 'mkdir -p i-wms.app'",
        "Execută 'mkdir -p mercantiq.app'",
        "Execută 'mkdir -p numeriqo.app'",
        "Execută 'mkdir -p triggerra.app'",
        "Execută 'mkdir -p vettify.app'",
        "Execută 'mkdir -p geniuserp.app'"
      ],
      "restrictii_de_iesire_din_contex": "Nu crea fișiere în interiorul acestor directoare.",
      "validare": "Verifică existența celor 9 directoare de aplicații la rădăcină.",
      "outcome": "Structura de directoare pentru aplicații este creată.",
      "componenta_de_CI_CD": "N/A"
    }
  },
```

##### F0.1.9

```JSON
 {
    "F0.1.9": {
      "denumire_task": "Creare Structură Directoare (Partea 4 - Infrastructură & Tooling)",
      "descriere_scurta_task": "Crearea directoarelor 'gateway', 'proxy', 'scripts' și 'docs'.",
      "descriere_lunga_si_detaliata_task": "Finalizăm crearea structurii de directoare de nivel superior, adăugând directoarele de suport pentru infrastructură, API gateway, scripturi și documentație, conform.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.5: 'pnpm-workspace.yaml' este definit.",
      "contextul_general_al_aplicatiei": "Materializarea structurii de fișiere.",
      "contextualizarea_directoarelor_si_cailor": "Execută comenzi 'mkdir' în '/var/www/GeniusSuite/'.",
      "restrictii_anti_halucinatie": [
        "Execută 'mkdir -p gateway'",
        "Execută 'mkdir -p proxy'",
        "Execută 'mkdir -p scripts'",
        "Execută 'mkdir -p docs'"
      ],
      "restrictii_de_iesire_din_contex": "Nu crea fișiere în interiorul acestor directoare.",
      "validare": "Verifică existența celor 4 directoare de suport la rădăcină.",
      "outcome": "Structura de directoare  este completă.",
      "componenta_de_CI_CD": "N/A"
    }
  },
```

##### F0.1.10

```JSON
 {
    "F0.1.10": {
      "denumire_task": "Creare Fișier Rădăcină '.gitignore'",
      "descriere_scurta_task": "Crearea și popularea fișierului '.gitignore' global.",
      "descriere_lunga_si_detaliata_task": "Creăm un fișier '.gitignore' la rădăcină pentru a exclude fișierele și directoarele comune care nu ar trebui să fie comisionate în Git. Acesta include 'node_modules', artefacte de build ('dist', 'build'), cache-uri Nx și fișiere de mediu ('.env').",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.1 - F0.1.9: Structura de directoare este gata.",
      "contextul_general_al_aplicatiei": "Asigurarea unui repository Git curat.",
      "contextualizarea_directoarelor_si_cailor": "Creează fișierul '/var/www/GeniusSuite/.gitignore'.",
      "restrictii_anti_halucinatie":,
      "restrictii_de_iesire_din_contex": "Nu adăuga reguli specifice aplicațiilor (de ex. 'archify.app/build'). Ne limităm la reguli globale.",
      "validare": "Verifică existența și conținutul fișierului '/var/www/GeniusSuite/.gitignore'.",
      "outcome": "Un fișier '.gitignore' global este configurat.",
      "componenta_de_CI_CD": "Acest fișier este fundamental pentru a preveni cache-ul CI să fie poluat cu fișiere irelevante."
    }
  },
```

##### F0.1.11

```JSON
 {
    "F0.1.11": {
      "denumire_task": "Instalare 'nx' ca Dependență Rădăcină",
      "descriere_scurta_task": "Adăugarea pachetului 'nx' ca dependență de dezvoltare (dev dependency) la rădăcina workspace-ului.",
      "descriere_lunga_si_detaliata_task": "Instalăm 'nx' [18], managerul de monorepo și task runner, la nivelul rădăcinii. Folosim 'pnpm add nx -D -w'. Flag-ul '-D' îl salvează ca devDependency. Flag-ul '-w' (sau '--workspace-root') este specific 'pnpm' și indică faptul că pachetul trebuie instalat în 'package.json' de la rădăcină, nu într-un sub-pachet.[15]",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.2: 'package.json' este configurat. F0.1.5: 'pnpm-workspace.yaml' este configurat.",
      "contextul_general_al_aplicatiei": "Nx este instrumentul central [1, 18] ales pentru gestionarea dependențelor, rularea task-urilor, caching și orchestrarea generală a monorepo-ului GeniusSuite.",
      "contextualizarea_directoarelor_si_cailor": "Comanda se execută în '/var/www/GeniusSuite/'. Va modifica 'package.json' și va crea 'node_modules' (și/sau '.pnpm-store').",
      "restrictii_anti_halucinatie":"N/A",
      "restrictii_de_iesire_din_contex": "Nu rula încă 'nx init' sau alte comenzi 'nx'. Doar instalează pachetul.",
      "validare": "Verifică 'package.json' pentru a vedea 'nx' listat în 'devDependencies'. Verifică existența directorului 'node_modules'.",
      "outcome": "Pachetul 'nx' este instalat la rădăcina monorepo-ului.",
      "componenta_de_CI_CD": "Acest pas este echivalentul 'pnpm install' din CI. Adaugă prima dependență majoră."
    }
  },
```

##### F0.1.12

```JSON
 {
    "F0.1.12": {
      "denumire_task": "Rulare 'nx init' pentru a Adopta Workspace-ul",
      "descriere_scurta_task": "Executarea 'pnpx nx@latest init' pentru a configura Nx să adopte workspace-ul pnpm existent.",
      "descriere_lunga_si_detaliata_task": "Acum că 'nx' este instalat, 'pnpm-workspace.yaml' este definit și directoarele există, rulăm 'nx init'. Această comandă [3, 19, 20] va detecta workspace-ul 'pnpm' existent și structura noastră. Ne va ghida prin procesul de a-l 'adopta', creând fișierul central 'nx.json' și integrându-se cu structura noastră.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.11: 'nx' este instalat. F0.1.5: 'pnpm-workspace.yaml' definește structura.[1] F0.1.6-F0.1.9: Directoarele fizice există.",
      "contextul_general_al_aplicatiei": "Acesta este pasul de 'căsătorie' între 'pnpm workspaces' și 'Nx'. 'nx init' va scana structura [1] și o va transforma într-un graf de proiecte Nx.",
      "contextualizarea_directoarelor_si_cailor": "Comanda se execută în '/var/www/GeniusSuite/'. Va crea 'nx.json'.",
      "restrictii_anti_halucinatie": [
        "Execută 'pnpx nx@latest init'.",
        "Când ești întrebat, confirmă 'pnpm' ca manager de pachete.[21]",
        "Urmărește prompt-urile pentru a 'adopta' monorepo-ul existent.[19]",
        "NU alege să creezi un workspace nou sau să folosești o structură generică.",
        "Când întreabă despre Nx Cloud, selectează 'Nu' pentru moment."
      ],
      "restrictii_de_iesire_din_contex": "Nu configura manual 'nx.json' în acest pas; lasă 'init' să creeze fișierul de bază.",
      "validare": "Verifică existența fișierului '/var/www/GeniusSuite/nx.json'.",
      "outcome": "Fișierul 'nx.json' a fost creat, iar Nx a preluat gestiunea workspace-ului 'pnpm' existent.",
      "componenta_de_CI_CD": "Crearea 'nx.json' este fundamentală. CI va folosi 'nx' pentru a rula task-uri afectate (affected tasks)."
    }
  },
```

##### F0.1.13

```JSON
  {
  "F0.1.13": {
    "denumire_task": "Configurare 'nx.json' (Partea 1 - Target Defaults)",
    "descriere_scurta_task": "Editarea 'nx.json' pentru a stabili 'targetDefaults' pentru operațiuni cacheabile.",
    "descriere_lunga_si_detaliata_task": "Modificăm 'nx.json' pentru a defini 'targetDefaults'. Aceasta este o practică recomandată Nx [2] pentru a seta implicit ce task-uri (cum ar fi 'build', 'lint', 'test') sunt cacheabile, fără a trebui să o specificăm în fiecare proiect. De asemenea, definim 'outputs' implicite, cum ar fi 'dist' sau 'coverage'.[2]",
    "directorul_directoarele": "",
    "contextul_taskurilor_anterioare": "F0.1.12: 'nx.json' a fost creat de 'nx init'.",
    "contextul_general_al_aplicatiei": "Definirea strategiilor de caching la rădăcină este cheia pentru un monorepo rapid.[18, 22]",
    "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/nx.json'.",
    "restrictii_anti_halucinatie": [
      "Editează DOAR fișierul existent '/var/www/GeniusSuite/nx.json'. Nu crea alte fișiere.",
      "Nu șterge și nu modifica alte chei de top ('extends', 'tasksRunnerOptions', etc.) dacă există deja.",
      "Adaugă la nivel rădăcină cheia 'targetDefaults' dacă nu există.",
      "Conținutul minim acceptat pentru 'targetDefaults' este:",
      "{",
      "  \"targetDefaults\": {",
      "    \"build\": {",
      "      \"cache\": true,",
      "      \"outputs\": [\"{projectRoot}/dist\"]",
      "    },",
      "    \"lint\": {",
      "      \"cache\": true",
      "    },",
      "    \"test\": {",
      "      \"cache\": true,",
      "      \"outputs\": [\"{projectRoot}/coverage\"]",
      "    }",
      "  }",
      "}",
      "Nu adăuga alte target-uri acum (de ex. 'docker-build'). Acestea vor fi tratate în fazele ulterioare.",
      "Nu adăuga câmpul 'projects' în 'nx.json'. Acesta trebuie să rămână gol sau absent; Nx va folosi Inferred Tasks."
    ],
    "restrictii_de_iesire_din_contex": "Nu adăuga încă proiecte ('projects: {}'). Nx le va descoperi automat (Inferred Tasks).[2]",
    "validare": "Conținutul 'nx.json' include cheia 'targetDefaults' cu configurațiile specificate.",
    "outcome": "'nx.json' este configurat cu valori implicite pentru caching-ul task-urilor comune.",
    "componenta_de_CI_CD": "Această configurație activează Nx Remote Cache (Nx Cloud sau similar), reducând drastic timpii de CI.[22]"
  }
}
```

##### F0.1.14

```JSON
  {
    "F0.1.14": {
      "denumire_task": "Configurare 'nx.json' (Partea 2 - Package Manager)",
      "descriere_scurta_task": "Asigurarea că 'nx.json' este setat explicit să folosească 'pnpm'.",
      "descriere_lunga_si_detaliata_task": "Deși 'nx init' ar fi trebuit să detecteze 'pnpm' [15, 21], vom verifica și vom seta explicit 'packageManager: \"pnpm\"' în 'nx.json'. Acest lucru asigură că Nx nu va încerca niciodată să folosească 'npm' sau 'yarn' pentru operațiunile de instalare.[3]",
      "directorul_directoarele":[/
      ],
      "contextul_taskurilor_anterioare": "F0.1.13: 'nx.json' a fost configurat cu 'targetDefaults'.",
      "contextul_general_al_aplicatiei": "Consolidarea 'pnpm' ca unic manager de pachete în monorepo.",
      "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/nx.json'.",
      "restrictii_anti_halucinatie": [
        "Adaugă sau verifică existența cheii 'packageManager' la nivelul rădăcinii 'nx.json'.",
        "Valoarea trebuie să fie exact '\"packageManager\": \"pnpm\"'."
      ],
      "restrictii_de_iesire_din_contex": "N/A",
      "validare": "Conținutul 'nx.json' include '\"packageManager\": \"pnpm\"'.",
      "outcome": "Nx este configurat explicit să folosească 'pnpm'.",
      "componenta_de_CI_CD": "Previne erorile de CI în care agentul ar putea încerca să folosească 'npm install' din greșeală."
    }
  },
```

##### F0.1.15

```JSON
  {
  "F0.1.15": {
    "denumire_task": "Instalare Dependențe TypeScript de Bază",
    "descriere_scurta_task": "Instalarea 'typescript' la rădăcina workspace-ului.",
    "descriere_lunga_si_detaliata_task": "Instalăm pachetul fundamental 'typescript' la nivelul rădăcinii monorepo-ului, folosind 'pnpm add'. Acesta va fi folosit de toate proiectele, de ESLint și de 'nx' însuși. Stiva specifică 'latest' TS.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.11: 'nx' este instalat.",
    "contextul_general_al_aplicatiei": "Stabilirea fundației TypeScript pentru întregul monorepo.",
    "contextualizarea_directoarelor_si_cailor": "Comanda se execută în '/var/www/GeniusSuite/'.",
    "restrictii_anti_halucinatie": [
      "Execută comanda DOAR din directorul '/var/www/GeniusSuite/'.",
      "Folosește exclusiv 'pnpm', nu 'npm' sau 'yarn'. Comanda recomandată: 'pnpm add -D typescript@latest'.",
      "Adaugă pachetul 'typescript' în 'devDependencies', nu în 'dependencies'.",
      "Nu instala alte pachete în acest task (de ex. 'ts-node', '@types/node', alte plugin-uri).",
      "Nu modifica alte câmpuri din 'package.json' în afară de adăugarea/actualizarea intrării 'typescript'."
    ],
    "restrictii_de_iesire_din_contex": "Nu instala 'ts-node' sau '@types/node' încă. Le vom instala separat pentru a fi atomici.",
    "validare": "Verifică 'package.json' pentru a vedea 'typescript' în 'devDependencies'.",
    "outcome": "TypeScript este instalat.",
    "componenta_de_CI_CD": "Acest pachet va fi necesar pentru toți pașii de 'build' și 'lint' din CI."
  }
},
```

##### F0.1.16

```JSON
  {
    "F0.1.16": {
      "denumire_task": "Instalare Dependențe 'ts-node' și Tipuri Node",
      "descriere_scurta_task": "Instalarea 'ts-node' și '@types/node' la rădăcina workspace-ului.",
      "descriere_lunga_si_detaliata_task": "Instalăm 'ts-node' (pentru rularea script-urilor TS direct) și '@types/node'.",
      "Directorul_directoarele":[“verificam versiunea existenta in sistem si actualizam la versiunea stakului”],
      "contextul_taskurilor_anterioare": "F0.1.15: 'typescript' este instalat.",
      "contextul_general_al_aplicatiei": "Asigurarea suportului pentru rularea script-urilor TypeScript și a tipurilor corecte pentru mediul Node.js 24 LTS.",
      "contextualizarea_directoarelor_si_cailor": "Comanda se execută în '/var/www/GeniusSuite/'.",
      "restrictii_anti_halucinatie": [
        "Execută comanda DOAR din directorul '/var/www/GeniusSuite/'.",
        "Folosește exclusiv 'pnpm', nu 'npm' sau 'yarn'. Recomandat: 'pnpm add -D ts-node @types/node'.",
        "Adaugă 'ts-node' și '@types/node' în 'devDependencies', nu în 'dependencies'.",
        "Nu instala alte pachete în acest task.",
        "Nu modifica alte câmpuri din 'package.json' în afară de intrările pentru 'ts-node' și '@types/node'."
      ],
      "restrictii_de_iesire_din_contex": "N/A",
      "validare": "Verifică 'package.json' pentru 'ts-node' și '@types/node' în 'devDependencies'.",
      "outcome": "Dependențele de suport TypeScript sunt instalate.",
      "componenta_de_CI_CD": "N/A"
    }
  },
```

##### F0.1.17

```JSON
  {
  "F0.1.17": {
    "denumire_task": "Creare 'tsconfig.base.json' la Rădăcină",
    "descriere_scurta_task": "Crearea fișierului de configurare TypeScript de bază, 'tsconfig.base.json'.",
    "descriere_lunga_si_detaliata_task": "Acesta este fișierul de configurare TypeScript central. Toate celelalte fișiere 'tsconfig.json' din monorepo (din aplicații și biblioteci) vor extinde acest fișier de bază. În acest task creăm doar fișierul și un skeleton minim; opțiunile stricte 'compilerOptions' vor fi configurate în taskurile următoare.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.15: TypeScript este instalat.",
    "contextul_general_al_aplicatiei": "Impunerea unui standard TypeScript strict și centralizat pentru toate proiectele din GeniusSuite.",
    "contextualizarea_directoarelor_si_cailor": "Creează fișierul '/var/www/GeniusSuite/tsconfig.base.json'.",
    "restrictii_anti_halucinatie": [
      "Creează DOAR fișierul '/var/www/GeniusSuite/tsconfig.base.json'. Nu modifica alte fișiere de configurare TypeScript în acest task.",
      "Conținutul inițial trebuie să fie un JSON valid, cu structură minimă:\n{\n  \"compilerOptions\": {},\n  \"exclude\": [\"node_modules\", \"tmp\"]\n}",
      "Nu adăuga încă opțiuni în 'compilerOptions' (strict, module, target, jsx etc.).",
      "Nu adăuga încă 'paths', 'references' sau alte câmpuri avansate. Acestea vor fi tratate în taskurile următoare (ex. F0.1.18+)."
    ],
    "restrictii_de_iesire_din_contex": "Nu popula încă 'compilerOptions' sau 'paths'. Acestea vor fi făcute în task-urile următoare.",
    "validare": "Verifică existența fișierului '/var/www/GeniusSuite/tsconfig.base.json' și că JSON-ul este valid cu cheile 'compilerOptions' goale și 'exclude' setat la ['node_modules', 'tmp'].",
    "outcome": "Fișierul 'tsconfig.base.json' este creat cu un skeleton minim, gata să fie extins de taskurile ulterioare.",
    "componenta_de_CI_CD": "CI va folosi acest fișier ca bază pentru 'typecheck' și 'build' după ce opțiunile vor fi completate în taskurile următoare."
  }
},
```

##### F0.1.18

```JSON
  {
  "F0.1.18": {
    "denumire_task": "Configurare 'compilerOptions' Stricte în 'tsconfig.base.json'",
    "descriere_scurta_task": "Setarea regulilor stricte de compilare TypeScript în 'tsconfig.base.json'.",
    "descriere_lunga_si_detaliata_task": "Configurăm 'compilerOptions' în 'tsconfig.base.json' pentru a impune standarde de cod stricte, conform cerințelor (Convenții generale: \"Strict TS\"). Aceasta include 'strict: true', 'noUncheckedIndexedAccess', 'exactOptionalPropertyTypes' și alte opțiuni moderne pentru compatibilitatea cu Node 24 (ESNext) și React 19 (JSX). Configurația permite emiterea fișierelor de build ('declaration: true', 'sourceMap: true'), esențiale pentru biblioteci și servicii backend.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.17: 'tsconfig.base.json' a fost creat.",
    "contextul_general_al_aplicatiei": "Standardizarea calității codului și prevenirea erorilor comune în întregul monorepo.",
    "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/tsconfig.base.json' și editează secțiunea 'compilerOptions'. Nu crea alte fișiere TS config.",
    "restrictii_anti_halucinatie": [
      "Modifică DOAR fișierul '/var/www/GeniusSuite/tsconfig.base.json'. Nu crea și nu modifica alte fișiere de configurare TypeScript.",
      "Nu șterge câmpul 'exclude' definit la F0.1.17 (trebuie să rămână cel puțin ['node_modules', 'tmp']).",
      "Asigură-te că în 'compilerOptions' sunt setate cel puțin următoarele chei și valori (poți păstra și alte chei deja existente, dacă nu contrazic aceste valori):",
      "{",
      "  \"compilerOptions\": {",
      "    \"target\": \"ESNext\",",
      "    \"module\": \"ESNext\",",
      "    \"moduleResolution\": \"bundler\",",
      "    \"skipLibCheck\": true,",
      "    \"allowJs\": true,",
      "    \"esModuleInterop\": true,",
      "    \"allowSyntheticDefaultImports\": true,",
      "    \"forceConsistentCasingInFileNames\": true,",
      "    \"isolatedModules\": true,",
      "    \"jsx\": \"react-jsx\",",
      "    \"strict\": true,",
      "    \"noUncheckedIndexedAccess\": true,",
      "    \"exactOptionalPropertyTypes\": true,",
      "    \"noImplicitAny\": true,",
      "    \"strictNullChecks\": true,",
      "    \"strictFunctionTypes\": true,",
      "    \"strictBindCallApply\": true,",
      "    \"strictPropertyInitialization\": true,",
      "    \"noImplicitThis\": true,",
      "    \"alwaysStrict\": true,",
      "    \"noUnusedLocals\": true,",
      "    \"noUnusedParameters\": true,",
      "    \"noImplicitReturns\": true,",
      "    \"noFallthroughCasesInSwitch\": true,",
      "    \"resolveJsonModule\": true,",
      "    \"composite\": false,",
      "    \"declaration\": true,",
      "    \"sourceMap\": true,",
      "    \"baseUrl\": \".\",",
      "    \"incremental\": true",
      "  }",
      "}",
      "Nu adăuga opțiunea 'noEmit' în acest task.",
      "Nu adăuga încă 'paths' în 'compilerOptions'; acestea vor fi configurate explicit în task-ul F0.1.19.",
      "Nu adăuga aici 'references' sau alte câmpuri de project references."
    ],
    "restrictii_de_iesire_din_contex": "Rămâi strict în contextul configurării 'compilerOptions' din 'tsconfig.base.json'. Nu modifica 'nx.json', '.eslintrc.*', config-uri Vite sau alte fișiere.",
    "validare": "'tsconfig.base.json' conține un obiect 'compilerOptions' cu 'strict: true', 'noUncheckedIndexedAccess', 'exactOptionalPropertyTypes', 'declaration: true', 'sourceMap: true' și NU conține 'noEmit: true'. Fișierul este JSON valid.",
    "outcome": "Configurația de bază TypeScript este strictă, modernă și capabilă să emită fișiere de build (.js, .d.ts) pentru biblioteci și servicii backend.",
    "componenta_de_CI_CD": "Toate job-urile 'typecheck' și 'build' din CI vor moșteni aceste reguli stricte și vor avea o bază comună coerentă."
  }
},
```

##### F0.1.19

```JSON
  {
  "F0.1.19": {
    "denumire_task": "Configurare 'paths' (Alias-uri) în 'tsconfig.base.json' (Critic)",
    "descriere_scurta_task": "Definirea alias-urilor de import TypeScript în 'paths' pentru toate bibliotecile din 'shared/'.",
    "descriere_lunga_si_detaliata_task": "Acesta este un pas vital pentru arhitectura monorepo-ului. Definind 'compilerOptions.paths' în tsconfig.base.json, permitem importuri curate (de ex. '@genius-suite/ui-design-system') în loc de căi relative lungi (de ex. '../../shared/ui-design-system'). Mapăm fiecare pachet definit în directorul 'shared/' (ui-design-system, feature-flags, auth-client, types, common, integrations, observability), respectând structurile reale din Capitolul 2. În package.json-urile viitoare vom folosi 'workspace:' de la pnpm, dar alias-urile TypeScript sunt necesare pentru IDE și type-checking.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.18: 'compilerOptions' sunt setate, inclusiv 'baseUrl': '.'.",
    "contextul_general_al_aplicatiei": "Crearea 'lipiciului' (glue) între bibliotecile partajate din 'shared/' și viitoarele aplicații consumatoare (cp/, vettify.app/, etc.).",
    "contextualizarea_directoarelor_si_cailor": "Modifică proprietatea 'compilerOptions.paths' în fișierul '/var/www/GeniusSuite/tsconfig.base.json'. Nu edita alte fișiere.",
    "restrictii_anti_halucinatie": [
      "Modifică exclusiv fișierul '/var/www/GeniusSuite/tsconfig.base.json'. Nu crea și nu modifica alte fișiere de configurare TypeScript.",
      "Nu șterge sau modifica alte proprietăți din 'compilerOptions' (de ex. 'strict', 'baseUrl', 'declaration'). Adaugă sau actualizează DOAR 'paths'.",
      "Configurează 'compilerOptions.paths' astfel încât să includă cel puțin următoarele intrări, respectând structurile reale din 'shared/':",
      "\"@genius-suite/ui-design-system\": [\"shared/ui-design-system/index.ts\"],",
      "\"@genius-suite/feature-flags\": [\"shared/feature-flags/src/index.ts\"],",
      "\"@genius-suite/auth-client\": [\"shared/auth-client/src/index.ts\"],",
      "\"@genius-suite/types\": [\"shared/types/index.ts\"],",
      "\"@genius-suite/common\": [\"shared/common/index.ts\"],",
      "\"@genius-suite/integrations\": [\"shared/integrations/index.ts\"],",
      "\"@genius-suite/observability\": [\"shared/observability/index.ts\"].",
      "Pentru 'feature-flags' și 'auth-client' folosește explicit 'src/index.ts' ca entrypoint, deoarece codul sursă este sub 'src/'.",
      "Pentru 'integrations' și 'observability', presupune existența unui 'index.ts' la rădăcina pachetului (barrel export) care va fi creat în task-uri ulterioare; nu modifica acum structura 'shared/integrations/' sau 'shared/observability/'.",
      "Nu adăuga alias-uri suplimentare în acest task. Acoperă doar cele 7 pachete din 'shared/'.",
      "Nu modifica valoarea 'baseUrl'; aceasta trebuie să rămână '.'."
    ],
    "restrictii_de_iesire_din_contex": "Nu rula 'nx sync', 'nx graph', 'nx run' sau alte comenzi. Acest task se ocupă strict de editarea fișierului tsconfig.base.json.",
    "validare": "'tsconfig.base.json' conține 'compilerOptions.paths' cu toate cele 7 alias-uri definite conform structurilor reale (inclusiv 'src/index.ts' pentru feature-flags și auth-client), iar fișierul este JSON valid.",
    "outcome": "Alias-urile de import pentru bibliotecile partajate sunt configurate centralizat, permițând importuri de forma '@genius-suite/<pachet>' în tot monorepo-ul, în acord cu structurile din Capitolul 2.",
    "componenta_de_CI_CD": "Job-urile de CI care rulează 'typecheck' și 'build' vor folosi aceste mapări de căi, asigurând rezolvarea corectă a importurilor către 'shared/*'."
  }
},
```

##### F0.1.20

```JSON
  {
  "F0.1.20": {
    "denumire_task": "Instalare Prettier",
    "descriere_scurta_task": "Instalarea 'prettier' ca dependență de dezvoltare la rădăcină.",
    "descriere_lunga_si_detaliata_task": "Instalăm 'prettier' [8, 23], instrumentul standard pentru formatarea codului. Acesta va fi folosit pentru a impune un stil de cod consistent în întregul monorepo. Pachetul se instalează ca dependență de dezvoltare la rădăcină, astfel încât toate proiectele (apps și shared libs) să poată folosi aceeași versiune de Prettier.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.11: Dependențele de bază sunt instalate (pnpm + nx + stack de bază).",
    "contextul_general_al_aplicatiei": "Standardizarea stilului de cod este crucială pentru mentenabilitatea monorepo-ului. Prettier va fi ulterior integrat în ESLint și în pipeline-ul de CI pentru a asigura o formatare automată și consistentă.",
    "contextualizarea_directoarelor_si_cailor": "Execută comanda de instalare din directorul rădăcină al monorepo-ului: '/var/www/GeniusSuite/'. Aceasta va modifica fișierul '/var/www/GeniusSuite/package.json' și va actualiza 'pnpm-lock.yaml'.",
    "restrictii_anti_halucinatie": [
      "Execută O SINGURĂ comandă de instalare: `pnpm add -D prettier` în directorul '/var/www/GeniusSuite/'.",
      "Nu instala Prettier global (NU folosi `-g`) și nu folosi alt manager de pachete (NU `npm`, NU `yarn`).",
      "Nu instala încă alte pachete legate de Prettier (cum ar fi 'eslint-config-prettier', 'eslint-plugin-prettier' etc.). Acestea au task-uri dedicate ulterior (F0.1.30–F0.1.31).",
      "Nu crea și nu modifica fișiere de configurare Prettier ('./.prettierrc', './.prettierignore') în acest task; acestea sunt acoperite explicit în F0.1.21 și F0.1.22.",
      "Nu modifica manual alte câmpuri din 'package.json' în afară de ceea ce adaugă automat comanda pnpm pentru 'devDependencies.prettier'.",
      "Dacă 'prettier' există deja în 'devDependencies', actualizează versiunea prin aceeași comandă pnpm (nu edita 'package.json' direct)."
    ],
    "restrictii_de_iesire_din_contex": "Nu te atinge de configurările ESLint sau Nx în acest task. Nu crea scripturi noi în 'package.json'. Doar instalează dependența 'prettier' la rădăcină.",
    "validare": "După rularea comenzii, verifică fișierul '/var/www/GeniusSuite/package.json' și confirmă că există cheia 'devDependencies.prettier' cu o versiune validă. Opțional, rulează 'pnpm prettier --version' din '/var/www/GeniusSuite/' pentru a verifica instalarea.",
    "outcome": "'prettier' este instalat ca dependență de dezvoltare la rădăcina monorepo-ului.",
    "componenta_de_CI_CD": "Această dependență va fi folosită ulterior în pipeline-urile de CI pentru a rula 'prettier --check' sau 'nx format:check' asupra codului, asigurând formatare consistentă înainte de merge."
  }
},
```

##### F0.1.21

```JSON
  {
  "F0.1.21": {
    "denumire_task": "Creare Fișier Configurare '.prettierrc'",
    "descriere_scurta_task": "Crearea fișierului de configurare '.prettierrc' cu regulile de formatare.",
    "descriere_lunga_si_detaliata_task": "Creăm fișierul '.prettierrc' la rădăcină. Acesta va conține regulile specifice de formatare (de ex. 'singleQuote', 'tabWidth') pe care le vom impune în tot codul (TS, JS, JSX, JSON, CSS, MD). Configurația este centralizată la nivel de monorepo, astfel încât toate aplicațiile și bibliotecile să folosească același standard de stil.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.20: 'prettier' este instalat.",
    "contextul_general_al_aplicatiei": "Definirea standardului unitar de formatare a codului pentru întregul monorepo GeniusSuite.",
    "contextualizarea_directoarelor_si_cailor": "Creează fișierul '/var/www/GeniusSuite/.prettierrc' la rădăcina monorepo-ului. Acest fișier va fi folosit de comenzi precum 'pnpm prettier', 'nx format:write' și de integrarea cu ESLint.",
    "restrictii_anti_halucinatie": [
      "Lucrează EXCLUSIV în directorul '/var/www/GeniusSuite/'. Nu crea sau modifica fișiere în alte directoare.",
      "Creează (sau suprascrie) fișierul '/var/www/GeniusSuite/.prettierrc' cu conținut JSON VALID.",
      "Conținutul fișierului '.prettierrc' trebuie să fie EXACT următorul (inclusiv cheile și valorile):",
      "{",
      "  \"singleQuote\": true,",
      "  \"semi\": true,",
      "  \"tabWidth\": 2,",
      "  \"useTabs\": false,",
      "  \"trailingComma\": \"all\",",
      "  \"printWidth\": 100,",
      "  \"arrowParens\": \"always\",",
      "  \"bracketSpacing\": true,",
      "  \"bracketSameLine\": false,",
      "  \"endOfLine\": \"lf\",",
      "  \"proseWrap\": \"preserve\"",
      "}",
      "Nu adăuga alte chei sau comentarii în '.prettierrc' în acest task.",
      "Nu crea alte fișiere de configurare Prettier (de ex. 'prettier.config.js', '.prettierrc.js', '.prettierrc.cjs').",
      "Nu modifica 'package.json', '.eslintrc.json' sau alte fișiere de configurare în acest task.",
      "Asigură-te că fișierul este JSON valid (fără virgule la final de linie și fără comentarii)."
    ],
    "restrictii_de_iesire_din_contex": "Nu crea '.prettierignore' încă. Acesta este un task separat (F0.1.22). Nu definești aici integrarea cu ESLint sau Nx.",
    "validare": "Verifică faptul că fișierul '/var/www/GeniusSuite/.prettierrc' există, este JSON valid și conține exact cheile specificate ('singleQuote', 'semi', 'tabWidth', 'useTabs', 'trailingComma', 'printWidth', 'arrowParens', 'bracketSpacing', 'bracketSameLine', 'endOfLine', 'proseWrap').",
    "outcome": "Regulile de formatare Prettier sunt definite centralizat, permițând formatare consistentă a codului în întregul monorepo.",
    "componenta_de_CI_CD": "Configurația va fi folosită implicit de pașii de CI care rulează 'prettier --check' sau 'nx format:check', asigurând că toate schimbările respectă același stil de cod."
  }
},
```

##### F0.1.22

```JSON
  {
  "F0.1.22": {
    "denumire_task": "Creare Fișier '.prettierignore'",
    "descriere_scurta_task": "Crearea fișierului '.prettierignore' pentru a exclude fișierele de la formatare.",
    "descriere_lunga_si_detaliata_task": "Creăm fișierul '.prettierignore' la rădăcina monorepo-ului pentru a controla ce fișiere și directoare sunt excluse din formatarea Prettier. Prettier folosește deja regulile din '.gitignore', deci '.prettierignore' trebuie să conțină doar excepțiile specifice (ex. lockfile-uri ale altor package manageri și directoare cu cod generat) care NU ar trebui formatate, chiar dacă sunt urmărite de Git.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.21: '.prettierrc' este creat. F0.1.10: '.gitignore' există.",
    "contextul_general_al_aplicatiei": "Optimizarea execuției 'prettier' și prevenirea formatării fișierelor generate sau irelevante, păstrând în același timp mentenabilitatea (fără duplicarea regulilor din '.gitignore').",
    "contextualizarea_directoarelor_si_cailor": "Creează fișierul '/var/www/GeniusSuite/.prettierignore' la rădăcina monorepo-ului. Acest fișier va fi luat în considerare de Prettier împreună cu '.gitignore'.",
    "restrictii_anti_halucinatie": [
      "Lucrează EXCLUSIV în directorul '/var/www/GeniusSuite/'. Nu crea fișiere suplimentare în alte directoare.",
      "Creează (sau suprascrie) fișierul '/var/www/GeniusSuite/.prettierignore'.",
      "NU copia integral conținutul din '.gitignore' în '.prettierignore'. Prettier citește deja '.gitignore' implicit; aici adăugăm doar excepțiile specifice.",
      "Conținutul fișierului '.prettierignore' trebuie să fie EXACT următorul (inclusiv comentariile):",
      "# Lockfile-uri ale altor package manageri (nu folosim npm/yarn în acest monorepo)",
      "package-lock.json",
      "yarn.lock",
      "",
      "# Cod generat care NU trebuie formatat (chiar dacă este urmărit de Git)",
      "shared/ui-design-system/icons/react/generated/",
      "",
      "# Intenționat NU ignorăm 'pnpm-lock.yaml' pentru a permite formatarea lui de către Prettier,",
      "# astfel încât dif-urile să fie consistente în echipă.",
      "NU adăuga alte pattern-uri în acest task. Pentru noi directoare generate se vor crea taskuri separate.",
      "Nu modifica '.gitignore' în cadrul acestui task."
    ],
    "restrictii_de_iesire_din_contex": "Rămâi strict în contextul creării și populării fișierului '.prettierignore'. Nu modifica 'package.json', '.prettierrc', '.eslintrc.*' sau alte configurări.",
    "validare": "Verifică faptul că fișierul '/var/www/GeniusSuite/.prettierignore' există și conține exact liniile specificate, în ordinea indicată. Rulează opțional 'pnpm prettier --list-different .' pe un subset de fișiere pentru a confirma că directorul 'shared/ui-design-system/icons/react/generated/' este ignorat.",
    "outcome": "Prettier este configurat să ignore doar fișierele și directoarele care nu necesită formatare (lockfile-uri ale altor package manageri și cod generat), fără duplicarea regulilor din '.gitignore', păstrând mentenabilitatea ridicată.",
    "componenta_de_CI_CD": "Accelerează pasul 'format:check' din CI prin excluderea căilor irelevante și evită interferența cu 'pnpm-lock.yaml', care rămâne formatat consistent de Prettier și pnpm."
  }
},
```

##### F0.1.23

```JSON
  {
  "F0.1.23": {
    "denumire_task": "Instalare ESLint Core",
    "descriere_scurta_task": "Instalarea pachetului 'eslint' la rădăcina monorepo-ului.",
    "descriere_lunga_si_detaliata_task": "Instalăm pachetul de bază pentru linting, 'eslint'. Acesta este motorul care va rula regulile de linting în întregul monorepo (pentru TypeScript, JavaScript, React etc.). Pachetul se instalează ca dependență de dezvoltare la rădăcină, astfel încât toate proiectele să folosească aceeași versiune de ESLint. Configurația efectivă (plugins, rules, Nx integration) va fi făcută în taskurile următoare.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.15: TypeScript este instalat. F0.1.11: pnpm și Nx sunt configurate la rădăcină.",
    "contextul_general_al_aplicatiei": "Stabilirea fundației pentru impunerea regulilor de calitate a codului (linting) în toate aplicațiile și bibliotecile monorepo-ului.",
    "contextualizarea_directoarelor_si_cailor": "Execută comanda de instalare din directorul rădăcină al monorepo-ului: '/var/www/GeniusSuite/'. Comanda va modifica '/var/www/GeniusSuite/package.json' și 'pnpm-lock.yaml'.",
    "restrictii_anti_halucinatie": [
      "Execută o singură comandă de instalare: `pnpm add -D eslint` din directorul '/var/www/GeniusSuite/'.",
      "Nu instala ESLint global (NU folosi `-g`) și nu folosi alți package manageri (NU `npm`, NU `yarn`).",
      "Adaugă 'eslint' doar în 'devDependencies', nu în 'dependencies'.",
      "Nu instala încă plugin-uri sau configurări suplimentare ESLint (de ex. '@typescript-eslint/*', 'eslint-plugin-react', '@nx/eslint-plugin'); acestea vor fi tratate în taskurile următoare.",
      "Nu crea în acest task fișiere de configurare ESLint ('.eslintrc.json', '.eslintrc.cjs', etc.). Acestea sunt acoperite separat (F0.1.29+).",
      "Nu modifica manual alte câmpuri din 'package.json' în afară de ceea ce adaugă automat comanda pnpm pentru 'devDependencies.eslint'.",
      "Dacă 'eslint' există deja în 'devDependencies', actualizează versiunea prin aceeași comandă pnpm (nu edita 'package.json' direct)."
    ],
    "restrictii_de_iesire_din_contex": "Nu instala încă plugin-uri TS, React sau Nx, și nu configurezi reguli ESLint în acest task. Doar adaugi dependența de bază 'eslint' la rădăcină.",
    "validare": "După rularea comenzii, verifică fișierul '/var/www/GeniusSuite/package.json' și confirmă că există cheia 'devDependencies.eslint' cu o versiune validă. Opțional, rulează 'pnpm eslint --version' din '/var/www/GeniusSuite/' pentru a verifica instalarea.",
    "outcome": "Motorul ESLint este instalat ca dependență de dezvoltare la rădăcina monorepo-ului.",
    "componenta_de_CI_CD": "Acest pachet este necesar pentru pașii de 'lint' din CI (de ex. joburi care vor rula 'nx lint' sau comenzi ESLint directe asupra proiectelor)."
  }
},
```

##### F0.1.24

```JSON
  {
  "F0.1.24": {
    "denumire_task": "Instalare Dependențe ESLint (TypeScript Parser)",
    "descriere_scurta_task": "Instalarea '@typescript-eslint/parser' la rădăcina monorepo-ului.",
    "descriere_lunga_si_detaliata_task": "Instalăm parser-ul '@typescript-eslint/parser', care permite ESLint să înțeleagă sintaxa TypeScript. Fără acest pachet, ESLint ar interpreta fișierele .ts și .tsx ca JavaScript invalid. Acest parser va fi ulterior referit în configurația ESLint (de ex. în .eslintrc.json) prin câmpul 'parser'. Pachetul se instalează ca dependență de dezvoltare la rădăcina monorepo-ului, astfel încât toate proiectele să folosească aceeași versiune.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.23: 'eslint' este instalat. F0.1.15: TypeScript este instalat.",
    "contextul_general_al_aplicatiei": "Extinderea ESLint pentru a suporta analiză statică pe cod TypeScript, aliniat cu configurarea centrală din 'tsconfig.base.json'.",
    "contextualizarea_directoarelor_si_cailor": "Execută comanda de instalare din directorul rădăcină al monorepo-ului: '/var/www/GeniusSuite/'. Comanda va modifica '/var/www/GeniusSuite/package.json' și 'pnpm-lock.yaml'.",
    "restrictii_anti_halucinatie": [
      "Execută o singură comandă de instalare: `pnpm add -D @typescript-eslint/parser` din directorul '/var/www/GeniusSuite/'.",
      "Nu instala pachetul global (NU folosi `-g`) și nu folosi alți package manageri (NU `npm`, NU `yarn`).",
      "Asigură-te că '@typescript-eslint/parser' este adăugat în 'devDependencies', nu în 'dependencies'.",
      "Nu instala în acest task alte pachete din ecosistemul '@typescript-eslint' (ex. '@typescript-eslint/eslint-plugin'); acestea vor fi instalate în taskuri separate.",
      "Nu crea și nu modifica fișiere de configurare ESLint ('.eslintrc.*') în acest task; doar instalezi dependența.",
      "Nu modifica manual alte câmpuri din 'package.json' în afară de ceea ce adaugă automat comanda pnpm pentru 'devDependencies.@typescript-eslint/parser'.",
      "Dacă '@typescript-eslint/parser' există deja în 'devDependencies', actualizează versiunea prin aceeași comandă pnpm (nu edita 'package.json' direct)."
    ],
    "restrictii_de_iesire_din_contex": "Nu instala încă plugin-ul '@typescript-eslint/eslint-plugin', preseturi sau configuri Nx/React pentru ESLint. Nu configurezi câmpul 'parser' în '.eslintrc.*' în acest task.",
    "validare": "După rularea comenzii, verifică fișierul '/var/www/GeniusSuite/package.json' și confirmă că există cheia 'devDependencies[\"@typescript-eslint/parser\"]' cu o versiune validă. Opțional, rulează 'pnpm ls @typescript-eslint/parser' din '/var/www/GeniusSuite/' pentru a confirma instalarea.",
    "outcome": "Parser-ul TypeScript pentru ESLint este instalat ca dependență de dezvoltare la rădăcina monorepo-ului și pregătit pentru a fi folosit în configurația ESLint.",
    "componenta_de_CI_CD": "Pachetul va fi folosit de joburile de 'lint' din CI atunci când ESLint este configurat să ruleze pe fișiere TypeScript."
  }
},
```

##### F0.1.25

```JSON
  {
  "F0.1.25": {
    "denumire_task": "Instalare Dependențe ESLint (TypeScript Plugin)",
    "descriere_scurta_task": "Instalarea '@typescript-eslint/eslint-plugin' la rădăcina monorepo-ului.",
    "descriere_lunga_si_detaliata_task": "Instalăm plugin-ul '@typescript-eslint/eslint-plugin', care furnizează setul de reguli specifice TypeScript pentru ESLint (ex: reguli conștiente de tipuri pentru variabile nefolosite, 'no-floating-promises', reguli pentru 'await', etc.). Acest plugin, împreună cu '@typescript-eslint/parser', permite definirea unui set complet de reguli de linting pentru codul TypeScript din întregul monorepo. Pachetul se instalează ca dependență de dezvoltare la rădăcina monorepo-ului, urmând ca activarea efectivă a regulilor să se facă în fișierele de configurare ESLint în task-uri ulterioare.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.23: 'eslint' este instalat. F0.1.24: '@typescript-eslint/parser' este instalat. F0.1.15: TypeScript este instalat.",
    "contextul_general_al_aplicatiei": "Extinderea ESLint pentru a suporta reguli specifice TypeScript, aliniate cu configurarea strictă definită în 'tsconfig.base.json'.",
    "contextualizarea_directoarelor_si_cailor": "Execută comanda de instalare din directorul rădăcină al monorepo-ului: '/var/www/GeniusSuite/'. Aceasta va modifica '/var/www/GeniusSuite/package.json' și 'pnpm-lock.yaml'.",
    "restrictii_anti_halucinatie": [
      "Execută o singură comandă de instalare: `pnpm add -D @typescript-eslint/eslint-plugin` din directorul '/var/www/GeniusSuite/'.",
      "Nu instala pachetul global (NU folosi `-g`) și nu folosi alți package manageri (NU `npm`, NU `yarn`).",
      "Asigură-te că '@typescript-eslint/eslint-plugin' este adăugat în 'devDependencies', nu în 'dependencies'.",
      "Nu instala în acest task alte plugin-uri ESLint (ex. 'eslint-plugin-react', '@nx/eslint-plugin', 'eslint-plugin-import'); acestea vor fi gestionate în task-uri separate.",
      "Nu crea și nu modifica fișiere de configurare ESLint ('.eslintrc.json', '.eslintrc.cjs', etc.) în acest task; doar instalezi dependența.",
      "Nu modifica manual alte câmpuri din 'package.json' în afară de ceea ce adaugă automat comanda pnpm pentru 'devDependencies[\"@typescript-eslint/eslint-plugin\"]'.",
      "Dacă '@typescript-eslint/eslint-plugin' există deja în 'devDependencies', actualizează versiunea prin aceeași comandă pnpm (nu edita 'package.json' direct)."
    ],
    "restrictii_de_iesire_din_contex": "Nu configurezi încă 'plugins' sau 'rules' în '.eslintrc.*'. Acest task se ocupă exclusiv de instalarea dependenței '@typescript-eslint/eslint-plugin' la rădăcină.",
    "validare": "După rularea comenzii, verifică fișierul '/var/www/GeniusSuite/package.json' și confirmă că există cheia 'devDependencies[\"@typescript-eslint/eslint-plugin\"]' cu o versiune validă. Opțional, rulează 'pnpm ls @typescript-eslint/eslint-plugin' din '/var/www/GeniusSuite/' pentru a confirma instalarea.",
    "outcome": "Plugin-ul TypeScript pentru ESLint este instalat ca dependență de dezvoltare la rădăcina monorepo-ului și este gata să fie referit în configurația ESLint.",
    "componenta_de_CI_CD": "Pachetul va fi folosit de joburile de 'lint' din CI atunci când configurația ESLint va activa regulile '@typescript-eslint'."
  }
},
```

##### F0.1.26

```JSON
  {
  "F0.1.26": {
    "denumire_task": "Instalare Dependențe ESLint (Plugin-ul Nx)",
    "descriere_scurta_task": "Instalarea '@nx/eslint-plugin' la rădăcina monorepo-ului.",
    "descriere_lunga_si_detaliata_task": "Instalăm plugin-ul ESLint specific pentru Nx, '@nx/eslint-plugin'. Acest plugin oferă reguli dedicate monorepo-urilor Nx, cum ar fi impunerea granițelor dintre module (module boundaries), verificarea corectă a dependențelor între proiecte și integrarea cu graful Nx. Pachetul se instalează ca dependență de dezvoltare la rădăcina monorepo-ului și va fi referit ulterior în configurația ESLint (ex. în .eslintrc.json) pentru a activa regulile Nx.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.23: 'eslint' este instalat. F0.1.11: 'nx' este instalat și configurat la rădăcină.",
    "contextul_general_al_aplicatiei": "Integrarea strânsă a ESLint cu capabilitățile Nx, pentru a asigura respectarea granițelor dintre module și o arhitectură de monorepo sănătoasă.",
    "contextualizarea_directoarelor_si_cailor": "Execută comanda de instalare din directorul rădăcină al monorepo-ului: '/var/www/GeniusSuite/'. Aceasta va modifica '/var/www/GeniusSuite/package.json' și 'pnpm-lock.yaml'.",
    "restrictii_anti_halucinatie": [
      "Execută o singură comandă de instalare: `pnpm add -D @nx/eslint-plugin` din directorul '/var/www/GeniusSuite/'.",
      "Nu instala pachetul global (NU folosi `-g`) și nu folosi alți package manageri (NU `npm`, NU `yarn`).",
      "Asigură-te că '@nx/eslint-plugin' este adăugat în 'devDependencies', nu în 'dependencies'.",
      "Nu instala în acest task alte pachete Nx sau ESLint suplimentare (ex. '@nx/eslint-plugin-react', preseturi custom); acestea vor fi tratate separat dacă este nevoie.",
      "Nu crea și nu modifica fișiere de configurare ESLint ('.eslintrc.json', '.eslintrc.cjs', etc.) în acest task; doar instalezi dependența.",
      "Nu modifica manual alte câmpuri din 'package.json' în afară de ceea ce adaugă automat comanda pnpm pentru 'devDependencies[\"@nx/eslint-plugin\"]'.",
      "Dacă '@nx/eslint-plugin' există deja în 'devDependencies', actualizează versiunea prin aceeași comandă pnpm (nu edita 'package.json' direct)."
    ],
    "restrictii_de_iesire_din_contex": "Nu configurezi încă 'plugins', 'extends' sau reguli Nx ('@nx/enforce-module-boundaries') în '.eslintrc.*'. Acest task se ocupă exclusiv de instalarea dependenței '@nx/eslint-plugin' la rădăcină.",
    "validare": "După rularea comenzii, verifică fișierul '/var/www/GeniusSuite/package.json' și confirmă că există cheia 'devDependencies[\"@nx/eslint-plugin\"]' cu o versiune validă. Opțional, rulează 'pnpm ls @nx/eslint-plugin' din '/var/www/GeniusSuite/' pentru a confirma instalarea.",
    "outcome": "Plugin-ul ESLint specific Nx este instalat ca dependență de dezvoltare la rădăcina monorepo-ului și este gata să fie folosit în configurațiile ESLint pentru a aplica reguli de module boundaries și bune practici Nx.",
    "componenta_de_CI_CD": "Joburile de 'lint' din CI vor folosi '@nx/eslint-plugin' pentru a aplica reguli critice (ex. enforce-module-boundaries) și pentru a preveni dependențele incorecte între proiecte în monorepo."
  }
},
```

##### F0.1.27

```JSON
  {
  "F0.1.27": {
    "denumire_task": "Creare Fișier Rădăcină '.eslintrc.json'",
    "descriere_scurta_task": "Crearea fișierului de configurare central '.eslintrc.json' la rădăcina monorepo-ului.",
    "descriere_lunga_si_detaliata_task": "Creăm fișierul '.eslintrc.json' la rădăcină. Acesta va fi fișierul de bază pe care toate proiectele din monorepo îl vor extinde. Setăm 'root: true' pentru a opri ESLint să caute configurații în directoarele părinte și folosim 'ignorePatterns': ['**/*'] conform recomandărilor Nx, astfel încât lintarea să fie controlată ulterior exclusiv prin secțiunea 'overrides'. În acest task definim doar skeleton-ul central, fără reguli sau 'extends'.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.23 - F0.1.26: Pachetele ESLint (eslint, @typescript-eslint/parser, @typescript-eslint/eslint-plugin, @nx/eslint-plugin) sunt instalate.",
    "contextul_general_al_aplicatiei": "Centralizarea configurației de linting la nivel de monorepo, astfel încât toate aplicațiile și bibliotecile să extindă aceeași bază ESLint.",
    "contextualizarea_directoarelor_si_cailor": "Creează fișierul '/var/www/GeniusSuite/.eslintrc.json' la rădăcina monorepo-ului. Acest fișier va fi punctul de intrare pentru configurațiile ESLint ale tuturor proiectelor.",
    "restrictii_anti_halucinatie": [
      "Lucrează EXCLUSIV în directorul '/var/www/GeniusSuite/'. Nu crea fișiere de configurare ESLint în alte locații în acest task.",
      "Creează (sau suprascrie) fișierul '/var/www/GeniusSuite/.eslintrc.json' cu conținut JSON VALID.",
      "Structura minimă a fișierului trebuie să fie EXACT următoarea (poți doar rearanja spațiile / indentarea, nu și cheile):",
      "{",
      "  \"root\": true,",
      "  \"ignorePatterns\": [\"**/*\"],",
      "  \"plugins\": [\"@nx\"],",
      "  \"overrides\": []",
      "}",
      "Nu adăuga câmpurile 'extends', 'rules', 'parser', 'parserOptions', 'env' sau alte chei suplimentare în acest task.",
      "Nu adăuga alte plugin-uri în afară de '@nx'.",
      "Nu crea alte fișiere '.eslintrc.*' (de ex. '.eslintrc.js', '.eslintrc.cjs') în acest task.",
      "Asigură-te că fișierul este JSON valid (fără comentarii și fără virgule la final de listă/obiect)."
    ],
    "restrictii_de_iesire_din_contex": "Nu adăuga încă reguli ESLint ('rules') sau 'extends'. Acestea vor fi configurate în task-uri separate, folosind secțiunea 'overrides'.",
    "validare": "Verifică faptul că fișierul '/var/www/GeniusSuite/.eslintrc.json' există, este JSON valid și conține cheile 'root', 'ignorePatterns', 'plugins' și 'overrides' exact ca în skeleton-ul definit.",
    "outcome": "Fișierul '.eslintrc.json' de bază este creat la rădăcina monorepo-ului, cu 'root: true' și 'ignorePatterns: [\"**/*\"]', pregătit pentru a fi extins prin 'overrides' specifice proiectelor.",
    "componenta_de_CI_CD": "Acest fișier va fi folosit ca bază pentru toate rulările ESLint din CI (ex. 'nx lint'), asigurând un punct unic de configurare pentru întregul monorepo."
  }
},
```

##### F0.1.28

```JSON
  {
  "F0.1.28": {
    "denumire_task": "Configurare 'nx.json' (Partea 3 - Plugin ESLint)",
    "descriere_scurta_task": "Adăugarea plugin-ului '@nx/eslint/plugin' în 'nx.json' pentru a permite Nx să infereze task-uri 'lint'.",
    "descriere_lunga_si_detaliata_task": "Acum că pachetele ESLint sunt instalate (inclusiv '@nx/eslint-plugin'), activăm plugin-ul '@nx/eslint/plugin' în 'nx.json'. Acest plugin permite lui Nx să infereze automat task-uri 'lint' pentru proiectele care au fișiere de configurare ESLint (ex: '.eslintrc.json') și fișiere de lint-uit. Configurația este adăugată în câmpul 'plugins' din 'nx.json' și setează în mod explicit numele țintei inferate la 'lint', astfel încât comenzi precum 'nx lint <project>' și 'nx affected:lint' să funcționeze corect.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.26: Plugin-ul '@nx/eslint-plugin' (ESLint plugin) este instalat. F0.1.14: 'nx.json' există și este configurat de bază. F0.1.27: '.eslintrc.json' root este creat.",
    "contextul_general_al_aplicatiei": "Integrarea 'Inferred Tasks' (Project Crystal) pentru ESLint, astfel încât Nx să descopere automat task-uri 'lint' în funcție de configurațiile ESLint existente.",
    "contextualizarea_directoarelor_si_cailor": "Deschide fișierul '/var/www/GeniusSuite/nx.json'. Modifică doar secțiunea de la rădăcină care conține câmpul 'plugins'. Dacă 'plugins' nu există încă, creează-l.",
    "restrictii_anti_halucinatie": [
      "Modifică EXCLUSIV fișierul '/var/www/GeniusSuite/nx.json' în acest task. Nu crea sau modifica alte fișiere de configurare Nx.",
      "Dacă la rădăcina fișierului nu există câmpul 'plugins', adaugă-l ca un array gol: \"plugins\": [].",
      "În array-ul 'plugins', adaugă un obiect cu următoarea structură (fără a șterge alte plugin-uri deja existente):",
      "{",
      "  \"plugin\": \"@nx/eslint/plugin\",",
      "  \"options\": {",
      "    \"targetName\": \"lint\"",
      "  }",
      "}",
      "Dacă există deja un obiect cu \"plugin\": \"@nx/eslint/plugin\", actualizează DOAR câmpul 'options.targetName' la valoarea \"lint\" și nu modifica alte opțiuni.",
      "Nu elimina sau suprascrie alți plugin-i existenți din 'plugins' (ex: '@nx/next/plugin', '@nx/vite/plugin', etc.), dacă apar ulterior în plan.",
      "Nu modifica alte chei din 'nx.json' (de ex. 'targetDefaults', 'tasksRunnerOptions', 'defaultBase', 'namedInputs') în acest task.",
      "Păstrează fișierul 'nx.json' ca JSON valid (fără comentarii și fără virgule în plus)."
    ],
    "restrictii_de_iesire_din_contex": "Nu adăuga alte plugin-uri Nx (ex: '@nx/next/plugin') în acest task. Nu definești aici ținte explicite 'lint' în proiecte individuale; doar activezi plugin-ul de inferență.",
    "validare": "Verifică faptul că 'nx.json' conține un array 'plugins' în care există un obiect cu 'plugin': '@nx/eslint/plugin' și 'options.targetName' setat la 'lint'. Confirmă că JSON-ul este valid și că nu au fost modificate alte secțiuni în afară de 'plugins'.",
    "outcome": "Nx este configurat să descopere și să ruleze automat task-uri de linting ('lint') pentru proiectele care dețin o configurare ESLint, prin intermediul plugin-ului '@nx/eslint/plugin'.",
    "componenta_de_CI_CD": "Acest pas permite pipeline-urilor de CI să ruleze 'nx affected:lint' sau 'nx lint <project>' bazându-se pe task-urile inferate de plugin-ul '@nx/eslint/plugin', fără a configura manual 'lint' în fiecare proiect."
  }
},
```

##### F0.1.29

```JSON
  {
  "F0.1.29": {
    "denumire_task": "Configurare '.eslintrc.json' (Integrare Nx și TS)",
    "descriere_scurta_task": "Configurarea 'plugins', 'parser', 'extends' și regulii '@nx/enforce-module-boundaries' în '.eslintrc.json' de la rădăcină.",
    "descriere_lunga_si_detaliata_task": "Configurăm fișierul '.eslintrc.json' de la rădăcina monorepo-ului pentru a folosi parser-ul TypeScript, plugin-ul Nx și seturile de reguli recomandate. Folosim pattern-ul modern Nx: 'ignorePatterns': ['**/*'] la rădăcină și definim un 'override' care se aplică tuturor fișierelor *.ts, *.tsx, *.js și *.jsx. În acest override activăm 'plugin:@nx/typescript' și 'plugin:@typescript-eslint/recommended', folosim '@typescript-eslint/parser' și activăm regula '@nx/enforce-module-boundaries' la nivel de bază (fără încă depConstraints specifice; acestea vor fi adăugate când taxonomiile de tags sunt definite). Este critic să NU setăm 'parserOptions.project' la rădăcină; această setare se va face la nivel de proiect.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.27: '.eslintrc.json' există (skeleton cu root, ignorePatterns, plugins, overrides). F0.1.23-F0.1.26: Pachetele ESLint (eslint, @typescript-eslint/parser, @typescript-eslint/eslint-plugin, @nx/eslint-plugin) sunt instalate.",
    "contextul_general_al_aplicatiei": "Activarea linting-ului bazat pe TypeScript și Nx, la nivel central, pentru toate proiectele din monorepo.",
    "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/.eslintrc.json'. Suprascrie skeleton-ul creat la F0.1.27 cu configurația completă de mai jos, păstrând 'root: true' și pattern-ul 'ignorePatterns': ['**/*'].",
    "restrictii_anti_halucinatie": [
      "Lucrează EXCLUSIV în fișierul '/var/www/GeniusSuite/.eslintrc.json'. Nu crea alte fișiere '.eslintrc.*' și nu modifica alte fișiere de configurare în acest task.",
      "Fișierul '.eslintrc.json' trebuie să fie JSON VALID, fără comentarii și fără virgule în plus.",
      "Înlocuiește conținutul existent al '.eslintrc.json' cu următoarea structură minimală completă:",
      "{",
      "  \"root\": true,",
      "  \"ignorePatterns\": [\"**/*\"],",
      "  \"plugins\": [\"@nx\"],",
      "  \"overrides\": [",
      "    {",
      "      \"files\": [\"*.ts\", \"*.tsx\", \"*.js\", \"*.jsx\"],",
      "      \"extends\": [",
      "        \"plugin:@nx/typescript\",",
      "        \"plugin:@typescript-eslint/recommended\"",
      "      ],",
      "      \"parser\": \"@typescript-eslint/parser\",",
      "      \"parserOptions\": {",
      "        \"ecmaVersion\": \"latest\",",
      "        \"sourceType\": \"module\"",
      "      },",
      "      \"rules\": {",
      "        \"@nx/enforce-module-boundaries\": [",
      "          \"error\",",
      "          {",
      "            \"enforceBuildableLibDependency\": true,",
      "            \"allow\": [],",
      "            \"depConstraints\": []",
      "          }",
      "        ]",
      "      }",
      "    }",
      "  ]",
      "}",
      "Nu adăuga câmpul 'parserOptions.project' în acest fișier. Această setare se va face în configurațiile ESLint specifice fiecărui proiect.",
      "Nu adăuga încă reguli legate de Prettier (de ex. 'prettier/prettier') sau configurări de plugin Prettier.",
      "Nu adăuga alte plugin-uri în secțiunea 'plugins' și nu adăuga alte 'overrides' în acest task.",
      "Nu modifica aici configurația Nx din 'nx.json'; acest task lucrează DOAR pe '.eslintrc.json'."
    ],
    "restrictii_de_iesire_din_contex": "Rămâi strict în contextul configurării '.eslintrc.json' root pentru TypeScript + Nx. Nu configurezi integrarea cu Prettier în acest task și nu adaugi reguli sau overrides suplimentare.",
    "validare": "Verifică faptul că '/var/www/GeniusSuite/.eslintrc.json' există, este JSON valid și conține cheile 'root', 'ignorePatterns', 'plugins' și 'overrides' exact ca în structura indicată. Confirmă că 'parser' este '@typescript-eslint/parser', că 'extends' include 'plugin:@nx/typescript' și 'plugin:@typescript-eslint/recommended' și că regula '@nx/enforce-module-boundaries' este definită cu nivel 'error' și obiect de opțiuni cu 'enforceBuildableLibDependency', 'allow' și 'depConstraints'.",
    "outcome": "ESLint este configurat la rădăcină pentru a înțelege TypeScript, a folosi regulile de bază Nx și a aplica regula '@nx/enforce-module-boundaries' în tot monorepo-ul.",
    "componenta_de_CI_CD": "Această configurație permite job-urilor de 'lint' din CI (ex. 'nx affected:lint') să aplice reguli stricte Nx și TypeScript la nivelul întregului monorepo, inclusiv verificarea granițelor dintre module."
  }
},
```

##### F0.1.30

```JSON
  {
  "F0.1.30": {
    "denumire_task": "Instalare Dependențe ESLint (Integrare Prettier Config)",
    "descriere_scurta_task": "Instalarea 'eslint-config-prettier' la rădăcina monorepo-ului.",
    "descriere_lunga_si_detaliata_task": "Instalăm pachetul 'eslint-config-prettier'. Acest pachet dezactivează regulile ESLint care intră în conflict cu regulile de formatare ale Prettier, astfel încât formatatorul (Prettier) să fie sursa de adevăr pentru stil, iar ESLint să se concentreze pe probleme de calitate a codului (bugs, best practices). Fără acest pachet, am putea avea conflicte între regulile ESLint și formatarea aplicată de Prettier.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.20: Prettier este instalat. F0.1.23: ESLint este instalat. F0.1.29: '.eslintrc.json' de bază este configurat pentru TypeScript + Nx.",
    "contextul_general_al_aplicatiei": "Reconcilierea conflictelor dintre linter (ESLint) și formatter (Prettier), astfel încât să nu existe reguli ESLint care contrazic formatarea aplicată automat.",
    "contextualizarea_directoarelor_si_cailor": "Execută comanda de instalare în directorul rădăcină al monorepo-ului: '/var/www/GeniusSuite/'. Aceasta va modifica '/var/www/GeniusSuite/package.json' și 'pnpm-lock.yaml'.",
    "restrictii_anti_halucinatie": [
      "Execută o singură comandă de instalare: `pnpm add -D eslint-config-prettier` din directorul '/var/www/GeniusSuite/'.",
      "Nu instala pachetul global (NU folosi `-g`) și nu folosi alți package manageri (NU `npm`, NU `yarn`).",
      "Asigură-te că 'eslint-config-prettier' este adăugat în 'devDependencies', nu în 'dependencies'.",
      "Nu instala încă 'eslint-plugin-prettier' sau alte plugin-uri legate de Prettier în acest task; acestea vor fi tratate separat.",
      "Nu modifica în acest task fișierul '.eslintrc.json' sau alte fișiere de configurare. Acest task se ocupă strict de instalarea dependenței.",
      "Nu modifica manual alte câmpuri din 'package.json' în afară de ceea ce adaugă automat comanda pnpm pentru 'devDependencies[\"eslint-config-prettier\"]'.",
      "Dacă 'eslint-config-prettier' există deja în 'devDependencies', actualizează versiunea prin aceeași comandă pnpm (nu edita 'package.json' direct)."
    ],
    "restrictii_de_iesire_din_contex": "Nu instala 'eslint-plugin-prettier' și nu configurezi încă integrarea Prettier în '.eslintrc.json'. Acest lucru va fi făcut într-un task ulterior.",
    "validare": "După rularea comenzii, verifică fișierul '/var/www/GeniusSuite/package.json' și confirmă că există cheia 'devDependencies[\"eslint-config-prettier\"]' cu o versiune validă. Opțional, rulează 'pnpm ls eslint-config-prettier' din '/var/www/GeniusSuite/' pentru a confirma instalarea.",
    "outcome": "Pachetul 'eslint-config-prettier' este instalat ca dependență de dezvoltare la rădăcina monorepo-ului și este gata să fie folosit în configurația ESLint pentru a dezactiva regulile în conflict cu Prettier.",
    "componenta_de_CI_CD": "Permite configurarea ulterioară a ESLint astfel încât verificările de stil din CI (lint + format) să nu se contrazică între ele, reducând zgomotul și conflictele în PR-uri."
  }
},
```

##### F0.1.31

```JSON
  {
  "F0.1.31": {
    "denumire_task": "Instalare Dependențe ESLint (Integrare Prettier Plugin)",
    "descriere_scurta_task": "Instalarea 'eslint-plugin-prettier' la rădăcina monorepo-ului.",
    "descriere_lunga_si_detaliata_task": "Instalăm 'eslint-plugin-prettier'. Acest pachet rulează Prettier ca o regulă ESLint și raportează diferențele de formatare ca probleme ESLint. Astfel, putem vedea erorile de formatare direct în output-ul ESLint și putem folosi 'eslint --fix' pentru a aplica automat formatarea Prettier în timpul dezvoltării.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.20: Prettier este instalat. F0.1.23: ESLint este instalat. F0.1.30: 'eslint-config-prettier' este instalat.",
    "contextul_general_al_aplicatiei": "Integrarea Prettier în fluxul de lucru ESLint, astfel încât linter-ul să poată raporta și enforce-ui formatarea codului.",
    "contextualizarea_directoarelor_si_cailor": "Execută comanda de instalare în directorul rădăcină al monorepo-ului: '/var/www/GeniusSuite/'. Comanda va modifica '/var/www/GeniusSuite/package.json' și 'pnpm-lock.yaml'.",
    "restrictii_anti_halucinatie": [
      "Execută o singură comandă de instalare: `pnpm add -D eslint-plugin-prettier` din directorul '/var/www/GeniusSuite/'.",
      "Nu instala pachetul global (NU folosi `-g`) și nu folosi alți package manageri (NU `npm`, NU `yarn`).",
      "Asigură-te că 'eslint-plugin-prettier' este adăugat în 'devDependencies', nu în 'dependencies'.",
      "NU modifica în acest task fișierul '.eslintrc.json' sau alte fișiere de configurare. Integrarea efectivă ('plugins', 'extends', regula 'prettier/prettier') va fi făcută într-un task ulterior.",
      "Nu instala alte pachete în aceeași comandă. Acest task se ocupă exclusiv de 'eslint-plugin-prettier'.",
      "Nu modifica manual alte câmpuri din 'package.json' în afară de ceea ce adaugă automat comanda pnpm pentru 'devDependencies[\"eslint-plugin-prettier\"]'.",
      "Dacă 'eslint-plugin-prettier' există deja în 'devDependencies', actualizează versiunea prin aceeași comandă pnpm (nu edita 'package.json' direct)."
    ],
    "restrictii_de_iesire_din_contex": "Nu configurezi încă integrarea Prettier în ESLint (nu adăuga 'prettier' în 'extends' sau 'prettier/prettier' în 'rules'). Acest task se ocupă strict de instalarea dependenței.",
    "validare": "După rularea comenzii, verifică fișierul '/var/www/GeniusSuite/package.json' și confirmă că există cheia 'devDependencies[\"eslint-plugin-prettier\"]' cu o versiune validă. Opțional, rulează 'pnpm ls eslint-plugin-prettier' din '/var/www/GeniusSuite/' pentru a confirma instalarea.",
    "outcome": "Pachetul 'eslint-plugin-prettier' este instalat ca dependență de dezvoltare la rădăcina monorepo-ului și este pregătit pentru a fi folosit în configurația ESLint.",
    "componenta_de_CI_CD": "Permite, în task-uri ulterioare, configurarea CI astfel încât verificările ESLint să raporteze și erorile de formatare Prettier, asigurând un stil de cod consistent în toate PR-urile."
  }
},
```

##### F0.1.32

```JSON
  {
  "F0.1.32": {
    "denumire_task": "Configurare '.eslintrc.json' (Integrare Prettier)",
    "descriere_scurta_task": "Adăugarea integrării Prettier în configurația ESLint de la rădăcină (extends, plugins și reguli).",
    "descriere_lunga_si_detaliata_task": "Finalizăm integrarea ESLint–Prettier în monorepo. Actualizăm fișierul '.eslintrc.json' de la rădăcină pentru a adăuga 'plugin:prettier/recommended' ca ultim element în array-ul 'extends' pentru override-ul care se aplică fișierelor '*.ts', '*.tsx', '*.js', '*.jsx'. Acest preset activează atât 'eslint-config-prettier' (care dezactivează regulile ESLint ce se bat cap în cap cu formatarea) cât și 'eslint-plugin-prettier' (care rulează Prettier ca regulă ESLint). În plus, adăugăm 'prettier' în lista de 'plugins' de la rădăcină și includem explicit regula 'prettier/prettier': 'error' în secțiunea 'rules', alături de '@nx/enforce-module-boundaries'. Astfel, 'eslint --fix' (sau 'nx lint --fix') va rula și Prettier, iar erorile de formatare vor apărea ca erori ESLint.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.29: '.eslintrc.json' este configurat pentru TypeScript + Nx, cu regula '@nx/enforce-module-boundaries'. F0.1.30: 'eslint-config-prettier' este instalat. F0.1.31: 'eslint-plugin-prettier' este instalat.",
    "contextul_general_al_aplicatiei": "O singură sursă de adevăr pentru problemele de cod (ESLint) care include și formatarea Prettier, astfel încât dezvoltatorii să poată rula un singur tool pentru lint + format.",
    "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/.eslintrc.json'. Pleacă de la configurația definită în F0.1.29 și aplică DOAR modificările necesare pentru integrarea Prettier (plugins, extends, rules).",
    "restrictii_anti_halucinatie": [
      "Lucrează exclusiv în fișierul '/var/www/GeniusSuite/.eslintrc.json'. Nu crea alte fișiere '.eslintrc.*' și nu modifica alte fișiere de configurare.",
      "Păstrează cheile existente 'root', 'ignorePatterns', 'plugins', 'overrides' și configurația regulii '@nx/enforce-module-boundaries' definite în F0.1.29. Nu le elimina.",
      "Actualizează secțiunea 'plugins' de la rădăcină astfel încât să conțină atât '@nx', cât și 'prettier':",
      "\"plugins\": [\"@nx\", \"prettier\"],",
      "Identifică override-ul unic care se aplică fișierelor ['*.ts', '*.tsx', '*.js', '*.jsx']. Lucrează doar în acest obiect din array-ul 'overrides'.",
      "În override-ul găsit, extinde array-ul 'extends' pentru a adăuga presetul Prettier ca ULTIM element, fără a șterge intrările existente:",
      "\"extends\": [",
      "  \"plugin:@nx/typescript\",",
      "  \"plugin:@typescript-eslint/recommended\",",
      "  \"plugin:prettier/recommended\"",
      "]",
      "În secțiunea 'rules' a aceluiași override, păstrează configurația existentă pentru '@nx/enforce-module-boundaries' și adaugă regula 'prettier/prettier': 'error' alături de ea. Structura minimă trebuie să arate astfel:",
      "\"rules\": {",
      "  \"prettier/prettier\": \"error\",",
      "  \"@nx/enforce-module-boundaries\": [",
      "    \"error\",",
      "    {",
      "      \"enforceBuildableLibDependency\": true,",
      "      \"allow\": [],",
      "      \"depConstraints\": []",
      "    }",
      "  ]",
      "}",
      "Nu adăuga câmpul 'parserOptions.project' în acest fișier. Această setare se configurează la nivel de proiect individual, nu la rădăcină.",
      "Nu adăuga alte reguli sau plugin-uri suplimentare în acest task. Nu modifica 'files', 'parser' sau 'parserOptions' în override.",
      "Asigură-te că fișierul '.eslintrc.json' rămâne JSON valid (fără comentarii și fără virgule la final de listă/obiect)."
    ],
    "restrictii_de_iesire_din_contex": "Nu modifica 'nx.json', '.prettierrc' sau '.prettierignore' în acest task. Nu introduci alte 'overrides' și nu redefiniți reguli care nu au legătură cu Prettier.",
    "validare": "Verifică faptul că '.eslintrc.json' conține acum 'plugins': [\"@nx\", \"prettier\"] la rădăcină, că pentru override-ul cu 'files': [\"*.ts\", \"*.tsx\", \"*.js\", \"*.jsx\"] array-ul 'extends' se termină cu '\"plugin:prettier/recommended\"', iar în 'rules' există atât 'prettier/prettier': 'error', cât și '@nx/enforce-module-boundaries' configurat corect. Rulează opțional 'pnpm eslint . --ext .ts,.tsx,.js,.jsx' pentru a verifica că fișierul de configurare este acceptat.",
    "outcome": "ESLint și Prettier sunt complet integrate: plugin-ul și config-ul Prettier sunt active, iar regulile de formatare sunt raportate ca erori ESLint.",
    "componenta_de_CI_CD": "Pasul de 'lint' din CI (ex. 'nx affected:lint') va eșua acum atât pe erori de calitate a codului (inclusiv '@nx/enforce-module-boundaries'), cât și pe erori de formatare Prettier, asigurând un stil de cod coerent în toate PR-urile."
  }
},
```

##### F0.1.33

```JSON
  {
  "F0.1.33": {
    "denumire_task": "Creare Fișier '.eslintignore'",
    "descriere_scurta_task": "Crearea fișierului '.eslintignore' pentru a exclude explicit anumite fișiere generate de la linting.",
    "descriere_lunga_si_detaliata_task": "Creăm fișierul '.eslintignore' la rădăcina monorepo-ului pentru a exclude explicit doar cazurile speciale de cod generat care nu ar trebui analizat de ESLint. Strategia principală de filtrare a fișierelor este deja implementată în '.eslintrc.json' prin 'ignorePatterns': ['**/*'] combinat cu 'overrides' pentru fișierele sursă ('*.ts', '*.tsx', '*.js', '*.jsx'). '.eslintignore' NU trebuie să dubleze regulile din '.gitignore' și nici să repete directoare de build sau cache. În schimb, îl folosim doar pentru directoare de cod generat care conțin fișiere TypeScript/JS ce ar coincide cu patternurile din 'overrides' (de ex. icoane React generate). Astfel, menținem o singură sursă de adevăr pentru ignore-uri generale ('.gitignore' + 'ignorePatterns') și folosim '.eslintignore' doar pentru excepții foarte specifice.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.27: '.eslintrc.json' a fost creat cu 'ignorePatterns': ['**/*']. F0.1.29–F0.1.32: Configurația ESLint (Nx + TS + Prettier) este completă.",
    "contextul_general_al_aplicatiei": "Optimizarea execuției 'eslint' și prevenirea erorilor sau avertismentelor pe fișiere de cod generat care nu ar trebui să fie întreținute manual.",
    "contextualizarea_directoarelor_si_cailor": "Creează fișierul '/var/www/GeniusSuite/.eslintignore' la rădăcina monorepo-ului. Acest fișier va fi luat în considerare atunci când unelte externe sau rulări directe 'eslint' caută pattern-urile de ignorare.",
    "restrictii_anti_halucinatie": [
      "Lucrează EXCLUSIV în directorul '/var/www/GeniusSuite/'. Nu crea '.eslintignore' în alte directoare.",
      "Creează (sau suprascrie) fișierul '/var/www/GeniusSuite/.eslintignore'.",
      "Nu copia și nu dubla conținutul din '.gitignore' aici (de ex. 'node_modules', 'dist', 'build', 'coverage', '.nx/cache'). Acestea sunt deja ignorate prin combinația '.gitignore' + 'ignorePatterns' din '.eslintrc.json'.",
      "Nu adăuga pattern-uri pentru '*.md', '*.json' sau 'pnpm-lock.yaml'. Aceste fișiere nu sunt vizate de override-ul ESLint pentru '*.ts', '*.tsx', '*.js', '*.jsx'.",
      "Conținutul inițial al fișierului '.eslintignore' trebuie să fie minimalist și să conțină DOAR excluderi pentru cod generat care nu trebuie lint-uit. Scrie exact următoarele linii:",
      "# Cod generat care NU trebuie lint-uit",
      "shared/ui-design-system/icons/react/generated/",
      "",
      "Nu adăuga alte pattern-uri în acest task. Pentru noi directoare de cod generat se vor crea taskuri separate.",
      "Nu modifica '.eslintrc.json' în acest task."
    ],
    "restrictii_de_iesire_din_contex": "Nu extinde acest fișier cu reguli generale de tip '.gitignore'. Rămâi strict la excluderi specifice de cod generat.",
    "validare": "Verifică existența fișierului '/var/www/GeniusSuite/.eslintignore' și că acesta conține exact comentariul și calea 'shared/ui-design-system/icons/react/generated/' pe linii separate, fără pattern-uri suplimentare.",
    "outcome": "ESLint este configurat să ignore explicit doar codul generat sensibil (ex. icoane React generate), fără a duplica regulile generale de ignorare deja acoperite de '.gitignore' și 'ignorePatterns'.",
    "componenta_de_CI_CD": "Reduce zgomotul în joburile de 'lint' din CI prin excluderea codului generat din analiza ESLint, menținând în același timp o configurație ușor de întreținut (fără dublarea regulilor de ignore)."
  }
},
```

##### F0.1.34

```JSON
  {
  "F0.1.34": {
    "denumire_task": "Instalare 'husky'",
    "descriere_scurta_task": "Instalarea 'husky' ca dependență de dezvoltare pentru gestionarea cârligelor Git.",
    "descriere_lunga_si_detaliata_task": "Instalăm pachetul 'husky', un utilitar care facilitează definirea și rularea de scripturi la evenimente Git (de ex. 'pre-commit', 'commit-msg'). Îl instalăm ca dependență de dezvoltare la rădăcina monorepo-ului, folosind pnpm. În acest task ne ocupăm strict de instalare; inițializarea structurii de hook-uri (prin 'husky init' și crearea directorului .husky/) va fi făcută în task-uri ulterioare, pentru a putea atașa corect verificările de lint, format și commit message.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.1 - F0.1.33: Fundația de tooling (pnpm, Nx, TypeScript, ESLint, Prettier, ignore-uri) este configurată la rădăcina monorepo-ului.",
    "contextul_general_al_aplicatiei": "Impunerea standardelor de calitate (lint, format, reguli de commit) înainte ca modificările să ajungă în CI sau pe branch-urile principale, prin folosirea de hooks Git gestionate de Husky.",
    "contextualizarea_directoarelor_si_cailor": "Execută comanda de instalare din directorul rădăcină al monorepo-ului: '/var/www/GeniusSuite/'. Aceasta va modifica fișierele '/var/www/GeniusSuite/package.json' și 'pnpm-lock.yaml'.",
    "restrictii_anti_halucinatie": [
      "Execută O SINGURĂ comandă de instalare: `pnpm add -D husky` în directorul '/var/www/GeniusSuite/'.",
      "Nu instala pachetul global (NU folosi `-g`) și nu folosi alți package manageri (NU `npm`, NU `yarn`).",
      "Asigură-te că 'husky' este adăugat în 'devDependencies', nu în 'dependencies'.",
      "Nu rula în acest task niciuna dintre comenzile de inițializare Husky (NU rula `npx husky install`, `pnpm husky install` sau `husky init`). Acestea au task dedicat ulterior.",
      "Nu crea manual directorul '.husky/' și nu adăuga fișiere de hook (de ex. '.husky/pre-commit') în acest task.",
      "Nu modifica manual alte câmpuri din 'package.json' în afară de ceea ce adaugă automat comanda pnpm pentru 'devDependencies.husky'.",
      "Dacă 'husky' există deja în 'devDependencies', actualizează versiunea prin aceeași comandă pnpm (nu edita 'package.json' direct)."
    ],
    "restrictii_de_iesire_din_contex": "Nu configura încă niciun hook Git și nu adăuga scripturi noi în 'package.json' (de ex. 'prepare'). Acest task se ocupă exclusiv de instalarea dependenței 'husky' la rădăcină.",
    "validare": "După rularea comenzii, verifică fișierul '/var/www/GeniusSuite/package.json' și confirmă că există cheia 'devDependencies.husky' cu o versiune validă. Opțional, rulează 'pnpm husky --help' din '/var/www/GeniusSuite/' pentru a confirma că pachetul este disponibil.",
    "outcome": "'husky' este instalat ca dependență de dezvoltare la rădăcina monorepo-ului și este pregătit pentru a fi inițializat și configurat în task-urile următoare.",
    "componenta_de_CI_CD": "Deși acest task nu modifică direct pipeline-ul de CI, el pregătește infrastructura necesară pentru a rula local hook-uri de tip 'pre-commit' și 'commit-msg', reducând numărul de erori care ajung în CI și pe branch-urile partajate."
  }
},
```

##### F0.1.35

```JSON
  {
  "F0.1.35": {
    "denumire_task": "Inițializare 'husky' (v9+)",
    "descriere_scurta_task": "Rularea 'husky init' pentru a crea directorul '.husky' și a configura script-ul 'prepare'.",
    "descriere_lunga_si_detaliata_task": "Rulăm comanda 'pnpm exec husky init' pentru a inițializa Husky la rădăcina monorepo-ului. Această comandă va: (1) crea directorul '.husky/' (dacă nu există), (2) crea un hook de exemplu 'pre-commit' în interiorul '.husky/' și (3) adăuga (sau ajusta) script-ul 'prepare' în 'package.json' de la rădăcină. Script-ul 'prepare' rulează automat după 'pnpm install' și se ocupă de activarea hook-urilor Git, astfel încât orice dezvoltator care clonează repository-ul și rulează 'pnpm install' va avea Husky activat fără pași manuali suplimentari.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.34: 'husky' este instalat ca dependență de dezvoltare la rădăcină.",
    "contextul_general_al_aplicatiei": "Activarea automată a cârligelor Git pentru toți dezvoltatorii, astfel încât verificările de lint/format/commit message să ruleze local înainte ca modificările să ajungă în CI sau pe branch-uri partajate.",
    "contextualizarea_directoarelor_si_cailor": "Execută comanda din directorul rădăcină al monorepo-ului: '/var/www/GeniusSuite/'. Comanda va crea directorul '/var/www/GeniusSuite/.husky/' și va modifica '/var/www/GeniusSuite/package.json' (script-ul 'prepare').",
    "restrictii_anti_halucinatie": [
      "Lucrează EXCLUSIV în directorul '/var/www/GeniusSuite/'. Nu rula comanda în subdirectoare (ex. cp/, shared/, etc.).",
      "Execută EXACT comanda: `pnpm exec husky init` din '/var/www/GeniusSuite/'.",
      "Nu folosi comenzi bazate pe npm (NU `npx husky-init`, NU `npx husky install`). Folosește strict varianta recomandată pentru pnpm: `pnpm exec husky init`.",
      "Nu crea manual directorul '.husky/' înainte de a rula comanda; lasă 'husky init' să îl creeze.",
      "Nu edita manual script-ul 'prepare' din 'package.json' înainte de a rula comanda. Lasă 'husky init' să adauge sau să actualizeze script-ul.",
      "Dacă după rularea comenzii script-ul 'prepare' există deja și conține 'husky', nu adăuga duplicate. Nu edita 'prepare' decât dacă un task ulterior cere explicit acest lucru.",
      "Nu modifica sau șterge hook-ul 'pre-commit' generat implicit în acest task. Va fi suprascris/ajustat în taskurile următoare.",
      "Nu crea sau modifica alte hook-uri (ex. '.husky/commit-msg') în acest task.",
      "Nu modifica alte câmpuri din 'package.json' în afară de ceea ce face automat comanda 'pnpm exec husky init'."
    ],
    "restrictii_de_iesire_din_contex": "Nu modifica conținutul fișierelor din '.husky/' în acest task. Schimbarea conținutului 'pre-commit' și adăugarea altor hook-uri se va face în taskurile următoare.",
    "validare": "Verifică existența directorului '/var/www/GeniusSuite/.husky/'. Verifică faptul că în '/var/www/GeniusSuite/package.json' există un script 'prepare' care rulează 'husky' (de ex. \"prepare\": \"husky\"). Confirmă că există un fișier '.husky/pre-commit' generat de Husky.",
    "outcome": "'husky' este inițializat la rădăcina monorepo-ului, directorul '.husky/' este creat, iar script-ul 'prepare' din 'package.json' este configurat pentru a activa hook-urile Git după fiecare 'pnpm install'.",
    "componenta_de_CI_CD": "CI-ul trebuie să ruleze 'pnpm install' (care va rula script-ul 'prepare') înainte de pașii de build/lint/test, pentru a asigura un mediu local consistent cu cel folosit de dezvoltatori. Hook-urile Git sunt de obicei ocolite în CI, dar această inițializare garantează că repository-ul este pregătit corect pentru dezvoltare locală."
  }
},
```

##### F0.1.36

```JSON
  {
  "F0.1.36": {
    "denumire_task": "Instalare 'lint-staged'",
    "descriere_scurta_task": "Instalarea 'lint-staged' pentru a rula comenzi doar pe fișierele aflate în 'staged'.",
    "descriere_lunga_si_detaliata_task": "Instalăm 'lint-staged', un utilitar care permite rularea de comenzi (lint, format, teste rapide) doar pe fișierele care sunt în 'staged' înainte de commit. Acesta va fi folosit împreună cu Husky în hook-ul 'pre-commit' pentru a rula ESLint și Prettier doar pe fișierele modificate, făcând verificările locale foarte rapide vàsă reducând fricțiunea pentru dezvoltatori.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.35: 'husky' este inițializat (directorul '.husky/' și script-ul 'prepare' sunt configurate). F0.1.20–F0.1.32: Prettier și ESLint sunt instalate și configurate.",
    "contextul_general_al_aplicatiei": "Optimizarea hook-ului 'pre-commit' astfel încât verificările de lint/format să fie rapide, rulând doar pe fișierele din 'staged' în locul întregului monorepo.",
    "contextualizarea_directoarelor_si_cailor": "Execută comanda de instalare în directorul rădăcină al monorepo-ului: '/var/www/GeniusSuite/'. Aceasta va modifica '/var/www/GeniusSuite/package.json' și 'pnpm-lock.yaml'.",
    "restrictii_anti_halucinatie": [
      "Execută O SINGURĂ comandă de instalare: `pnpm add -D lint-staged` în directorul '/var/www/GeniusSuite/'.",
      "Nu instala pachetul global (NU folosi `-g`) și nu folosi alți package manageri (NU `npm`, NU `yarn`).",
      "Asigură-te că 'lint-staged' este adăugat în 'devDependencies', nu în 'dependencies'.",
      "Nu configura 'lint-staged' în acest task (nu adăuga cheie 'lint-staged' în 'package.json' și nu crea fișiere separate de config). Configurația va fi făcută într-un task ulterior.",
      "Nu modifica fișierele din '.husky/' în acest task (de ex. '.husky/pre-commit'). Integrarea efectivă cu Husky va fi făcută în taskuri ulterioare.",
      "Nu instala alte pachete în aceeași comandă. Acest task se ocupă exclusiv de 'lint-staged'.",
      "Nu modifica manual alte câmpuri din 'package.json' în afară de ceea ce adaugă automat comanda pnpm pentru 'devDependencies[\"lint-staged\"]'.",
      "Dacă 'lint-staged' există deja în 'devDependencies', actualizează versiunea prin aceeași comandă pnpm (nu edita 'package.json' direct)."
    ],
    "restrictii_de_iesire_din_contex": "Nu configura încă mapările 'lint-staged' și nu edita hook-ul 'pre-commit'. Acest task se ocupă strict de instalarea dependenței.",
    "validare": "După rularea comenzii, verifică fișierul '/var/www/GeniusSuite/package.json' și confirmă că există cheia 'devDependencies[\"lint-staged\"]' cu o versiune validă. Opțional, rulează 'pnpm lint-staged --version' din '/var/www/GeniusSuite/' pentru a confirma instalarea.",
    "outcome": "'lint-staged' este instalat ca dependență de dezvoltare la rădăcina monorepo-ului și pregătit pentru a fi configurat și integrat cu Husky în hook-ul 'pre-commit'.",
    "componenta_de_CI_CD": "Nu modifică direct pipeline-ul de CI, dar pregătește infrastructura pentru ca verificările locale (pre-commit) să fie rapide și consistente, reducând numărul de erori care ajung în CI."
  }
},
```

##### F0.1.37

```JSON
  {
  "F0.1.37": {
    "denumire_task": "Configurare 'lint-staged' în '.lintstagedrc.json' (Critic)",
    "descriere_scurta_task": "Crearea fișierului '.lintstagedrc.json' care rulează comenzi Nx ('format:write' și 'affected:lint') pe fișierele staged.",
    "descriere_lunga_si_detaliata_task": "Creăm configurația pentru 'lint-staged' la rădăcina monorepo-ului. În loc să rulăm direct 'prettier --write' și 'eslint --fix' pe fișierele staged, folosim comenzile wrapper Nx ('nx format:write' și 'nx affected:lint') cu opțiunea '--files'. Astfel, Nx folosește graful de dependențe și caching-ul propriu ca să determine proiectele afectate și să ruleze doar formatarea și linting-ul necesare. Configurația va rula mai întâi 'nx format:write --files' (prettier prin Nx), apoi 'nx affected:lint --fix --files' (ESLint prin Nx) pentru toate fișierele TypeScript și JavaScript aflate în staged.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.36: 'lint-staged' este instalat. F0.1.32: ESLint/Prettier sunt configurate. F0.1.29: ESLint este integrat cu Nx (@nx/enforce-module-boundaries).",
    "contextul_general_al_aplicatiei": "Impunerea standardelor de cod (formatare + linting Nx-aware) în mod eficient la momentul comiterii, folosind ecosistemul Nx în locul rulării directe a tool-urilor.",
    "contextualizarea_directoarelor_si_cailor": "Creează fișierul '/var/www/GeniusSuite/.lintstagedrc.json' la rădăcina monorepo-ului. Acesta va fi fișierul de configurare folosit de 'lint-staged' atunci când este apelat din hook-ul Husky 'pre-commit'.",
    "restrictii_anti_halucinatie": [
      "Lucrează EXCLUSIV în directorul '/var/www/GeniusSuite/'. Creează (sau suprascrie) fișierul '.lintstagedrc.json' la rădăcină.",
      "Fișierul '.lintstagedrc.json' trebuie să fie JSON VALID, conținând un obiect cu mapări glob -> listă de comenzi.",
      "Nu introduce comentarii în JSON (nu sunt suportate).",
      "Conținutul inițial al fișierului '.lintstagedrc.json' trebuie să fie EXACT următorul:",
      "{",
      "  \"*.{ts,tsx,js,jsx}\": [",
      "    \"nx format:write --files\",",
      "    \"nx affected:lint --fix --files\"",
      "  ]",
      "}",
      "Nu adăuga alte chei sau pattern-uri glob în acest task. Configurația de mai sus acoperă toate fișierele sursă relevante (TS/JS) și se bazează pe Nx pentru a determina proiectele afectate.",
      "NU folosi direct 'prettier --write' sau 'eslint --fix' în '.lintstagedrc.json'. Toată logica trebuie să treacă prin comenzi Nx ('nx format:write', 'nx affected:lint').",
      "Nu modifica fișierele '.eslintrc.json', '.prettierrc', '.prettierignore' sau configurații Nx în cadrul acestui task.",
      "Nu adăuga script suplimentar 'lint-staged' în 'package.json' în acest task; acesta va fi, dacă este nevoie, adăugat într-un task ulterior."
    ],
    "restrictii_de_iesire_din_contex": "Rămâi strict în contextul definirii configurației 'lint-staged' la rădăcină. Nu modifica hook-urile Husky (ex. '.husky/pre-commit') în acest task; acestea vor fi ajustate în task-ul următor.",
    "validare": "Verifică faptul că fișierul '/var/www/GeniusSuite/.lintstagedrc.json' există, este JSON valid și conține exact maparea '*. {ts,tsx,js,jsx}' către lista de comenzi ['nx format:write --files', 'nx affected:lint --fix --files']. Opțional, rulează 'pnpm lint-staged --dry-run' pentru a verifica că fișierele TS/JS staged declanșează comenzile Nx.",
    "outcome": "Configurația 'lint-staged' este creată astfel încât, pentru fișierele TypeScript/JavaScript din staged, să ruleze mai întâi formatarea Nx ('nx format:write --files') și apoi linting-ul Nx ('nx affected:lint --fix --files').",
    "componenta_de_CI_CD": "Această configurație asigură că, înainte de orice commit local, formatarea și linting-ul Nx sunt aplicate doar pe fișierele modificate, reducând erorile care ajung în CI și îmbunătățind viteza de feedback pentru dezvoltatori."
  }
},
```

##### F0.1.38

```JSON
  {
    "F0.1.38": {
      "denumire_task": "Creare Hook 'pre-commit' (Husky)",
      "descriere_scurta_task": "Crearea hook-ului 'pre-commit' folosind 'husky add' pentru a rula 'lint-staged'.",
      "descriere_lunga_si_detaliata_task": "Acum legăm 'husky' de 'lint-staged'. Folosim comanda 'husky add' pentru a crea (sau suprascrie) fișierul '.husky/pre-commit'. Acest fișier va conține o singură comandă: 'npx lint-staged'.[8] Aceasta va declanșa configurația definită în F0.1.37 de fiecare dată când cineva încearcă să facă un commit.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.35: 'husky' este inițializat. F0.1.37: 'lint-staged' este configurat.",
      "contextul_general_al_aplicatiei": "Activarea finală a validării de formatare și linting la momentul comiterii.",
      "contextualizarea_directoarelor_si_cailor": "Comanda va crea/modifica fișierul '.husky/pre-commit'.",
      "restrictii_anti_halucinatie": [
        "Execută comanda: 'pnpm exec husky add.husky/pre-commit \"npx lint-staged\"'",
        "Asigură-te că suprascrii fișierul 'pre-commit' implicit creat de 'husky init'.",
        "Comanda din interiorul hook-ului trebuie să fie 'npx lint-staged' (sau 'pnpm exec lint-staged')."
      ],
      "restrictii_de_iesire_din_contex": "Nu adăuga alte comenzi în hook-ul 'pre-commit'.",
      "validare": "Verifică conținutul fișierului '.husky/pre-commit'. Acesta ar trebui să conțină 'npx lint-staged'.",
      "outcome": "Hook-ul 'pre-commit' este configurat pentru a rula 'lint-staged'.",
      "componenta_de_CI_CD": "N/A"
    }
  },
```

##### F0.1.39

```JSON
  {
  "F0.1.39": {
    "denumire_task": "Instalare 'commitlint' (CLI)",
    "descriere_scurta_task": "Instalarea '@commitlint/cli' ca dependență de dezvoltare la rădăcina monorepo-ului.",
    "descriere_lunga_si_detaliata_task": "Instalăm '@commitlint/cli', utilitarul în linie de comandă pentru commitlint. Acesta va fi folosit ulterior în hook-ul Git 'commit-msg' (prin Husky) pentru a valida mesajele de commit conform unui standard (ex. Conventional Commits). În acest task ne ocupăm strict de instalarea CLI-ului la rădăcina monorepo-ului, fără a configura încă regulile sau presetul ('config-conventional').",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.35: 'husky' este inițializat ('.husky/' + script 'prepare'). F0.1.34–F0.1.38: infrastructura de hook-uri (Husky + lint-staged) este funcțională.",
    "contextul_general_al_aplicatiei": "Impunerea unui standard pentru mesajele de commit (ex. Conventional Commits), necesar pentru generarea automată a changelog-urilor și versionarea semantică în F0.2.",
    "contextualizarea_directoarelor_si_cailor": "Execută comanda de instalare în directorul rădăcină al monorepo-ului: '/var/www/GeniusSuite/'. Aceasta va modifica '/var/www/GeniusSuite/package.json' și 'pnpm-lock.yaml'.",
    "restrictii_anti_halucinatie": [
      "Execută O SINGURĂ comandă de instalare: `pnpm add -D @commitlint/cli` în directorul '/var/www/GeniusSuite/'.",
      "Nu instala pachetul global (NU folosi `-g`) și nu folosi alți package manageri (NU `npm`, NU `yarn`).",
      "Asigură-te că '@commitlint/cli' este adăugat în 'devDependencies', nu în 'dependencies'.",
      "Nu instala în acest task pachetul '@commitlint/config-conventional' sau alte preseturi/configuri commitlint. Acestea vor fi instalate într-un task separat.",
      "Nu crea sau modifica fișiere de configurare commitlint în acest task (ex. 'commitlint.config.cjs', '.commitlintrc.*').",
      "Nu modifica fișierele din '.husky/' în acest task (ex. nu crea încă hook-ul 'commit-msg').",
      "Nu modifica manual alte câmpuri din 'package.json' în afară de ceea ce adaugă automat comanda pnpm pentru 'devDependencies[\"@commitlint/cli\"]'.",
      "Dacă '@commitlint/cli' există deja în 'devDependencies', actualizează versiunea prin aceeași comandă pnpm (nu edita 'package.json' direct)."
    ],
    "restrictii_de_iesire_din_contex": "Nu configurezi încă regulile commitlint și nu creezi hook-ul 'commit-msg'. Acest task se ocupă exclusiv de instalarea '@commitlint/cli' la rădăcină.",
    "validare": "După rularea comenzii, verifică fișierul '/var/www/GeniusSuite/package.json' și confirmă că există cheia 'devDependencies[\"@commitlint/cli\"]' cu o versiune validă. Opțional, rulează 'pnpm commitlint --help' din '/var/www/GeniusSuite/' pentru a verifica faptul că binarul este disponibil.",
    "outcome": "'commitlint' (CLI) este instalat ca dependență de dezvoltare la rădăcina monorepo-ului și pregătit pentru a fi configurat și legat de hook-ul Git 'commit-msg' în taskurile următoare.",
    "componenta_de_CI_CD": "Această dependență este esențială pentru F0.2 (CI/CD), unde va fi folosită împreună cu preseturi (ex. 'config-conventional') și 'semantic-release' pentru a impune mesaje de commit standardizate și a permite versionare semantică automată."
  }
},
```

##### F0.1.40

```JSON
  {
  "F0.1.40": {
    "denumire_task": "Instalare 'commitlint' (Config)",
    "descriere_scurta_task": "Instalarea '@commitlint/config-conventional' ca preset de reguli pentru commitlint.",
    "descriere_lunga_si_detaliata_task": "Instalăm '@commitlint/config-conventional', presetul oficial de reguli pentru commitlint bazat pe 'Conventional Commits' (tipuri de commit precum 'feat:', 'fix:', 'docs:', 'chore:' etc.). Acest pachet va fi folosit în configurația commitlint (de ex. 'commitlint.config.cjs') pentru a impune formatul standardizat al mesajelor de commit. În acest task facem doar instalarea presetului, fără a crea încă fișierele de configurare.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.39: '@commitlint/cli' este instalat ca dependență de dezvoltare. F0.1.35: Husky este inițializat și pregătit pentru hook-uri.",
    "contextul_general_al_aplicatiei": "Adoptarea standardului 'Conventional Commits' pentru mesaje de commit, ca bază pentru changelog automat și versionare semantică în F0.2.",
    "contextualizarea_directoarelor_si_cailor": "Execută comanda de instalare în directorul rădăcină al monorepo-ului: '/var/www/GeniusSuite/'. Aceasta va modifica '/var/www/GeniusSuite/package.json' și 'pnpm-lock.yaml'.",
    "restrictii_anti_halucinatie": [
      "Execută O SINGURĂ comandă de instalare: `pnpm add -D @commitlint/config-conventional` în directorul '/var/www/GeniusSuite/'.",
      "Nu instala pachetul global (NU folosi `-g`) și nu folosi alți package manageri (NU `npm`, NU `yarn`).",
      "Asigură-te că '@commitlint/config-conventional' este adăugat în 'devDependencies', nu în 'dependencies'.",
      "Nu crea încă fișiere de configurare commitlint (ex. 'commitlint.config.cjs', '.commitlintrc.*') în acest task; acestea vor fi create într-un task ulterior.",
      "Nu modifica fișierele din '.husky/' (ex. hook-ul 'commit-msg') în acest task.",
      "Nu modifica manual alte câmpuri din 'package.json' în afară de ceea ce adaugă automat comanda pnpm pentru 'devDependencies[\"@commitlint/config-conventional\"]'.",
      "Dacă '@commitlint/config-conventional' există deja în 'devDependencies', actualizează versiunea prin aceeași comandă pnpm (nu edita 'package.json' direct)."
    ],
    "restrictii_de_iesire_din_contex": "Nu configurezi încă regulile commitlint și nu legi commitlint la Husky. Acest task se ocupă strict de instalarea presetului '@commitlint/config-conventional'.",
    "validare": "După rularea comenzii, verifică fișierul '/var/www/GeniusSuite/package.json' și confirmă că există cheia 'devDependencies[\"@commitlint/config-conventional\"]' cu o versiune validă. Opțional, rulează 'pnpm commitlint --help' pentru a verifica faptul că presetul este disponibil pentru a fi referit în configurație.",
    "outcome": "Presetul '@commitlint/config-conventional' este instalat ca dependență de dezvoltare și pregătit pentru a fi folosit în configurația commitlint pentru a impune Conventional Commits.",
    "componenta_de_CI_CD": "Permite ca, în fazele următoare (F0.1.41+ și F0.2), pipeline-ul de CI și uneltele precum 'semantic-release' să folosească mesaje de commit standardizate pentru generarea automată de changelog și versionare semantică."
  }
},
```

##### F0.1.41

```JSON
  {
  "F0.1.41": {
    "denumire_task": "Configurare 'commitlint'",
    "descriere_scurta_task": "Crearea fișierului de configurare 'commitlint.config.js' la rădăcina monorepo-ului.",
    "descriere_lunga_si_detaliata_task": "Creăm fișierul de configurare pentru 'commitlint' la rădăcină. Configurația extinde presetul '@commitlint/config-conventional', ceea ce activează regulile standard 'Conventional Commits' (feat, fix, docs, chore etc.) pentru toate mesajele de commit. În acest task definim doar configurarea de bază, fără reguli custom.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.40: '@commitlint/config-conventional' este instalat. F0.1.39: '@commitlint/cli' este instalat.",
    "contextul_general_al_aplicatiei": "Activarea regulilor 'Conventional Commits' pentru a standardiza mesajele de commit și a pregăti terenul pentru changelog automat și semantic-release.",
    "contextualizarea_directoarelor_si_cailor": "Creează fișierul '/var/www/GeniusSuite/commitlint.config.js' la rădăcina monorepo-ului. Commitlint îl va folosi automat când rulează în acest director.",
    "restrictii_anti_halucinatie": [
      "Lucrează EXCLUSIV în directorul '/var/www/GeniusSuite/'.",
      "Creează un fișier NOU 'commitlint.config.js' dacă nu există deja. Dacă există, suprascrie-l complet cu conținutul specificat.",
      "Conținutul fișierului trebuie să fie EXACT acesta (CommonJS, fără alte chei sau reguli):",
      \"module.exports = {",
      "  extends: ['@commitlint/config-conventional']",
      "};",
      "Nu adăuga alte proprietăți (de ex. 'rules', 'parserPreset') în acest task.",
      "Nu crea alternativ '.commitlintrc.json' sau alte formate de config în acest task; folosim doar 'commitlint.config.js'.",
      "Asigură-te că fișierul este JavaScript valid (fără comentarii inline care ar rupe sintaxa CommonJS)."
    ],
    "restrictii_de_iesire_din_contex": "Nu adăuga încă reguli custom commitlint (cheia 'rules') și nu modifică hook-urile Husky ('commit-msg') în acest task.",
    "validare": "Verifică existența fișierului '/var/www/GeniusSuite/commitlint.config.js' și confirmă că exportă un obiect cu 'extends: [\"@commitlint/config-conventional\"]'. Opțional, rulează 'echo \"feat: test\" | pnpm commitlint' pentru a verifica că fișierul este citit fără erori.",
    "outcome": "Configurația 'commitlint' este creată la rădăcina monorepo-ului și extinde presetul '@commitlint/config-conventional'.",
    "componenta_de_CI_CD": "Permite ulterior legarea commitlint la hook-ul 'commit-msg' (Husky) și integrarea cu pipeline-ul de CI și semantic-release."
  }
},
```

##### F0.1.42

```JSON
  {
  "F0.1.42": {
    "denumire_task": "Creare Hook 'commit-msg' (Husky)",
    "descriere_scurta_task": "Crearea hook-ului 'commit-msg' folosind 'husky add' pentru a rula 'commitlint'.",
    "descriere_lunga_si_detaliata_task": "Legăm 'husky' de 'commitlint' printr-un hook Git 'commit-msg'. Folosim comanda 'pnpm exec husky add' pentru a crea fișierul '.husky/commit-msg'. Acest hook este declanșat după ce 'pre-commit' a rulat și înainte ca commit-ul să fie finalizat și validează mesajul de commit folosind 'commitlint', bazat pe configurația 'commitlint.config.js' (F0.1.41). Dacă mesajul nu respectă regulile 'Conventional Commits', commit-ul este blocat.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.35: 'husky' este inițializat ('.husky/' + 'prepare'). F0.1.39–F0.1.41: '@commitlint/cli', '@commitlint/config-conventional' și 'commitlint.config.js' sunt configurate.",
    "contextul_general_al_aplicatiei": "Activarea finală a validării mesajelor de commit conform unui standard unitar (Conventional Commits).",
    "contextualizarea_directoarelor_si_cailor": "Comanda se execută în '/var/www/GeniusSuite/' și va crea fișierul '/var/www/GeniusSuite/.husky/commit-msg'.",
    "restrictii_anti_halucinatie": [
      "Lucrează EXCLUSIV în directorul '/var/www/GeniusSuite/'.",
      "Asigură-te că directorul '.husky/' există deja (creat de 'pnpm exec husky init' în F0.1.35).",
      "Execută EXACT comanda următoare din '/var/www/GeniusSuite/':",
      "pnpm exec husky add .husky/commit-msg \"pnpm exec commitlint --edit \\\"$1\\\"\"",
      "Nu folosi comenzi bazate pe npm (NU 'npx commitlint'). Respectă standardul monorepo-ului: 'pnpm exec'.",
      "Această comandă va crea sau suprascrie fișierul '.husky/commit-msg'. Suprascrierea este intenționată.",
      "După rularea comenzii, nu modifica manual linia generată de Husky pentru 'pnpm exec commitlint --edit \"$1\"', cu excepția cazului în care un task ulterior cere explicit asta.",
      "Nu adăuga alte comenzi în hook-ul 'commit-msg' (de exemplu, nu rula teste sau alte scripturi aici).",
      "Nu modifica alte hook-uri Husky (de ex. '.husky/pre-commit') în acest task."
    ],
    "restrictii_de_iesire_din_contex": "Rămâi strict la configurarea hook-ului 'commit-msg' pentru commitlint. Nu modifica configurația 'commitlint.config.js' sau alte fișiere de tooling în acest task.",
    "validare": "Verifică existența fișierului '/var/www/GeniusSuite/.husky/commit-msg'. Deschide fișierul și confirmă că, după shebang-ul generat de Husky, există o linie care execută 'pnpm exec commitlint --edit \"$1\"'. Opțional, încearcă un commit cu un mesaj invalid (ex. 'bad message') și verifică faptul că este blocat de commitlint.",
    "outcome": "Hook-ul 'commit-msg' este configurat pentru a rula 'commitlint' la fiecare commit, blocând mesajele care nu respectă standardul 'Conventional Commits'.",
    "componenta_de_CI_CD": "Deși acest hook rulează local, el asigură că toate commit-urile care ajung în CI respectă formatul necesar pentru generarea automată de changelog și versionare semantică."
  }
},
 ```

##### F0.1.43

```JSON
  {
  "F0.1.43": {
    "denumire_task": "Adăugare Script-uri 'lint' în 'package.json'",
    "descriere_scurta_task": "Adăugarea script-urilor 'lint' și 'lint:fix' în 'package.json' de la rădăcină pentru rularea linting-ului pe întregul monorepo.",
    "descriere_lunga_si_detaliata_task": "Adăugăm scripturi convenabile în 'package.json' de la rădăcină pentru a rula linting pe întregul monorepo, fie local, fie în CI. În loc să apelăm direct ESLint, folosim comanda Nx 'run-many', care rulează ținta 'lint' pe toate proiectele configurate. Scriptul 'lint' rulează verificarea fără fix, iar 'lint:fix' rulează aceeași comandă cu '--fix' pentru a aplica automat remediile acolo unde este posibil.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.12: Nx este inițializat. F0.1.29–F0.1.32: ESLint este configurat la nivel de monorepo și integrat cu Nx.",
    "contextul_general_al_aplicatiei": "Furnizarea unor puncte de intrare standardizate ('pnpm lint', 'pnpm lint:fix') pentru validarea întregului proiect, utilizabile atât local, cât și în CI.",
    "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/package.json', în secțiunea 'scripts'. Nu crea un alt 'package.json'.",
    "restrictii_anti_halucinatie": [
      "Deschide fișierul '/var/www/GeniusSuite/package.json' și lucrează EXCLUSIV în cheia 'scripts'.",
      "Nu șterge scripturile existente (ex. 'prepare' adăugat de Husky, 'dev', 'build', 'test', etc.).",
      "Dacă nu există deja cheile 'lint' și 'lint:fix' în 'scripts', adaugă-le astfel:",
      "\"lint\": \"nx run-many -t lint --all\",",
      "\"lint:fix\": \"nx run-many -t lint --all --fix\"",
      "Dacă există deja scripturi 'lint' sau 'lint:fix', înlocuiește-le cu valorile de mai sus, fără a modifica alte scripturi.",
      "Păstrează JSON-ul valid: nu lăsa virgule în plus sau chei duplicate în 'scripts'.",
      "Nu adăuga încă scripturi suplimentare precum 'format' sau 'format:check' în acest task.",
      "Nu modifica alte câmpuri (ex. 'dependencies', 'devDependencies', 'name', 'version') în acest task."
    ],
    "restrictii_de_iesire_din_contex": "Rămâi strict la adăugarea/actualizarea scripturilor 'lint' și 'lint:fix' din 'package.json'. Nu modifici configurarea Nx sau fișiere ESLint în acest task.",
    "validare": "Verifică faptul că în '/var/www/GeniusSuite/package.json' există cheile 'scripts.lint' și 'scripts.lint:fix' cu valorile 'nx run-many -t lint --all' și respectiv 'nx run-many -t lint --all --fix'. Opțional, rulează 'pnpm lint' din '/var/www/GeniusSuite/' pentru a verifica faptul că comenzile rulează fără erori de configurare.",
    "outcome": "Scripturile globale de linting sunt disponibile prin 'pnpm lint' și 'pnpm lint:fix', facilitând rularea linting-ului pe întregul monorepo.",
    "componenta_de_CI_CD": "Pipeline-ul de CI poate folosi acum 'pnpm lint' pentru a rula linting-ul pe toate proiectele (sau 'nx affected -t lint' în joburi dedicate pentru schimbări afectate)."
  }
},
```

##### F0.1.44

```JSON
  {
  "F0.1.44": {
    "denumire_task": "Adăugare Script-uri 'format' în 'package.json'",
    "descriere_scurta_task": "Adăugarea script-urilor 'format:check' și 'format:write' în 'package.json' de la rădăcină pentru a folosi wrapper-ul Nx pentru Prettier.",
    "descriere_lunga_si_detaliata_task": "Adăugăm script-uri convenabile în 'package.json' de la rădăcina monorepo-ului pentru a verifica ('format:check') și aplica ('format:write') formatarea Prettier prin wrapper-ul Nx ('nx format:check' și 'nx format:write'). Aceste comenzi folosesc configurația Prettier definită la rădăcină și sunt integrate cu Nx, astfel încât pot fi folosite atât local, cât și în CI ca puncte de intrare standard.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.12: Nx este inițializat. F0.1.20–F0.1.22: Prettier este instalat și configurat (.prettierrc + .prettierignore). F0.1.32: Integrarea ESLint–Prettier este finalizată.",
    "contextul_general_al_aplicatiei": "Furnizarea unor comenzi standardizate pentru formatarea întregului monorepo, utilizabile atât de dezvoltatori local (pnpm format:write / format:check), cât și în pipeline-ul de CI.",
    "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/package.json', în secțiunea 'scripts'. Nu crea un alt 'package.json' și nu modifica alte pachete.",
    "restrictii_anti_halucinatie": [
      "Deschide fișierul '/var/www/GeniusSuite/package.json' și lucrează EXCLUSIV în cheia 'scripts'.",
      "Nu șterge scripturi existente (ex. 'prepare' pentru Husky, 'lint', 'lint:fix', 'dev', 'build', etc.).",
      "Dacă nu există deja cheile 'format:check' și 'format:write' în 'scripts', adaugă-le EXACT cu valorile:",
      "\"format:check\": \"nx format:check\",",
      "\"format:write\": \"nx format:write\"",
      "Dacă există deja scripturi 'format:check' sau 'format:write', înlocuiește-le cu valorile de mai sus, fără a modifica alte scripturi.",
      "Păstrează JSON-ul valid: asigură-te că toate intrările din 'scripts' sunt separate prin virgule corecte și nu există chei duplicate.",
      "Nu adăuga în acest task scripturi suplimentare (ex. 'format:staged' sau 'format:affected'); acestea ar necesita taskuri separate.",
      "Nu modifica alte câmpuri din 'package.json' ('dependencies', 'devDependencies', 'name', 'version', etc.)."
    ],
    "restrictii_de_iesire_din_contex": "Rămâi strict la adăugarea/ajustarea scripturilor 'format:check' și 'format:write'. Nu modifici configurarea Nx, ESLint sau Prettier în acest task.",
    "validare": "Verifică faptul că în '/var/www/GeniusSuite/package.json' există cheile 'scripts.format:check' și 'scripts.format:write' cu valorile 'nx format:check' și respectiv 'nx format:write'. Opțional, rulează 'pnpm format:check' din '/var/www/GeniusSuite/' pentru a verifica faptul că Nx recunoaște comanda.",
    "outcome": "Scripturile globale de formatare sunt disponibile prin 'pnpm format:check' (verificare) și 'pnpm format:write' (aplicare), facilitând formatarea consistentă a codului în întregul monorepo.",
    "componenta_de_CI_CD": "Pipeline-ul de CI poate rula 'pnpm format:check' pentru a valida că PR-urile respectă formatarea Prettier, înainte de merge."
  }
},
```

##### F0.1.45

```JSON
  {
  "F0.1.45": {
    "denumire_task": "Validare Hook 'pre-commit' (Test Eșec Lint)",
    "descriere_scurta_task": "Testarea hook-ului 'pre-commit' prin introducerea intenționată a unei erori de linting într-un fișier staged.",
    "descriere_lunga_si_detaliata_task": "Acest task validează că hook-ul 'pre-commit' configurat cu Husky + lint-staged (F0.1.38) funcționează corect. Scopul este să confirmăm că, atunci când un fișier cu erori de linting este adăugat în 'staged', încercarea de commit eșuează, iar commit-ul NU este creat. Vom crea un fișier temporar TypeScript, vom introduce o eroare ESLint evidentă (de exemplu folosirea tipului 'any'), îl vom adăuga în 'staged' și vom încerca să facem un commit. Ne așteptăm ca hook-ul 'pre-commit' să ruleze 'lint-staged', care la rândul său va apela 'nx format:write --files' și 'nx affected:lint --fix --files', iar linting-ul să eșueze, blocând commit-ul. După test, curățăm fișierul și starea Git.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.36: 'lint-staged' este instalat. F0.1.37: '.lintstagedrc.json' este configurat cu comenzi Nx. F0.1.38: hook-ul 'pre-commit' este creat și rulează 'pnpm exec lint-staged'.",
    "contextul_general_al_aplicatiei": "Testarea efectivă a infrastructurii de DevEx (Husky + lint-staged + Nx + ESLint/Prettier) pentru a ne asigura că erorile de linting nu pot intra în istoria Git.",
    "contextualizarea_directoarelor_si_cailor": "Toate comenzile se execută în directorul rădăcină al repository-ului: '/var/www/GeniusSuite/'. Fișierul temporar de test poate fi creat într-un subdirector neutru (de exemplu 'tmp/' sau la rădăcină), atâta timp cât calea lui este acoperită de globul din '.lintstagedrc.json' ('*.{ts,tsx,js,jsx}').",
    "restrictii_anti_halucinatie": [
      "Lucrează EXCLUSIV în directorul '/var/www/GeniusSuite/'. Nu modifica fișiere de configurare în acest task; doar creezi un fișier de test și rulezi comenzi Git.",
      "Alege un nume clar pentru fișierul temporar, de exemplu 'lint-precommit-test.ts' și creează-l în rădăcină sau într-un director simplu (de ex. 'tmp/lint-precommit-test.ts'). Asigură-te că extensia este '.ts' astfel încât să fie prins de pattern-ul '*.ts,*.tsx,*.js,*.jsx' din '.lintstagedrc.json'.",
      "Conținut recomandat pentru eroare ESLint/TS clare (în fișierul de test):",
      \"export const lintPrecommitTest = (): any => {",
      "  // folosirea tipului 'any' este interzisă de 'plugin:@typescript-eslint/recommended'",
      "  const x: any = 1;",
      "  return x;",
      "};",
      "Nu modifica fișiere existente din proiect pentru acest test; folosește DOAR fișierul temporar creat.",
      "Secvența recomandată de comenzi (execută-le textual, adaptând numele fișierului dacă l-ai schimbat):",
      "1) cd /var/www/GeniusSuite/",
      "2) Creează fișierul de test (exemplu):",
      "   echo \"export const lintPrecommitTest = (): any => { const x: any = 1; return x; };\" > lint-precommit-test.ts",
      "3) Adaugă fișierul în staging:",
      "   git add lint-precommit-test.ts",
      "4) Încearcă un commit de test:",
      "   git commit -m \"test: pre-commit lint should fail\"",
      "Așteptarea este ca PASUL 4 să EȘUEZE (exit code nenul) din cauza erorilor ESLint raportate de 'lint-staged' / Nx.",
      "Dacă, DIN GREȘEALĂ, commit-ul reușește (ceea ce indică o configurare greșită a hook-ului), rulează imediat:",
      "   git reset --soft HEAD~1",
      "pentru a anula commit-ul, și marchează testul ca FAILED.",
      "După ce ai confirmat că hook-ul 'pre-commit' blochează commit-ul (comanda 'git commit' a eșuat), curăță fișierul de test și starea Git:",
      " - Scoate fișierul din staging (dacă e cazul):",
      "   git restore --staged lint-precommit-test.ts || true",
      " - Șterge fișierul de test din filesystem:",
      "   rm lint-precommit-test.ts || true",
      "Nu face 'git commit' cu fișierul de test păstrat. Acest fișier NU trebuie să rămână în repository.",
      "Nu împinge (push) niciun commit rezultat din acest test către un remote.",
      "Nu modifica configurările '.lintstagedrc.json', '.eslintrc.json', 'nx.json' sau alte fișiere de tooling în cadrul acestui task."
    ],
    "restrictii_de_iesire_din_contex": "Rămâi strict în contextul VALIDĂRII comportamentului hook-ului 'pre-commit'. Nu încerca să repari configurația în acest task (dacă testul eșuează, se va crea un task separat pentru debugging/configurare).",
    "validare": "Validarea este considerată REUȘITĂ dacă: (1) comanda 'git commit -m \"test: pre-commit lint should fail\"' eșuează cu un mesaj de eroare provenit din 'lint-staged' / Nx / ESLint, și (2) nu rămâne niciun commit nou în istorie și fișierul de test a fost șters din repository. Poți verifica istoricul cu 'git log -1' pentru a te asigura că ultimul commit REAL nu este commit-ul de test.",
    "outcome": "Hook-ul 'pre-commit' este confirmat ca fiind funcțional: commit-urile care introduc erori de linting în fișierele sursă sunt blocate înainte de a intra în istoria Git.",
    "componenta_de_CI_CD": "Acest task validează experiența locală a dezvoltatorilor. Deși CI nu rulează hook-uri Husky în mod normal, această verificare asigură că majoritatea problemelor de linting sunt prinse devreme, înainte ca schimbările să ajungă în pipeline-ul de CI."
  }
},
```

##### F0.1.46

```JSON
  {
  "F0.1.46": {
    "denumire_task": "Validare Hook 'pre-commit' (Test Auto-Fix)",
    "descriere_scurta_task": "Testarea hook-ului 'pre-commit' pentru auto-fixarea erorilor de formatare și linting.",
    "descriere_lunga_si_detaliata_task": "Acest task validează că pipeline-ul 'lint-staged' configurat în F0.1.37 (care rulează 'nx format:write --files' și 'nx affected:lint --fix --files') chiar poate corecta automat probleme simple de formatare și linting la momentul comiterii. Vom crea un fișier TypeScript cu formatare incorectă și o eroare de stil care poate fi auto-fixată (de ex. spațiere greșită și lipsa punctului și virgulei), îl vom adăuga în 'staged' și vom încerca să facem un commit. Ne așteptăm ca hook-ul 'pre-commit' să ruleze 'lint-staged', care la rândul lui va apela Nx: codul va fi reformatat și auto-fixat, iar commit-ul va REUȘI. La final, vom inspecta fișierul pentru a confirma că formatarea a fost corectată și vom curăța orice urme (fișierul de test nu trebuie să rămână în repository).",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.36: 'lint-staged' este instalat. F0.1.37: '.lintstagedrc.json' rulează 'nx format:write --files' și 'nx affected:lint --fix --files' pe fișierele staged. F0.1.38: hook-ul 'pre-commit' Husky este configurat să ruleze 'pnpm exec lint-staged'. F0.1.45: S-a validat că hook-ul poate BLOCA commit-uri cu erori de linting.",
    "contextul_general_al_aplicatiei": "Testarea infrastructurii de Developer Experience pentru a confirma că nu doar blochează codul prost, ci și auto-corectează problemele simple de formatare și linting acolo unde este posibil.",
    "contextualizarea_directoarelor_si_cailor": "Toate comenzile se execută în '/var/www/GeniusSuite/'. Fișierul de test trebuie creat într-o locație simplă prinsă de glob-ul '.lintstagedrc.json' (ex. 'test-format.ts' la rădăcină).",
    "restrictii_anti_halucinatie": [
      "Lucrează EXCLUSIV în directorul '/var/www/GeniusSuite/'. Nu modifica fișiere de configurare (Nx, ESLint, Prettier, Husky, lint-staged) în acest task.",
      "Alege un nume de fișier de test clar, de exemplu 'test-format.ts', creat la rădăcina repository-ului, astfel încât să fie prins de pattern-ul '*.ts' din '.lintstagedrc.json'.",
      "Creează fișierul de test cu o formatare vizibil incorectă, dar cu probleme care pot fi auto-fixate de Prettier/ESLint. Exemplu minimal:",
      "\"export const  testFormat=()=>{",
      "console.log('x')",
      "}\",
      "Observații pentru exemplu:",
      "- Spațiere intenționat greșită ('const  testFormat').",
      "- Lipsă spații după virgule și înainte de acolade.",
      "- Lipsă punct și virgulă la finalul liniilor.",
      "Nu folosi erori de tip pe care ESLint/TS nu le poate auto-fixa (de ex. tipuri invalide sau variabile nedeclarate). Obiectivul este ca hook-ul să poată remedia automat fișierul.",
      "Secvența recomandată de comenzi (presupunând fișierul 'test-format.ts'):",
      "1) cd /var/www/GeniusSuite/",
      "2) Creează fișierul de test (exemplu simplificat în shell):",
      "   cat > test-format.ts << 'EOF'",
      "   export const  testFormat=()=>{",
      "   console.log('x')",
      "   }",
      "   EOF",
      "3) Adaugă fișierul în staging:",
      "   git add test-format.ts",
      "4) Încearcă un commit de test:",
      "   git commit -m "\"test: pre-commit auto-fix formatting\"",
      "Așteptarea este ca PASUL 4 să REUȘEASCĂ (exit code 0), pentru că:",
      "- 'lint-staged' va rula 'nx format:write --files' → Prettier re-formatează fișierul.",
      "- Apoi 'nx affected:lint --fix --files' → ESLint aplică auto-fix acolo unde este cazul.",
      "- 'lint-staged' va re-adăuga fișierul modificat în index și va permite commit-ul dacă nu mai există erori.",
      "După commit, verifică faptul că fișierul este formatat corect (ex. cu punct și virgulă, spații normalize):",
      "   cat test-format.ts",
      "Te aștepți la ceva de tipul:",
      \"export const testFormat = () => {",
      "  console.log('x');",
      "};",
      "Dacă commit-ul EȘUEAZĂ cu erori de linting/formatare:",
      "- Notează comportamentul ca FAIL al testului (hook-ul nu reușește să auto-fixeze complet).",
      "- Nu încerca să repari configurația în acest task; va fi nevoie de un task separat pentru debugging.",
      "IMPORTANT: Nu lăsa fișierul de test sau commit-ul în istoria repository-ului.",
      "Dacă commit-ul a reușit:",
      "- Anulează commit-ul de test:",
      "   git reset --soft HEAD~1",
      "- Scoate fișierul din staging:",
      "   git restore --staged test-format.ts || true",
      "- Șterge fișierul de pe disc:",
      "   rm test-format.ts || true",
      "Dacă commit-ul nu a reușit, dar fișierul este încă în staging sau în workspace:",
      "- Scoate fișierul din staging:",
      "   git restore --staged test-format.ts || true",
      "- Șterge fișierul de pe disc:",
      "   rm test-format.ts || true",
      "Nu împinge (push) niciun commit de test către un remote.",
      "Nu redenumi sau muta alte fișiere din proiect în acest task."
    ],
    "restrictii_de_iesire_din_contex": "Rămâi strict în contextul VALIDĂRII comportamentului de auto-fix al hook-ului 'pre-commit'. Nu modifica configurațiile ESLint/Prettier/Nx/Husky și nu adăuga alte fișiere permanente în proiect.",
    "validare": "Testul este considerat REUȘIT dacă: (1) comanda 'git commit -m \"test: pre-commit auto-fix formatting\"' REUȘEȘTE, (2) conținutul fișierului 'test-format.ts' după rularea hook-ului este formatat corect (ex. 'export const testFormat = () => { console.log(\"x\"); };' cu spații și punct și virgulă conform Prettier), și (3) după finalizarea taskului, fișierul de test și commit-ul de test NU mai există (git reset + rm aplicate).",
    "outcome": "Hook-ul 'pre-commit' este confirmat că poate auto-corecta formatarea și unele probleme de linting pentru fișierele staged, înainte ca acestea să fie comise.",
    "componenta_de_CI_CD": "Acest task confirmă că pipeline-ul local (Husky + lint-staged + Nx) aduce codul într-o stare formatată și lint-uită înainte de a ajunge în CI, reducând numărul de erori raportate de joburile de lint/format din pipeline."
  }
},
```

##### F0.1.47

```JSON
  {
  "F0.1.47": {
    "denumire_task": "Validare Hook 'commit-msg' (Test Eșec)",
    "descriere_scurta_task": "Testarea hook-ului 'commit-msg' prin furnizarea unui mesaj de commit neconform cu Conventional Commits.",
    "descriere_lunga_si_detaliata_task": "Acest task validează că hook-ul Husky 'commit-msg' (F0.1.42) și configurația 'commitlint' (F0.1.41) funcționează corect. Scopul este să demonstrăm că un commit cu un mesaj care nu respectă regulile 'Conventional Commits' (de ex. un simplu 'test' sau 'mesaj invalid') este blocat. Vom crea un fișier TypeScript de test cu conținut valid, îl vom adăuga în staging și vom încerca să facem un commit folosind un mesaj clar neconform (fără 'type: subject'). Ne așteptăm ca hook-ul 'commit-msg' să ruleze 'commitlint', care va returna erori și va împiedica commit-ul.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.39: '@commitlint/cli' este instalat. F0.1.40: '@commitlint/config-conventional' este instalat. F0.1.41: 'commitlint.config.js' extinde '@commitlint/config-conventional'. F0.1.42: hook-ul '.husky/commit-msg' este configurat să ruleze 'pnpm exec commitlint --edit \"$1\"'.",
    "contextul_general_al_aplicatiei": "Testarea infrastructurii de Developer Experience pentru a asigura că toate mesajele de commit respectă standardul 'Conventional Commits' înainte de a ajunge în istoria Git.",
    "contextualizarea_directoarelor_si_cailor": "Toate comenzile se execută în directorul rădăcină al repository-ului: '/var/www/GeniusSuite/'. Fișierul de test ('test-commitmsg.ts') va fi creat în acest director sau într-un subdirector simplu, dar suficient încât să fie urmărit de Git.",
    "restrictii_anti_halucinatie": [
      "Lucrează EXCLUSIV în directorul '/var/www/GeniusSuite/'.",
      "Asigură-te că nu ai alte fișiere în 'staged' înainte de acest test. Dacă există, fă commit/stash sau rulează 'git reset' pentru a avea un context curat.",
      "Creează un fișier de test valid, dar trivial, de exemplu 'test-commitmsg.ts' la rădăcină:",
      "Comandă recomandată:",
      "  echo \"export const testCommitMsg = () => 'ok';\" > test-commitmsg.ts",
      "Adaugă fișierul în staging:",
      "  git add test-commitmsg.ts",
      "Execută un commit cu un mesaj intenționat INVALID (nu folosi Conventional Commits):",
      "  git commit -m 'mesaj invalid'",
      "NU folosi opțiunea '--no-verify' (aceasta ar ocoli hook-ul 'commit-msg').",
      "Așteptarea este ca comanda 'git commit' să EȘUEZE cu un cod de ieșire nenul și să afișeze erori provenite din 'commitlint' (de tipul 'type may not be empty', 'subject may not be empty' sau mesaje similare generate de '@commitlint/config-conventional').",
      "Dacă, din greșeală, commit-ul reușește:",
      "- tratează testul ca FAILED,",
      "- anulează imediat commit-ul:",
      "    git reset --soft HEAD~1",
      "- și continuă cu pașii de curățare de mai jos.",
      "După ce comanda 'git commit' a eșuat (comportamentul dorit), curăță starea repository-ului:",
      "- Scoate fișierul din staging (dacă este încă staged):",
      "    git restore --staged test-commitmsg.ts || true",
      "- Șterge fișierul de test din filesystem:",
      "    rm test-commitmsg.ts || true",
      "Verifică faptul că nu a fost creat niciun commit nou în istorie:",
      "- opțional: compară 'git log -1' înainte și după test sau verifică că nu există un commit cu mesajul 'mesaj invalid'.",
      "Nu împinge (push) niciun commit rezultat din acest test către remote.",
      "Nu modifica configurările 'commitlint.config.js' sau fișierele din '.husky/' în cadrul acestui task.",
      "Nu modifica alte fișiere din proiect în afara fișierului temporar de test."
    ],
    "restrictii_de_iesire_din_contex": "Rămâi strict în contextul VALIDĂRII hook-ului 'commit-msg'. Nu remediezi configurări în acest task; dacă testul eșuează (commit-ul trece cu mesaj invalid), se va crea un task separat pentru debugging.",
    "validare": "Testul este considerat REUȘIT dacă: (1) comanda 'git commit -m \"mesaj invalid\"' EȘUEAZĂ, (2) mesajul de eroare afișat în terminal provine de la 'commitlint' (ex. erori despre 'type' sau 'subject' lipsă conform 'config-conventional'), și (3) după curățare, nu există niciun commit nou în istorie și fișierul 'test-commitmsg.ts' a fost șters.",
    "outcome": "Hook-ul 'commit-msg' este confirmat ca fiind funcțional și capabil să blocheze commit-urile care nu respectă regulile 'Conventional Commits'.",
    "componenta_de_CI_CD": "Deși acest test se concentrează pe comportamentul local al hook-ului, el garantează că toate commit-urile care ajung în CI au mesaje standardizate, lucru esențial pentru integrarea ulterioară cu semantic-release și generarea automată a changelog-urilor."
  }
},
```

##### F0.1.48

```JSON
  {
  "F0.1.48": {
    "denumire_task": "Validare Hook 'commit-msg' (Test Succes)",
    "descriere_scurta_task": "Testarea hook-ului 'commit-msg' cu un mesaj de commit convențional valid.",
    "descriere_lunga_si_detaliata_task": "Acest task validează că un mesaj de commit valid conform 'Conventional Commits' (de ex. 'feat: add commitlint') trece de hook-ul 'commit-msg' configurat cu Husky și commitlint. Spre deosebire de F0.1.47 (unde am verificat că un mesaj invalid este blocat), aici verificăm că un mesaj CORECT nu este blocat. Vom crea un fișier TypeScript de test cu conținut valid, îl vom adăuga în staging și vom executa un commit cu un mesaj conform (ex. 'feat: validate commit-msg hook'). Ne așteptăm ca hook-ul 'commit-msg' să ruleze 'commitlint', să accepte mesajul și commit-ul să REUȘEASCĂ. La final, vom curăța commit-ul de test și fișierul, astfel încât repository-ul să revină la starea inițială.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.39–F0.1.41: '@commitlint/cli', '@commitlint/config-conventional' și 'commitlint.config.js' sunt configurate. F0.1.42: hook-ul 'commit-msg' Husky rulează 'pnpm exec commitlint --edit \"$1\"'. F0.1.47: S-a validat că un mesaj de commit INVALID este blocat.",
    "contextul_general_al_aplicatiei": "Testarea infrastructurii de DevEx pentru a confirma că regulile 'Conventional Commits' sunt aplicate corect: mesajele invalide sunt respinse, iar mesajele valide sunt acceptate fără fricțiune pentru dezvoltatori.",
    "contextualizarea_directoarelor_si_cailor": "Toate comenzile se execută în directorul rădăcină al repository-ului: '/var/www/GeniusSuite/'. Fișierul de test (de ex. 'test-commitmsg-success.ts') va fi creat în acest director, astfel încât să fie urmărit de Git dar ușor de șters ulterior.",
    "restrictii_anti_halucinatie": [
      "Lucrează EXCLUSIV în directorul '/var/www/GeniusSuite/'.",
      "Înainte de test, asigură-te că nu există alte fișiere în 'staged'. Dacă există, rulează 'git status' și curăță starea (commit/stash/reset) astfel încât numai fișierul de test să fie implicat în acest test.",
      "Creează un fișier de test valid, de exemplu 'test-commitmsg-success.ts' la rădăcină, cu conținut TypeScript simplu și corect. Exemplu:",
      "  echo \"export const testCommitMsgSuccess = () => 'ok';\" > test-commitmsg-success.ts",
      "Adaugă fișierul în staging:",
      "  git add test-commitmsg-success.ts",
      "Execută un commit cu un mesaj VALID conform 'Conventional Commits', de exemplu:",
      "  git commit -m \"feat: validate commit-msg hook\"",
      "NU folosi opțiunea '--no-verify' (ar ocoli hook-ul 'commit-msg').",
      "Așteptarea este ca comanda 'git commit' să REUȘEASCĂ (exit code 0) fără erori de la 'commitlint'.",
      "Dacă commit-ul EȘUEAZĂ cu erori de la 'commitlint', marchează testul ca FAILED (înseamnă că regulile sunt prea stricte sau mesajul nu este conform) și NU încerca să repari configurația în acest task.",
      "După ce ai confirmat că commit-ul de test a REUȘIT:",
      "- Anulează commit-ul de test pentru a nu polua istoricul:",
      "    git reset --soft HEAD~1",
      "- Scoate fișierul din staging (dacă este cazul):",
      "    git restore --staged test-commitmsg-success.ts || true",
      "- Șterge fișierul de test de pe disc:",
      "    rm test-commitmsg-success.ts || true",
      "Verifică faptul că:",
      "- Nu mai există commit-ul 'feat: validate commit-msg hook' în istorie (de ex. 'git log -1' nu îl arată ca ultim commit).",
      "- 'git status' arată un working tree curat sau doar modificările așteptate (fără 'test-commitmsg-success.ts').",
      "Nu împinge (push) commit-ul de test către remote.",
      "Nu modifica fișierul 'commitlint.config.js' sau hook-ul '.husky/commit-msg' în acest task.",
      "Nu modifica alte fișiere din proiect în afara fișierului temporar 'test-commitmsg-success.ts'."
    ],
    "restrictii_de_iesire_din_contex": "Rămâi strict în contextul VALIDĂRII scenariului de succes al hook-ului 'commit-msg'. Nu schimba configurări, reguli sau hook-uri în acest task.",
    "validare": "Testul este considerat REUȘIT dacă: (1) 'git commit -m \"feat: validate commit-msg hook\"' REUȘEȘTE fără erori de la 'commitlint', (2) după rularea 'git reset --soft HEAD~1' și ștergerea fișierului, nu există niciun commit nou persistent în istorie și 'test-commitmsg-success.ts' nu mai există în repository.",
    "outcome": "Hook-ul 'commit-msg' este confirmat nu doar că blochează mesaje invalide (F0.1.47), ci și că acceptă mesajele conform 'Conventional Commits', validând întregul flux de commitlint.",
    "componenta_de_CI_CD": "Acest test asigură că dezvoltatorii pot folosi mesaje de commit valide fără blocaje artificiale, iar CI și instrumente precum semantic-release pot avea încredere în consistența mesajelor de commit."
  }
},
```

##### F0.1.49

```JSON
  {
  "F0.1.49": {
    "denumire_task": "Creare Fișier Rădăcină 'README.md'",
    "descriere_scurta_task": "Crearea unui fișier 'README.md' de bază pentru monorepo.",
    "descriere_lunga_si_detaliata_task": "Creăm un fișier 'README.md' la rădăcina monorepo-ului. Acesta va servi ca punct de intrare pentru noii dezvoltatori, descriind pe scurt suita GeniusSuite, stack-ul principal folosit (Nx, pnpm, TypeScript etc.) și oferind instrucțiuni de bază de inițializare și comenzi uzuale (lint, format). În acest task construim doar o versiune minimală, clară și factuală, fără a intra în detalii de arhitectură sau în documentația fiecărui modul.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.1 - F0.1.48: Fundația de monorepo, tooling (pnpm, Nx, TypeScript, ESLint, Prettier), hook-uri Husky și validări a fost configurată și testată.",
    "contextul_general_al_aplicatiei": "Documentație minimă, dar esențială, pentru onboarding-ul dezvoltatorilor în monorepo-ul GeniusSuite.",
    "contextualizarea_directoarelor_si_cailor": "Creează fișierul '/var/www/GeniusSuite/README.md' la rădăcina repository-ului. Acesta va fi primul fișier pe care îl vede un dezvoltator când deschide proiectul în editor sau pe platforma de git hosting.",
    "restrictii_anti_halucinatie": [
      "Lucrează EXCLUSIV în directorul '/var/www/GeniusSuite/'. Creează (sau suprascrie) fișierul 'README.md' la rădăcină.",
      "Nu crea alte fișiere de documentație în acest task (ex. 'CONTRIBUTING.md', 'docs/').",
      "Conținutul 'README.md' trebuie să fie Markdown valid și să includă, MINIM, următoarele secțiuni și informații:",
      "1) Un titlu clar pentru monorepo:",
      "# GeniusSuite Monorepo",
      "",
      "2) O descriere scurtă a proiectului (în 1–3 propoziții), de ex.:",
      "GeniusSuite este o suită de aplicații și servicii (Control Plane, ERP, DMS, aplicații stand-alone) organizate într-un monorepo Nx, cu tooling unificat pentru dezvoltare, testare și livrare.",
      "",
      "3) O secțiune despre stack-ul principal:",
      "## Stack Principal",
      "",
      "* **Monorepo:** Nx + pnpm workspaces",
      "* **Limbaj:** TypeScript (strict)",
      "* **Tooling:** ESLint, Prettier, Husky, lint-staged, commitlint",
      "",
      "4) O secțiune de inițializare cu comanda de instalare:",
      "## Inițializare",
      "",
      "```bash",
      "pnpm install",
      "```",
      "",
      "5) O secțiune cu comenzi uzuale, care să folosească scripturile deja definite în 'package.json':",
      "## Comenzi Uzuale",
      "",
      "```bash",
      "# Rulează linting pe toate proiectele",
      "pnpm lint",
      "",
      "# Verifică formatarea (fără a modifica fișierele)",
      "pnpm format:check",
      "",
      "# Aplică formatarea pe întregul monorepo",
      "pnpm format:write",
      "```",
      "",
      "Nu inventa alte comenzi care nu sunt definite în 'package.json' (de ex. nu adăuga 'pnpm test' sau 'pnpm dev' dacă nu există încă).",
      "Nu descrie module sau aplicații care nu au fost încă definite în plan (nu lista servicii, API-uri sau URL-uri speculative). Folosește o descriere generică de nivel înalt pentru GeniusSuite.",
      "Nu adăuga badge-uri de CI/CD, link-uri către repo remote sau secțiuni avansate (contribuții, release process). Acestea pot fi adăugate în taskuri ulterioare.",
      "Textul trebuie să fie concis, factual și să reflecte DOAR ceea ce a fost setat efectiv în faza F0.1 (stack, tooling, comenzi)."
    ],
    "restrictii_de_iesire_din_contex": "Rămâi strict în contextul creării unui 'README.md' de bază. Nu modifica alte fișiere de configurație și nu adăuga documentație suplimentară în acest task.",
    "validare": "Verifică faptul că fișierul '/var/www/GeniusSuite/README.md' există, este Markdown valid și conține cel puțin secțiunile: titlu, descriere scurtă, 'Stack Principal', 'Inițializare' și 'Comenzi Uzuale' cu comenzile 'pnpm install', 'pnpm lint', 'pnpm format:check' și 'pnpm format:write'.",
    "outcome": "Monorepo-ul GeniusSuite are un fișier 'README.md' de bază, util pentru onboarding-ul inițial al dezvoltatorilor și pentru a expune rapid stack-ul și comenzile fundamentale.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

##### F0.1.50

```JSON
  {
  "F0.1.50": {
    "denumire_task": "Creare Branch 'dev'",
    "descriere_scurta_task": "Crearea branch-ului 'dev' din branch-ul principal ('master' sau 'main') și poziționarea pe acesta.",
    "descriere_lunga_si_detaliata_task": "Conform guvernanței Git cu 3 branch-uri (master, staging, dev), creăm branch-ul de lucru 'dev' pornind din branch-ul principal al repository-ului ('master' sau 'main', în funcție de cum este configurat repo-ul). După crearea branch-ului 'dev', acesta devine branch-ul activ pentru lucrul curent. În acest task NU facem commit-uri și NU împingem (push) nimic; doar creăm/activăm branch-ul 'dev'.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.1 - F0.1.49: Fundația de monorepo, tooling și hook-uri Git este definită la nivel de plan și urmează să fie implementată efectiv pe branch-ul 'dev'.",
    "contextul_general_al_aplicatiei": "Respectarea guvernanței Git cu 3 branch-uri (master, staging, dev) pentru fluxul de dezvoltare: 'dev' pentru dezvoltare activă, 'staging' pentru testare integrată, 'master' (sau 'main') pentru producție.",
    "contextualizarea_directoarelor_si_cailor": "Toate comenzile Git se execută în directorul rădăcină al repository-ului: '/var/www/GeniusSuite/'.",
    "restrictii_anti_halucinatie": [
      "Lucrează EXCLUSIV în '/var/www/GeniusSuite/'. Înainte de orice, rulează: `cd /var/www/GeniusSuite/`.",
      "Verifică că ești într-un repository Git valid: `git rev-parse --is-inside-work-tree`. Dacă acest comandă eșuează, NU încerca să creezi branch-uri (repo-ul nu este inițializat sau nu e corect).",
      "Verifică că nu ai modificări necomitate înainte de a schimba branch-ul: `git status --porcelain` trebuie să fie gol. Dacă există modificări, acestea trebuie comitate, stashed sau resetate într-un task separat, nu în acesta.",
      "Determină branch-ul principal EXISTENT fără a-l presupune:",
      "1) Dacă `git show-ref --verify --quiet refs/heads/master` are exit code 0, consideră 'master' ca branch principal.",
      "2) Altfel, dacă `git show-ref --verify --quiet refs/heads/main` are exit code 0, consideră 'main' ca branch principal.",
      "3) Dacă nici 'master' nici 'main' nu există, oprește task-ul și marchează-l drept FAIL (nu inventa numele branch-ului principal).",
      "Fă checkout pe branch-ul principal determinat la pasul anterior, de exemplu:",
      "- `git checkout master` sau",
      "- `git checkout main`",
      "Dacă există remote 'origin' (verifică cu `git remote` și vezi dacă include 'origin'), atunci adu ultimele schimbări ALEA branch-ului principal:",
      "- `git pull origin master` sau `git pull origin main`",
      "Dacă 'origin' NU există, NU rula 'git pull origin ...'. Nu inventa remote-uri.",
      "Verifică dacă branch-ul 'dev' există deja:",
      "- Dacă `git show-ref --verify --quiet refs/heads/dev` are exit code 0, NU îl recrea. Doar fă: `git checkout dev`.",
      "- Dacă branch-ul 'dev' NU există, creează-l din branch-ul principal curent prin: `git checkout -b dev`.",
      "NU rula comenzi care modifică istoricul (ex. 'git rebase', 'git merge', 'git reset --hard') în acest task.",
      "NU face commit-uri și NU rula `git push` în acest task. Scopul este exclusiv crearea/activarea branch-ului 'dev'."
    ],
    "restrictii_de_iesire_din_contex": "Rămâi strict în contextul creării și activării branch-ului 'dev'. Nu crea și nu modifica alte branch-uri (ex. 'staging') în acest task.",
    "validare": "Execută `git branch --show-current` sau `git rev-parse --abbrev-ref HEAD` în '/var/www/GeniusSuite/'. Rezultatul trebuie să fie exact 'dev'. Verifică de asemenea că `git show-ref --verify --quiet refs/heads/dev` returnează exit code 0 (branch-ul există).",
    "outcome": "Branch-ul 'dev' există în repository și este branch-ul curent activ, pregătit pentru a primi implementarea efectivă a task-urilor F0.1 prin commit-uri și PR-uri/MR-uri ulterioare.",
    "componenta_de_CI_CD": "N/A (acest task pregătește doar structura de branch-uri; integrarea cu CI/CD va fi definită în fazele ulterioare, de ex. F0.2)."
  }
},
```

##### F0.1.51

```JSON
  {
  "F0.1.51": {
    "denumire_task": "Comisionare Artefacte F0.1 pe Branch-ul 'dev'",
    "descriere_scurta_task": "Adăugarea și comisionarea tuturor fișierelor de fundație F0.1 pe branch-ul 'dev' cu un mesaj de commit convențional.",
    "descriere_lunga_si_detaliata_task": "Acest task finalizează faza F0.1 prin comisionarea tuturor artefactelor de fundație pe branch-ul 'dev'. Pe acest branch trebuie să se regăsească toate fișierele și configurările introduse în F0.1: monorepo Nx + pnpm (package.json, pnpm-lock.yaml, pnpm-workspace.yaml, nx.json), TypeScript (tsconfig.base.json), ESLint (.eslintrc.json), Prettier (.prettierrc, .prettierignore), Husky (.husky/), lint-staged (.lintstagedrc.json), commitlint (commitlint.config.js), gitignore (.gitignore), README.md și orice alte fișiere de configurare/structură definite în F0.1. Fișierele temporare de test folosite pentru validarea hook-urilor NU trebuie să fie incluse. După verificarea stării repository-ului, toate fișierele relevante sunt adăugate în staging și se creează un singur commit cu un mesaj care respectă 'Conventional Commits' (de ex. 'chore(tooling): bootstrap F0.1 monorepo foundation').",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.1 – F0.1.49: Fundația de monorepo, tooling și documentație de bază a fost configurată. F0.1.50: Branch-ul 'dev' există și este activ.",
    "contextul_general_al_aplicatiei": "Închiderea fazei F0.1 prin materializarea într-un commit atomic pe branch-ul 'dev', care devine punctul de referință pentru review, PR/MR și fazele ulterioare (F0.2+).",
    "contextualizarea_directoarelor_si_cailor": "Toate comenzile Git se execută în directorul rădăcină al repository-ului: '/var/www/GeniusSuite/'. Commit-ul creat va exista local pe branch-ul 'dev'.",
    "restrictii_anti_halucinatie": [
      "Lucrează EXCLUSIV în '/var/www/GeniusSuite/'. Înainte de orice, rulează: `cd /var/www/GeniusSuite/`.",
      "Verifică că branch-ul curent este 'dev' înainte de a continua: `git branch --show-current` trebuie să returneze 'dev'. Dacă nu, fă `git checkout dev`.",
      "Asigură-te că toate fișierele temporare de test folosite în validări (de exemplu: 'lint-precommit-test.ts', 'test-format.ts', 'test-commitmsg.ts', 'test-commitmsg-success.ts' sau nume similare) AU FOST șterse și nu apar în 'git status'. Dacă apar, șterge-le și scoate-le din staging (git restore --staged + rm).",
      "Rulează `git status --short` și inspectează ieșirea. Verifică că modificările corespund DOAR fișierelor și directoarelor asociate fazei F0.1: 'package.json', 'pnpm-lock.yaml', 'pnpm-workspace.yaml', 'nx.json', 'tsconfig.base.json', '.eslintrc.json', '.prettierrc', '.prettierignore', '.lintstagedrc.json', 'commitlint.config.js', '.husky/**', '.gitignore', 'README.md', eventual alte fișiere de config/documentație menționate în plan.",
      "Nu adăuga în acest commit fișiere care țin de alte faze (F0.2+, aplicații CP, DMS, ERP etc.) sau fișiere temporare/compi late.",
      "Adaugă toate fișierele relevante în staging folosind `git add`:",
      "– Variante acceptate:",
      "  * `git add .` URMAT de o verificare atentă cu `git status` pentru a te asigura că nu intră fișiere nedorite.",
      "  * Sau, mai strict, `git add` pe fișiere/directoare individuale (ex.: `git add package.json pnpm-lock.yaml pnpm-workspace.yaml nx.json tsconfig.base.json .eslintrc.json .prettierrc .prettierignore .lintstagedrc.json commitlint.config.js .husky .gitignore README.md`).",
      "După `git add`, rulează `git status --short` și confirmă că toate fișierele staged sunt corecte și NU includ fișiere temporare sau artefacte de build (ex. 'node_modules', '.nx/cache', 'dist', etc.).",
      "Folosește un mesaj de commit care respectă STRICT 'Conventional Commits'. Recomandare pentru acest task:",
      "– `chore(tooling): bootstrap F0.1 monorepo foundation`",
      "Dar orice mesaj de forma '<type>(<scope>): <subject>' este acceptabil, cu 'type' din setul convențional (feat, fix, chore, refactor, docs, ci, build, etc.).",
      "Execută comanda de commit DOAR după ce hook-urile 'pre-commit' și 'commit-msg' sunt funcționale; nu folosi `--no-verify`. Exemplu:",
      "– `git commit -m \"chore(tooling): bootstrap F0.1 monorepo foundation\"`",
      "Dacă commit-ul eșuează din cauza linting-ului sau a mesajului, REPARĂ problemele și relansează commit-ul în același task, NU schimba strategia (nu folosi `--no-verify`).",
      "NU rula `git push` în acest task. Acest task se oprește la commit local pe 'dev'.",
      "NU modifica istoricul existent (nu folosi `git rebase`, `git reset --hard`, `git commit --amend`) în acest task. Este un commit nou, nu o rescriere de istoric."
    ],
    "restrictii_de_iesire_din_contex": "Nu face push către niciun remote (ex. 'origin') în acest task. Nu crea alte branch-uri și nu deschide PR/MR aici; acestea vor fi acoperite de task-uri separate.",
    "validare": "După commit, rulează `git log -1` și verifică: (1) că branch-ul curent este 'dev' (`git branch --show-current` == 'dev'), (2) că ultimul commit are mesajul de tip Conventional Commits ales (ex. 'chore(tooling): bootstrap F0.1 monorepo foundation'), și (3) că `git status` raportează un working tree curat ('nothing to commit, working tree clean').",
    "outcome": "Toate artefactele de fundație ale fazei F0.1 sunt comisionate local într-un singur commit coerent pe branch-ul 'dev', pregătit pentru review și pentru integrarea în fluxul de PR/MR.",
    "componenta_de_CI_CD": "N/A (acest task pregătește baza codului comisionat; integrarea cu CI/CD și pipeline-urile aferente vor fi tratate în fazele următoare)."
  }
},
```

##### F0.1.52

```JSON
  {
  "F0.1.52": {
    "denumire_task": "Migrare hook-uri Husky la format v9+ și commit + push pe 'dev'",
    "descriere_scurta_task": "Actualizarea fișierelor .husky/pre-commit și .husky/commit-msg la formatul fără husky.sh, apoi commit și push pe branch-ul 'dev'.",
    "descriere_lunga_si_detaliata_task": "Acest task rezolvă deprecările raportate de Husky și clarifică comportamentul lint-staged. În prezent, hook-urile .husky/pre-commit și .husky/commit-msg folosesc încă formatul vechi bazat pe scriptul _/husky.sh, ceea ce produce warning-uri de tipul 'husky - DEPRECATED ... They WILL FAIL in v10.0.0'. Conform recomandărilor Husky v9+, aceste hook-uri trebuie să conțină doar shebang-ul și comanda efectivă (pnpm exec lint-staged / pnpm exec commitlint --edit \"$1\") fără sourcing-ul husky.sh. În acest task rescriem ambele fișiere în formatul modern, verificăm că doar aceste fișiere sunt modificate, apoi creăm un commit nou pe branch-ul 'dev' cu un mesaj Conventional Commits descriptiv (de ex. 'chore(husky): migrate hooks to v9+ format') și facem push către origin/dev. Mesajul informativ de la lint-staged ('could not find any staged files matching configured tasks') este considerat comportament normal atunci când nu există fișiere .ts/.tsx/.js/.jsx în staged, astfel că nu modificăm configurația lint-staged.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/",
      "/var/www/GeniusSuite/.husky/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.36–F0.1.38: lint-staged și hook-ul 'pre-commit' au fost configurate. F0.1.39–F0.1.42: commitlint și hook-ul 'commit-msg' au fost configurate. F0.1.50–F0.1.52: branch-ul 'dev' a fost creat, comisionat și împins pe remote.",
    "contextul_general_al_aplicatiei": "Asigurarea că infrastructura de DevEx (Husky, lint-staged, commitlint) este compatibilă cu versiunile actuale și viitoare ale Husky (v9+ / v10), fără warning-uri de deprecări, și că branch-ul 'dev' rămâne sursa de adevăr pentru F0.1.",
    "contextualizarea_directoarelor_si_cailor": "Toate modificările se fac în '/var/www/GeniusSuite/.husky/pre-commit' și '/var/www/GeniusSuite/.husky/commit-msg'. Commit-ul și push-ul se execută din '/var/www/GeniusSuite/' pe branch-ul 'dev'.",
    "restrictii_anti_halucinatie": [
      "Lucrează EXCLUSIV în directorul '/var/www/GeniusSuite/'. Începe prin a rula: cd /var/www/GeniusSuite/",
      "Verifică branch-ul curent: git branch --show-current trebuie să returneze EXACT 'dev'. Dacă nu, execută git checkout dev și verifică din nou.",
      "Asigură-te că nu există modificări necomitate neintenționate înainte de a edita hook-urile. Rulează: git status --porcelain. Dacă apar fișiere în afară de .husky/* pe care nu dorești să le incluzi în acest commit, gestionează-le într-un task separat (commit/stash/reset) înainte de a continua.",
      "Deschide fișierul '.husky/pre-commit' și rescrie ÎNTREG conținutul lui astfel încât să fie EXACT:",
      "#!/usr/bin/env sh",
      "pnpm exec lint-staged",
      "Nu include nicio altă linie (NU . \"$(dirname -- \"$0\")/_/husky.sh\"). Asigură-te că nu există spații sau caractere ascunse suplimentare.",
      "Deschide fișierul '.husky/commit-msg' și rescrie ÎNTREG conținutul lui astfel încât să fie EXACT:",
      "#!/usr/bin/env sh",
      "pnpm exec commitlint --edit \"$1\"",
      "Din nou, NU include linia veche cu . \"$(dirname -- \"$0\")/_/husky.sh\" și nu adăuga alte comenzi.",
      "Asigură-te că ambele fișiere sunt executabile, conform cerințelor Husky: rulează comanda:",
      "chmod +x .husky/pre-commit .husky/commit-msg",
      "Nu modifica fișierele de configurare lint-staged ('.lintstagedrc.json') sau commitlint ('commitlint.config.js') în acest task. Mesajul lint-staged 'could not find any staged files matching configured tasks' este acceptat ca comportament normal când nu există fișiere .ts/.tsx/.js/.jsx în staging și nu necesită schimbări de configurare.",
      "După editarea fișierelor Husky, rulează din nou: git status --porcelain. Verifică faptul că DOAR '.husky/pre-commit' și '.husky/commit-msg' apar ca modificate. Dacă apar și alte fișiere, fie le revii (git restore), fie le tratezi în alt task – nu le include implicit în acest commit.",
      "Adaugă în staging DOAR cele două fișiere Husky:",
      "git add .husky/pre-commit .husky/commit-msg",
      "Verifică staging-ul: git status --short trebuie să arate exact liniile pentru M .husky/pre-commit și M .husky/commit-msg (sau similare).",
      "Creează un commit nou cu un mesaj valid Conventional Commits, descriptiv pentru această schimbare. De exemplu:",
      "git commit -m \"chore(husky): migrate hooks to v9+ style\"",
      "Nu folosi --no-verify; trebuie să permiți rularea hook-urilor 'pre-commit' și 'commit-msg' pentru a valida configurația.",
      "Este posibil ca la acest commit lint-staged să afișeze în continuare un mesaj informativ dacă nu există fișiere .ts/.tsx/.js/.jsx în staged. Acest mesaj NU este o eroare și nu trebuie tratat ca failure.",
      "După commit, verifică faptul că worktree-ul este curat: git status trebuie să arate 'nothing to commit, working tree clean'.",
      "Execută push pe branch-ul 'dev' către remote-ul 'origin'. Dacă upstream-ul este deja configurat, poți folosi:",
      "git push",
      "Dacă upstream-ul NU este configurat (de exemplu la primul push), folosește:",
      "git push -u origin dev",
      "Nu folosi în acest task comenzi destructive precum git push --force, git rebase sau git reset --hard."
    ],
    "restrictii_de_iesire_din_contex": "Nu modifica configurațiile lint-staged, ESLint, Prettier sau commitlint în acest task. Nu creea sau modifica alte branch-uri (ex. 'staging', 'master/main') și nu efectua merge între branch-uri. Rămâi strict la actualizarea hook-urilor Husky, commit și push pe 'dev'.",
    "validare": "Validarea este considerată reușită dacă: (1) conținutul fișierelor '.husky/pre-commit' și '.husky/commit-msg' este exact în formatul modern (fără linia cu 'husky.sh'), (2) un commit cu mesaj de forma 'chore(husky): migrate hooks to v9+ style' a fost creat cu succes pe branch-ul 'dev' și apare ca ultim commit în 'git log -1', (3) 'git status' este curat și (4) 'git ls-remote --heads origin dev' arată că branch-ul 'dev' a fost împins pe remote cu acest commit inclus.",
    "outcome": "Hook-urile Husky sunt aliniate cu formatul v9+ (compatibile cu v10), warning-urile de deprecări dispar, iar branch-ul 'dev' conține un commit clar care documentează migrarea hook-urilor și păstrează comportamentul lint-staged/commitlint conform planului F0.1.",
    "componenta_de_CI_CD": "La push-ul rezultat, pipeline-ul de CI configurat în F0.2 va rula pe branch-ul 'dev' cu hook-uri Husky modernizate și nu va fi afectat de deprecările legate de husky.sh. Linting-ul și format-check-ul continuă să fie declanșate prin scripturile 'pnpm lint' și 'pnpm format:check'."
  }
}
```

##### F0.1.53

```JSON
  {
  "F0.1.53": {
    "denumire_task": "Push Branch 'dev' și Creare PR/MR",
    "descriere_scurta_task": "Publicarea branch-ului 'dev' pe remote și pregătirea datelor pentru un PR/MR către branch-ul principal.",
    "descriere_lunga_si_detaliata_task": "Acest task finalizează Faza F0.1 prin publicarea branch-ului 'dev' pe remote-ul 'origin' și pregătirea metadatelor necesare pentru un Pull Request (PR) sau Merge Request (MR) de la 'dev' către branch-ul principal ('master' sau 'main', în funcție de repository). Push-ul va conține commit-ul/commit-urile în care au fost comisionate artefactele F0.1 (tooling monorepo, hook-uri, configurări). În plus, definim în câmpul 'PR_MR' titlul și descrierea structurate, astfel încât un agent AI sau un dezvoltator să le poată folosi direct pentru a deschide PR/MR în interfața platformei de hosting (GitHub, GitLab, etc.). Acest task NU execută merge și NU modifică istoricul branch-urilor principale.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.50: Branch-ul 'dev' a fost creat și activ. F0.1.51: Artefactele F0.1 au fost comisionate local pe branch-ul 'dev' cu un mesaj valid 'Conventional Commits'.",
    "contextul_general_al_aplicatiei": "Respectarea guvernanței Git cu 3 branch-uri (master, staging, dev) și finalizarea primei faze (F0.1) ca unitate de lucru revizuibilă prin PR/MR.",
    "contextualizarea_directoarelor_si_cailor": "Toate comenzile Git se execută în directorul rădăcină al repository-ului: '/var/www/GeniusSuite/'. PR/MR-ul va avea ca sursă branch-ul 'dev' și ca destinație branch-ul principal ('master' sau 'main').",
    "restrictii_anti_halucinatie": [
      "Lucrează EXCLUSIV în '/var/www/GeniusSuite/'. Rulează la început: 'cd /var/www/GeniusSuite/'.",
      "Verifică branch-ul curent înainte de push: 'git branch --show-current' trebuie să fie 'dev'. Dacă nu este, execută 'git checkout dev' și verifică din nou.",
      "Asigură-te că nu există modificări necomitate înainte de push: 'git status --porcelain' trebuie să fie gol. Dacă există modificări, acestea trebuie comisionate sau resetate într-un task separat, NU în acest task.",
      "Verifică existența remote-ului 'origin' cu 'git remote'. Dacă 'origin' NU există, NU încerca să creezi remote-uri noi și NU inventa URL-uri. Marchează task-ul ca blocat până când remote-ul este configurat manual.",
      "Determină branch-ul principal EXISTENT pe remote, fără a-l presupune:",
      "- Dacă 'git ls-remote --heads origin master' returnează un head, consideră 'master' ca branch principal.",
      "- Altfel, dacă 'git ls-remote --heads origin main' returnează un head, consideră 'main' ca branch principal.",
      "- Dacă nici 'master' nici 'main' nu există pe remote, marchează task-ul ca blocat. Nu inventa branch principal.",
      "Pentru push-ul inițial al branch-ului 'dev', folosește:",
      "- 'git push -u origin dev'",
      "Dacă branch-ul 'dev' există deja pe remote și push-ul eșuează din cauza divergențelor, NU folosi 'git push --force' sau rebase în acest task. Aceasta necesită un task clar separat de rezolvare a conflictelor.",
      "După push, NU executa 'git merge', 'git rebase' sau alte operații care schimbă istoricul branch-ului principal. Acest task se oprește la publicarea branch-ului 'dev' și pregătirea metadatelor pentru PR/MR.",
      "NU încerca să creezi PR/MR prin API-uri sau comenzi CLI externe în acest task. Scopul este să furnizezi datele ('titlu', 'descriere', 'sursa_branch', 'destinatie_branch') pentru a fi folosite manual sau de un agent AI într-un context separat.",
      "Nu modifica conținutul commit-urilor deja create în F0.1.51 (nu folosi 'git commit --amend', 'git rebase', 'git reset --hard')."
    ],
    "restrictii_de_iesire_din_contex": "Nu executa merge între 'dev' și branch-ul principal. Nu crea în acest task branch-ul 'staging' și nu modifică politica de branch-uri. Rămâi strict în contextul push-ului pentru 'dev' și a pregătirii datelor pentru PR/MR.",
    "validare": "După 'git push -u origin dev', verifică: (1) 'git branch --show-current' returnează 'dev', (2) 'git status' arată 'nothing to commit, working tree clean', (3) 'git ls-remote --heads origin dev' returnează un head (branch-ul 'dev' există pe remote).",
    "outcome": "Branch-ul 'dev' care conține artefactele F0.1 este publicat pe remote-ul 'origin' și există date clare pentru deschiderea unui PR/MR către branch-ul principal.",
    "componenta_de_CI_CD": "Primul push al branch-ului 'dev' va declanșa pipeline-ul CI configurat în F0.2 (de exemplu rularea 'pnpm install', 'pnpm lint', 'pnpm format:check'), permițând verificarea automată a fundației monorepo-ului.",
    "PR_MR": {
      "sursa_branch": "dev",
      "destinatie_branch": "master",
      "titlu": "feat(platform): F0.1 - Inițializare Fundație Monorepo și Tooling",
      "descriere": "Acest PR stabilește fundația completă a monorepo-ului GeniusSuite (Faza F0.1), conform planului de arhitectură.\n\n**Schimbări cheie**\n\n1. Manager de pachete și monorepo\n- Configurat managerul de pachete pnpm și fișierul pnpm-workspace.yaml pentru a reflecta structura generală a aplicațiilor și bibliotecilor (cp/*, shared/*, vettify.app etc.).\n- Inițializat Nx și configurat nx.json pentru a lucra împreună cu pnpm workspaces, cu targetDefaults pentru caching-ul task-urilor standard (build, lint, test).\n\n2. TypeScript\n- Adăugat tsconfig.base.json ca sursă unică de adevăr pentru configurarea TypeScript în monorepo.\n- Activat Strict TS (strict: true, noUncheckedIndexedAccess, exactOptionalPropertyTypes și alte opțiuni stricte).\n- Configurat compilerOptions moderne pentru Node 24 și React (ESNext, jsx: react-jsx).\n- Definite alias-uri paths pentru bibliotecile shared/* (ex. @genius-suite/ui-design-system, @genius-suite/types, @genius-suite/common etc.).\n\n3. Standarde de cod (ESLint + Prettier)\n- Instalate și configurate Prettier (.prettierrc, .prettierignore) ca formatter principal.\n- Instalate și configurate ESLint și integrarea cu TypeScript (@typescript-eslint/parser, @typescript-eslint/eslint-plugin).\n- Integrat pluginul Nx (@nx/eslint-plugin) și activată regula de bază pentru module boundaries.\n- Configurat .eslintrc.json de rădăcină cu overrides pentru fișiere TS/JS și integrare completă cu Prettier (plugin:prettier/recommended).\n\n4. Cârlige Git și verificări locale\n- Instalate Husky v9, lint-staged și commitlint.\n- Hook pre-commit: rulează lint-staged, care execută nx format:write --files și nx affected:lint --fix --files pe fișierele staged.\n- Hook commit-msg: rulează commitlint cu presetul @commitlint/config-conventional pentru a impune Conventional Commits.\n- Configurațiile au fost validate prin task-urile F0.1.45–F0.1.48 (teste deliberate de eșec și succes pentru pre-commit și commit-msg).\n\n5. Scripturi și documentație\n- Adăugate scripturi standardizate în package.json: pnpm lint (nx run-many -t lint --all), pnpm lint:fix, pnpm format:check (nx format:check), pnpm format:write (nx format:write).\n- Creat README.md de rădăcină cu descrierea stack-ului și comenzile de bază (pnpm install, pnpm lint, pnpm format:check, pnpm format:write).\n\n**Motivație**\n\nAcest PR pregătește un fundament solid pentru dezvoltarea ulterioară (Control Plane, ERP, DMS, aplicații stand-alone), asigurând un DevEx coerent (tooling unificat, standarde stricte de cod, hook-uri Git și Conventional Commits) și un monorepo Nx pregătit pentru fazele F0.2+ (CI/CD, release, module noi)."
    }
  }
}
```

#### F0.2 CI/CD: pipeline build/test/lint, release semantice, versionare pachete, container registry

#### F0.2.1

```JSON
{
  "F0.2.1": {
    "denumire_task": "Creare Director Workflows GitHub Actions",
    "descriere_scurta_task": "Crearea ierarhiei '.github/workflows' la rădăcina monorepo-ului.",
    "descriere_lunga_si_detaliata_task": "Acest task stabilește locația standard pentru fișierele de pipeline GitHub Actions. La rădăcina monorepo-ului GeniusSuite vom crea ierarhia de directoare '.github/workflows/'. Nu adăugăm încă niciun fișier de workflow; doar pregătim structura necesară pentru următoarele taskuri din Faza F0.2 (CI/CD).",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1: Fundația monorepo (tooling, Nx, pnpm, hook-uri Git) este completă și comisionată pe branch-ul 'dev'. F0.1.52: Branch-ul 'dev' este deja push-uit și pregătit pentru integrarea cu CI.",
    "contextul_general_al_aplicatiei": "Inițierea Fazei F0.2 (CI/CD) prin crearea infrastructurii de directoare unde vor fi definite workflow-urile GitHub Actions.",
    "contextualizarea_directoarelor_si_cailor": "În directorul rădăcină al repository-ului ('/var/www/GeniusSuite/'), trebuie creată structura '.github/workflows/'. Se poate folosi comanda: mkdir -p .github/workflows",
    "restrictii_anti_halucinatie": [
      "Nu crea alte directoare decât '.github' și '.github/workflows' la rădăcina '/var/www/GeniusSuite/'.",
      "Nu crea niciun fișier YAML de workflow în acest task (de ex. 'ci.yml', 'pipeline.yml'). Acestea vor fi adăugate în taskurile următoare din Faza F0.2.",
      "Nu modifica niciun alt fișier existent (package.json, nx.json, tsconfig.base.json, etc.).",
      "Nu executa comenzi Git (add/commit/push) în cadrul acestui task; aici ne ocupăm strict de structura de directoare.",
      "Asigură-te că lucrezi în '/var/www/GeniusSuite/' și nu la rădăcina sistemului de fișiere ('/')."
    ],
    "restrictii_de_iesire_din_contex": "Rămâi strict la crearea ierarhiei '.github/workflows'. Nu configura conținutul workflow-urilor și nu definește încă pași de CI/CD.",
    "validare": "Verifică existența directorului '/var/www/GeniusSuite/.github/workflows' prin comanda 'test -d .github/workflows' sau listarea sa cu 'ls -ld .github/workflows'.",
    "outcome": "Directorul standard pentru stocarea fișierelor de workflow GitHub Actions este creat la rădăcina monorepo-ului.",
    "componenta_de_CI_CD": "Acesta este directorul standard în care vor fi plasate workflow-urile GitHub Actions (de ex. pipeline-ul principal de CI pentru branch-urile 'dev', 'staging' și 'master')."
  }
},
```

#### F0.2.2

```JSON
  {
  "F0.2.2": {
    "denumire_task": "Creare Fișier Workflow CI Principal ('ci.yml')",
    "descriere_scurta_task": "Creează fișierul 'ci.yml' pentru validarea Pull Request-urilor.",
    "descriere_lunga_si_detaliata_task": "Creăm fișierul principal de workflow, 'ci.yml', în care vor fi definite ulterior triggerele (F0.2.3) și job-ul 'validate' (F0.2.4+). În această fază, scopul este doar crearea fișierului și, opțional, adăugarea unui comentariu de header, fără niciun conținut funcțional (fără 'name', 'on', 'jobs'), pentru a evita introducerea de logică de CI înaintea task-urilor dedicate.",
    "directorul_directoarele": [
      ".github/workflows/"
    ],
    "contextul_taskurilor_anterioare": "F0.2.1: Directorul '.github/workflows/' a fost creat.",
    "contextul_general_al_aplicatiei": "Faza F0.2 automatizează validările definite în F0.1 (lint, format, test, build) prin GitHub Actions. Fișierul 'ci.yml' va deveni pipeline-ul principal de validare pentru PR-uri către 'dev', 'staging' și 'master', dar logica efectivă este introdusă în task-urile următoare.",
    "contextualizarea_directoarelor_si_cailor": "Lucrezi în rădăcina monorepo-ului '/var/www/GeniusSuite'. Creează fișierul YAML '.github/workflows/ci.yml' (cale completă: '/var/www/GeniusSuite/.github/workflows/ci.yml'). Dacă directorul '.github/workflows/' nu există, acesta ar fi trebuit deja creat în F0.2.1.",
    "restrictii_anti_halucinatie": [
      "Nu adăuga în acest task secțiuni YAML funcționale precum 'on:', 'jobs:' sau 'name:'. Acestea vor fi configurate explicit în task-urile F0.2.3, F0.2.4 și următoarele.",
      "Nu crea alte fișiere de workflow (de ex. 'release.yml', 'deploy-staging.yml', 'deploy-prod.yml') în cadrul acestui task.",
      "Conținutul maxim permis acum este un comentariu YAML de header, de exemplu: '# CI workflow principal pentru GeniusSuite – configurat în F0.2.3+'. Nu inventa pași, job-uri sau triggere.",
      "Nu modifica alte fișiere din '.github/workflows/' (dacă există deja). Acest task lucrează exclusiv cu 'ci.yml'."
    ],
    "restrictii_de_iesire_din_contex": "Nu implementa logică de CI (triggers, job-uri, pași) în acest task. Doar creează fișierul 'ci.yml' și, opțional, un singur comentariu de header.",
    "validare": "Există fișierul '/var/www/GeniusSuite/.github/workflows/ci.yml'. Conținutul său este fie gol, fie conține doar un comentariu YAML de header, fără chei 'on', 'jobs' sau 'name'.",
    "outcome": "Fișierul principal de workflow 'ci.yml' este creat și pregătit pentru a fi completat în task-urile următoare (declanșatoare, job 'validate', pași Nx).",
    "componenta_de_CI_CD": "Acest fișier va deveni pipeline-ul principal de CI pentru PR-uri către 'dev', 'staging' și 'master', dar în această fază reprezintă doar scheletul (containerul) în care vor fi definite ulterior toate validările automate."
  }
},
```

#### F0.2.3

```JSON
  {
  "F0.2.3": {
    "denumire_task": "Definire Declanșatoare (Triggers) pentru 'ci.yml'",
    "descriere_scurta_task": "Configurează 'ci.yml' să ruleze pe Pull Request-uri către 'master', 'staging' și 'dev'.",
    "descriere_lunga_si_detaliata_task": "În acest task, configurăm evenimentele GitHub Actions care declanșează workflow-ul de CI definit în 'ci.yml'. Conform strategiei de branching (3 branch-uri: master, staging, dev), pipeline-ul principal de CI trebuie să ruleze automat pentru orice Pull Request deschis către una dintre aceste ramuri. Nu adăugăm încă job-uri sau pași de execuție (lint, test, build); ne concentrăm exclusiv pe secțiunea YAML 'on:' și configurarea evenimentului 'pull_request' cu lista de branch-uri țintă.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/.github/workflows/"
    ],
    "contextul_taskurilor_anterioare": "F0.2.1: Directorul '.github/workflows/' a fost creat. F0.2.2: Fișierul '.github/workflows/ci.yml' există (eventual cu un comentariu de header, fără cheile 'on' sau 'jobs').",
    "contextul_general_al_aplicatiei": "Alinierea pipeline-ului de CI la guvernanța Git cu 3 branch-uri (master, staging, dev), astfel încât fiecare Pull Request către aceste branch-uri să declanșeze automat validările definite în F0.1 (lint, format, test, build) care vor fi configurate în task-urile F0.2.4+.",
    "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/.github/workflows/ci.yml'. Acesta trebuie să conțină, pe lângă eventualul comentariu de header existent, o secțiune YAML validă 'on:' care definește evenimentul 'pull_request' pentru branch-urile 'master', 'staging' și 'dev'.",
    "restrictii_anti_halucinatie": [
      "Lucrează EXCLUSIV pe fișierul '/var/www/GeniusSuite/.github/workflows/ci.yml'. Nu crea și nu modifica alte fișiere de workflow în acest task.",
      "Păstrează eventualul comentariu de header existent (de la F0.2.2), dacă există. Adaugă noua secțiune YAML imediat sub acel comentariu.",
      "Adaugă SECȚIUNEA 'on' EXACT cu structura de mai jos (indentare cu două spații pentru nivelurile imbricate):",
      "on:",
      "  pull_request:",
      "    branches:",
      "      - master",
      "      - staging",
      "      - dev",
      "Nu adăuga alte evenimente ('push', 'workflow_dispatch', 'pull_request_target', etc.) în acest task. Acest workflow trebuie să se declanșeze DOAR pe 'pull_request' către branch-urile specificate.",
      "Nu adăuga în acest moment chei YAML precum 'name:' sau 'jobs:'. Acestea vor fi configurate în task-uri ulterioare (de ex. definirea job-ului 'validate', pașii de Nx, etc.).",
      "Asigură-te că fișierul final 'ci.yml' este YAML valid (ex. nu există tab-uri, doar spații, nu există caractere ascunse înainte de 'on:').",
      "Nu schimba numele branch-ului 'master' în 'main' automat. Planul de guvernanță specifică explcit 'master'. Dacă repository-ul real folosește 'main', acest lucru trebuie tratat într-un task separat, nu prin presupuneri aici."
    ],
    "restrictii_de_iesire_din_contex": "Nu implementa în acest task job-uri, pași, strategii de matrici sau pași Nx (`nx affected:lint`, `nx test`, etc.). Rămâi strict la definirea declanșatoarelor (secțiunea 'on:').",
    "validare": "Fișierul '/var/www/GeniusSuite/.github/workflows/ci.yml' conține o secțiune YAML validă 'on' cu 'pull_request.branches' setat exact la ['master', 'staging', 'dev'], fără alte evenimente suplimentare. Validarea minimă se poate face vizual sau cu un validator YAML.",
    "outcome": "'ci.yml' este configurat astfel încât workflow-ul de CI să fie declanșat automat pentru orice Pull Request deschis către branch-urile 'master', 'staging' și 'dev', aliniat cu strategia de guvernanță Git.",
    "componenta_de_CI_CD": "Acest task definește MOMENTUL în care va rula pipeline-ul de CI: la fiecare Pull Request către branch-urile protejate. Logica efectivă de validare (job-uri și pași) va fi adăugată în task-urile următoare ale Fazei F0.2."
  }
},
```

#### F0.2.4

```JSON
  {
  "F0.2.4": {
    "denumire_task": "Definire Job 'validate' în 'ci.yml'",
    "descriere_scurta_task": "Adaugă structura de bază pentru job-ul 'validate' în 'ci.yml', cu runner și pasul de checkout.",
    "descriere_lunga_si_detaliata_task": "În acest task definim primul și principalul job al workflow-ului de CI: 'validate'. Job-ul va rula pe un runner GitHub Actions 'ubuntu-latest' și va conține, pentru moment, doar pasul de checkout al repository-ului folosind 'actions/checkout@v4'. Pașii suplimentari (instalare pnpm, cache, lint, test, build) vor fi adăugați în task-uri ulterioare din Faza F0.2. Scopul acestui task este să introducă secțiunea 'jobs:' și job-ul 'validate' cu o structură minimală, dar validă, fără a implementa încă logica completă de CI.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/.github/workflows/"
    ],
    "contextul_taskurilor_anterioare": "F0.2.1: A fost creat directorul '.github/workflows/'. F0.2.2: A fost creat fișierul 'ci.yml'. F0.2.3: În 'ci.yml' au fost definite declanșatoarele 'on: pull_request' pentru branch-urile 'master', 'staging' și 'dev'.",
    "contextul_general_al_aplicatiei": "Structurarea pipeline-ului de CI: introducem job-ul 'validate', care va deveni punctul central pentru toate verificările de calitate (lint, test, build) ale monorepo-ului GeniusSuite pe Pull Request-uri către branch-urile protejate.",
    "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/.github/workflows/ci.yml'. Acesta conține deja secțiunea 'on:' configurată în F0.2.3. Sub acea secțiune, trebuie adăugată o secțiune YAML 'jobs:' care definește job-ul 'validate' cu runner 'ubuntu-latest' și un singur pas: checkout-ul repository-ului.",
    "restrictii_anti_halucinatie": [
      "Lucrează EXCLUSIV pe fișierul '/var/www/GeniusSuite/.github/workflows/ci.yml'. Nu crea sau modifica alte fișiere workflow în acest task.",
      "Păstrează intactă secțiunea 'on:' definită în F0.2.3 (pull_request către 'master', 'staging', 'dev'). Nu o altera, nu adăuga alte evenimente.",
      "Dacă fișierul conține doar un comentariu de header și secțiunea 'on:', adaugă sub acestea secțiunea 'jobs:' cu următoarea structură minimală (folosind spații, nu tab-uri):",
      "jobs:",
      "  validate:",
      "    runs-on: ubuntu-latest",
      "    steps:",
      "      - name: Checkout repository",
      "        uses: actions/checkout@v4",
      "Asigură-te că indentarea este corectă: 'jobs' la nivel de rădăcină YAML (fără spații înainte), 'validate' la două spații, 'runs-on' și 'steps' la patru spații, iar elementele din 'steps' la șase/opt spații conform exemplului.",
      "Nu adăuga alți pași în acest moment (nu defini încă instalarea pnpm, cache, nx, pnpm lint/test/build, etc.). Singurul pas permis acum este 'actions/checkout@v4'.",
      "Nu adăuga alte job-uri (de ex. 'release', 'test-only', 'deploy'). Acest task definește STRICT job-ul 'validate'.",
      "Nu modifica numele job-ului ('validate') și nu schimba runner-ul ('ubuntu-latest') în acest task.",
      "Asigură-te că fișierul final rămâne un YAML valid: nu duplica cheile 'jobs:'; dacă există deja o cheie 'jobs' introdusă accidental, aceasta trebuie înlocuită astfel încât să conțină EXACT job-ul 'validate' descris aici (fără alte job-uri inventate)."
    ],
    "restrictii_de_iesire_din_contex": "Nu adăuga alți pași (steps) în afară de 'actions/checkout@v4' și nu introduce logică suplimentară (env, strategy, matrix, timeout). Nu seta nume de workflow ('name:') sau alte metadate în acest task.",
    "validare": "Fișierul '/var/www/GeniusSuite/.github/workflows/ci.yml' conține, pe lângă secțiunea 'on:' definită în F0.2.3, o secțiune 'jobs' cu job-ul 'validate' configurat astfel: 'runs-on: ubuntu-latest' și un singur pas 'Checkout repository' care folosește 'actions/checkout@v4'. Fișierul trece validarea YAML.",
    "outcome": "Structura de bază a job-ului 'validate' este creată în 'ci.yml': workflow-ul are acum un job principal care rulează pe 'ubuntu-latest' și face checkout al codului din repository, fiind pregătit pentru a primi pași suplimentari (pnpm install, Nx lint/test/build) în task-urile următoare.",
    "componenta_de_CI_CD": "Reprezintă scheletul job-ului principal de CI. Toate verificările automate (lint, test, build) vor fi atașate ulterior acestui job 'validate', păstrând un singur punct de intrare CI pentru PR-urile către 'master', 'staging' și 'dev'."
  }
},
```

#### F0.2.5

```JSON
  {
  "F0.2.5": {
    "denumire_task": "Adăugare setup Node + pnpm + cache în job-ul 'validate'",
    "descriere_scurta_task": "Adaugă în 'ci.yml' pașii pentru instalarea Node.js, configurarea pnpm și cache-ul pnpm store.",
    "descriere_lunga_si_detaliata_task": "În acest task extindem job-ul 'validate' din 'ci.yml' pentru a pregăti mediul de rulare: instalăm versiunea corectă de Node.js (conform stack-ului cu Node 24 LTS), configurăm pnpm folosind acțiunea oficială pnpm/action-setup și adăugăm un pas de cache pentru '~/.pnpm-store' cu actions/cache@v4 bazat pe hash-ul fișierului 'pnpm-lock.yaml'. În acest moment NU rulăm încă 'pnpm install' sau alte comenzi Nx; doar pregătim mediul și cache-ul pentru task-urile următoare.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/.github/workflows/"
    ],
    "contextul_taskurilor_anterioare": "F0.2.4: Job-ul 'validate' a fost creat în 'ci.yml' cu pasul de checkout (actions/checkout@v4). F0.1: monorepo-ul este configurat să folosească pnpm ca manager de pachete și Node 24 LTS ca runtime.",
    "contextul_general_al_aplicatiei": "Configurarea mediului de CI pentru a utiliza Node.js 24 LTS și pnpm cu cache, conform stack-ului definit în F0.1, pentru instalări rapide și consistente ale dependențelor.",
    "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/.github/workflows/ci.yml', în secțiunea 'jobs.validate.steps'. Adaugă pașii după pasul existent 'Checkout repository' (actions/checkout@v4).",
    "restrictii_anti_halucinatie": [
      "Lucrează EXCLUSIV pe fișierul '/var/www/GeniusSuite/.github/workflows/ci.yml'. Nu crea sau modifica alte workflow-uri în acest task.",
      "Păstrează pasul existent de checkout:",
      "- name: Checkout repository",
      "  uses: actions/checkout@v4",
      "Nu îl șterge și nu îl modifică.",
      "Imediat DUPĂ pasul de checkout, adaugă ÎN ACEASTĂ ORDINE următorii pași YAML (cu indentare corectă în cadrul 'steps'):",
      "1) Setup Node.js (versiunea 24.x):",
      "- name: Setup Node.js",
      "  uses: actions/setup-node@v4",
      "  with:",
      "    node-version: 24.x",
      "    check-latest: true",
      "Nu alege alte versiuni (ex. 18.x, 20.x) – respectă stack-ul cu Node 24 LTS.",
      "2) Setup pnpm:",
      "- name: Setup pnpm",
      "  uses: pnpm/action-setup@v2",
      "  with:",
      "    version: 8",
      "Nu inventa altă versiune pnpm; folosește explicit 'version: 8' (conform stack-ului pnpm 8.x).",
      "3) Setup pnpm cache:",
      "- name: Setup pnpm cache",
      "  uses: actions/cache@v4",
      "  with:",
      "    path: ~/.pnpm-store",
      "    key: ${{ runner.os }}-pnpm-store-${{ hashFiles('**/pnpm-lock.yaml') }}",
      "    restore-keys: |",
      "      ${{ runner.os }}-pnpm-store-",
      "Nu modifica 'path' în altceva; pnpm store implicit este '~/.pnpm-store'.",
      "Nu adăuga ÎNCĂ pasul de instalare a dependențelor (ex. 'pnpm install') sau comenzi Nx (ex. 'nx affected:lint'). Acelea vor fi introduse într-un task separat.",
      "Asigură-te că toți pașii noi sunt în cadrul aceluiași job 'validate', în array-ul 'steps', și că YAML-ul rămâne valid (nu folosi tab-uri, doar spații).",
      "Nu adăuga variabile de mediu suplimentare sau alte câmpuri (env, if, timeout-minutes) în acest task.",
      "Nu schimba numele job-ului ('validate') și nici runner-ul ('runs-on: ubuntu-latest')."
    ],
    "restrictii_de_iesire_din_contex": "Rămâi strict la adăugarea pașilor 'Setup Node.js', 'Setup pnpm' și 'Setup pnpm cache' în job-ul 'validate'. Nu introduce pași pentru 'pnpm install', 'pnpm lint', 'pnpm test' sau Nx în acest task.",
    "validare": "Fișierul '/var/www/GeniusSuite/.github/workflows/ci.yml' conține în 'jobs.validate.steps' (în ordine) pasul de checkout, urmat de cei trei pași: 'Setup Node.js' (actions/setup-node@v4 cu node-version: 24.x), 'Setup pnpm' (pnpm/action-setup@v2 cu version: 8) și 'Setup pnpm cache' (actions/cache@v4 cu path: ~/.pnpm-store și key bazat pe hashFiles('**/pnpm-lock.yaml')). YAML-ul este valid.",
    "outcome": "Agentul de CI este pregătit pentru rularea comenzilor pnpm în job-ul 'validate', cu Node.js 24.x instalat și cu pnpm store cache-uit pentru performanță.",
    "componenta_de_CI_CD": "Acest task asigură mediul și cache-ul necesare pentru instalarea rapidă a dependențelor și rularea ulterioară a pașilor Nx (lint, test, build) în pipeline-ul de CI."
  }
},
```

#### F0.2.6

```JSON
  {
  "F0.2.6": {
    "denumire_task": "Adăugare Pas 'pnpm install' în Job-ul 'validate'",
    "descriere_scurta_task": "Adaugă pasul de instalare a dependențelor cu 'pnpm install --frozen-lockfile' în job-ul 'validate' din 'ci.yml'.",
    "descriere_lunga_si_detaliata_task": "După ce job-ul 'validate' a fost configurat cu checkout, setup Node.js, setup pnpm și cache pentru '~/.pnpm-store', acest task adaugă pasul de instalare a dependențelor monorepo-ului. Folosim comanda 'pnpm install --frozen-lockfile' rulată din directorul rădăcină al proiectului. Opțiunea '--frozen-lockfile' este critică în CI: ea impune ca 'pnpm-lock.yaml' să fie sursa unică de adevăr pentru versiuni, iar pipeline-ul să eșueze dacă lockfile-ul și 'package.json' nu sunt sincronizate. Astfel prevenim instalările nedeterministe sau schimbările de dependențe necomisionate.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/.github/workflows/"
    ],
    "contextul_taskurilor_anterioare": "F0.2.4: job-ul 'validate' a fost definit cu pasul de checkout. F0.2.5: au fost adăugați pașii 'Setup Node.js', 'Setup pnpm' și 'Setup pnpm cache' în 'jobs.validate.steps'.",
    "contextul_general_al_aplicatiei": "Asigurarea unei instalări deterministe a dependențelor în mediul de CI pentru întregul monorepo GeniusSuite, ca precondiție pentru rularea lint-ului, testelor și build-urilor Nx.",
    "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/.github/workflows/ci.yml'. În job-ul 'validate', în lista 'steps', adaugă un nou pas imediat DUPĂ pasul 'Setup pnpm cache'. Comanda 'pnpm install --frozen-lockfile' va fi executată implicit în directorul de lucru al runner-ului, care este rădăcina repository-ului (echivalent cu '/var/www/GeniusSuite/').",
    "restrictii_anti_halucinatie": [
      "Lucrează EXCLUSIV pe fișierul '/var/www/GeniusSuite/.github/workflows/ci.yml'. Nu crea și nu modifica alte workflow-uri în acest task.",
      "Nu modifica pașii existenți 'Checkout repository', 'Setup Node.js', 'Setup pnpm' sau 'Setup pnpm cache'. Aceștia trebuie păstrați exact așa cum au fost definiți în F0.2.4 și F0.2.5.",
      "În secțiunea 'jobs.validate.steps', adaugă UN NOU pas imediat după 'Setup pnpm cache' cu următoarea structură YAML (respectă indentarea și numele):",
      "- name: Install dependencies",
      "  run: pnpm install --frozen-lockfile",
      "Nu folosi alt nume de pas (ex. 'pnpm install deps') și nu schimba comanda în 'npm install' sau 'yarn install'.",
      "Nu elimina opțiunea '--frozen-lockfile' și nu o înlocui cu alte flag-uri (ex. '--no-frozen-lockfile' sau '--force'). Această opțiune este esențială pentru determinismul instalării în CI.",
      "Nu adăuga în acest pas variabile de mediu suplimentare (env), condiții (if) sau alte câmpuri. Pasul trebuie să fie strict un 'run: pnpm install --frozen-lockfile'.",
      "Nu introduce alte comenzi de instalare (ex. un al doilea pas 'pnpm install' sau 'pnpm install --prod'). Instalarea completă se face O SINGURĂ DATĂ în acest pas.",
      "Asigură-te că nu există dubluri de pași 'Install dependencies' sau alte instanțe de 'pnpm install' în 'steps'. Dacă există astfel de pași creați anterior, elimină-i în favoarea acestui pas standardizat.",
      "Nu modifica numele job-ului ('validate') și nici runner-ul ('runs-on: ubuntu-latest') în acest task.",
      "Verifică la final ca YAML-ul să fie valid (fără tab-uri, doar spații, fără caractere ascunse) și ca secvența logică a pașilor să fie: Checkout → Setup Node → Setup pnpm → Setup pnpm cache → Install dependencies."
    ],
    "restrictii_de_iesire_din_contex": "Nu adăuga în acest task pași care rulează lint, test sau build (ex. 'pnpm lint', 'pnpm test', 'nx affected:lint', 'nx affected:test', 'nx affected:build'). Task-urile pentru aceste acțiuni vor fi definite ulterior.",
    "validare": "Fișierul '/var/www/GeniusSuite/.github/workflows/ci.yml' conține, în 'jobs.validate.steps', un pas numit exact 'Install dependencies' cu 'run: pnpm install --frozen-lockfile', plasat după 'Setup pnpm cache'. Nu există alte comenzi 'pnpm install' în workflow.",
    "outcome": "Pipeline-ul de CI instalează determinist toate dependențele monorepo-ului folosind 'pnpm install --frozen-lockfile', pregătind mediul pentru pașii de lint, test și build.",
    "componenta_de_CI_CD": "Reprezintă pasul de instalare a dependențelor, obligatoriu înainte de orice task de lint, test sau build rulat în job-ul 'validate'."
  }
},
```

#### F0.2.7

```JSON
  {
  "F0.2.7": {
    "denumire_task": "Adăugare pas 'Set Nx SHAs' + validare pas 'Install dependencies' în job-ul 'validate'",
    "descriere_scurta_task": "Adaugă acțiunea 'nrwl/nx-set-shas@v4' după 'pnpm install --frozen-lockfile' și verifică/completează pasul de instalare a dependențelor în 'ci.yml'.",
    "descriere_lunga_si_detaliata_task": "Acest task finalizează pregătirea job-ului 'validate' pentru rularea corectă a comenzilor 'nx affected' în CI. În primul rând, confirmă că în job-ul 'validate' există pasul de instalare a dependențelor cu 'pnpm install --frozen-lockfile' (F0.2.6) și, dacă lipsește sau este greșit, îl creează/înlocuiește cu varianta corectă. Apoi adaugă un nou pas 'Set Nx SHAs' care folosește acțiunea 'nrwl/nx-set-shas@v4'. Această acțiune calculează SHA-ul de bază (commit-ul de bază al PR-ului) și SHA-ul de capăt și setează variabilele de mediu 'NX_BASE' și 'NX_HEAD', pe care 'nx affected' le folosește automat. Pentru ca acest pas să funcționeze corect, se presupune că acțiunea 'actions/checkout@v4' este configurată cu 'fetch-depth: 0' (pentru a avea istoricul Git complet).",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/.github/workflows/"
    ],
    "contextul_taskurilor_anterioare": "F0.2.4: Job-ul 'validate' a fost creat cu pasul de checkout. F0.2.5: Au fost adăugați pașii 'Setup Node.js', 'Setup pnpm' și 'Setup pnpm cache'. F0.2.6: A fost planificat pasul de instalare a dependențelor cu 'pnpm install --frozen-lockfile' (dar în task-ul original lipsea blocul YAML concret).",
    "contextul_general_al_aplicatiei": "Pipeline-ul de CI trebuie să ruleze rapid și corect doar proiectele afectate într-un PR folosind 'nx affected'. Pentru asta sunt esențiale atât instalarea deterministă a dependențelor (pnpm + lockfile), cât și calculul corect al SHA-urilor NX_BASE/NX_HEAD prin 'nrwl/nx-set-shas@v4'.",
    "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/.github/workflows/ci.yml', în secțiunea 'jobs.validate.steps'. Lucrezi pe workflow-ul principal de CI definit pentru Pull Request-uri către 'master', 'staging' și 'dev'.",
    "restrictii_anti_halucinatie": [
      "Lucrează EXCLUSIV pe fișierul '/var/www/GeniusSuite/.github/workflows/ci.yml'. Nu crea și nu modifica alte workflow-uri în acest task.",
      "Păstrează secțiunea 'on:' definită în F0.2.3 (pull_request către 'master', 'staging', 'dev') EXACT așa cum este. Nu adăuga 'push' sau alte triggere în acest task.",
      "În secțiunea 'jobs.validate', verifică faptul că pasul de checkout arată astfel (sau echivalent semantic) și, dacă nu, actualizează-l ACUM pentru a avea fetch-depth: 0 (necesar pentru 'nrwl/nx-set-shas'):",
      "- name: Checkout repository",
      "  uses: actions/checkout@v4",
      "  with:",
      "    fetch-depth: 0",
      "Nu elimina acest pas și nu schimba numele job-ului ('validate') sau runner-ul ('runs-on: ubuntu-latest').",
      "În interiorul 'jobs.validate.steps', asigură-te că există pașii de setup din F0.2.5, în această ordine logică: 'Checkout repository' → 'Setup Node.js' → 'Setup pnpm' → 'Setup pnpm cache'. Nu îi modifica în acest task.",
      "VALIDARE/COMPLETARE F0.2.6 (Install dependencies):",
      "Verifică dacă există deja un pas cu numele 'Install dependencies'. Dacă lipsește sau dacă execută altceva decât 'pnpm install --frozen-lockfile', rescrie/creează pasul astfel, imediat DUPĂ 'Setup pnpm cache':",
      "- name: Install dependencies",
      "  run: pnpm install --frozen-lockfile",
      "Nu folosi comanda 'pnpm install' fără '--frozen-lockfile' și nu o înlocui cu alte manager-e (npm, yarn).",
      "Asigură-te că NU există alte instanțe de 'pnpm install' în workflow. Trebuie să existe un singur pas de instalare a dependențelor, acesta.",
      "ADĂUGARE PAS F0.2.7 – Set Nx SHAs:",
      "Imediat DUPĂ pasul 'Install dependencies', adaugă un nou pas în 'jobs.validate.steps' cu următorul conținut YAML EXACT:",
      "- name: Set Nx SHAs",
      "  uses: nrwl/nx-set-shas@v4",
      "Nu adăuga câmpuri suplimentare (with:, env:, if:) la acest pas în acest task. Configurația implicita a acțiunii este suficientă pentru PR-uri.",
      "Nu muta acest pas înainte de instalarea dependențelor și nu îl plasa după eventuale pași viitori de lint/test/build. Ordinea corectă este: checkout → setup Node → setup pnpm → setup pnpm cache → install dependencies → Set Nx SHAs → (pașii Nx afectați, în task-uri ulterioare).",
      "Verifică la final ca fișierul 'ci.yml' să fie YAML valid (fără tab-uri, doar spații, indentare corectă) și ca în 'jobs.validate.steps' să existe atât pasul 'Install dependencies' cu 'pnpm install --frozen-lockfile', cât și pasul 'Set Nx SHAs' cu 'nrwl/nx-set-shas@v4'."
    ],
    "restrictii_de_iesire_din_contex": "Nu adăuga în acest task pași care rulează Nx (de ex. 'nx affected:lint', 'nx affected:test', 'nx affected:build') sau pași de conectare la Nx Cloud. Acestea vor fi definite în task-urile următoare. Nu modifica alte job-uri sau workflow-uri.",
    "validare": "Fișierul '/var/www/GeniusSuite/.github/workflows/ci.yml' conține în 'jobs.validate.steps' (1) un pas 'Install dependencies' care rulează exact 'pnpm install --frozen-lockfile', plasat după 'Setup pnpm cache', și (2) un pas 'Set Nx SHAs' care folosește 'nrwl/nx-set-shas@v4', plasat imediat după 'Install dependencies'. Pasul de checkout folosește 'actions/checkout@v4' cu 'fetch-depth: 0'. Workflow-ul este YAML-valid.",
    "outcome": "Job-ul 'validate' din 'ci.yml' are acum atât instalarea deterministă a dependențelor, cât și setarea corectă a SHA-urilor pentru Nx, pregătind pipeline-ul pentru rularea eficientă a comenzilor 'nx affected' în task-urile următoare.",
    "componenta_de_CI_CD": "Acest task completează infrastructura de bază pentru CI orientat pe monorepo Nx: garantează build-uri deterministe (prin 'pnpm install --frozen-lockfile') și permite rularea 'nx affected' cu baze de comparație corecte (prin 'nrwl/nx-set-shas@v4'), reducând semnificativ timpul de execuție al pipeline-ului pe Pull Request-uri."
  }
},
```

#### F0.2.8

```JSON
  {
  "F0.2.8": {
    "denumire_task": "Conectare la Nx Cloud (Remote Cache) în job-ul 'validate'",
    "descriere_scurta_task": "Adaugă pasul de conectare la Nx Cloud în 'ci.yml' după 'Set Nx SHAs'.",
    "descriere_lunga_si_detaliata_task": "În acest task conectăm pipeline-ul de CI la Nx Cloud (sau alt remote cache compatibil) pentru a beneficia de caching distribuit între rulări. Presupunem că monorepo-ul a fost deja conectat la Nx Cloud la nivel de proiect (de ex. prin 'nx connect' sau în timpul 'nx init' din F0.1), astfel încât pachetul 'nx-cloud' și configurația necesară există deja în 'package.json' și 'nx.json'. În job-ul 'validate' din 'ci.yml', după pasul 'Set Nx SHAs' (care setează NX_BASE și NX_HEAD), adăugăm un pas 'Connect to Nx Cloud' care rulează 'pnpm exec nx-cloud start-ci-run' și folosește secretul 'NX_CLOUD_AUTH_TOKEN' definit în setările repository-ului GitHub. Acest pas trebuie să fie executat înainte de orice comandă 'nx affected:*' pentru ca acestea să poată citi/scrie în cache-ul la distanță.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/.github/workflows/"
    ],
    "contextul_taskurilor_anterioare": "F0.2.4: Job-ul 'validate' a fost creat cu checkout. F0.2.5: Au fost adăugați pașii 'Setup Node.js', 'Setup pnpm' și 'Setup pnpm cache'. F0.2.6: A fost adăugat pasul 'Install dependencies' cu 'pnpm install --frozen-lockfile'. F0.2.7: A fost adăugat pasul 'Set Nx SHAs' care setează NX_BASE și NX_HEAD prin 'nrwl/nx-set-shas@v4'.",
    "contextul_general_al_aplicatiei": "Faza F0.2 urmărește să construiască un pipeline de CI rapid și incremental folosind capabilitățile Nx (particularly 'nx affected'). Remote caching-ul Nx Cloud folosește SHA-urile (NX_BASE/NX_HEAD) pentru a reutiliza rezultatele de lint/test/build între rulări, reducând semnificativ timpul de execuție al pipeline-ului.",
    "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/.github/workflows/ci.yml'. În job-ul 'validate', în lista 'steps', adaugă noul pas imediat DUPĂ pasul 'Set Nx SHAs' și ÎNAINTE de pașii care vor rula 'nx affected:lint', 'nx affected:test', 'nx affected:build' (care vor fi definiți în F0.2.9+).",
    "restrictii_anti_halucinatie": [
      "Lucrează EXCLUSIV pe fișierul '/var/www/GeniusSuite/.github/workflows/ci.yml'. Nu crea și nu modifica alte workflow-uri în acest task.",
      "Păstrează toți pașii existenți din 'jobs.validate.steps' (Checkout, Setup Node, Setup pnpm, Setup pnpm cache, Install dependencies, Set Nx SHAs) EXACT cum au fost definiți în F0.2.4 – F0.2.7. Nu le redenumi, nu le reordona.",
      "Verifică faptul că pasul 'Set Nx SHAs' există și are forma:",
      "- name: Set Nx SHAs",
      "  uses: nrwl/nx-set-shas@v4",
      "Dacă lipsește sau este diferit, corectează-l conform task-ului F0.2.7 înainte de a continua.",
      "Imediat DUPĂ pasul 'Set Nx SHAs', adaugă următorul pas YAML (cu indentare corectă în cadrul 'steps'):",
      "- name: Connect to Nx Cloud",
      "  run: pnpm exec nx-cloud start-ci-run",
      "  env:",
      "    NX_CLOUD_AUTH_TOKEN: ${{ secrets.NX_CLOUD_AUTH_TOKEN }}",
      "Nu schimba numele pasului ('Connect to Nx Cloud') și nu folosi altă comandă (de ex. 'npx nx-cloud', 'nx connect', 'nx-cloud start-ci-run' fără 'pnpm exec').",
      "NU scrie token-ul Nx Cloud direct în fișier. Singura sursă permisă este secretul GitHub 'NX_CLOUD_AUTH_TOKEN' referențiat prin 'secrets.NX_CLOUD_AUTH_TOKEN'.",
      "Nu adăuga câmpuri suplimentare în acest pas (de ex. 'if:', 'timeout-minutes:', 'working-directory:'), cu excepția cazului în care sunt introduse explicit într-un task viitor. Aici păstrăm pasul minim și clar.",
      "Asigură-te că acest pas este PLASAT înaintea oricărui pas care va rula comenzi Nx (ex. 'nx affected:lint', 'nx affected:test', 'nx affected:build'), astfel încât run-ul Nx Cloud să fie deja pornit.",
      "Presupunem că secretul 'NX_CLOUD_AUTH_TOKEN' a fost creat manual în GitHub (Settings → Secrets and variables → Actions). Nu încerca să creezi sau să modifici secretul din acest workflow.",
      "La final, verifică că fișierul 'ci.yml' este YAML-valid (fără tab-uri, doar spații, fără caractere suplimentare) și că structura logică a pașilor în 'jobs.validate.steps' este: Checkout → Setup Node → Setup pnpm → Setup pnpm cache → Install dependencies → Set Nx SHAs → Connect to Nx Cloud → (pași Nx future)."
    ],
    "restrictii_de_iesire_din_contex": "Nu adăuga în acest task pași care rulează efectiv 'nx affected:lint', 'nx affected:test', 'nx affected:build' sau alte comenzi Nx. Aceștia vor fi definiți în task-urile următoare. Nu modifica alte job-uri sau workflow-uri și nu introduce alte variabile de mediu în afară de 'NX_CLOUD_AUTH_TOKEN' pentru acest pas.",
    "validare": "Fișierul '/var/www/GeniusSuite/.github/workflows/ci.yml' conține în 'jobs.validate.steps' un pas numit exact 'Connect to Nx Cloud' care rulează 'pnpm exec nx-cloud start-ci-run' și setează 'NX_CLOUD_AUTH_TOKEN' din 'secrets.NX_CLOUD_AUTH_TOKEN', plasat imediat după pasul 'Set Nx SHAs'. La rularea pipeline-ului, job-ul 'validate' apare în dashboard-ul Nx Cloud (presupunând că secretul este configurat corect).",
    "outcome": "Job-ul 'validate' este conectat la Nx Cloud și este pregătit să folosească remote caching pentru toate comenzile Nx ulterioare, reducând considerabil timpul de execuție al pipeline-ului de CI.",
    "componenta_de_CI_CD": "Acest pas activează remote cache-ul Nx Cloud în pipeline-ul de CI, permițând reutilizarea rezultatelor de lint/test/build între rulări și integrând în mod practic configurațiile de caching definite în 'nx.json' (targetDefaults) în F0.1."
  }
},
```

#### F0.2.9

```JSON
  {
  "F0.2.9": {
    "denumire_task": "Adăugare Pași de Validare (Format, Lint, Test, Build) în 'ci.yml'",
    "descriere_scurta_task": "Adaugă în job-ul 'validate' rularea 'pnpm exec nx affected' pentru 'format:check', 'lint', 'test' și 'build'.",
    "descriere_lunga_si_detaliata_task": "Acest task finalizează job-ul 'validate' din 'ci.yml' prin adăugarea pașilor de validare efectivă a codului pentru Pull Request-uri. După ce SHAs-urile Nx au fost setate (F0.2.7) și conectarea la Nx Cloud a fost realizată (F0.2.8), rulăm în mod incremental comenzi 'pnpm exec nx affected' pentru țintele 'format:check', 'lint', 'test' și 'build'. Astfel, numai proiectele afectate de schimbările din PR sunt verificate, folosind remote cache-ul Nx Cloud pentru performanță maximă. În mod deliberat NU folosim script-urile globale din 'package.json' (ex. 'pnpm lint'), deoarece acestea invocă 'nx affected:lint --all' și ar rula inutil pe întregul monorepo.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/.github/workflows/"
    ],
    "contextul_taskurilor_anterioare": "F0.2.4: Job-ul 'validate' a fost creat. F0.2.5: Au fost adăugați pașii de setup Node, pnpm și cache. F0.2.6: A fost adăugat pasul 'Install dependencies' cu 'pnpm install --frozen-lockfile'. F0.2.7: A fost adăugat pasul 'Set Nx SHAs' cu 'nrwl/nx-set-shas@v4'. F0.2.8: A fost adăugat pasul 'Connect to Nx Cloud' cu 'pnpm exec nx-cloud start-ci-run'.",
    "contextul_general_al_aplicatiei": "Faza F0.2 definește pipeline-ul de CI pentru PR-uri pe monorepo-ul GeniusSuite. Miezul acestui pipeline este rularea validărilor Nx doar pe proiectele afectate (affected), pentru a minimiza timpul de execuție și a maximiza feedback-ul relevat dezvoltatorilor, folosind cache-ul Nx Cloud și configurările de caching din 'nx.json'.",
    "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/.github/workflows/ci.yml'. În job-ul 'validate', în lista 'steps', adaugă patru pași noi imediat DUPĂ pasul existent 'Connect to Nx Cloud' și ÎNAINTE de orice pași suplimentari (dacă vor exista în viitor). Fiecare pas va apela 'pnpm exec nx affected' cu o țintă diferită: 'format:check', 'lint', 'test' și 'build'.",
    "restrictii_anti_halucinatie": [
      "Lucrează EXCLUSIV pe fișierul '/var/www/GeniusSuite/.github/workflows/ci.yml'. Nu crea și nu modifica alte workflow-uri.",
      "Nu modifica pașii existenți din 'jobs.validate.steps' (Checkout, Setup Node.js, Setup pnpm, Setup pnpm cache, Install dependencies, Set Nx SHAs, Connect to Nx Cloud). Acest task doar ADAUGĂ pași noi după 'Connect to Nx Cloud'.",
      "Identifică pasul existent:",
      "- name: Connect to Nx Cloud",
      "  run: pnpm exec nx-cloud start-ci-run",
      "  env:",
      "    NX_CLOUD_AUTH_TOKEN: ${{ secrets.NX_CLOUD_AUTH_TOKEN }}",
      "Toți pașii noi trebuie adăugați IMEDIAT DUPĂ acest pas.",
      "Adaugă, în această ordine, următorii pași YAML în 'jobs.validate.steps' (respectă indentarea corectă, spații nu tab-uri):",
      "- name: Check formatting (affected)",
      "  run: pnpm exec nx affected -t format:check",
      "",
      "- name: Lint affected projects",
      "  run: pnpm exec nx affected -t lint",
      "",
      "- name: Test affected projects",
      "  run: pnpm exec nx affected -t test",
      "",
      "- name: Build affected projects",
      "  run: pnpm exec nx affected -t build",
      "Nu schimba prefixul 'pnpm exec'; nu folosi 'npx', 'yarn' sau 'nx' direct.",
      "Nu folosi script-urile din 'package.json' ('pnpm lint', 'pnpm test', etc.) în acest workflow de PR, deoarece în F0.1.43 'pnpm lint' a fost mapat la 'nx affected:lint --all', ceea ce ar rula pe toate proiectele, nu doar pe cele afectate.",
      "Nu adăuga opțiunea '--all' la niciuna dintre comenzile 'nx affected'. Comenzile trebuie să se bazeze pe variabilele NX_BASE și NX_HEAD setate de 'nrwl/nx-set-shas'.",
      "Nu adăuga alte ținte (targets) în acest task (ex. 'e2e', 'storybook') și nu modifica numele țintelor ('format:check', 'lint', 'test', 'build').",
      "Nu adăuga câmpuri suplimentare în acești pași (ex. 'env:', 'if:', 'timeout-minutes:') în acest task. Păstrează pașii simpli și determinist executabili.",
      "Asigură-te că fișierul final rămâne YAML-valid (fără tab-uri, fără caractere suplimentare) și că ordinea pașilor în 'jobs.validate.steps' este logică: Checkout → Setup Node → Setup pnpm → Setup pnpm cache → Install dependencies → Set Nx SHAs → Connect to Nx Cloud → Check formatting (affected) → Lint affected projects → Test affected projects → Build affected projects.",
      "Dacă există deja pași similari (ex. pași vechi care r-ulau 'pnpm lint' sau 'pnpm test'), aceștia trebuie eliminați pentru a evita dublarea logicii și pentru a forța utilizarea exclusivă a 'pnpm exec nx affected'."
    ],
    "restrictii_de_iesire_din_contex": "Nu transforma acest job într-un matrix job (nu adăuga 'strategy.matrix'). Nu adăuga job-uri noi (test-only, build-only) în acest task. Validarea se face într-un singur job 'validate' cu pași secvențiali. Nu modifica triggerele 'on:' sau alte workflow-uri.",
    "validare": "În '/var/www/GeniusSuite/.github/workflows/ci.yml', secțiunea 'jobs.validate.steps' conține, după 'Connect to Nx Cloud', exact patru pași noi cu numele 'Check formatting (affected)', 'Lint affected projects', 'Test affected projects' și 'Build affected projects', fiecare rulând respectiv 'pnpm exec nx affected -t format:check', 'pnpm exec nx affected -t lint', 'pnpm exec nx affected -t test' și 'pnpm exec nx affected -t build'. La rularea unui PR cu modificări, pipeline-ul eșuează dacă oricare dintre aceste comenzi eșuează.",
    "outcome": "Pipeline-ul 'ci.yml' validează complet formatarea, linting-ul, testele și build-ul DOAR pentru proiectele afectate de schimbări, folosind Nx + Nx Cloud, oferind feedback rapid și relevant pentru fiecare Pull Request.",
    "componenta_de_CI_CD": "Acești pași reprezintă miezul validării CI: combină Nx 'affected' cu remote caching-ul Nx Cloud pentru a executa doar ceea ce este necesar, reducând în mod semnificativ timpul de rulare al pipeline-ului pe PR-uri și asigurând în același timp calitatea codului și a build-urilor."
  }
},
```

#### F0.2.10

```JSON
  {
  "F0.2.10": {
    "denumire_task": "Creare Fișier Workflow 'release.yml'",
    "descriere_scurta_task": "Creează fișierul 'release.yml' pentru publicarea pachetelor.",
    "descriere_lunga_si_detaliata_task": "Creăm un al doilea fișier workflow, 'release.yml', în directorul standard '.github/workflows/'. Acest workflow va fi responsabil pentru partea de CD: versionare semantică și publicarea pachetelor. În acest task definim doar scheletul fișierului YAML (un nume de workflow și o structură minimă 'on' + 'jobs' validă). Declanșatoarele concrete (ex. 'push' pe 'master') și job-urile efective de release (semantic-release, publish) vor fi configurate în task-urile următoare, pentru a păstra atomicitatea și pentru a evita amestecarea responsabilităților în același task.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/.github/workflows/"
    ],
    "contextul_taskurilor_anterioare": "F0.2.1: Directorul '.github/workflows/' există. F0.2.2-F0.2.9: Pipeline-ul de CI ('ci.yml') pentru PR-uri a fost creat și completat.",
    "contextul_general_al_aplicatiei": "Separarea clară între pipeline-ul de verificare (CI, în 'ci.yml') și pipeline-ul de publicare/versiune (CD, în 'release.yml'), conform strategiei de Git branching (master, staging, dev) și obiectivelor de automatizare a release-urilor.",
    "contextualizarea_directoarelor_si_cailor": "Lucrează în rădăcina repository-ului '/var/www/GeniusSuite/'. Creează fișierul '/var/www/GeniusSuite/.github/workflows/release.yml' cu un conținut YAML minim valid, astfel încât GitHub Actions să îl recunoască drept workflow, chiar dacă deocamdată nu definește încă logica de release.",
    "restrictii_anti_halucinatie": [
      "Nu modifica fișierul existent '.github/workflows/ci.yml' în acest task. Acest task se referă STRICT la 'release.yml'.",
      "Dacă directorul '.github/workflows/' nu există, nu îl crea aici; el a fost deja creat în F0.2.1. Presupune că există.",
      "Creează fișierul '.github/workflows/release.yml' doar dacă nu există. Dacă există deja, actualizează-l pentru a corespunde scheletului descris mai jos, fără a adăuga logică de release suplimentară în acest task.",
      "Conținutul inițial al fișierului trebuie să fie un YAML minim valid, de forma:",
      "name: Release",
      "on:",
      "  workflow_dispatch:",
      "jobs: {}",
      "Nu adăuga încă evenimente 'push' sau 'tags' în secțiunea 'on'. Acestea vor fi configurate în task-urile următoare (de exemplu, pentru 'push' pe branch-ul 'master').",
      "Nu adăuga încă job-uri reale (steps, runs-on etc.). 'jobs: {}' este suficient în acest moment ca placeholder valid.",
      "Nu adăuga logică pentru 'semantic-release', 'npm publish' sau alte unelte de release în acest task. Acestea vor fi implementate în pași ulteriori.",
      "Asigură-te că fișierul 'release.yml' este YAML-valid (fără tab-uri, doar spații) și NU conține alte chei în afara 'name', 'on' și 'jobs' în această fază.",
      "Nu copia conținut din 'ci.yml' în 'release.yml'. Cele două workflow-uri au responsabilități distincte (CI vs CD)."
    ],
    "restrictii_de_iesire_din_contex": "Nu configura în acest task declanșatoarele finale pentru release (ex. 'on: push: branches: [\"master\"]') și nu defineiți job-uri de versionare sau publicare. Aceste aspecte vor fi tratate în task-urile F0.2.x următoare.",
    "validare": "Verifică existența fișierului '/var/www/GeniusSuite/.github/workflows/release.yml' și faptul că acesta conține un YAML minim valid cu cheile 'name', 'on.workflow_dispatch' și 'jobs: {}'.",
    "outcome": "Fișierul 'release.yml' există în '.github/workflows/' și reprezintă scheletul workflow-ului de release, pregătit pentru a fi completat cu declanșatoare și job-uri de publicare în task-urile următoare.",
    "componenta_de_CI_CD": "Acest fișier va găzdui pipeline-ul de CD (release semantic și publicarea pachetelor), separat de pipeline-ul de CI ('ci.yml'), permițând configurarea independentă a fluxurilor de verificare și release."
  }
},
```

#### F0.2.11

```JSON
  {
  "F0.2.11": {
    "denumire_task": "Instalare '@changesets/cli'",
    "descriere_scurta_task": "Instalează '@changesets/cli' ca dependență de dezvoltare la rădăcina monorepo-ului.",
    "descriere_lunga_si_detaliata_task": "Pentru a gestiona versionarea independentă a pachetelor (conform structurii din Capitolul 2: shared/*, cp/*, vettify.app etc.), vom folosi Changesets. '@changesets/cli' oferă un flux modern pentru monorepo-uri, permițând definirea de changeset-uri explicite pentru fiecare modificare și calcularea versiunilor fără a depinde de formatul mesajelor de commit (spre deosebire de semantic-release). În acest task instalăm doar CLI-ul la rădăcină, ca devDependency, folosind pnpm, fără a inițializa încă configurația Changesets.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.51: Fundația F0.1 este comisionată pe branch-ul 'dev'. F0.2.1 - F0.2.10: Infrastructura de CI/CD (ci.yml, release.yml) a început să fie definită. Următoarele task-uri vor integra Changesets în pipeline-ul de release.",
    "contextul_general_al_aplicatiei": "Monorepo-ul GeniusSuite conține mai multe biblioteci shared/* și aplicații. Avem nevoie de un mecanism care să poată versiona independent pachetele și să genereze changelog-uri corecte, fără să ne bazăm strict pe formatul mesajelor de commit. Changesets este un standard de facto pentru astfel de monorepo-uri.",
    "contextualizarea_directoarelor_si_cailor": "Comanda se execută în directorul rădăcină al monorepo-ului: '/var/www/GeniusSuite/'. Aceasta va modifica fișierul '/var/www/GeniusSuite/package.json', adăugând '@changesets/cli' în 'devDependencies' și actualizând fișierul 'pnpm-lock.yaml'.",
    "restrictii_anti_halucinatie": [
      "Execută comanda EXCLUSIV din '/var/www/GeniusSuite/'.",
      "Folosește pnpm ca manager de pachete. Comanda corectă este:",
      "pnpm add -D @changesets/cli",
      "Nu folosi 'npm install', 'yarn add' sau 'npx'.",
      "Nu instala alte pachete din ecosistemul Changesets în acest task (ex. '@changesets/changelog-github', '@changesets/apply-release-plan'). Doar '@changesets/cli'.",
      "Nu modifica alte câmpuri din 'package.json' în afară de adăugarea dependenței '@changesets/cli' (și actualizarea automată a versiunilor/lockfile-ului făcute de pnpm).",
      "Nu rula încă 'pnpm changeset init' sau alte comenzi Changesets. Inițializarea configurării Changesets va fi tratată într-un task separat.",
      "După instalare, verifică că '@changesets/cli' apare la 'devDependencies' și că nu există duplicări (de ex. aceeași dependență atât la 'dependencies', cât și la 'devDependencies')."
    ],
    "restrictii_de_iesire_din_contex": "Acest task NU configurează workflow-ul de release și nu creează fișiere Changesets (de ex. '.changeset/config.json'). Se ocupă strict de instalarea '@changesets/cli' la rădăcină.",
    "validare": "Fișierul '/var/www/GeniusSuite/package.json' conține '@changesets/cli' în secțiunea 'devDependencies'. Comanda 'pnpm changeset --help' rulat în '/var/www/GeniusSuite/' funcționează fără erori.",
    "outcome": "CLI-ul Changesets este instalat la rădăcina monorepo-ului și pregătit pentru a fi inițializat și integrat în pipeline-ul de release ('release.yml') în task-urile următoare.",
    "componenta_de_CI_CD": "Asigură dependența de bază pentru fluxul de release: workflows-urile de CD (definite în 'release.yml') vor putea ulterior să ruleze comenzi Changesets (de ex. 'pnpm changeset version', 'pnpm changeset publish') pentru versionare și publicare controlată a pachetelor."
  }
},
```

#### F0.2.12

```JSON
  {
  "F0.2.12": {
    "denumire_task": "Inițializare 'changesets'",
    "descriere_scurta_task": "Rulează 'pnpm exec changeset init' pentru a crea directorul '.changeset' și configurația de bază.",
    "descriere_lunga_si_detaliata_task": "Rulăm comanda de inițializare Changesets la rădăcina monorepo-ului. Aceasta va crea directorul '.changeset/', fișierul de configurare '.changeset/config.json' și un '.changeset/README.md' explicativ. Acest pas configurează structura de bază pentru versionarea pe pachete și pentru generarea de changeset-uri individuale. Nu modificăm încă manual fișierele generate; folosim configurația implicită furnizată de '@changesets/cli', urmând să o ajustăm în task-uri ulterioare dacă e nevoie.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "F0.2.11: '@changesets/cli' este instalat ca devDependency la rădăcină. F0.2.10: 'release.yml' (scheletul workflow-ului de release) există.",
    "contextul_general_al_aplicatiei": "Inițierea configurației Changesets, care va fi folosită ulterior pentru versionarea și publicarea pachetelor 'shared/*' și, eventual, a aplicațiilor, în cadrul pipeline-ului de release ('release.yml').",
    "contextualizarea_directoarelor_si_cailor": "Execută comenzile în directorul rădăcină al monorepo-ului: '/var/www/GeniusSuite/'. Comanda va crea directorul '/var/www/GeniusSuite/.changeset/' și fișierele implicite în interiorul lui.",
    "restrictii_anti_halucinatie": [
      "Execută comanda EXCLUSIV din '/var/www/GeniusSuite/'.",
      "Folosește pnpm și CLI-ul instalat local. Comanda corectă este:",
      "pnpm exec changeset init",
      "Nu folosi 'npx changeset init', 'yarn changeset init' sau 'changeset init' direct.",
      "Dacă directorul '.changeset/' există deja și conține un 'config.json' valid, NU rula din nou 'changeset init' în acest task (pentru a evita suprascrierea). În acest caz, marchează task-ul ca deja satisfăcut.",
      "Nu modifica manual conținutul '.changeset/config.json' sau '.changeset/README.md' în acest task. Orice ajustări de configurație se fac în task-uri separate.",
      "Nu adăuga, nu șterge și nu redenumi alte fișiere din repository în acest task; modificările trebuie să se limiteze la crearea structurii '.changeset/'."
    ],
    "restrictii_de_iesire_din_contex": "Nu crea încă changeset-uri individuale (fișiere '*.md' în '.changeset/'). Nu integra încă Changesets în workflow-ul 'release.yml'.",
    "validare": "Verifică existența directorului '/var/www/GeniusSuite/.changeset/' și a fișierului '/var/www/GeniusSuite/.changeset/config.json'. Opțional, execută 'pnpm exec changeset status' în '/var/www/GeniusSuite/' pentru a verifica că inițializarea a reușit (ar trebui să raporteze 'No unreleased changesets').",
    "outcome": "Configurația de bază Changesets este inițializată în monorepo, pregătind terenul pentru definirea de changeset-uri și integrarea cu workflow-ul de release.",
    "componenta_de_CI_CD": "Deși acest task nu modifică încă workflow-urile de GitHub Actions, el introduce infrastructura necesară pentru ca pipeline-ul de release ('release.yml') să poată folosi Changesets pentru calcularea versiunilor și publicare."
  }
},
```

#### F0.2.13

```JSON
  {
  "F0.2.13": {
    "denumire_task": "Configurare completă 'changesets' (config.json + changelog GitHub)",
    "descriere_scurta_task": "Instalează '@changesets/changelog-github' și configurează '.changeset/config.json' cu 'baseBranch', 'access' și generatorul de changelog pentru GitHub.",
    "descriere_lunga_si_detaliata_task": "Acest task finalizează configurarea 'changesets' pentru monorepo-ul GeniusSuite. În primul rând, instalăm pachetul '@changesets/changelog-github', care va genera intrări de changelog cu link-uri către commit-uri, PR-uri și useri GitHub. Apoi, modificăm fișierul '.changeset/config.json' generat de 'pnpm exec changeset init' pentru a-l alinia la strategia de Git și de publicare: setăm 'baseBranch' la 'master' (branch-ul principal de release), 'access' la 'public' (pachetele pot fi publicate pe un registry public), configurăm 'updateInternalDependencies' la 'patch' și definim 'changelog' astfel încât să folosească '@changesets/changelog-github' cu repository-ul corect. Păstrăm 'commit: false' pentru ca workflow-ul 'release.yml' să controleze explicit commit-urile de versiune.",
    "directorul_directoarele": [
      "/",
      ".changeset/"
    ],
    "contextul_taskurilor_anterioare": "F0.2.11: '@changesets/cli' este instalat. F0.2.12: 'pnpm exec changeset init' a creat directorul '.changeset/' și fișierul 'config.json'.",
    "contextul_general_al_aplicatiei": "Configurarea 'changesets' astfel încât să funcționeze corect cu fluxul Git (master/staging/dev) și cu GitHub (changelog cu link-uri către PR-uri și commit-uri), pregătind pipeline-ul de release bazat pe changeset-uri.",
    "contextualizarea_directoarelor_si_cailor": "Execută comenzile în directorul rădăcină '/var/www/GeniusSuite/'. Fișierul de configurare țintă este '/var/www/GeniusSuite/.changeset/config.json'.",
    "restrictii_anti_halucinatie": [
      "1) Lucrează DOAR în repository-ul existent, la calea '/var/www/GeniusSuite/'. Nu crea un proiect nou, nu rula 'git init' și nu modifica structura de directoare în afara celor menționate.",
      "2) Instalează generatorul de changelog GitHub ca dependență de dezvoltare la rădăcină, folosind EXACT comanda:",
      "   pnpm add -D @changesets/changelog-github",
      "   Nu folosi 'npm' sau 'yarn'. Nu instala alte pachete '@changesets/*' în acest task.",
      "3) Deschide fișierul '.changeset/config.json' existent și suprascrie-i conținutul cu un obiect JSON VALID care să aibă cel puțin următoarea structură:",
      "   {",
      "     \"$schema\": \"https://unpkg.com/@changesets/config/schema.json\",",
      "     \"changelog\": [",
      "       \"@changesets/changelog-github\",",
      "       { \"repo\": \"GITHUB_USERNAME/GeniusSuite\" }",
      "     ],",
      "     \"commit\": false,",
      "     \"fixed\": [],",
      "     \"linked\": [],",
      "     \"access\": \"public\",",
      "     \"baseBranch\": \"master\",",
      "     \"updateInternalDependencies\": \"patch\",",
      "     \"ignore\": []",
      "   }",
      "4) Nu schimba cheia 'commit': trebuie să rămână 'false'. Nu o seta la 'true' și nu o elimina.",
      "5) Nu inventa alte chei necunoscute în config ('changelog-github-bot', 'cli-github' etc.). Folosește DOAR câmpurile listate mai sus, plus câmpuri deja generate de 'changeset init' dacă există și nu intră în conflict.",
      "6) Nu modifica numele branch-ului de bază: trebuie să fie EXACT 'master', aliniat cu strategia Git a proiectului.",
      "7) Nu adăuga token-uri sau secrete în fișierul de configurare. Autentificarea GitHub se face din workflow-urile GitHub Actions prin 'secrets.GITHUB_TOKEN', nu din 'config.json'."
    ],
    "restrictii_de_iesire_din_contex": "Acest task se limitează la instalarea '@changesets/changelog-github' și modificarea fișierului '.changeset/config.json'. Nu crea workflow-uri noi și nu modifica 'release.yml' sau alte fișiere CI/CD în acest task.",
    "validare": "1) În 'package.json' de la rădăcină, în secțiunea 'devDependencies', trebuie să existe intrarea '@changesets/changelog-github'. 2) Fișierul '.changeset/config.json' trebuie să fie JSON valid și să conțină: 'baseBranch': 'master', 'access': 'public', 'updateInternalDependencies': 'patch', 'commit': false, 'changelog' configurat cu '@changesets/changelog-github' și 'repo': 'GITHUB_USERNAME/GeniusSuite'. 3) Rularea 'pnpm exec changeset status' NU trebuie să dea erori de configurare.",
    "outcome": "Monorepo-ul GeniusSuite are 'changesets' complet configurat: config.json este valid, aliniat cu strategia Git și de publicare, iar generatorul de changelog pentru GitHub este instalat și referențiat corect.",
    "componenta_de_CI_CD": "Această configurație va fi folosită ulterior de workflow-ul 'release.yml' pentru a genera changelog-uri corecte, a calcula versiunile pachetelor și a publica release-uri bazate pe changeset-uri."
  }
},
```

#### F0.2.14

```JSON
  {
  "F0.2.14": {
    "denumire_task": "Configurare Bot 'changesets' pentru PR-uri",
    "descriere_scurta_task": "Configurează workflow-ul 'changeset-bot.yml' care verifică și comentează dacă lipsesc fișiere '.changeset' în PR-uri.",
    "descriere_lunga_si_detaliata_task": "Configurăm un workflow GitHub Actions dedicat (changeset-bot.yml) care rulează pe fiecare Pull Request către branch-urile principale. Jobul verifică dacă PR-ul modifică pachete din monorepo (ex. 'shared/*', 'cp/*', 'vettify.app/*'). Dacă există modificări de cod dar nu există fișiere '.changeset/*.md' (în afară de README), workflow-ul adaugă automat un comentariu explicativ pe PR și marchează job-ul ca eșuat. Comentariul îl ghidează pe dezvoltator să ruleze 'pnpm exec changeset' și să comită fișierul generat. Pentru comentarii mai avansate, se poate instala și aplicația oficială 'changesets-bot' din GitHub Marketplace, dar acest task se bazează doar pe '@changesets/cli' instalat în F0.2.11.",
    "directorul_directoarele": [
      "/",
      ".github/workflows/"
    ],
    "contextul_taskurilor_anterioare": "F0.2.11: '@changesets/cli' este instalat. F0.2.12: '.changeset/' este inițializat. F0.2.13: '.changeset/config.json' este configurat.",
    "contextul_general_al_aplicatiei": "Impunerea disciplinei de versionare: orice modificare de pachet trebuie însoțită de un fișier '.changeset', altfel PR-ul este blocat și autorul primește un feedback clar.",
    "contextualizarea_directoarelor_si_cailor": "Nu se mai instalează pachete suplimentare Changesets. Se creează fișierul '/var/www/GeniusSuite/.github/workflows/changeset-bot.yml'.",
    "restrictii_anti_halucinatie": [
      "NU instala pachetul inexistent '@changesets/cli-github'. Folosește doar '@changesets/cli' instalat în F0.2.11.",
      "Dacă se dorește comentariu suplimentar din partea aplicației oficiale, un maintainer poate instala manual GitHub App-ul 'changesets-bot' pe repository. Acest lucru nu se automatizează din workflow.",
      "Creează fișierul '.github/workflows/changeset-bot.yml' cu următorul conținut YAML (adaptat pentru pnpm):",
      "name: Changeset Bot",
      "",
      "on:",
      "  pull_request:",
      "    branches:",
      "      - master",
      "      - staging",
      "      - dev",
      "",
      "jobs:",
      "  changeset-check:",
      "    runs-on: ubuntu-latest",
      "    steps:",
      "      - name: Checkout repository",
      "        uses: actions/checkout@v4",
      "        with:",
      "          fetch-depth: 0",
      "",
      "      - name: Setup Node.js",
      "        uses: actions/setup-node@v4",
      "        with:",
      "          node-version: 24",
      "",
      "      - name: Setup pnpm",
      "        uses: pnpm/action-setup@v2",
      "        with:",
      "          version: 8",
      "",
      "      - name: Install dependencies",
      "        run: pnpm install --frozen-lockfile",
      "",
      "      - name: Detect changed packages",
      "        id: changed-files",
      "        run: |",
      "          BASE_BRANCH=${GITHUB_BASE_REF:-master}",
      "          git fetch origin \"$BASE_BRANCH\" --depth=50",
      "          changed_files=$(git diff --name-only \"origin/$BASE_BRANCH\"...HEAD | grep -E '^(shared/|cp/|vettify\\.app/)' || true)",
      "          if [ -n \"$changed_files\" ]; then",
      "            echo \"has_package_changes=true\" >> $GITHUB_OUTPUT",
      "          else",
      "            echo \"has_package_changes=false\" >> $GITHUB_OUTPUT",
      "          fi",
      "",
      "      - name: Check for changeset files",
      "        id: changeset-check",
      "        run: |",
      "          if [ -d \".changeset\" ]; then",
      "            count=$(find .changeset -maxdepth 1 -name '*.md' ! -name 'README.md' | wc -l)",
      "          else",
      "            count=0",
      "          fi",
      "          if [ \"$count\" -eq 0 ]; then",
      "            echo \"has_changesets=false\" >> $GITHUB_OUTPUT",
      "          else",
      "            echo \"has_changesets=true\" >> $GITHUB_OUTPUT",
      "          fi",
      "",
      "      - name: Comment when changesets are missing",
      "        if: steps.changed-files.outputs.has_package_changes == 'true' && steps.changeset-check.outputs.has_changesets == 'false'",
      "        uses: actions/github-script@v7",
      "        with:",
      "          script: |",
      "            const { context, github } = require('@actions/github');",
      "            const { owner, repo } = context.repo;",
      "            const prNumber = context.payload.pull_request.number;",
      "            const body = [",
      "              '## Changesets',",
      "              '',",
      "              'Am detectat modificări în pachetele monorepo-ului, dar niciun fișier `.changeset`.',",
      "              'Te rog rulează `pnpm exec changeset` în local, alege versiunea potrivită și comite fișierul generat în acest PR.',",
      "              '',",
      "              'Fără changeset, modificarea nu va fi inclusă corect în release-uri.'",
      "            ].join('\\n');",
      "            await github.rest.issues.createComment({",
      "              owner,",
      "              repo,",
      "              issue_number: prNumber,",
      "              body",
      "            });",
      "",
      "      - name: Fail if package changes have no changeset",
      "        if: steps.changed-files.outputs.has_package_changes == 'true' && steps.changeset-check.outputs.has_changesets == 'false'",
      "        run: |",
      "          echo \"Pachet modificat fără fișier .changeset. Vedeți comentariul automat pentru instrucțiuni.\"",
      "          exit 1",
      "",
      "Nu modifica alte workflow-uri în acest task.",
      "Nu adăuga alte secrete; 'GITHUB_TOKEN' implicit oferit de GitHub Actions este suficient pentru 'actions/github-script'."
    ],
    "restrictii_de_iesire_din_contex": "Nu modifica 'ci.yml' sau 'release.yml' în acest task. Acesta adaugă doar un workflow nou, 'changeset-bot.yml'.",
    "validare": "Fișierul '.github/workflows/changeset-bot.yml' există. Pe un PR care modifică pachete (ex. în 'shared/ui-design-system') fără niciun fișier '.changeset/*.md', job-ul 'changeset-check' eșuează și apare un comentariu automat pe PR cu instrucțiuni de adăugare a unui changeset.",
    "outcome": "Orice PR care modifică pachete în monorepo este obligat să includă un fișier '.changeset'; în caz contrar, PR-ul este blocat și autorul este notificat clar printr-un comentariu automat.",
    "componenta_de_CI_CD": "Componentă CI suplimentară, complementară lui 'ci.yml': asigură disciplina de versionare și previne PR-uri care modifică pachete fără changeset-uri corespunzătoare."
  }
},
```

#### F0.2.15

```JSON
  {
  "F0.2.15": {
    "denumire_task": "Configurare Workflow 'release.yml' (Triggers și Job 'publish')",
    "descriere_scurta_task": "Configurează 'release.yml' să ruleze pe 'push' la 'master' și definește job-ul 'publish'.",
    "descriere_lunga_si_detaliata_task": "Configurăm fișierul 'release.yml'. Acesta se va declanșa doar la push pe 'master'. Definim un singur job, 'publish', care va fi responsabil de rularea validărilor finale, versionarea și publicarea pachetelor. În acest task creăm doar scheletul job-ului; pașii efectivi de validare și publicare vor fi adăugați în F0.2.16 și F0.2.17.",
    "directorul_directoarele": [
      ".github/workflows/"
    ],
    "contextul_taskurilor_anterioare": "F0.2.10: Fișierul 'release.yml' există.",
    "contextul_general_al_aplicatiei": "Automatizarea publicării pachetelor la push pe 'master', separat de pipeline-ul de CI.",
    "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/.github/workflows/release.yml'.",
    "restrictii_anti_halucinatie": [
      "Modifică fișierul '.github/workflows/release.yml' astfel încât să conțină următorul schelet minimal:",
      "name: Release Packages",
      "",
      "on:",
      "  push:",
      "    branches:",
      "      - master",
      "",
      "jobs:",
      "  publish:",
      "    name: Publish Packages",
      "    runs-on: ubuntu-latest",
      "    steps:",
      "      - name: Pipeline skeleton",
      "        run: echo 'Release pipeline skeleton – steps vor fi adăugate în F0.2.16 și F0.2.17'"
    ],
    "restrictii_de_iesire_din_contex": "Secretul 'GH_PAT_TOKEN' (un Personal Access Token cu permisiuni de 'write' pe repository și, dacă este cazul, pe registry-ul de pachete) trebuie creat și adăugat în setările GitHub ale repository-ului, dar nu îl folosi încă în acest task. Nu adăuga pașii de changesets sau publish până la F0.2.16 și F0.2.17.",
    "validare": "'/.github/workflows/release.yml' conține blocul 'on: push: branches: [master]' și job-ul 'publish' cu un step placeholder valid.",
    "outcome": "Job-ul 'publish' este definit ca schelet și gata să fie completat cu pașii de versionare și publicare în task-urile următoare.",
    "componenta_de_CI_CD": "Reprezintă scheletul pipeline-ului de CD care va publica pachetele la push pe 'master'."
  }
},
```

#### F0.2.16

```JSON
  {
  "F0.2.16": {
    "denumire_task": "Adăugare Pași de Validare în 'release.yml'",
    "descriere_scurta_task": "Completează job-ul 'publish' din 'release.yml' cu pași de setup și validare 'nx affected' (format, lint, test, build).",
    "descriere_lunga_si_detaliata_task": "Înainte de a publica pachetele, trebuie să ne asigurăm că merge-ul în 'master' este valid. Completăm job-ul 'publish' din 'release.yml' cu pașii necesari: checkout, configurare Node.js și pnpm, cache pentru pnpm, instalare dependențe și rularea validărilor 'nx affected' (format:check, lint, test, build). Într-un workflow de tip 'push' pe 'master', 'nx affected' va compara commit-ul curent cu commit-ul precedent de pe master pentru a determina proiectele afectate.",
    "directorul_directoarele": [
      ".github/workflows/"
    ],
    "contextul_taskurilor_anterioare": "F0.2.15: 'release.yml' există și definește scheletul job-ului 'publish' (fără pași concreți).",
    "contextul_general_al_aplicatiei": "Asigurarea integrității branch-ului 'master' înainte de a rula pașii de versionare și publicare.",
    "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/.github/workflows/release.yml', completând job-ul 'publish' cu pașii de setup și validare.",
    "restrictii_anti_halucinatie": [
      "Înlocuiește conținutul fișierului '.github/workflows/release.yml' cu următorul conținut complet:",
      "name: Release Packages",
      "",
      "on:",
      "  push:",
      "    branches:",
      "      - master",
      "",
      "jobs:",
      "  publish:",
      "    name: Publish Packages",
      "    runs-on: ubuntu-latest",
      "    steps:",
      "      - name: Checkout repository",
      "        uses: actions/checkout@v4",
      "        with:",
      "          fetch-depth: 0",
      "",
      "      - name: Setup Node.js",
      "        uses: actions/setup-node@v4",
      "        with:",
      "          node-version: 24",
      "",
      "      - name: Setup pnpm",
      "        uses: pnpm/action-setup@v2",
      "        with:",
      "          version: 8",
      "",
      "      - name: Setup pnpm cache",
      "        uses: actions/cache@v4",
      "        with:",
      "          path: ~/.pnpm-store",
      "          key: ${{ runner.os }}-pnpm-store-${{ hashFiles('**/pnpm-lock.yaml') }}",
      "          restore-keys: |",
      "            ${{ runner.os }}-pnpm-store-",
      "",
      "      - name: Install dependencies",
      "        run: pnpm install --frozen-lockfile",
      "",
      "      - name: Check formatting (affected)",
      "        run: pnpm exec nx affected -t format:check",
      "",
      "      - name: Lint affected projects",
      "        run: pnpm exec nx affected -t lint",
      "",
      "      - name: Test affected projects",
      "        run: pnpm exec nx affected -t test",
      "",
      "      - name: Build affected projects",
      "        run: pnpm exec nx affected -t build",
      "",
      "      # Pașii de versionare și publicare (changesets) vor fi adăugați în F0.2.17."
    ],
    "restrictii_de_iesire_din_contex": "Nu adăuga încă pașii de versionare/publicare 'changesets'. Aceștia vor fi tratați în F0.2.17, după ce validările 'nx affected' trec cu succes. Nu folosi încă secretul 'GH_PAT_TOKEN' în acest task.",
    "validare": "Fișierul '.github/workflows/release.yml' conține job-ul 'publish' cu pașii: checkout, setup Node.js, setup pnpm, cache pnpm, 'pnpm install --frozen-lockfile' și cele patru comenzi 'pnpm exec nx affected' pentru 'format:check', 'lint', 'test' și 'build'.",
    "outcome": "Pipeline-ul de release validează codul pe 'master' (format, lint, test, build) înainte de orice pas de versionare și publicare.",
    "componenta_de_CI_CD": "Reprezintă poarta de siguranță din pipeline-ul de CD: dacă orice pas 'nx affected' eșuează, publicarea nu va fi executată."
  }
},
```

#### F0.2.17

```JSON
  {
  "F0.2.17": {
    "denumire_task": "Adăugare Pași de Versionare și Publicare (Changesets) în 'release.yml'",
    "descriere_scurta_task": "Adaugă pașii de versionare și publicare folosind 'changesets/action@v1' în job-ul 'publish' din 'release.yml'.",
    "descriere_lunga_si_detaliata_task": "După ce validările 'nx affected' (format:check, lint, test, build) trec cu succes pe branch-ul 'master' (F0.2.16), completăm job-ul 'publish' din 'release.yml' cu pașii de versionare și publicare. Folosim 'changesets/action@v1' pentru a rula 'pnpm exec changeset version' (care actualizează versiunile și changelog-urile) și 'pnpm -r publish' (pentru a publica toate pachetele afectate). Înainte de a rula acțiunea, configurăm identitatea Git pentru commit-ul automat. Acțiunea folosește secretele 'GH_PAT_TOKEN' (pentru push/PR) și 'NPM_TOKEN' (pentru publicarea în registry).",
    "directorul_directoarele": [
      ".github/workflows/"
    ],
    "contextul_taskurilor_anterioare": "F0.2.15: 'release.yml' definește scheletul job-ului 'publish'. F0.2.16: job-ul 'publish' conține deja pașii de checkout, setup Node/pnpm, cache, instalare dependențe și validările 'nx affected'.",
    "contextul_general_al_aplicatiei": "Finalizarea pipeline-ului de CD: după ce codul de pe 'master' este validat, se rulează versionarea și publicarea pachetelor.",
    "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/.github/workflows/release.yml', adăugând pașii de versionare și publicare la finalul job-ului 'publish', după pașii 'nx affected'.",
    "restrictii_anti_halucinatie": [
      "În fișierul '.github/workflows/release.yml', în job-ul 'publish', adaugă URMĂTORII pași DUPĂ pașii de validare ('Check formatting', 'Lint affected projects', 'Test affected projects', 'Build affected projects'):",
      "",
      "- name: Configure Git user",
      "  run: |",
      "    git config user.name \"github-actions[bot]\"",
      "    git config user.email \"41898282+github-actions[bot]@users.noreply.github.com\"",
      "",
      "- name: Create Release Pull Request or Publish",
      "  uses: changesets/action@v1",
      "  with:",
      "    version: pnpm exec changeset version",
      "    publish: pnpm -r publish --access public --no-git-checks",
      "  env:",
      "    GITHUB_TOKEN: ${{ secrets.GH_PAT_TOKEN }}",
      "    NPM_TOKEN: ${{ secrets.NPM_TOKEN }}",
      "",
      "Nu dubla pașii de 'checkout', 'setup-node', 'setup pnpm', 'cache' sau 'pnpm install' în acest task; aceștia există deja din F0.2.16.",
      "Asigură-te că secretul 'GH_PAT_TOKEN' are permisiuni de 'repo write' și 'packages:write', iar 'NPM_TOKEN' are permisiuni de publicare în registry-ul configurat (npmjs.com sau registry privat)."
    ],
    "restrictii_de_iesire_din_contex": "Nu modifica pașii de validare 'nx affected' adăugați în F0.2.16. Acest task doar adaugă pașii de versionare/publicare la finalul job-ului 'publish'. Nu adăuga aici pași de Docker (aceștia sunt tratați în F0.2.18).",
    "validare": "Fișierul '.github/workflows/release.yml' conține, în job-ul 'publish', după pașii 'nx affected', un pas 'Configure Git user' urmat de un pas 'Create Release Pull Request or Publish' care folosește 'changesets/action@v1' cu 'version: pnpm exec changeset version' și 'publish: pnpm -r publish --access public --no-git-checks', plus variabilele de mediu 'GITHUB_TOKEN' și 'NPM_TOKEN'.",
    "outcome": "Pipeline-ul de release este complet: după validarea branch-ului 'master', versiunile pachetelor sunt actualizate prin Changesets, se creează commit-ul de release și pachetele sunt publicate în registry.",
    "componenta_de_CI_CD": "Reprezintă partea finală a pipeline-ului de CD: automatizează versionarea și publicarea pachetelor odată ce toate validările au trecut."
  }
},
```

#### F0.2.18

```JSON
  {
  "F0.2.18": {
    "denumire_task": "Creare Șablon 'Dockerfile.base' (Multi-stage)",
    "descriere_scurta_task": "Creează un 'Dockerfile.base' multi-stage reutilizabil pentru aplicațiile Node.js 24.",
    "descriere_lunga_si_detaliata_task": "Creăm un Dockerfile de bază în directorul 'scripts/'. Acesta va fi un șablon multi-stage pentru aplicațiile Node.js 24 din monorepo-ul Nx + pnpm. Stage-ul 'base' pornește de la imaginea 'node:24-alpine', configurează Corepack și pnpm. Stage-ul 'builder' copiază lockfile-urile și fișierele de workspace, rulează 'pnpm install --frozen-lockfile' și apoi 'pnpm exec nx build' pentru aplicația țintă (specificată prin build-arg APP_NAME). Stage-ul 'runner' pornește tot de la 'node:24-alpine', setează 'NODE_ENV=production' și copiază doar artefactele de build ale aplicației în imaginea finală. Acest fișier este un șablon reutilizabil; fiecare aplicație își poate defini propriul Dockerfile care îl extinde sau îl copiază și setează APP_NAME corespunzător.",
    "directorul_directoarele": [
      "scripts/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.9: Directorul 'scripts/' există. F0.1.16: Tipurile pentru Node.js 24 sunt instalate. Stack-ul proiectului folosește Node.js 24 LTS.",
    "contextul_general_al_aplicatiei": "Standardizarea containerizării pentru toate aplicațiile (archify.app, vettify.app, etc.) folosind un șablon comun, aliniat la Node.js 24.",
    "contextualizarea_directoarelor_si_cailor": "Creează fișierul '/var/www/GeniusSuite/scripts/Dockerfile.base'.",
    "restrictii_anti_halcinatie": [
      "Creează fișierul 'scripts/Dockerfile.base' cu următorul conținut exact:",
      "# syntax=docker/dockerfile:1",
      "",
      "# Șablon multi-stage pentru aplicații Node.js 24 în monorepo Nx + pnpm",
      "ARG NODE_VERSION=24-alpine",
      "ARG APP_NAME",
      "",
      "FROM node:${NODE_VERSION} AS base",
      "WORKDIR /app",
      "",
      "ENV PNPM_HOME=/pnpm",
      "ENV PATH=\"$PNPM_HOME:$PATH\"",
      "RUN corepack enable",
      "",
      "FROM base AS builder",
      "",
      "# Copiem fișierele de lock și de workspace pentru a instala dependențele",
      "COPY pnpm-lock.yaml pnpm-workspace.yaml package.json ./",
      "RUN pnpm install --frozen-lockfile",
      "",
      "# Copiem restul monorepo-ului pentru a permite build-ul Nx",
      "COPY . .",
      "",
      "# Construim doar aplicația țintă folosind Nx; APP_NAME va fi trecut ca build-arg",
      "RUN pnpm exec nx build ${APP_NAME}",
      "",
      "FROM node:${NODE_VERSION} AS runner",
      "WORKDIR /app",
      "ENV NODE_ENV=production",
      "",
      "# Copiem artefactele de build ale aplicației în imaginea finală",
      "COPY --from=builder /app/dist/apps/${APP_NAME} ./dist",
      "",
      "# Punct de intrare implicit (pentru aplicații Node tip backend Nest/Express).",
      "# Aplicațiile individuale pot suprascrie CMD în propriile Dockerfile-uri.",
      "CMD [\"node\", \"dist/main.js\"]"
    ],
    "restrictii_de_iesire_din_contex": "Acesta este un fișier de bază/șablon. Nu este menit să fie construit direct. Aplicațiile individuale fie vor copia acest fișier, fie vor defini Dockerfile-uri proprii care folosesc aceeași structură și trec APP_NAME ca build-arg.",
    "validare": "Fișierul '/var/www/GeniusSuite/scripts/Dockerfile.base' există și conținutul său corespunde exact cu șablonul definit în 'restrictii_anti_halcinatie'.",
    "outcome": "Un șablon Dockerfile multi-stage standardizat, aliniat la Node.js 24, este disponibil pentru toate aplicațiile din monorepo.",
    "componenta_de_CI_CD": "Fundația pentru toți pașii de 'docker-build' (de ex. ținta Nx 'docker-build' din F0.2.19 și pipeline-urile de deploy din F0.2.20/F0.2.22)."
  }
},
```

#### F0.2.19

```JSON
  {
  "F0.2.19": {
    "denumire_task": "Adăugare Țintă (Target) 'docker-build' în 'nx.json'",
    "descriere_scurta_task": "Adaugă o țintă implicită 'docker-build' în 'targetDefaults' din 'nx.json'.",
    "descriere_lunga_si_detaliata_task": "Extindem configurația 'targetDefaults' din 'nx.json' (inițial definită în F0.1.13) cu o nouă intrare numită 'docker-build'. Această intrare nu definește executorul sau comanda (acestea vor fi configurate la nivel de proiect), ci doar comportamentul implicit: că 'docker-build' depinde de 'build', este cache-uit și folosește aceleași input-uri ca și celelalte ținte ('default' și '^default'). Astfel, atunci când aplicațiile vor avea o țintă 'docker-build' definită, vom putea folosi 'nx affected -t docker-build' în pipeline-uri pentru a construi imagini Docker doar pentru aplicațiile afectate.",
    "directorul_directoarele": [
      "/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.13: 'nx.json' și 'targetDefaults' există (build/lint/test). F0.2.18: 'scripts/Dockerfile.base' a fost creat.",
    "contextul_general_al_aplicatiei": "Integrarea build-urilor Docker în graful de task-uri Nx, cu suport pentru 'nx affected -t docker-build' și caching (inclusiv Nx Cloud).",
    "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/nx.json'.",
    "restrictii_anti_halcinatie": [
      "Deschide fișierul 'nx.json' de la rădăcină ('/var/www/GeniusSuite/nx.json').",
      "Găsește cheia de top-level 'targetDefaults'. Nu șterge și nu modifica intrările existente (de ex. 'build', 'lint', 'test').",
      "În interiorul obiectului 'targetDefaults', adaugă o nouă intrare pentru 'docker-build' cu următorul conținut:",
      "",
      "\"docker-build\": {",
      "  \"dependsOn\": [\"build\"],",
      "  \"cache\": true,",
      "  \"inputs\": [\"default\", \"^default\"]",
      "}",
      "",
      "Asigură-te că sintaxa JSON este validă: adaugă virgule doar acolo unde este necesar (de exemplu, între intrările 'build', 'lint', 'test' și noua intrare 'docker-build').",
      "Nu încerca să definești executorul sau comanda Docker aici; acestea vor fi configurate la nivel de proiect/target specific (de ex. în 'project.json' pentru aplicații), iar 'targetDefaults' doar definește comportamentul comun (depinde de 'build', cache/inputs)."
    ],
    "restrictii_de_iesire_din_contex": "Acest task extinde doar 'targetDefaults'; nu creează încă ținte 'docker-build' specifice aplicațiilor și nu modifică alte chei din 'nx.json'.",
    "validare": "'nx.json' conține cheia 'targetDefaults.docker-build' cu câmpurile 'dependsOn', 'cache' și 'inputs' setate exact ca în 'restrictii_anti_halcinatie'.",
    "outcome": "Nx este conștient de ținta implicită 'docker-build' (cu dependență de 'build', caching activat și input-uri corecte), permițând folosirea 'nx affected -t docker-build' în pipeline-urile de deploy.",
    "componenta_de_CI_CD": "Pregătește integrarea build-urilor Docker cu Nx și CI (de ex. în job-urile de deploy care vor rula 'nx affected -t docker-build')."
  }
},
```

#### F0.2.20

```JSON
  {
  "F0.2.20": {
    "denumire_task": "Creare Fișier Workflow 'deploy-staging.yml'",
    "descriere_scurta_task": "Creează 'deploy-staging.yml' pentru build și push al imaginilor de staging.",
    "descriere_lunga_si_detaliata_task": "Creăm un al treilea fișier workflow GitHub Actions. Acesta va fi responsabil pentru construirea imaginilor Docker pentru aplicațiile afectate și publicarea lor în container registry (de ex. GHCR) cu tag-ul 'staging'. Acest pipeline se declanșează la push pe branch-ul 'staging'. În acest task definim doar scheletul workflow-ului: nume, trigger și un job placeholder; pașii reali de build & push vor fi adăugați în F0.2.21.",
    "directorul_directoarele": [
      ".github/workflows/"
    ],
    "contextul_taskurilor_anterioare": "F0.2.1: Directorul '.github/workflows/' există. F0.2.19: Ținta 'docker-build' este definită în 'nx.json'.",
    "contextul_general_al_aplicatiei": "Definirea pipeline-ului de CD pentru mediul de staging, conform strategiei de branching (master, staging, dev).",
    "contextualizarea_directoarelor_si_cailor": "Creează sau suprascrie fișierul '/var/www/GeniusSuite/.github/workflows/deploy-staging.yml'.",
    "restrictii_anti_halcinatie": [
      "Creează sau suprascrie fișierul '.github/workflows/deploy-staging.yml' cu următorul conținut YAML minimal, valid:",
      "",
      "name: Deploy to Staging",
      "",
      "on:",
      "  push:",
      "    branches:",
      "      - staging",
      "",
      "jobs:",
      "  docker-deploy-staging:",
      "    name: Docker Build & Push (Staging)",
      "    runs-on: ubuntu-latest",
      "    steps:",
      "      - name: Placeholder",
      "        run: echo \"Skeleton deploy-staging.yml - pașii reali de build & push se adaugă în F0.2.21\"",
      "",
      "Nu adăuga în acest task pași de login la registry, build Docker sau 'nx affected -t docker-build'. Toți acești pași vor fi definiți explicit în F0.2.21."
    ],
    "restrictii_de_iesire_din_contex": "Nu adăuga încă pași de build, login sau deploy în acest workflow. Acest task trebuie să furnizeze doar scheletul valid al fișierului 'deploy-staging.yml'.",
    "validare": "Fișierul '.github/workflows/deploy-staging.yml' există, iar în UI-ul GitHub Actions workflow-ul 'Deploy to Staging' apare ca workflow valid, declanșat de push pe branch-ul 'staging'.",
    "outcome": "Scheletul pipeline-ului de deploy pentru staging este creat și valid, pregătit pentru a fi completat cu pași de build & push în F0.2.21.",
    "componenta_de_CI_CD": "Definește pipeline-ul de deploy pentru staging și îl conectează la strategia de branching (push pe 'staging')."
  }
},
```

#### F0.2.21

```JSON
  {
  "F0.2.21": {
    "denumire_task": "Completare Workflow 'deploy-staging.yml' (Build & Push)",
    "descriere_scurta_task": "Adaugă pașii de build și push Docker în 'deploy-staging.yml'.",
    "descriere_lunga_si_detaliata_task": "Completăm workflow-ul de staging. Adăugăm pașii necesari pentru: checkout, setup pnpm, install, setup Docker Buildx, login la GHCR și, cel mai important, rularea 'nx affected -t docker-build'. Vom seta baza comparației la 'origin/master' pentru a compara corect branch-ul 'staging' cu 'master'. Imaginile vor fi tag-uite cu 'staging' prin opțiunea '--tag-suffix=staging'.",
    "directorul_directoarele": [
      ".github/workflows/"
    ],
    "contextul_taskurilor_anterioare": "F0.2.19: Ținta 'docker-build' este definită în 'nx.json'. F0.2.20: Workflow-ul 'deploy-staging.yml' există deja cu scheletul (name/on/jobs).",
    "contextul_general_al_aplicatiei": "Automatizarea creării și publicării imaginilor Docker de staging (Continuous Deployment către mediul de staging) folosind graful Nx.",
    "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/.github/workflows/deploy-staging.yml'. Poți înlocui complet conținutul existent cu cel de mai jos pentru claritate.",
    "restrictii_anti_halucinatie": [
      "Înlocuiește conținutul fișierului '.github/workflows/deploy-staging.yml' cu YAML-ul complet de mai jos:",
      "",
      "name: Deploy to Staging",
      "",
      "on:",
      "  push:",
      "    branches:",
      "      - staging",
      "",
      "permissions:",
      "  contents: read",
      "  packages: write",
      "",
      "jobs:",
      "  docker-deploy-staging:",
      "    name: Docker Build & Push (Staging)",
      "    runs-on: ubuntu-latest",
      "    steps:",
      "      - name: Checkout repository",
      "        uses: actions/checkout@v4",
      "        with:",
      "          fetch-depth: 0  # necesar pentru a putea compara cu origin/master",
      "",
      "      - name: Setup Node.js",
      "        uses: actions/setup-node@v4",
      "        with:",
      "          node-version: 24",
      "",
      "      - name: Setup pnpm",
      "        uses: pnpm/action-setup@v2",
      "        with:",
      "          version: 8",
      "",
      "      - name: Setup pnpm cache",
      "        uses: actions/cache@v4",
      "        with:",
      "          path: ~/.pnpm-store",
      "          key: ${{ runner.os }}-pnpm-store-${{ hashFiles('**/pnpm-lock.yaml') }}",
      "          restore-keys: |",
      "            ${{ runner.os }}-pnpm-store-",
      "",
      "      - name: Install dependencies",
      "        run: pnpm install --frozen-lockfile",
      "",
      "      - name: Setup Docker Buildx",
      "        uses: docker/setup-buildx-action@v3",
      "",
      "      - name: Login to GHCR",
      "        uses: docker/login-action@v3",
      "        with:",
      "          registry: ghcr.io",
      "          username: ${{ github.actor }}",
      "          password: ${{ secrets.GITHUB_TOKEN }}",
      "",
      "      - name: Build & push Docker images for affected apps",
      "        env:",
      "          DOCKER_REGISTRY: ghcr.io/${{ github.repository_owner }}",
      "        run: |",
      "          pnpm exec nx affected -t docker-build --base=origin/master --head=HEAD -- --push --tag-with-ref --tag-suffix=staging",
      "",
      "Presupunem că ținta 'docker-build' din 'nx.json' (și/sau din 'project.json'-urile aplicațiilor) este configurată să citească variabila de mediu `DOCKER_REGISTRY` și să proceseze argumentele `--push`, `--tag-with-ref` și `--tag-suffix` transmise după `--`.",
      "Nu adăuga alți pași suplimentari în acest task (de ex. deploy pe Kubernetes sau alte medii). Acestea ar trebui tratate în task-uri separate, dacă vor exista."
    ],
    "restrictii_de_iesire_din_contex": "Nu modifica trigger-ul 'on.push.branches: [staging]'. Acest workflow trebuie să ruleze exclusiv la push pe branch-ul 'staging'. Nu adăuga aici logică de deploy în producție.",
    "validare": "Fă un push într-un branch 'staging' (sau un test simplu). În GitHub Actions, workflow-ul 'Deploy to Staging' trebuie să ruleze, să construiască și să încerce să publice imaginile Docker pentru proiectele afectate. Log-ul pasului 'Build & push Docker images for affected apps' trebuie să arate execuția comenzii 'nx affected -t docker-build'.",
    "outcome": "Pipeline-ul 'deploy-staging.yml' este complet și funcțional: la fiecare push pe 'staging', construiește și publică imaginile Docker doar pentru aplicațiile afectate, folosind Nx.",
    "componenta_de_CI_CD": "Pas cheie în CD (Continuous Deployment) către staging, bazat pe Nx affected + Docker Buildx + GHCR."
  }
},
```

#### F0.2.22

```JSON
  {
  "F0.2.22": {
    "denumire_task": "Creare Fișier Workflow 'deploy-prod.yml'",
    "descriere_scurta_task": "Creează 'deploy-prod.yml' pentru build și push al imaginilor de producție.",
    "descriere_lunga_si_detaliata_task": "Creăm fișierul final de workflow. Acesta va fi responsabil pentru construirea imaginilor Docker de producție. Un model robust este declanșarea acestuia 'on: release: types: [published]', adică după ce 'release.yml' a creat cu succes o nouă versiune (tag Git). În acest task definim doar scheletul workflow-ului: nume, trigger și un job de bază cu checkout; pașii de build & push Docker vor fi adăugați în F0.2.23.",
    "directorul_directoarele": [
      ".github/workflows/"
    ],
    "contextul_taskurilor_anterioare": "F0.2.17: Pipeline-ul 'release.yml' este definit și creează release-uri/tag-uri. F0.2.18–F0.2.21: există ținta 'docker-build' și pipeline-ul de staging.",
    "contextul_general_al_aplicatiei": "Definirea pipeline-ului de CD pentru producție, declanșat de un release oficial pe GitHub.",
    "contextualizarea_directoarelor_si_cailor": "Creează sau suprascrie fișierul '/var/www/GeniusSuite/.github/workflows/deploy-prod.yml'.",
    "restrictii_anti_halucinatie": [
      "Conținutul fișierului '.github/workflows/deploy-prod.yml' trebuie setat la următorul YAML minimal (schelet):",
      "",
      "name: Deploy to Production",
      "",
      "on:",
      "  release:",
      "    types: [published]",
      "",
      "permissions:",
      "  contents: read",
      "  packages: write",
      "",
      "jobs:",
      "  docker-deploy-prod:",
      "    name: Docker Build & Push (Production)",
      "    runs-on: ubuntu-latest",
      "    steps:",
      "      - name: Checkout repository",
      "        uses: actions/checkout@v4",
      "        with:",
      "          fetch-depth: 0  # pentru a avea istoric complet când vom adăuga pașii reali în F0.2.23",
      "",
      "Nu adăuga încă pași de setup Node/pnpm, Docker Buildx, login sau 'nx affected -t docker-build' în acest task; aceia vor fi tratați explicit în F0.2.23."
    ],
    "restrictii_de_iesire_din_contex": "Acest workflow trebuie să fie declanșat DOAR pe 'release.published'. Nu adăuga triggere de 'push' sau 'pull_request' aici. Nu adăuga încă pași de build/push imagini Docker.",
    "validare": "Fișierul '.github/workflows/deploy-prod.yml' există în repository și, în interfața GitHub Actions, workflow-ul 'Deploy to Production' apare listat ca workflow care se declanșează pe evenimentul 'Release · published'.",
    "outcome": "Scheletul pipeline-ului de deploy pentru producție este creat: există un workflow GitHub Actions declanșat la publicarea unui release.",
    "componenta_de_CI_CD": "Definește structura de bază a pipeline-ului de deploy pentru producție; F0.2.23 va adăuga logica de build & push."
  }
},
```

#### F0.2.23

```JSON
  {
  "F0.2.23": {
    "denumire_task": "Completare Workflow 'deploy-prod.yml' (Build & Push)",
    "descriere_scurta_task": "Adaugă pașii de build și push Docker în 'deploy-prod.yml', tag-uite cu versiunea release-ului.",
    "descriere_lunga_si_detaliata_task": "Completăm workflow-ul de producție definit în F0.2.22. Workflow-ul este declanșat pe evenimentul 'release.published' și trebuie să construiască și să publice imagini Docker pentru aplicațiile afectate, folosind ținta Nx 'docker-build'. Diferența cheie față de staging este tag-ul: imaginile vor fi tag-uite cu versiunea Git a release-ului (ex. 'v1.2.3'), disponibilă în 'github.ref_name'. Presupunem același contract ca în F0.2.21: ținta 'docker-build' citește DOCKER_REGISTRY și DOCKER_TAG (sau derivă tag-ul din contextul Git).",
    "directorul_directoarele": [
      ".github/workflows/"
    ],
    "contextul_taskurilor_anterioare": "F0.2.18: 'Dockerfile.base' există. F0.2.19: Ținta 'docker-build' este definită în 'nx.json'. F0.2.20–F0.2.21: Pipeline-ul de staging este complet. F0.2.22: 'deploy-prod.yml' există cu trigger-ul 'on: release: types: [published]' și job-ul 'docker-deploy-prod' care face checkout.",
    "contextul_general_al_aplicatiei": "Automatizarea creării artefactelor de producție (imagini Docker) aliniate cu release-urile oficiale (tag-uri Git).",
    "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/.github/workflows/deploy-prod.yml', completând job-ul 'docker-deploy-prod' cu pașii de setup și rulare 'nx affected -t docker-build'.",
    "restrictii_anti_halucinatie": [
      "În fișierul '.github/workflows/deploy-prod.yml' există deja scheletul definit în F0.2.22:",
      "  name: Deploy to Production",
      "  ",
      "  on:",
      "    release:",
      "      types: [published]",
      "  ",
      "  permissions:",
      "    contents: read",
      "    packages: write",
      "  ",
      "  jobs:",
      "    docker-deploy-prod:",
      "      name: Docker Build & Push (Production)",
      "      runs-on: ubuntu-latest",
      "      steps:",
      "        - name: Checkout repository",
      "          uses: actions/checkout@v4",
      "          with:",
      "            fetch-depth: 0",
      "",
      "În acest task ADĂUGĂ pașii NOI în cadrul job-ului 'docker-deploy-prod', DUPĂ pasul 'Checkout repository':",
      "",
      "      - name: Setup Node.js",
      "        uses: actions/setup-node@v4",
      "        with:",
      "          node-version: 24",
      "          cache: pnpm",
      "",
      "      - name: Setup pnpm",
      "        uses: pnpm/action-setup@v2",
      "        with:",
      "          version: 8",
      "",
      "      - name: Setup pnpm cache",
      "        uses: actions/cache@v4",
      "        with:",
      "          path: ~/.pnpm-store",
      "          key: ${{ runner.os }}-pnpm-store-${{ hashFiles('**/pnpm-lock.yaml') }}",
      "          restore-keys: |",
      "            ${{ runner.os }}-pnpm-store-",
      "",
      "      - name: Install dependencies",
      "        run: pnpm install --frozen-lockfile",
      "",
      "      - name: Set up Docker Buildx",
      "        uses: docker/setup-buildx-action@v3",
      "",
      "      - name: Log in to GitHub Container Registry",
      "        uses: docker/login-action@v3",
      "        with:",
      "          registry: ghcr.io",
      "          username: ${{ github.actor }}",
      "          password: ${{ secrets.GITHUB_TOKEN }}",
      "",
      "      - name: Build & push Docker images (production)",
      "        run: pnpm exec nx affected -t docker-build",
      "        env:",
      "          DOCKER_REGISTRY: ghcr.io/${{ github.repository_owner }}",
      "          DOCKER_TAG: ${{ github.ref_name }}",
      "",
      "Presupunem că ținta 'docker-build' (definită în 'nx.json' și/sau 'project.json') folosește DOCKER_REGISTRY și DOCKER_TAG pentru a construi și a împinge imaginile (de ex. nume_serve:DOCKER_TAG) și setează intern '--push'.",
      "Nu modifica blocul 'on:' sau numele job-ului; doar completează steps.",
      "Nu folosi un tag hardcodat (ex. 'latest' sau 'prod'); folosește exclusiv '${{ github.ref_name }}' ca semantic version (ex. 'v1.2.3')."
    ],
    "restrictii_de_iesire_din_contex": "Nu adăuga triggere suplimentare ('push', 'pull_request') în acest workflow. Acesta trebuie să ruleze DOAR pe 'release.published'. Nu suprascrie pașii definiți în F0.2.22 (checkout).",
    "validare": "Creează un release GitHub cu tag (ex. 'v1.2.3') pe 'master'. Verifică în GitHub Actions că workflow-ul 'Deploy to Production' pornește, rulează pașii de setup și 'pnpm exec nx affected -t docker-build', iar în GHCR apar imaginile pentru proiectele afectate tag-uite cu 'v1.2.3'.",
    "outcome": "Pipeline-ul de producție este complet: la fiecare release publicat, imaginile Docker pentru aplicațiile afectate sunt construite și împinse în GHCR cu tag-ul versiunii release-ului.",
    "componenta_de_CI_CD": "Pas cheie în CD (Continuous Deployment) către producție, legând direct release-urile semantice de imaginile Docker publicate."
  }
},
```

#### F0.2.24

```JSON
  {
    "F0.2.24": {
      "denumire_task": "Comisionare Artefacte F0.2 pe Branch-ul 'dev' și Creare PR/MR",
      "descriere_scurta_task": "Adaugă și comisionează toate fișierele de CI/CD (F0.2).",
      "descriere_lunga_si_detaliata_task": "Adăugăm toate fișierele noi și modificate din Faza F0.2. Aceasta include: '.github/workflows/ci.yml', '.github/workflows/release.yml', '.github/workflows/changeset-bot.yml', '.github/workflows/deploy-staging.yml', '.github/workflows/deploy-prod.yml', '.changeset/config.json', 'scripts/Dockerfile.base', 'package.json' (cu 'changesets' adăugat) și 'nx.json' (cu ținta 'docker-build'). Comisionăm totul pe 'dev' și pregătim un PR către 'master'.",
      "directorul_directoarele": [
        "/"
      ],
      "contextul_taskurilor_anterioare": "F0.2.1 - F0.2.23: Toate fișierele de configurare CI/CD au fost create și modificate.",
      "contextul_general_al_aplicatiei": "Finalizarea Fazei F0.2 și pregătirea pentru revizuirea infrastructurii de CI/CD.",
      "contextualizarea_directoarelor_si_cailor": "Comenzi Git executate la rădăcina '/var/www/GeniusSuite/'.",
      "restrictii_anti_halucinatie":,
      "restrictii_de_iesire_din_contex": "Nu face push. Doar comisionează local pe 'dev' și generează descrierea PR/MR.",
      "validare": "Execută 'git log -1'. Commit-ul trebuie să fie vizibil pe branch-ul 'dev'.",
      "outcome": "Toate artefactele F0.2 sunt comisionate local pe 'dev'.",
      "componenta_de_CI_CD": "Acest commit, odată împins și transformat în PR, va declanșa *pentru prima dată* pipeline-ul 'ci.yml'.",
      "PR_MR": {
        "sursa_branch": "dev",
        "destinatie_branch": "master",
        "titlu": "feat(ci): F0.2 - Implementare Pipeline CI/CD (Validation, Release, Docker)",
        "descriere": "Acest PR implementează Faza F0.2, stabilind fundația completă de CI/CD pentru monorepo, bazându-se pe F0.1.\n\n**Schimbări Cheie:**\n\n1.  **CI (Validare PR):**\n    *   S-a creat `.github/workflows/ci.yml`.\n    *   Se declanșează pe Pull Request-uri către `master`, `staging` și `dev`.\n    *   Configurează `pnpm` și caching-ul 'pnpm-store'.\n    *   Folosește `nrwl/nx-set-shas` pentru a detecta corect baza PR-ului.\n    *   Se conectează la Nx Cloud (remote cache).\n    *   Rulează 'nx affected' pentru `format:check`, `lint`, `test` și `build`.\n\n2.  **Versionare Semantică (Changesets):**\n    *   S-a instalat și configurat `@changesets/cli`.\n    *   S-a configurat `.changeset/config.json` pentru `baseBranch: \"master\"`.\n    *   S-a adăugat 'changeset-bot.yml' pentru a valida prezența changesets-urilor în PR-uri.\n\n3.  **CD (Publicare Pachete):**\n    *   S-a creat `.github/workflows/release.yml`, declanșat pe `push` la `master`.\n    *   Job-ul 'publish' validează (lint, test, build), apoi rulează `changeset version` și `pnpm publish -r`.\n    *   Necesită secretele `GH_PAT_TOKEN` (pentru push-ul de versionare) și `NPM_TOKEN` (pentru publicare).\n\n4.  **Containerizare (Docker):**\n    *   S-a creat un `scripts/Dockerfile.base` (multi-stage).\n    *   S-a adăugat o țintă implicită `docker-build` în `nx.json`.\n    *   S-a creat `deploy-staging.yml` (push la `staging`) care construiește și publică imagini `affected` pe GHCR cu tag-ul `staging`.\n    *   S-a creat `deploy-prod.yml` (declanșat `on: release: [published]`) care publică imagini `affected` pe GHCR cu tag-ul de versiune Git (ex. `v1.0.0`)."
      }
    }
  }
```

#### F0.3 Observabilitate (skeleton): OTEL collector, Prometheus, Grafana, Loki/Tempo skeleton + dashboards de bază

#### F0.3.1

```JSON
  {
  "F0.3.1": {
    "denumire_task": "Aliniere structură 'shared/observability' cu arhitectura",
    "descriere_scurta_task": "Creează (dacă lipsesc) subdirectoarele standard în 'shared/observability' conform planului de arhitectură, fără a introduce 'telemetry' și fără a muta logger-ul.",
    "descriere_lunga_si_detaliata_task": "Începem Faza F0.3 (Observabilitate) prin alinierea strictă la structura de directoare definită în capitolul de arhitectură. În loc să creăm un director neplanificat 'telemetry', acest task se asigură că subdirectoarele oficiale 'logs/', 'metrics/', 'traces/', 'dashboards/', 'alerts/', 'exporters/', 'otel-config/', 'compose/', 'scripts/' și 'docs/' există sub 'shared/observability/'. Logging-ul (Pino) rămâne în 'shared/common/logger/' conform arhitecturii, iar codul de instrumentare OpenTelemetry (traces, exporters, config) va fi plasat ulterior în subdirectoarele dedicate ('traces/', 'exporters/', 'otel-config/').",
    "directorul_directoarele": [
      "shared/observability/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.6: Structura de bază a fost creată, inclusiv directorul gol 'shared/observability/'. Acum aliniem subdirectoarele exacte la planul de arhitectură înainte de a adăuga cod de observabilitate.",
    "contextul_general_al_aplicatiei": "Sub-faza F0.3 presupune implementarea scheletului de observabilitate pentru toate modulele. Acest pas garantează că toate directoarele folosite ulterior (logs, metrics, traces, etc.) sunt conforme cu arhitectura și că nu apar directoare ad-hoc precum 'telemetry/'.",
    "contextualizarea_directoarelor_si_cailor": "Execută comanda:\n  mkdir -p /var/www/GeniusSuite/shared/observability/{logs,metrics,traces,dashboards,alerts,exporters,otel-config,compose,scripts,docs}",
    "restrictii_anti_halucinatie": [
      "NU crea directorul '/var/www/GeniusSuite/shared/observability/telemetry'. Acest director NU există în arhitectura oficială.",
      "NU muta și NU duplica configurarea logger-ului (Pino). Logger-ul comun rămâne în 'shared/common/logger/'.",
      "NU crea alte directoare în 'shared/observability/' în afara celor listate explicit: 'logs', 'metrics', 'traces', 'dashboards', 'alerts', 'exporters', 'otel-config', 'compose', 'scripts', 'docs'.",
      "Nu adăuga fișiere de cod în acest pas. Acest task este doar pentru structură de directoare."
    ],
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu introduce noi concepte de directoare (ex. 'telemetry') și nu redefini responsabilitățile deja stabilite (ex. nu muta logger-ul din 'shared/common/logger/').",
    "validare": "Verifică existența directoarelor:\n  /var/www/GeniusSuite/shared/observability/logs/\n  /var/www/GeniusSuite/shared/observability/metrics/\n  /var/www/GeniusSuite/shared/observability/traces/\n  /var/www/GeniusSuite/shared/observability/dashboards/\n  /var/www/GeniusSuite/shared/observability/alerts/\n  /var/www/GeniusSuite/shared/observability/exporters/\n  /var/www/GeniusSuite/shared/observability/otel-config/\n  /var/www/GeniusSuite/shared/observability/compose/\n  /var/www/GeniusSuite/shared/observability/scripts/\n  /var/www/GeniusSuite/shared/observability/docs/\nși absența directorului:\n  /var/www/GeniusSuite/shared/observability/telemetry/",
    "outcome": "Structura 'shared/observability' este aliniată 1:1 cu arhitectura proiectului, fără directoare neplanificate, pregătită pentru task-urile ulterioare (loguri, metrici, traces, exporters, etc.).",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.2

```JSON
  {
  "F0.3.2": {
    "denumire_task": "Creare structură pentru loguri în 'shared/observability/logs/'",
    "descriere_scurta_task": "Creează subdirectoarele de bază pentru loguri: 'ingestion/', 'parsers/', 'processors/', 'retention/', 'sinks/' și 'dashboards/' în 'shared/observability/logs/'.",
    "descriere_lunga_si_detaliata_task": "Conform planului de arhitectură, componenta de loguri este structurată pe mai multe subfoldere pentru a separa clar preocupările. Acest task creează următoarele subdirectoare sub 'shared/observability/logs/': 'ingestion/' (configurații de ingestie loguri, ex. Promtail sau colector OTEL), 'parsers/' (șabloane/definiții pentru parsarea logurilor, de ex. formate JSON sau regex pentru Traefik), 'processors/' (scripturi sau definiții de procesare a logurilor – ex. filtrare, redacție PII), 'retention/' (configurații privind retenția logurilor), 'sinks/' (configurații de destinație pentru loguri, ex. Loki) și 'dashboards/' (dashboard-uri Grafana specifice logurilor, distincte de dashboard-urile globale din 'shared/observability/dashboards/'). Această separare clară permite gestionarea și extinderea facilă a pipeline-ului de loguri.",
    "directorul_directoarele": [
      "shared/observability/logs/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.1: Structura 'shared/observability/' a fost aliniată cu arhitectura (logs/, metrics/, traces/, dashboards/, alerts/, exporters/, otel-config/, compose/, scripts/, docs/). Acum detaliem structura internă pentru componenta de loguri.",
    "contextul_general_al_aplicatiei": "Logurile aplicațiilor vor fi colectate centralizat (ex. folosind Loki) și vor fi prelucrate conform necesităților (ex. ștergere date sensibile). Structura creată acum urmărește guvernarea clară a fișierelor de configurare și a definițiilor legate de loguri.",
    "contextualizarea_directoarelor_si_cailor": "Execută comenzi de tip 'mkdir -p' pentru fiecare subdirector necesar, de exemplu:\n- mkdir -p /var/www/GeniusSuite/shared/observability/logs/ingestion\n- mkdir -p /var/www/GeniusSuite/shared/observability/logs/parsers\n- mkdir -p /var/www/GeniusSuite/shared/observability/logs/processors\n- mkdir -p /var/www/GeniusSuite/shared/observability/logs/retention\n- mkdir -p /var/www/GeniusSuite/shared/observability/logs/sinks\n- mkdir -p /var/www/GeniusSuite/shared/observability/logs/dashboards",
    "restrictii_anti_halucinatie": "Nu crea fișiere de configurare în aceste directoare în cadrul acestui task, doar directoarele în sine. Nu crea alte subdirectoare în afara celor specificate explicit.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu adăuga subdirectoare suplimentare și nu plasa aici cod de logger (Pino); logger-ul rămâne în 'shared/common/logger/'.",
    "validare": "Verifică faptul că toate cele 6 directoare ('ingestion/', 'parsers/', 'processors/', 'retention/', 'sinks/', 'dashboards/') există sub 'shared/observability/logs/'.",
    "outcome": "Structura de directoare pentru gestionarea logurilor centralizate este creată cu succes, conform planificării arhitecturale.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.3

```JSON
{
  "F0.3.3": {
    "denumire_task": "Creare structură pentru metrici în 'shared/observability/metrics/'",
    "descriere_scurta_task": "Creează subdirectoarele de bază pentru metrici: 'exporters/', 'recorders/', 'rules/' și 'dashboards/' în 'shared/observability/metrics/'.",
    "descriere_lunga_si_detaliata_task": "Se pregătește structura pentru componenta de metrici, similar cu cea de loguri. Sub 'shared/observability/metrics/' vom crea directoarele: 'exporters/' (configurații sau cod pentru exportul metricilor, ex. către Prometheus), 'recorders/' (cod care generează și înregistrează metrici personalizate în aplicații), 'rules/' (reguli de alertare sau de agregare/recording rules pentru Prometheus) și 'dashboards/' (dashboard-uri Grafana specifice metricilor, distincte de dashboard-urile globale din 'shared/observability/dashboards/'). Acest design urmează planul suitei pentru un stack complet de observabilitate (logs/metrics/traces), segregând clar resursele legate de metrici.",
    "directorul_directoarele": [
      "shared/observability/metrics/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.2: Structura pentru loguri este creată. Acum definim structura pentru metrici, asigurând paritatea organizării pentru toate componentele observabilității.",
    "contextul_general_al_aplicatiei": "Metricile aplicațiilor (ex. număr de request-uri, latențe, erori) vor fi colectate în Prometheus și vizualizate în Grafana. Structura creată permite definirea ușoară a metricilor suplimentare și a regulilor de alertare într-un mod centralizat.",
    "contextualizarea_directoarelor_si_cailor": "Execută comenzi 'mkdir -p' pentru a crea subdirectoarele:\n- mkdir -p /var/www/GeniusSuite/shared/observability/metrics/exporters\n- mkdir -p /var/www/GeniusSuite/shared/observability/metrics/recorders\n- mkdir -p /var/www/GeniusSuite/shared/observability/metrics/rules\n- mkdir -p /var/www/GeniusSuite/shared/observability/metrics/dashboards",
    "restrictii_anti_halucinatie": "Limitează-te la crearea acestor directoare. Nu crea altele sau fișiere de configurare la acest pas.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu adăuga subdirectoare în afara celor specificate; nu crea aici cod de observabilitate efectiv (recorders, exporters) încă.",
    "validare": "Verifică existența directoarelor 'exporters/', 'recorders/', 'rules/' și 'dashboards/' în 'shared/observability/metrics/'.",
    "outcome": "Structura de directoare pentru metrici este creată, pregătind terenul pentru configurarea colectării și vizualizării metricilor.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.4

```JSON
  {
  "F0.3.4": {
    "denumire_task": "Creare fișier de bază 'prometheus.yml' în 'shared/observability/otel-config/'",
    "descriere_scurta_task": "Creează un fișier minim 'prometheus.yml' în 'shared/observability/otel-config/' pentru configurarea instanței Prometheus.",
    "descriere_lunga_si_detaliata_task": "În loc să introducem un nou director neprevăzut în arhitectură ('shared/observability/prometheus/'), centralizăm configurarea instanței Prometheus în directorul existent 'shared/observability/otel-config/'. Acest task creează un fișier de bază 'prometheus.yml' cu o structură minimă (global scrape interval + un job placeholder). Reguli de alertare și recording rules pentru Prometheus NU se pun aici, ci în directorul deja definit 'shared/observability/metrics/rules/'.",
    "directorul_directoarele": [
      "shared/observability/otel-config/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.2: Structura pentru loguri este creată. F0.3.3: Structura pentru metrici este creată, inclusiv directorul 'metrics/rules/' pentru reguli Prometheus.",
    "contextul_general_al_aplicatiei": "Prometheus este baza de date de metrici a suitei. 'prometheus.yml' definește job-urile de scrape și parametrii globali, iar regulile (alerte, recording rules) sunt gestionate separat în 'shared/observability/metrics/rules/'.",
    "contextualizarea_directoarelor_si_cailor": "Creează fișierul '/var/www/GeniusSuite/shared/observability/otel-config/prometheus.yml'.",
    "restrictii_anti_halucinatie": [
      "Nu crea directorul 'shared/observability/prometheus/'.",
      "Creează doar fișierul '/var/www/GeniusSuite/shared/observability/otel-config/prometheus.yml'.",
      "Conținutul minim recomandat pentru fișier:",
      "global:",
      "  scrape_interval: 15s",
      "",
      "scrape_configs:",
      "  - job_name: 'placeholder'",
      "    static_configs:",
      "      - targets: ['localhost:9090']",
      "Nu adăuga aici reguli Prometheus; acestea vor fi definite în 'shared/observability/metrics/rules/'."
    ],
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu crea alte fișiere de config în acest pas (ex. rules files). Nu modifica încă docker-compose sau alte servicii care vor folosi acest fișier.",
    "validare": "Verifică existența fișierului '/var/www/GeniusSuite/shared/observability/otel-config/prometheus.yml' și faptul că are structura minimă 'global' + 'scrape_configs'.",
    "outcome": "Configurația de bază a instanței Prometheus este prezentă în 'shared/observability/otel-config/', aliniată cu arhitectura, iar regulile rămân centralizate în 'metrics/rules/'.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.5

```JSON
  {
  "F0.3.5": {
    "denumire_task": "Creare Director pentru Dashboard-urile Grafana de nivel global",
    "descriere_scurta_task": "Creează structura dedicată pentru dashboard-urile Grafana în `shared/observability/dashboards/grafana/`.",
    "descriere_lunga_si_detaliata_task": "Pentru a versiona și menține dashboard-urile Grafana în cod, în acord cu arhitectura existentă, stocăm definițiile acestora (fișiere JSON) în subdirectorul `grafana/` din `shared/observability/dashboards/`. Dashboard-urile de nivel global (ex. overview pentru întreaga suită, panouri cross-service) vor fi plasate în `shared/observability/dashboards/grafana/`. Dashboard-urile strict legate de loguri și metrici rămân în directoarele deja definite: `shared/observability/logs/dashboards/` și `shared/observability/metrics/dashboards/`.",
    "directorul_directoarele": [
      "shared/observability/dashboards/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.2: Structura pentru loguri, inclusiv `logs/dashboards/`, este creată. F0.3.3: Structura pentru metrici, inclusiv `metrics/dashboards/`, este creată. Acum adăugăm locația pentru dashboard-urile Grafana de nivel global conform structurii `shared/observability/dashboards/` definită în arhitectură.",
    "contextul_general_al_aplicatiei": "Grafana este instrumentul principal de vizualizare pentru metrici, loguri și trace-uri. Păstrarea dashboard-urilor în repozitoriu asigură reproducibilitatea mediului de observabilitate și un set de panouri predefinite pentru întreaga suită.",
    "contextualizarea_directoarelor_si_cailor": "Execută comanda `mkdir -p /var/www/GeniusSuite/shared/observability/dashboards/grafana` pentru a crea ierarhia necesară.",
    "restrictii_anti_halucinatie": [
      "Nu crea directorul `shared/observability/grafana/` la rădăcină.",
      "Creează DOAR calea `shared/observability/dashboards/grafana/`.",
      "Nu adăuga încă fișiere JSON de dashboard; acest task se limitează la structură."
    ],
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu crea subdirectoare suplimentare în acest pas (ex. `apps/`, `infra/`). Acestea pot fi introduse doar prin task-uri viitoare explicite.",
    "validare": "Verifică existența directorului `/var/www/GeniusSuite/shared/observability/dashboards/grafana/` în proiect.",
    "outcome": "Directorul corect pentru stocarea dashboard-urilor Grafana de nivel global este creat, în deplină concordanță cu arhitectura.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.6

```JSON
  {
  "F0.3.6": {
    "denumire_task": "Adăugare Dependențe OpenTelemetry și Prometheus Client",
    "descriere_scurta_task": "Instalează pachetele necesare în monorepo pentru observabilitate: OpenTelemetry (tracing), clientul Prometheus (metrici) și logger-ul Pino.",
    "descriere_lunga_si_detaliata_task": "Pentru a implementa codul de observabilitate, este necesară instalarea librăriilor relevante la nivel de workspace. Acest task adaugă următoarele pachete npm la dependențele monorepo-ului (în `package.json`-ul rădăcină, utilizând `pnpm` cu flag `-w`):\n- **OpenTelemetry SDK**: `@opentelemetry/api`, `@opentelemetry/sdk-node` (pentru inițializarea tracer-ului global), `@opentelemetry/auto-instrumentations-node` (pentru auto-instrumentare HTTP/DB etc.) și `@opentelemetry/exporter-trace-otlp-http` (exporter OTLP prin HTTP către colector).\n- **Prometheus client**: `prom-client` pentru expunerea metricilor aplicațiilor (endpoint `/metrics`).\n- **Logger**: `pino` pentru logare structurată și `pino-pretty` pentru formatat logurile în mediul de dezvoltare.\nInstalarea se face cu versiuni stabile compatibile cu Node 24 LTS. Comanda `pnpm add` va actualiza automat și `pnpm-lock.yaml`.",
    "directorul_directoarele": [
      "/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.2 și F0.3.3: Structurile de foldere pentru loguri și metrici au fost create. F0.3.5: Există structura pentru dashboard-urile Grafana de nivel global. Înainte de a scrie codul de instrumentare și configurare, trebuie să avem la dispoziție pachetele third-party necesare.",
    "contextul_general_al_aplicatiei": "Suitei GeniusERP i se adaugă capabilități de observabilitate la nivel de cod. OpenTelemetry va fi folosit pentru trasabilitate distribuită, Prometheus pentru metrici și Pino pentru logare structurată. Aceste biblioteci trebuie incluse ca dependențe pentru a putea fi folosite ulterior în implementare.",
    "contextualizarea_directoarelor_si_cailor": "Execută în directorul rădăcină al monorepo-ului (`/var/www/GeniusSuite/`) comanda:\n`pnpm add -w @opentelemetry/api @opentelemetry/sdk-node @opentelemetry/auto-instrumentations-node @opentelemetry/exporter-trace-otlp-http prom-client pino pino-pretty`",
    "restrictii_anti_halucinatie": "Nu instala alte pachete în afara celor listate explicit în acest task. Nu modifica alte câmpuri din `package.json` în afară de secțiunea de dependențe actualizată de `pnpm add`.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu executa configurări sau inițializări ale acestor pachete în acest pas; doar asigură-te că sunt disponibile ca dependențe. Configurația propriu-zisă OTEL/Prometheus/Pino va fi tratată în task-uri ulterioare.",
    "validare": "Verifică în `package.json` de la rădăcină că pachetele `@opentelemetry/api`, `@opentelemetry/sdk-node`, `@opentelemetry/auto-instrumentations-node`, `@opentelemetry/exporter-trace-otlp-http`, `prom-client`, `pino` și `pino-pretty` apar în secțiunea de dependențe. Asigură-te că ieșirea comenzii `pnpm add` nu conține erori.",
    "outcome": "Dependențele necesare observabilității (OpenTelemetry, Prometheus client, Pino) sunt instalate în proiect și pregătite pentru a fi utilizate în codul de instrumentare.",
    "componenta_de_CI_CD": "Aceste dependențe vor fi preluate automat în pașii de instalare din pipeline-urile de CI/CD; nu este necesară o configurare suplimentară în workflow-uri."
  }
},
```

#### F0.3.7

```JSON
  {
  "F0.3.7": {
    "denumire_task": "Implementare Modul de Tracing în `traces/otel.ts`",
    "descriere_scurta_task": "Implementează fișierul `otel.ts` în `shared/observability/traces/` pentru inițializarea OpenTelemetry (traces) la pornirea aplicațiilor.",
    "descriere_lunga_si_detaliata_task": "Se creează modulul central de configurare a trasabilității distribuite folosind OpenTelemetry. În `shared/observability/traces/otel.ts` vom scrie codul care:\n- Configurează un `NodeSDK` OpenTelemetry cu resurse implicite (ex. `service.name` setat dinamic la numele aplicației) și cu exporter OTLP către colectorul OTEL (URL-ul va fi preluat din variabila de mediu `OTEL_EXPORTER_OTLP_ENDPOINT`, de ex. `http://otel-collector:4318`).\n- Activează instrumentările automate (prin `@opentelemetry/auto-instrumentations-node`) pentru HTTP (și alte componente standard) astfel încât request-urile și interacțiunile I/O să fie capturate fără cod boilerplate în fiecare serviciu.\n- Inițializează SDK-ul global astfel încât toate modulele suitei să trimită trace-urile către colector.\nAcest modul va fi importat și invocat în fiecare serviciu la pornire, asigurând că trasabilitatea (span-uri) este activă peste tot.",
    "directorul_directoarele": [
      "shared/observability/traces/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.2 și F0.3.3: Structurile pentru loguri și metrici sunt create în `shared/observability/logs/` și `shared/observability/metrics/`. F0.3.6: Pachetele OpenTelemetry necesare (SDK, exporter, auto-instrumentations) sunt instalate la rădăcină.",
    "contextul_general_al_aplicatiei": "Implementarea tracing-ului distribuit permite corelarea evenimentelor între modulele suitei. Conform arhitecturii, folosim un colector OTEL central, deci fiecare serviciu trebuie să trimită trace-urile către acesta printr-o inițializare comună.",
    "contextualizarea_directoarelor_si_cailor": "Creează/editează fișierul `/var/www/GeniusSuite/shared/observability/traces/otel.ts` și implementează logica descrisă:\n- Importă `NodeSDK` din `@opentelemetry/sdk-node`, `Resource` și `SemanticResourceAttributes` din `@opentelemetry/resources` (dacă este necesar), exporter-ul OTLP HTTP și `getNodeAutoInstrumentations` din `@opentelemetry/auto-instrumentations-node`.\n- Construiește un `Resource` cu `service.name` citit dintr-o variabilă de mediu (ex. `OTEL_SERVICE_NAME`) cu fallback rezonabil.\n- Creează un `NodeSDK` care folosește acest `Resource`, exporter-ul OTLP și auto-instrumentările.\n- Expune o funcție simplă, de ex. `startOtel()` care pornește SDK-ul (și opțional o funcție `shutdownOtel()` pentru oprire grațioasă).",
    "restrictii_anti_halucinatie": [
      "Nu plasa fișierul în `shared/observability/telemetry/`. Locația corectă este `shared/observability/traces/otel.ts`.",
      "Folosește doar pachetele deja instalate în F0.3.6: `@opentelemetry/api`, `@opentelemetry/sdk-node`, `@opentelemetry/auto-instrumentations-node`, `@opentelemetry/exporter-trace-otlp-http`.",
      "Structură minimă (schelet TypeScript) sugerată:",
      \"import { NodeSDK } from '@opentelemetry/sdk-node';\",
      \"import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';\",
      \"import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';\",
      \"import { Resource } from '@opentelemetry/resources';\",
      \"import { SemanticResourceAttributes } from '@opentelemetry/semantic-conventions';\",
      \"const serviceName = process.env.OTEL_SERVICE_NAME ?? 'genius-suite-service';\",
      \"const resource = new Resource({ [SemanticResourceAttributes.SERVICE_NAME]: serviceName });\",
      \"const traceExporter = new OTLPTraceExporter({ url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT ?? 'http://otel-collector:4318/v1/traces' });\",
      \"export const sdk = new NodeSDK({ resource, traceExporter, instrumentations: [getNodeAutoInstrumentations()] });\",
      \"export async function startOtel() { await sdk.start(); }\"
    ],
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu adăuga instrumentări specifice unei aplicații (span-uri custom, logica de business) în acest modul. Aici definim doar setup-ul generic OTEL reutilizabil.",
    "validare": "Rulează `pnpm build` la rădăcină și asigură-te că nu există erori de tipare sau import. Opțional, pornește unul dintre servicii importând `startOtel()` la bootstrap și verifică în colector/Jaeger/Tempo că apar span-uri.",
    "outcome": "Fișierul `shared/observability/traces/otel.ts` este implementat și oferă un punct unic de inițializare a tracing-ului distribuit pentru toate serviciile suitei.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.8

```JSON
  {
  "F0.3.8": {
    "denumire_task": "Implementare Modul de Logging în `shared/common/logger/pino.ts`",
    "descriere_scurta_task": "Implementează fișierul `pino.ts` în `shared/common/logger/` pentru configurarea logger-ului (Pino) uniform în toate serviciile.",
    "descriere_lunga_si_detaliata_task": "Se creează modulul comun de logging bazat pe Pino, astfel încât toate serviciile să folosească același format de logare. În `shared/common/logger/pino.ts` implementăm o funcție/utilitar care:\n- Inițializează un logger Pino cu format JSON compact, potrivit pentru agregare în Loki/ELK (fără culori sau formatare greu de parsat).\n- Include în fiecare mesaj de log un identificator de corelație (de exemplu `traceId` sau `spanId` din contextul OTEL curent), pentru a lega log-urile de trace-uri.\n- Permite configurarea dinamică a nivelului de log (`LOG_LEVEL`) și, opțional, activarea unui prettifier doar în medii de development.\nAcest modul va fi punctul unic de adevăr pentru logging și va fi re-exportat prin `shared/common/logger/index.ts`, conform arhitecturii.",
    "directorul_directoarele": [
      "shared/common/logger/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.x: Structura `shared/common/logger/` (inclusiv `pino.ts`, `formatters.ts`, `index.ts`) este definită în arhitectură. F0.3.6: Pachetul `pino` (și eventual `pino-pretty`) este instalat la rădăcină. F0.3.7: Tracing-ul OTEL este configurat în `shared/observability/traces/otel.ts`, permițând corelarea logurilor cu `traceId`.",
    "contextul_general_al_aplicatiei": "Logurile consistente și corelate cu trace-urile sunt esențiale pentru depanare. Conform arhitecturii, logger-ul comun trăiește în `shared/common/logger/` și este folosit de toate aplicațiile backend.",
    "contextualizarea_directoarelor_si_cailor": "Creează/editează fișierul `/var/www/GeniusSuite/shared/common/logger/pino.ts`. În acest fișier:\n- Importă `pino`.\n- Citește `LOG_LEVEL` (cu fallback la `info`) și o variabilă de mediu pentru modul de rulare (ex. `NODE_ENV`).\n- Configurează instanța principală Pino pentru producție să logheze JSON simplu către stdout.\n- Opțional, în mediu de dev, activează prettifier-ul (`pino-pretty`).\n- Integrează contextul OTEL (dacă este disponibil) pentru a atașa `traceId` în log (ex. printr-o funcție helper care creează un `child logger` cu câmpul `traceId`).\n- Exportă fie direct instanța de logger, fie o funcție `createLogger(context?: object)` care atașează metadate suplimentare.",
    "restrictii_anti_halucinatie": [
      "Nu plasa fișierul în `shared/observability/telemetry/`. Locația corectă este `shared/common/logger/pino.ts`.",
      "Nu introduce logică de business în modulul de logging; păstrează-l generic și reutilizabil.",
      "Nu scrie direct din acest modul către Loki/Promtail/ELK; logger-ul scrie la stdout, iar pipeline-ul de loguri se ocupă de colectare.",
      "Corelarea cu OTEL trebuie să fie opțională și defensivă: dacă nu există context OTEL, logurile trebuie să funcționeze în continuare fără erori.",
      "Respectă structura arhitecturală: acest modul este folosit de restul suitei prin `shared/common/logger/index.ts`."
    ],
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu crea aici alte fișiere (ex. `formatters.ts`, `index.ts`) – acestea vor fi tratate în task-uri separate. Nu modifică framework-urile (Fastify/Express) la acest pas, doar expune logger-ul.",
    "validare": "Importă logger-ul într-un mic script de test (ex. `apps/api-gateway/src/main.ts`), loghează câteva mesaje și verifică că apar în consolă în format JSON corect, respectând `LOG_LEVEL`. Opțional, dacă tracing-ul OTEL este activ, verifică apariția câmpului `traceId` în loguri.",
    "outcome": "Fișierul `shared/common/logger/pino.ts` este implementat și furnizează un logger standardizat pentru toate modulele backend, aliniat cu arhitectura proiectului.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.9

```JSON
  {
  "F0.3.9": {
    "denumire_task": "Implementare Modul de Metrici în `metrics/recorders/prometheus.ts`",
    "descriere_scurta_task": "Implementează fișierul `prometheus.ts` în `shared/observability/metrics/recorders/` pentru expunerea metricilor Prometheus în aplicații.",
    "descriere_lunga_si_detaliata_task": "Pentru a permite colectarea metricilor de către Prometheus, fiecare serviciu va expune un endpoint `/metrics`. În `shared/observability/metrics/recorders/prometheus.ts` implementăm un modul care:\n- Initializează clientul Prometheus (`prom-client`) global, apelând `collectDefaultMetrics()` pentru a aduna metricile de bază Node.js (CPU, memorie, event loop etc.).\n- Furnizează o funcție (sau middleware) care, integrată în serverul web al fiecărei aplicații, răspunde la cereri HTTP pe calea `/metrics` cu metricile în format text (formatul de expunere al Prometheus).\n- Permite înregistrarea ușoară a unor metrici personalizate (ex. counteri, histograme) prin exportarea obiectelor corespunzătoare din `prom-client` (sau helperi pentru a le crea consistent).\nAcest modul va fi importat și utilizat în initializer-ul fiecărui API, astfel încât metricile devin disponibile imediat ce serviciul pornește.",
    "directorul_directoarele": [
      "shared/observability/metrics/recorders/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.3: A fost creată structura `shared/observability/metrics/` (inclusiv `recorders/`). F0.3.6: Biblioteca `prom-client` este instalată în monorepo.",
    "contextul_general_al_aplicatiei": "Monitorizarea metricilor (CPU, memorie, RPS, erori HTTP etc.) este o componentă cheie a observabilității. Acest modul oferă un punct unic de integrare cu Prometheus pentru toate serviciile backend.",
    "contextualizarea_directoarelor_si_cailor": "Creează fișierul `/var/www/GeniusSuite/shared/observability/metrics/recorders/prometheus.ts`. În el:\n- Importă `prom-client`.\n- Apelează `promClient.collectDefaultMetrics({ register: promClient.register })` (opțional cu un prefix comun pentru suiteă).\n- Exportă un helper (de exemplu `export function registerMetricsRoute(app) { ... }`) care configurează ruta `/metrics` pe serverul folosit (Fastify, Express etc.), răspunzând cu `promClient.register.metrics()` și `Content-Type: text/plain; version=0.0.4`.\n- Exportă și referințe utile (`promClient`, `promClient.register`) pentru definirea de metrici custom în alte module.\n- Asigură-te că inițializarea este idempotentă (nu înregistrează metrici de mai multe ori dacă modulul este importat de mai multe ori).",
    "restrictii_anti_halucinatie": [
      "Nu crea fișierul direct în `shared/observability/metrics/`; locația corectă este `shared/observability/metrics/recorders/prometheus.ts`.",
      "Nu implementa aici metrici de business specifice (financiare, domeniu etc.); acest modul se ocupă de setup-ul generics și mecanismul de expunere.",
      "Nu porni un server HTTP separat pentru `/metrics`; folosește serverul deja existent al aplicației.",
      "Fă inițializarea `collectDefaultMetrics` idempotentă (evită înregistrarea dublă a acelorași metrici)."
    ],
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu modifica alte fișiere de configurare (Prometheus, docker-compose) în acest pas. Nu adăuga rute suplimentare în afara `/metrics`.",
    "validare": "Integrează modulul într-un serviciu (ex. API-ul principal), pornește serviciul în modul dev și accesează `/metrics`. Ar trebui să vezi un output text cu metricile default (de ex. `process_cpu_user_seconds_total`). Asigură-te că nu apar erori în consola aplicației la import/init.",
    "outcome": "Fișierul `metrics/recorders/prometheus.ts` este implementat și furnizează un mecanism standardizat pentru ca toate serviciile să expună metrici pentru Prometheus.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.10

```JSON
  {
  "F0.3.10": {
    "denumire_task": "Creare Fișier de Export `index.ts` pentru Pachetul Observability",
    "descriere_scurta_task": "Creează `index.ts` în `shared/observability/` pentru a exporta centralizat modulele de tracing și metrici.",
    "descriere_lunga_si_detaliata_task": "Pentru a facilita importurile din pachetul comun de observabilitate (`@genius-suite/observability`), se adaugă un fișier `index.ts` la rădăcina `shared/observability/` care re-exportă componentele principale, din locațiile corecte din punct de vedere arhitectural:\n- Modulul de tracing OpenTelemetry din `traces/otel.ts`.\n- Modulul de metrici Prometheus din `metrics/recorders/prometheus.ts`.\nLogger-ul Pino NU este exportat de aici; el aparține pachetului `shared/common/logger` și va avea propriul său `index.ts` în acel pachet. În urma acestui task, aplicațiile vor putea utiliza importuri de forma `import { initTracing, initMetrics } from '@genius-suite/observability';` fără să cunoască structura internă a directorului.",
    "directorul_directoarele": [
      "shared/observability/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.7: Modulul de tracing OTEL a fost implementat în `shared/observability/traces/otel.ts`. F0.3.9: Modulul de metrici Prometheus a fost implementat în `shared/observability/metrics/recorders/prometheus.ts`. F0.3.8: Logger-ul Pino a fost implementat în `shared/common/logger/pino.ts` și nu aparține acestui pachet.",
    "contextul_general_al_aplicatiei": "Standardizarea importurilor pentru observabilitate crește lizibilitatea și reduce cuplarea la structura internă a directoarelor. Conform convenției monorepo, fiecare librărie are un fișier de intrare (`index.ts`) care definește API-ul public al modulului.",
    "contextualizarea_directoarelor_si_cailor": "Creează/editează fișierul `/var/www/GeniusSuite/shared/observability/index.ts` și adaugă următorul conținut:\n```ts\nexport * from './traces/otel';\nexport * from './metrics/recorders/prometheus';\n```\nAsigură-te că aceste căi corespund exact fișierelor implementate anterior în F0.3.7 și F0.3.9.",
    "restrictii_anti_halucinatie": [
      "Nu exporta logger-ul Pino din acest fișier; el aparține pachetului `shared/common/logger`.",
      "Nu folosi căi bazate pe directorul `telemetry/`; acesta nu există în arhitectura finală. Folosește doar `./traces/otel` și `./metrics/recorders/prometheus`.",
      "Nu adăuga logică de inițializare în `index.ts`; acesta este strict un fișier de re-export."
    ],
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu crea sau muta alte fișiere în acest task. Presupune că `traces/otel.ts` și `metrics/recorders/prometheus.ts` există deja și doar le re-exportă.",
    "validare": "Rulează `pnpm build` la rădăcina monorepo-ului și verifică faptul că nu apar erori de tip „Cannot find module './traces/otel'” sau similare. Opțional, într-un serviciu, testează un import de tip `import { initTracing } from '@genius-suite/observability';` pentru a verifica rezolvarea corectă a modulului.",
    "outcome": "Pachetul `@genius-suite/observability` are un punct unic de acces (`shared/observability/index.ts`) care expune modulele de tracing și metrici din locațiile corecte, aliniat cu arhitectura proiectului.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.11

```JSON
  {
  "F0.3.11": {
    "denumire_task": "Creare Fișier Docker Compose pentru Observabilitate (profil dev)",
    "descriere_scurta_task": "Creează fișierul `compose.dev.yml` în `shared/observability/compose/profiles/`, care va defini serviciile stack-ului de observabilitate pentru mediul de dezvoltare.",
    "descriere_lunga_si_detaliata_task": "Vom configura componentele de observabilitate (OTEL Collector, Prometheus, Grafana, Loki, Tempo etc.) ca servicii Docker Compose. Acest task inițiază fișierul de orchestrare dedicat profilului de dezvoltare: `shared/observability/compose/profiles/compose.dev.yml`. Fișierul va fi ulterior completat cu definiția containerelor și a setărilor necesare pentru fiecare componentă din stack. În acest pas creăm fișierul și îi adăugăm un schelet YAML minimal, conform structurii planificate în arhitectură.",
    "directorul_directoarele": [
      "shared/observability/compose/profiles/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.10: Pachetul de cod observability este gata. Structura `shared/observability/compose/` este definită în arhitectură, incluzând subdirectorul `profiles/` pentru fișierele Compose specifice profilului (dev/staging/prod).",
    "contextul_general_al_aplicatiei": "Modelul de orchestrare este hibrid: fiecare aplicație are un Compose propriu, iar la nivel de suită există un Compose orchestrator. Componentele de observabilitate, fiind comune, sunt definite într-un fișier Compose separat pentru profilul de dev, care poate fi inclus sau suprapus peste orchestrarea principală.",
    "contextualizarea_directoarelor_si_cailor": "Creează directorul `/var/www/GeniusSuite/shared/observability/compose/profiles/` dacă nu există deja. Apoi creează fișierul `/var/www/GeniusSuite/shared/observability/compose/profiles/compose.dev.yml` și adaugă un schelet YAML minimal, de exemplu:\n```yaml\nversion: '3.9'\n\nservices: {}\n```\nAcest lucru asigură că fișierul este YAML valid și pregătit pentru a fi extins în task-urile următoare.",
    "restrictii_anti_halucinatie": [
      "Nu defini încă servicii concrete în `compose.dev.yml` (nu adăuga încă OTEL Collector, Prometheus, Grafana etc.).",
      "Nu crea fișierul `compose.dev.yml` direct în `shared/observability/compose/`; folosește obligatoriu subdirectorul `profiles/`, conform arhitecturii.",
      "Nu crea încă fișiere pentru alte profiluri (staging/prod) în acest task."
    ],
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Limitează-te la structură minimă (version + services gol). Nu adăuga volume, rețele sau environment variables în acest pas.",
    "validare": "Verifică faptul că fișierul există la calea `/var/www/GeniusSuite/shared/observability/compose/profiles/compose.dev.yml` și că `docker compose -f shared/observability/compose/profiles/compose.dev.yml config` rulează fără erori de sintaxă.",
    "outcome": "Fișierul de orchestrare `compose.dev.yml` este creat în locația corectă (`compose/profiles/`), pregătit pentru definirea serviciilor de observabilitate în mediul de dezvoltare.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.12

```JSON
  {
  "F0.3.12": {
    "denumire_task": "Definire Rețea Docker 'observability' în Compose (profil dev)",
    "descriere_scurta_task": "Adaugă în `compose.dev.yml` (profil dev) definirea unei rețele Docker dedicate observabilității (ex. `observability`) la care vor adera componentele și aplicațiile.",
    "descriere_lunga_si_detaliata_task": "Pentru a permite comunicarea între serviciile de observabilitate și aplicații, creăm o rețea Docker izolată numită `observability`. În fișierul `shared/observability/compose/profiles/compose.dev.yml`, adaugă o secțiune `networks:` la sfârșit, definind rețeaua `observability`. Această rețea va fi folosită de containerul OTEL Collector, Prometheus, Grafana, Loki, Tempo etc., precum și de containerele aplicațiilor (care vor fi atașate la rețea prin propriile lor fișiere Compose). Rețeaua va fi de tip `bridge`, cu un nume explicit (ex. `geniuserp_observability`) pentru a evita conflictele și a permite referința din Compose-urile aplicațiilor.",
    "directorul_directoarele": [
      "shared/observability/compose/profiles/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.11: A fost creat fișierul `shared/observability/compose/profiles/compose.dev.yml` cu scheletul YAML de bază (version + services). Acum definim infrastructura de rețea necesară înainte de a adăuga serviciile concrete.",
    "contextul_general_al_aplicatiei": "Conform arhitecturii Docker Compose hibride, rețelele partajate (edge, internal, observability) sunt pre-definite pentru a lega containerele între ele. Rețeaua `observability` va izola traficul de telemetrie și va permite componentelor precum Prometheus sau OTEL Collector să comunice cu serviciile monitorizate.",
    "contextualizarea_directoarelor_si_cailor": "Deschide fișierul `/var/www/GeniusSuite/shared/observability/compose/profiles/compose.dev.yml` și adaugă la sfârșit blocul:\n```yaml\nnetworks:\n  observability:\n    name: geniuserp_observability\n    driver: bridge\n```\nDacă în fișier există deja o secțiune `networks:`, adaugă doar intrarea `observability` în acea secțiune.",
    "restrictii_anti_halucinatie": [
      "Nu defini alte rețele în afara `observability` în acest task.",
      "Nu schimba driver-ul default (`bridge`).",
      "Nu marca încă rețeaua ca `external`; acest detaliu se poate decide ulterior, la integrarea cu Compose-urile aplicațiilor."
    ],
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Limitează-te la definirea rețelei. Nu atașa încă serviciile la rețeaua `observability` în acest pas – acest lucru se va face când definești servicii concrete (OTEL Collector, Prometheus, Grafana etc.).",
    "validare": "Rulează `docker compose -f shared/observability/compose/profiles/compose.dev.yml config` și verifică faptul că ieșirea include secțiunea `networks` cu intrarea `observability` și că nu există erori de sintaxă.",
    "outcome": "Rețeaua Docker `observability` este definită în config-ul Compose pentru profilul de dev, gata să fie folosită de serviciile de observabilitate și de aplicațiile monitorizate.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.13

```JSON
  {
  "F0.3.13": {
    "denumire_task": "Creare Configurație OpenTelemetry Collector (`otel-collector-config.yml`)",
    "descriere_scurta_task": "Adaugă fișierul de configurare pentru OTEL Collector (`otel-collector-config.yml`) în `shared/observability/otel-config/` pentru definirea pipeline-urilor de trace-uri.",
    "descriere_lunga_si_detaliata_task": "Pentru a inițializa OpenTelemetry Collector-ul, avem nevoie de un fișier de configurare YAML care să specifice ce date colectează și unde le trimite. Vom crea fișierul `otel-collector-config.yml` în directorul `shared/observability/otel-config/`, conținând cel puțin:\n- **Receivere**: configurare pentru a primi date OTLP pe protocol gRPC (port 4317) și HTTP (port 4318) pentru traces. Aceste receivere permit primirea span-urilor trimise de serviciile noastre.\n- **Exportere**: configurare pentru a trimite mai departe datele către Tempo (pentru traces) prin OTLP gRPC către adresa `tempo:4317`.\n- **Procesor**: un procesor `batch` pentru a grupa și optimiza trimiterea datelor.\n- **Pipeline**: definirea unui pipeline de `traces` care leagă receiver-ul OTLP de exporter-ul Tempo (prin procesorul `batch`). Astfel, orice trace primit de colector va fi trimis către Tempo pentru stocare.\nConfig-ul poate rămâne minimalist la acest stadiu, urmând să fie extins pe măsură ce adăugăm procesări sau alte tipuri de date.",
    "directorul_directoarele": [
      "shared/observability/otel-config/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.12: Rețeaua de observabilitate este definită în Compose (profil dev). Acum pregătim configurația necesară primului serviciu din stack: OTEL Collector-ul.",
    "contextul_general_al_aplicatiei": "OpenTelemetry Collector centralizează datele de telemetrie (traces, logs, metrici) și le rutează către backend-urile de stocare (Tempo, Loki, Prometheus etc.). Conform design-ului, Collector-ul va primi trace-urile de la aplicații și le va trimite către Tempo (stack-ul Grafana pentru traces). Această configurație realizează legătura între microservicii și sistemul de stocare a trasabilității.",
    "contextualizarea_directoarelor_si_cailor": "Creează fișierul `/var/www/GeniusSuite/shared/observability/otel-config/otel-collector-config.yml`. În interior, adaugă conținut YAML, de exemplu:\n```yaml\nreceivers:\n  otlp:\n    protocols:\n      http:\n      grpc:\nexporters:\n  otlp/tempo:\n    endpoint: \"tempo:4317\"\nprocessors:\n  batch:\nservice:\n  pipelines:\n    traces:\n      receivers: [otlp]\n      processors: [batch]\n      exporters: [otlp/tempo]\n```\nAceasta configurează minimal colectorul să accepte orice trace pe protocoalele standard OTLP și să le trimită către serviciul Tempo. Asigură-te că indentarea YAML este corectă.",
    "restrictii_anti_halucinatie": [
      "Nu activa deocamdată metrici sau loguri prin collector; metricile sunt colectate direct cu Prometheus, iar logurile prin Promtail.",
      "Nu adăuga alți exporteri sau receivere în afara celor menționate (OTLP input, Tempo output) la acest pas.",
      "Păstrează config-ul cât mai simplu; extensiile (procesori suplimentari, alți exporteri) vor fi adăugate în task-uri ulterioare dacă este nevoie."
    ],
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Menține configurația la nivel de skeleton. Nu inventa alte fișiere de config aici (pentru aplicații individuale); acestea vor intra în subfolderele `apps/` conform arhitecturii.",
    "validare": "Poți valida sintaxa rulând containerul OTEL Collector local cu acest fișier (ex. `otelcol --dry-run -c otel-collector-config.yml` în interiorul imaginii) sau, odată integrat în Compose, verificând log-urile la pornirea containerului OTEL (nu trebuie să apară erori de config).",
    "outcome": "Fișierul de configurare pentru OpenTelemetry Collector este creat în `shared/observability/otel-config/`, definind pipeline-ul de bază pentru preluarea trasabilității și transmiterea către Tempo.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.14

```JSON
  {
  "F0.3.14": {
    "denumire_task": "Adăugare Serviciu OTEL Collector în `compose.dev.yml`",
    "descriere_scurta_task": "Configurează serviciul Docker `otel-collector` în fișierul de Compose dev, folosind imaginea OpenTelemetry Collector și fișierul de configurare creat.",
    "descriere_lunga_si_detaliata_task": "Introducem în `shared/observability/compose/profiles/compose.dev.yml` primul serviciu din stack-ul de observabilitate: OTEL Collector. Vom adăuga sub secțiunea `services:` un serviciu numit `otel-collector`, cu următoarele atribute:\n- **Image**: imaginea oficială OpenTelemetry Collector (ex. `otel/opentelemetry-collector:latest` sau o versiune fixă compatibilă).\n- **Volumes**: montează fișierul de configurare `shared/observability/otel-config/otel-collector-config.yml` în container, de ex.: `- ../../otel-config/otel-collector-config.yml:/etc/otel-collector-config.yml:ro` (cale relativă față de `compose/profiles/`).\n- **Command**: comanda de start a colectorului pentru a folosi config-ul montat (ex.: `--config=/etc/otel-collector-config.yml`).\n- **Ports**: nu este obligatoriu să expunem porturi către exterior în dev; celelalte containere îl vor accesa prin rețeaua `observability`, dar dacă e nevoie se pot expune 4317/4318.\n- **Networks**: atașează serviciul la rețeaua `observability` definită la F0.3.12.\nAstfel configurat, OTEL Collector-ul va porni în container și va asculta pe porturile OTLP pentru datele trimise de aplicații.",
    "directorul_directoarele": [
      "shared/observability/compose/profiles/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.11: Fișierul `shared/observability/compose/profiles/compose.dev.yml` există (schelet). F0.3.12: Rețeaua `observability` este definită în același fișier. F0.3.13: Fișierul de config pentru colector există în `shared/observability/otel-config/otel-collector-config.yml`.",
    "contextul_general_al_aplicatiei": "Collectorul OTEL reprezintă punctul central al pipeline-ului de trasabilitate. Prin includerea lui în Docker Compose (profilul dev), ne asigurăm că la rularea mediului de dev (`docker compose up`) acesta va porni împreună cu celelalte componente, conform cerinței de a avea Traefik + observability lansate cu o singură comandă.",
    "contextualizarea_directoarelor_si_cailor": "Deschide `/var/www/GeniusSuite/shared/observability/compose/profiles/compose.dev.yml` și, sub cheia existentă `services:`, adaugă:\n```yaml\n  otel-collector:\n    image: otel/opentelemetry-collector:latest\n    command: [\"--config=/etc/otel-collector-config.yml\"]\n    volumes:\n      - ../../otel-config/otel-collector-config.yml:/etc/otel-collector-config.yml:ro\n    networks:\n      - observability\n```\nCalea `../../otel-config/otel-collector-config.yml` este relativă la directorul fișierului `compose.dev.yml` (`shared/observability/compose/profiles/`) și ajunge în `shared/observability/otel-config/`.",
    "restrictii_anti_halucinatie": [
      "Nu adăuga environment variables inutile; configurarea se face prin fișierul YAML montat.",
      "Nu adăuga încă `depends_on` către alte servicii; collectorul poate porni independent.",
      "Nu modifica în acest pas fișierul de config OTEL; presupunem că este valid (F0.3.13)."
    ],
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu activa aici colectarea de metrici sau loguri prin collector; focusul acestui serviciu rămâne trasabilitatea, conform config-ului minimal curent.",
    "validare": "Rulează `docker compose -f shared/observability/compose/profiles/compose.dev.yml up -d otel-collector` și verifică log-urile containerului: OTEL Collector trebuie să pornească fără erori de configurare (ex. mesaj tipic de inițializare reușită).",
    "outcome": "Serviciul Docker `otel-collector` este definit în configurația de dezvoltare (profil dev), folosind config-ul din `otel-config/` și este atașat la rețeaua de observabilitate.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.15

```JSON
  {
  "F0.3.15": {
    "denumire_task": "Creare Configurație Prometheus (`prometheus.yml`)",
    "descriere_scurta_task": "Adaugă fișierul `prometheus.yml` în `shared/observability/compose/` cu job-urile de scrap pentru metricile expuse de suite.",
    "descriere_lunga_si_detaliata_task": "Se pregătește configurarea serverului Prometheus, definind ce ținte (aplicații) să monitorizeze. În `shared/observability/compose/prometheus.yml` vom specifica cel puțin:\n- Setări globale (ex. `scrape_interval: 15s` și, opțional, `evaluation_interval`).\n- Un job global (ex. `genius_applications`) care include toate serviciile suitei ce expun metrici. Vom lista ca **static_configs** adresele containerelor pentru fiecare aplicație, pe portul pe care expun metricile (de exemplu, 3000 pentru API-urile back-end: `archify.app:3000`, `flowxify.app:3000`, etc. – numele de servicii definite ulterior în Compose-ul orchestrator din F0.4).\n- Un job pentru Traefik (ex. `traefik`) care va scrapa endpoint-ul de metrici expus de acesta (configurat în F0.4).\n- Secțiunea `rule_files`, care va include fișiere de reguli (de ex. `rules/traefik.rules.yml`). Fișierul de reguli efectiv (`traefik.rules.yml`) va fi stocat, conform arhitecturii, în `shared/observability/metrics/rules/` și va fi montat în container astfel încât promQL să îl vadă ca `rules/traefik.rules.yml`.\n\nAcest fișier de configurare va fi folosit de containerul Prometheus definit în `compose/profiles/compose.dev.yml` (F0.3.16), printr-un volum montat în `/etc/prometheus/`.",
    "directorul_directoarele": [
      "shared/observability/compose/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.3: A fost creat directorul `shared/observability/metrics/rules/` pentru rules Prometheus. F0.3.11–F0.3.14: A fost definit scheletul `compose.dev.yml`, rețeaua `observability` și serviciul `otel-collector`.",
    "contextul_general_al_aplicatiei": "Prometheus va fi sursa unică de adevăr pentru metricile runtime ale suitei. Configurându-l corespunzător încă din faza skeleton, ne asigurăm că fiecare serviciu este monitorizat și că putem construi dashboard-uri în Grafana pe baza acestor metrici.",
    "contextualizarea_directoarelor_si_cailor": "Creează fișierul `/var/www/GeniusSuite/shared/observability/compose/prometheus.yml` cu un conținut exemplificativ:\n```yaml\nglobal:\n  scrape_interval: 15s\n\nscrape_configs:\n  - job_name: 'genius_applications'\n    static_configs:\n      - targets:\n          - 'archify.app:3000'\n          - 'flowxify.app:3000'\n          - 'i-wms.app:3000'\n          - 'mercantiq.app:3000'\n          - 'numeriqo.app:3000'\n          - 'triggerra.app:3000'\n          - 'vettify.app:3000'\n          - 'suite-admin:3000'\n          - 'suite-login:3000'\n          - 'identity:3000'\n          - 'licensing:3000'\n          - 'analytics-hub:3000'\n          - 'ai-hub:3000'\n\n  - job_name: 'traefik'\n    metrics_path: /metrics\n    scrape_interval: 5s\n    static_configs:\n      - targets:\n          - 'traefik:9100'\n\nrule_files:\n  - rules/traefik.rules.yml\n```\nLista de ținte folosește numele DNS ale containerelor din rețeaua `observability` (vor fi definite în Compose-ul orchestrator din F0.4). Secțiunea `rule_files` presupune că în container fișierele de reguli vor fi montate sub `/etc/prometheus/rules/`, iar din perspectiva config-ului vor fi accesibile ca `rules/traefik.rules.yml`.",
    "restrictii_anti_halucinatie": "Nu inventa servicii care nu există; folosește doar numele de aplicații definite în plan. Nu adăuga deocamdată alte job-uri (ex. node_exporter) sau reguli complexe de alertare – acestea pot fi adăugate ulterior.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu crea aici fișierul `traefik.rules.yml` și nu te ocupa de montarea volumelor în container (acestea vor fi tratate în task-urile F0.3.16 și F0.3.23). Limitează-te la configurarea de bază a lui `prometheus.yml`.",
    "validare": "Rulează un validator de config (ex. pornind containerul Prometheus în F0.3.16) și verifică faptul că fișierul `prometheus.yml` este acceptat fără erori de sintaxă. Verifică în loguri că job-urile `genius_applications` și `traefik` sunt înregistrate.",
    "outcome": "Fișierul de configurare `shared/observability/compose/prometheus.yml` este pregătit, specificând scrapping-ul metricilor pentru aplicațiile suitei și pentru Traefik, cu suport pentru fișiere de rules stocate în `shared/observability/metrics/rules/`.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.16

```JSON
  {
  "F0.3.16": {
    "denumire_task": "Adăugare Serviciu Prometheus în `compose.dev.yml`",
    "descriere_scurta_task": "Configurează serviciul Docker `prometheus` în fișierul Compose dev, folosind imaginea oficială și montând configurația `prometheus.yml` generată.",
    "descriere_lunga_si_detaliata_task": "Adăugăm serviciul de monitorizare Prometheus în fișierul `shared/observability/compose/profiles/compose.dev.yml`. Sub secțiunea `services:` introducem serviciul `prometheus` cu setările necesare:\n- **Image**: `prom/prometheus:latest` (sau o versiune stabilă v2.x).\n- **Volumes**: montăm fișierul de configurare creat la F0.3.15, aflat în `shared/observability/compose/prometheus.yml`, în container la `/etc/prometheus/prometheus.yml` (cale implicită pentru imaginea prom/prometheus).\n- Opțional, putem monta un volum named pentru date (ex. `prom_data:/prometheus`), dar în skeleton-ul de dev nu este obligatoriu.\n- **Ports**: expunem portul `9090` (UI Prometheus) pentru acces local în dev, ex. `9090:9090`.\n- **Networks**: atașăm containerul la rețeaua `observability` definită în F0.3.12, pentru a rezolva numele serviciilor țintă (ex. `archify.app`, `traefik`).\nCu această definiție, la pornirea Compose-ului, Prometheus va citi configurația montată și va începe să scrape-uiască metricile serviciilor suitei.",
    "directorul_directoarele": [
      "shared/observability/compose/profiles/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.11–F0.3.12: `compose/profiles/compose.dev.yml` și rețeaua `observability` au fost create. F0.3.15: `shared/observability/compose/prometheus.yml` conține job-urile de scrap pentru aplicații și Traefik.",
    "contextul_general_al_aplicatiei": "Integrarea Prometheus ca serviciu Docker în profilul de dezvoltare face parte din skeleton-ul de observabilitate al suitei. Stack-ul de observabilitate (OTEL Collector, Prometheus, Grafana, Loki, Tempo etc.) trebuie să poată fi pornit unitar prin Docker Compose.",
    "contextualizarea_directoarelor_si_cailor": "Deschide fișierul `/var/www/GeniusSuite/shared/observability/compose/profiles/compose.dev.yml` și, sub secțiunea `services:`, adaugă serviciul:\n```yaml\n  prometheus:\n    image: prom/prometheus:latest\n    volumes:\n      - ../prometheus.yml:/etc/prometheus/prometheus.yml:ro\n    networks:\n      - observability\n    ports:\n      - \"9090:9090\"\n```\nNotă: calea relativă `../prometheus.yml` este calculată din directorul `profiles/` către fișierul `prometheus.yml` aflat în `shared/observability/compose/`.",
    "restrictii_anti_halucinatie": "Nu adăuga aici alte servicii (ex. Alertmanager) și nu monta alte fișiere de configurare în afară de `prometheus.yml`. Nu defini volume persistente suplimentare decât dacă sunt clar necesare.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu modifica conținutul fișierului `prometheus.yml` în acest task și nu altera structura rețelei `observability`. Limitează-te la definirea serviciului Prometheus folosind config-ul existent.",
    "validare": "Rulează `docker compose -f shared/observability/compose/profiles/compose.dev.yml up -d prometheus` și accesează `http://localhost:9090/targets`. Job-urile definite în `prometheus.yml` trebuie să apară în listă (chiar dacă unele ținte pot fi încă `DOWN` până pornesc toate serviciile).",
    "outcome": "Serviciul Prometheus este definit în profilul Docker Compose de dezvoltare, atașat la rețeaua `observability` și configurat să folosească `shared/observability/compose/prometheus.yml` pentru a colecta metricile din suita GeniusERP.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.17

```JSON
  {
  "F0.3.17": {
    "denumire_task": "Creare Configurație Datasource Grafana pentru Observabilitate",
    "descriere_scurta_task": "Adaugă un fișier de provisioning Grafana pentru data source-uri (Prometheus, Loki, Tempo) în `shared/observability/dashboards/grafana/` (ex. `datasources.yml`).",
    "descriere_lunga_si_detaliata_task": "Pentru ca instanța Grafana să cunoască automat sursele de date (Prometheus pentru metrici, Loki pentru loguri, Tempo pentru trace-uri), vom folosi mecanismul de provisioning. Creăm un fișier YAML (`datasources.yml`) sub directorul `shared/observability/dashboards/grafana/`, cu conținut de forma:\n```yaml\napiVersion: 1\ndatasources:\n  - name: Prometheus\n    type: prometheus\n    url: http://prometheus:9090\n    access: proxy\n    isDefault: true\n  - name: Loki\n    type: loki\n    url: http://loki:3100\n    access: proxy\n  - name: Tempo\n    type: tempo\n    url: http://tempo:3100\n    access: proxy\n```\nAcest exemplu definește 3 surse: Prometheus, Loki și Tempo, indicând Grafanei cum să le acceseze (prin DNS-ul serviciilor respective în rețeaua Docker). Flagul `isDefault: true` face ca Prometheus să fie sursa implicită pentru panel-urile de grafice. Acest fișier va fi montat în containerul Grafana la pornire, asigurând configurarea automată a surselor de date.",
    "directorul_directoarele": [
      "shared/observability/dashboards/grafana/"
    ],
    "contextul_taskurilor_anterioare": "F0.1.6: Structura de bază `shared/observability/dashboards/` este definită în arhitectură. F0.3.2–F0.3.3: Structura pentru logs și metrics este creată; acum pregătim provisioning-ul pentru Grafana.",
    "contextul_general_al_aplicatiei": "Provisionarea surselor de date elimină necesitatea configurării manuale post-deploy a Grafana. În modul skeleton dev, definim sursele esențiale conform stack-ului de observabilitate (Prometheus, Loki, Tempo).",
    "contextualizarea_directoarelor_si_cailor": "Creează fișierul `/var/www/GeniusSuite/shared/observability/dashboards/grafana/datasources.yml` cu conținutul de mai sus. Acest fișier va fi ulterior montat în containerul Grafana în `/etc/grafana/provisioning/datasources/datasources.yml` de către serviciul definit în Compose.",
    "restrictii_anti_halucinatie": "Nu crea mai multe datasources decât este cazul. Nu adăuga data source-uri pentru baze de date sau alte sisteme care nu fac parte din stack-ul de observabilitate (ex: PostgreSQL).",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu schimba porturile standard în acest config fără motiv. Nu seta credențiale sau alte câmpuri avansate; în modul dev serviciile rulează fără autentificare internă.",
    "validare": "Fișierul va fi validat la pornirea containerului Grafana (dacă are erori, Grafana va loga mesaje de eroare). Poți verifica vizual că fișierul este YAML valid și conține cele 3 data source-uri așteptate.",
    "outcome": "Fișierul de provisioning pentru sursele de date Grafana este creat în locația arhitectural corectă, permițând configurarea automată a conexiunilor către Prometheus, Loki și Tempo la startul Grafana.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.18

```JSON
  {
  "F0.3.18": {
    "denumire_task": "Creare Configurație Provisionare Dashboard-uri Grafana",
    "descriere_scurta_task": "Adaugă un fișier de provisioning Grafana (ex. `dashboards.yml`) care indică încărcarea automată a dashboard-urilor JSON din `shared/observability/dashboards/grafana/dashboards/`.",
    "descriere_lunga_si_detaliata_task": "Pentru a încărca automat dashboard-urile de bază în Grafana, vom folosi mecanismul de provisioning. Creăm un fișier `dashboards.yml` în `shared/observability/dashboards/grafana/`, cu conținutul:\n```yaml\napiVersion: 1\nproviders:\n  - name: 'Genius Suite Dashboards'\n    orgId: 1\n    folder: ''\n    type: file\n    disableDeletion: false\n    updateIntervalSeconds: 60\n    options:\n      path: /etc/grafana/provisioning/dashboards\n```\nAcest config spune Grafana să ia toate dashboard-urile JSON din calea specificată și să le încarce automat. Noi vom monta directorul nostru `shared/observability/dashboards/grafana/dashboards/` în container la acea cale (`/etc/grafana/provisioning/dashboards`). Astfel, orice fișier `.json` plasat acolo (de ex. `traefik.json`) va apărea ca dashboard în Grafana fără acțiuni manuale ulterioare. Parametrul `updateIntervalSeconds: 60` indică verificarea periodică a modificărilor (nu critic în dev, dar util).",
    "directorul_directoarele": [
      "shared/observability/dashboards/grafana/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.17: Configurarea surselor de date Grafana este pregătită în `shared/observability/dashboards/grafana/datasources.yml`. Urmează configurarea încărcării dashboard-urilor.",
    "contextul_general_al_aplicatiei": "Dashboard-urile de bază (cum este cel pentru Traefik) trebuie să fie disponibile imediat în Grafana pentru a valida observabilitatea. Acest fișier asigură că panourile noastre JSON din cod sunt propagate în UI Grafana la run-time.",
    "contextualizarea_directoarelor_si_cailor": "Creează fișierul `/var/www/GeniusSuite/shared/observability/dashboards/grafana/dashboards.yml` cu conținutul de mai sus. Notă: `options.path` indică un director din container. Vom monta folderul local `/var/www/GeniusSuite/shared/observability/dashboards/grafana/dashboards` în container la `/etc/grafana/provisioning/dashboards`. Verifică să nu existe erori de indentare YAML și că `apiVersion` este setat la 1.",
    "restrictii_anti_halucinatie": "Nu schimba valorile cheie (ex: orgId trebuie să rămână 1, reprezentând organizația implicită Grafana). Nu adăuga provideri multipli inutil – un singur provider global e suficient pentru skeleton.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu plasa `options.path` către altă locație; menținem convenția standard. Nu adăuga opțiuni avansate (ex: filtrare după tag) atâta timp cât avem doar câteva dashboard-uri generice.",
    "validare": "Configul va fi validat la pornirea Grafana: dacă fișierul are erori, acestea apar în log-urile containerului. După pornire, verifică în UI Grafana la Settings -> Provisioning -> Dashboard că provider-ul 'Genius Suite Dashboards' apare și indică calea corectă.",
    "outcome": "Fișierul de provisioning al dashboard-urilor este creat în locația arhitectural corectă, instructând Grafana să preia automat definițiile JSON din `shared/observability/dashboards/grafana/dashboards/`.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.19

```JSON
  {
  "F0.3.19": {
    "denumire_task": "Adăugare Serviciu Grafana în `compose.dev.yml` (aliniat cu arhitectura)",
    "descriere_scurta_task": "Configurează serviciul Docker `grafana` în `shared/observability/compose/profiles/compose.dev.yml`, montând fișierele de provisioning și folderul de dashboard-uri din `shared/observability/dashboards/grafana/`.",
    "descriere_lunga_si_detaliata_task": "Adăugăm serviciul de vizualizare Grafana la orchestrarea dev. În `shared/observability/compose/profiles/compose.dev.yml`, sub `services:`, definim serviciul `grafana` cu:\n- Image: `grafana/grafana-oss:latest`.\n- Volumes:\n  - Montează `shared/observability/dashboards/grafana/datasources.yml` la `/etc/grafana/provisioning/datasources/datasources.yml`.\n  - Montează `shared/observability/dashboards/grafana/dashboards.yml` la `/etc/grafana/provisioning/dashboards/dashboards.yml`.\n  - Montează directorul `shared/observability/dashboards/grafana/dashboards/` la `/etc/grafana/provisioning/dashboards` (dashboard-urile JSON).\n- Environment: `GF_SECURITY_ADMIN_USER=admin`, `GF_SECURITY_ADMIN_PASSWORD=admin` pentru dev.\n- Networks: atașat la rețeaua `observability`.\n- Ports: expune `3000:3000` pentru acces UI Grafana.\nAstfel, Grafana pornește cu datasources și dashboards provisionate automat, folosind structura de directoare definită în arhitectură.",
    "directorul_directoarele": [
      "shared/observability/compose/profiles/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.11-F0.3.12 (corectate): `shared/observability/compose/profiles/compose.dev.yml` există și definește rețeaua `observability`. F0.3.17 și F0.3.18 (corectate): `datasources.yml` și `dashboards.yml` sunt în `shared/observability/dashboards/grafana/`, iar dashboard-urile JSON sunt în `shared/observability/dashboards/grafana/dashboards/`.",
    "contextul_general_al_aplicatiei": "Grafana este UI-ul unificat pentru metrici (Prometheus), loguri (Loki) și trace-uri (Tempo). În modul dev, vrem să pornim tot stack-ul de observabilitate cu o singură comandă Compose, cu provisioning automat (fără configurare manuală în UI).",
    "contextualizarea_directoarelor_si_cailor": "Editează fișierul `/var/www/GeniusSuite/shared/observability/compose/profiles/compose.dev.yml` și, sub secțiunea `services:`, adaugă:\n```yaml\n  grafana:\n    image: grafana/grafana-oss:latest\n    volumes:\n      - ../../dashboards/grafana/datasources.yml:/etc/grafana/provisioning/datasources/datasources.yml:ro\n      - ../../dashboards/grafana/dashboards.yml:/etc/grafana/provisioning/dashboards/dashboards.yml:ro\n      - ../../dashboards/grafana/dashboards:/etc/grafana/provisioning/dashboards:ro\n    environment:\n      - GF_SECURITY_ADMIN_USER=admin\n      - GF_SECURITY_ADMIN_PASSWORD=admin\n    networks:\n      - observability\n    ports:\n      - 3000:3000\n```\nCăile relative sunt calculate din `shared/observability/compose/profiles/` către `shared/observability/dashboards/grafana/`.",
    "restrictii_anti_halucinatie": "Nu monta alte fișiere sau directoare în plus. Nu schimba portul 3000 și nu adăuga integrări avansate (LDAP, OAuth etc.) în acest pas.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu crea alte servicii în acest task. Nu modifica structura de directoare față de cea definită în Capitolul 2; folosește exact `dashboards/grafana/` ca sursă pentru provisioning.",
    "validare": "Rulează `docker compose -f shared/observability/compose/profiles/compose.dev.yml up -d grafana`. Apoi accesează `http://localhost:3000` cu `admin/admin` și verifică:\n- În Configuration -> Data Sources, apar Prometheus, Loki, Tempo.\n- În meniul Dashboards apar dashboard-urile JSON montate.",
    "outcome": "Serviciul Grafana este definit corect în Compose dev, aliniat cu structura `shared/observability/dashboards/grafana/`, și pornește cu provisioning automat de datasources și dashboards.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.20

```JSON
  {
  "F0.3.20": {
    "denumire_task": "Creare Configurație Promtail pentru Colectarea Logurilor",
    "descriere_scurta_task": "Adaugă fișierul de configurare Promtail (agent Loki) în `shared/observability/logs/ingestion/` (ex. `promtail-config.yml`), pentru a defini ce loguri să fie trimise către Loki.",
    "descriere_lunga_si_detaliata_task": "În vederea colectării logurilor containerelor și trimiterii lor către Loki, vom folosi Promtail, agentul de loguri pentru Loki. Creăm un fișier `promtail-config.yml` sub `shared/observability/logs/ingestion/`, care să conțină configurația necesară. Configurația va specifica:\n- scrape_configs: definim job-uri pentru colectarea logurilor. Un job generic poate prelua logurile tuturor containerelor din rețeaua noastră `observability` (sau toate containerele, filtrând după etichete Docker). Exemplu de config relevant:\n\nserver:\n  http_listen_port: 9080\npositions:\n  filename: /tmp/positions.yaml\nclients:\n  - url: http://loki:3100/loki/api/v1/push\nscrape_configs:\n  - job_name: all-containers\n    docker_sd_configs:\n      - host: unix:///var/run/docker.sock\n        network: geniuserp_observability\n    relabel_configs:\n      - source_labels: [__docker_container_image]\n        action: keep\n        regex: .*\n    pipeline_stages:\n      - json:\n          expressions:\n            level: level\n            msg: message\n            trace: traceId\n      - labeldrop: [\"__address__\"]\n\nAcest config instruiește Promtail să descopere automat toate containerele din rețeaua `geniuserp_observability` (numele rețelei definit la F0.3.12) via Docker socket, să preia logurile lor (Promtail va citi stream-ul de log al fiecărui container) și să le trimită la Loki. Stadiile de pipeline includ un parser JSON (presupunând că logurile sunt JSON, de exemplu cele generate de Pino), extrăgând câmpurile standard (level, message, traceId) ca etichete sau mesaje. Se elimină etichete implicite inutile (`__address__`). Vom putea adăuga parse-stage specific pentru Traefik (format diferit) folosind `parsers/traefik.json` separat, în alt task.",
    "directorul_directoarele": [
      "shared/observability/logs/ingestion/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.2: Structura de directoare pentru loguri a fost creată. Acum completăm fișierul principal de config pentru ingestia de loguri (Promtail).",
    "contextul_general_al_aplicatiei": "Loki necesită un agent de loguri pentru a primi date; Promtail este soluția standard. Configurând Promtail acum, asigurăm colectarea centralizată a logurilor generate de toate aplicațiile și componentele, îndeplinind obiectivul „loguri colectate unitar în Loki”.",
    "contextualizarea_directoarelor_si_cailor": "Creează fișierul `/var/www/GeniusSuite/shared/observability/logs/ingestion/promtail-config.yml` cu conținutul exemplificat mai sus. Verifică să folosești numele corect al rețelei Docker (dacă la F0.3.12 s-a dat un alt nume, reflectă-l aici). Asigură-te că URL-ul Loki (`http://loki:3100`) corespunde numelui serviciului pe care îl vom defini. Prin configurarea stage-ului `json`, presupunem că logurile majorității serviciilor sunt deja în format JSON (așa cum asigurăm prin Pino).",
    "restrictii_anti_halucinatie": "Nu adăuga configuri de Promtail pentru surse inexistente (ex: nu definim file_sd dacă nu folosim fișiere). Nu trimite loguri către altă destinație decât Loki.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu include încă parser-ul Traefik direct aici; vom folosi un pipeline stage separat dacă e nevoie, după cum vom defini în `logs/parsers/traefik.json` ulterior. Menține config-ul general și cât mai simplu.",
    "validare": "Validarea completă va fi la rularea containerului Promtail. Ca verificare preliminară, asigură-te că sintaxa YAML este corectă și că fiecare secțiune este bine indentată. Poți testa config-ul prin rularea locală a Promtail (dacă este instalat) cu flag de dry-run, dar în mod uzual doar pornirea containerului ne va confirma.",
    "outcome": "Fișierul de configurare pentru Promtail este creat, permițând agentului de loguri să culeagă automat logurile containerelor și să le transmită către Loki.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.21

```JSON
  {
  "F0.3.21": {
    "denumire_task": "Adăugare Serviciu Loki în `compose.dev.yml`",
    "descriere_scurta_task": "Configurează serviciul Docker `loki` (Grafana Loki) în Compose dev, pentru stocarea centralizată a logurilor, incluzând un volum de date pentru persistență temporară.",
    "descriere_lunga_si_detaliata_task": "Adăugăm componenta de log management Grafana Loki ca serviciu în fișierul de profil `compose.dev.yml`. Sub secțiunea `services:` definim serviciul `loki` cu parametri:\n- Image: `grafana/loki:latest` (imaginea oficială Loki, mod single-binary care ascultă pe portul 3100 pentru scriere/query de loguri).\n- Ports: putem expune portul 3100 extern dacă vrem să testăm direct interogări (nu neapărat necesar, Grafana va comunica intern cu Loki). Pentru dev, putem totuși expune `3100:3100` ca să avem acces eventual la API-ul Loki.\n- Volumes: definim un volum de stocare pentru datele Loki (mount la `/loki` în container) astfel încât logurile să nu fie păstrate doar în memoria containerului. În dev pot fi și ephemeral, dar configurăm un volum named, de ex. `loki_data`.\n- Command/Config: Loki vine cu un config implicit pentru single-process mode; pentru skeleton nu montăm un config custom, folosim implicitul.\n- Networks: atașăm `loki` la rețeaua `observability`.\nAstfel, Promtail (definit în taskul următor) va putea trimite logurile la `http://loki:3100`, iar Grafana are deja data source-ul configurat către aceeași adresă.",
    "directorul_directoarele": [
      "shared/observability/compose/profiles/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.20: Configul Promtail (agentul de loguri) este pregătit să trimită către Loki. Acum adăugăm efectiv serviciul Loki care să primească și să stocheze logurile.",
    "contextul_general_al_aplicatiei": "Stocarea centralizată a logurilor completează cerința de observabilitate (alături de metrici și trace-uri). Loki va permite interogarea logurilor istorice în Grafana și corelarea cu metrici/traces. Integrarea lui acum asigură că la pornire, suita va avea un loc unde să-și trimită toate logurile.",
    "contextualizarea_directoarelor_si_cailor": "Deschide fișierul `/var/www/GeniusSuite/shared/observability/compose/profiles/compose.dev.yml` și, sub secțiunea `services:`, adaugă serviciul:\n\n  loki:\n    image: grafana/loki:latest\n    networks:\n      - observability\n    volumes:\n      - loki_data:/loki\n    ports:\n      - 3100:3100\n\nDacă fișierul nu are deja o secțiune globală `volumes:` (la același nivel cu `services:` și `networks:`), adaugă la final:\n\nvolumes:\n  loki_data:\n\nDacă secțiunea `volumes:` există deja (de ex. definită anterior pentru Prometheus sau alte servicii), doar adaugă intrarea `loki_data:` în acea secțiune, fără a o duplica.",
    "restrictii_anti_halucinatie": "Nu configura replici multiple sau microservicii separate pentru Loki (ingester, querier etc.) – rulăm modul all-in-one. Nu adăuga parametri de linie de comandă nejustificați; modul implicit este suficient în skeleton.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu seta autentificare sau multi-tenancy în config-ul Loki la acest pas – skeletonul este single-tenant dev. Nu uita volumul de date, altfel la restart logurile se pierd (în dev nu e grav, dar persistența minimă e utilă pentru debugging).",
    "validare": "După integrarea serviciului, rulează `docker compose -f shared/observability/compose/profiles/compose.dev.yml up -d loki`. Accesează `http://localhost:3100/metrics`; dacă primești un răspuns text cu metrici, containerul rulează corect. Ulterior, din Grafana, data source-ul Loki ar trebui să apară ca \"UP\".",
    "outcome": "Serviciul Loki este configurat și integrat în orchestrarea dev, gata să primească logurile colectate de la aplicații.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.22

```JSON
  {
  "F0.3.22": {
    "denumire_task": "Adăugare Serviciu Promtail (Agent de Loguri) în `compose.dev.yml`",
    "descriere_scurta_task": "Configurează serviciul Docker `promtail` în Compose dev, montând configurația `promtail-config.yml` și Docker socket-ul, pentru a trimite logurile containerelor către Loki.",
    "descriere_lunga_si_detaliata_task": "Adăugăm ultimul component al stack-ului de observabilitate: agentul de loguri Promtail. În fișierul de profil `compose.dev.yml`, definim serviciul `promtail` astfel:\n- Image: `grafana/promtail:latest` (imaginea oficială Promtail compatibilă cu versiunea Loki folosită).\n- Volumes:\n  - Montăm configurația noastră: `../../logs/ingestion/promtail-config.yml:/etc/promtail/promtail-config.yml:ro`.\n  - Montăm socket-ul Docker al host-ului în container: `/var/run/docker.sock:/var/run/docker.sock:ro`, pentru ca Promtail să poată descoperi containerele și să le citească logurile.\n- Command/Args: lansăm Promtail cu `-config.file=/etc/promtail/promtail-config.yml` pentru a ne asigura că folosește fișierul montat.\n- Networks: atașăm `promtail` la rețeaua `observability`, astfel încât să poată rezolva DNS-ul `loki` și să trimită datele către `http://loki:3100`.\nNu expunem porturi pentru Promtail, acesta acționând doar ca agent. Prin această configurare, Promtail va porni, va citi config-ul (job-ul `all-containers`) și se va conecta la Docker socket. Va descoperi toate containerele (inclusiv aplicațiile și serviciile de observabilitate) din rețeaua `observability` și va începe să trimită logurile lor către Loki.",
    "directorul_directoarele": [
      "shared/observability/compose/profiles/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.20: Configurația Promtail este scrisă în `logs/ingestion/promtail-config.yml`. F0.3.21: Serviciul Loki este disponibil ca țintă. Acum punem Promtail în funcțiune pentru a lega aceste componente.",
    "contextul_general_al_aplicatiei": "Promtail, împreună cu Loki, realizează centralizarea logurilor pentru întreg sistemul, completând implementarea observabilității inițiale (skeleton). Acest pas finalizează pipeline-ul de loguri: aplicațiile -> stdout (Pino JSON) -> Promtail -> Loki -> Grafana.",
    "contextualizarea_directoarelor_si_cailor": "Deschide fișierul `/var/www/GeniusSuite/shared/observability/compose/profiles/compose.dev.yml` și, sub secțiunea `services:` (la același nivel cu `loki`, `prometheus`, `grafana` etc.), adaugă:\n\n  promtail:\n    image: grafana/promtail:latest\n    command: -config.file=/etc/promtail/promtail-config.yml\n    volumes:\n      - ../../logs/ingestion/promtail-config.yml:/etc/promtail/promtail-config.yml:ro\n      - /var/run/docker.sock:/var/run/docker.sock:ro\n    networks:\n      - observability\n\nCalea relativă `../../logs/ingestion/promtail-config.yml` este calculată din directorul `shared/observability/compose/profiles/` către `shared/observability/logs/ingestion/promtail-config.yml` (două niveluri în sus, apoi în jos în `logs/ingestion/`). Verifică indentarea YAML pentru a evita erori de parse.",
    "restrictii_anti_halucinatie": "Nu porni Promtail fără a monta Docker socket-ul, altfel nu va putea descoperi containerele. Nu monta socket-ul cu permisiuni de scriere – păstrează `:ro` pentru siguranță. Nu adăuga porturi expuse pentru Promtail, nu este necesar.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu defini politici de restart sau constrângeri suplimentare în acest pas; pentru dev este suficient comportamentul implicit. Nu conecta Promtail la alte rețele decât `observability`.",
    "validare": "Pornește stack-ul de observabilitate cu `docker compose -f shared/observability/compose/profiles/compose.dev.yml up -d promtail loki`. Verifică logurile containerului Promtail (`docker compose -f shared/observability/compose/profiles/compose.dev.yml logs promtail`): ar trebui să vezi mesaje că a citit config-ul și a descoperit containere. În Grafana, în Explore (Loki), ar trebui să apară intrări de log după ce aplicațiile încep să emită loguri.",
    "outcome": "Serviciul Promtail este integrat în orchestrarea dev, colectând logurile din toate containerele suitei și direcționându-le către Loki, finalizând setup-ul de log management al skeleton-ului de observabilitate.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.23

```JSON
  {
  "F0.3.23": {
    "denumire_task": "Creare Reguli de Alertă Prometheus pentru Traefik (`traefik.rules.yml`)",
    "descriere_scurta_task": "Adaugă un fișier de reguli Prometheus în `shared/observability/metrics/rules/traefik.rules.yml` cu o regulă exemplificativă de alertă pentru Traefik (ex. rată ridicată de erori 5xx).",
    "descriere_lunga_si_detaliata_task": "Pentru a demonstra capacitatea de alertare (chiar dacă minimală în skeleton), definim un set de reguli pentru Traefik, ale cărui metrici vor fi colectate de Prometheus. Conform arhitecturii, toate regulile Prometheus sunt stocate în `shared/observability/metrics/rules/`. Creăm fișierul `traefik.rules.yml` în acest director, cu un grup de reguli simplu pentru Traefik, de exemplu:\n```yaml\ngroups:\n- name: traefik_alerts\n  rules:\n  - alert: TraefikHighErrorRate\n    expr: sum(rate(traefik_service_requests_total{code=~\"5..\"}[5m])) by (service) > 0.1\n    for: 2m\n    labels:\n      severity: warning\n    annotations:\n      summary: \"Rată mare de erori 5xx pe serviciul {{ $labels.service }}\"\n      description: \"Traefik raportează >10% request-uri cu erori 5xx în ultimele 5 minute.\"\n```\nAceastă regulă (exemplificativă) alertează dacă mai mult de 10% din cererile prin Traefik au cod 5xx în medie pe 5 minute, timp de 2 minute continuu. Severitatea este setată la `warning`. Fișierul va fi încărcat de Prometheus prin secțiunea `rule_files` din `prometheus.yml`.",
    "directorul_directoarele": [
      "shared/observability/metrics/rules/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.3: A fost creat directorul `shared/observability/metrics/rules/` pentru regulile Prometheus. F0.3.15: Configul Prometheus (`prometheus.yml`) include referință către fișierul de reguli pentru Traefik, care acum este implementat în locația corectă.",
    "contextul_general_al_aplicatiei": "Traefik, ca reverse-proxy, este critic pentru suită și merită monitorizat special. Definirea unei alerte de exemplu ilustrează cum vom gestiona și alte alerte în viitor, asigurând capacitatea de a detecta condiții anormale (ex. erori 5xx persistente) chiar din faza incipientă a sistemului.",
    "contextualizarea_directoarelor_si_cailor": "Creează fișierul `/var/www/GeniusSuite/shared/observability/metrics/rules/traefik.rules.yml` și inserează conținutul YAML de mai sus. Asigură-te că fișierul `prometheus.yml` folosit de serviciul Prometheus include acest fișier în secțiunea `rule_files` (ex.: `rule_files: ['traefik.rules.yml']` sau calea relativă corespunzătoare modului în care este montat directorul de reguli în container). Verifică atent indentarea YAML (în special sub cheile `groups:` și `rules:`).",
    "restrictii_anti_halucinatie": "Nu defini mai multe alerte decât este cazul în acest skeleton; ne limităm la o regulă exemplificativă. Nu inventa metrici inexistente – folosește numai metrici reale expuse de Traefik (ex. `traefik_service_requests_total`).",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu configura în acest task Alertmanager sau rute de notificare; acest fișier definește doar regulile în Prometheus. Nu muta sau redenumi directorul `metrics/rules/` – acesta este directorul canonic pentru regulile Prometheus conform arhitecturii.",
    "validare": "După ce Prometheus pornește cu acest fișier inclus, deschide UI-ul Prometheus și verifică secțiunea `/rules` pentru a confirma că grupul `traefik_alerts` este încărcat și apare cu starea `inactive` (în absența unei condiții de alertă). Orice eroare de parsare YAML va fi vizibilă în logurile containerului Prometheus.",
    "outcome": "Fișierul de reguli de alertare `traefik.rules.yml` este creat în `shared/observability/metrics/rules/` și integrat în configurația Prometheus, conținând o regulă exemplificativă de monitorizare a erorilor 5xx din Traefik.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.24

```JSON
  {
  "F0.3.24": {
    "denumire_task": "Creare Dashboard Grafana pentru Traefik (`traefik.json`)",
    "descriere_scurta_task": "Adaugă un fișier JSON în `shared/observability/metrics/dashboards/traefik.json` care definește un dashboard Grafana de bază pentru Traefik (metrice de trafic și erori), aliniat cu structura arhitecturală a metrice-lor.",
    "descriere_lunga_si_detaliata_task": "Pentru a verifica vizual metricile și starea Traefik, creăm un dashboard Grafana minimal, bazat pe metrici Prometheus. Conform arhitecturii, dashboard-urile bazate pe metrici sunt stocate în `shared/observability/metrics/dashboards/`. Fișierul `traefik.json` va conține un obiect JSON conform schema Grafana, cu panouri precum:\n- Un time-series pentru rata de request-uri prin Traefik, defalcate pe cod de status (200, 4xx, 5xx), folosind metrica `rate(traefik_service_requests_total[1m])` grupată pe `code` sau `service`.\n- Un panel de tip `stat` (sau gauge) pentru numărul curent de conexiuni deschise, folosind o metrică de tip `traefik_service_open_connections` (dacă este disponibilă).\n- Opțional, un graf pentru latența medie a request-urilor (dacă Traefik expune histograme de tip `traefik_service_request_duration_seconds`).\nDashboard-ul va avea titlul „Traefik Overview” și va fi setat să folosească sursa de date Prometheus implicită. JSON-ul poate fi generat inițial prin Grafana (export) și apoi salvat aici. Important: fișierul este plasat în `metrics/dashboards/` pentru a respecta arhitectura, iar provisioning-ul Grafana (corectat la F0.3.18/F0.3.19) va monta acest director în container și va încărca dashboard-ul automat.",
    "directorul_directoarele": [
      "shared/observability/metrics/dashboards/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.3: A fost creat directorul `shared/observability/metrics/dashboards/` pentru dashboard-uri bazate pe metrici. F0.3.15: Configurația Prometheus definește job-ul pentru Traefik. F0.3.18 și F0.3.19: Provisioning-ul și serviciul Grafana (corectate) sunt pregătite să încarce dashboard-urile din directorul de dashboards de metrici.",
    "contextul_general_al_aplicatiei": "Traefik este frontiera de intrare în sistem și trebuie monitorizat prin metrici runtime (trafic, erori, latențe). Un dashboard Grafana de bază pentru Traefik oferă echipei de dev/ops vizibilitate imediată asupra stării gateway-ului, folosind metricile colectate de Prometheus și afișate prin Grafana.",
    "contextualizarea_directoarelor_si_cailor": "Creează fișierul `/var/www/GeniusSuite/shared/observability/metrics/dashboards/traefik.json`. Inserează structura JSON completă a dashboard-ului Grafana, de tipul:\n```json\n{\n  \"title\": \"Traefik Overview\",\n  \"panels\": [\n    {\n      \"type\": \"timeseries\",\n      \"title\": \"Request Rate by Status\",\n      \"targets\": [\n        {\n          \"expr\": \"sum by (code) (rate(traefik_service_requests_total[1m]))\",\n          \"legendFormat\": \"{{code}}\"\n        }\n      ]\n    },\n    {\n      \"type\": \"stat\",\n      \"title\": \"Active Connections\",\n      \"targets\": [\n        {\n          \"expr\": \"sum(traefik_service_open_connections)\"\n        }\n      ]\n    }\n  ],\n  \"time\": { \"from\": \"now-5m\", \"to\": \"now\" },\n  \"uid\": \"traefik-overview\",\n  \"schemaVersion\": 36\n}\n```\n(Structura exactă poate fi adaptată sau exportată dintr-un dashboard creat manual în Grafana, important este să fie JSON valid și să folosească metricile reale expuse de Traefik.) Asigură-te că provisioning-ul Grafana (fișierul `dashboards.yml` și serviciul din Compose) montează directorul `shared/observability/metrics/dashboards/` în container la calea folosită în providerul Grafana pentru dashboards.",
    "restrictii_anti_halucinatie": "Nu defini un dashboard excesiv de complex; păstrează 2–3 panouri relevante pentru skeleton. Nu inventa metrici — folosește numai metrici reale expuse de Traefik (ex.: `traefik_service_requests_total`, `traefik_service_open_connections`). Asigură-te că JSON-ul este sintactic valid.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu muta dashboard-ul în alte directoare (ex. `shared/observability/grafana/`); acest task trebuie să rămână aliniat cu `metrics/dashboards/`. Nu adăuga logică de provisioning aici – aceasta este gestionată de fișierul `dashboards.yml` și de serviciul Grafana din Compose.",
    "validare": "Pornește stack-ul de observabilitate. În UI Grafana, verifică în lista de dashboard-uri existența „Traefik Overview”. Deschide dashboard-ul și confirmă că panourile execută query-uri valide (chiar dacă datele pot fi încă limitate până la integrarea completă Traefik). Orice eroare de parsare va fi vizibilă în logurile Grafana la pornire.",
    "outcome": "Dashboard-ul Traefik de bază este creat și versionat în `shared/observability/metrics/dashboards/traefik.json`, gata să fie încărcat automat de Grafana și să ofere vizibilitate asupra metricilor Traefik.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.25

```JSON
  {
  "F0.3.25": {
    "denumire_task": "Creare Configurație Parser Log Traefik (`traefik.json` în parsers)",
    "descriere_scurta_task": "Adaugă un fișier JSON de configurare a parser-ului de loguri Traefik în `shared/observability/logs/parsers/traefik.json` pentru a documenta și structura pașii de parsare a logurilor Traefik înainte de trimiterea în Loki (prin Promtail).",
    "descriere_lunga_si_detaliata_task": "Pentru logurile de acces Traefik dorim o procesare separată, astfel încât informațiile să fie structurate și eventualele date sensibile (ex. IP client) să poată fi mascate sau eliminate. Conform arhitecturii, fișierele de parsare pentru loguri sunt stocate în `shared/observability/logs/parsers/`. În fișierul `traefik.json` vom defini un schelet de configurare pentru pașii de parsare (pipeline) pe care îi vom integra ulterior în configurația Promtail.\n\nExemplu de conținut al fișierului (schelet JSON, inspirat de pipeline-urile Promtail):\n```json\n{\n  \"pipeline_stages\": [\n    {\n      \"json\": {\n        \"expressions\": {\n          \"client_ip\": \"ClientHost\",\n          \"path\": \"RequestPath\",\n          \"status\": \"StatusCode\"\n        }\n      }\n    },\n    {\n      \"timestamp\": {\n        \"source\": \"StartUTC\",\n        \"format\": \"2006-01-02T15:04:05.999Z\"\n      }\n    },\n    {\n      \"labels\": {\n        \"status\": \"StatusCode\",\n        \"path\": \"RequestPath\"\n      }\n    }\n  ]\n}\n```\nAcesta este un exemplu de schelet: presupune că Traefik este configurat să emită loguri în format JSON și arată ce câmpuri intenționăm să extragem (IP client, path, cod status) și cum pot fi folosite la etichetare. În faze ulterioare, pașii din acest schelet vor fi copiați/adaptați în configurația efectivă a Promtail (F0.3.20) într-un job dedicat pentru Traefik. În acest task ne limităm la a versiona schema/șablonul de parser pentru logurile Traefik în directorul corect (`logs/parsers/`).",
    "directorul_directoarele": [
      "shared/observability/logs/parsers/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.2: A fost creată structura de directoare pentru loguri, inclusiv `logs/parsers/`. F0.3.20: Configurația principală Promtail definește ingestia logurilor containerelor. Acum adăugăm un parser dedicat pentru logurile Traefik, care va fi integrat ulterior în config-ul Promtail.",
    "contextul_general_al_aplicatiei": "Logurile de acces Traefik pot conține date sensibile (IP-uri clienți, URL-uri). Definind un parser dedicat, avem un loc central unde documentăm pașii de procesare (parsare, etichetare, eventual redactare PII) pentru logurile Traefik, aliniat cu planul de redactare PII și trimitere a logurilor către observability.",
    "contextualizarea_directoarelor_si_cailor": "Creează fișierul `/var/www/GeniusSuite/shared/observability/logs/parsers/traefik.json`. Inserează un obiect JSON valid cu o cheie de top `pipeline_stages`, care descrie pașii de parsare intenționați pentru logurile Traefik (de exemplu, parsare JSON, extragerea câmpurilor importante, normalizarea timestamp-ului și transformarea unor câmpuri în etichete). Acest fișier funcționează ca șablon/schemă pentru pașii ce vor fi integrați ulterior în fișierul de configurare Promtail (`promtail-config.yml`). Confirmă că JSON-ul este valid (fără virgule lipsă sau chei invalide).",
    "restrictii_anti_halucinatie": "Nu complica excesiv parserul: un parse JSON (sau regex, dacă Traefik ar scrie text) plus câteva transformări simple sunt suficiente pentru skeleton. Nu descrie aici features Promtail care nu există; limitează-te la stagii standard (json, timestamp, labels etc.).",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu modifica în acest task fișierul `promtail-config.yml`; integrarea concretă a parserului va fi făcută ulterior când Traefik va fi adăugat în orchestrare. Nu crea alte fișiere de parsare suplimentare (ex. pentru alte servicii) în acest pas.",
    "validare": "Verifică faptul că fișierul `traefik.json` este JSON valid (poate fi deschis în orice editor/linter JSON fără erori). În fazele ulterioare, când pașii vor fi copiați în config-ul Promtail, se va valida că Promtail pornește fără erori și că logurile Traefik sunt parse-ate corect în Loki.",
    "outcome": "Fișierul de parser pentru logurile Traefik (`shared/observability/logs/parsers/traefik.json`) este creat și versionat, documentând schema de parsare intenționată pentru logurile Traefik și pregătind terenul pentru integrarea sa în pipeline-ul Promtail.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.26

```JSON
  {
  "F0.3.26": {
    "denumire_task": "Creare Script de Validare Observabilitate (`validate.sh`)",
    "descriere_scurta_task": "Adaugă un script `validate.sh` în `shared/observability/scripts/` care pornește stack-ul de observabilitate (din `compose/profiles/compose.dev.yml`) și execută verificări de bază (servicii up, endpoint-uri accesibile).",
    "descriere_lunga_si_detaliata_task": "Pentru a facilita testarea integrării observabilității, creăm un script Bash de validare automată. În `shared/observability/scripts/validate.sh` vom implementa pași precum:\n- Determină directorul scriptului și mută working dir în `shared/observability/`, de ex.:\n  - `cd \"$(dirname \"$0\")/..\"` (astfel toate căile devin relative la `shared/observability/`).\n- Pornește stack-ul de observabilitate folosind Docker Compose profilul de dev: `docker compose -f compose/profiles/compose.dev.yml up -d`.\n- Așteaptă câteva secunde pentru ca serviciile să fie up (ex. un `sleep 10`).\n- Execută verificări de sănătate pentru componentele principale:\n  - `curl -f http://localhost:9090/-/ready` pentru Prometheus.\n  - `curl -f http://localhost:3000/api/health` pentru Grafana (autentificare basic `admin:admin` dacă este necesară, de ex. `curl -f -u admin:admin ...`).\n  - `curl -f http://localhost:3100/metrics` pentru Loki (doar să răspundă).\n  - opțional, un request către endpoint-ul OTEL Collector (ex. `curl -f http://localhost:4318/v1/traces` doar ca health check simplu).\n- Pentru fiecare verificare, afișează un mesaj clar (`echo \"[OK] ...\"` / `[FAIL] ...`) și, dacă una din ele eșuează, script-ul iese cu `exit 1`.\n- Dacă toate verificările trec, script-ul iese cu cod 0.\nScriptul nu oprește stack-ul; rolul lui este strict de validare. Va fi folosit ulterior și în pipeline-urile CI pentru a verifica rapid că stack-ul de observabilitate este funcțional după modificări.",
    "directorul_directoarele": [
      "shared/observability/scripts/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.11–F0.3.25: Stack-ul de observabilitate (OTEL Collector, Prometheus, Grafana, Loki, Promtail etc.) este definit în `shared/observability/compose/profiles/compose.dev.yml`, iar configurațiile lor (otel-config, prometheus.yml, provisioning Grafana, promtail-config) sunt plasate în directoarele dedicate.",
    "contextul_general_al_aplicatiei": "Scripturile de validare reduc munca manuală și se aliniază practicilor DevOps: pot fi rulate local de dezvoltatori și, ulterior, integrate în CI pentru a verifica că observabilitatea nu este ruptă de modificări ulterioare ale codului sau ale configurațiilor Docker.",
    "contextualizarea_directoarelor_si_cailor": "Creează fișierul executabil `/var/www/GeniusSuite/shared/observability/scripts/validate.sh`. Asigură-te că:\n- Primele linii setează `set -euo pipefail` pentru un comportament robust al scriptului.\n- Se face `cd` în `shared/observability/` relativ la locația scriptului.\n- Comanda de pornire folosește fișierul corect, conform arhitecturii: `docker compose -f compose/profiles/compose.dev.yml up -d`.\n- Verificările folosesc `curl -f` (sau `docker compose exec ...` pentru health intern) și evaluează codul de exit. La prima verificare eșuată, script-ul iese cu `exit 1`.\n- La final, dacă toate verificările trec, se afișează un mesaj de succes (ex. `echo \"Observability stack: OK\"`) și scriptul iese cu `exit 0`.\nNu presupune o altă locație pentru `compose.dev.yml` decât `compose/profiles/compose.dev.yml`; dacă fișierul nu există, scriptul ar trebui să raporteze clar eroarea.",
    "restrictii_anti_halucinatie": "Nu adăuga verificări complexe sau dependente de business logic (ex: query-uri Prometheus complicate sau API-uri specifice aplicațiilor). Menține-te la health checks simple (readiness/health endpoints). Nu șterge sau recrea volume de date din acest script.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu modifica sau genera fișiere de config din `validate.sh`; el doar consumă configurațiile existente. Nu introduce logica de deploy sau de teardown aici (oprirea stack-ului poate fi făcută manual sau într-un script separat, ex. `stop.sh`).",
    "validare": "Rulează manual scriptul pe maşina de dezvoltare: `bash shared/observability/scripts/validate.sh`. Dacă Docker Compose și configurațiile asociate sunt corecte, scriptul trebuie să se termine cu cod de ieșire 0 și mesaje de succes pentru fiecare componentă. În caz contrar, trebuie să raporteze clar care serviciu sau endpoint nu a răspuns.",
    "outcome": "Scriptul de validare `validate.sh` este creat în `shared/observability/scripts/`, permițând rularea rapidă a unui health-check automat pentru stack-ul de observabilitate bazat pe `compose/profiles/compose.dev.yml`.",
    "componenta_de_CI_CD": "Scriptul poate fi folosit într-un job de pipeline (ex. `validate-observability`) care rulează după build/deploy pe un mediu de test, eșuând pipeline-ul dacă stack-ul de observabilitate nu pornește sau nu răspunde la health checks."
  }
},
```

#### F0.3.27

```JSON
  {
  "F0.3.27": {
    "denumire_task": "Integrare Observabilitate în suite-shell (cod)",
    "descriere_scurta_task": "Importă și initializează observabilitatea în aplicația suite-shell, folosind tracing + metrici din `@genius-suite/observability` și logger-ul Pino din `@genius-suite/common`.",
    "descriere_lunga_si_detaliata_task": "În serviciul `suite-shell` (parte a Control Plane), activăm observabilitatea la nivel de cod. În fișierul principal de inițializare al serverului (ex. `cp/suite-shell/src/main.ts` sau echivalent), vom:\n- **Tracing (OTEL)**: Importăm funcția de inițializare din pachetul comun de observabilitate și o apelăm cât mai devreme în lifecycle, înainte de pornirea serverului HTTP, de exemplu:\n  - `import { initTracing } from '@genius-suite/observability';`\n  - la startup: `initTracing({ serviceName: 'suite-shell' });`\n  Aceasta va configura SDK-ul OTEL și va trimite trace-urile către OTEL Collector, conform config-ului deja definit.\n- **Metrici Prometheus**: Importăm inițializarea/registrul de metrici din același pachet:\n  - `import { initMetrics, metricsHandler } from '@genius-suite/observability';`\n  - apelăm `initMetrics({ serviceName: 'suite-shell' });` la startup (dacă este nevoie) pentru a porni `collectDefaultMetrics`.\n  - în instanța Fastify, definim o rută GET `/metrics` care răspunde cu metricile în format text:\n    ```ts\n    fastify.get('/metrics', async (request, reply) => {\n      const body = await metricsHandler(); // intern apelează promClient.register.metrics()\n      reply.type('text/plain').send(body);\n    });\n    ```\n  Astfel Prometheus va putea scrapa metricile `suite-shell` prin Traefik.\n- **Logging (Pino)**: Folosim logger-ul unificat din pachetul `@genius-suite/common`, nu din observability:\n  - `import { logger } from '@genius-suite/common';`\n  - la crearea serverului Fastify: `const app = fastify({ logger });`\n  Sau, dacă există deja un logger, îl înlocuim cu cel din `@genius-suite/common`, astfel încât formatul logurilor să fie JSON standardizat (inclusiv câmpuri pentru corelație, ex. traceId, requestId).\n- **Integrare minimală**: Ne asigurăm că introducerea acestor inițializări nu schimbă comportamentul de business al aplicației (nu mutăm logica endpoint-urilor, doar adăugăm cross-cutting concerns). Dacă există deja un endpoint `/health`, îl păstrăm; `/metrics` este adăugat separat.\nDupă aceste modificări, `suite-shell` va trimite trace-uri către OTEL Collector, va expune metrici Prometheus și va loga JSON prin Pino, în conformitate cu arhitectura comună.",
    "directorul_directoarele": [
      "cp/suite-shell/",
      "cp/suite-shell/src/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.7, F0.3.9 și F0.3.10 corectate: modulul `@genius-suite/observability` expune tracing (ex. `traces/otel.ts`) și metrici (ex. `metrics/recorders/prometheus.ts`) prin `shared/observability/index.ts`, iar logger-ul Pino este definit în `shared/common/logger/` și exportat de pachetul `@genius-suite/common`.",
    "contextul_general_al_aplicatiei": "suite-shell este parte a Control Plane și trebuie monitorizat la fel ca celelalte servicii ale suitei. Integrarea observabilității direct în cod (traces + metrics + logs) permite corelarea cererilor și diagnosticarea rapidă a problemelor, în linie cu arhitectura de observabilitate definită în Capitolul 2.",
    "contextualizarea_directoarelor_si_cailor": "Modifică fișierul de bootstrap al aplicației din `cp/suite-shell/src/` (de ex. `main.ts` sau `server.ts`):\n- Adaugă importurile:\n  - `import { initTracing, initMetrics, metricsHandler } from '@genius-suite/observability';`\n  - `import { logger } from '@genius-suite/common';`\n- Imediat la startup, înainte de `app.listen(...)`, apelează:\n  - `initTracing({ serviceName: 'suite-shell' });`\n  - `initMetrics({ serviceName: 'suite-shell' });`\n- Creează instanța Fastify astfel încât să folosească logger-ul comun:\n  ```ts\n  const app = fastify({ logger });\n  ```\n- Adaugă ruta `/metrics` folosind handler-ul comun:\n  ```ts\n  app.get('/metrics', async (request, reply) => {\n    const body = await metricsHandler();\n    reply.type('text/plain').send(body);\n  });\n  ```\nAjustează numele fișierelor/funcțiilor la API-ul real definit în pachetul comun, dar respectă principiul: tracing + metrics din `@genius-suite/observability`, logger din `@genius-suite/common`.",
    "restrictii_anti_halucinatie": "Nu importa logger-ul din `@genius-suite/observability` și nu dubla inițializările OTEL sau Prometheus în mai multe locuri. Nu modifica logica endpoint-urilor de business, doar codul de start/initializare și configurarea serverului.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu adăuga alte endpoint-uri de observabilitate în afara `/metrics` (ex. nu crea `/debug` sau alte rute neprevăzute). Nu inițializa observabilitatea în interiorul handler-elor de request; totul trebuie făcut o singură dată, la bootstrap.",
    "validare": "Pornește local `suite-shell` în modul dev. Verifică:\n- că logurile din consolă sunt în format JSON și provin din logger-ul comun;\n- că `GET /metrics` răspunde cu textul standard de metrici Prometheus (`process_cpu_seconds_total`, `http_request_duration_seconds`, etc.);\n- că nu apar erori de inițializare OTEL/Prometheus în loguri.\nDupă integrarea completă a stack-ului de observabilitate, poți verifica în Prometheus/Tempo/Loki că apar date asociate serviciului `suite-shell`.",
    "outcome": "Aplicația suite-shell are observabilitate activă, folosind pachetele corecte (`@genius-suite/observability` pentru tracing + metrici și `@genius-suite/common` pentru logging), conform arhitecturii proiectului.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.28

```JSON
  {
  "F0.3.28": {
    "denumire_task": "Actualizare Docker Compose pentru suite-shell (integrare observability)",
    "descriere_scurta_task": "Modifică configurația Docker Compose a modulului suite-shell pentru a se integra cu observabilitatea: atașează serviciul la rețeaua `observability` (externală `geniuserp_observability`) și setează variabilele de mediu OTEL.",
    "descriere_lunga_si_detaliata_task": "În fișierul Docker Compose al aplicației **suite-shell** (`cp/suite-shell/compose/docker-compose.yml`), conectăm containerul la stack-ul de observabilitate și configurăm SDK-ul OTEL din cod (din F0.3.27 corectat):\n- **Rețea observability**:\n  - Sub serviciul `suite-shell`, adaugă rețeaua logică `observability` în lista de `networks`, pe lângă rețelele deja existente.\n  - La nivel de fișier (`networks:`), definește rețeaua `observability` ca rețea externă care referă network-ul creat de stack-ul comun de observabilitate:\n    ```yaml\n    networks:\n      observability:\n        external: true\n        name: geniuserp_observability\n    ```\n  Astfel, containerul `suite-shell` va partaja aceeași rețea Docker cu serviciul `otel-collector` definit în `shared/observability/compose/profiles/compose.dev.yml`.\n- **Variabile de mediu OTEL**:\n  - În secțiunea `environment:` a serviciului `suite-shell`, adaugă:\n    ```yaml\n    - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318\n    - OTEL_SERVICE_NAME=suite-shell\n    ```\n  - `OTEL_EXPORTER_OTLP_ENDPOINT` indică SDK-ului OTEL din aplicație că trebuie să trimită trace-urile (și eventual alte semnale) prin OTLP HTTP către serviciul `otel-collector` din aceeași rețea Docker.\n  - `OTEL_SERVICE_NAME` setează numele serviciului raportat în sistemul de observabilitate (Tempo/Prometheus/Grafana), și trebuie să corespundă cu cel folosit în `initTracing` / `initMetrics`.\n- **Dependență opțională**:\n  - Opțional, poți adăuga `depends_on:` cu `otel-collector` pentru a porni mai întâi colectorul atunci când rulezi un orchestrator comun (nu este obligatoriu, dar poate reduce zgomotul de erori la startup).\nDupă aceste modificări, `suite-shell` va putea să trimită telemetrie către OTEL Collector atunci când este orchestrat împreună cu stack-ul de observabilitate.",
    "directorul_directoarele": [
      "cp/suite-shell/compose/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.12 și F0.3.14 corectate: rețeaua `observability` (name: `geniuserp_observability`) și serviciul `otel-collector` sunt definite în `shared/observability/compose/profiles/compose.dev.yml`. F0.3.27 corectat: codul suite-shell folosește `@genius-suite/observability` pentru tracing/metrici și `@genius-suite/common` pentru logging.",
    "contextul_general_al_aplicatiei": "Fiecare serviciu al suitei trebuie conectat la stack-ul comun de observabilitate printr-o rețea partajată și variabile de mediu OTEL. Pentru `suite-shell`, acest lucru se face la nivel de `docker-compose.yml` specific modulului, fără a încălca arhitectura de rețele și compoziția hibridă descrisă în plan (compose per app + compose comun de observabilitate).",
    "contextualizarea_directoarelor_si_cailor": "Deschide fișierul `cp/suite-shell/compose/docker-compose.yml` și:\n1. Găsește definiția serviciului principal (ex. `suite-shell:` sau numele echivalent).\n2. În secțiunea `environment:` a serviciului, adaugă liniile:\n   ```yaml\n   - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318\n   - OTEL_SERVICE_NAME=suite-shell\n   ```\n   (dacă `environment` este în format map în loc de listă, folosește chei: `OTEL_EXPORTER_OTLP_ENDPOINT: http://otel-collector:4318` etc.).\n3. În secțiunea `networks:` a serviciului, adaugă `observability` pe lângă rețelele deja prezente, de exemplu:\n   ```yaml\n   services:\n     suite-shell:\n       networks:\n         - internal\n         - observability\n   ```\n4. La finalul fișierului (sau în blocul global `networks:`), adaugă definiția:\n   ```yaml\n   networks:\n     observability:\n       external: true\n       name: geniuserp_observability\n   ```\n   Dacă există deja o secțiune `networks:`, doar adaugă acolo intrarea `observability` fără a altera celelalte rețele.",
    "restrictii_anti_halucinatie": "Nu elimina rețele existente ale serviciului (ex. `internal`, `default`), doar adaugă `observability`. Nu schimba port mapping-uri, volume sau alte setări ale serviciului care nu țin de observabilitate. Nu seta alte variabile OTEL în afara celor specificate, dacă nu există cerințe explicite.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu crea rețeaua `observability` ca rețea nouă locală; trebuie definită ca `external` indicând `geniuserp_observability`, care este creată de stack-ul comun de observabilitate. Nu adăuga servicii noi în acest fișier Compose.",
    "validare": "După modificare, rulează `docker compose -f cp/suite-shell/compose/docker-compose.yml config` pentru a verifica sintaxa. Apoi, într-un context în care rețeaua `geniuserp_observability` există deja, pornește containerul suite-shell și rulează `docker inspect suite-shell` pentru a verifica că este conectat la rețeaua `geniuserp_observability`. În interiorul containerului (`docker exec`), rulează `printenv` și confirmă că `OTEL_EXPORTER_OTLP_ENDPOINT` și `OTEL_SERVICE_NAME` sunt setate corect.",
    "outcome": "Configurația Docker Compose pentru suite-shell este actualizată: containerul este conectat la rețeaua de observabilitate (externală `geniuserp_observability`) și are variabilele de mediu OTEL setate pentru a trimite telemetria către OTEL Collector.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.29

```JSON
  {
  "F0.3.29": {
    "denumire_task": "Integrare Observabilitate în suite-admin (cod)",
    "descriere_scurta_task": "Instrumentează aplicația suite-admin pentru observabilitate: inițializează tracing-ul OTEL, metricile Prometheus și logger-ul Pino la pornire, folosind pachetele comune corecte.",
    "descriere_lunga_si_detaliata_task": "Pentru aplicația stand-alone **suite-admin** (parte a Control Plane), integrăm observabilitatea la nivel de cod, respectând separația arhitecturală între common logger și observability:\n- **Logging (Pino)**: logger-ul este furnizat de pachetul comun `@genius-suite/common` (modulul `shared/common/logger`). În punctul de intrare al serverului (ex. `src/main.ts` sau `src/index.ts`), importăm `logger` din `@genius-suite/common` și îl conectăm la framework-ul HTTP (de ex. Fastify: `Fastify({ logger })`). Astfel, toate logurile vor fi JSON structurat, compatibile cu Promtail/Loki.\n- **Tracing (OTEL)**: funcția `initTracing` este expusă de pachetul `@genius-suite/observability`, care la rândul lui exportă din `shared/observability/traces/otel.ts`. La startup, înainte de crearea serverului HTTP, apelăm `initTracing({ serviceName: 'suite-admin' })` sau echivalent, astfel încât SDK-ul OTEL să înceapă să emită span-uri către collector.\n- **Metrici (Prometheus)**: pachetul `@genius-suite/observability` expune și inițializarea metricilor (ex. `initMetrics` și `metricsRegister`) din `shared/observability/metrics/recorders/prometheus.ts`. În cod, expunem o rută `/metrics` care răspunde cu `text/plain` și conținutul registrului: `metricsRegister.metrics()`. Această rută va fi scrapp-uită de Prometheus.\n- **Nume serviciu & config prin env**: codul va citi `OTEL_SERVICE_NAME` și `OTEL_EXPORTER_OTLP_ENDPOINT` din variabile de mediu (setate în Compose la F0.3.30), dar în acest task ne asigurăm că, dacă lipsesc, avem fallback-uri rezonabile (ex. `suite-admin` ca nume default) și că logăm clar eventualele probleme de config, fără a opri aplicația.\nDupă aceste modificări, suite-admin va trimite trace-uri către OTEL Collector, va expune metrici pentru Prometheus și va produce loguri JSON coerente pentru Loki, aliniate cu restul suitei.",
    "directorul_directoarele": [
      "cp/suite-admin/",
      "cp/suite-admin/src/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.7, F0.3.9 și F0.3.10 corectate: pachetul `@genius-suite/observability` exportă tracing-ul din `shared/observability/traces/otel.ts` și metricile din `shared/observability/metrics/recorders/prometheus.ts`. Pachetul `@genius-suite/common` expune logger-ul Pino din `shared/common/logger`.",
    "contextul_general_al_aplicatiei": "suite-admin este o aplicație stand-alone critică din Control Plane și trebuie monitorizată la fel ca celelalte servicii. Arhitectura prevede un logger comun (`@genius-suite/common`) și un pachet de observabilitate (`@genius-suite/observability`) care să fie reutilizate în toate aplicațiile, pentru consistență în loguri, metrici și trace-uri.",
    "contextualizarea_directoarelor_si_cailor": "În directorul `cp/suite-admin/`, identifică fișierul principal de bootstrap al serverului (ex. `src/main.ts`, `src/index.ts` sau similar). Aplică următorii pași:\n1. **Importuri**:\n   - Adaugă import pentru logger-ul comun:\n     ```ts\n     import { logger } from '@genius-suite/common';\n     ```\n   - Adaugă import pentru tracing și metrici:\n     ```ts\n     import { initTracing, initMetrics, metricsRegister } from '@genius-suite/observability';\n     ```\n2. **Inițializare tracing** – cât mai devreme în executare (înainte de crearea serverului HTTP):\n   ```ts\n   initTracing({\n     serviceName: process.env.OTEL_SERVICE_NAME || 'suite-admin',\n     otlpEndpoint: process.env.OTEL_EXPORTER_OTLP_ENDPOINT\n   });\n   ```\n   (Semnătura exactă a lui `initTracing` se aliniază cu ce s-a definit la F0.3.7/F0.3.10 corectate; aici folosim un exemplu generic.)\n3. **Crearea serverului** – dacă folosești Fastify:\n   ```ts\n   const app = Fastify({ logger });\n   ```\n   Dacă aplicația avea deja propriul logger, îl înlocuiești cu cel comun.\n4. **Inițializare metrici și ruta `/metrics`**:\n   - În zona de bootstrap (după creare server):\n     ```ts\n     initMetrics();\n     ```\n   - Înregistrarea rutei `/metrics`:\n     ```ts\n     app.get('/metrics', async (_req, reply) => {\n       reply.type('text/plain');\n       return metricsRegister.metrics();\n     });\n     ```\n5. **Păstrează restul logicii neschimbate** – nu muta rute sau logica de business, doar adaugă aceste cross-cutting concerns de observabilitate.",
    "restrictii_anti_halucinatie": "Nu importa logger-ul Pino din `@genius-suite/observability` – acesta trebuie să vină exclusiv din `@genius-suite/common`. Nu crea instanțe noi de prom-client sau OTEL în această aplicație; folosește doar wrapper-ele expuse de `@genius-suite/observability`. Nu modifica semnături de endpoint-uri existente în afară de adăugarea /metrics.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu inițializa observabilitatea în mai multe locuri (doar în punctul de intrare). Nu adăuga alte endpoint-uri în afară de `/metrics` pentru acest task. Nu introduce configurări OTEL avansate (sampling, exporters suplimentari) – skeleton-ul rămâne minimal.",
    "validare": "Rulează aplicația suite-admin în modul de dezvoltare. Verifică: (1) logurile din consolă sunt JSON, provenind din logger-ul comun, (2) accesând `http://localhost:<port>/metrics` primești text cu metrici Prometheus valide (fără erori), (3) aplicația pornește fără erori legate de OTEL. După ce stack-ul de observabilitate este funcțional, verifică în Tempo/Prometheus/Grafana că apar trace-uri și metrici etichetate cu `service_name=\"suite-admin\"`.",
    "outcome": "Aplicația suite-admin este instrumentată corect pentru observabilitate: folosește logger-ul comun, expune metrici Prometheus și trimite trace-uri OTEL, respectând structura de pachete definită în arhitectură.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.30

```JSON
  {
  "F0.3.30": {
    "denumire_task": "Actualizare Docker Compose pentru suite-admin (observabilitate)",
    "descriere_scurta_task": "Conectează containerul suite-admin la ecosistemul de observabilitate: îl atașează la rețeaua `observability` (geniuserp_observability) și setează variabilele OTEL în compose-ul aplicației.",
    "descriere_lunga_si_detaliata_task": "În fișierul Docker Compose al aplicației **suite-admin** (`cp/suite-admin/compose/docker-compose.yml`), integrăm serviciul cu stack-ul de observabilitate deja definit în `shared/observability/compose/profiles/compose.dev.yml`. Facem două lucruri principale:\n- **Rețea**: adăugăm serviciul `suite-admin` în rețeaua logică `observability`, care mapează în Docker pe network-ul `geniuserp_observability` creat de stack-ul de observabilitate. Astfel, containerul poate rezolva DNS-ul `otel-collector`, `prometheus`, `loki`, etc.\n- **Environment OTEL**: adăugăm variabilele de mediu necesare SDK-ului OTEL din cod (instrumentat la F0.3.29 corectat):\n  - `OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318` – endpoint-ul HTTP OTLP al collector-ului din stack-ul de observabilitate.\n  - `OTEL_SERVICE_NAME=suite-admin` – numele serviciului așa cum va apărea în Tempo/Prometheus/Grafana.\nOpțional, dacă acest compose este folosit împreună cu observability într-un singur proiect Compose, se poate folosi `depends_on` pentru `otel-collector`, dar în scenariul cu rețea externă e suficient ca rețeaua să existe. Rezultatul: când suite-admin este lansat împreună cu stack-ul de observabilitate, are conectivitate de rețea și configurația necesară pentru a trimite trace-uri și a fi corelat în observability.",
    "directorul_directoarele": [
      "cp/suite-admin/compose/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.29 (corectat): codul suite-admin este instrumentat pentru observabilitate (traces, metrici, loguri), folosind logger-ul din `@genius-suite/common` și tracing/metrici din `@genius-suite/observability`. F0.3.12 și F0.3.14 (corectate): rețeaua `observability` / `geniuserp_observability` și serviciul `otel-collector` au fost definite în `shared/observability/compose/profiles/compose.dev.yml`.",
    "contextul_general_al_aplicatiei": "Arhitectura prevede un model Docker Compose hibrid, în care stack-ul de observabilitate expune o rețea comună `geniuserp_observability`, iar aplicațiile (inclusiv suite-admin) se alipesc acestei rețele și își configurează OTEL prin variabile de mediu. Astfel, toate serviciile pot trimite telemetrie către același colector și pot fi vizualizate unitar.",
    "contextualizarea_directoarelor_si_cailor": "1. Deschide fișierul `cp/suite-admin/compose/docker-compose.yml`.\n2. Identifică serviciul `suite-admin` (sau numele real al serviciului pentru această aplicație) sub secțiunea `services:`.\n3. În definiția serviciului, asigură-te că există o secțiune `environment:` și adaugă:\n   ```yaml\n   services:\n     suite-admin:\n       # ... configurări existente (image, ports, volumes etc.)\n       environment:\n         - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318\n         - OTEL_SERVICE_NAME=suite-admin\n       networks:\n         - observability\n   ```\n   Dacă `environment` sau `networks` există deja, inserează doar liniile noi, fără a șterge restul.\n4. Dacă fișierul nu definește încă rețeaua `observability` la nivel de top, adaugă la final:\n   ```yaml\n   networks:\n     observability:\n       external: true\n       name: geniuserp_observability\n   ```\n   Aceasta spune Docker Compose că rețeaua este creată și deținută de stack-ul de observabilitate, iar acest compose doar o folosește.\n5. Salvează fișierul, păstrând indentarea YAML corectă.",
    "restrictii_anti_halucinatie": "Nu redenumi rețeaua Docker (`observability` / `geniuserp_observability`) și nu modifica numele serviciului `otel-collector` – acestea trebuie să rămână consistente cu stack-ul de observabilitate. Nu adăuga alte variabile OTEL în afară de cele planificate aici, decât dacă sunt introduse explicit în alte task-uri.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu modifica porturile, volumele sau alte setări ale serviciului suite-admin – acest task se ocupă exclusiv de rețea și variabilele de mediu de observabilitate. Nu declara rețeaua `observability` ca non-external; proprietarul acesteia este stack-ul de observabilitate din `shared/observability/compose/profiles/compose.dev.yml`.",
    "validare": "Într-un mediu unde stack-ul de observabilitate a creat deja rețeaua `geniuserp_observability`, rulează `docker compose` pentru suite-admin (sau orchestratorul global). Apoi:\n- Execută `docker network inspect geniuserp_observability` și verifică faptul că containerul suite-admin apare în lista de `Containers`.\n- Rulează `docker compose exec suite-admin env` și confirmă existența variabilelor `OTEL_EXPORTER_OTLP_ENDPOINT` și `OTEL_SERVICE_NAME` cu valorile așteptate.\nDacă stack-ul de observabilitate este funcțional și codul din F0.3.29 este implementat, ar trebui ca trace-urile suite-admin să apară în Tempo și să fie vizibile în Grafana.",
    "outcome": "Docker Compose-ul pentru suite-admin este actualizat astfel încât containerul să fie conectat la rețeaua de observabilitate `geniuserp_observability` și să aibă configurate variabilele OTEL necesare pentru a trimite telemetrie către colector.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.31

```JSON
  {
  "F0.3.31": {
    "denumire_task": "Integrare Observabilitate în suite-login (Cod)",
    "descriere_scurta_task": "Instrumentează aplicația suite-login pentru observabilitate: inițializează tracing-ul OTEL, metricile Prometheus și logger-ul Pino la pornire, folosind `@genius-suite/common` și `@genius-suite/observability`.",
    "descriere_lunga_si_detaliata_task": "Pentru aplicația stand-alone **suite-login** (parte a Control Plane), integrăm observabilitatea la nivel de cod, în conformitate cu arhitectura:\n- **Logging (Pino)**: Logger-ul este definit în pachetul comun `shared/common/logger/` și expus prin `@genius-suite/common`. În punctul de intrare al aplicației (ex. `cp/suite-login/src/main.ts` sau `src/index.ts`), importă `logger` din `@genius-suite/common` și configurează framework-ul (ex. Fastify) să îl folosească: `const app = fastify({ logger })`. Astfel, toate logurile sunt JSON uniforme și pregătite pentru a fi colectate de Promtail/Loki.\n- **Tracing (OTEL)**: Funcționalitatea de tracing este definită în `shared/observability/traces/otel.ts` și expusă prin pachetul `@genius-suite/observability` (via `index.ts` corectat). Importă `initTracing` (sau funcția echivalentă) din `@genius-suite/observability` și apeleaz-o cât mai devreme în punctul de intrare (înainte de creare server): `initTracing()`; aceasta va configura OTEL SDK (Http/Grpc OTLP) și va folosi `OTEL_EXPORTER_OTLP_ENDPOINT` și `OTEL_SERVICE_NAME` din variabile de mediu.\n- **Metrici (Prometheus)**: Exporterul de metrici este definit în `shared/observability/metrics/recorders/prometheus.ts` și expus tot prin `@genius-suite/observability`. Importă registrul/handler-ul (ex. `metricsRegister` sau `createMetricsHandler`) și expune un endpoint HTTP `/metrics` care întoarce conținut `text/plain` generat de `prom-client`. Pentru Fastify, de exemplu: `app.get('/metrics', async (req, reply) => { reply.type('text/plain'); reply.send(await metricsRegister.metrics()); });`.\n- **Numele serviciului**: Asigură-te că aplicația folosește numele `suite-login` pentru resource-ul OTEL, fie prin variabila de mediu `OTEL_SERVICE_NAME=suite-login` (setată în compose, vezi task-ul de compose aferent), fie prin configurarea explicită în `initTracing`.\nDupă aceste modificări, suite-login va emite loguri JSON structurate, va expune metrici Prometheus pe `/metrics` și va genera trace-uri OTEL trimise către colectorul configurat.",
    "directorul_directoarele": [
      "cp/suite-login/",
      "cp/suite-login/src/",
      "cp/suite-login/compose/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.7 și F0.3.9 (corectate): au definit implementările de tracing (traces/otel.ts) și metrici (metrics/recorders/prometheus.ts) în `shared/observability/`. F0.3.10 (corectat): a expus o interfață publică clară în `@genius-suite/observability` pentru tracing și metrici. Pachetul `@genius-suite/common` expune logger-ul Pino din `shared/common/logger/`. Acum consumăm aceste facilități în aplicația suite-login.",
    "contextul_general_al_aplicatiei": "suite-login este unul dintre serviciile importante din Control Plane și trebuie monitorizat consistent cu restul suitei. Prin integrarea logging-ului comun și a bibliotecii de observabilitate, asigurăm coerență la nivel de loguri, metrici și trace-uri, în conformitate cu arhitectura definită în Capitolul 2.",
    "contextualizarea_directoarelor_si_cailor": "1. Deschide fișierul de intrare al serverului din `cp/suite-login/` (ex.: `cp/suite-login/src/main.ts` sau `src/index.ts`).\n2. Adaugă importurile corecte, de exemplu:\n   ```ts\n   import { logger } from '@genius-suite/common';\n   import { initTracing, metricsRegister } from '@genius-suite/observability';\n   ```\n3. Apelează tracing-ul cât mai devreme:\n   ```ts\n   initTracing();\n   ```\n4. Creează instanța serverului (ex. Fastify) folosind logger-ul comun:\n   ```ts\n   const app = fastify({ logger });\n   ```\n5. Adaugă ruta `/metrics` care expune metricile din Prometheus client:\n   ```ts\n   app.get('/metrics', async (_request, reply) => {\n     const body = await metricsRegister.metrics();\n     reply.type('text/plain').send(body);\n   });\n   ```\n6. Asigură-te că nu există un alt endpoint `/metrics` conflictual. Dacă există, înlocuiește-l cu cel bazat pe registrul comun.\n7. Verifică faptul că numele serviciului este controlat prin `OTEL_SERVICE_NAME` (setat în compose în task-ul dedicat suite-login) sau configurat explicit în `initTracing`.",
    "restrictii_anti_halucinatie": "Nu importa logger-ul din `@genius-suite/observability`; folosește exclusiv `@genius-suite/common` pentru Pino, conform arhitecturii. Nu introduce un al doilea client Prometheus; utilizează doar infrastructura expusă de `@genius-suite/observability`. Nu modifica logica de business existentă, doar înfășoară serverul cu capabilități de observabilitate.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu muta fișierele în alte directoare decât cele planificate (codul suite-login rămâne sub `cp/suite-login/`). Nu adăuga configurări OTEL avansate (sampling, exporters suplimentari) în acest pas; skeleton-ul rămâne minimal. Nu schimba semnătura publică a API-ului suite-login.",
    "validare": "1. Rulează aplicația local (ex.: `pnpm run dev` în `cp/suite-login`).\n2. Verifică în consolă că logurile apar în format JSON structurat (câmpuri `level`, `msg`, eventual `traceId`).\n3. Accesează `http://localhost:{PORT}/metrics` și confirmă că răspunsul este `text/plain` cu metrici Prometheus valide.\n4. După ce stack-ul de observabilitate este pornit și variabilele OTEL sunt setate corect în compose, verifică în Tempo/ Grafana că trace-urile pentru serviciul `suite-login` apar cu numele configurat.",
    "outcome": "Aplicația suite-login este instrumentată corect pentru observabilitate: folosește logger-ul comun din `@genius-suite/common`, expune metrici Prometheus prin librăria din `@genius-suite/observability` și trimite trace-uri OTEL către colector, respectând structura și responsabilitățile arhitecturale.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.32

```JSON
  {
  "F0.3.32": {
    "denumire_task": "Actualizare Docker Compose pentru suite-login (Observabilitate)",
    "descriere_scurta_task": "Conectează containerul suite-login la ecosistemul de observabilitate: adaugă rețeaua `observability` și variabilele OTEL în compose-ul aplicației.",
    "descriere_lunga_si_detaliata_task": "În `cp/suite-login/compose/docker-compose.yml`, actualizăm serviciul **suite-login** pentru a se integra cu stack-ul de observabilitate:\n- **Rețea**: adăugăm rețeaua `observability` în lista de rețele ale serviciului, astfel încât containerul să fie pe aceeași rețea Docker cu `otel-collector`, Prometheus etc. (rețeaua este definită la nivelul orchestratorului global dev din `shared/observability/compose/profiles/compose.dev.yml`).\n- **Environment (OTEL)**: adăugăm variabilele de mediu necesare agentului OTEL din aplicație:\n  - `OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318` – endpoint-ul HTTP OTLP al colectorului.\n  - `OTEL_SERVICE_NAME=suite-login` – numele serviciului care va apărea în traces și metrici.\nDacă serviciul are deja chei în `environment:`, inserăm aceste două variabile acolo. Nu modificăm porturile, volumele sau alte setări de business. După aceste modificări, codul instrumentat (din F0.3.31) va putea trimite telemetrie către colector, iar containerul va fi conectat logic la rețeaua de observabilitate.",
    "directorul_directoarele": [
      "cp/suite-login/compose/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.31 (corectat): Codul suite-login a fost instrumentat pentru observabilitate folosind `@genius-suite/common` (logger) și `@genius-suite/observability` (tracing + metrici). F0.3.12 și F0.3.x din zona observability au definit rețeaua `observability` și serviciul `otel-collector` în compose-ul global dev.",
    "contextul_general_al_aplicatiei": "Menținând consistența cu suite-shell și suite-admin, și aplicația suite-login trebuie să fie vizibilă în observabilitate (traces, metrici, loguri). Conectarea containerului la rețeaua `observability` și setarea variabilelor OTEL aliniază runtime-ul cu arhitectura de observabilitate definită în Capitolul 2.",
    "contextualizarea_directoarelor_si_cailor": "1. Deschide fișierul `cp/suite-login/compose/docker-compose.yml`.\n2. Găsește definiția serviciului principal (ex. `suite-login:`).\n3. În secțiunea `environment:` a serviciului, adaugă:\n   ```yaml\n   - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318\n   - OTEL_SERVICE_NAME=suite-login\n   ```\n   sau, dacă environment este map-style:\n   ```yaml\n   OTEL_EXPORTER_OTLP_ENDPOINT: \"http://otel-collector:4318\"\n   OTEL_SERVICE_NAME: \"suite-login\"\n   ```\n4. În secțiunea `networks:` a serviciului, adaugă `observability` pe lângă rețelele deja existente.\n5. Dacă fișierul definește explicit rețele la final, asigură-te că `observability` este menționată acolo sau este marcată ca rețea externă, în funcție de cum e definită în orchestratorul global (de regulă, este creată în compose-ul din `shared/observability/compose/profiles/`).",
    "restrictii_anti_halucinatie": "Nu modifica numele serviciului, port mapping-ul sau volumele existente. Nu adăuga alte variabile OTEL în acest pas (ex. sampling, log level); ne limităm la endpoint și numele serviciului. Nu crea local o rețea `observability` cu alt nume decât cel folosit în orchestrator.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu introduce servicii noi în acest compose. Nu muta responsabilitatea de definire a rețelei `observability` din orchestratorul global în compose-ul suite-login – acesta doar o consumă.",
    "validare": "1. Pornește orchestrarea dev care include atât stack-ul de observabilitate, cât și suite-login.\n2. Rulează `docker network inspect geniuserp_observability` (sau numele efectiv al rețelei) și verifică faptul că containerul suite-login apare listat.\n3. Rulează `docker compose exec suite-login env` (din directorul `cp/suite-login/compose/`) și confirmă că `OTEL_EXPORTER_OTLP_ENDPOINT` și `OTEL_SERVICE_NAME` sunt prezente și au valorile așteptate.\n4. Verifică logurile suite-login la startup pentru a confirma că inițializarea OTEL folosește endpoint-ul și service name-ul corect (dacă există logging pentru asta).",
    "outcome": "Configurația Docker Compose pentru suite-login este actualizată: containerul este atașat la rețeaua de observabilitate și expune variabilele de mediu OTEL necesare pentru a trimite telemetrie către `otel-collector`.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.33

```JSON
  {
  "F0.3.33": {
    "denumire_task": "Integrare Observabilitate în identity (Cod)",
    "descriere_scurta_task": "Instrumentează aplicația identity pentru observabilitate: inițializează tracing-ul OTEL, metricile Prometheus și logger-ul Pino la pornire.",
    "descriere_lunga_si_detaliata_task": "Pentru aplicația stand-alone **identity** (parte a Control Plane), integrăm observabilitatea la nivel de cod. În punctul de intrare al serverului (ex. `src/main.ts` sau `src/index.ts`):\n- **Logger (Pino)**: importăm logger-ul partajat din `@genius-suite/common` (ex. `import { logger } from '@genius-suite/common';`) și îl injectăm în framework (Fastify / Express etc.) astfel încât toate logurile să fie JSON unificate.\n- **Tracing OTEL**: importăm funcția de inițializare a tracing-ului din `@genius-suite/observabilit`y (ex. `import { initTracing } from '@genius-suite/observability';`) și o apelăm cât mai devreme, înainte de crearea serverului HTTP. `initTracing` citește configurarea din env (ex. `OTEL_EXPORTER_OTLP_ENDPOINT`, `OTEL_SERVICE_NAME=identity`).\n- **Metrici Prometheus**: importăm inițializarea metricilor și registrul Prometheus (ex. `import { initMetrics, metricsRegistry } from '@genius-suite/observability';`). La startup apelăm `initMetrics()` și adăugăm o rută `/metrics` în aplicație care răspunde cu `metricsRegistry.metrics()` având header `text/plain; version=0.0.4`.\n- Ne asigurăm că toate erorile neașteptate sunt logate prin logger-ul comun (ex. handler global de erori care folosește `logger.error`).\nDupă aceste modificări, identity va produce loguri JSON, va emite metrici Prometheus și va genera trace-uri OTEL, toate compatibile cu stack-ul de observabilitate (otel-collector, Prometheus, Tempo, Loki).",
    "directorul_directoarele": [
      "cp/identity/",
      "cp/identity/compose/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.1–F0.3.10 (corectate): au creat pachetul `@genius-suite/observability` cu modulele pentru tracing și metrici, precum și `@genius-suite/common` cu logger-ul Pino partajat. În F0.3.21+ este definit stack-ul de observabilitate (otel-collector, Prometheus etc.) în compose dev.",
    "contextul_general_al_aplicatiei": "identity este un serviciu critic de autentificare/identitate în Control Plane și trebuie să fie complet observabil: loguri, metrici și trace-uri centralizate. Acest task aliniază comportamentul lui cu restul serviciilor CP (suite-shell, suite-admin, suite-login), conform arhitecturii din Capitolul 2 (logging în `shared/common/logger`, tracing/metrics în `shared/observability`).",
    "contextualizarea_directoarelor_si_cailor": "1. Deschide fișierul de startup al serviciului identity (ex. `cp/identity/src/main.ts`).\n2. Adaugă importuri de forma:\n   ```ts\n   import { logger } from '@genius-suite/common';\n   import { initTracing, initMetrics, metricsRegistry } from '@genius-suite/observability';\n   ```\n3. Imediat la startup (înainte de a crea serverul):\n   ```ts\n   initTracing({ serviceName: process.env.OTEL_SERVICE_NAME ?? 'identity' });\n   initMetrics();\n   ```\n4. Creează instanța Fastify/Express folosind logger-ul comun:\n   ```ts\n   const app = fastify({ logger });\n   ```\n5. Adaugă ruta `/metrics`:\n   ```ts\n   app.get('/metrics', async (_req, reply) => {\n     const metrics = await metricsRegistry.metrics();\n     reply.header('Content-Type', 'text/plain; version=0.0.4');\n     reply.send(metrics);\n   });\n   ```\n6. Păstrează celelalte rute existente neschimbate. Nu schimba portul sau comportamentul funcțional; doar adaugă cross-cutting concerns de observabilitate.",
    "restrictii_anti_halucinatie": "Folosește doar logger-ul din `@genius-suite/common` și modulele de tracing/metrics din `@genius-suite/observability`. Nu introduce un al doilea client Prometheus sau o a doua instanță Pino locală. Nu inventa nume de variabile de mediu noi; bazează-te pe `OTEL_EXPORTER_OTLP_ENDPOINT` și `OTEL_SERVICE_NAME` definite la nivel de container.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu muta logica de business în alt fișier, doar învelește inițializarea cu observabilitate. Nu introduce aici configurări OTEL avansate (sampling, exporters suplimentare); acestea vor fi tratate în faze ulterioare dacă este nevoie.",
    "validare": "1. Rulează local serviciul identity (ex. `pnpm dev` sau `docker compose up identity`).\n2. Accesează `http://localhost:<port>/metrics` și verifică faptul că primești un payload text cu metrici Prometheus valide.\n3. Fă câteva request-uri către API și verifică în consolă că logurile apar JSON (cu `level`, `msg`, `time` etc.).\n4. După ce stack-ul OTEL+Tempo este funcțional, verifică într-un viewer de trace-uri că apar span-uri pentru serviciul `identity` (service name setat prin env).",
    "outcome": "Serviciul identity este instrumentat cu observabilitate: logurile sunt centralizate și structurate, metricile sunt expuse pe `/metrics`, iar trace-urile OTEL sunt trimise către colector conform arhitecturii.",
    "componenta_de_CI_CD": "N/A"
  }
},
```

#### F0.3.34

```JSON
  {
  "F0.3.34": {
    "denumire_task": "Actualizare Docker Compose pentru identity",
    "descriere_scurta_task": "Conectează containerul identity la ecosistemul de observabilitate: adaugă rețeaua `observability` și variabilele OTEL în compose-ul aplicației.",
    "descriere_lunga_si_detaliata_task": "În `cp/identity/compose/docker-compose.yml` actualizăm serviciul `identity` pentru a trimite telemetrie către OTEL Collector. Adăugăm rețeaua `observability` la serviciu și setăm variabilele de mediu OTEL necesare. Aceasta permite SDK-ului OTEL (inițializat în cod la F0.3.33 corectat) să comunice cu colectorul prin HTTP/OTLP pe portul 4318.",
    "directorul_directoarele": [
      "cp/identity/compose/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.33 (corectat): codul identity inițializează tracing și metrici din `@genius-suite/observability` și folosește logger-ul din `@genius-suite/common`. F0.3.12 (corectat): rețeaua `observability` este definită în orchestrarea globală (profiles).",
    "contextul_general_al_aplicatiei": "identity este serviciu CP critic; trebuie să emită trace-uri, metrici și loguri corelabile. Conectarea la rețeaua `observability` și setarea variabilelor OTEL aliniază containerul cu stack-ul comun (otel-collector, Prometheus, Loki/Tempo, Grafana).",
    "contextualizarea_directoarelor_si_cailor": "Deschide `cp/identity/compose/docker-compose.yml` și actualizează serviciul:\n\n```yaml\ nservices:\n  identity:\n    environment:\n      - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318\n      - OTEL_SERVICE_NAME=identity\n    networks:\n      - observability\n    # optional (doar pentru orchestrări locale combinate):\n    # depends_on:\n    #   - otel-collector\n```\n\nNu defini `observability` ca rețea `external` aici; ea este declarată și gestionată în orchestrarea globală din `shared/observability/compose/profiles/compose.dev.yml`. Acest fișier doar face referință la rețea.",
    "restrictii_anti_halucinatie": "Nu modifica alte secțiuni (ports, volumes etc.). Nu redenumi rețeaua sau serviciul. Nu adăuga alte variabile OTEL în afara celor două necesare aici.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu marca rețeaua ca `external` în acest compose. Nu introduce servicii noi; configurarea collectorului aparține orchestrării globale.",
    "validare": "Rulează orchestrarea dev completă. Verifică: (1) containerul identity este atașat la `observability` (`docker network inspect <proiect>_observability`), (2) în interiorul containerului există variabilele (`docker compose exec identity env | grep OTEL_`), (3) logul de startup arată endpoint-ul OTLP corect, iar `/metrics` răspunde.",
    "outcome": "Containerul identity este conectat la rețeaua de observabilitate și configurat prin env să trimită telemetrie către `otel-collector`.",
    "componenta_de_CI_CD": "Poate fi verificat într-un job de pipeline (smoke) care ridică profile-ul dev și rulează health-checkuri pe `/metrics` și pe colector."
  }
},
```

#### F0.3.35

```JSON
  {
  "F0.3.35": {
    "denumire_task": "Integrare Observabilitate în licensing (Cod) — CORECTAT",
    "descriere_scurta_task": "Instrumentează aplicația cp/licensing: inițializează tracing (OTEL) și metrici (Prometheus) din @genius-suite/observability și folosește logger-ul Pino din @genius-suite/common; expune endpoint-ul /metrics.",
    "descriere_lunga_si_detaliata_task": "Corectăm importurile conform arhitecturii: logger-ul Pino provine din pachetul comun (@genius-suite/common/logger), iar tracing-ul și metricile din pachetul de observabilitate (@genius-suite/observability). În punctul de intrare al serviciului (ex. cp/licensing/src/main.ts), inițializăm cât mai devreme tracing-ul (initTracing), configurăm logger-ul Pino în server (ex. Fastify) și expunem ruta /metrics folosind registrul Prometheus expus de modulul observability. Notă: variabilele de mediu OTEL (ex. OTEL_SERVICE_NAME, OTEL_EXPORTER_OTLP_ENDPOINT) vor fi setate în task-ul de compose aferent (următorul pas, nu în acesta).",
    "directorul_directoarele": [
      "cp/licensing/",
      "cp/licensing/src/",
      "cp/licensing/compose/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.7, F0.3.9 și F0.3.10 corectate: exporturile din @genius-suite/observability sunt aliniate pe trasee 'traces/*' și 'metrics/recorders/*'. Logger-ul este în @genius-suite/common/logger. Acest task consumă acele module corectate.",
    "contextul_general_al_aplicatiei": "licensing este serviciu CP; trebuie monitorizat la fel ca restul: loguri JSON corelabile, trace-uri OTEL, metrici Prometheus. Integrarea la nivel de cod este primul pas; conectarea containerului la rețeaua 'observability' și setarea variabilelor OTEL se face în task-ul de compose dedicat.",
    "contextualizarea_directoarelor_si_cailor": "1) Deschide 'cp/licensing/src/main.ts' (sau intrarea reală).\n2) Adaugă importurile corecte:\n   import { logger } from '@genius-suite/common/logger';\n   import { initTracing, initMetrics, promRegister } from '@genius-suite/observability';\n3) Inițializează tracing-ul foarte devreme în runtime:\n   initTracing({ serviceName: process.env.OTEL_SERVICE_NAME || 'licensing' });\n4) Creează/actualizează serverul (ex. Fastify) cu logger-ul comun:\n   const app = Fastify({ logger });\n5) Inițializează metricile (registru default prom-client prin observability):\n   await initMetrics();\n6) Expune endpoint-ul '/metrics':\n   app.get('/metrics', async (_req, reply) => {\n     reply.type('text/plain');\n     return promRegister.metrics();\n   });\n7) Pornește serverul în mod obișnuit (listen).",
    "restrictii_anti_halucinatie": "NU importa logger-ul din '@genius-suite/observability'. NU reimplementa un alt client Prometheus; folosește registrul expus de pachetul de observabilitate. NU introduce configurări OTEL avansate (sampling, processors) în acest task.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "NU modifica configurația containerului aici; variabilele OTEL și rețeaua 'observability' vor fi gestionate în task-ul de Compose al licensing. NU crea directoare noi în afara celor prevăzute de arhitectură.",
    "validare": "1) Rulează local serviciul (pnpm run dev sau echivalent) cu env minimal: OTEL_SERVICE_NAME=licensing. 2) Accesează 'http://localhost:{port}/metrics' și verifică răspunsul text Prometheus. 3) Verifică în loguri că ieșirea este JSON Pino (chei level, msg, time) și că nu există erori de inițializare OTEL. 4) Opțional, execută un request simplu la o rută și observă că totul funcționează fără erori de observabilitate.",
    "outcome": "Codul licensing exportă metrici pe /metrics, folosește logger-ul comun Pino și inițializează trasabilitatea OTEL corect, pregătit pentru conectarea la infrastructura de observabilitate.",
    "componenta_de_CI_CD": "Se poate adăuga un smoke test de componentă care pornește aplicația în mod test și verifică status 200 pe '/metrics' și prezența cheilor de log Pino într-un request."
  }
},
```

#### F0.3.36

```JSON
  {
  "F0.3.36": {
    "denumire_task": "Actualizare Docker Compose pentru licensing — CORECTAT",
    "descriere_scurta_task": "Conectează containerul cp/licensing la observabilitate: adaugă rețeaua externă 'geniuserp_observability' și variabilele OTEL corecte.",
    "descriere_lunga_si_detaliata_task": "Aplicăm modificările strict în fișierul Compose al aplicației, aliniat cu arhitectura. Atașăm serviciul 'licensing' la rețeaua externă de observabilitate (creată în stack-ul shared) și setăm variabilele de mediu OTEL pentru a puncta către collector. Nu adăugăm 'depends_on' către servicii din alt fișier Compose (nu funcționează cross-project).",
    "directorul_directoarele": [
      "cp/licensing/compose/"
    ],
    "contextul_taskurilor_anterioare": "Prerechizite: F0.3.35 (instrumentare cod licensing) CORECTAT; F0.3.11–F0.3.14 CORECTATE (mutarea compose-ului observability în 'shared/observability/compose/profiles/compose.dev.yml', corectarea volumelor și definirea rețelei externe 'geniuserp_observability').",
    "contextul_general_al_aplicatiei": "Conectarea containerului la rețeaua de observabilitate și definirea variabilelor OTEL permit aplicației să emită trace-uri/metrici către OTEL Collector și să fie vizibilă în platforma de observabilitate.",
    "contextualizarea_directoarelor_si_cailor": "Deschide 'cp/licensing/compose/docker-compose.yml' și aplică următoarele:\n\n1) În definiția serviciului (ex. services.licensing):\n   \n   ```yaml\n   services:\n     licensing:\n       environment:\n         - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318\n         - OTEL_SERVICE_NAME=licensing\n       networks:\n         - observability\n         # ... restul configurării existente rămâne neschimbat\n   ```\n\n2) La finalul fișierului (dacă nu există deja blocul 'networks') adaugă rețeaua externă:\n   \n   ```yaml\n   networks:\n     observability:\n       external: true\n       name: geniuserp_observability\n   ```\n\nObservații: păstrează toate rețelele existente ale serviciului; doar adaugă 'observability'. Nu modifica porturi/volume existente.",
    "restrictii_anti_halucinatie": "Nu adăuga 'depends_on' către 'otel-collector' (este în alt proiect Compose). Nu redenumi serviciul sau rețeaua. Nu seta alte variabile OTEL neprevăzute.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu crea o rețea nouă locală numită 'observability'; trebuie folosită rețeaua externă 'geniuserp_observability' definită de stack-ul shared. Nu schimba structura folderelor.",
    "validare": "1) Validează sintaxa: `docker compose -f cp/licensing/compose/docker-compose.yml config`.\n2) Pornește serviciul în contextul în care rulează și stack-ul observability: `docker compose up -d licensing` (sau orchestratorul tău curent).\n3) Verifică atașarea la rețea: `docker network inspect geniuserp_observability` și confirmă că apare containerul licensing.\n4) Verifică variabilele în container: `docker compose exec licensing printenv | grep OTEL_`.\n5) Verifică rezoluția DNS către collector: `docker compose exec licensing getent hosts otel-collector` (trebuie să returneze o adresă).",
    "outcome": "Containerul 'licensing' este conectat la rețeaua de observabilitate și are variabilele OTEL setate corect, gata să comunice cu OTEL Collector.",
    "componenta_de_CI_CD": "Adaugă în pipeline o verificare `docker compose config` pentru cp/licensing și un smoke-test care confirmă prezența rețelei 'geniuserp_observability' în runtime."
  }
},
```

#### F0.3.37

```JSON
  {
  "F0.3.37": {
    "denumire_task": "Integră Observabilitate în analytics-hub (Cod) — CORECTAT",
    "descriere_scurta_task": "Instrumentează cp/analytics-hub: init tracing OTEL, expune /metrics Prometheus și folosește logger-ul din @genius-suite/common (nu din observability).",
    "descriere_lunga_si_detaliata_task": "Aliniază integrarea la arhitectură: logger-ul provine din pachetul comun, iar tracing/metrics din pachetul de observabilitate pe căile corecte. Modificăm punctul de intrare al serverului (ex. `cp/analytics-hub/src/main.ts` sau `src/index.ts`) astfel:\n\n1) **Logging (corect):**\n   ```ts\n   import { logger } from '@genius-suite/common';\n   // Fastify:\n   const app = fastify({ logger });\n   ```\n\n2) **Tracing (OTEL):**\n   ```ts\n   import { initTracing } from '@genius-suite/observability/traces/otel';\n   await initTracing({ serviceName: process.env.OTEL_SERVICE_NAME || 'analytics-hub' });\n   ```\n\n3) **Metrici Prometheus:**\n   ```ts\n   import { metricsRegistry, initDefaultMetrics } from '@genius-suite/observability/metrics/recorders/prometheus';\n   // registrează metricile default (proces, runtime, event loop etc.)\n   initDefaultMetrics();\n\n   app.get('/metrics', async (_req, reply) => {\n     reply.type('text/plain');\n     return metricsRegistry.metrics();\n   });\n   ```\n\n4) **Ordinea inițializărilor:** pornește tracing **înainte** de a crea conexiuni externe/porni serverul; configurează Fastify cu `logger` din pachetul comun; adaugă ruta `/metrics`;\n\n5) **Config runtime:**\n   - `OTEL_EXPORTER_OTLP_ENDPOINT` (ex. `http://otel-collector:4318`)\n   - `OTEL_SERVICE_NAME=analytics-hub`\n\nAceste modificări asigură loguri JSON consistente, trace-uri OTEL și endpoint de metrici compatibil Prometheus.",
    "directorul_directoarele": [
      "cp/analytics-hub/",
      "cp/analytics-hub/src/",
      "cp/analytics-hub/compose/"
    ],
    "contextul_taskurilor_anterioare": "Necesită corecțiile din F0.3.7 (mutare în `shared/observability/traces/`), F0.3.9 (mutare în `shared/observability/metrics/recorders/`) și F0.3.10 (index care re-exportă corect SAU importuri pe sub-căi ca mai sus). Logger-ul există în `shared/common/logger` și este expus de `@genius-suite/common`.",
    "contextul_general_al_aplicatiei": "analytics-hub este parte CP și trebuie monitorizat uniform: loguri JSON, trace-uri OTEL, metrici Prometheus. Integrarea corectă previne duplicarea responsabilităților și erori de rezolvare a modulelor.",
    "contextualizarea_directoarelor_si_cailor": "Modifică fișierul de intrare al serverului (ex. `cp/analytics-hub/src/main.ts`). Dacă proiectul folosește alt nume (ex. `index.ts`), aplică identic acolo. Nu crea un nou pachet pentru logger; importă din `@genius-suite/common`. Pentru observability, importă explicit din sub-căile `traces/otel` și `metrics/recorders/prometheus` pentru a evita ambiguități.",
    "restrictii_anti_halucinatie": "Nu importa `logger` din `@genius-suite/observability`. Nu adăuga alte endpoint-uri sau sampling OTEL avansat. Nu schimba logica de business.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu muta structura directoarelor aplicației. Nu introduce noi dependențe; folosește cele comune deja planificate.",
    "validare": "1) Pornește aplicația în dev și verifică că nu apar erori de import pentru observability/common. 2) Accesează `GET /metrics` → trebuie să returneze text Prometheus. 3) Generează trafic pe o rută și confirmă că logurile apar JSON cu câmpurile standard; dacă propagarea contextului OTEL este activă, poți include traceId în formatterele Pino din pachetul comun. 4) Cu stack-ul de observabilitate pornit, confirmă că collector primește trace-uri (ex. prin Tempo/Grafana).",
    "outcome": "analytics-hub emite corect trace-uri OTEL, expune `/metrics` pentru Prometheus și folosește logger-ul comun, conform arhitecturii.",
    "componenta_de_CI_CD": "Adaugă un smoke-test care face `GET /metrics` și verifică `Content-Type: text/plain; version=0.0.4`. Rulează linters/build pentru a prinde importuri greșite."
  }
},
```

#### F0.3.38

```JSON
  {
  "F0.3.38": {
    "denumire_task": "Actualizare Docker Compose pentru analytics-hub — CORECTAT",
    "descriere_scurta_task": "Atașează cp/analytics-hub la rețeaua de observabilitate definită global și setează variabilele OTEL, aliniat cu arhitectura (network external + compose profiles).",
    "descriere_lunga_si_detaliata_task": "În `cp/analytics-hub/compose/docker-compose.yml`, conectează serviciul la rețeaua de observabilitate **externă** (creată de stack-ul din `shared/observability/compose/profiles/compose.dev.yml`) și setează variabilele OTEL.\n\n1) **Networks (external, denumire stabilă):**\nAdaugă rețeaua `observability` la serviciul `analytics-hub` și declară rețeaua ca **external** la finalul fișierului pentru a evita coliziuni de nume între proiecte Compose.\n\n```yaml\nservices:\n  analytics-hub:\n    # ... existing config ...\n    networks:\n      - observability\n    environment:\n      - OTEL_EXPORTER_OTLP_ENDPOINT=${OTEL_EXPORTER_OTLP_ENDPOINT:-http://otel-collector:4318}\n      - OTEL_SERVICE_NAME=${OTEL_SERVICE_NAME:-analytics-hub}\n    # optional, doar pentru dev local orchestrat împreună cu observability\n    # depends_on:\n    #   - otel-collector\n\nnetworks:\n  observability:\n    external: true\n    name: ${GS_OBS_NET:-observability}\n```\n\n2) **Variabile de mediu:**\n- `OTEL_EXPORTER_OTLP_ENDPOINT` indică endpoint-ul OTLP/HTTP al colectorului (implicit `http://otel-collector:4318`).\n- `OTEL_SERVICE_NAME` stabilește identitatea serviciului în telemetrie (implicit `analytics-hub`).\n- (Opțional) definește în `.env` valorile pentru `GS_OBS_NET`, `OTEL_EXPORTER_OTLP_ENDPOINT` și `OTEL_SERVICE_NAME`.\n\n3) **Compatibilitate rețea:**\nStack-ul de observabilitate trebuie să creeze o rețea Docker numită `observability` (sau valoarea din `GS_OBS_NET`). Declararea ca `external: true` previne recrearea unei rețele separate în acest compose.",
    "directorul_directoarele": [
      "cp/analytics-hub/compose/"
    ],
    "contextul_taskurilor_anterioare": "Necesită corecții la F0.3.11–F0.3.14 (mutarea și repararea `shared/observability/compose/profiles/compose.dev.yml` + volume corecte) și implementarea corectă a F0.3.37 (instrumentarea codului cu logger din @genius-suite/common și OTEL/Prometheus din @genius-suite/observability pe căile `traces/` și `metrics/recorders/`).",
    "contextul_general_al_aplicatiei": "analytics-hub trebuie să emită trace-uri/metrici către colectorul OTEL și să fie accesibil pentru Prometheus în aceeași rețea Docker; variabilele OTEL oferă configurabilitate pe medii.",
    "contextualizarea_directoarelor_si_cailor": "Editează `cp/analytics-hub/compose/docker-compose.yml`. La serviciul `analytics-hub`, adaugă `networks: [observability]` și cheile din `environment:`. La finalul fișierului, declară blocul `networks:` cu `observability` ca `external: true` și `name: ${GS_OBS_NET:-observability}`. Nu elimina alte rețele existente ale serviciului.",
    "restrictii_anti_halucinatie": "Nu redenumi serviciul sau alte rețele existente; nu adăuga port mapping/volume neprevăzute. Nu seta alte variabile OTEL decât cele două necesare.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu marca rețeaua drept internal; trebuie să fie rețea comună cu stack-ul de observabilitate. Nu introduce dependențe noi în compose.",
    "validare": "1) `docker compose -f cp/analytics-hub/compose/docker-compose.yml config` trebuie să treacă. 2) `docker network ls` trebuie să conțină rețeaua `${GS_OBS_NET:-observability}` creată de stack-ul observability. 3) `docker compose up -d analytics-hub` și apoi `docker inspect <container>` → în `Networks` trebuie să apară rețeaua observability. 4) `docker compose exec analytics-hub printenv | grep OTEL_` arată variabilele setate. 5) Dacă serviciul rulează, `curl http://localhost:<port>/metrics` trebuie să răspundă cu text Prometheus.",
    "outcome": "Containerul analytics-hub este conectat la rețeaua de observabilitate definită global și are variabilele OTEL setate corect, gata să comunice cu colectorul.",
    "componenta_de_CI_CD": "Adaugă un job de smoke-test care rulează `docker compose config` pe acest fișier și verifică prezența rețelei external `observability`, plus un healthcheck simplu pe `GET /metrics` (dacă este expus în dev)."
  }
},
```

#### F0.3.39

```JSON
  {
  "F0.3.39": {
    "denumire_task": "Integră Observabilitate în ai-hub (Cod) — CORECTAT",
    "descriere_scurta_task": "Instrumentează cp/ai-hub cu logger-ul din @genius-suite/common și OTEL/Prometheus din @genius-suite/observability (căi corecte), expune /metrics.",
    "descriere_lunga_si_detaliata_task": "În entrypoint-ul cp/ai-hub: (1) setează defaults pentru OTEL din env (OTEL_SERVICE_NAME=ai-hub, OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318), (2) apelează initTracing() din @genius-suite/observability/traces/otel cât mai devreme, (3) creează Fastify cu logger din @genius-suite/common, (4) expune GET /metrics folosind registrul prom-client exportat din @genius-suite/observability/metrics/recorders/prometheus. În pachetul shared/observability, asigură-te că index.ts re-exportă corect din 'traces/otel' și 'metrics/recorders/prometheus'.",
    "directorul_directoarele": [
      "cp/ai-hub/",
      "shared/observability/src/"
    ],
    "contextul_taskurilor_anterioare": "Necesită corectarea F0.3.7, F0.3.9, F0.3.10 (căi corecte: traces/otel, metrics/recorders/prometheus și re-export în index.ts) și confirmarea că logger-ul Pino este în @genius-suite/common.",
    "contextul_general_al_aplicatiei": "ai-hub trebuie să emită trace-uri către OTEL Collector, să expună metrici Prometheus și să logheze JSON unitar pentru corelare (Loki/Tempo/Prometheus).",
    "contextualizarea_directoarelor_si_cailor": "Modifică cp/ai-hub/src/main.ts (sau fișierul de bootstrap echivalent). În shared/observability/src/index.ts adaugă re-exporturile corecte.",
    "restrictii_anti_halucinatie": "Nu importa logger-ul din @genius-suite/observability. Nu adăuga clienți Prometheus adiționali; folosește exportul din modulul comun de observabilitate.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu modifica logica de business; doar bootstrap cross-cutting. Nu adăuga sampling/filtre OTEL avansate în acest pas.",
    "validare": "1) `pnpm build -r` fără erori. 2) `curl http://localhost:8080/metrics` întoarce text Prometheus. 3) Logurile apar JSON cu câmpuri standard. 4) După ce compui cu observability, trace-urile apar în Tempo și endpoint-ul /metrics este scrapat de Prometheus.",
    "outcome": "ai-hub emite trace-uri, expune metrici și loghează structurat, compatibil cu stack-ul de observabilitate.",
    "componenta_de_CI_CD": "Adaugă un job de smoke-test care rulează serverul în mod ephemeral și verifică `GET /metrics` (HTTP 200, Content-Type text/plain).",
    "status": "completed"
  }
},
```

#### F0.3.40

```JSON
  {
  "F0.3.40": {
    "denumire_task": "Actualizare Docker Compose pentru ai-hub — CORECTAT",
    "descriere_scurta task": "Atașează ai-hub la rețeaua globală 'observability' și setează variabilele OTEL, fără a altera alte setări ale serviciului.",
    "descriere_lunga si detaliata_task": "În cp/ai-hub/compose/docker-compose.yml: 1) adaugă 'observability' în lista de networks a serviciului ai-hub (rețeaua este definită global în compose/profiles/observability/compose.dev.yml), 2) setează environment: OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318 și OTEL_SERVICE_NAME=ai-hub, 3) (opțional) depends_on: [otel-collector] când rulezi compus cu profilul observability. Nu modifica volumes/ports/alte setări.",
    "directorul_directoarele": [
      "cp/ai-hub/compose/",
      "compose/profiles/observability/"
    ],
    "contextul_taskurilor_anterioare": "Necesită F0.3.39 (instrumentare cod) CORECTAT + F0.3.11–F0.3.14 mutate/aliniate sub compose/profiles/observability cu rețeaua 'observability' definită acolo.",
    "contextul_general al aplicatiei": "Asigură conectivitatea ai-hub → OTEL Collector pe aceeași rețea Docker pentru export de trace/metrics.",
    "contextualizarea directoarelor si cailor": "App-ul referă doar rețeaua 'observability'; definirea ei rămâne în orchestratorul global (compose/profiles/observability/compose.dev.yml).",
    "restrictii_anti halucinatie": "Nu marca rețeaua observability ca 'external' în acest fișier; este definită în orchestrator. Nu adăuga alte variabile/servicii.",
    "restrictii de iesire din context sau de inventare de sub_taskuri": "Nu modifica logica serviciului și nu altera alte rețele existente.",
    "validare": "1) docker compose -f compose/profiles/observability/compose.dev.yml -f cp/ai-hub/compose/docker-compose.yml up -d; 2) docker compose ps (ai-hub și otel-collector UP); 3) curl http://localhost:8080/metrics → 200 text/plain; 4) fără erori OTEL în logs.",
    "outcome": "ai-hub este conectat la ecosistemul de observabilitate și exportă telemetrie corespunzător.",
    "componenta de CI DI": "Smoke test CI: boot ai-hub + profil observability și assert pe GET /metrics (200, content-type text/plain)."
  }
},
```

#### F0.3.41

```JSON
  {
  "F0.3.41": {
    "denumire_task": "Integră Observabilitate în archify.app (Cod) — CORECTAT",
    "descriere_scurta_task": "Inițializează OTEL (traces), expune /metrics (Prometheus) și setează logger-ul Pino din @genius-suite/common.",
    "descriere_lunga si detaliata_task": "În entrypoint-ul archify.app: 1) importă și rulează initTracing() din @genius-suite/observability; 2) folosește logger-ul Pino din @genius-suite/common; 3) expune ruta /metrics folosind registerPrometheusRoute() din @genius-suite/observability. Respectă arhitectura: logger-ul în pachetul common, traces/metrics în pachetul observability cu layout-ul corect (traces/..., metrics/recorders/...).",
    "directorul_directoarele": [
      "archify.app/",
      "shared/common/",
      "shared/observability/"
    ],
    "contextul_taskurilor_anterioare": "Necesită corectarea F0.3.1–F0.3.10 (layout & exporturi Observability/Common) pentru a rezolva importurile.",
    "contextul_general al aplicatiei": "archify.app trebuie să emită loguri structurate, metrici și trace-uri în stack-ul comun de observabilitate.",
    "contextualizarea directoarelor si cailor": "Importă logger-ul din @genius-suite/common; importă initTracing și registerPrometheusRoute din @genius-suite/observability (care re-exportă din traces/ și metrics/recorders/).",
    "restrictii_anti halucinatie": "Nu instala client Prometheus separat în app; folosește registrul expus de modulul comun. Nu muta responsabilități între pachete.",
    "restrictii de iesire din context sau de inventare de sub_taskuri": "Nu introduce sampling/optimizări OTEL avansate acum; skeleton doar.",
    "validare": "Rulează app-ul local, verifică logs fără erori OTEL; GET /metrics returnează metrice; logurile sunt JSON și includ meta de trace când collectorul este disponibil.",
    "outcome": "archify.app este instrumentat corect și pregătit de conectare la infrastructura de observabilitate.",
    "componenta_de_CI_CD": "Smoke-test CI: pornește serverul și verifică HTTP 200 pe /metrics, Content-Type text/plain."
  }
},
```

#### F0.3.42

```JSON
  {
  "F0.3.42": {
    "denumire_task": "Actualizare Docker Compose pentru archify.app — CORECTAT",
    "descriere_scurta task": "Atașează archify.app la rețeaua Observability și setează variabilele OTEL.",
    "descriere_lunga si detaliata_task": "În archify.app/compose/docker-compose.yml: 1) adaugă rețeaua 'observability' cu nume ${COMPOSE_PROJECT_NAME}_observability; 2) setează OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318 și OTEL_SERVICE_NAME=archify.app; 3) (opțional) depends_on: otel-collector când rulează în același proiect. Rulează împreună cu infra/observability/compose/profiles/dev/docker-compose.yml sub același COMPOSE_PROJECT_NAME.",
    "directorul_directoarele": [
      "archify.app/compose/",
      "infra/observability/compose/profiles/dev/"
    ],
    "contextul_taskurilor_anterioare": "Necesită corectarea F0.3.11–F0.3.14 (plasarea corectă a observability stack și rețelei) și F0.3.41 (instrumentarea codului archify.app).",
    "validare": "docker network inspect ${COMPOSE_PROJECT_NAME}_observability include archify-app; env din container conține variabilele OTEL; /metrics din archify.app răspunde 200.",
    "outcome": "archify.app atașat la Observability, gata să exporte trace-uri și metrici.",
    "componenta_de_CI_CD": "Job de smoke test: pornește collector + archify.app cu compose multi-file, verifică /metrics și atașarea la rețea."
  }
},
```

#### F0.3.43

```JSON
  {
  "F0.3.43": {
    "denumire_task": "Integră Observabilitate în cerniq.app (Cod)",
    "descriere_scurta_task": "Inițializează OTEL, expune /metrics, folosește logger Pino comun în cerniq.app.",
    "descriere_lunga si detaliata_task": "În `cerniq.app`, instrumentăm serverul Fastify astfel: (1) pornim tracing OTEL cât mai devreme; (2) folosim logger-ul comun Pino; (3) expunem endpoint-ul Prometheus `/metrics`. Pași:\n1) Deschide/creează `cerniq.app/src/index.ts`.\n2) Adaugă:\n```\nimport { initTracing, registerMetricsRoute } from '@genius-suite/observability';\nawait initTracing();\nimport { buildLogger } from '@genius-suite/common/logger';\nimport Fastify from 'fastify';\nconst serviceName = process.env.OTEL_SERVICE_NAME ?? 'cerniq.app';\nconst app = Fastify({ logger: buildLogger(serviceName) });\nregisterMetricsRoute(app, '/metrics');\nconst port = Number(process.env.PORT ?? 3000);\nawait app.listen({ port, host: '0.0.0.0' });\n```\n3) Asigură-te că pachetul app importă corect modulele `@genius-suite/common/logger` și `@genius-suite/observability`.\n4) Nu adăuga alți clienți Prometheus/OTEL în aplicație.",
    "directorul_directoarele": [
      "cerniq.app/",
      "cerniq.app/src/"
    ],
    "contextul_taskurilor_anterioare": "Corecții F0.3.1–F0.3.10 aplicate: logger în shared/common/logger; OTEL în shared/observability/traces; Prometheus în shared/observability/metrics/recorders.",
    "contextul_general_al_aplicatiei": "cerniq.app este app stand-alone, trebuie să emită trace-uri, metrici și loguri consistente cu restul suitei.",
    "contextualizarea_directoarelor si_cailor": "Importă logger din `@genius-suite/common/logger` și utilitare observability din `@genius-suite/observability` (index-ul acestuia reexportă din `traces/` și `metrics/recorders/`).",
    "restrictii_anti_halucinatie": "Nu importa logger din @genius-suite/observability. Nu crea directoare `telemetry/` sau `metrics/` ad-hoc în app. Nu dubla /metrics.",
    "restrictii_de_iesire din context sau de inventare de sub_taskuri": "Nu modifica porturi, volumes sau alte servicii. Fără sampling custom în acest moment.",
    "validare": "Rulează local: `pnpm dev`. Deschide `http://localhost:3000/metrics` și verifică metricile. În loguri trebuie să apară name=OTEL_SERVICE_NAME. Trace-urile trebuie să fie trimise către collector dacă există la `OTEL_EXPORTER_OTLP_ENDPOINT`.",
    "outcome": "cerniq.app instrumentat corect: OTEL on, /metrics expus, logger comun Pino activ.",
    "componenta_de_CI_CD": "Adaugă job lint/build/test; rulează un e2e simplu care lovește `/metrics` și verifică 200 + content-type text/plain; version bump minor."}
  },
```

#### F0.3.44

```JSON
  {
  "F0.3.44": {
    "denumire_task": "Actualizare Docker Compose pentru cerniq.app",
    "descriere_scurta_task": "Leagă cerniq.app la rețeaua `observability` și setează variabilele OTEL.",
    "descriere_lunga si detaliata_task": "Modifică `cerniq.app/compose/docker-compose.yml` pentru a atașa serviciul la rețeaua `observability` și a injecta variabilele OTEL:\n```\nversion: \"3.9\"\nservices:\n  app:\n    build:\n      context: ..\n      dockerfile: Dockerfile\n    environment:\n      - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318\n      - OTEL_SERVICE_NAME=cerniq.app\n    networks:\n      - default\n      - observability\nnetworks:\n  observability:\n    name: ${COMPOSE_PROJECT_NAME}_observability\n```\nNu declara rețeaua ca external aici; ea este creată de profilul global din `compose/profiles/observability`.",
    "directorul_directoarele": [
      "cerniq.app/compose/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.43 finalizat (cod instrumentat). Profilul `compose/profiles/observability` existent și pornit.",
    "contextul_general_al_aplicatiei": "Asigură conectivitatea de rețea spre `otel-collector` (4318/HTTP).",
    "contextualizarea_directoarelor si_cailor": "`compose/profiles/observability/compose.dev.yml` definește serviciul collector + rețeaua.",
    "restrictii_anti_halucinatie": "Nu redenumi serviciul. Nu adăuga volumes/ports suplimentare. Nu marca rețeaua drept external.",
    "restrictii_de_iesire din context sau de inventare de sub_taskuri": "Nu altera alte servicii din fișier.",
    "validare": "`docker compose -f compose/profiles/observability/compose.dev.yml up -d` apoi `docker compose up -d` în cerniq.app. `docker network inspect ${COMPOSE_PROJECT_NAME}_observability` trebuie să includă containerul app.",
    "outcome": "cerniq.app conectat corect la observability; variabilele OTEL vizibile în env.",
    "componenta_de_CI_CD": "Smoke test container → healthcheck pe `/metrics`."}
  },
```

#### F0.3.45

```JSON
  {
  "F0.3.45": {
    "denumire_task": "Integră Observabilitate în flowxify.app (Cod)",
    "descriere_scurta_task": "OTEL + /metrics + logger Pino comun în flowxify.app.",
    "descriere_lunga si detaliata_task": "În `flowxify.app/src/index.ts` adaugă instrumentarea standard:\n```\nimport { initTracing, registerMetricsRoute } from '@genius-suite/observability';\nawait initTracing();\nimport { buildLogger } from '@genius-suite/common/logger';\nimport Fastify from 'fastify';\nconst serviceName = process.env.OTEL_SERVICE_NAME ?? 'flowxify.app';\nconst app = Fastify({ logger: buildLogger(serviceName) });\nregisterMetricsRoute(app, '/metrics');\nconst port = Number(process.env.PORT ?? 3000);\nawait app.listen({ port, host: '0.0.0.0' });\n```\nNu modifica alte module.",
    "directorul_directoarele": [
      "flowxify.app/",
      "flowxify.app/src/"
    ],
    "contextul_taskurilor_anterioare": "Common logger + observability corectate.",
    "contextul_general_al_aplicatiei": "Unificare observabilitate între aplicațiile suitei.",
    "contextualizarea_directoarelor si_cailor": "Importuri exclusive din modulele comune.",
    "restrictii_anti_halucinatie": "Fără importuri de logger din observability. Fără multiple /metrics.",
    "restrictii_de_iesire din context sau de inventare de sub_taskuri": "Nu introduce configs OTEL suplimentare.",
    "validare": "Rulare locală, verificare `/metrics`, verificare log JSON + service name.",
    "outcome": "flowxify.app instrumentat corect.",
    "componenta_de_CI_CD": "Test minim pe endpoint /metrics."}
  },
```

#### F0.3.46

```JSON
  {
  "F0.3.46": {
    "denumire_task": "Actualizare Docker Compose pentru flowxify.app",
    "descriere_scurta_task": "Atașează flowxify.app la rețeaua `observability` și setează variabilele OTEL.",
    "descriere_lunga si detaliata_task": "Editează `flowxify.app/compose/docker-compose.yml`:\n```\nversion: \"3.9\"\nservices:\n  app:\n    build:\n      context: ..\n    environment:\n      - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318\n      - OTEL_SERVICE_NAME=flowxify.app\n    networks:\n      - default\n      - observability\nnetworks:\n  observability:\n    name: ${COMPOSE_PROJECT_NAME}_observability\n```\nNu marca rețeaua ca external aici.",
    "directorul_directoarele": [
      "flowxify.app/compose/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.45 finalizat; profilul observability pornit.",
    "contextul_general_al_aplicatiei": "Asigură rutarea OTLP HTTP spre collector.",
    "contextualizarea_directoarelor si_cailor": "Rețea definită global în `compose/profiles/observability`.",
    "restrictii_anti_halucinatie": "Fără alte modificări de servicii/volumes.",
    "restrictii_de_iesire din context sau de inventare de sub_taskuri": "Nu schimba numele serviciului.",
    "validare": "Inspectează rețeaua observability; verifică env în container (`docker compose exec app env`).",
    "outcome": "flowxify.app conectat corect la observability.",
    "componenta_de_CI_CD": "Healthcheck pe `/metrics` în pipeline."}
  },
```

#### F0.3.47

```JSON
  {
  "F0.3.47": {
    "denumire_task": "Integră Observabilitate în i-wms.app (Cod)",
    "descriere_scurta_task": "OTEL + /metrics + logger Pino comun în i-wms.app.",
    "descriere_lunga si detaliata_task": "În `i-wms.app/src/index.ts` aplică șablonul standard:\n```\nimport { initTracing, registerMetricsRoute } from '@genius-suite/observability';\nawait initTracing();\nimport { buildLogger } from '@genius-suite/common/logger';\nimport Fastify from 'fastify';\nconst serviceName = process.env.OTEL_SERVICE_NAME ?? 'i-wms.app';\nconst app = Fastify({ logger: buildLogger(serviceName) });\nregisterMetricsRoute(app, '/metrics');\nconst port = Number(process.env.PORT ?? 3000);\nawait app.listen({ port, host: '0.0.0.0' });\n```\nPăstrează restul codului neschimbat.",
    "directorul_directoarele": [
      "i-wms.app/",
      "i-wms.app/src/"
    ],
    "contextul_taskurilor_anterioare": "Common + observability corectate.",
    "contextul_general_al_aplicatiei": "Unificare observabilitate.",
    "contextualizarea_directoarelor si_cailor": "Importuri doar din modulele comune.",
    "restrictii_anti_halucinatie": "Nu adăuga alți exportatori/registries.",
    "restrictii_de_iesire din context sau de inventare de sub_taskuri": "Fără sampling custom deocamdată.",
    "validare": "Rulare locală; verificare /metrics; log JSON; trace-uri spre collector.",
    "outcome": "i-wms.app instrumentat corect.",
    "componenta_de_CI_CD": "Test automat `/metrics`."}
  },
```

#### F0.3.48

```JSON
  {
  "F0.3.48": {
    "denumire_task": "Actualizare Docker Compose pentru i-wms.app",
    "descriere_scurta_task": "Atașează i-wms.app la observability și setează variabilele OTEL.",
    "descriere_lunga si detaliata_task": "Editează `i-wms.app/compose/docker-compose.yml`:\n```\nversion: \"3.9\"\nservices:\n  app:\n    build:\n      context: ..\n    environment:\n      - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318\n      - OTEL_SERVICE_NAME=i-wms.app\n    networks:\n      - default\n      - observability\nnetworks:\n  observability:\n    name: ${COMPOSE_PROJECT_NAME}_observability\n```\nAsigură-te că profilul observability e activ.",
    "directorul_directoarele": [
      "i-wms.app/compose/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.47 finalizat.",
    "contextul_general_al_aplicatiei": "Trimitere OTLP/HTTP la collector.",
    "contextualizarea_directoarelor si_cailor": "Folosește rețeaua globală observability.",
    "restrictii_anti_halucinatie": "Nu adăuga ports/volumes inutile.",
    "restrictii_de_iesire din context sau de inventare de sub_taskuri": "Nu redenumi serviciul.",
    "validare": "`docker network inspect` → container vizibil. `env` conține variabilele OTEL.",
    "outcome": "i-wms.app conectat corect la observability.",
    "componenta_de_CI_CD": "Healthcheck `/metrics`."}
  },
```

#### F0.3.49

```JSON
  {
  "F0.3.49": {
    "denumire_task": "Integră Observabilitate în mercantiq.app (Cod)",
    "descriere_scurta_task": "OTEL + /metrics + logger Pino comun în mercantiq.app.",
    "descriere_lunga si detaliata_task": "În `mercantiq.app/src/index.ts` adaugă:\n```\nimport { initTracing, registerMetricsRoute } from '@genius-suite/observability';\nawait initTracing();\nimport { buildLogger } from '@genius-suite/common/logger';\nimport Fastify from 'fastify';\nconst serviceName = process.env.OTEL_SERVICE_NAME ?? 'mercantiq.app';\nconst app = Fastify({ logger: buildLogger(serviceName) });\nregisterMetricsRoute(app, '/metrics');\nconst port = Number(process.env.PORT ?? 3000);\nawait app.listen({ port, host: '0.0.0.0' });\n```\nNu introduce alte dependențe.",
    "directorul_directoarele": [
      "mercantiq.app/",
      "mercantiq.app/src/"
    ],
    "contextul_taskurilor_anterioare": "Common + observability corectate.",
    "contextul_general_al_aplicatiei": "Conformizare observabilitate în suită.",
    "contextualizarea_directoarelor si_cailor": "Importuri centralizate.",
    "restrictii_anti_halucinatie": "Fără duplicarea /metrics. Fără logger din observability.",
    "restrictii_de_iesire din context sau de inventare de sub_taskuri": "Fără custom exporters.",
    "validare": "Verifică /metrics + log JSON; trace-uri către collector.",
    "outcome": "mercantiq.app instrumentat corect.",
    "componenta_de_CI_CD": "Test endpoint /metrics."}
  },
```

#### F0.3.50

```JSON
  {
  "F0.3.50": {
    "denumire_task": "Actualizare Docker Compose pentru mercantiq.app",
    "descriere_scurta_task": "Atașează mercantiq.app la `observability` și setează variabilele OTEL.",
    "descriere_lunga si detaliata_task": "Editează `mercantiq.app/compose/docker-compose.yml`:\n```\nversion: \"3.9\"\nservices:\n  app:\n    build:\n      context: ..\n    environment:\n      - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318\n      - OTEL_SERVICE_NAME=mercantiq.app\n    networks:\n      - default\n      - observability\nnetworks:\n  observability:\n    name: ${COMPOSE_PROJECT_NAME}_observability\n```\nNu marca rețeaua ca external.",
    "directorul_directoarele": [
      "mercantiq.app/compose/"
    ],
    "contextul_taskurilor_anterioare": "F0.3.49 finalizat; profil observability activ.",
    "contextul_general_al_aplicatiei": "Conectare OTLP/HTTP → collector.",
    "contextualizarea_directoarelor si_cailor": "Rețea unificată în profilul global.",
    "restrictii_anti_halucinatie": "Nu modifica alte servicii/volumes.",
    "restrictii_de_iesire din context sau de inventare de sub_taskuri": "Nu redenumi serviciul.",
    "validare": "Inspectează rețeaua; verifică variabilele OTEL în env.",
    "outcome": "mercantiq.app conectat corect la observability.",
    "componenta_de_CI_CD": "Healthcheck `/metrics` în pipeline."}
  },
```

#### F0.3.51

```JSON
  {
  "F0.3.51": {
    "denumire_task": "Integră Observabilitate în numeriqo.app (Cod)",
    "descriere_scurta_task": "Activează OTEL, expune /metrics și folosește logger-ul Pino comun în numeriqo.app.",
    "descriere_lunga si detaliata_task": "Instrumentează serverul Fastify din numeriqo.app: pornește tracing OTEL devreme, setează logger-ul Pino comun și expune /metrics. Pași:\n1) Deschide/creează `numeriqo.app/src/index.ts`.\n2) Adaugă:\n```\nimport { initTracing, registerMetricsRoute } from '@genius-suite/observability';\nimport { buildLogger } from '@genius-suite/common/logger';\nimport Fastify from 'fastify';\n\nasync function start() {\n  await initTracing();\n  const serviceName = process.env.OTEL_SERVICE_NAME ?? 'numeriqo.app';\n  const app = Fastify({ logger: buildLogger(serviceName) });\n  registerMetricsRoute(app, '/metrics');\n  const port = Number(process.env.PORT ?? 3000);\n  await app.listen({ port, host: '0.0.0.0' });\n}\nstart().catch(err => { console.error(err); process.exit(1); });\n```\n3) Asigură-te că importurile vin din `@genius-suite/common/logger` și `@genius-suite/observability` (care reexportă din `traces/` și `metrics/recorders/`).\n4) Nu adăuga alți clienți Prometheus/OTEL.",
    "directorul_directoarele": ["numeriqo.app/", "numeriqo.app/src/"],
    "contextul_taskurilor_anterioare": "Corecțiile F0.3.1–F0.3.10 aplicate (logger în shared/common/logger; OTEL & Prometheus în shared/observability).",
    "contextul_general_al_aplicatiei": "numeriqo.app trebuie să emită trace-uri, metrici și loguri consistente cu restul suitei.",
    "contextualizarea_directoarelor si_cailor": "Importă logger din `@genius-suite/common/logger` și utilitare observability din `@genius-suite/observability`.",
    "restrictii_anti_halucinatie": "Nu importa logger din @genius-suite/observability. Nu crea directoare `telemetry/` sau `metrics/` în app. Nu dubla ruta /metrics.",
    "restrictii_de_iesire din context sau de inventare de sub_taskuri": "Nu modifica porturi/volumes/servicii în acest task.",
    "validare": "Rulează `pnpm dev`. Accesează `http://localhost:3000/metrics` (200 + text/plain). Verifică log JSON și eticheta service.",
    "outcome": "numeriqo.app instrumentat corect: OTEL on, /metrics expus, logger comun Pino.",
    "componenta_de_CI_CD": "Job smoke pe /metrics (200) și verificare format text/plain."}
  },
```

#### F0.3.52

```JSON
  {
  "F0.3.52": {
    "denumire_task": "Actualizare Docker Compose pentru numeriqo.app",
    "descriere_scurta_task": "Leagă numeriqo.app la rețeaua `observability` și setează variabilele OTEL.",
    "descriere_lunga si detaliata_task": "Editează `numeriqo.app/compose/docker-compose.yml` pentru a atașa serviciul la rețeaua `observability` și a injecta variabilele OTEL:\n```\nversion: \"3.9\"\nservices:\n  app:\n    build:\n      context: ..\n      dockerfile: Dockerfile\n    environment:\n      - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318\n      - OTEL_SERVICE_NAME=numeriqo.app\n    networks:\n      - default\n      - observability\nnetworks:\n  observability:\n    name: ${COMPOSE_PROJECT_NAME}_observability\n```\nRețeaua e creată de profilul global `compose/profiles/observability/compose.dev.yml`.",
    "directorul_directoarele": ["numeriqo.app/compose/"],
    "contextul_taskurilor_anterioare": "F0.3.51 finalizat (cod instrumentat). Profilul observability activ.",
    "contextul_general_al_aplicatiei": "Conectivitate OTLP HTTP spre collector.",
    "contextualizarea_directoarelor si_cailor": "Rețeaua și collectorul sunt definite global.",
    "restrictii_anti_halucinatie": "Nu marca rețeaua external. Nu redenumi serviciul. Fără volumes/ports suplimentare.",
    "restrictii_de_iesire din context sau de inventare de sub_taskuri": "Nu altera alte servicii.",
    "validare": "`docker compose up -d`; `docker network inspect ${COMPOSE_PROJECT_NAME}_observability` conține containerul app; `docker compose exec app env` arată variabilele OTEL.",
    "outcome": "numeriqo.app conectat corect la observability.",
    "componenta_de_CI_CD": "Healthcheck pe `/metrics` în pipeline."}
  },
```

#### F0.3.53

```JSON
  {
  "F0.3.53": {
    "denumire_task": "Integră Observabilitate în triggerra.app (Cod)",
    "descriere_scurta_task": "OTEL + /metrics + logger Pino comun în triggerra.app.",
    "descriere_lunga si detaliata_task": "În `triggerra.app/src/index.ts` aplică șablonul standard:\n```\nimport { initTracing, registerMetricsRoute } from '@genius-suite/observability';\nimport { buildLogger } from '@genius-suite/common/logger';\nimport Fastify from 'fastify';\n\nasync function start() {\n  await initTracing();\n  const serviceName = process.env.OTEL_SERVICE_NAME ?? 'triggerra.app';\n  const app = Fastify({ logger: buildLogger(serviceName) });\n  registerMetricsRoute(app, '/metrics');\n  const port = Number(process.env.PORT ?? 3000);\n  await app.listen({ port, host: '0.0.0.0' });\n}\nstart().catch(err => { console.error(err); process.exit(1); });\n```",
    "directorul_directoarele": ["triggerra.app/", "triggerra.app/src/"],
    "contextul_taskurilor_anterioare": "Common logger + observability corectate.",
    "contextul_general_al_aplicatiei": "Unificare observabilitate între aplicațiile suitei.",
    "contextualizarea_directoarelor si_cailor": "Importuri exclusive din modulele comune.",
    "restrictii_anti_halucinatie": "Fără importuri de logger din observability. Fără multiple /metrics.",
    "restrictii_de_iesire din context sau de inventare de sub_taskuri": "Fără sampling custom.",
    "validare": "Rulare locală, verificare `/metrics`, log JSON + service name.",
    "outcome": "triggerra.app instrumentat corect.",
    "componenta_de_CI_CD": "Test minim pe endpoint /metrics."}
  },
```

#### F0.3.54

```JSON
  {
  "F0.3.54": {
    "denumire_task": "Actualizare Docker Compose pentru triggerra.app",
    "descriere_scurta_task": "Atașează triggerra.app la rețeaua `observability` și setează variabilele OTEL.",
    "descriere_lunga si detaliata_task": "Editează `triggerra.app/compose/docker-compose.yml`:\n```\nversion: \"3.9\"\nservices:\n  app:\n    build:\n      context: ..\n    environment:\n      - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318\n      - OTEL_SERVICE_NAME=triggerra.app\n    networks:\n      - default\n      - observability\nnetworks:\n  observability:\n    name: ${COMPOSE_PROJECT_NAME}_observability\n```",
    "directorul_directoarele": ["triggerra.app/compose/"],
    "contextul_taskurilor_anterioare": "F0.3.53 finalizat; profil observability pornit.",
    "contextul_general_al_aplicatiei": "Rutare OTLP → collector.",
    "contextualizarea_directoarelor si_cailor": "Rețea definită global.",
    "restrictii_anti_halucinatie": "Fără alte modificări de servicii/volumes.",
    "restrictii_de_iesire din context sau de inventare de sub_taskuri": "Nu schimba numele serviciului.",
    "validare": "Inspectează rețeaua observability; verifică env în container.",
    "outcome": "triggerra.app conectat corect la observability.",
    "componenta_de_CI_CD": "Healthcheck `/metrics`."}
  },
```

#### F0.3.55

```JSON
  {
  "F0.3.55": {
    "denumire_task": "Integră Observabilitate în vettify.app (Cod)",
    "descriere_scurta_task": "OTEL + /metrics + logger Pino comun în vettify.app.",
    "descriere_lunga si detaliata_task": "În `vettify.app/src/index.ts` adaugă:\n```\nimport { initTracing, registerMetricsRoute } from '@genius-suite/observability';\nimport { buildLogger } from '@genius-suite/common/logger';\nimport Fastify from 'fastify';\n\nasync function start() {\n  await initTracing();\n  const serviceName = process.env.OTEL_SERVICE_NAME ?? 'vettify.app';\n  const app = Fastify({ logger: buildLogger(serviceName) });\n  registerMetricsRoute(app, '/metrics');\n  const port = Number(process.env.PORT ?? 3000);\n  await app.listen({ port, host: '0.0.0.0' });\n}\nstart().catch(err => { console.error(err); process.exit(1); });\n```",
    "directorul_directoarele": ["vettify.app/", "vettify.app/src/"],
    "contextul_taskurilor_anterioare": "Common + observability corectate.",
    "contextul_general_al_aplicatiei": "Conformizare observabilitate în suită.",
    "contextualizarea_directoarelor si_cailor": "Importuri centralizate (common/logger, observability).",
    "restrictii_anti_halucinatie": "Fără duplicarea /metrics. Fără logger din observability.",
    "restrictii_de_iesire din context sau de inventare de sub_taskuri": "Fără custom exporters.",
    "validare": "Verifică /metrics + log JSON; trace-uri către collector.",
    "outcome": "vettify.app instrumentat corect.",
    "componenta_de_CI_CD": "Test endpoint /metrics."}
  },
```

#### F0.3.56

```JSON
  {
  "F0.3.56": {
    "denumire_task": "Actualizare Docker Compose pentru vettify.app",
    "descriere_scurta_task": "Atașează vettify.app la `observability` și setează variabilele OTEL.",
    "descriere_lunga si detaliata_task": "Editează `vettify.app/compose/docker-compose.yml`:\n```\nversion: \"3.9\"\nservices:\n  app:\n    build:\n      context: ..\n    environment:\n      - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318\n      - OTEL_SERVICE_NAME=vettify.app\n    networks:\n      - default\n      - observability\nnetworks:\n  observability:\n    name: ${COMPOSE_PROJECT_NAME}_observability\n```",
    "directorul_directoarele": ["vettify.app/compose/"],
    "contextul_taskurilor_anterioare": "F0.3.55 finalizat; profil observability activ.",
    "contextul_general_al_aplicatiei": "Conectare OTLP/HTTP → collector.",
    "contextualizarea_directoarelor si_cailor": "Rețea unificată definită global.",
    "restrictii_anti_halucinatie": "Nu modifica alte servicii/volumes. Nu marca rețeaua external.",
    "restrictii_de_iesire din context sau de inventare de sub_taskuri": "Nu redenumi serviciul.",
    "validare": "`docker compose up -d`; inspect network; verifică variabilele OTEL în env.",
    "outcome": "vettify.app conectat corect la observability.",
    "componenta_de_CI_CD": "Healthcheck `/metrics` în pipeline."}
  },
```

#### F0.3.57

```JSON
{
  "F0.3.57": {
    "denumire_task": "Creează scriptul shared/observability/scripts/install.sh (skeleton)",
    "descriere_scurta_task": "Script Bash minimal pentru bootstrap local al stack-ului de observabilitate.",
    "descriere_lunga_si_detaliata_task": "Creează `shared/observability/scripts/install.sh` executabil, cu precondiții și pornire opțională a profilului dev:\n```bash\n#!/usr/bin/env bash\nset -euo pipefail\n\nusage() {\n  cat <<EOF\nUsage: $0 [dev] [--help]\n  dev       Pornește stack-ul de observabilitate pentru dezvoltare\n  --help    Afișează acest mesaj\nEOF\n}\n\ncommand -v docker >/dev/null || { echo \"Eroare: docker lipsă\"; exit 1; }\nif docker compose version >/dev/null 2>&1; then DC=(docker compose); else DC=(docker-compose); fi\n\nMODE=\"${1:-dev}\"\n[[ \"${MODE}\" == \"--help\" ]] && { usage; exit 0; }\n[[ \"${MODE}\" != \"dev\" ]] && { echo \"Doar 'dev' suportat în F0.3\"; exit 2; }\n\nCOMPOSE_FILE=${COMPOSE_FILE:-\"compose/profiles/compose.dev.yml\"}\n\necho \"[install] Verific profilul: ${COMPOSE_FILE}\"\n${DC[@]} -f \"${COMPOSE_FILE}\" config >/dev/null\n\necho \"[install] Pornez stack-ul de observabilitate (dev)\"\n${DC[@]} -f \"${COMPOSE_FILE}\" up -d\n\necho \"[install] OK. Servicii pornite.\"\n```\nSalvează și `chmod +x`.",
    "directorul_directoarele": [
      "shared/observability/scripts/"
    ],
    "contextul_taskurilor_anterioare": "Structura `shared/observability/` definită; profilul compose există.",
    "contextul_general_al_aplicatiei": "Bootstrap rapid pentru dev și pentru utilizare ulterioară în CI.",
    "contextualizarea_directoarelor_si_cailor": "Rulează din rădăcina repo-ului; COMPOSE_FILE poate fi suprascris.",
    "restrictii_anti_halucinatie": "Nu implementa provisioning pentru staging/prod în acest task.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu modifica fișierele de compose.",
    "validare": "`bash shared/observability/scripts/install.sh --help`; apoi `bash .../install.sh` → stack UP.",
    "outcome": "Script skeleton instalare observability (dev) disponibil.",
    "componenta_de_CI_CD": "Va fi folosit în faze ulterioare; deocamdată manual."
  }
},
```

#### F0.3.58

```JSON
{
  "F0.3.58": {
    "denumire_task": "Creează scriptul shared/observability/scripts/validate.sh",
    "descriere_scurta_task": "Standard unic de validare a observabilității (local & CI).",
    "descriere_lunga_si_detaliata_task": "Creează `shared/observability/scripts/validate.sh` executabil, care verifică stack-ul și cel puțin un /metrics:\n```bash\n#!/usr/bin/env bash\nset -euo pipefail\n\nif docker compose version >/dev/null 2>&1; then DC=(docker compose); else DC=(docker-compose); fi\nCOMPOSE_FILE=${COMPOSE_FILE:-\"compose/profiles/compose.dev.yml\"}\nTARGET_METRICS_URL=${TARGET_METRICS_URL:-\"http://localhost:3000/metrics\"}\n\nstep() { echo \"[validate] $1\"; }\n\nstep \"Verific docker compose config\"\n${DC[@]} -f \"${COMPOSE_FILE}\" config >/dev/null\n\nstep \"Verific că /metrics răspunde la ${TARGET_METRICS_URL}\"\nHTTP_CODE=$(curl -s -o /dev/null -w \"%{http_code}\" --max-time 5 \"${TARGET_METRICS_URL}\")\n[[ \"${HTTP_CODE}\" == \"200\" ]] || { echo \"FAIL: /metrics=${HTTP_CODE}\"; exit 3; }\n\nstep \"OK: /metrics răspunde 200\"\n```\nAdaugă `chmod +x`.",
    "directorul_directoarele": [
      "shared/observability/scripts/"
    ],
    "contextul_taskurilor_anterioare": "install.sh există; aplicațiile expun /metrics.",
    "contextul_general_al_aplicatiei": "Validare rapidă și deterministă a observabilității.",
    "contextualizarea_directoarelor_si_cailor": "Parametrizabil prin `COMPOSE_FILE` și `TARGET_METRICS_URL`.",
    "restrictii_anti_halucinatie": "Nu include teste de load/e2e.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu modifică compose sau codul aplicațiilor.",
    "validare": "Rulează scriptul cu un serviciu up; primește exit 0.",
    "outcome": "Standard de validare observabilitate disponibil.",
    "componenta_de_CI_CD": "Poate fi integrat ca job obligatoriu în pipeline."
  }
},
```

#### F0.3.59

```JSON
{
  "F0.3.59": {
    "denumire_task": "Creează scriptul shared/observability/scripts/smoke.sh",
    "descriere_scurta_task": "Smoke tests rapide pentru health & /metrics pe servicii cheie.",
    "descriere_lunga_si_detaliata_task": "Creează `shared/observability/scripts/smoke.sh` executabil, cu verificări HTTP rapide:\n```bash\n#!/usr/bin/env bash\nset -euo pipefail\n\nENDPOINTS=(\n  \"http://localhost:3000/metrics\"\n  \"http://localhost:3001/health\"\n)\n\nOK=0; FAIL=0\ncheck() {\n  local url=\"$1\"\n  local code\n  code=$(curl -s -o /dev/null -w \"%{http_code}\" --max-time 5 \"$url\" || echo 000)\n  if [[ \"$code\" == 200 ]]; then\n    echo \"[smoke] OK  $url\"\n    ((OK++))\n  else\n    echo \"[smoke] FAIL $url => $code\"\n    ((FAIL++))\n  fi\n}\n\nfor e in \"${ENDPOINTS[@]}\"; do check \"$e\"; done\n\necho \"[smoke] Rezultat: OK=$OK FAIL=$FAIL\"\n[[ $FAIL -eq 0 ]] || exit 4\n```\nAjustează lista ENDPOINTS după mediul local.",
    "directorul_directoarele": [
      "shared/observability/scripts/"
    ],
    "contextul_taskurilor_anterioare": "validate.sh există; aplicațiile expun health/metrics.",
    "contextul_general_al_aplicatiei": "Detecție rapidă a problemelor evidente după schimbări.",
    "contextualizarea_directoarelor_si_cailor": "Rulat manual sau dintr-un stage rapid de CI.",
    "restrictii_anti_halucinatie": "Nu devine suită e2e/performanță.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu pornește/oprim servicii; presupune mediul up.",
    "validare": "Rulare: OK=2, FAIL=0 cu serviciile up.",
    "outcome": "Smoke tests pentru observabilitate disponibile.",
    "componenta_de_CI_CD": "Opțional în pipeline ca verificare rapidă post-deploy."
  }
},
```

#### F0.3.60

```JSON
  {
  "F0.3.60": {
    "denumire_task": "Creează README pentru shared/observability/scripts (usage & convenții)",
    "descriere_scurta_task": "Documentează în README.md din shared/observability/scripts modul de utilizare a scripturilor install.sh, validate.sh și smoke.sh.",
    "descriere_lunga_si_detaliata_task": [],
    "directorul_directoarele": [
      "shared/observability/scripts/"
    ],
    "contextul_taskurilor_anterioare": "Scripturile install.sh, validate.sh și smoke.sh au fost create funcționale. Fără documentație, utilizarea lor poate fi neuniformă sau greșită. Acest README leagă împreună intenția scripturilor și modul corect de utilizare, fiind o sursă de adevăr pentru dezvoltatori și pentru configurarea CI/CD.",
    "contextul_general_al_aplicatiei": "Documentația clară în repo este esențială pentru a evita knowledge silos și pentru a asigura că Observabilitatea este folosită consistent de echipă. shared/observability/scripts/README.md devine entrypoint-ul de documentație pentru tool-urile de Observabilitate la nivel de script.",
    "contextualizarea_directoarelor_si_cailor": "Creează fișierul \"shared/observability/scripts/README.md\" și structurează-l cu secțiuni precum: Introducere, Precondiții, install.sh (rol și exemple), validate.sh (rol și exemple, inclusiv în CI), smoke.sh (rol și exemple), Extensii viitoare. Referențiază clar căi relative din repo (de ex. \"shared/observability/compose/docker-compose.yml\" acolo unde este cazul).",
    "restrictii_anti_halucinatie": "Nu documenta comportamente care nu există în scripturi (de ex. parametri sau moduri de execuție neimplementate încă). Dacă un feature este planificat pentru faze ulterioare, marchează-l explicit ca \"future work\" sau \"planned\". Nu introduce în README concepte de observabilitate sau infrastructură care nu sunt menționate în planul actual.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu crea alte fișiere de documentație în afara acestui README în cadrul acestui task. Nu modifica scripturile pentru a se potrivi documentației; mai degrabă ajustează documentația pentru a reflecta exact comportamentul existent sau actualizează scripturile într-un task dedicat, dacă este nevoie.",
    "validare": "Deschide README-ul și verifică dacă un dezvoltator fără context poate urma pașii pentru: 1) a porni stack-ul de observabilitate în modul dev; 2) a rula validate.sh; 3) a rula smoke.sh. Verifică corespondența dintre exemplele din README și comportamentul real al scripturilor (comenzile trebuie să funcționeze exact așa cum sunt scrise). Ajustează formulările pentru claritate.",
    "outcome": "Există un README coerent pentru scripturile de observabilitate care standardizează modul de utilizare și pregătește integrarea lor în CI/CD și în procesele operaționale.",
    "componenta_de_CI_CD": "README-ul nu introduce logică nouă în CI/CD, dar devine referința atunci când se configurează joburile CI (ex. în F0.3.64). Commit-ul se face pe branch-ul \"dev\" (de ex. \"docs(observability): add README for observability scripts\"), iar documentația va fi verificată și în cadrul PR-ului final de fază."
  },
```

#### F0.3.61

```JSON
  {
  "F0.3.61": {
    "denumire_task": "Creează shared/observability/docs/architecture.md (arhitectura Observabilității)",
    "descriere_scurta_task": "Documentează la nivel înalt arhitectura stack-ului de observabilitate în shared/observability/docs/architecture.md.",
    "descriere_lunga_si_detaliata_task": "Creează fișierul \"shared/observability/docs/architecture.md\" și descrie arhitectura Observabilității în GeniusSuite în faza F0.3: componentele principale (OTEL collector, Prometheus, Grafana, Loki, Tempo), modul în care aplicațiile trimit telemetrie (OTLP, /metrics, log JSON către Loki), convențiile de denumire (service.name, environment, tenant, etc.) și integrarea cu Docker Compose (rețele comune, profiles). Documentul trebuie să explice clar ce înseamnă \"skeleton\" în F0.3 (minimul necesar pentru logs/metrics/traces + dashboards de bază), ce rămâne pentru fazele ulterioare și cum este structurată mapa \"shared/observability/\" (logs/, metrics/, traces/, dashboards/, alerts/, exporters/, otel-config/, compose/, scripts/, docs/).",
    "directorul_directoarele": [
      "shared/observability/docs/"
    ],
    "contextul_taskurilor_anterioare": "Structura directorului shared/observability a fost definită, stack-ul de observabilitate a fost configurat la nivel de compose, scripturile de bază au fost create. Lipsesc însă explicațiile arhitecturale centralizate care să lege toate aceste elemente într-o imagine clară pentru dezvoltatori și DevOps.",
    "contextul_general_al_aplicatiei": "Documentarea arhitecturii Observabilității ajută la onboarding, la troubleshooting și la evoluția stack-ului. architecture.md devine referința principală atunci când cineva vrea să înțeleagă cum sunt colectate și agregate logurile, metricile și trace-urile în GeniusSuite.",
    "contextualizarea_directoarelor_si_cailor": "Lucrează în \"shared/observability/docs/\" și creează \"architecture.md\". Structurează documentul cu secțiuni clare (Overview, Components, Data Flow, Conventions, Compose Integration, Limitări F0.3). Referențiază explicit alte fișiere relevante (de ex. \"otel-config/apps/*.yaml\", \"compose/docker-compose.yml\", scripturile din \"scripts/\") pentru a crea o hartă mentală coerentă.",
    "restrictii_anti_halucinatie": "Nu descrie componente sau scenarii care nu sunt în plan (de ex. alerte complexe bazate pe machine learning, integrări cu tool-uri externe ne-menționate). Dacă un element este planificat pentru faze viitoare, marchează-l explicit ca atare și nu îl prezenta ca fiind deja implementat. Nu introduce nume de servicii sau label-uri OTEL care nu au fost stabilite.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu crea alte fișiere de documentație în afara architecture.md în cadrul acestui task. Nu modifica cod sau configurații doar pentru a se potrivi descrierii; dacă există discrepanțe majore, acestea trebuie adresate într-un task separat.",
    "validare": "Citește documentul din perspectiva unui dezvoltator sau DevOps nou în proiect: poate înțelege rapid ce componente există, cum curg datele de observabilitate și cum se pornește stack-ul? Verifică faptul că toate rutele și fișierele menționate există efectiv în repo și că numele lor sunt exacte. Ajustează documentul pentru claritate și acuratețe.",
    "outcome": "Există un document architecture.md în shared/observability/docs care descrie arhitectura Observabilității pentru faza F0.3 și servește drept bază pentru extinderi ulterioare.",
    "componenta_de_CI_CD": "Documentul nu adaugă logică de CI/CD, dar poate fi referențiat în descrierea PR-ului final de fază F0.3 ca parte din documentația obligatorie. Commit-ul se face pe branch-ul \"dev\" (de ex. \"docs(observability): add architecture overview for observability skeleton\") și este verificat în review-ul de cod."
  },
```

#### F0.3.62

```JSON
  {
  "F0.3.62": {
    "denumire_task": "Creează shared/observability/docs/how-to-add-new-app(module).md (guideline integrare nouă aplicație)",
    "descriere_scurta_task": "Documentează pașii standard pentru a integra o nouă aplicație în stack-ul de observabilitate în how-to-add-app.md.",
    "descriere_lunga_si_detaliata_task": "Creează fișierul \"shared/observability/docs/how-to-add-new-app(module).md\" care descrie pas cu pas cum se integrează o aplicație nouă (sau un nou modul) în Observabilitate. Ghidul trebuie să acopere: 1) ce trebuie adăugat în cod (importul librăriei shared/observability, init tracing, logger, /metrics); 2) ce fișiere de config trebuie create sau extinse (de ex. otel-config/apps/<app>.yaml); 3) cum se conectează aplicația la stack-ul de observabilitate în Docker Compose (rețele, variabile OTEL, porturi); 4) cum se validează integrarea folosind validate.sh și smoke.sh; 5) ce așteptări de naming și tagging există (service.name, environment etc.). Documentul trebuie să folosească exemple reale deja implementate (de ex. CP sau una dintre aplicațiile stand-alone) ca model.",
    "directorul_directoarele": [
      "shared/observability/docs/"
    ],
    "contextul_taskurilor_anterioare": "Integrarea Observabilității a fost realizată pentru mai multe aplicații ale suitei (CP, archify.app, vettify.app etc.), dar procesul nu este încă formalizat într-un ghid reutilizabil. how-to-add-app.md este acel ghid, care reduce riscul de implementări inconsistente atunci când se adaugă aplicații noi.",
    "contextul_general_al_aplicatiei": "Pe termen lung, vor exista mai multe module și servicii noi în GeniusSuite. Un ghid clar de integrare Observabilitate asigură că fiecare aplicație este onboardată în mod standard, fără discuții repetitive sau decizii ad-hoc.",
    "contextualizarea_directoarelor_si_cailor": "Creează \"shared/observability/docs/how-to-add-new-app(module).md\" și structurează-l în secțiuni: Precondiții, Modificări în cod, Configurări OTEL, Integrare în Compose, Validare cu scripturi, Checklist final. Folosește referințe către fișiere concrete (de ex. \"shared/observability/otel-config/apps/vettify.yaml\", exemplu de cod dintr-o aplicație deja instrumentată) pentru a face ghidul cât mai practic.",
    "restrictii_anti_halucinatie": "Nu descrie pași care nu sunt utilizați de niciuna dintre aplicațiile deja integrate. Dacă unele pattern-uri sunt dorite, dar încă neimplementate, marchează-le explicit ca recomandări viitoare. Nu inventa noi directoare sau structuri în repo; rămâi în limitele structurii deja definite pentru shared/observability.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu crea alte fișiere de documentație în acest task și nu modifica codul aplicațiilor existente doar pentru a se potrivi perfect cu ghidul; dacă se observă diferențe majore, acestea se pot adresa în taskuri separate.",
    "validare": "Verifică ghidul practic: simulează integrarea unei aplicații noi urmând exclusiv pașii din how-to-add-app.md și confirmă că, în principiu, se poate ajunge la o integrare completă a observabilității (cod, config, compose, validare). Asigură-te că toate referințele de fișiere și comenzi sunt corecte.",
    "outcome": "Există un ghid clar how-to-add-app.md pentru integrarea noilor aplicații în Observabilitate, reducând efortul de onboarding și crescând consistența implementărilor.",
    "componenta_de_CI_CD": "Documentul poate fi folosit ca referință obligatorie pentru viitoarele PR-uri care introduc aplicații noi (link în template-ul de PR). Commit-ul se face pe branch-ul \"dev\" (ex. \"docs(observability): add how-to-add-new-app guideline\") și este verificat în cadrul PR-ului de fază.",
    "componenta_de_CI_CD_note": "Câmp auxiliar opțional dacă vrei să separi clar partea de PR/template; poate fi ignorat de parser dacă nu este folosit."
  },
```

#### F0.3.63

```JSON
  {
  "F0.3.63": {
    "denumire_task": "Creează shared/observability/docs/dashboards.md și runbooks.md (documentație dashboards & runbooks)",
    "descriere_scurta_task": "Documentează dashboards-urile de bază și runbook-urile asociate în fișierele dashboards.md și runbooks.md din shared/observability/docs.",
    "descriere_lunga_si_detaliata_task": "Creează fișierele \"shared/observability/docs/dashboards.md\" și \"shared/observability/docs/runbooks.md\". În dashboards.md descrie dashboard-urile de bază disponibile în Grafana pentru faza F0.3: ce panel-uri există, ce servicii acoperă, ce metrici sunt esențiale (de ex. rate de eroare, latency p95, număr de request-uri) și cum pot fi extinse. În runbooks.md definește runbook-uri minimale pentru incidente legate de observabilitate (de ex. \"nu apar metrici pentru un serviciu\", \"Loki nu mai indexează loguri\", \"Tempo nu returnează trace-uri\"), cu pași de verificare (check compose, check validate.sh, check endpoints) și acțiuni recomandate. Ambele documente trebuie să reflecte starea reală a stack-ului skeleton F0.3, nu o versiune idealizată completă.",
    "directorul_directoarele": [
      "shared/observability/docs/"
    ],
    "contextul_taskurilor_anterioare": "Dashboards de bază au fost create pentru servicii, iar scripturile validate.sh și smoke.sh oferă un prim nivel de verificare. Documentația pentru modul în care se folosesc dashboards-urile și pentru răspunsul la incidente nu este însă formalizată. dashboards.md și runbooks.md rezolvă această lacună.",
    "contextul_general_al_aplicatiei": "Observabilitatea nu se limitează la colectarea de date; este esențială și partea de interpretare (dashboards) și reacție (runbooks) atunci când apar probleme. Aceste documente pun cap la cap modul de utilizare a dashboard-urilor și pașii de urmat atunci când semnalele indică o problemă.",
    "contextualizarea_directoarelor_si_cailor": "Lucrează în \"shared/observability/docs/\" și creează \"dashboards.md\" și \"runbooks.md\". În dashboards.md, include tabele sau liste cu: numele dashboard-ului, scopul, principalele panel-uri și linkuri relative către JSON-urile sau template-urile de dashboard din repo, dacă există. În runbooks.md, structura recomandată este: Simptom, Posibile cauze, Pași de diagnostic, Acțiuni de remediere, Linkuri către dashboards relevante.",
    "restrictii_anti_halucinatie": "Nu documenta dashboards sau runbook-uri care nu există sau nu sunt pregătite în F0.3. Dacă unele sunt planificate, marchează-le ca \"planned\" sau \"TODO\" cu claritate. Nu inventa alerte complexe sau integrare cu sisteme de on-call care nu sunt descrise în planul actual.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu crea alte documente în acest task. Nu modifica configurații Grafana/Prometheus/Loki; scopul este doar documentarea stării curente.",
    "validare": "Verifică faptul că pentru fiecare dashboard documentat există un corespondent real în configurarea Grafana (sau în fișierele din repo) și că runbook-urile corespund unor scenarii reale posibile (ex. aplicația nu mai trimite metrici). Ajustează descrierile pentru a fi pragmatice și ușor de urmat.",
    "outcome": "Există documente dashboards.md și runbooks.md care descriu modul de utilizare a dashboard-urilor și pașii de reacție la probleme de observabilitate în faza F0.3.",
    "componenta_de_CI_CD": "Aceste documente nu afectează direct CI/CD, dar pot fi menționate în descrierile PR-urilor și în playbook-urile echipei de operațiuni. Commit-ul se face pe branch-ul \"dev\" (ex. \"docs(observability): document dashboards and runbooks for F0.3 skeleton\") și este inclus în PR-ul final de fază."
  },
```

#### F0.3.64

```JSON
  {
  "F0.3.64": {
    "denumire_task": "Integrează shared/observability/scripts/validate.sh în pipeline-ul CI (dev/staging)",
    "descriere_scurta_task": "Adaugă un job de CI care rulează validate.sh pentru a verifica observabilitatea pe branch-urile dev și staging înainte de merge.",
    "descriere_lunga_si_detaliata_task": "Actualizează configurația de CI existentă (de ex. \".github/workflows/ci.yml\" pentru GitHub sau \".gitlab-ci.yml\" pentru GitLab) pentru a introduce un job nou, de tip \"observability-validate\", care rulează scriptul \"shared/observability/scripts/validate.sh\". Job-ul trebuie să pornească de la o imagine care are la dispoziție un mediu potrivit (bash, docker, eventual docker-in-docker dacă este necesar) și să se asigure că stack-ul de observabilitate și aplicațiile sunt pornite sau pornite temporar în contextul job-ului. Job-ul trebuie configurat să ruleze automat pe PR/MR deschise către branch-urile \"dev\" și \"staging\" (sau pe push-uri către aceste branch-uri), iar eșecul scriptului validate.sh să blocheze merge-ul. Include în configurație timeouts rezonabile pentru a evita blocări.",
    "directorul_directoarele": [
      ".github/workflows/",
      ".gitlab-ci.yml",
      "shared/observability/scripts/"
    ],
    "contextul_taskurilor_anterioare": "Scriptul standard de validare a observabilității (validate.sh) a fost creat în shared/observability/scripts. CI/CD de bază a fost configurat în faza F0.2. Acum trebuie conectate aceste componente astfel încât Observabilitatea să devină o condiție de trecere pentru PR-urile relevante.",
    "contextul_general_al_aplicatiei": "Integrarea Observabilității în CI asigură că problemele legate de stack-ul de telemetrie sunt detectate din timp și nu ajung în branch-urile principale. Job-ul observability-validate va deveni un gate obligatoriu pentru merge pe dev și staging, crescând calitatea generală a sistemului.",
    "contextualizarea_directoarelor_si_cailor": "În funcție de platforma de CI folosită: 1) dacă există \".github/workflows/ci.yml\", adaugă un nou job YAML (de ex. \"observability-validate\") care, în pașii săi, execută \"bash shared/observability/scripts/validate.sh\"; 2) dacă există \".gitlab-ci.yml\", adaugă un nou job în pipeline, cu stage adecvat (ex. \"validation\") și script de execuție a validate.sh. Nu crea simultan ambele configurații; detectează contextul bazându-te pe fișierele existente. Asigură-te că job-ul este condiționat să ruleze doar acolo unde este relevant (PR/MR sau branch-uri dev/staging) pentru a evita costuri inutile.",
    "restrictii_anti_halucinatie": "Nu presupune că proiectul folosește în același timp GitHub și GitLab; lucrează doar cu fișierele de CI care există deja în repo. Nu modifica alte job-uri CI în afara adăugării/legării job-ului de observabilitate. Nu introduce pași care distrug sau modifică resurse din medii de producție; job-ul trebuie să se limiteze la mediile de test/CI.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu crea fișiere noi de pipeline complet diferite de structura deja existentă; extinde pipeline-ul actual. Nu inventa alte job-uri sau stage-uri complicate; job-ul observability-validate trebuie să fie atomic și clar.",
    "validare": "Deschide un PR/MR de test către branch-ul \"dev\" care modifică un fișier nesemnificativ și verifică: 1) că job-ul observability-validate apare în pipeline; 2) că acesta rulează scriptul validate.sh; 3) că, în condiții normale, job-ul trece cu succes. Simulează și un eșec (de ex. modificând temporar scriptul pentru a returna exit code nenul) pentru a verifica faptul că pipeline-ul marchează PR/MR-ul ca failed și nu permite merge-ul până la remediere.",
    "outcome": "Pipeline-ul CI include un job observability-validate care rulează validate.sh pe branch-urile dev și staging, transformând observabilitatea într-o condiție automată de trecere pentru PR/MR.",
    "componenta_de_CI_CD": "Job-ul observability-validate este acum parte integrantă din CI. Orice PR/MR către dev și staging trebuie să treacă acest job înainte de merge. Modificările de configurare CI se fac pe branch-ul \"dev\" (ex. commit \"ci(observability): run validate.sh in CI pipeline\"), sunt revizuite în cadrul unui PR către \"staging\" și, după verificare, sunt propagate către \"master\" odată cu restul livrabilelor F0.3."
  },
```

#### F0.3.65

```JSON
  {
  "F0.3.65": {
    "denumire_task": "PR/MR final pentru F0.3 Observabilitate (dev → staging → master)",
    "descriere_scurta_task": "Agregă toate modificările din F0.3 pe branch-ul dev și deschide PR/MR-urile necesare către staging și master, cu descriere detaliată și referințe la Observabilitate.",
    "descriere_lunga_si_detaliata_task": "După finalizarea tuturor taskurilor F0.3.x (inclusiv integrarea în cod, Docker Compose, scripturi, documentație și CI), agregă modificările pe branch-ul \"dev\" și pregătește un PR/MR de fază către branch-ul \"staging\". Descrierea PR-ului trebuie să includă: rezumatul arhitecturii Observabilității skeleton, lista principalelor componente adăugate (shared/observability, stack OTEL/Prometheus/Grafana/Loki/Tempo, scripturi, documente), modul de utilizare (link către how-to-add-app.md și README-urile relevante) și impactul asupra mediului de dezvoltare. După review și testare pe staging, creează un al doilea PR/MR din \"staging\" către \"master\" (sau folosește fluxul standard al echipei) pentru a promova Observabilitatea skeleton în linia principală. Asigură-te că toate job-urile CI (inclusiv observability-validate) sunt verzi înainte de merge.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/"
    ],
    "contextul_taskurilor_anterioare": "Toate taskurile F0.3 au fost implementate: configurare shared/observability, stack OTEL + Prometheus + Grafana + Loki + Tempo, integrarea în aplicații (CP și stand-alone), scripturi (install.sh, validate.sh, smoke.sh), documentație și integrare în CI. Acest task finalizează faza printr-un PR/MR coerent și bine documentat.",
    "contextul_general_al_aplicatiei": "GeniusSuite folosește o strategie cu trei branch-uri principale (dev, staging, master). Fiecare fază majoră trebuie integrată prin PR-uri clar documentate, pentru a permite code review, validare CI și testare incrementale înainte de a ajunge în master.",
    "contextualizarea_directoarelor_si_cailor": "Lucrează din rădăcina repo-ului. Verifică faptul că toate modificările legate de F0.3 sunt comise pe branch-ul \"dev\". Creează PR/MR către \"staging\" cu o descriere bogată, folosind secțiuni precum: \"Context\", \"Schimbări cheie\", \"Impact\", \"Instrucțiuni de rulare\", \"Checklist de validare\" (inclusiv rularea validate.sh și smoke.sh). După aprobarea PR-ului și testarea pe staging, pregătește un PR/MR către \"master\" cu un rezumat orientat pe release (ce aduce Observabilitatea skeleton în produs).",
    "restrictii_anti_halucinatie": "Nu introduce schimbări noi de cod sau configurare în acest task; focusul este exclusiv pe operațiunile Git și pe descrierea PR-urilor. Nu modifica istoricul Git (rebase/force-push) într-un mod care ar putea afecta alte faze fără acordul echipei. Nu promite în descriere funcționalități de Observabilitate care nu sunt implementate efectiv.",
    "restrictii_de_iesire_din_context_sau_de_inventare_de_sub_taskuri": "Nu crea alte branch-uri în afara celor necesare pentru fluxul dev → staging → master. Nu inventa sub-taskuri suplimentare; toate modificările de cod/config ar trebui să fie deja acoperite de taskurile F0.3.1–F0.3.64.",
    "validare": "Asigură-te că: 1) toate job-urile CI legate de PR (inclusiv observability-validate) sunt verzi; 2) cel puțin un reviewer tehnic a aprobat PR-ul către staging; 3) pe staging, scripturile validate.sh și smoke.sh trec și se pot vizualiza dashboards-urile de bază; 4) PR-ul către master este aprobat conform procesului echipei și merge-ul se face fără conflicte.",
    "outcome": "Faza F0.3 Observabilitate (skeleton) este complet integrată în branch-ul master, cu un istoric clar de PR-uri și o descriere detaliată a schimbărilor, gata pentru a fi folosită ca fundație în fazele următoare (F0.4, F0.8 etc.).",
    "componenta_de_CI_CD": "Acest task este strict legat de fluxul de CI/CD: PR/MR din \"dev\" către \"staging\" și apoi către \"master\". CI trebuie să ruleze automat pe fiecare PR, incluzând job-ul observability-validate și restul verificărilor definite în F0.2. Nu se face merge manual (fără PR) în branch-urile staging sau master; toate actualizările Observabilității skeleton trebuie să treacă prin aceste PR-uri cu CI verde."
  }
```

#### F0.4 Orchestrare Docker (hibrid): compose per app + orchestrator root, rețele partajate, Traefik routing

##### F0.4.1

```JSON
    {
      "F0.4.1": {
        "denumire_task": "Definire Volumelor Numite Globale (Root compose.yml)",
        "descriere_scurta_task": "Definirea tuturor volumelor 'stateful' (PostgreSQL, Kafka, Observability, Traefik) în fișierul compose.yml de la rădăcină.",
        "detalii_tehnice": "Implementează Partea 2 din  (Strategia de Protecție a Datelor). Definește volumele numite (ex. 'gs_pgdata_identity', 'gs_kafka_data', 'gs_traefik_certs') în secțiunea 'volumes:' a fișierului root. Acest lucru previne ștergerea lor accidentală de către comenzi 'docker compose down -v' la nivel de aplicație.[24]",
        "surse": ,
        "obiectiv_faza": "F0.4",
        "rationale": "Decuplează ciclul de viață al datelor de ciclul de viață al containerelor, o cerință de bază pentru servicii stateful.",
        "validare": "Comanda 'docker volume ls' afișează volumele (ex. 'gs_pgdata_identity') după rularea scriptului de inițializare (F0.4.20)."
      }
    },
  ```

##### F0.4.2

```JSON
    {
      "F0.4.2": {
        "denumire_task": "Configurare Serviciu 'proxy' (Traefik) în Root Compose",
        "descriere_scurta_task": "Adăugarea serviciului Traefik în compose.yml de la rădăcină, expunerea porturilor 80/443 și conectarea la rețele.",
        "detalii_tehnice": "Serviciul 'proxy/traefik'  se conectează la 'net_edge' (pentru porturile 80/443), 'net_suite_internal' (pentru a ruta traficul către API-uri) și 'net_observability' (pentru a expune /metrics). Utilizează volumul 'gs_traefik_certs'  pentru stocarea certificatelor ACME.",
        "surse": [1, 2, 24],
        "obiectiv_faza": "F0.4",
        "rationale": "Singurul punct de intrare (gateway) în cluster, conform strategiei de rețea.",
        "validare": "Traefik pornește, redirecționează HTTP->HTTPS și obține certificate ACME valide."
      }
    },
  ```

##### F0.4.3

```JSON
    {
      "F0.4.3": {
        "denumire_task": "Configurare Serviciu 'observability' în Root Compose",
        "descriere_scurta_task": "Adăugarea stack-ului de observabilitate (Prometheus, Grafana, Loki) în compose.yml de la rădăcină.",
        "detalii_tehnice": "Adaugă serviciile din 'shared/observability/compose/' (definite în F0.3) în orchestratorul root. Toate serviciile (Prometheus, Loki, Tempo) se conectează *exclusiv* la 'net_observability' și utilizează volumele 'stateful' dedicate (ex. 'gs_prometheus_data'). Grafana UI poate fi expusă prin Traefik pe 'net_suite_internal'.",
        "surse": [1, 2, 24],
        "obiectiv_faza": "F0.4",
        "rationale": "Centralizează stack-ul de monitorizare, permițând colectarea de date de la toate celelalte servicii prin 'net_observability'.",
        "validare": "Serviciile Grafana și Prometheus sunt accesibile prin rutele Traefik."
      }
    },
  ```

##### F0.4.4

```JSON
    {
      "F0.4.4": {
        "denumire_task": "Implementare Servicii de Bază (Backing Services) în Root Compose",
        "descriere_scurta_task": "Adăugarea definițiilor de servicii pentru PostgreSQL (instanțe multiple), Kafka și Temporal în compose.yml de la rădăcină.",
        "detalii_tehnice": "Adaugă serviciile 'stateful' partajate în orchestratorul root. Fiecare serviciu (ex. 'postgres_identity', 'postgres_numeriqo', 'kafka', 'temporal', 'neo4j_vettify') trebuie să folosească volumul numit corespunzător (ex. 'gs_pgdata_identity' ) și să se conecteze *exclusiv* la 'net_backing_services' și 'net_observability'. Niciunul dintre aceste servicii nu trebuie să fie pe 'net_suite_internal' sau 'net_edge'.",
        "surse": ,
        "obiectiv_faza": "F0.4",
        "rationale": "Izolează infrastructura de date (baze de date, brokeri) de rețeaua API, impunând Stratul 1 (Rețea) al DiD.",
        "validare": "Containerele DB/Kafka pornesc și sunt accesibile *doar* din alte containere atașate la 'net_backing_services'."
      }
    },
    {
      "F0.4.6": {
        "denumire_task": "Refactorizare Compose Aplicație (Model Hibrid): cp/identity",
        "descriere_scurta_task": "Actualizarea 'cp/identity/compose/docker-compose.yml' pentru a implementa modelul hibrid (rețele și volume externe).",
        "detalii_tehnice": "Acesta este șablonul pentru toate celelalte aplicații (F0.4.7 - F0.4.19). Serviciul local 'postgres_identity' este *eliminat* (deoarece este definit în root F0.4.5). Serviciul 'api' (identity) se conectează la rețelele externe: 'net_suite_internal' [1], 'net_backing_services' (pentru a accesa 'postgres_identity' și 'supertokens-core') și 'net_observability'. Rețelele sunt definite cu 'external: true'.",
        "surse": [1, 2, 24],
        "obiectiv_faza": "F0.4",
        "rationale": "Implementează modelul hibrid [2] și strategia de protecție a volumelor [24] pentru aplicația 'identity'.",
        "validare": "Aplicația pornește local (folosind 'docker compose up' în 'cp/identity/compose') și se conectează cu succes la serviciile externe (DB, Traefik)."
      }
    },
    {
      "F0.4.7": {
        "denumire_task": "Refactorizare Compose Aplicație: cp/suite-shell",
        "descriere_scurta_task": "Aplicarea modelului hibrid pentru 'cp/suite-shell/compose/docker-compose.yml'.",
        "detalii_tehnice": "Similar cu F0.4.6. Serviciul BFF (port 6100 [1]) se conectează la 'net_suite_internal' (expus de Traefik) și 'net_observability'. Rețelele sunt marcate 'external: true'.",
        "surse": [1, 2, 24],
        "obiectiv_faza": "F0.4"
      }
    },
    {
      "F0.4.8": {
        "denumire_task": "Refactorizare Compose Aplicație: cp/suite-admin",
        "descriere_scurta_task": "Aplicarea modelului hibrid pentru 'cp/suite-admin/compose/docker-compose.yml'.",
        "detalii_tehnice": "Similar cu F0.4.6. Serviciul API (port 6150 [1]) se conectează la 'net_suite_internal', 'net_backing_services' și 'net_observability'. Rețele și volume marcate 'external: true'.",
        "surse": [1, 2, 24],
        "obiectiv_faza": "F0.4"
      }
    },
    {
      "F0.4.9": {
        "denumire_task": "Refactorizare Compose Aplicație: cp/licensing",
        "descriere_scurta_task": "Aplicarea modelului hibrid pentru 'cp/licensing/compose/docker-compose.yml'.",
        "detalii_tehnice": "Similar cu F0.4.6. Serviciul API (port 6300 [1]) se conectează la 'net_suite_internal', 'net_backing_services' și 'net_observability'. Rețele și volume marcate 'external: true'.",
        "surse": [1, 2, 24],
        "obiectiv_faza": "F0.4"
      }
    },
    {
      "F0.4.10": {
        "denumire_task": "Refactorizare Compose Aplicație: cp/analytics-hub",
        "descriere_scurta_task": "Aplicarea modelului hibrid pentru 'cp/analytics-hub/compose/docker-compose.yml'.",
        "detalii_tehnice": "Similar cu F0.4.6. Serviciul API (port 6350 [1]) se conectează la 'net_suite_internal', 'net_backing_services' (pentru Kafka/DB) și 'net_observability'. Rețele și volume marcate 'external: true'.",
        "surse": [1, 2, 24],
        "obiectiv_faza": "F0.4"
      }
    },
    {
      "F0.4.11": {
        "denumire_task": "Refactorizare Compose Aplicație: cp/ai-hub",
        "descriere_scurta_task": "Aplicarea modelului hibrid pentru 'cp/ai-hub/compose/docker-compose.yml'.",
        "detalii_tehnice": "Similar cu F0.4.6. Serviciul API (port 6400 [1]) se conectează la 'net_suite_internal', 'net_backing_services' și 'net_observability'. Rețele și volume marcate 'external: true'.",
        "surse": [1, 2, 24],
        "obiectiv_faza": "F0.4"
      }
    },
    {
      "F0.4.12": {
        "denumire_task": "Refactorizare Compose Aplicație: archify.app",
        "descriere_scurta_task": "Aplicarea modelului hibrid pentru 'archify.app/compose/docker-compose.yml'.",
        "detalii_tehnice": "Similar cu F0.4.6. Serviciul API (port 6500 [1]) se conectează la 'net_suite_internal', 'net_backing_services' și 'net_observability'. Volumul 'archify_storage_originals'  este definit în root (F0.4.2) și referit aici ca 'external: true'.",
        "surse": [1, 2, 24],
        "obiectiv_faza": "F0.4"
      }
    },
    {
      "F0.4.13": {
        "denumire_task": "Refactorizare Compose Aplicație: cerniq.app",
        "descriere_scurta_task": "Aplicarea modelului hibrid pentru 'cerniq.app/compose/docker-compose.yml'.",
        "detalii_tehnice": "Similar cu F0.4.6. Serviciul API (port 6550 [1]) se conectează la 'net_suite_internal', 'net_backing_services' (pentru a consuma din Kafka/DBs) și 'net_observability'. Rețele și volume marcate 'external: true'.",
        "surse": [1, 2, 24],
        "obiectiv_faza": "F0.4"
      }
    },
    {
      "F0.4.14": {
        "denumire_task": "Refactorizare Compose Aplicație: flowxify.app",
        "descriere_scurta_task": "Aplicarea modelului hibrid pentru 'flowxify.app/compose/docker-compose.yml'.",
        "detalii_tehnice": "Similar cu F0.4.6. Serviciul API (port 6600 [1]) se conectează la 'net_suite_internal', 'net_backing_services' (pentru Temporal/DB) și 'net_observability'. Rețele și volume marcate 'external: true'.",
        "surse": [1, 2, 24],
        "obiectiv_faza": "F0.4"
      }
    },
    {
      "F0.4.15": {
        "denumire_task": "Refactorizare Compose Aplicație: i-wms.app",
        "descriere_scurta_task": "Aplicarea modelului hibrid pentru 'i-wms.app/compose/docker-compose.yml'.",
        "detalii_tehnice": "Similar cu F0.4.6. Serviciul API (port 6650 [1]) se conectează la 'net_suite_internal', 'net_backing_services' și 'net_observability'. Rețele și volume marcate 'external: true'.",
        "surse": [1, 2, 24],
        "obiectiv_faza": "F0.4"
      }
    },
    {
      "F0.4.16": {
        "denumire_task": "Refactorizare Compose Aplicație: mercantiq.app",
        "descriere_scurta_task": "Aplicarea modelului hibrid pentru 'mercantiq.app/compose/docker-compose.yml'.",
        "detalii_tehnice": "Similar cu F0.4.6. Serviciul API (port 6700 [1]) se conectează la 'net_suite_internal', 'net_backing_services' și 'net_observability'. Rețele și volume marcate 'external: true'.",
        "surse": [1, 2, 24],
        "obiectiv_faza": "F0.4"
      }
    },
    {
      "F0.4.17": {
        "denumire_task": "Refactorizare Compose Aplicație: numeriqo.app",
        "descriere_scurta_task": "Aplicarea modelului hibrid pentru 'numeriqo.app/compose/docker-compose.yml'.",
        "detalii_tehnice": "Similar cu F0.4.6. Serviciul API (port 6750 [1]) se conectează la 'net_suite_internal', 'net_backing_services' și 'net_observability'. Rețele și volume marcate 'external: true'.",
        "surse": [1, 2, 24],
        "obiectiv_faza": "F0.4"
      }
    },
    {
      "F0.4.18": {
        "denumire_task": "Refactorizare Compose Aplicație: triggerra.app",
        "descriere_scurta_task": "Aplicarea modelului hibrid pentru 'triggerra.app/compose/docker-compose.yml'.",
        "detalii_tehnice": "Similar cu F0.4.6. Serviciul API (port 6800 [1]) se conectează la 'net_suite_internal', 'net_backing_services' și 'net_observability'. Rețele și volume marcate 'external: true'.",
        "surse": [1, 2, 24],
        "obiectiv_faza": "F0.4"
      }
    },
    {
      "F0.4.19": {
        "denumire_task": "Refactorizare Compose Aplicație: vettify.app",
        "descriere_scurta_task": "Aplicarea modelului hibrid pentru 'vettify.app/compose/docker-compose.yml'.",
        "detalii_tehnice": "Similar cu F0.4.6. Serviciul API (port 6850 [1]) se conectează la 'net_suite_internal', 'net_backing_services' (pentru DB și Neo4j) și 'net_observability'. Rețelele și volumele (inclusiv 'gs_neo4j_data') sunt marcate 'external: true'.[24]",
        "surse": [1, 2, 24],
        "obiectiv_faza": "F0.4"
      }
    },
    {
      "F0.4.20": {
        "denumire_task": "Creare Script de Inițializare Infra (init-infra.sh)",
        "descriere_scurta_task": "Crearea unui script (ex. 'scripts/compose/init-infra.sh') care creează rețelele și volumele externe.",
        "detalii_tehnice": "Deoarece aplicațiile depind de rețele și volume 'external: true' [F0.4.6-F0.4.19], acestea trebuie să existe înainte ca 'docker compose up' să fie rulat pe o aplicație individuală. Acest script va rula 'docker network create...' și 'docker volume create...' pentru toate resursele definite în F0.4.1 și F0.4.2. Acest script este esențial pentru mediile de CI și pentru setup-ul local al dezvoltatorilor.",
        "surse": ,
        "obiectiv_faza": "F0.4",
        "rationale": "Rezolvă problema 'oul sau găina' a modelului hibrid, asigurând că resursele partajate există înainte ca aplicațiile dependente să pornească.",
        "validare": "Scriptul rulează fără erori și creează toate rețelele și volumele necesare."
      }
    },
    {
      "F0.4.21": {
        "denumire_task": "Validare Segmentare Rețea (Zero-Trust)",
        "descriere_scurta_task": "Testarea și validarea faptului că segregarea rețelelor funcționează conform planului.",
        "detalii_tehnice": "După pornirea stack-ului (root compose), executați teste de conectivitate. Exemplu de test 1: 'docker exec [container_traefik] ping [container_postgres_identity]' TREBUIE să eșueze (Traefik nu este pe 'net_backing_services'). Exemplu de test 2: 'docker exec [container_api_identity] ping [container_postgres_identity]' TREBUIE să reușească (ambele sunt pe 'net_backing_services'). Documentați rezultatele ca dovadă a implementării Zero-Trust.",
        "surse": ,
        "obiectiv_faza": "F0.4",
        "rationale": "Validarea practică a Stratului 1 (Rețea) al strategiei DiD.",
        "validare": "Testele de ping eșuează și reușesc exact așa cum este descris în 'detalii_tehnice'."
      }
    },
    {
      "F0.4.22": {
        "denumire_task": "Validare Persistență Volum (Test 'down -v')",
        "descriere_scurta_task": "Testarea strategiei de protecție a datelor PostgreSQL.[24]",
        "detalii_tehnice": "1. Porniți stack-ul root și o aplicație (ex. 'numeriqo.app'). 2. Adăugați date de test în baza de date 'numeriqo_db'. 3. Rulați 'docker compose down -v' în directorul 'numeriqo.app/compose/'. 4. Porniți din nou aplicația ('docker compose up' în același director). 5. Confirmați că datele de test persistă. Acest test validează că strategia 'external: true' [24] funcționează și previne pierderea accidentală a datelor.",
        "surse": ,
        "obiectiv_faza": "F0.4",
        "rationale": "Validarea practică a strategiei de protecție a volumelor, o cerință cheie a utilizatorului.",
        "validare": "Datele persistă după rularea 'docker compose down -v' la nivel de aplicație."
      }
    }
  ]
}


F0.5 Securitate & Secrets: Vault/1Password/SSM, rotație chei, profile dev/staging/prod.

F0.6 Bootstrap Scripts: init local/dev, seeds, demo data.

F0.7 DB Scripts: create/migrate/seed per app, orchestrare cross‑db.

F0.8 CI & QA Scripts: smoke/load/security scripts, canary.

F0.9 Schemă DB Comună: Identity/Licensing/Gateway (crea/upgrade DB comune: uuidv7, RLS, indici).

F0.10 Schemă DB per App: vettify, numeriqo, archify, flowxify, iwms, mercantiq, triggerra – aplicare scheme + seeds minime.

F0.11 Schemă DB BI: cerniq_warehouse (metastore/cache) + joburi ETL inițiale.

Deliverables: repo inițial, pipelines verzi, DB-uri funcționale (migrate & seed), „one‑command up” pentru profile dev.
Criterii acceptare: pnpm i && pnpm build trece global; docker compose -f compose.yml up pornește Traefik+observability; gs db migrate funcțional.

F1 - Faza 1 — Shared (Canvas: „Shared”)
Obiectiv: biblioteci comune reutilizabile.
F1.1 UI Design System: structura components/primitives/layouts/tokens/themes, Storybook, teste vizuale.

F1.2 Feature Flags: server+client SDK, storage provider, UI admin, tRPC/OpenAPI.

F1.3 Auth Client: PKCE, OIDC, JWT mgmt, hooks React, guards RBAC/ABAC, interceptors.

F1.4 Types & Contracts: domain types, DTOs, events (Kafka), validation (Zod), errors, utils.

F1.5 Integrations & Common: clienți ANAF/BNR/Stripe etc. + utilitare.

Deliverables: pachete @shared/ publicate intern, acoperire teste ≥70%.
Criterii acceptare: toate apps pot importa din @shared/* fără breaking.

F2 - Faza 2 — Control Plane (Canvas: „CP”)
Obiectiv: nucleu suite: shell MF, admin, login, identity, licensing, analytics-hub, ai-hub.
F2.1 Suite Shell: MF container, registry, routing, fallback, theming per tenant.

F2.2 Suite Login: flux PKCE → JWT, MFA, reset, consimțământ; pagini gata de brand-uit.

F2.3 Identity: SuperTokens, OIDC provider, memberships/roles, RLS policies în DB identity.

F2.4 Licensing: planuri, features, entitlements, metering + SDK client.

F2.5 Analytics-Hub (skeleton): colectori, ingestion, semantic layer minimal.

F2.6 AI-Hub (skeleton): endpoints chat/embeddings + policy & quota.

Deliverables: acces unificat în suita, provisioning tenant, licențe funcționale.
Criterii acceptare: login funcțional, RBAC enforce, license gates active, shell încarcă remote apps.

F3 - Faza 3 — Gateway (Canvas: „gateway”)
Obiectiv: strat unificat de acces API.
F3.1 BFF & API Gateway: agregare servicii, rate limit, caching, schema validation.

F3.2 tRPC/OpenAPI: contract federation, doc UI (Scalar), versionare.

F3.3 Policies: access policies per route/tenant/entitlement.

Deliverables: endpoint stabil pentru frontends; docs centralizate.
Criterii acceptare: conformance tests cross-app, latență sub praguri definite.

F4 - Faza 4 — Proxy (Canvas: „proxy”)
Obiectiv: edge routing & TLS.
F4.1 Traefik: routers/services/middlewares + certificates.

F4.2 Alternative Caddy (profil): config paralel pentru fallback.

Deliverables: domenii & subdomenii funcționale, HTTPS.
Criterii acceptare: health-check extern OK, canary routes funcționale.

F5 - Faza 5 — Archify (Canvas: „archify.app”)
Obiectiv: DMS: upload, versiuni, OCR, e‑sign.
F5.1 DB & Storage: tabele, versiuni, tags, storage drivers (din F0.10).

F5.2 OCR Pipeline: cozi/worker, statusuri, extragere text.

F5.3 Semnături: integrare PandaDoc/adapters.

F5.4 UI & Permisiuni: views, căutare, ACL.

Deliverables: MVP gestionare documente multi-tenant.
Criterii acceptare: upload→OCR→search→sign flow end‑to‑end.

F6 - Faza 6 — Numeriqo (Canvas: „numeriqo.app”)
Obiectiv: Producător Date #1: contabilitate RO + HR/Payroll.
F6.1 Accounting Core: plan de conturi, jurnale, înregistrări partida dublă, TVA.

F6.2 Invoicing PRO & e‑Factura/SAF‑T: generare, validare, export.

F6.3 HR & Payroll & REGES‑Online (faza hibrid):
F6.3.1 Achiziție și integrare nomenclatoare: descărcarea, parsarea și actualizarea periodică a nomenclatoarelor oficiale (COR, SIRUTA, temeiuri de încetare/suspendare, tipuri de contracte) din sursa reges‑ro/integrare.

F6.3.2 Mapare model de date: construirea și menținerea tabelului de mapare între câmpurile interne din GeniusERP și modelul de date REGES‑Online, pe baza documentației inferate.

F6.3.3 Motor de validare locală: implementarea unui serviciu de validare locală care aplică regulile de business (de exemplu: salariu minim, durată program, coduri COR/SIRUTA valide) și utilizează nomenclatoarele; blocarea exportului la apariția erorilor.

F6.3.4 Generare fișiere REGES (JSON/XML): dezvoltarea funcției de serializare pentru export în format JSON (și XML ca alternativă) pentru operațiunile de HR selectate; creare UI/UX dedicat care afișează operațiunile ne‑raportate și permite selecția lor; testarea fișierelor generate în mediul de test REGES‑Online și redactarea unui ghid pas‑cu‑pas pentru clienți privind generarea și upload‑ul manual.

F6.4 Integrare API REGES‑Online (faza completă):
F6.4.1 Obținere documentație și autorizări: contactarea oficială a Inspecției Muncii pentru a obține specificațiile API și accesul la mediul de test; pregătirea pachetului juridic de „prestator” și a actelor adiționale; gestionarea procesului de delegare și colectarea credențialelor pentru fiecare client.

F6.4.2 Management credențiale: implementarea unui mecanism securizat (vault) pentru stocarea perechii (ID_Utilizator, ID_Angajator) asociate fiecărui client; dezvoltarea unui flux de colectare a acestor chei prin portalul clientului.

F6.4.3 Client API și transmitere automată: dezvoltarea serviciului backend care autentifică și transmite automat operațiunile (angajare, modificare, încetare) către endpoint‑urile REGES‑Online; implementarea mecanismelor de retry cu exponential backoff pentru erorile 5xx și logica de reconciliere prin apeluri GET; gestionarea răspunsurilor și jurnalizare detaliată.

F6.4.4 UI/UX și onboarding modul automat: extinderea interfeței GeniusERP cu un buton „Transmitere directă REGES” și un ecran „Jurnal Transmiteri” care afișează statusurile (Succes/Eroare); implementarea procesului de onboarding care permite trecerea clienților de la modul hibrid la modul automat, inclusiv introducerea credențialelor API și validarea lor.

Deliverables: balanță/bilanț, registre, state salarii, modul de export hibrid REGES‑Online (fișiere JSON) și integrare API.
Criterii acceptare: verificări contabile standard, declarații exportabile, fișiere REGES generate fără erori și acceptate în portalul REGES‑Online, integrare API funcțională pentru clienții autorizați, jurnal de transmiteri și reconciliere de succes.

F7 - Faza 7 — i‑WMS (Canvas: „i-wms.app”)
Obiectiv: Producător Date #2: stocuri, mișcări, batches, integrări curieri.
F7.1 Model stocuri: warehouses, products, stocks, batches.
F7.2 Operațiuni: recepții, transfer, inventar, picking.
F7.3 Integrări: curieri/POS, coduri de bare. Deliverables: gestiune multi‑depozit completă. Criterii acceptare: rapoarte on‑hand/available corecte, e2e recepție→livrare.

F8 - Faza 8 — Mercantiq (Canvas: „mercantiq.app”)
Obiectiv: Producător Date #3: vânzări & e‑commerce (lite).
F8.1 Quotes & Orders: pipeline, pricing, taxe.
F8.2 Plăți: Stripe/Revolut, webhooks.
F8.3 Integrare CRM/WMS: sincron conturi/stocuri. Deliverables: comandă la încasare end‑to‑end. Criterii acceptare: ordine acceptate, plăți reconciliate, stoc actualizat.

F9 - Faza 9 — Cerniq (Canvas: „cerniq.app”)
Obiectiv: Consumator Data Mesh: Platformă BI (Consum + Semantică + Dashboards).
F9.1 Dezvoltare Conectori Data Mesh: Crearea consumatorilor pentru "Produsele de Date" standard publicate de modulele anterioare (F6, F7, F8).
F9.2 Semantic Layer & APIs: Definirea metricilor/dimensiunilor care unifică produsele de date consumate.
F9.3 Dashboards & Governance: Implementare RLS/CLS în semantic layer, guvernanță pe contractele de date. Deliverables: Platformă analitică unificată, API semantic stabil. Criterii acceptare: Dashboarduri standard (sales, AR/AP, stock, payroll) live, populate prin consumul de "Produse de Date" reale de la F6, F7, F8.

F10 - Faza 10 — Flowxify (Canvas: „flowxify.app”)
Obiectiv: Orchestrare Unificată (Temporal) + Collaborare + Intranet.
F10.1 BPM (Temporal): Dezvoltarea motorului Temporal pentru workflows, activities, retry policies, și crearea API-ului pentru serviciul monetizabil "BPM on-request".
F10.2 Tasks & Threads: mesagerie internă, fișiere atașate (interfață HITL pentru Temporal).
F10.3 Intranet: pagini, anunțuri, directory. Deliverables: Orchestrare procese unificată (fără iPaaS) + colaborare în app. Criterii acceptare: definire/execuție workflow din UI, SLA‑uri respectate, API-ul "BPM on-request" funcțional.

F11 - Faza 11 — Triggerra (Canvas: „triggerra.app”)
Obiectiv: marketing automation & journeys.
F11.1 Segmente & Campanii: definire, programare, canale.
F11.2 Journeys: graf, condiții, A/B testing.
F11.3 Analytics Marketing: atribuiri, ROI, rapoarte. Deliverables: campanii multi‑canal cu măsurare full‑funnel. Criterii acceptare: livrări la timp, conversii urmărite end‑to‑end.

F12 - Faza 12 — Vettify (Canvas: „vettify.app”)
Obiectiv: CRM + Firmographics + Sales Assist.
F12.1 Accounts/Contacts/Leads: scoring, enrichment (ANAF/Termene).
F12.2 Opportunities & Activities: pipeline, tasking, reminders.
F12.3 Comms B2B & AI Assist: email/WhatsApp, asistent vânzări. Deliverables: CRM producție cu enrichment automat. Criterii acceptare: scoring lead funcțional, conversii urmărite.

F13 - Faza 13 — GeniusERP.app (Canvas: „geniuserp.app”)
Obiectiv: portalul suitei (prezentare), rutare către sub‑apps, subscription flows.
F13.1 Website & Onboarding: landing, pricing, signup.
F13.2 Tenancy & Themes: brand‑uri tenant, preferințe.
F13.3 Monitoring & Telemetry suite: health, usage, cost. Deliverables: site live + onboarding suita. Criterii acceptare: trial → plată → activare module funcțional.

Milestone-uri & livrare incrementală (Actualizat)
M1 (F0–F2): Login, RBAC, licensing, shell, DB & Scripts — alpha suite & fundație.
M2 (F3–F5): Gateway+Proxy + Archify — doc workflows live.
M3 (F6–F8): Numeriqo + i‑WMS + Mercantiq — producători de date pilot.
M4 (F9–F12): Cerniq + Flowxify + Triggerra + Vettify — consumatori de date & suite beta.
GA (F13): Site public (GeniusERP.app), hardening & SRE.

Reguli de tranziție între faze
Faza următoare începe doar când: criteriile de acceptare anterioare + testele e2e cross‑app sunt verzi.
Orice dependență (ex. Auth Client) se livrează „versionată” și adoptată prin changelog clar.
Orice „breaking change” în contracts (tRPC/OpenAPI, events) necesită migration guides și adapters temporari.
