# GeniusERP Suite Plan


# Capitolul 1

## GeniusSuite – Plan general

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

```
/var/www/GeniusSuite/                        # rădăcina monorepo‑ului NX + orchestrator
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
│   ├── analytics-hub/                       # Hub Data Mesh (stream consumers, data products, semantics)
│   └── ai-hub/                              # inference, embeddings, RAG, assistants
├── archify.app/                             # DMS stand‑alone (web/api/db)
│   ├── web/                                 # frontend
│   ├── api/                                 # BFF/REST/tRPC
│   └── compose/                             # docker‑compose al aplicației
├── cerniq.app/                              # Platformă Data Mesh & BI stand‑alone
│   ├── consumers/                           # Conectori/Consumatori pt. "Data Products"
│   ├── semantics/                           # Semantic layer (metrici, KPIs)
│   ├── dashboards/                          # Vizualizări (Grafana, etc.) 
│   └── compose/                             # orchestrare BI
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
└── compose.yml                              # orchestrator root (rețele, Traefik, observability)
```
**Notă orchestrare (model hibrid):**
- Compose **per aplicație** (`*/compose/docker-compose.yml`) → izolare, rulare rapidă, ownership clar.
- Compose **orchestrat la rădăcină** (`/var/www/GeniusSuite/compose.yml`) → pornește suita/subseturi, gestionează Traefik, rețelele partajate și observability.

### 6) Licențiere & Deployment
- Stand‑alone sau suită completă; licențiere și entitlement centralizate în **CP/licensing**.
- SSO PKCE→JWT comun (SuperTokens/identity), multi‑tenant la nivel de subdomeniu.
- Pipeline CI/CD pe profiluri (dev/staging/prod) + observabilitate unificată.


# Capitolul 2

## `shared/` – modul comun al suitei (arhitectură și structuri detaliate)

> Scop: oferă biblioteci, tipuri, utilitare, SDK‑uri și observabilitate comune tuturor aplicațiilor și Control Plane‑ului. Standardizează API‑urile, erorile, contractele de evenimente și UX‑ul.

### 1) `ui-design-system/`
Structură pe 6–7 niveluri până la fișiere, cu comentarii pentru fiecare element.

```
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

### 2) `feature-flags/` - SDK server/client + API admin, cu DB și openapi.

```
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

### 3) `auth-client/` - PKCE → OIDC → JWT, hooks React, guards RBAC/ABAC, multi‑tenant routing.

```
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

### 4) `types/` - Tipuri cross‑domain: domain/api/events/security/ui/validation/dto/errors/utils.

```
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

### 5) `common/` - Utilitare, config centralizat, logger, middleware și mapare erori.

```
shared/common/
├── index.ts
├── utils/{date.ts,number.ts,string.ts,crypto.ts,env.ts,index.ts}
├── config/{default.ts,dev.ts,staging.ts,prod.ts}
├── constants/{index.ts,featureKeys.ts,limits.ts}
├── middleware/{requestId.ts,errorBoundary.ts,rateLimit.ts,cors.ts}
├── error-handling/{problem.ts,errorMapper.ts}
└── logger/{pino.ts,formatters.ts,index.ts}
```

### 6) `integrations/` - Conectori oficiali (BNR, ANAF, Revolut, Shopify, Stripe, PandaDoc, e‑mail/SMS/WA, Graph, OpenAI, ElevenLabs, curieri).

```
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

### 7) `observability/` - Stack complet: logs/metrics/traces + dashboards, alerts și OTEL collector.

```
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

---
## Convenții generale
- **Naming:** `kebab-case` pentru directoare, `PascalCase.tsx` pentru componente, `camelCase.ts` pentru utilitare.
- **Barrel exports:** fiecare subdirector expune `index.ts` pentru API clar și tree‑shaking.
- **Strict TS:** `"strict": true`, `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`.
- **Testare:** unit (Jest), vizual (Playwright), e2e acolo unde are sens (component stories).
- **Versionare:** changeset pe pachetele `shared/*` + release automat în registry intern.
---

# Capitolul 3

## `cp/` – Control Plane (arhitectură și structuri detaliate)

> Scop: găzduiește serviciile centrale ale suitei: orchestrator MF, admin, login PKCE/OIDC, identitate (SuperTokens + OIDC provider + RBAC), licențiere & metering, analytics hub (BI pentru suită) și AI hub. Toate serviciile sunt containerizate și pot rula independent sau orchestrate la rădăcină.

### 1) `suite-shell/` – orchestrator micro‑frontend (Module Federation host)

```
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

```
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
│       │   │   ├── drizzle/             # schema.ts + migrations
│       │   │   └── seeds.ts
│       │   ├── auth/
│       │   │   ├── guards.ts            # requireScope/role/entitlement
│       │   │   └── session.ts           # verify JWT
│       │   ├── index.ts                 # Fastify v5.6.1 bootstrap
│       │   └── health.ts
│       └── Dockerfile
├── compose/
│   └── docker-compose.yml
└── README.md
```

### 3) `suite-login/` – portal PKCE + OIDC

```
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

```
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
│   │       ├── db.adapter.ts           # Drizzle/PG adapter
│   │       ├── email.adapter.ts        # SMTP provider
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
│   │   │   ├── schema.ts               # Users, Sessions, Tenants, Orgs
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

```
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
│   │   │   ├── schema.ts               # plans, features, entitlements, usage
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

```
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
│   └── scheduler.ts                    # Temporal workflows pentru publicare Data Products
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

```
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

---
## Convenții & operațional
- **Segregare clară** `apps/` vs `services/`, `web/` vs `api/` când e cazul.
- **AuthN/AuthZ** centralizate: toate rutele admin trec prin `identity` (JWT + scopes + entitlements).
- **Temporal**: workflows pentru ingestie (analytics-hub) și joburi programate (licensing.jobs).
- **Kafka**: topics canonice pentru evenimente cross‑app (publicate din apps ca "Data Products", consumate de cerniq și alte module).
- **Docker Compose** la nivel de serviciu + profiluri orchestrate la rădăcină.
---

# Capitolul 4

## `archify.app/` – Document Management (DMS) – arhitectură și structuri detaliate

> Scop: gestionare documente enterprise (upload, OCR, indexare, versionare, permisiuni granulare, registru intrări/ieșiri, șabloane, e‑semnătură, fluxuri de aprobare, retenție legală), integrată în suita GeniusERP sau vândută stand‑alone.

### 1) Structură generală (6–7 niveluri, până la fișier) – web + API + servicii

```
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
│   │   │   │   │   ├── VersionTimeline.tsx
│   │       │   │   │   └── ShareDialog.tsx
│   │       │   │   ├── hooks/
│   │       │   │   │   ├── useDocuments.ts              # tRPC queries + cache
│   │       │   │   │   ├── useUpload.ts                 # resumable + progress
│   │       │   │   │   └── useShare.ts                  # link secure, expirare
│   │       │   │   ├── state/
│   │       │   │   │   ├── selection.store.ts           # Zustand: selectare rânduri
│   │       │   │   │   └── filters.store.ts
│   │       │   │   └── index.ts
│   │       │   ├── search/
│   │       │   │   ├── components/
│   │       │   │   │   ├── SearchBox.tsx
│   │       │   │   │   ├── Facets.tsx
│   │       │   │   │   └── ResultItem.tsx
│   │       │   │   ├── hooks/useSearch.ts               # query builder, highlight
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
│       │   │   │   ├── schema.ts              # Documents, Files, Versions, Tags, ACL
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
│   │   ├── src/{index.ts, worker.ts}           # ascultă evenimente dms.file.uploaded
│   │   └── Dockerfile
│   ├── ocr-worker/
│   │   ├── src/{index.ts, worker.ts}           # procesează coada OCR
│   │   └── Dockerfile
│   ├── converter/
│   │   ├── src/{index.ts, worker.ts}           # office→pdf, split/merge
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
│   │   ├── originals/                          # fișiere brute
│   │   ├── thumbnails/
│   │   └── previews/
│   └── policy/
│       ├── retention.yaml                      # reguli ștergere/archivare
│       └── lifecycle.yaml
├── env/
│   ├── .env.example
│   ├── vault.template.hcl
│   └── README.md
├── compose/
│   ├── docker-compose.yml                      # api, web, workers, db, minio, clamav
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
│   └── flows.spec.ts                           # upload → OCR → index → search → share
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
- **Auth**: PKCE→OIDC→JWT (SuperTokens/identity), RBAC + entitlements din CP/licensing.
- **RLS/CLS**: filtre la nivel de tenant/utilizator pentru interogări și căutări.
- **OTEL**: trace pentru upload/OCR/indexare; logs structurate (pino) + metrics (durate OCR, rata erori, dimensiune fișiere).

### 4) Integrare cu suita
- **MF remote**: `web` poate fi încărcat în `cp/suite-shell`.
- **API**: expune tRPC + OpenAPI; gateway-ul global poate compune rute și policy‑uri.
- **Evenimente (Data Mesh)**: Publică "Produse de Date" (ex. dms.document.created, dms.document.ocr_extracted) pe Kafka, disponibile pentru consum de către cerniq.app și ai-hub`.'


# Capitolul 5

## `cerniq.app/` – Advanced Business Intelligence Hub (arhitectură și structuri detaliate)

> Scop: platformă Data Mesh & BI. Acționează ca un **consumator** inteligent de "Produse de Date" publicate de celelalte module (archify, numeriqo, i-wms etc.). Nu deține datele brute. Unifică aceste date într-un semantic layer centralizat pentru dashboards, AI și analiză predictivă.

### 1) Structură generală (6–7 niveluri, până la fișiere) – collectors → ingestion → transforms → warehouse → semantics → apis → dashboards → governance

```
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
## 2) Fluxuri cheie
- **Consum Data Mesh**: Se abonează la "Produse de Date" publicate de modulele operaționale (ex. wms.stock_changed, numeriqo.invoice.paid).
- **Guvernanță**: Validează la intrare contractele de date (schemas) ale produselor consumate.
- **Semantic Layer**: Unifică produsele de date într-un model semantic central (metrics, dimensions), fără a muta datele brute.
- **Semantic layer** definește KPI/dimensiuni și controlează consistența rapoartelor.
- **Federation gateway** randează SQL sau calcule semantice, cu cache + invalidare CDC.
- **Governance**: RLS/CLS, data contracts, lineage (OpenLineage), catalog & ownership.
## 3) Securitate, multi-tenant & licențiere
- Integrare `cp/identity` (PKCE→JWT, scopes) + `cp/licensing` (entitlements la nivel metric/raport).
- RLS per tenant, masking pentru PII, audit acces & query.
## 4) Observabilitate
- OTEL (traces pentru query & transformări), logs structurate (pino), metrics runtime: cache hit ratio, query latency p95, job failures.


Capitolul 6
flowxify.app/ – Platformă de Orchestrare Inteligentă (BPM, AI, iPaaS, Collab)
Scop: Platformă de orchestrare inteligentă bazată pe o **Arhitectură Hibridă Dublă**: 
Nivel 2 (Inteligență No-Code): Agenți AI (CrewAI/LangGraph via cp/ai-hub) și Server MCP (Model Context Protocol) pentru brainstorming și orchestrare dinamică a proceselor.
Nivel 1 (Orchestrare Code-First): BPM Durabil (Temporal) pentru **toate** procesele stateful (SLA-uri, aprobări, procese de lungă durată) și pentru execuția **fluxurilor customizate (serviciu monetizabil "BPM on-request")**.
## 1) Structură generală (6–7 niveluri, până la fișiere) – web + API + serviciiflowxify.app/
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
## 2) Fluxuri funcționale cheie (Arhitectură Hibridă Triplă)
### Nivel 3: Brainstorming (No-Code AI):
Utilizatorul (în Collab/Chat 1) cere un proces ("Aprobare factură"). Agentul AI (din cp/ai-hub 1) interpretează cererea, folosește MCP pentru a apela tool_start_temporal_workflow, și pornește un workflow de Nivel 1.
### Nivel 1: Execuție Durabilă (Code-First - Temporal):
Workflow-ul pornit la Nivelul 3 rulează. Acesta execută pași critici (ex. verifică suma în numeriqo.app).
### Nivel 1 -> HITL (Human-in-the-Loop):
Workflow-ul Temporal ajunge la pasul de aprobare. Apelează tool_create_human_task (via MCP sau o activitate directă). Un task nou apare în Tasks.tsx (Kanban). Workflow-ul Temporal intră în "așteptare" (sleep).
### HITL -> Nivel 1:
Managerul aprobă task-ul în UI. Acțiunea trimite un semnal workflow-ului Temporal aflat în așteptare, care se "trezește" și continuă.
### Unificarea Orchestrării Toate execuțiile 
Atât cele inițiate de AI-Nivel 3, cât și cele predefinite, rulează exclusiv pe motorul Temporal (Nivel 1). Integrările non-critice (ex. "Postează un mesaj pe Slack") sunt executate ca activități Temporal standard, nu printr-un sistem iPaaS separat, asigurând o orchestrare cu stare unificată.

## 3) Securitate & Multi‑tenant
PKCE→OIDC→JWT (cp/identity), RBAC + entitlements (cp/licensing) pentru spații/proiecte/canale.
RLS pe tabele (tenant_id + membership), audit evenimente (Kafka → cerniq).
Serverul MCP aplică aceleași politici de autorizare, asigurând că agenții AI nu pot executa acțiuni nepermise utilizatorului.
## 4) Observabilitate
OTEL (traces pentru WS, workflows, DB), logs structurate, metrics: message fanout latency, WS connections, task cycle time, approval SLA breachs.
NOU: Metrics pentru Nivelul 3 (timp de răspuns agent AI, utilizare unelte MCP).
## 5) Integrare cu suita
MF remote: web poate fi încărcat în cp/suite-shell.
API: tRPC + OpenAPI; gateway global compune rute și policies.Integrare AI (Nivel 3): Consumator principal al cp/ai-hub (Cap 3) (pt. agenți LangGraph/CrewAI). Expune un Server MCP cu "unelte" (tools) pentru a orchestra Nivelul 1 și 2.
Servicii BPM On-Request: Expune API-uri pentru serviciul monetizabil de dezvoltare fluxuri customizate pe Temporal, permițând clienților să solicite și să monitorizeze noi automatizări.
Evenimente: Kafka (collab.task.created, chat.message.posted, bpm.approval.pending, agent.flow.generated).


Capitolul 7
# i-wms.app/ – Warehouse & Inventory (arhitectură și structuri detaliate)
Scop: WMS multi‑depozit, multi‑tenant, cu optimizare AI (slotting dinamic, prognoză cerere, planificare picking), orchestrare WES (roboți & forță de muncă), recepții (ASN), NIR românesc, putaway ghidat, picking (Single/Multi/Batch/Wave/Streaming), FEFO/FIFO, lot/serie/expirări, inventariere (cycle count), packing, etichetare (ZPL), expediții (curieri RO), transferuri inter‑depozit, 3PL billing și sincronizare e‑commerce/OMS/POS.
## 1) Structură generală (6–7 niveluri, până la fișiere) – web + API + servicii + RF
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
## 2) Fluxuri funcționale cheie (Actualizat cu AI)
Inbound: ASN → recepție → NIR (RO) → putaway ghidat (AI slotting & capacități).

Inventory: stoc granular (lot/serie/exp), RLS per tenant & depozit, transferuri, ajustări, cycle counts.

Outbound: AI wave planning (order streaming) → picking optimizat (zone/batch/path) → packing (dim weight) → etichete curier → tracking.

Replenishment: AI Demand Forecast (bazat pe cp/ai-hub ) vs. reguli min/max statice, tasking automat.

Orchestrare WES: NOU: Alocare dinamică a taskurilor (roboți & operatori) prin Agent AI Supervisor (conectat la cp/ai-hub ).

3PL: servicii tarifabile, rate cards, export facturi către numeriqo.app.
## 3) Securitate & Multi‑tenant
PKCE→OIDC→JWT (cp/identity), RBAC + entitlements (cp/licensing) pe depozit/zonă.

Audit evenimente operaționale → Kafka (cerniq.app).
## 4) Observabilitate
OTEL (traces pentru RF, picking, carriers, AI models), logs structurate, metrics: UPH/LPH, lead time inbound/outbound, acuratețe stoc, acuratețe prognoză AI.
## 5) Integrare cu suita
MF remote: apps/web poate fi încărcat în cp/suite-shell.

API: tRPC + OpenAPI; gateway global compune rute și policies.

Integrare AI: Consumator principal al cp/ai-hub (Cap 3)  pentru modele de prognoză, optimizare și agenți.

Evenimente: Kafka (wms.inbound.received, wms.pick.completed, wms.shipped, wms.ai.recommendation.generated).


Capitolul 8
# `mercantiq.app/` – Commerce & Sales Ops (arhitectură și structuri detaliate)
> Scop: aplicație stand‑alone pentru cataloage produse, cotații/ofertare B2B, coș/checkout, comenzi, plăți, promoții, prețuri dinamice, integrare marketplace & e‑commerce, sincron stoc (cu `i-wms.app`), facturare *lite* (export spre `numeriqo.app`), CRM & lead hand‑off (`vettify.app`), asistent AI pentru oferte și recomandări. Multi‑tenant, RBAC & entitlements prin `cp/identity`/`cp/licensing`.
## 1) Structură generală (6–7 niveluri, până la fișiere) – web + API + engines + services
```
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
## 2) Fluxuri funcționale cheie
- **Catalog & Căutare**: atribute, variante, prețuri, dispo stoc (via `i-wms.app`), FTS + facete.
- **Cotații B2B**: generare, discounturi negociate, aprobare (integrare `flowxify`), conversie în comenzi.
- **Coș & Checkout**: cupoane, taxe, transport, intents de plată (Stripe/Revolut), 3DS, webhooks.
- **Comenzi**: alocare multi‑depozit, tracking transport, retururi; facturare *lite* → export `numeriqo`.
- **Recomandări/AI**: cross/upsell, reprice suggestions (semnale din `cerniq`).
## 3) Securitate & Multi‑tenant
- PKCE→OIDC→JWT (cp/identity), RBAC + entitlements (cp/licensing) pe canale/segmente.
- RLS per tenant, audit evenimente vânzare → Kafka (`cerniq.app`).
## 4) Observabilitate
- OTEL (traces pentru checkout, payment, sync), logs structurate, metrics: conversie, latency plăți, erori webhooks, out‑of‑stock rate.
## 5) Integrare cu suita
- MF remote: `apps/web` încărcabil în `cp/suite-shell`.
- API: tRPC + OpenAPI; gateway global compune rute/policies.
- Evenimente: Kafka (`commerce.order.created`, `commerce.payment.succeeded`).


Capitolul 9
# `numeriqo.app/` – Accounting, Tax (RO), HR & Payroll – arhitectură și structuri detaliate
> Scop: aplicație stand‑alone și modul al suitei pentru **contabilitate românească** (OMFP 1802/2014, plan de conturi, partidă dublă, registre, TVA – D300/D394/D390, SAF‑T D406), **facturare pro + e‑Factura**, **HR & Payroll** (contracte, REGES‑Online, D112), politici salarizare, pontaj, concedii, tichete, rețineri, exporte bancare, raportări către ANAF/BNR/IM. Multi‑tenant, RBAC, RLS pe entități contabile.
## 1) Structură generală (6–7 niveluri, până la fișiere) – web + API + domenii + servicii
```
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
## 2) Modele de date – esențiale (Drizzle)
- **Cont**: `code`, `name`, `type` (`asset|liability|equity|income|expense|bifunctional`), `parent`, `currency`, `isAnalytic`, `tenantId`.
- **NotaContabila**: `date`, `period`, `lines[]` (cont, debit, credit, descriere, VATLink?), `docRef` (factură/încasare/plată), `locked`.
- **Jurnal**: tip (`sales|purchases|cash|bank|general`), `sequence`, `documentNo`, legături la note.
- **VATDoc**: `regime`, `rate`, `base`, `tax`, mapări linii D300/D394/D390.
- **FixedAsset**: `class`, `method`, `lifetime`, `residual`, `startDate`, `depreciationPlan[]`.
- **Invoice**: `series`, `number`, `partner`, `lines[]` (cont venit/chelt., TVA), `due`, `status`, `ubl`.
- **Employee/Contract/Timesheet/PayrollRun/Payslip**: câmpuri standard + istorice.
## 3) Fluxuri funcționale cheie
- **Partidă dublă**: orice document generează **note contabile echilibrate** (debit=credit). Lock perioade la închidere.
- **TVA**: setări cote/regimuri, marcaj „TVA la încasare”, reconciliere D300↔D394↔D390, validări VIES.
- **SAF‑T (D406)**: builder XML pe schemele RO, validări de consistență și raport erori; export lunar/trimestrial/anual după categorie contribuabil.
- **HR**: gestionare CIM, reviste contracte, generare export hibrid REGES‑Online și integrare API; pontaj cu coduri muncă; politici concedii. - **Payroll**: motor brut→net (contribuții, impozit, deduceri), fluturași, fișiere bancare, D112.
- **Invoicing Pro**: e‑Factura (upload & status), serii numerotare, șabloane PDF/UBL.
## 4) Securitate & Multi‑tenant
- PKCE→OIDC→JWT (cp/identity), RBAC + entitlements (cp/licensing) pe entități (companie, jurnal, perioadă). RLS pe tabele cu `tenantId` + `companyId`.
## 5) Observabilitate
- OTEL (traces pentru posting, generatoare D‑forms, payroll), logs structurate, KPIs contabile, alerte reconciliere TVA și erori SAF‑T/D112.
## 6) Integrare cu suita
- MF remote: `apps/web` încărcabil în `cp/suite-shell`.
- API: tRPC + OpenAPI; gateway global compune rute și policies.
- Evenimente: Kafka (`acct.entry.posted`, `vat.return.generated`, `hr.payroll.closed`).


Capitolul 10
# `triggerra.app/` – Marketing Automation, Intelligence & Decisioning (state‑of‑the‑art)
> Scop: aplicație stand‑alone și modul de marketing al suitei. Concentrează **automation**, **CDP first‑party**, **analytics avansat** (MTA + MMM), **decisioning în timp real**, **journey orchestration** (Temporal), **SEO & Product Knowledge Graph** ca „source of truth”, **data clean rooms** și **server‑side tagging**. Integrare nativă cu `vettify.app` (CRM), `mercantiq.app` (commerce), `i-wms.app` (stoc/logistică), `numeriqo.app` (costuri/margini), `cerniq.app` (BI Hub).
## 1) Structură generală (6–7 niveluri, până la fișiere) – web + API + engines + analytics + services
```
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
## 2) Modele de date – esențiale (Drizzle)
- **Profile** (CDP): identități (email, phone, deviceId, cookieId), `traits` (JSONB tipizat), consimțământ (TCF 2.2), `tenantId`.
- **Events**: evenimente normalizate (view, add_to_cart, checkout, purchase, lead_submitted), sursă (web/app/backend), UTM, campaign/adset/ad, `profileId`.
- **Audiences**: reguli (inclusion/exclusion), dimensiune, refresh policy, export destinations (adtech/CDP extern).
- **Assets**: creativ, varianta, canal, budget cap, flight window.
- **Experiments**: design (A/B/n, bandit, uplift), `metrics` (primary/secondary), trafic alocat.
- **SEO/Feeds**: `productId`, schema JSON‑LD generată, stări feed (GMC/Meta/marketplace), erori validator.
## 3) Fluxuri funcționale cheie
- **CDP & Tagging**: colectare server‑side (GTM‑SS) → normalizare → îmbogățire (UTM/geo) → scriere în Events; rezolvare identități; consimțământ TCF aplicat înainte de activări.
- **Journeys**: templatizate (bun‑venit, abandon coș, replenishment, winback); orchestrare cu Temporal; canale: email/SMS/WhatsApp/ads audiences; throttling & frequency caps.
- **Attribution**: MTA (Markov/Shapley/time‑decay) pentru digital; MMM (Robyn/LightweightMMM) pentru mix cross‑canal + optimizator bugete.
- **Decisioning**: bandits pentru creativ/landing; uplift pentru targeting incremental; alocare buget pe constrângeri & ROI.
- **SEO & Source‑of‑Truth**: generator JSON‑LD (schema.org Product) + feeduri GMC/Meta; reconciliere PIM↔web; validare conform ghidurilor Google.
- **Research & Enrichment**: crawlers etici (robots.txt), parsare schema.org, agregare specificații/preturi; scor calitate + deduplicare; publică "Produse de Date" (ex. marketing.trends) consumabile de cerniq.app (Data Mesh).
- **Clean Rooms & Privacy**: Ads Data Hub / BigQuery DCR pentru analize agregate; PII redaction/hashing; guvernanță acces.
## 4) Securitate & Multi‑tenant
- PKCE→OIDC→JWT (cp/identity), RBAC + entitlements (cp/licensing). RLS pe `tenantId` + controale pe canale & destinații. Audit complet pentru activări & exporturi.
## 5) Observabilitate
- OTEL (traces pentru journeys, activări, MTA/MMM joburi), logs structurate, metrics: delivery, uplift, ROAS, cost per event, erori feeds.
## 6) Integrare în suita
- MF remote: `apps/web` încărcabil în `cp/suite-shell`.
- API: tRPC + OpenAPI; gateway global compune rute/policies.
- Evenimente: Kafka (`marketing.event.ingested`, `marketing.journey.sent`, `marketing.attribution.updated`).


Capitolul 11
# `vettify.app/` – CRM, Relationships & Firmographics (EU‑grade)
> Scop: aplicație stand‑alone și modul CRM al suitei, axată pe **prospects/leads/clients/partners/suppliers**, **firmographics RO+UE (oficiale, GDPR‑compliant)**, **identity resolution**, **enrichment automat**, **lead scoring ML & ICP fit**, **sales funnels & pipeline automation**, **outreach multi‑canal**, **data quality & dedup**, **graph‑360 relații**. Integrare nativă cu `triggerra.app` (marketing CDP), `mercantiq.app` (sales orders & quotes), `numeriqo.app` (invoicing/account status), `cerniq.app` (BI) și `i‑wms.app` (livrări).
## 1) Structură generală (6–7 niveluri) – web + API + enrichment + graph + services
```
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
## 2) Modele de date – esențiale (Drizzle + Graph)
- **Lead**: identități brute (email/phone/domain/url), sursă, `status`, `score`, `owner`, `tenantId`.
- **Account**: companie; CUI/TVA, CAEN, dimensiune, venituri, adrese, website, tehnologie (techgraph), `riskProfile`.
- **Contact**: persoană; consimțământ by‑channel, preferințe, job title, seniority, `gdprFlags`.
- **Opportunity**: pipeline/stadiu, forecastCategory, value, currency, expectedClose.
- **Activity**: tip (call/email/meeting/task), outcome, nextStep, linked entities.
- **EnrichmentSource**: vendor, fields coverage, trust score, freshness, provenance.
- **Graph (Neo4j)**: noduri `ACCOUNT`, `CONTACT`, `LEAD`, relații `WORKS_AT`, `OWNS`, `PARTNERS_WITH`, `CHILD_OF` (grupuri), `INTERACTED`.
## 3) Fluxuri funcționale cheie
- **Identity Resolution & Dedupe**: matching determinist (email, domain+CUI) + fuzzy (nume, adresă) cu scor; **merge survivorship** pe reguli (freshness, trust, source priority) + audit lineage.
- **Firmographics EU‑grade**: prioritizare surse oficiale (RO: CUI/TVA, bilanțuri) + vendori EU (intent, tech install); reconciliere periodică & alerts diferențe.
- **Enrichment Orchestrator**: Temporal workflows: `enrich.lead` → `enrich.account` → `verify.email` → `score.icp` → `route.owner`. Timeouts & fallbacks per sursă; cache + TTL.
- **Email Discovery & Verification**: pattern‑guess + MX checks + API NeverBounce/ZeroBounce; hard‑bounce suppression & hygiene score; double‑opt‑in.
- **Outreach Sequences**: multi‑canal (email/SMS/WhatsApp) cu throttling, quiet hours, A/B, reply intent detect; auto‑stop la pozitiv/negativ.
- **Lead Scoring ML**: features din firmographics, intent signals, web events (Triggerra), istoric vânzări; model binar (close/won) + **uplift** pentru prescriptiv.
- **Graph360**: vizualizare grupuri, relații între conturi, parteneriate, shareholding; query „path to power” pentru stakeholders; recomandări next‑best‑account.
## 4) Securitate & Multi‑tenant
- PKCE→OIDC→JWT (cp/identity), RBAC + entitlements (cp/licensing). RLS pe `tenantId`; mascare câmpuri sensibile; export guvernat cu registre de procesare.

## 5) Observabilitate
- OTEL pentru enrichment/identity/outreach; KPIs: coverage, hygiene, conversion lift, reply rate; alerte pentru spike‑uri de bounce sau rate‑limit vendors.
## 6) Integrare cu suita
- MF remote: `apps/web` încărcabil în `cp/suite-shell`.
- API: tRPC + OpenAPI; gateway global compune rute/policies.
- Evenimente: Kafka (`crm.lead.created`, `crm.account.enriched`, `crm.sequence.sent`).
```
## 7) Seeds & Playbooks (inițiale)
- **ICP Templates** (SaaS/Manufacturing/Commerce) – câmpuri & greutăți scor.
- **Pipeline Defaults** – stadii + probabilități + SLA per stadiu.
- **Sequences** – cold outreach (etice, opt‑in), nurture, referral, re‑activation.
## 8) Config & Policies
- **Field Mapping** (import CSV/XLSX, API) cu validatori CUI/IBAN/phone.
- **Source Priority** – matrice vendor×câmp (firm name, revenue, headcount, NAICS/CAEN etc.).
- **GDPR** – DPIA/LIA templates, residency EU, TCF v2.2 hooks pentru tracking/activation.


Capitolul 12
# `geniuserp.app/` – Suite Orchestrator Surface & Tenant Operations
> Scop: aplicație stand‑alone (public website + customer portal) și „fața” suita **GeniusERP**. Nu dublează Control Plane (CP), ci îl **orchestrază și expune** pentru clienți: onboarding, SSO, management tenanți, abonamente & facturare (front), status & suport, documentație. Integrare strânsă cu `cp/identity`, `cp/licensing`, `gateway/`, `shared/feature-flags`, `shared/ui-design-system`.

- **Public site**: homepage, produse, prețuri, blog/docs, contact, legal.
- **Customer Portal**: workspace selector, provisioning subdomenii, SSO → **suite-shell**, gestionare licențe, plăți, invitații, audit bazic.
- **Status & Incidente**: status public, RSS/Atom, istorice incidente, SLO/SLA vizibile.
- **Docs**: ghiduri, changelog, API docs (agregat din `gateway/openapi`).
## 1) Structură generală (6–7 niveluri, până la fișiere)
```
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
## 2) Contracte & Evenimente (interfețe cu CP și suita)
- **Bridge CP**: `identity.client.ts` (creare utilizator/invitații, SSO settings), `licensing.client.ts` (planuri, entitlements, metering), `billing.client.ts` (checkout/portal), `gateway.client.ts` (OpenAPI union + service discovery).
- **Events (Kafka)**: `tenant.created`, `tenant.domain.verified`, `license.plan.changed`, `billing.payment.failed`, `user.invited`, `user.accepted`.
## 3) Fluxuri cheie
- **Onboarding**: signup → verificare domeniu (opțional) → creare tenant → seed defaults → alegere plan trial → invitații → Launch (handoff la `cp/suite-shell`).
- **SSO Enterprise**: configurare OIDC/SAML, test conexiune, enforce SSO, SCIM provisionare automată.
- **Provisioning Subdomenii**: verificări DNS (TXT/CNAME), emitere certificate (Traefik ACME), mapare routes.
- **Billing & Licențe**: checkout, dunning, upgrade/downgrade, seat management, entitlements sincronizate în SDK‑urile app‑urilor.
- **Docs & API**: agregare OpenAPI din `gateway` + MDX docs, changelog sincronizat din monorepo tags.
## 4) Securitate & Multi‑tenant
- PKCE→OIDC→JWT (via `cp/identity`). RLS pe `tenantId` în tabele portal. Guard pentru entitlement la nivel de rută UI + API. Audit trail la acțiuni critice.
## 5) Observabilitate
- OTEL: traces pentru provisioning/billing; dashboards de funnel (signup→launch), alerte pentru eșec provisioning/dunning > N.
## 6) Integrare în suita
- „Launch” deschide `cp/suite-shell` cu tenant context + token SSO. Portalul devine sursa principală pentru operațiuni tenant (users, domains, licenses, billing) — CP rămâne intern (adminită de echipa noastră).


Capitolul 13
# `gateway/` – API Gateway, BFF & Policy Enforcement (suite‑wide)
> Scop: layer unic de **intrare** în suită pentru UI‑uri (BFF), agregare API‑uri cross‑app (tRPC + OpenAPI), **policy enforcement** (authZ pe roluri + entitlements + tenant RLS), **rate‑limiting & caching**, observabilitate, **schema governance** și **service discovery**. Nu dublează CP; îl folosește (identity/licensing) și compune interfețe stabile pentru clienți interni/externi.
## 1) Structură generală (6–7 niveluri)
```
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
## 2) Fluxuri cheie
- **AuthN/AuthZ**: PKCE→OIDC (via `cp/identity`) → JWT validat (JWKS cache) → RBAC + entitlements (via `cp/licensing`) → OPA policies.
- **BFF**: agregă rute pentru UI (portal, site, shell) și aplică caching+ratelimit atent la tenant/plan.
- **API Gateway**: unifică **tRPC** (federat) + **OpenAPI** (agregat) și oferă rute REST stabile; transformă răspunsurile și normalizează paginațiile.
- **Discovery & Health**: registry semiautomat din compose; poller degradează serviciile instabile (circuit breaker).
- **Schema Governance**: lint/validate specs, versionare evenimente (JSON Schema/Avro), compat check între apps și gateway.
## 3) Interfețe cu alte module
- `cp/identity` → JWKS, claims, OIDC; **bff/security/jwt.verify.ts** folosește cache + rotație chei.
- `cp/licensing` → entitlements & metering; **security/entitlement.guard.ts** blochează rutele fără drepturi.
- `shared/feature-flags` → toggles pentru rollout endpointuri noi.
- Aplicații stand‑alone → publică `trpc` routers și `openapi` specs; **federation/** le compune.
## 4) Observabilitate & SLO
- OTEL traces pe hop‑uri (BFF→Gateway→Service), Prometheus metrics (lat, err rate, pXX), dashboards grafana preset.
- Alarme: `5xx_rate>1%` 5m, `p95_latency>1s` 10m, `auth_fail_spike`.
## 5) Securitate
- Strict transport security (HSTS), CORS pe allowlist din tenants, rate‑limit adaptiv pe plan, redaction PII în logs, mTLS opțional spre servicii sensibile.
## 6) Deploy & CI
- Compose per modul + orchestrator root; job CI pentru **openapi build + spectral lint + publish**; contract tests pentru compatibilitate înainte de release.


Capitolul 14
# `proxy/` – Edge Proxy, Ingress & Routing (Traefik primary, Caddy optional)
> Rol: stratul **edge** al suitei GeniusSuite. Face terminare TLS (ACME/LE), rutare pe domenii/subdomenii către serviciile interne (gateway, cp, apps), **forward‑auth** către `cp/identity` (PKCE→OIDC→JWT), **security headers/WAF**, **rate‑limit & buffering**, **HTTP/2 + HTTP/3 (QUIC)**, **WebSocket** pass‑through, **observabilitate**. Mode „hibrid”: *compose per app* + *compose orchestrator root*.
## 1) Structură director (6–7 niveluri) cu fișiere comentate
```
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
## 2) `traefik/static/traefik.yml` – conținut exemplificativ (comentat)
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

## 3) `traefik/dynamic/routers/geniuserp.yml` – rute (site, portal, status, docs)
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
## 4) `traefik/dynamic/middlewares/oauth-forwardauth.yml` – forward auth (OIDC/JWT)
```yaml
http:
middlewares:
oauth-forwardauth:
forwardAuth:
address: "http://forward-auth:3000/check"   # validează JWT (cp/identity JWKS)
trustForwardHeader: true
authResponseHeaders: ["X-User-Id","X-User-Roles","X-Tenant-Id"]
```
## 5) Compose (root) – extras `proxy/compose/docker-compose.yml`
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
## 6) Integrare cu orchestratorul root & per‑app compose
- **Per‑app**: fiecare aplicație are etichete Docker `traefik.enable=true`, `traefik.http.routers.<app>.rule=Host(...)`, sau folosim **providerul file** (recomandat pentru multi‑tenant) → fișiere generate în `traefik/files/tenants/tenant-<id>.yml` via `scripts/generate-tenant-route.ts`.
- **Orchestrator root**: atașează toate serviciile pe rețelele `edge` și `internal`, expune Traefik pe 80/443, gestionează ACME centralizat, logs și metrics.
## 7) Securitate
- **Headers**: HSTS, CSP strict (nonce), Referrer‑Policy, X‑Frame‑Options deny pe portal/admin.
- **Auth**: `forwardAuth` obligatoriu pentru subdomeniile aplicațiilor (exceptând public/health).
- **mTLS intern**: pentru servicii sensibile (identity/licensing/gateway‑admin) conform `dynamic/tls/mtls.yml`.
- **Rate‑limit**: per plan/tenant, protecție DoS; **circuit‑breaker** pe servicii instabile.
- **Logs**: access log JSON cu redactare PII; trimise la `observability/` (Loki + dashboards).
## 8) Observabilitate & Testare
- **Metrics**: Prometheus scrape; dashboards Grafana predefinite.
- **Smoke tests**: `scripts/smoke.sh` execută rute critice (200/302/403) pentru fiecare domeniu.
- **Health**: liveness/readiness pentru container Traefik + probe pe upstreams.
## 9) Proceduri operaționale (README)
- Adăugare tenant: rulează `scripts/generate-tenant-route.ts`, verifică DNS, reload config.
- Rotație ACME: `scripts/rotate-acme.sh` (backup → rotate → reload); permisiuni 600 pe `acme.json`.
- Failover: profil **Caddy** – pornește `caddy/compose/docker-compose.yml` și dezactivează Traefik.


Capitolul 15
# `scripts/` – DevOps, CI/CD & Tooling for GeniusSuite (root‑level)
> Rol: colecție unificată de **scripturi operaționale** pentru bootstrap monorepo, orchestrare Docker (model hibrid), baze de date (Drizzle), build & release, QA (e2e, load, security), guvernanță API (OpenAPI + tRPC), provisioning tenanți, observabilitate, și siguranță (secrets, SBoM). Toate scripturile suportă target **global** sau **per‑aplicație** (`--app vettify.app`) și **per‑mediu** (`--env dev|staging|prod`).
## 1) Arhitectura directorului (6–7 niveluri + fișiere)
```
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
## 2) `bin/gs` – CLI unificat (schelet)
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
## 3) Exemple de comenzi uzuale (README)
- **Pornește suita minimă pentru onboarding:** `scripts/bin/gs compose up --profile core`
- **Migrare DB pentru `numeriqo.app` în staging:** `gs db migrate --app numeriqo.app --env staging`
- **Agregă & publică OpenAPI:** `gs api openapi publish --env prod`
- **Rulează e2e critice:** `gs qa e2e run --select signup-to-launch`
- **Creează tenant demo:** `gs provisioning tenants create --plan pro --domain acme.geniuserp.app`
## 4) Convenții
- Fiecare script **nu scrie** în repo fără prompt (`--yes`) și loghează în `logs/`.
- Toate scripturile acceptă `--dry-run`.
- Selectoare: `--app`, `--tag` (nx affected), `--env`, `--profile` (compose), `--tenant`.
## 5) Integrare cu celelalte module
- **proxy/**: `compose/sync-proxy.ts` regenerează file-provider din compose‑urile active.
- **gateway/**: `api/openapi/*` colectează & validează specs; `api/trpc/*` compune routers.
- **cp/**: `provisioning/*` apelează `identity/licensing` pentru SSO & entitlements.
- **shared/**: `codegen/*` folosește types & contracts pentru generarea SDK‑urilor.
## 6) Roadmap
- Profil **k8s** (Helm charts + skaffold dev loop).
- `gs doctor` pentru sănătate sistem end‑to‑end.
- Generare **tenant blueprints** (seturi de module+feature‑flags).


Capitolul 16
# Database Schema – GeniusSuite (v1 core)
> Obiectiv: schemă completă **PostgreSQL 18** pentru suita GeniusSuite, optimizată pentru vânzare ca **stand‑alone apps** și ca **suită**. Include tabele, coloane, tipuri ENUM, indici, chei, constrângeri și politici de multi‑tenancy.

---
## 0. Arhitectură date & multi‑tenancy
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

---
## 1. DB: `db_identity` (SSO, utilizatori, org, SAML/OIDC)
**Schemas:** `public` (global), `auth` (session/index), `admin` (audit).
### 1.1 Tabele cheie
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
## 2. DB: `db_licensing` (planuri, entitlements, metering, billing refs)
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
## 3. DB: `db_vettify` (CRM + Firmographics)
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

**Relații & constrângeri:** FK la `accounts` și `contacts`; `owner_id` referință la `identity.users` (cross‑db via app layer). **RLS ON**.

---
## 4. DB: `db_numeriqo` (Accounting RO + HR & Payroll)
**Schemas:** `public` (metadata), `tenant_*` pentru contabilitate și HR.
### 4.1 Accounting – tabele de bază (partida dublă, RO)
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
### 4.2 HR & Payroll (RO)
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
## 5. DB: `db_archify` (Document Management)
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
## 6. DB: `db_flowxify` (BPM + Collaboration + Intranet)
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
## 7. DB: `db_iwms` (Warehouse & Inventory)
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
## 8. DB: `db_mercantiq` (Sales, Invoicing lite, E‑commerce)
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
## 9. DB: `db_triggerra` (Marketing Automation)
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
## 10. DB: db_cerniq (BI Metastore & Data Mesh Cache)
> Notă: db_cerniq nu stochează datele brute (care rămân în DB-urile aplicațiilor). Stochează doar definițiile și cache-ul semantic.

- **data_products** - id uuid PK, tenant_id, source_module text(ex. 'numeriqo'),product_name text(ex. 'invoices_paid'),kafka_topic text, schema_definition jsonb (contractul de date).
- **semantic_metrics** - id uuid PK, tenant_id, name text(ex. 'MRR'),calculation_logic text, source_products uuid(FK ladata_products.id).
- **query_cache** - id uuid PK, tenant_id, query_hash text, result jsonb, expires_at timestamptz.
- **governance_rules** - id uuid PK, tenant_id, product_id uuid FK, rule_type text, config jsonb.

---
## 11. DB: `db_gateway` (policy cache, service registry)
- `service_registry` — `id`, `name`, `version`, `endpoint`, `health`, `updated_at`
- `policy_cache` — `id`, `tenant_id`, `route`, `policy jsonb`, `etag`, `updated_at`

---
## 12. Indici, constrângeri & performanță (guidelines)
- **Indici compuși** pentru chei de filtrare uzuale: `(tenant_id, status)`, `(tenant_id, created_at DESC)`.
- **GIN** pentru `jsonb` (path_ops) pe coloane `meta/criteria/payload`.
- **Partial indexes** pentru stări frecvente: ex. `WHERE is_deleted = false`.
- **FK ON DELETE CASCADE/SET NULL** după caz (ex: `document_versions` CASCADE; `owner_id` SET NULL).
- **Vederi materializate** pentru registre contabile și rapoarte frecvente (refresh programat).
- **PG18 – Skip Scan pe B‑tree:** definiți **indici multi‑coloană** când filtrele încep pe a doua/treia coloană; plannerul poate sări peste prefixele lipsă.
- **PG18 – `JSON_TABLE`:** preferați views care expun coloane relaționale peste `jsonb` (ex. firmographics, events) pentru interogări mai curate și mai rapide.

---
## 13. Concluzie: DB comună vs. DB per aplicație
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
## 14. Convenții denumire & tipuri
- Tabele `snake_case`, PK `id`, FK `<entity>_id`.
- Timpuri `timestamptz`. Bani `numeric(18,2)`; cantități `numeric(18,3/4)`.
- ENUM‑uri prefixate per domeniu (`enum_invoice_status`, `enum_wf_status`).
- Toate tabele tenant‑scoped au **RLS ON** + politici standard.

---
## 15. Extensii PostgreSQL necesare
`pgcrypto` (hash/encrypt), `citext`, `btree_gin`, `pg_trgm`, `pg_partman` (opțional), `postgis` (dacă e nevoie), `timescaledb` (opțional pentru events/time‑series).

> Notă: **`uuidv7()` este nativ în PostgreSQL 18**, nu mai este necesar `uuid-ossp`/`pg_uuidv7`. `JSON_TABLE` este disponibil fără extensii.

---
## 16. Migrate & seeds (Drizzle)
- Migrations versionate pe fiecare DB; seeds minime: roluri default, planuri, chart of accounts (RO), VAT codes, payroll pay items.

> Versiunea acestui schelet: **v1 core**. Pentru extindere (ex: e‑Factura detaliu, SAF‑T, modele HR avansate, E‑commerce complet) se pot adăuga sub‑canvasuri pe module.


Capitolul 17
Program de implementare pe faze – GeniusSuite
Structură generală de implementare, fiecare canvas = o fază. În fiecare fază avem subfaze (F1.1..Fn.m) care acoperă structura + scripturile din canvasul dedicat. Ordonarea ține cont de dependențe (Fundație/Auth/CP înaintea apps) și de livrabile incrementale (MVP → Hardening → GA).

F0 - Faza 0 — Fundația: Guvernanță, DevEx, DB & Scripts
Obiectiv: fundație comună, baze de date și scripturi de bază pentru toate proiectele.
F0.1 Monorepo & Tooling: NX + pnpm, workspaces, standard TS/ESLint/Prettier, commit hooks.
F0.1.1
{ 
"F0.1.1": { 
"denumire_task": "Creare Director Rădăcină Monorepo", 
"descriere_scurta_task": "Crearea directorului rădăcină /var/www/GeniusSuite.",
"descriere_lunga_si_detaliata_task": "Acest task inițiază structura fizică pe disc. Vom crea directorul rădăcină pentru întregul monorepo GeniusSuite. Conform planului, calea standardizată este '/var/www/GeniusSuite'. Această comandă trebuie executată cu permisiunile necesare (posibil 'sudo') în funcție de mediul sistemului de operare.",
"directorul_directoarele": [ "/var/www/" ],
"contextul_taskurilor_anterioare": "N/A. Acesta este primul task.",
"contextul_general_al_aplicatiei": "Se inițiază structura de fișiere pentru monorepo-ul GeniusSuite, care va conține toate aplicațiile (vettify.app, numeriqo.app, etc.) și bibliotecile partajate (shared/), conform.",
"contextualizarea_directoarelor_si_cailor": "Comanda 'mkdir -p /var/www/GeniusSuite' va crea directorul rădăcină. Toate task-urile următoare se vor desfășura în interiorul acestei căi.",
"Restrictii_anti_halucinatie":null,
"restrictii_de_iesire_din_contex": "Nu executa 'git init' sau alte comenzi. Doar creează directorul.",
"validare": "Rulează 'ls -d /var/www/GeniusSuite'. Comanda trebuie să returneze cu succes calea directorului.",
"outcome": "Directorul rădăcină '/var/www/GeniusSuite' există.",
"componenta_de_CI_DI": "În CI, acest pas este de obicei înlocuit de 'git checkout' într-un director de lucru predefinit." 
}
}
F0.1.2 
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
    "componenta_de_CI_DI": "N/A"
  }
}
F0.1.3
  {
    "F0.1.3": {
      "denumire_task": "Setare 'private: true' în 'package.json'",
      "descriere_scurta_task": "Editarea 'package.json' de la rădăcină pentru a seta 'private: true'.",
      "descriere_lunga_si_detaliata_task": "Este o practică standard pentru rădăcina unui monorepo să fie setată ca 'private: true'. Acest lucru previne publicarea accidentală a pachetului rădăcină în registrul npm. De asemenea, activează anumite funcționalități ale managerilor de pachete pentru workspaces.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.2: 'package.json' a fost creat.",
      "contextul_general_al_aplicatiei": "Securizarea monorepo-ului împotriva publicării accidentale.",
      "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/package.json'.",
      "restrictii_anti_halucinatie":,
      "restrictii_de_iesire_din_contex": "Nu modifica alte chei în 'package.json'.",
      "validare": "Conținutul 'package.json' include '\"private\": true'.",
      "outcome": "'package.json' este marcat ca privat.",
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.1.4  
{
    "F0.1.4": {
      "denumire_task": "Creare Fișier 'pnpm-workspace.yaml'",
      "descriere_scurta_task": "Crearea fișierului 'pnpm-workspace.yaml' pentru a defini pachetele din monorepo.",
      "descriere_lunga_si_detaliata_task": "Acesta este fișierul central de configurare pentru 'pnpm workspaces'.[15, 16, 17] Prin crearea acestui fișier, îi spunem lui 'pnpm' că acesta este un monorepo și unde să caute pachetele (sub-proiectele).",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.2: 'package.json' de rădăcină există.",
      "contextul_general_al_aplicatiei": "Definirea formală a structurii monorepo-ului pentru 'pnpm'.",
      "contextualizarea_directoarelor_si_cailor": "Creează fișierul '/var/www/GeniusSuite/pnpm-workspace.yaml'.",
      "restrictii_anti_halucinatie":,
      "restrictii_de_iesire_din_contex": "Nu adăuga conținut în fișier. Acest lucru se va face în task-ul următor.",
      "validare": "Verifică existența fișierului '/var/www/GeniusSuite/pnpm-workspace.yaml'.",
      "outcome": "Fișierul 'pnpm-workspace.yaml' este creat.",
      "componenta_de_CI_DI": "Acest fișier este esențial pentru CI pentru a înțelege cum să instaleze dependențele (pnpm install)."
    }
  },
F0.1.5 
 {
    "F0.1.5": {
      "denumire_task": "Populare 'pnpm-workspace.yaml' (Critic)",
      "descriere_scurta_task": "Adăugarea căilor (glob patterns) în 'pnpm-workspace.yaml' conform structurii.",
      "descriere_lunga_si_detaliata_task": "Acest task definește 'inima' monorepo-ului. Bazat pe structura de directoare din  (Capitolul 1.5), trebuie să specificăm toate căile unde 'pnpm' și 'Nx' vor găsi proiecte (aplicații și biblioteci). Acest lucru include 'shared/', 'cp/', aplicațiile '.app' și directoarele de suport.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.4: Fișierul 'pnpm-workspace.yaml' există.",
      "contextul_general_al_aplicatiei": "Alinierea definiției workspace-ului pnpm cu arhitectura.",
      "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/pnpm-workspace.yaml'.",
      "restrictii_anti_halucinatie":,
      "restrictii_de_iesire_din_contex": "Nu folosi ghilimele duble în YAML. Folosește ghilimele simple. Nu inventa alte căi.",
      "validare": "Conținutul 'pnpm-workspace.yaml' corespunde exact specificației de mai sus.",
      "outcome": "pnpm este acum conștient de structura completă a monorepo-ului.",
      "componenta_de_CI_DI": "Acest fișier dictează modul în care 'pnpm install' descoperă și leagă pachetele locale."
    }
  },
F0.1.6 
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
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.1.7 
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
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.1.8 
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
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.1.9 
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
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.1.10 
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
      "componenta_de_CI_DI": "Acest fișier este fundamental pentru a preveni cache-ul CI să fie poluat cu fișiere irelevante."
    }
  },
F0.1.11 
 {
    "F0.1.11": {
      "denumire_task": "Instalare 'nx' ca Dependență Rădăcină",
      "descriere_scurta_task": "Adăugarea pachetului 'nx' ca dependență de dezvoltare (dev dependency) la rădăcina workspace-ului.",
      "descriere_lunga_si_detaliata_task": "Instalăm 'nx' [18], managerul de monorepo și task runner, la nivelul rădăcinii. Folosim 'pnpm add nx -D -w'. Flag-ul '-D' îl salvează ca devDependency. Flag-ul '-w' (sau '--workspace-root') este specific 'pnpm' și indică faptul că pachetul trebuie instalat în 'package.json' de la rădăcină, nu într-un sub-pachet.[15]",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.2: 'package.json' este configurat. F0.1.5: 'pnpm-workspace.yaml' este configurat.",
      "contextul_general_al_aplicatiei": "Nx este instrumentul central [1, 18] ales pentru gestionarea dependențelor, rularea task-urilor, caching și orchestrarea generală a monorepo-ului GeniusSuite.",
      "contextualizarea_directoarelor_si_cailor": "Comanda se execută în '/var/www/GeniusSuite/'. Va modifica 'package.json' și va crea 'node_modules' (și/sau '.pnpm-store').",
      "restrictii_anti_halucinatie":"
      ],
      "restrictii_de_iesire_din_contex": "Nu rula încă 'nx init' sau alte comenzi 'nx'. Doar instalează pachetul.",
      "validare": "Verifică 'package.json' pentru a vedea 'nx' listat în 'devDependencies'. Verifică existența directorului 'node_modules'.",
      "outcome": "Pachetul 'nx' este instalat la rădăcina monorepo-ului.",
      "componenta_de_CI_DI": "Acest pas este echivalentul 'pnpm install' din CI. Adaugă prima dependență majoră."
    }
  },
F0.1.12 
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
      "componenta_de_CI_DI": "Crearea 'nx.json' este fundamentală. CI va folosi 'nx' pentru a rula task-uri afectate (affected tasks)."
    }
  },
F0.1.13
  {
    "F0.1.13": {
      "denumire_task": "Configurare 'nx.json' (Partea 1 - Target Defaults)",
      "descriere_scurta_task": "Editarea 'nx.json' pentru a stabili 'targetDefaults' pentru operațiuni cacheabile.",
      "descriere_lunga_si_detaliata_task": "Modificăm 'nx.json' pentru a defini 'targetDefaults'. Aceasta este o practică recomandată Nx [2] pentru a seta implicit ce task-uri (cum ar fi 'build', 'lint', 'test') sunt cacheabile, fără a trebui să o specificăm în fiecare proiect. De asemenea, definim 'outputs' implicite, cum ar fi 'dist' sau 'coverage'.[2]",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.12: 'nx.json' a fost creat de 'nx init'.",
      "contextul_general_al_aplicatiei": "Definirea strategiilor de caching la rădăcină este cheia pentru un monorepo rapid.[18, 22]",
      "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/nx.json'.",
      "restrictii_anti_halucinatie":",
        "  },",
        "  \"lint\": {",
        "    \"cache\": true",
        "  },",
        "  \"test\": {",
        "    \"cache\": true,",
        "    \"outputs\":",
        "  }",
        "}"
      ],
      "restrictii_de_iesire_din_contex": "Nu adăuga încă proiecte ('projects: {}'). Nx le va descoperi automat (Inferred Tasks).[2]",
      "validare": "Conținutul 'nx.json' include cheia 'targetDefaults' cu configurațiile specificate.",
      "outcome": "'nx.json' este configurat cu valori implicite pentru caching-ul task-urilor comune.",
      "componenta_de_CI_DI": "Această configurație activează Nx Remote Cache (Nx Cloud sau similar), reducând drastic timpii de CI.[22]"
    }
  },
F0.1.14
  {
    "F0.1.14": {
      "denumire_task": "Configurare 'nx.json' (Partea 2 - Package Manager)",
      "descriere_scurta_task": "Asigurarea că 'nx.json' este setat explicit să folosească 'pnpm'.",
      "descriere_lunga_si_detaliata_task": "Deși 'nx init' ar fi trebuit să detecteze 'pnpm' [15, 21], vom verifica și vom seta explicit 'packageManager: \"pnpm\"' în 'nx.json'. Acest lucru asigură că Nx nu va încerca niciodată să folosească 'npm' sau 'yarn' pentru operațiunile de instalare.[3]",
      "directorul_directoarele":,
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
      "componenta_de_CI_DI": "Previne erorile de CI în care agentul ar putea încerca să folosească 'npm install' din greșeală."
    }
  },
F0.1.15
  {
    "F0.1.15": {
      "denumire_task": "Instalare Dependențe TypeScript de Bază",
      "descriere_scurta_task": "Instalarea 'typescript' la rădăcina workspace-ului.",
      "descriere_lunga_si_detaliata_task": "Instalăm pachetul fundamental 'typescript' la nivelul rădăcinii monorepo-ului, folosind 'pnpm add'. Acesta va fi folosit de toate proiectele, de ESLint și de 'nx' însuși. Stiva  specifică 'latest' TS.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.11: 'nx' este instalat.",
      "contextul_general_al_aplicatiei": "Stabilirea fundației TypeScript  pentru întregul monorepo.",
      "contextualizarea_directoarelor_si_cailor": "Comanda se execută în '/var/www/GeniusSuite/'.",
      "restrictii_anti_halucinatie":,
      "restrictii_de_iesire_din_contex": "Nu instala 'ts-node' sau '@types/node' încă. Le vom instala separat pentru a fi atomici.",
      "validare": "Verifică 'package.json' pentru a vedea 'typescript' în 'devDependencies'.",
      "outcome": "TypeScript este instalat.",
      "componenta_de_CI_DI": "Acest pachet va fi necesar pentru toți pașii de 'build' și 'lint' din CI."
    }
  },
F0.1.16
  {
    "F0.1.16": {
      "denumire_task": "Instalare Dependențe 'ts-node' și Tipuri Node",
      "descriere_scurta_task": "Instalarea 'ts-node' și '@types/node' la rădăcina workspace-ului.",
      "descriere_lunga_si_detaliata_task": "Instalăm 'ts-node' (pentru rularea script-urilor TS direct) și '@types/node'.",
      "Directorul_directoarele":[“verificam versiunea existenta in sistem si actualizam la versiunea stakului”],
      "contextul_taskurilor_anterioare": "F0.1.15: 'typescript' este instalat.",
      "contextul_general_al_aplicatiei": "Asigurarea suportului pentru rularea script-urilor TypeScript și a tipurilor corecte pentru mediul Node.js 24 LTS.",
      "contextualizarea_directoarelor_si_cailor": "Comanda se execută în '/var/www/GeniusSuite/'.",
      "restrictii_anti_halucinatie":,
      "restrictii_de_iesire_din_contex": "N/A",
      "validare": "Verifică 'package.json' pentru 'ts-node' și '@types/node' în 'devDependencies'.",
      "outcome": "Dependențele de suport TypeScript sunt instalate.",
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.1.17
  {
    "F0.1.17": {
      "denumire_task": "Creare 'tsconfig.base.json' la Rădăcină",
      "descriere_scurta_task": "Crearea fișierului de configurare TypeScript de bază, 'tsconfig.base.json'.",
      "descriere_lunga_si_detaliata_task": "Acesta este fișierul de configurare TypeScript central.[2, 4, 9] Toate celelalte fișiere 'tsconfig.json' din monorepo (din aplicații și biblioteci) vor extinde acest fișier de bază. Vom seta opțiunile 'compilerOptions' stricte, conform cerințelor.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.15: TypeScript este instalat.",
      "contextul_general_al_aplicatiei": "Impunerea unui standard TypeScript strict și centralizat pentru toate proiectele din GeniusSuite.",
      "contextualizarea_directoarelor_si_cailor": "Creează fișierul '/var/www/GeniusSuite/tsconfig.base.json'.",
      "restrictii_anti_halucinatie":",
        "Conținutul inițial trebuie să fie un JSON valid: \n{\n  \"compilerOptions\": {},\n  \"exclude\": [\"node_modules\", \"tmp\"]\n}"
      ],
      "restrictii_de_iesire_din_contex": "Nu popula încă 'compilerOptions' sau 'paths'. Acestea vor fi făcute în task-urile următoare.",
      "validare": "Verifică existența fișierului '/var/www/GeniusSuite/tsconfig.base.json'.",
      "outcome": "Fișierul 'tsconfig.base.json' este creat.",
      "componenta_de_CI_DI": "CI va folosi acest fișier ca bază pentru 'typecheck' și 'build'."
    }
  },
F0.1.18
  {
    "F0.1.18": {
      "denumire_task": "Configurare 'compilerOptions' Stricte în 'tsconfig.base.json'",
      "descriere_scurta_task": "Setarea regulilor stricte de compilare TypeScript în 'tsconfig.base.json'.",
      "descriere_lunga_si_detaliata_task": "Configurăm 'compilerOptions' în 'tsconfig.base.json' pentru a impune standarde de cod stricte, conform cerințelor  (Convenții generale: \"Strict TS\"). Aceasta include 'strict: true', 'noUncheckedIndexedAccess', 'exactOptionalPropertyTypes', și opțiuni moderne pentru compatibilitatea cu Node 24 (ESNext) și React 19 (JSX).",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.17: 'tsconfig.base.json' a fost creat.",
      "contextul_general_al_aplicatiei": "Standardizarea calității codului și prevenirea erorilor comune în întregul monorepo.",
      "contextualizarea_directoarelor_si_cailor": "Modifică '/var/www/GeniusSuite/tsconfig.base.json'.",
      "restrictii_anti_halucinatie": [1],",
        "  \"skipLibCheck\": true,",
        "  \"allowJs\": true,",
        "  \"esModuleInterop\": true,",
        "  \"allowSyntheticDefaultImports\": true,",
        "  \"forceConsistentCasingInFileNames\": true,",
        "  \"isolatedModules\": true,",
        "  \"noEmit\": true,",
        "  \"jsx\": \"react-jsx\",",
        "",
        "  \"strict\": true,",
        "  \"noUncheckedIndexedAccess\": true,",
        "  \"exactOptionalPropertyTypes\": true,",
        "  \"noImplicitAny\": true,",
        "  \"strictNullChecks\": true,",
        "  \"strictFunctionTypes\": true,",
        "  \"strictBindCallApply\": true,",
        "  \"strictPropertyInitialization\": true,",
        "  \"noImplicitThis\": true,",
        "  \"alwaysStrict\": true,",
        "  \"noUnusedLocals\": true,",
        "  \"noUnusedParameters\": true,",
        "  \"noImplicitReturns\": true,",
        "  \"noFallthroughCasesInSwitch\": true,",
        "",
        "  \"resolveJsonModule\": true,",
        "  \"composite\": false,",
        "  \"declaration\": true,",
        "  \"sourceMap\": true,",
        "  \"baseUrl\": \".\",",
        "  \"incremental\": true",
        "}"
      ],
      "restrictii_de_iesire_din_contex": "Nu adăuga încă 'paths'. Acesta este un task separat și critic.",
      "validare": "'tsconfig.base.json' conține 'compilerOptions' cu 'strict: true' și celelalte setări.",
      "outcome": "Configurația de bază TypeScript este stabilită la un standard înalt de calitate.",
      "componenta_de_CI_DI": "Toate job-urile 'typecheck' vor moșteni aceste reguli stricte."
    }
  },
F0.1.19
  {
    "F0.1.19": {
      "denumire_task": "Configurare 'paths' (Alias-uri) în 'tsconfig.base.json' (Critic)",
      "descriere_scurta_task": "Definirea alias-urilor de import TypeScript în 'paths' pentru toate bibliotecile din 'shared/'.",
      "descriere_lunga_si_detaliata_task": "Acesta este un pas vital pentru arhitectura monorepo-ului.[4, 9] Definind 'paths', permitem importuri curate (de ex. '@genius-suite/ui-design-system') în loc de căi relative (de ex. '../../shared/ui-design-system'). Mapăm *fiecare* pachet definit în , Capitolul 2, în directorul 'shared/'. Vom folosi convenția 'workspace:' de la pnpm în 'package.json'-urile viitoare [16], dar alias-urile TS sunt necesare pentru IDE și type-checking.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.18: 'compilerOptions' sunt setate. 'baseUrl' este \".\".",
      "contextul_general_al_aplicatiei": "Crearea 'lipiciului' (glue) între bibliotecile partajate  și viitoarele aplicații consumatoare (cp/, vettify.app/, etc.).",
      "contextualizarea_directoarelor_si_cailor": "Modifică 'compilerOptions.paths' în '/var/www/GeniusSuite/tsconfig.base.json'.",
      "restrictii_anti_halucinatie":'.",
        "Căile trebuie să pointeze către sursa TypeScript (de ex. 'index.ts' sau 'src/index.ts'). Vom folosi 'index.ts' ca în [1] (Capitolul 2).",
        "Adaugă următoarele 'paths' [1]:",
        "\"paths\": {",
        "  \"@genius-suite/ui-design-system\": [\"shared/ui-design-system/index.ts\"],",
        "  \"@genius-suite/feature-flags\": [\"shared/feature-flags/index.ts\"],",
        "  \"@genius-suite/auth-client\": [\"shared/auth-client/index.ts\"],",
        "  \"@genius-suite/types\": [\"shared/types/index.ts\"],",
        "  \"@genius-suite/common\": [\"shared/common/index.ts\"],",
        "  \"@genius-suite/integrations\": [\"shared/integrations/index.ts\"],",
        "  \"@genius-suite/observability\": [\"shared/observability/index.ts\"]",
        "}",
        "Dacă fișierul principal de export este 'src/index.ts', ajustează calea (de ex. 'shared/ui-design-system/src/index.ts')."
      ],
      "restrictii_de_iesire_din_contex": "Nu rula 'nx sync' sau alte comenzi. Doar scrie configurația.",
      "validare": "'tsconfig.base.json' conține 'compilerOptions.paths' cu toate cele 7 alias-uri definite corect.",
      "outcome": "Alias-urile de import pentru bibliotecile partajate sunt configurate, permițând importuri de pachete curate.",
      "componenta_de_CI_DI": "CI va trebui să respecte aceste mapări de căi în timpul 'build'-urilor."
    }
  },
F0.1.20
  {
    "F0.1.20": {
      "denumire_task": "Instalare Prettier",
      "descriere_scurta_task": "Instalarea 'prettier' ca dependență de dezvoltare la rădăcină.",
      "descriere_lunga_si_detaliata_task": "Instalăm 'prettier' [8, 23], instrumentul standard pentru formatarea codului. Acesta va fi folosit pentru a impune un stil de cod consistent în întregul monorepo.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.11: Dependențele de bază sunt instalate.",
      "contextul_general_al_aplicatiei": "Standardizarea stilului de cod  este crucială pentru mentenabilitatea monorepo-ului.",
      "contextualizarea_directoarelor_si_cailor": "Comanda se execută în '/var/www/GeniusSuite/'.",
      "restrictii_anti_halucinatie":,
      "restrictii_de_iesire_din_contex": "Nu instala plugin-uri 'prettier' sau 'eslint' încă.",
      "validare": "Verifică 'package.json' pentru a vedea 'prettier' în 'devDependencies'.",
      "outcome": "'prettier' este instalat.",
      "componenta_de_CI_DI": "CI va rula 'prettier --check' (sau 'nx format:check') pentru a valida formatarea."
    }
  },
F0.1.21
  {
    "F0.1.21": {
      "denumire_task": "Creare Fișier Configurare '.prettierrc'",
      "descriere_scurta_task": "Crearea fișierului de configurare '.prettierrc' cu regulile de formatare.",
      "descriere_lunga_si_detaliata_task": "Creăm fișierul '.prettierrc' la rădăcină.[10] Acesta va conține regulile specifice de formatare (de ex. 'singleQuote', 'tabWidth') pe care le vom impune în tot codul (TS, JS, JSON, CSS, MD).",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.20: 'prettier' este instalat.",
      "contextul_general_al_aplicatiei": "Definirea standardului de formatare a codului.",
      "contextualizarea_directoarelor_si_cailor": "Creează fișierul '/var/www/GeniusSuite/.prettierrc'.",
      "restrictii_anti_halucinatie":,
      "restrictii_de_iesire_din_contex": "Nu crea '.prettierignore' încă. Acesta este un task separat.",
      "validare": "Verifică existența și conținutul JSON valid al fișierului '/var/www/GeniusSuite/.prettierrc'.",
      "outcome": "Regulile de formatare Prettier sunt definite centralizat.",
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.1.22
  {
    "F0.1.22": {
      "denumire_task": "Creare Fișier '.prettierignore'",
      "descriere_scurta_task": "Crearea fișierului '.prettierignore' pentru a exclude fișierele de la formatare.",
      "descriere_lunga_si_detaliata_task": "Similar cu '.gitignore', '.prettierignore' [23] spune lui Prettier ce fișiere și directoare să ignore. Acest lucru este important pentru a preveni formatarea fișierelor generate, a artefactelor de build sau a cache-urilor.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.21: '.prettierrc' este creat. F0.1.10: '.gitignore' există.",
      "contextul_general_al_aplicatiei": "Optimizarea execuției 'prettier' și prevenirea formatării fișierelor sensibile.",
      "contextualizarea_directoarelor_si_cailor": "Creează fișierul '/var/www/GeniusSuite/.prettierignore'.",
      "restrictii_anti_halucinatie": [
        "Conținutul fișierului '.prettierignore' trebuie să includă conținutul din '.gitignore' și 'pnpm-lock.yaml'.",
        "# Copiază conținutul din.gitignore",
        "node_modules",
        ".pnpm-store",
        "dist",
        "build",
        "coverage",
        ".nx/cache",
        "*.log",
        "",
        "# Fișiere specifice",
        "package-lock.json",
        "pnpm-lock.yaml",
        "",
        "# Fișiere generate (viitor)",
        "shared/ui-design-system/icons/react/generated/"
      ],
      "restrictii_de_iesire_din_contex": "N/A",
      "validare": "Verifică existența fișierului '/var/www/GeniusSuite/.prettierignore'.",
      "outcome": "Prettier este configurat să ignore fișierele și directoarele care nu necesită formatare.",
      "componenta_de_CI_DI": "Accelerează pasul 'format:check' din CI prin excluderea căilor irelevante."
    }
  },
F0.1.23
  {
    "F0.1.23": {
      "denumire_task": "Instalare ESLint Core",
      "descriere_scurta_task": "Instalarea pachetului 'eslint'.",
      "descriere_lunga_si_detaliata_task": "Instalăm pachetul de bază pentru linting, 'eslint'.[5] Acesta este motorul care va rula regulile de linting.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.15: TypeScript este instalat.",
      "contextul_general_al_aplicatiei": "Stabilirea fundației pentru impunerea regulilor de calitate a codului (linting).",
      "contextualizarea_directoarelor_si_cailor": "Comanda se execută în '/var/www/GeniusSuite/'.",
      "restrictii_anti_halucinatie":,
      "restrictii_de_iesire_din_contex": "Nu instala încă plugin-uri TS sau Nx.",
      "validare": "Verifică 'package.json' pentru 'eslint' în 'devDependencies'.",
      "outcome": "Motorul ESLint este instalat.",
      "componenta_de_CI_DI": "Acest pachet este necesar pentru pasul 'lint' din CI."
    }
  },
F0.1.24
  {
    "F0.1.24": {
      "denumire_task": "Instalare Dependențe ESLint (TypeScript Parser)",
      "descriere_scurta_task": "Instalarea '@typescript-eslint/parser'.",
      "descriere_lunga_si_detaliata_task": "Instalăm parser-ul care permite ESLint să înțeleagă sintaxa TypeScript.[6] Fără acesta, ESLint ar trata codul TS ca JavaScript invalid.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.23: 'eslint' este instalat.",
      "contextul_general_al_aplicatiei": "Extinderea ESLint pentru a suporta TypeScript.",
      "contextualizarea_directoarelor_si_cailor": "Comanda se execută în '/var/www/GeniusSuite/'.",
      "restrictii_anti_halucinatie":,
      "restrictii_de_iesire_din_contex": "N/A",
      "validare": "Verifică 'package.json' pentru '@typescript-eslint/parser'.",
      "outcome": "Parser-ul TypeScript pentru ESLint este instalat.",
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.1.25
  {
    "F0.1.25": {
      "denumire_task": "Instalare Dependențe ESLint (TypeScript Plugin)",
      "descriere_scurta_task": "Instalarea '@typescript-eslint/eslint-plugin'.",
      "descriere_lunga_si_detaliata_task": "Instalăm setul de reguli specifice TypeScript pentru ESLint [6], cum ar fi 'no-unused-vars' conștient de tipuri, reguli pentru 'await', etc.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.23: 'eslint' este instalat.",
      "contextul_general_al_aplicatiei": "Extinderea ESLint pentru a suporta reguli specifice TypeScript.",
      "contextualizarea_directoarelor_si_cailor": "Comanda se execută în '/var/www/GeniusSuite/'.",
      "restrictii_anti_halucinatie":,
      "restrictii_de_iesire_din_contex": "N/A",
      "validare": "Verifică 'package.json' pentru '@typescript-eslint/eslint-plugin'.",
      "outcome": "Plugin-ul TypeScript pentru ESLint este instalat.",
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.1.26
  {
    "F0.1.26": {
      "denumire_task": "Instalare Dependențe ESLint (Plugin-ul Nx)",
      "descriere_scurta_task": "Instalarea '@nx/eslint-plugin'.",
      "descriere_lunga_si_detaliata_task": "Instalăm plugin-ul ESLint specific pentru Nx, '@nx/eslint-plugin'.[5] Acest plugin oferă reguli specifice pentru monorepo-uri Nx, cum ar fi impunerea granițelor dintre module (module boundaries) și detectarea corectă a proiectelor.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.23: 'eslint' este instalat. F0.1.11: 'nx' este instalat.",
      "contextul_general_al_aplicatiei": "Integrarea strânsă a ESLint cu capabilitățile Nx.[5]",
      "contextualizarea_directoarelor_si_cailor": "Comanda se execută în '/var/www/GeniusSuite/'.",
      "restrictii_anti_halucinatie":"
      ],
      "restrictii_de_iesire_din_contex": "N/A",
      "validare": "Verifică 'package.json' pentru '@nx/eslint-plugin' în 'devDependencies'.",
      "outcome": "Plugin-ul ESLint specific Nx este instalat.",
      "componenta_de_CI_DI": "Regulile acestui plugin (de ex. module boundaries) sunt una dintre cele mai importante validări din CI."
    }
  },
F0.1.27
  {
    "F0.1.27": {
      "denumire_task": "Creare Fișier Rădăcină '.eslintrc.json'",
      "descriere_scurta_task": "Crearea fișierului de configurare central '.eslintrc.json' la rădăcină.",
      "descriere_lunga_si_detaliata_task": "Creăm fișierul '.eslintrc.json' la rădăcină.[5, 24] Acesta va fi fișierul de bază pe care toate proiectele din monorepo îl vor extinde. Setăm 'root: true' pentru a opri ESLint să caute configurații în directoarele părinte.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.23 - F0.1.26: Pachetele ESLint sunt instalate.",
      "contextul_general_al_aplicatiei": "Centralizarea configurației de linting.",
      "contextualizarea_directoarelor_si_cailor": "Creează fișierul '/var/www/GeniusSuite/.eslintrc.json'.",
      "restrictii_anti_halucinatie":,",
        "  \"plugins\":,",
        "  \"overrides\":",
        "}",
        "Folosind 'ignorePatterns': ['**/*'] este o practică modernă Nx [7] pentru a forța configurația să se bazeze pe 'overrides' specifice, în loc de a lint-ui totul implicit."
      ],
      "restrictii_de_iesire_din_contex": "Nu adăuga reguli sau 'extends' încă.",
      "validare": "Verifică existența fișierului '/var/www/GeniusSuite/.eslintrc.json'.",
      "outcome": "Fișierul '.eslintrc.json' de bază este creat.",
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.1.28
  {
    "F0.1.28": {
      "denumire_task": "Configurare 'nx.json' (Partea 3 - Plugin ESLint)",
      "descriere_scurta_task": "Adăugarea plugin-ului ESLint în 'nx.json'.",
      "descriere_lunga_si_detaliata_task": "Acum că ESLint este instalat, putem activa plugin-ul Nx pentru ESLint în 'nx.json'. Acest lucru permite Nx să infera automat task-uri 'lint' pentru proiectele care au fișiere '.eslintrc.json'.[5]",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.26: Plugin-ul '@nx/eslint-plugin' este instalat. F0.1.14: 'nx.json' există.",
      "contextul_general_al_aplicatiei": "Integrarea 'Inferred Tasks' (Project Crystal) [5] de la Nx pentru ESLint.",
      "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/nx.json'.",
      "restrictii_anti_halucinatie":"
      ],
      "restrictii_de_iesire_din_contex": "Nu adăuga alte plugin-uri în acest task.",
      "validare": "Verifică 'nx.json' pentru a vedea 'plugins' configurat corect pentru ESLint.",
      "outcome": "Nx este acum configurat să descopere și să ruleze task-uri de linting.",
      "componenta_de_CI_DI": "Acest pas permite CI să ruleze 'nx affected:lint' în loc să ghicească ce proiecte trebuie lint-uite."
    }
  },
F0.1.29
  {
    "F0.1.29": {
      "denumire_task": "Configurare '.eslintrc.json' (Integrare Nx și TS)",
      "descriere_scurta_task": "Configurarea 'plugins', 'parser' și 'extends' în '.eslintrc.json' de la rădăcină.",
      "descriere_lunga_si_detaliata_task": "Configurăm fișierul '.eslintrc.json' de la rădăcină pentru a folosi parser-ul TypeScript, plugin-ul Nx și seturile de reguli recomandate. Acest 'override' se va aplica tuturor fișierelor.ts și.tsx din monorepo.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.27: '.eslintrc.json' există. F0.1.23-F0.1.26: Plugin-urile sunt instalate.",
      "contextul_general_al_aplicatiei": "Activarea linting-ului bazat pe TypeScript și Nx.",
      "contextualizarea_directoarelor_si_cailor": "Modifică '/var/www/GeniusSuite/.eslintrc.json'.",
      "restrictii_anti_halucinatie": [
        "Modifică fișierul '.eslintrc.json' pentru a arăta astfel:",
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
        "        \"@nx/enforce-module-boundaries\":,",
        "            \"depConstraints\": }",
        "            ]",
        "          }",
        "        ]",
        "      }",
        "    }",
        "  ]",
        "}",
        "Este *critic* să *nu* adaugi 'parserOptions.project' aici.[6] Acest lucru se va face la nivel de proiect."
      ],
      "restrictii_de_iesire_din_contex": "Nu adăuga încă reguli Prettier.",
      "validare": "Verifică conținutul '.eslintrc.json' pentru a corespunde structurii.",
      "outcome": "ESLint este configurat pentru a înțelege TypeScript și a aplica regulile de bază Nx.",
      "componenta_de_CI_DI": "Activează regula 'enforce-module-boundaries' care va fi verificată în CI."
    }
  },
F0.1.30
  {
    "F0.1.30": {
      "denumire_task": "Instalare Dependențe ESLint (Integrare Prettier Config)",
      "descriere_scurta_task": "Instalarea 'eslint-config-prettier'.",
      "descriere_lunga_si_detaliata_task": "Instalăm 'eslint-config-prettier'.[11] Acest pachet este crucial: dezactivează toate regulile ESLint care sunt în conflict cu regulile de formatare Prettier.[6] Fără acesta, am avea erori contradictorii.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.20: Prettier este instalat. F0.1.23: ESLint este instalat.",
      "contextul_general_al_aplicatiei": "Reconcilierea conflictelor dintre linter și formatter.",
      "contextualizarea_directoarelor_si_cailor": "Comanda se execută în '/var/www/GeniusSuite/'.",
      "restrictii_anti_halucinatie":,
      "restrictii_de_iesire_din_contex": "Nu instala 'eslint-plugin-prettier' încă.",
      "validare": "Verifică 'package.json' pentru 'eslint-config-prettier'.",
      "outcome": "Pachetul de configurare pentru dezactivarea conflictelor ESLint este instalat.",
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.1.31
  {
    "F0.1.31": {
      "denumire_task": "Instalare Dependențe ESLint (Integrare Prettier Plugin)",
      "descriere_scurta_task": "Instalarea 'eslint-plugin-prettier'.",
      "descriere_lunga_si_detaliata_task": "Instalăm 'eslint-plugin-prettier'.[11, 25] Acest pachet face ceva diferit: rulează Prettier ca o regulă ESLint și raportează diferențele de formatare ca probleme ESLint. Acest lucru ne permite să vedem erorile de formatare direct în linter.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.20: Prettier este instalat. F0.1.23: ESLint este instalat.",
      "contextul_general_al_aplicatiei": "Integrarea Prettier în fluxul de lucru ESLint.",
      "contextualizarea_directoarelor_si_cailor": "Comanda se execută în '/var/www/GeniusSuite/'.",
      "restrictii_anti_halucinatie":,
      "restrictii_de_iesire_din_contex": "N/A",
      "validare": "Verifică 'package.json' pentru 'eslint-plugin-prettier'.",
      "outcome": "Pachetul de plugin pentru rularea Prettier ca regulă ESLint este instalat.",
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.1.32
  {
    "F0.1.32": {
      "denumire_task": "Configurare '.eslintrc.json' (Integrare Prettier)",
      "descriere_scurta_task": "Adăugarea 'prettier' la 'extends' și 'plugins' în '.eslintrc.json'.",
      "descriere_lunga_si_detaliata_task": "Finalizăm integrarea ESLint-Prettier. Adăugăm 'plugin:prettier/recommended' la 'extends'. Acest lucru activează 'eslint-plugin-prettier' și 'eslint-config-prettier' simultan. Este crucial ca 'prettier' (sau 'plugin:prettier/recommended') să fie *ultima* intrare în array-ul 'extends' pentru a suprascrie corect regulile anterioare.[11]",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.29: '.eslintrc.json' este configurat. F0.1.30, F0.1.31: Pachetele Prettier ESLint sunt instalate.",
      "contextul_general_al_aplicatiei": "O singură sursă de adevăr pentru problemele de cod (ESLint) care include și formatarea.",
      "contextualizarea_directoarelor_si_cailor": "Modifică '/var/www/GeniusSuite/.eslintrc.json'.",
      "restrictii_anti_halucinatie": [
        "Modifică secțiunea 'overrides' pentru 'files: [\"*.ts\", \"*.tsx\", \"*.js\", \"*.jsx\"]'.",
        "Adaugă 'plugin:prettier/recommended' ca *ultima* intrare în array-ul 'extends'.",
        "Fragmentul 'extends' ar trebui să arate acum astfel:",
        "\"extends\": [",
        "  \"plugin:@nx/typescript\",",
        "  \"plugin:@typescript-eslint/recommended\",",
        "  \"plugin:prettier/recommended\"",
        "]",
        "Adaugă 'prettier' la array-ul 'plugins' de la rădăcină (deși 'recommended' o face implicit, este o bună practică).",
        "\"plugins\": [\"@nx\", \"prettier\"],",
        "Adaugă regula 'prettier/prettier': 'error' în 'rules' (din nou, 'recommended' o face, dar explicităm):",
        "\"rules\": {",
        "  \"prettier/prettier\": \"error\",",
        "  \"@nx/enforce-module-boundaries\": [... ]",
        "}"
      ],
      "restrictii_de_iesire_din_contex": "N/A",
      "validare": "Verifică că 'plugin:prettier/recommended' este ultima intrare în 'extends' în 'overrides'.",
      "outcome": "ESLint și Prettier sunt complet integrate. 'eslint --fix' va rula acum și Prettier.",
      "componenta_de_CI_DI": "Pasul 'lint' din CI va eșua acum și pe erori de formatare, nu doar de sintaxă."
    }
  },
F0.1.33
  {
    "F0.1.33": {
      "denumire_task": "Creare Fișier '.eslintignore'",
      "descriere_scurta_task": "Crearea fișierului '.eslintignore' pentru a exclude fișierele de la linting.",
      "descriere_lunga_si_detaliata_task": "Similar cu '.prettierignore', '.eslintignore' [26] spune lui ESLint ce fișiere și directoare să ignore. Acest lucru este important pentru a preveni linting-ul fișierelor generate, a artefactelor de build sau a cache-urilor. Deși 'ignorePatterns' din '.eslintrc.json' este modern, un '.eslintignore' este încă o practică bună pentru compatibilitatea cu uneltele.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.32: ESLint este complet configurat.",
      "contextul_general_al_aplicatiei": "Optimizarea execuției 'eslint' și prevenirea erorilor din fișierele non-sursă.",
      "contextualizarea_directoarelor_si_cailor": "Creează fișierul '/var/www/GeniusSuite/.eslintignore'.",
      "restrictii_anti_halucinatie": [
        "Conținutul fișierului '.eslintignore' trebuie să fie similar cu '.prettierignore':",
        "node_modules",
        "dist",
        "build",
        "coverage",
        ".nx/cache",
        "pnpm-lock.yaml",
        "*.md",
        "*.json",
        "!.eslintrc.json"
      ],
      "restrictii_de_iesire_din_contex": "N/A",
      "validare": "Verifică existența fișierului '/var/www/GeniusSuite/.eslintignore'.",
      "outcome": "ESLint este configurat să ignore fișierele și directoarele care nu necesită linting.",
      "componenta_de_CI_DI": "Accelerează pasul 'lint' din CI."
    }
  },
F0.1.34
  {
    "F0.1.34": {
      "denumire_task": "Instalare 'husky'",
      "descriere_scurta_task": "Instalarea 'husky' pentru gestionarea cârligelor Git (git hooks).",
      "descriere_lunga_si_detaliata_task": "Instalăm 'husky' [27], un instrument care facilitează gestionarea și rularea script-urilor la diferite evenimente Git (de ex. 'pre-commit', 'commit-msg'). Vom folosi 'pnpm' pentru a-l instala.[14, 27]",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.1 - F0.1.33: Fundația de tooling (pnpm, nx, eslint, prettier) este gata.",
      "contextul_general_al_aplicatiei": "Impunerea standardelor de cod (lint, format, commit message) *înainte* ca codul să ajungă pe serverul de CI.",
      "contextualizarea_directoarelor_si_cailor": "Comanda se execută în '/var/www/GeniusSuite/'.",
      "restrictii_anti_halucinatie":,
      "restrictii_de_iesire_din_contex": "Nu rula încă 'husky init'.",
      "validare": "Verifică 'package.json' pentru 'husky' în 'devDependencies'.",
      "outcome": "'husky' este instalat.",
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.1.35
  {
    "F0.1.35": {
      "denumire_task": "Inițializare 'husky' (v9+)",
      "descriere_scurta_task": "Rularea 'husky init' pentru a crea directorul '.husky' și a configura script-ul 'prepare'.",
      "descriere_lunga_si_detaliata_task": "Rulăm comanda 'husky init' specifică 'pnpm'.[27] Această comandă va: 1. Crea directorul '.husky/'. 2. Crea un exemplu de hook 'pre-commit'. 3. Adăuga un script 'prepare' în 'package.json' de la rădăcină. Script-ul 'prepare' rulează automat după 'pnpm install' și activează hook-urile Git, asigurând că orice dezvoltator care clonează repository-ul va avea hook-urile activate.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.34: 'husky' este instalat.",
      "contextul_general_al_aplicatiei": "Activarea automată a cârligelor Git pentru toți dezvoltatorii.",
      "contextualizarea_directoarelor_si_cailor": "Comanda se execută la rădăcină. Va crea '.husky/' și va modifica 'package.json'.",
      "restrictii_anti_halucinatie": [
        "Execută comanda: 'pnpm exec husky init'.[27]",
        "Nu folosi 'npx husky-init' (care este pentru npm). Folosește 'pnpm exec'.[14, 27]"
      ],
      "restrictii_de_iesire_din_contex": "Vom suprascrie hook-ul 'pre-commit' implicit în task-urile următoare.",
      "validare": "Verifică existența directorului '.husky/'. Verifică 'package.json' pentru script-ul 'prepare': '\"prepare\": \"husky\"'.",
      "outcome": "'husky' este inițializat și configurat să se activeze automat la 'pnpm install'.",
      "componenta_de_CI_DI": "CI-ul trebuie să ruleze 'pnpm install' (care va rula 'prepare') înainte de a executa teste, deși hook-urile în sine sunt de obicei ocolite în CI."
    }
  },
F0.1.36
  {
    "F0.1.36": {
      "denumire_task": "Instalare 'lint-staged'",
      "descriere_scurta_task": "Instalarea 'lint-staged' pentru a rula comenzi pe fișierele din 'staged'.",
      "descriere_lunga_si_detaliata_task": "Instalăm 'lint-staged'.[8] Acest instrument este esențial pentru hook-ul 'pre-commit'. Permite rularea comenzilor (cum ar fi linter-ul și formatter-ul) doar pe fișierele care sunt pe cale de a fi comisionate ('staged'), în loc de întregul proiect.[8]",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.35: 'husky' este inițializat.",
      "contextul_general_al_aplicatiei": "Optimizarea hook-ului 'pre-commit' pentru a fi extrem de rapid.",
      "contextualizarea_directoarelor_si_cailor": "Comanda se execută în '/var/www/GeniusSuite/'.",
      "restrictii_anti_halucinatie":,
      "restrictii_de_iesire_din_contex": "Nu configura încă 'lint-staged' sau hook-ul.",
      "validare": "Verifică 'package.json' pentru 'lint-staged' în 'devDependencies'.",
      "outcome": "'lint-staged' este instalat.",
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.1.37
  {
    "F0.1.37": {
      "denumire_task": "Configurare 'lint-staged' în '.lintstagedrc.json' (Critic)",
      "descriere_scurta_task": "Crearea fișierului '.lintstagedrc.json' cu comenzi Nx (format și lint).",
      "descriere_lunga_si_detaliata_task": "Creăm configurația pentru 'lint-staged'.[12] Acest fișier definește ce comenzi să ruleze pentru ce tipuri de fișiere. Este crucial să folosim comenzile Nx ('nx format:write' și 'nx affected:lint') în loc de 'prettier' sau 'eslint' direct, pentru a beneficia de caching-ul și graful de dependențe Nx.[8, 28]",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.36: 'lint-staged' este instalat. F0.1.32: ESLint/Prettier sunt configurate.",
      "contextul_general_al_aplicatiei": "Impunerea standardelor de cod într-un mod eficient, specific Nx, la momentul comiterii.",
      "contextualizarea_directoarelor_si_cailor": "Creează fișierul '/var/www/GeniusSuite/.lintstagedrc.json'.",
      "restrictii_anti_halucinatie":,",
        "  \"*.{ts,tsx,js,jsx}\": [",
        "    \"nx affected:lint --fix --files\"",
        "  ]",
        "}",
        "Folosește 'nx format:write --files' [29] și 'nx affected:lint --fix --files'.[12, 30]",
        "Nu folosi 'prettier --write' sau 'eslint --fix' direct."
      ],
      "restrictii_de_iesire_din_contex": "N/A",
      "validare": "Verifică existența și conținutul fișierului '.lintstagedrc.json'.",
      "outcome": "Configurația 'lint-staged' este creată pentru a rula formatarea și linting-ul specific Nx.",
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.1.38
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
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.1.39
  {
    "F0.1.39": {
      "denumire_task": "Instalare 'commitlint' (CLI)",
      "descriere_scurta_task": "Instalarea '@commitlint/cli'.",
      "descriere_lunga_si_detaliata_task": "Instalăm 'commitlint'.[13] Acest instrument verifică dacă mesajele de commit respectă un format standard.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.35: 'husky' este inițializat.",
      "contextul_general_al_aplicatiei": "Impunerea unui standard pentru mesajele de commit (Conventional Commits), care este vitală pentru generarea automată a changelog-urilor și versionarea semantică (F0.2).",
      "contextualizarea_directoarelor_si_cailor": "Comanda se execută în '/var/www/GeniusSuite/'.",
      "restrictii_anti_halucinatie":,
      "restrictii_de_iesire_din_contex": "Nu instala 'config-conventional' încă.",
      "validare": "Verifică 'package.json' pentru '@commitlint/cli'.",
      "outcome": "'commitlint' (CLI) este instalat.",
      "componenta_de_CI_DI": "Această configurație este o dependență cheie pentru F0.2 (CI/CD), permițând 'semantic-release'."
    }
  },
F0.1.40
  {
    "F0.1.40": {
      "denumire_task": "Instalare 'commitlint' (Config)",
      "descriere_scurta_task": "Instalarea '@commitlint/config-conventional'.",
      "descriere_lunga_si_detaliata_task": "Instalăm '@commitlint/config-conventional', care este setul de reguli standard (de ex. 'feat:', 'fix:', 'docs:') pe care îl vom impune, așa cum este sugerat în [13] și.[14]",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.39: '@commitlint/cli' este instalat.",
      "contextul_general_al_aplicatiei": "Adoptarea standardului 'Conventional Commits'.",
      "contextualizarea_directoarelor_si_cailor": "Comanda se execută în '/var/www/GeniusSuite/'.",
      "restrictii_anti_halucinatie":,
      "restrictii_de_iesire_din_contex": "N/A",
      "validare": "Verifică 'package.json' pentru '@commitlint/config-conventional'.",
      "outcome": "Configurația convențională pentru 'commitlint' este instalată.",
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.1.41
  {
    "F0.1.41": {
      "denumire_task": "Configurare 'commitlint'",
      "descriere_scurta_task": "Crearea fișierului 'commitlint.config.js' (sau '.commitlintrc.json').",
      "descriere_lunga_si_detaliata_task": "Creăm fișierul de configurare pentru 'commitlint' la rădăcină. Acest fișier pur și simplu extinde setul de reguli 'config-conventional' pe care tocmai le-am instalat.[13]",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.40: '@commitlint/config-conventional' este instalat.",
      "contextul_general_al_aplicatiei": "Activarea regulilor 'Conventional Commits'.",
      "contextualizarea_directoarelor_si_cailor": "Creează fișierul '/var/www/GeniusSuite/commitlint.config.js'.",
      "restrictii_anti_halucinatie": [
        "Creează un fișier nou 'commitlint.config.js'.",
        "Conținutul fișierului trebuie să fie:",
        "module.exports = {",
        "  extends: ['@commitlint/config-conventional']",
        "};"
      ],
      "restrictii_de_iesire_din_contex": "Nu adăuga reguli custom încă.",
      "validare": "Verifică existența și conținutul fișierului 'commitlint.config.js'.",
      "outcome": "Configurația 'commitlint' este creată.",
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.1.42
  {
    "F0.1.42": {
      "denumire_task": "Creare Hook 'commit-msg' (Husky)",
      "descriere_scurta_task": "Crearea hook-ului 'commit-msg' folosind 'husky add' pentru a rula 'commitlint'.",
      "descriere_lunga_si_detaliata_task": "Acum legăm 'husky' de 'commitlint'. Folosim comanda 'husky add' pentru a crea fișierul '.husky/commit-msg'. Acest hook se declanșează *după* ce 'pre-commit' a rulat și *înainte* ca commit-ul să fie finalizat. Acesta va valida mesajul de commit folosind 'commitlint'.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.35: 'husky' este inițializat. F0.1.41: 'commitlint' este configurat.",
      "contextul_general_al_aplicatiei": "Activarea finală a validării mesajelor de commit.",
      "contextualizarea_directoarelor_si_cailor": "Comanda va crea fișierul '.husky/commit-msg'.",
      "restrictii_anti_halucinatie": [
        "Execută comanda: 'pnpm exec husky add.husky/commit-msg \"npx commitlint --edit $1\"'",
        "Argumentul '--edit $1' este esențial; $1 este un parametru Git care conține calea către fișierul temporar cu mesajul de commit."
      ],
      "restrictii_de_iesire_din_contex": "N/A",
      "validare": "Verifică conținutul fișierului '.husky/commit-msg'.",
      "outcome": "Hook-ul 'commit-msg' este configurat pentru a valida mesajele de commit.",
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.1.43
  {
    "F0.1.43": {
      "denumire_task": "Adăugare Script-uri 'lint' în 'package.json'",
      "descriere_scurta_task": "Adăugarea script-urilor 'lint' și 'lint:fix' în 'package.json' de la rădăcină.",
      "descriere_lunga_si_detaliata_task": "Adăugăm script-uri la rădăcină pentru a rula linting-ul pe *întregul* proiect (de ex., în CI sau la cerere). Folosim 'nx affected:lint --all' [31] pentru a rula pe toate proiectele afectate (sau pe toate dacă se specifică '--all').",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.12: Nx este inițializat. F0.1.32: ESLint configurat.",
      "contextul_general_al_aplicatiei": "Furnizarea unor puncte de intrare convenabile pentru validarea întregului proiect.",
      "contextualizarea_directoarelor_si_cailor": "Modifică 'package.json' de la rădăcină, în secțiunea 'scripts'.",
      "restrictii_anti_halucinatie": [
        "Adaugă următoarele script-uri la cheia 'scripts':",
        "\"lint\": \"nx affected:lint --all\",",
        "\"lint:fix\": \"nx affected:lint --all --fix\"",
        "Asigură-te că nu ștergi script-ul 'prepare' adăugat de 'husky init'."
      ],
      "restrictii_de_iesire_din_contex": "Nu adăuga script-uri 'format' încă.",
      "validare": "'package.json' conține script-urile 'lint' și 'lint:fix'.",
      "outcome": "Script-uri de linting global sunt disponibile prin 'pnpm lint'.",
      "componenta_de_CI_DI": "CI va rula 'pnpm lint'."
    }
  },
F0.1.44
  {
    "F0.1.44": {
      "denumire_task": "Adăugare Script-uri 'format' în 'package.json'",
      "descriere_scurta_task": "Adăugarea script-urilor 'format:check' și 'format:write' în 'package.json' de la rădăcină.",
      "descriere_lunga_si_detaliata_task": "Adăugăm script-uri la rădăcină pentru a verifica și aplica formatarea Prettier folosind wrapper-ul Nx, 'nx format'.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.12: Nx este inițializat. F0.1.21: Prettier configurat.",
      "contextul_general_al_aplicatiei": "Furnizarea unor puncte de intrare convenabile pentru formatarea întregului proiect.",
      "contextualizarea_directoarelor_si_cailor": "Modifică 'package.json' de la rădăcină, în secțiunea 'scripts'.",
      "restrictii_anti_halucinatie": [
        "Adaugă următoarele script-uri la cheia 'scripts':",
        "\"format:check\": \"nx format:check\",",
        "\"format:write\": \"nx format:write\"",
        "Asigură-te că nu ștergi script-ul 'prepare' sau script-urile 'lint'."
      ],
      "restrictii_de_iesire_din_contex": "N/A",
      "validare": "'package.json' conține script-urile 'format:check' și 'format:write'.",
      "outcome": "Script-uri de formatare globală sunt disponibile prin 'pnpm format:check'.",
      "componenta_de_CI_DI": "CI va rula 'pnpm format:check'."
    }
  },
F0.1.45
  {
    "F0.1.45": {
      "denumire_task": "Validare Hook 'pre-commit' (Test Eșec Lint)",
      "descriere_scurta_task": "Testarea hook-ului 'pre-commit' prin introducerea intenționată a unei erori de linting.",
      "descriere_lunga_si_detaliata_task": "Acest task validează că hook-ul 'pre-commit' (F0.1.38) funcționează. Vom crea un fișier temporar, vom introduce o eroare ESLint evidentă (de ex. 'var x = 1;'), îl vom adăuga în 'staged' și vom încerca să-l comisionăm. Commit-ul ar trebui să eșueze.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.38: Hook-ul 'pre-commit' este creat.",
      "contextul_general_al_aplicatiei": "Testarea infrastructurii de DevEx (Developer Experience).",
      "contextualizarea_directoarelor_si_cailor": "Se execută comenzi Git și 'echo' la rădăcină.",
      "restrictii_anti_halucinatie":,
      "restrictii_de_iesire_din_contex": "N/A",
      "validare": "Commit-ul eșuează cu un mesaj de eroare de la 'lint-staged' / 'eslint'.",
      "outcome": "Hook-ul 'pre-commit' este confirmat ca fiind funcțional.",
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.1.46
  {
    "F0.1.46": {
      "denumire_task": "Validare Hook 'pre-commit' (Test Auto-Fix)",
      "descriere_scurta_task": "Testarea hook-ului 'pre-commit' pentru auto-fixarea erorilor de formatare.",
      "descriere_lunga_si_detaliata_task": "Acest task validează că 'nx format:write --files' și 'nx affected:lint --fix' (F0.1.37) funcționează. Vom crea un fișier cu formatare incorectă (spații vs. tab-uri), îl vom adăuga în 'staged' și vom încerca să-l comisionăm. 'lint-staged' ar trebui să corecteze automat fișierul.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.45: Eșecul hook-ului a fost validat.",
      "contextul_general_al_aplicatiei": "Testarea infrastructurii de DevEx.",
      "contextualizarea_directoarelor_si_cailor": "Se execută comenzi Git și 'echo' la rădăcină.",
      "restrictii_anti_halucinatie":,
      "restrictii_de_iesire_din_contex": "Nu lăsa fișierul de test în repository.",
      "validare": "Commit-ul reușește. Verifică conținutul 'test-format.ts' după 'git add' (ar trebui să fie formatat corect: 'const a = 1;').",
      "outcome": "Hook-ul 'pre-commit' este confirmat că auto-corectează formatarea.",
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.1.47
  {
    "F0.1.47": {
      "denumire_task": "Validare Hook 'commit-msg' (Test Eșec)",
      "descriere_scurta_task": "Testarea hook-ului 'commit-msg' prin furnizarea unui mesaj de commit neconvențional.",
      "descriere_lunga_si_detaliata_task": "Acest task validează că hook-ul 'commit-msg' (F0.1.42) și 'commitlint' (F0.1.41) funcționează. Vom încerca să facem un commit (folosind un fișier valid) cu un mesaj invalid, cum ar fi \"test\". Commit-ul ar trebui să fie blocat.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.42: Hook-ul 'commit-msg' este creat.",
      "contextul_general_al_aplicatiei": "Testarea infrastructurii de DevEx.",
      "contextualizarea_directoarelor_si_cailor": "Se execută comenzi Git la rădăcină.",
      "restrictii_anti_halucinatie": [
        "Execută 'echo \"// test file\" > test-commitmsg.ts'",
        "Execută 'git add test-commitmsg.ts'",
        "Execută 'git commit -m \"mesaj invalid\"' (Fără --no-verify)",
        "Comanda 'git commit' *trebuie* să eșueze.",
        "Output-ul trebuie să arate erori de la 'commitlint' (de ex. 'subject may not be empty', 'type may not be empty').",
        "Curăță după: 'rm test-commitmsg.ts' și 'git reset'."
      ],
      "restrictii_de_iesire_din_contex": "N/A",
      "validare": "Commit-ul eșuează cu un mesaj de eroare de la 'commitlint'.",
      "outcome": "Hook-ul 'commit-msg' este confirmat ca fiind funcțional.",
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.1.48
  {
    "F0.1.48": {
      "denumire_task": "Validare Hook 'commit-msg' (Test Succes)",
      "descriere_scurta_task": "Testarea hook-ului 'commit-msg' cu un mesaj de commit convențional valid.",
      "descriere_lunga_si_detaliata_task": "Acest task validează că un mesaj de commit valid (de ex. 'feat: add commitlint') trece de hook-ul 'commit-msg'.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.47: Eșecul hook-ului a fost validat.",
      "contextul_general_al_aplicatiei": "Testarea infrastructurii de DevEx.",
      "contextualizarea_directoarelor_si_cailor": "Se execută comenzi Git la rădăcină.",
      "restrictii_anti_halucinatie":,
      "restrictii_de_iesire_din_contex": "Nu lăsa fișierul de test în repository.",
      "validare": "Commit-ul reușește fără erori.",
      "outcome": "Întreaga suită de hook-uri Git (pre-commit, commit-msg) este validată.",
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.1.49
  {
    "F0.1.49": {
      "denumire_task": "Creare Fișier Rădăcină 'README.md'",
      "descriere_scurta_task": "Crearea unui fișier 'README.md' de bază pentru monorepo.",
      "descriere_lunga_si_detaliata_task": "Creăm un fișier 'README.md' la rădăcină. Acesta va servi ca punct de intrare pentru noii dezvoltatori, descriind pe scurt suita GeniusSuite și oferind instrucțiuni de bază (de ex. 'pnpm install').",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.1 - F0.1.48: Fundația este gata.",
      "contextul_general_al_aplicatiei": "Documentația de bază a proiectului.",
      "contextualizarea_directoarelor_si_cailor": "Creează '/var/www/GeniusSuite/README.md'.",
      "restrictii_anti_halucinatie":",
        "",
        "## Stack Principal",
        "*   **Monorepo:** Nx + pnpm workspaces",
        "*   **Tooling:** TypeScript, ESLint, Prettier, Husky",
        "",
        "## Inițializare",
        "```bash",
        "pnpm install",
        "```",
        "",
        "## Comenzi Uzuale",
        "```bash",
        "# Rulează linting pe proiectele afectate",
        "pnpm lint",
        "",
        "# Verifică formatarea",
        "pnpm format:check",
        "```"
      ],
      "restrictii_de_iesire_din_contex": "N/A",
      "validare": "Fișierul 'README.md' există.",
      "outcome": "Proiectul are un fișier 'README.md' de bază.",
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.1.50
  {
    "F0.1.50": {
      "denumire_task": "Creare Branch 'dev'",
      "descriere_scurta_task": "Crearea branch-ului 'dev' din 'master' (sau 'main').",
      "descriere_lunga_si_detaliata_task": "Conform guvernanței Git, creăm branch-ul 'dev' din branch-ul principal ('master' sau 'main'). Presupunem că 'master' este branch-ul implicit. Toată munca F0.1 va fi comisionată pe acest branch.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "Toate task-urile F0.1 sunt finalizate.",
      "contextul_general_al_aplicatiei": "Respectarea guvernanței Git cu 3 branch-uri (master, staging, dev) menționată în cerință.",
      "contextualizarea_directoarelor_si_cailor": "Comenzi Git executate la rădăcină.",
      "restrictii_anti_halucinatie": [
        "Presupunând că 'git init' și un prim commit (de ex. cu.gitignore) a fost făcut pe 'master'.",
        "Execută 'git checkout master' (sau 'main').",
        "Execută 'git pull origin master' (pentru a fi la zi).",
        "Execută 'git checkout -b dev'"
      ],
      "restrictii_de_iesire_din_contex": "Nu comisiona încă.",
      "validare": "Execută 'git branch --show-current'. Rezultatul trebuie să fie 'dev'.",
      "outcome": "Un nou branch 'dev' este creat și activ.",
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.1.51
  {
    "F0.1.51": {
      "denumire_task": "Comisionare Artefacte F0.1 pe Branch-ul 'dev'",
      "descriere_scurta_task": "Adăugarea și comisionarea tuturor fișierelor de fundație F0.1.",
      "descriere_lunga_si_detaliata_task": "Adăugăm toate fișierele create și modificate în Faza F0.1 (package.json, nx.json, pnpm-workspace.yaml, tsconfig.base.json,.eslintrc.json,.prettierrc,.husky/,.gitignore, README.md, și directoarele goale) și le comisionăm cu un mesaj care respectă 'Conventional Commits'.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.50: Branch-ul 'dev' este activ. F0.1.1 - F0.1.49: Toate fișierele au fost create/configurate.",
      "contextul_general_al_aplicatiei": "Finalizarea fazei F0.1 și pregătirea pentru revizuire.",
      "contextualizarea_directoarelor_si_cailor": "Comenzi Git executate la rădăcină.",
      "restrictii_anti_halucinatie":,
      "restrictii_de_iesire_din_contex": "Nu face push încă.",
      "validare": "Execută 'git log -1'. Commit-ul trebuie să fie vizibil.",
      "outcome": "Toate artefactele F0.1 sunt comisionate local pe branch-ul 'dev'.",
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.1.52
  {
    "F0.1.52": {
      "denumire_task": "Push Branch 'dev' și Creare PR/MR",
      "descriere_scurta_task": "Publicarea branch-ului 'dev' și pregătirea instrucțiunilor pentru un PR/MR către 'master'.",
      "descriere_lunga_si_detaliata_task": "Acest task finalizează Faza F0.1 prin publicarea branch-ului 'dev' pe 'origin' și instruirea agentului AI să genereze descrierea pentru un Pull Request (PR) sau Merge Request (MR) de la 'dev' la 'master' (sau 'main'), conform cerinței.",
      "directorul_directoarele":,
      "contextul_taskurilor_anterioare": "F0.1.51: Munca F0.1 este comisionată local pe 'dev'.",
      "contextul_general_al_aplicatiei": "Respectarea guvernanței Git și finalizarea primei unități de lucru.",
      "contextualizarea_directoarelor_si_cailor": "Comenzi Git executate la rădăcină.",
      "restrictii_anti_halucinatie":,
      "restrictii_de_iesire_din_contex": "Nu executa 'merge'. Doar pregătește PR/MR-ul.",
      "validare": "Branch-ul 'dev' există pe 'origin' și conține commit-ul F0.1.",
      "outcome": "Faza F0.1 este finalizată, comisionată și gata de revizuire într-un PR/MR.",
      "componenta_de_CI_DI": "Acest push va declanșa primul pipeline CI (definit în F0.2), care ar trebui să ruleze 'pnpm install', 'pnpm lint' și 'pnpm format:check'.",
      "PR_MR": {
        "sursa_branch": "dev",
        "destinatie_branch": "master",
        "titlu": "feat(platform): F0.1 - Inițializare Fundație Monorepo și Tooling",
        "descriere": "Acest PR stabilește fundația completă a monorepo-ului GeniusSuite (Faza F0.1), conform planului de arhitectură.\n\n**Schimbări Cheie:**\n\n1.  **Manager de Pachete:** Inițializat cu `pnpm` și configurat `pnpm-workspace.yaml` pentru a reflecta structura exactă a aplicațiilor din (ex. `cp/*`, `shared/*`, `vettify.app`, etc.).\n2.  **Manager Monorepo:** `Nx` a fost instalat și configurat (`nx.json`) pentru a adopta workspace-ul `pnpm`, cu `targetDefaults` pentru caching. \n3.  **TypeScript:** Configurat `tsconfig.base.json` cu setări `strict: true`  și alias-uri `paths` pentru toate bibliotecile `shared/*` (de ex. `@genius-suite/ui-design-system`). \n4.  **Standarde de Cod:**\n    *   `Prettier` instalat și configurat (`.prettierrc`). \n    *   `ESLint` instalat și configurat (`.eslintrc.json`) cu plugin-urile `@nx/eslint-plugin`, `@typescript-eslint/eslint-plugin`  și integrare `eslint-config-prettier`. \n5.  **Cârlige Git (Husky v9):**\n    *   `pre-commit`: Rulează `lint-staged`, care execută `nx format:write` și `nx affected:lint --fix` pe fișierele din staged. \n    *   `commit-msg`: Rulează `commitlint` pentru a impune 'Conventional Commits' (bazat pe `@commitlint/config-conventional`). \n\n**Validare:**\n\n*   Toate hook-urile (pre-commit, commit-msg) au fost testate local (task-urile F0.1.45 - F0.1.48) și funcționează conform așteptărilor.\n*   Script-urile `pnpm lint` și `pnpm format:check` sunt disponibile pentru CI."
      }
    }
  }
F0.2 CI/CD: pipeline build/test/lint, release semantice, versionare pachete, container registry.
F0.2.1
{
  "F0.2.1": {
    "denumire_task": "Creare Director Workflows GitHub Actions",
    "descriere_scurta_task": "Creează directorul '.github/workflows' la rădăcina monorepo-ului.",
    "descriere_lunga_si_detaliata_task": "Acest task stabilește locația standard pentru fișierele de pipeline GitHub Actions. Vom crea ierarhia de directoare '.github/workflows/' în directorul rădăcină '/var/www/GeniusSuite'.",
    "directorul_directoarele": [
      "/"
    ],
    "contextul_taskurilor_anterioare": "F0.1: Fundația monorepo (tooling, nx, pnpm) este completă și comisionată pe branch-ul 'dev'.",
    "contextul_general_al_aplicatiei": "Inițierea Fazei F0.2 (CI/CD) prin crearea infrastructurii de fișiere pentru pipeline-uri.",
    "contextualizarea_directoarelor_si_cailor": "Comanda 'mkdir -p /var/www/GeniusSuite/.github/workflows' va crea directoarele necesare.",
    "restrictii_anti_halcinatie":,
    "restrictii_de_iesire_din_contex": "Nu crea alte fișiere sau directoare.",
    "validare": "Verifică existența directorului '/var/www/GeniusSuite/.github/workflows'.",
    "outcome": "Directorul pentru stocarea fișierelor de workflow GitHub Actions este creat.",
    "componenta_de_CI_DI": "Acesta este directorul standard pentru toate pipeline-urile de CI/CD GitHub Actions."
  }
}
F0.2.2
  {
    "F0.2.2": {
      "denumire_task": "Creare Fișier Workflow CI Principal ('ci.yml')",
      "descriere_scurta_task": "Creează fișierul 'ci.yml' pentru validarea Pull Request-urilor.",
      "descriere_lunga_si_detaliata_task": "Creăm fișierul principal de workflow, 'ci.yml'. Acest pipeline va fi responsabil pentru validarea calității codului (lint, test, build) pe fiecare Pull Request deschis către branch-urile 'dev', 'staging' și 'master'.",
      "directorul_directoarele": [
        ".github/workflows/"
      ],
      "contextul_taskurilor_anterioare": "F0.2.1: Directorul '.github/workflows/' a fost creat.",
      "contextul_general_al_aplicatiei": "Faza F0.2 automatizează validările definite în F0.1. Acest fișier va conține logica de CI pentru PR-uri.",
      "contextualizarea_directoarelor_si_cailor": "Creează fișierul '/var/www/GeniusSuite/.github/workflows/ci.yml'.",
      "restrictii_anti_halcinatie":,
      "restrictii_de_iesire_din_contex": "Nu crea alte fișiere workflow (de ex. 'release.yml').",
      "validare": "Verifică existența fișierului '.github/workflows/ci.yml'.",
      "outcome": "Fișierul 'ci.yml' este creat.",
      "componenta_de_CI_DI": "Acest fișier va defini pipeline-ul principal de validare (CI)."
    }
  },
F0.2.3
  {
    "F0.2.3": {
      "denumire_task": "Definire Declanșatoare (Triggers) pentru 'ci.yml'",
      "descriere_scurta_task": "Configurează 'ci.yml' să ruleze pe Pull Request-uri către 'master', 'staging' și 'dev'.",
      "descriere_lunga_si_detaliata_task": "Edităm 'ci.yml' pentru a defini evenimentele care îl declanșează. Conform strategiei de branching, acest pipeline trebuie să ruleze la orice Pull Request deschis către branch-urile principale.",
      "directorul_directoarele": [
        ".github/workflows/"
      ],
      "contextul_taskurilor_anterioare": "F0.2.2: Fișierul 'ci.yml' a fost creat.",
      "contextul_general_al_aplicatiei": "Alinierea CI-ului la strategia de guvernanță Git (master, staging, dev).",
      "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '.github/workflows/ci.yml'.",
      "restrictii_anti_halcinatie":,
      "restrictii_de_iesire_din_contex": "Nu adăuga triggere 'push' în acest fișier. Pipeline-urile de push vor fi separate (de ex. 'release.yml').",
      "validare": "Conținutul 'ci.yml' reflectă triggerele specificate.",
      "outcome": "'ci.yml' este configurat să ruleze doar pe PR-uri către branch-urile protejate.",
      "componenta_de_CI_DI": "Definește momentul execuției pipeline-ului de CI."
    }
  },
F0.2.4
  {
    "F0.2.4": {
      "denumire_task": "Definire Job 'validate' în 'ci.yml'",
      "descriere_scurta_task": "Adaugă structura de bază pentru job-ul 'validate' în 'ci.yml'.",
      "descriere_lunga_si_detaliata_task": "Definim primul și principalul job al pipeline-ului de CI: 'validate'. Acest job va rula pe un agent 'ubuntu-latest' și va conține toți pașii necesari pentru checkout, instalare, lint, test și build.",
      "directorul_directoarele": [
        ".github/workflows/"
      ],
      "contextul_taskurilor_anterioare": "F0.2.3: Au fost definite triggerele 'ci.yml'.",
      "contextul_general_al_aplicatiei": "Structurarea pipeline-ului de CI.",
      "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '.github/workflows/ci.yml'.",
      "restrictii_anti_halcinatie":"
      ],
      "restrictii_de_iesire_din_contex": "Nu adăuga alți pași (steps) în afară de 'actions/checkout@v4'.",
      "validare": "'ci.yml' conține definiția job-ului 'validate' cu pasul de checkout.",
      "outcome": "Structura de bază a job-ului 'validate' este creată.",
      "componenta_de_CI_DI": "Reprezintă scheletul job-ului de CI."
    }
  },
F0.2.5
  {
    "F0.2.5": {
      "denumire_task": "Adăugare 'pnpm/action-setup' în Job-ul 'validate'",
      "descriere_scurta_task": "Adaugă pasul de instalare 'pnpm' în 'ci.yml'.",
      "descriere_lunga_si_detaliata_task": "Pentru a putea rula comenzi 'pnpm' (conform F0.1), trebuie să instalăm 'pnpm' pe agentul de CI. Folosim acțiunea oficială 'pnpm/action-setup'. Acest pas include și configurarea cache-ului pentru 'pnpm store'.",
      "directorul_directoarele": [
        ".github/workflows/"
      ],
      "contextul_taskurilor_anterioare": "F0.2.4: Job-ul 'validate' a fost creat cu pasul de checkout.",
      "contextul_general_al_aplicatiei": "Configurarea mediului de CI pentru a utiliza managerul de pachete 'pnpm'.[1]",
      "contextualizarea_directoarelor_si_cailor": "Modifică '.github/workflows/ci.yml', adăugând pași noi în job-ul 'validate' după 'checkout'.",
      "restrictii_anti_halcinatie":",
        "",
        "- name: Setup pnpm",
        "  uses: pnpm/action-setup@v2",
        "  with:",
        "    version: 8 # Sau cea mai recentă versiune pnpm",
        "",
        "- name: Setup pnpm Cache",
        "  uses: actions/cache@v4",
        "  with:",
        "    path: \"~/.pnpm-store\"",
        "    key: ${{ runner.os }}-pnpm-store-${{ hashFiles('**/pnpm-lock.yaml') }}",
        "    restore-keys: |",
        "      ${{ runner.os }}-pnpm-store-",
        ""
      ],
      "restrictii_de_iesire_din_contex": "Nu adăuga 'pnpm install' încă. Acesta va fi un pas separat.",
      "validare": "'ci.yml' conține pașii pentru 'setup-node', 'setup-pnpm' și 'cache'.",
      "outcome": "Agentul de CI este configurat să folosească 'pnpm' și să cache-uiască store-ul 'pnpm'.",
      "componenta_de_CI_DI": "Esențial pentru performanța instalării dependențelor."
    }
  },
F0.2.6
  {
    "F0.2.6": {
      "denumire_task": "Adăugare Pas 'pnpm install' în Job-ul 'validate'",
      "descriere_scurta_task": "Adaugă pasul de instalare a dependențelor în 'ci.yml'.",
      "descriere_lunga_si_detaliata_task": "După configurarea 'pnpm' și a cache-ului, rulăm 'pnpm install --frozen-lockfile'. Folosirea '--frozen-lockfile' este cea mai bună practică în CI pentru a asigura că se instalează exact versiunile din 'pnpm-lock.yaml', prevenind instalări nedeterministe.",
      "directorul_directoarele": [
        ".github/workflows/"
      ],
      "contextul_taskurilor_anterioare": "F0.2.5: 'pnpm' și cache-ul său sunt configurate în 'ci.yml'.",
      "contextul_general_al_aplicatiei": "Instalarea dependențelor monorepo-ului.",
      "contextualizarea_directoarelor_si_cailor": "Modifică '.github/workflows/ci.yml', adăugând un pas nou în job-ul 'validate' după 'Setup pnpm Cache'.",
      "restrictii_anti_halcinatie":,
      "restrictii_de_iesire_din_contex": "Nu folosi 'pnpm install' simplu.",
      "validare": "'ci.yml' conține pasul 'Install Dependencies'.",
      "outcome": "Pipeline-ul de CI instalează corect dependențele proiectului.",
      "componenta_de_CI_DI": "Pas obligatoriu înainte de orice task de lint, test sau build."
    }
  },
F0.2.7
  {
    "F0.2.7": {
      "denumire_task": "Adăugare Pas 'nrwl/nx-set-shas' în Job-ul 'validate'",
      "descriere_scurta_task": "Adaugă acțiunea 'nrwl/nx-set-shas' pentru a seta SHAs-urile pentru 'nx affected'.",
      "descriere_lunga_si_detaliata_task": "Acest pas este critic pentru rularea corectă a comenzilor 'nx affected' în CI pe Pull Requests. Acțiunea 'nrwl/nx-set-shas@v4' calculează automat SHA-ul de bază (punctul de merge cu branch-ul destinație) și SHA-ul de capăt (ultimul commit al PR-ului). Setează variabilele de mediu `NX_BASE` și `NX_HEAD` pe care `nx affected` le folosește automat.",
      "directorul_directoarele": [
        ".github/workflows/"
      ],
      "contextul_taskurilor_anterioare": "F0.2.6: Dependențele sunt instalate în 'ci.yml'.",
      "contextul_general_al_aplicatiei": "Utilizarea 'nx affected' este pilonul central al acestui pipeline de CI pentru a economisi timp.",
      "contextualizarea_directoarelor_si_cailor": "Modifică '.github/workflows/ci.yml', adăugând un pas nou în job-ul 'validate' după 'Install Dependencies'.",
      "restrictii_anti_halcinatie":,
      "restrictii_de_iesire_din_contex": "Nu adăuga alte configurații la acest pas.",
      "validare": "Log-ul pasului 'Set Nx SHAs' din GitHub Actions ar trebui să indice SHA-urile corecte.",
      "outcome": "Job-ul 'validate' este acum capabil să determine corect proiectele afectate.",
      "componenta_de_CI_DI": "Configurare fundamentală pentru 'nx affected' în CI."
    }
  },
F0.2.8
  {
    "F0.2.8": {
      "denumire_task": "Conectare la Nx Cloud (Remote Cache)",
      "descriere_scurta_task": "Adaugă pasul de conectare la Nx Cloud pentru remote caching.",
      "descriere_lunga_si_detaliata_task": "Pentru a accelera pipeline-ul, ne conectăm la Nx Cloud (sau alt remote cache). Acest pas, 'nx-cloud start-ci-run', este de obicei rulat înainte de task-urile 'affected'. Acest lucru presupune că 'nx' a fost conectat la Nx Cloud (un pas care se face de obicei local prin 'nx connect' sau a fost făcut în F0.1.12 'nx init'). Vom adăuga și token-ul ca secret.",
      "directorul_directoarele": [
        ".github/workflows/"
      ],
      "contextul_taskurilor_anterioare": "F0.2.7: SHAs-urile Nx sunt setate.",
      "contextul_general_al_aplicatiei": "Accelerarea CI/CD prin utilizarea remote caching-ului. F0.1.13 a configurat 'targetDefaults' pentru cache.",
      "contextualizarea_directoarelor_si_cailor": "Modifică '.github/workflows/ci.yml', adăugând un pas nou în job-ul 'validate' după 'Set Nx SHAs'.",
      "restrictii_anti_halcinatie":,
      "restrictii_de_iesire_din_contex": "Acest task presupune că secretul 'NX_CLOUD_AUTH_TOKEN' va fi adăugat în setările repository-ului GitHub. Nu adăuga token-ul direct în fișier.",
      "validare": "Run-ul de CI va apărea în dashboard-ul Nx Cloud.",
      "outcome": "Pipeline-ul de CI este conectat la Nx Cloud, permițând cache-ul distribuit.",
      "componenta_de_CI_DI": "Pas de optimizare a performanței CI."
    }
  },
F0.2.9
  {
    "F0.2.9": {
      "denumire_task": "Adăugare Pași de Validare (Format, Lint, Test, Build) în 'ci.yml'",
      "descriere_scurta_task": "Adaugă rularea 'nx affected' pentru 'format:check', 'lint', 'test' și 'build'.",
      "descriere_lunga_si_detaliata_task": "Acesta este miezul job-ului 'validate'. Adăugăm pașii care rulează script-urile definite în F0.1, dar folosind 'nx affected'. Vom rula 'format:check', 'lint', 'test' și 'build' în paralel (Nx gestionează paralelizarea) pentru toate proiectele afectate de PR.",
      "directorul_directoarele": [
        ".github/workflows/"
      ],
      "contextul_taskurilor_anterioare": "F0.2.8: Nx Cloud este conectat și F0.2.7 SHAs-urile sunt setate.",
      "contextul_general_al_aplicatiei": "Validarea calității codului și a funcționalității înainte de merge.",
      "contextualizarea_directoarelor_si_cailor": "Modifică '.github/workflows/ci.yml', adăugând pași noi în job-ul 'validate' după 'Connect to Nx Cloud'.",
      "restrictii_anti_halcinatie":,
      "restrictii_de_iesire_din_contex": "Folosește 'pnpm exec nx affected'. Nu rula 'pnpm lint' sau 'pnpm test' direct, deoarece F0.1 a mapat 'pnpm lint' la 'nx affected:lint --all', ceea ce nu este dorit într-un PR.",
      "validare": "Pipeline-ul de CI va eșua dacă oricare dintre acești pași eșuează pe un proiect afectat.",
      "outcome": "Pipeline-ul 'ci.yml' validează complet formatarea, linting-ul, testele și build-ul proiectelor afectate.",
      "componenta_de_CI_DI": "Miezul validării CI."
    }
  },
F0.2.10
  {
    "F0.2.10": {
      "denumire_task": "Creare Fișier Workflow 'release.yml'",
      "descriere_scurta_task": "Creează fișierul 'release.yml' pentru publicarea pachetelor.",
      "descriere_lunga_si_detaliata_task": "Creăm un al doilea fișier workflow, 'release.yml'. Acesta va fi responsabil pentru versionarea semantică și publicarea pachetelor. Acest pipeline va rula doar pe push-uri către 'master'.",
      "directorul_directoarele": [
        ".github/workflows/"
      ],
      "contextul_taskurilor_anterioare": "F0.2.1: Directorul '.github/workflows/' există.",
      "contextul_general_al_aplicatiei": "Automatizarea procesului de release (CD).",
      "contextualizarea_directoarelor_si_cailor": "Creează fișierul '/var/www/GeniusSuite/.github/workflows/release.yml'.",
      "restrictii_anti_halcinatie":,
      "restrictii_de_iesire_din_contex": "Nu modifica 'ci.yml'.",
      "validare": "Verifică existența fișierului '.github/workflows/release.yml'.",
      "outcome": "Fișierul 'release.yml' este creat.",
      "componenta_de_CI_DI": "Acest fișier va defini pipeline-ul de publicare a pachetelor."
    }
  },
F0.2.11
  {
    "F0.2.11": {
      "denumire_task": "Instalare '@changesets/cli'",
      "descriere_scurta_task": "Instalează '@changesets/cli' ca dependență de dezvoltare la rădăcină.",
      "descriere_lunga_si_detaliata_task": "Pentru a gestiona versionarea independentă a pachetelor (conform  Cap. 2), vom folosi 'changesets'. Acesta este un instrument preferat în monorepo-uri, în locul 'semantic-release', deoarece decuplează versionarea de mesajele de commit. Instalăm pachetul CLI la rădăcina monorepo-ului.",
      "directorul_directoarele": [
        "/"
      ],
      "contextul_taskurilor_anterioare": "F0.1.51: Fundația F0.1 este comisionată.",
      "contextul_general_al_aplicatiei": "Pregătirea pentru versionarea semantică a pachetelor 'shared/*' și a aplicațiilor.",
      "contextualizarea_directoarelor_si_cailor": "Execută comanda în '/var/www/GeniusSuite/'. Va modifica 'package.json' de la rădăcină.",
      "restrictii_anti_halcinatie":,
      "restrictii_de_iesire_din_contex": "Nu instala alte pachete 'changesets' (cum ar fi `@changesets/cli-github`) încă.",
      "validare": "Verifică 'package.json' pentru a vedea '@changesets/cli' în 'devDependencies'.",
      "outcome": "CLI-ul 'changesets' este instalat.",
      "componenta_de_CI_DI": "Dependență de bază pentru pipeline-ul de release."
    }
  },
F0.2.12
  {
    "F0.2.12": {
      "denumire_task": "Inițializare 'changesets'",
      "descriere_scurta_task": "Rulează 'pnpm changeset init' pentru a crea directorul '.changeset'.",
      "descriere_lunga_si_detaliata_task": "Rulăm comanda de inițializare 'changesets'. Aceasta va crea directorul '.changeset' și fișierul de configurare 'config.json', precum și un 'README.md' explicativ în acel director.",
      "directorul_directoarele": [
        "/"
      ],
      "contextul_taskurilor_anterioare": "F0.2.11: '@changesets/cli' este instalat.",
      "contextul_general_al_aplicatiei": "Configurarea inițială a 'changesets'.",
      "contextualizarea_directoarelor_si_cailor": "Execută comanda în '/var/www/GeniusSuite/'. Va crea directorul '.changeset/'.",
      "restrictii_anti_halcinatie": [
        "Execută comanda: 'pnpm exec changeset init'"
      ],
      "restrictii_de_iesire_din_contex": "Nu modifica manual fișierele generate în acest pas.",
      "validare": "Verifică existența directorului '.changeset/' și a fișierului '.changeset/config.json'.",
      "outcome": "Configurația de bază 'changesets' este creată.",
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.2.13
  {
    "F0.2.13": {
      "denumire_task": "Configurare '.changeset/config.json'",
      "descriere_scurta_task": "Configurează 'config.json' pentru 'changesets' cu 'baseBranch' și 'access'.",
      "descriere_lunga_si_detaliata_task": "Modificăm fișierul de configurare 'changesets' pentru a-l alinia la proiectul nostru. Setăm 'baseBranch' la 'master' (conform F0.1) și 'access' la 'public' (presupunând că pachetele 'shared/*' vor fi publice, deși 'restricted' ar fi valabil pentru un registry privat). De asemenea, legăm repository-ul GitHub.",
      "directorul_directoarele": [
        ".changeset/"
      ],
      "contextul_taskurilor_anterioare": "F0.2.12: '.changeset/config.json' a fost creat.",
      "contextul_general_al_aplicatiei": "Configurarea fină a 'changesets' pentru a se potrivi cu fluxul Git și permisiunile pachetelor.",
      "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/.changeset/config.json'.",
      "restrictii_anti_halcinatie":,",
        "  \"linked\":,",
        "  \"access\": \"public\",",
        "  \"baseBranch\": \"master\",",
        "  \"updateInternalDependencies\": \"patch\",",
        "  \"ignore\":,",
        "  \"repository\": \"https://github.com/GITHUB_USERNAME/GeniusSuite\"",
        "}"
      ],
      "restrictii_de_iesire_din_contex": "Nu schimba 'commit': false. Vom gestiona comisionarea manual în pipeline.",
      "validare": "Fișierul '.changeset/config.json' este actualizat.",
      "outcome": "'changesets' este configurat pentru 'master' și publicare.",
      "componenta_de_CI_DI": "N/A"
    }
  },
F0.2.14
  {
    "F0.2.14": {
      "denumire_task": "Instalare Bot 'changesets' (GitHub Action)",
      "descriere_scurta_task": "Instalează '@changesets/cli-github' și adaugă workflow-ul bot-ului.",
      "descriere_lunga_si_detaliata_task": "Instalăm pachetul '@changesets/cli-github'. Apoi, creăm un nou fișier workflow, 'changeset-bot.yml'. Acest bot va rula pe PR-uri și va adăuga un comentariu dacă un PR modifică pachete, dar nu include un fișier '.changeset'.",
      "directorul_directoarele": [
        "/",
        ".github/workflows/"
      ],
      "contextul_taskurilor_anterioare": "F0.2.13: 'changesets' este configurat.",
      "contextul_general_al_aplicatiei": "Impunerea disciplinei de versionare pe PR-uri.",
      "contextualizarea_directoarelor_si_cailor": "Rulează 'pnpm add' la rădăcină. Creează fișierul '.github/workflows/changeset-bot.yml'.",
      "restrictii_anti_halcinatie":,
      "restrictii_de_iesire_din_contex": "Secretul 'GITHUB_TOKEN' este furnizat automat de GitHub.",
      "validare": "Pe un PR viitor care modifică un pachet (de ex. în 'shared/ui-design-system') fără un fișier.changeset, bot-ul va comenta.",
      "outcome": "Un bot automatizat validează prezența fișierelor de versionare pe PR-uri.",
      "componenta_de_CI_DI": "O componentă de validare CI suplimentară."
    }
  },
F0.2.15
  {
    "F0.2.15": {
      "denumire_task": "Configurare Workflow 'release.yml' (Triggers și Job 'publish')",
      "descriere_scurta_task": "Configurează 'release.yml' să ruleze pe 'push' la 'master' și definește job-ul 'publish'.",
      "descriere_lunga_si_detaliata_task": "Configurăm fișierul 'release.yml'. Acesta se va declanșa *doar* la push pe 'master'. Definim un singur job, 'publish', care va fi responsabil de rularea validărilor finale, versionarea și publicarea pachetelor.",
      "directorul_directoarele": [
        ".github/workflows/"
      ],
      "contextul_taskurilor_anterioare": "F0.2.10: Fișierul 'release.yml' există.",
      "contextul_general_al_aplicatiei": "Automatizarea publicării pachetelor pe 'master'.",
      "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '.github/workflows/release.yml'.",
      "restrictii_anti_halcinatie":,
      "restrictii_de_iesire_din_contex": "Secretul 'GH_PAT_TOKEN' (un Personal Access Token cu drepturi de 'write' pe repository) trebuie creat și adăugat în setările GitHub. Nu adăuga pașii 'changeset' încă.",
      "validare": "'release.yml' conține structura de bază a job-ului 'publish'.",
      "outcome": "Job-ul 'publish' este pregătit pentru pașii de versionare.",
      "componenta_de_CI_DI": "Scheletul pipeline-ului de CD."
    }
  },
F0.2.16
  {
    "F0.2.16": {
      "denumire_task": "Adăugare Pași de Validare în 'release.yml'",
      "descriere_scurta_task": "Adaugă pașii 'nx affected' (lint, test, build) în 'release.yml'.",
      "descriere_lunga_si_detaliata_task": "Înainte de a publica, trebuie să ne asigurăm că merge-ul în 'master' este valid. Re-rulăm validările (lint, test, build) folosind 'nx affected'. De data aceasta, 'nx affected' va compara 'master' cu commit-ul anterior ('master~1' sau 'origin/master~1').",
      "directorul_directoarele": [
        ".github/workflows/"
      ],
      "contextul_taskurilor_anterioare": "F0.2.15: Job-ul 'publish' din 'release.yml' este configurat cu instalarea.",
      "contextul_general_al_aplicatiei": "Asigurarea integrității branch-ului 'master' înainte de publicare.",
      "contextualizarea_directoarelor_si_cailor": "Modifică '.github/workflows/release.yml', adăugând pași noi în job-ul 'publish' după 'Install Dependencies'.",
      "restrictii_anti_halcinatie":,
      "restrictii_de_iesire_din_contex": "Acești pași sunt o replică a celor din 'ci.yml' pentru a garanta starea 'master'.",
      "validare": "'release.yml' conține pașii de validare 'affected'.",
      "outcome": "Pipeline-ul de release validează codul înainte de a încerca să publice.",
      "componenta_de_CI_DI": "Pas de siguranță în pipeline-ul de CD."
    }
  },
F0.2.17
  {
    "F0.2.17": {
      "denumire_task": "Adăugare Pași 'changeset version' și 'publish' în 'release.yml'",
      "descriere_scurta_task": "Adaugă pașii 'changeset version' și 'pnpm publish' în 'release.yml'.",
      "descriere_lunga_si_detaliata_task": "Acesta este pasul de publicare. Mai întâi, rulăm 'pnpm changeset version'. Această comandă consumă fișierele.changeset (dacă există), actualizează 'package.json'-urile pachetelor afectate, generează 'CHANGELOG.md' și șterge fișierele.changeset. Apoi, rulăm 'pnpm publish -r', care publică doar pachetele ce au o versiune nouă în registry (NPM sau GHCR).",
      "directorul_directoarele": [
        ".github/workflows/"
      ],
      "contextul_taskurilor_anterioare": "F0.2.16: Job-ul 'publish' din 'release.yml' este validat.",
      "contextul_general_al_aplicatiei": "Publicarea efectivă a pachetelor 'shared/*' și a altor pachete versionate.",
      "contextualizarea_directoarelor_si_cailor": "Modifică '.github/workflows/release.yml', adăugând pași noi la finalul job-ului 'publish'.",
      "restrictii_anti_halcinatie":@users.noreply.github.com\"",
        "",
        "- name: Create Release Pull Request or Version",
        "  id: changesets",
        "  uses: changesets/action@v1",
        "  with:",
        "    version: pnpm exec changeset version",
        "    publish: pnpm exec pnpm publish -r --no-git-checks",
        "    commit: \"chore(release): version packages\"",
        "    title: \"chore(release): version packages\"",
        "  env:",
        "    GITHUB_TOKEN: ${{ secrets.GH_PAT_TOKEN }}",
        "    NPM_TOKEN: ${{ secrets.NPM_TOKEN }} # Secretul pentru publicare în registry",
        ""
      ],
      "restrictii_de_iesire_din_contex": "Acest pas necesită 'NPM_TOKEN' (pentru publicare pe npmjs.org) sau 'GITHUB_TOKEN' (pentru publicare pe GHCR, dar 'NPM_TOKEN' este convenția 'changesets/action' pentru registry). 'GH_PAT_TOKEN' este necesar pentru a comisiona înapoi.",
      "validare": "Când un PR cu un changeset esteS_merguit în 'master', acest job va rula, va crea un commit nou de versionare și va publica pachetele.",
      "outcome": "Pipeline-ul 'release.yml' automatizează complet versionarea și publicarea pachetelor.",
      "componenta_de_CI_DI": "Miezul componentei de CD (Continuous Delivery) pentru pachete."
    }
  },
F0.2.18
  {
    "F0.2.18": {
      "denumire_task": "Creare Șablon 'Dockerfile.base' (Multi-stage)",
      "descriere_scurta_task": "Creează un 'Dockerfile.base' multi-stage reutilizabil pentru aplicațiile Node.js 24.",
      "descriere_lunga_si_detaliata_task": "Creăm un Dockerfile de bază în directorul 'scripts/'. Acesta va fi un șablon multi-stage. 'builder' stage va folosi imaginea 'node:20-alpine' (sau 24, dar 20 e mai comună în CI) pentru a instala dependențele pnpm și a construi artefactele. 'runner' stage va folosi o imagine 'node:20-alpine' slim, va copia doar artefactele de build și 'node_modules' de producție, pentru o imagine finală mică și securizată.",
      "directorul_directoarele": [
        "scripts/"
      ],
      "contextul_taskurilor_anterioare": "F0.1.9: Directorul 'scripts/' există.",
      "contextul_general_al_aplicatiei": "Standardizarea containerizării pentru toate aplicațiile (archify.app, vettify.app, etc.).",
      "contextualizarea_directoarelor_si_cailor": "Creează fișierul '/var/www/GeniusSuite/scripts/Dockerfile.base'.",
      "restrictii_anti_halcinatie":"
      ],
      "restrictii_de_iesire_din_contex": "Acesta este un fișier de bază/șablon. Nu este menit să fie construit direct.",
      "validare": "Fișierul 'scripts/Dockerfile.base' există.",
      "outcome": "Un șablon Dockerfile multi-stage standardizat este disponibil.",
      "componenta_de_CI_DI": "Fundația pentru toți pașii de 'docker-build'."
    }
  },
F0.2.19
  {
    "F0.2.19": {
      "denumire_task": "Adăugare Țintă (Target) 'docker-build' în 'nx.json'",
      "descriere_scurta_task": "Adaugă o țintă 'docker-build' în 'targetDefaults' din 'nx.json'.",
      "descriere_lunga_si_detaliata_task": "Adăugăm o nouă țintă implicită în 'nx.json' numită 'docker-build'. Această țintă va rula comanda 'docker buildx build'. Acest lucru ne va permite să rulăm 'nx affected -t docker-build' pentru a construi imagini doar pentru aplicațiile afectate.",
      "directorul_directoarele": [
        "/"
      ],
      "contextul_taskurilor_anterioare": "F0.1.13: 'nx.json' și 'targetDefaults' există.",
      "contextul_general_al_aplicatiei": "Integrarea build-urilor Docker în graful de task-uri Nx.",
      "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '/var/www/GeniusSuite/nx.json'.",
      "restrictii_anti_halcinatie":,",
        "  \"inputs\":",
        "}"
      ],
      "restrictii_de_iesire_din_contex": "Acesta definește doar ținta; nu creează Dockerfile-urile specifice aplicațiilor încă.",
      "validare": "'nx.json' conține 'targetDefaults.docker-build'.",
      "outcome": "Nx este acum conștient de ținta 'docker-build' și de dependențele sale.",
      "componenta_de_CI_DI": "Permite rularea 'nx affected -t docker-build' în pipeline."
    }
  },
F0.2.20
  {
    "F0.2.20": {
      "denumire_task": "Creare Fișier Workflow 'deploy-staging.yml'",
      "descriere_scurta_task": "Creează 'deploy-staging.yml' pentru build și push al imaginilor de staging.",
      "descriere_lunga_si_detaliata_task": "Creăm un al treilea fișier workflow. Acesta va fi responsabil pentru construirea imaginilor Docker pentru aplicațiile afectate și publicarea lor în container registry (GHCR) cu tag-ul 'staging'. Acest pipeline se declanșează la push pe branch-ul 'staging'.",
      "directorul_directoarele": [
        ".github/workflows/"
      ],
      "contextul_taskurilor_anterioare": "F0.2.1: Directorul '.github/workflows/' există. F0.2.19: Ținta 'docker-build' este definită.",
      "contextul_general_al_aplicatiei": "Definirea pipeline-ului de CD pentru mediul de staging, conform strategiei de branching.",
      "contextualizarea_directoarelor_si_cailor": "Creează fișierul '/var/www/GeniusSuite/.github/workflows/deploy-staging.yml'.",
      "restrictii_anti_halcinatie":,
      "restrictii_de_iesire_din_contex": "Nu adăuga pașii de build sau login încă.",
      "validare": "Fișierul 'deploy-staging.yml' există.",
      "outcome": "Scheletul pipeline-ului de deploy pentru staging este creat.",
      "componenta_de_CI_DI": "Definește pipeline-ul de deploy pentru staging."
    }
  },
F0.2.21
  {
    "F0.2.21": {
      "denumire_task": "Completare Workflow 'deploy-staging.yml' (Build & Push)",
      "descriere_scurta_task": "Adaugă pașii de build și push Docker în 'deploy-staging.yml'.",
      "descriere_lunga_si_detaliata_task": "Completăm workflow-ul de staging. Adăugăm pașii necesari pentru: checkout, setup pnpm, install, setup Docker Buildx, login la GHCR și, cel mai important, rularea 'nx affected -t docker-build'. Vom seta 'base' la 'master' pentru a compara corect branch-ul 'staging' cu 'master'. Imaginile vor fi tag-uite cu 'staging'.",
      "directorul_directoarele": [
        ".github/workflows/"
      ],
      "contextul_taskurilor_anterioare": "F0.2.20: Fișierul 'deploy-staging.yml' a fost creat.",
      "contextul_general_al_aplicatiei": "Automatizarea creării artefactelor de staging (imagini Docker).",
      "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '.github/workflows/deploy-staging.yml'.",
      "restrictii_anti_halcinatie":,
      "restrictii_anti_halcinatie": "Presupunem că ținta 'docker-build' din 'nx.json' (și/sau 'project.json'-ul aplicațiilor) va fi configurată să citească `DOCKER_REGISTRY`, `--push`, `--tag-with-ref` și `--tag-suffix`.",
      "validare": "La un push pe 'staging', pipeline-ul rulează și publică imaginile afectate pe GHCR cu tag-ul 'staging'.",
      "outcome": "Pipeline-ul de build pentru staging este complet și funcțional.",
      "componenta_de_CI_DI": "Pas cheie în CD (Continuous Deployment) către staging."
    }
  },
F0.2.22
  {
    "F0.2.22": {
      "denumire_task": "Creare Fișier Workflow 'deploy-prod.yml'",
      "descriere_scurta_task": "Creează 'deploy-prod.yml' pentru build și push al imaginilor de producție.",
      "descriere_lunga_si_detaliata_task": "Creăm fișierul final de workflow. Acesta va fi responsabil pentru construirea imaginilor Docker de producție. Un model robust este declanșarea acestuia 'on: release: types: [published]', adică *după* ce 'release.yml' a creat cu succes o nouă versiune (tag Git).",
      "directorul_directoarele": [
        ".github/workflows/"
      ],
      "contextul_taskurilor_anterioare": "F0.2.17: Pipeline-ul 'release.yml' este definit.",
      "contextul_general_al_aplicatiei": "Definirea pipeline-ului de CD pentru producție, declanșat de un release oficial.",
      "contextualizarea_directoarelor_si_cailor": "Creează fișierul '/var/www/GeniusSuite/.github/workflows/deploy-prod.yml'.",
      "restrictii_anti_halcinatie":",
        "",
        "jobs:",
        "  build-and-push-prod:",
        "    name: Build and Push Production Images",
        "    runs-on: ubuntu-latest",
        "    steps:",
        "      - name: Checkout Repository",
        "        uses: actions/checkout@v4",
        "        with:",
        "          fetch-depth: 0",
        ""
      ],
      "restrictii_de_iesire_din_contex": "Nu adăuga pașii de build sau login încă.",
      "validare": "Fișierul 'deploy-prod.yml' există.",
      "outcome": "Scheletul pipeline-ului de deploy pentru producție este creat.",
      "componenta_de_CI_DI": "Definește pipeline-ul de deploy pentru producție."
    }
  },
F0.2.23
  {
    "F0.2.23": {
      "denumire_task": "Completare Workflow 'deploy-prod.yml' (Build & Push)",
      "descriere_scurta_task": "Adaugă pașii de build și push Docker în 'deploy-prod.yml' tag-uite cu versiunea.",
      "descriere_lunga_si_detaliata_task": "Completăm workflow-ul de producție. Este similar cu cel de staging, dar cu o diferență cheie: imaginile vor fi tag-uite cu versiunea Git a release-ului (de ex. 'v1.2.3'). Acest tag este disponibil în contextul 'github.ref_name'.",
      "directorul_directoarele": [
        ".github/workflows/"
      ],
      "contextul_taskurilor_anterioare": "F0.2.22: Fișierul 'deploy-prod.yml' a fost creat.",
      "contextul_general_al_aplicatiei": "Automatizarea creării artefactelor de producție (imagini Docker).",
      "contextualizarea_directoarelor_si_cailor": "Modifică fișierul '.github/workflows/deploy-prod.yml'.",
      "restrictii_anti_halcinatie":,
      "restrictii_anti_halcinatie": "Folosește `github.ref_name` pentru a obține tag-ul de release (ex. 'v1.2.3').",
      "validare": "La publicarea unui release, pipeline-ul rulează și publică imaginile afectate pe GHCR cu tag-ul de versiune.",
      "outcome": "Pipeline-ul de build pentru producție este complet și funcțional.",
      "componenta_de_CI_DI": "Pas cheie în CD (Continuous Deployment) către producție."
    }
  },
F0.2.24
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
      "restrictii_anti_halcinatie":,
      "restrictii_de_iesire_din_contex": "Nu face push. Doar comisionează local pe 'dev' și generează descrierea PR/MR.",
      "validare": "Execută 'git log -1'. Commit-ul trebuie să fie vizibil pe branch-ul 'dev'.",
      "outcome": "Toate artefactele F0.2 sunt comisionate local pe 'dev'.",
      "componenta_de_CI_DI": "Acest commit, odată împins și transformat în PR, va declanșa *pentru prima dată* pipeline-ul 'ci.yml'.",
      "PR_MR": {
        "sursa_branch": "dev",
        "destinatie_branch": "master",
        "titlu": "feat(ci): F0.2 - Implementare Pipeline CI/CD (Validation, Release, Docker)",
        "descriere": "Acest PR implementează Faza F0.2, stabilind fundația completă de CI/CD pentru monorepo, bazându-se pe F0.1.\n\n**Schimbări Cheie:**\n\n1.  **CI (Validare PR):**\n    *   S-a creat `.github/workflows/ci.yml`.\n    *   Se declanșează pe Pull Request-uri către `master`, `staging` și `dev`.\n    *   Configurează `pnpm` și caching-ul 'pnpm-store'.\n    *   Folosește `nrwl/nx-set-shas` pentru a detecta corect baza PR-ului.\n    *   Se conectează la Nx Cloud (remote cache).\n    *   Rulează 'nx affected' pentru `format:check`, `lint`, `test` și `build`.\n\n2.  **Versionare Semantică (Changesets):**\n    *   S-a instalat și configurat `@changesets/cli`.\n    *   S-a configurat `.changeset/config.json` pentru `baseBranch: \"master\"`.\n    *   S-a adăugat 'changeset-bot.yml' pentru a valida prezența changesets-urilor în PR-uri.\n\n3.  **CD (Publicare Pachete):**\n    *   S-a creat `.github/workflows/release.yml`, declanșat pe `push` la `master`.\n    *   Job-ul 'publish' validează (lint, test, build), apoi rulează `changeset version` și `pnpm publish -r`.\n    *   Necesită secretele `GH_PAT_TOKEN` (pentru push-ul de versionare) și `NPM_TOKEN` (pentru publicare).\n\n4.  **Containerizare (Docker):**\n    *   S-a creat un `scripts/Dockerfile.base` (multi-stage).\n    *   S-a adăugat o țintă implicită `docker-build` în `nx.json`.\n    *   S-a creat `deploy-staging.yml` (push la `staging`) care construiește și publică imagini `affected` pe GHCR cu tag-ul `staging`.\n    *   S-a creat `deploy-prod.yml` (declanșat `on: release: [published]`) care publică imagini `affected` pe GHCR cu tag-ul de versiune Git (ex. `v1.0.0`)."
      }
    }
  }
F0.3 Observabilitate (skeleton): OTEL collector, Prometheus, Grafana, Loki/Tempo skeleton + dashboards de bază.


F0.4 Orchestrare Docker (hibrid): compose per app + orchestrator root, rețele partajate, Traefik routing.


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


Deliverables: pachete @shared/* publicate intern, acoperire teste ≥70%. 
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




