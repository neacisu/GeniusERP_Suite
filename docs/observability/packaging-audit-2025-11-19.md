# Observability Packaging Audit — 2025-11-19

## Standalone Apps (`*.app`)

| App | Dockerfile | Compose | Shared build copied? | Observability network/env? | Notes |
| --- | --- | --- | --- | --- | --- |
| archify.app | `archify.app/Dockerfile` | `archify.app/compose/docker-compose.yml` | ✅ `pnpm --filter=@genius-suite/{observability,common,archify.app}` build + deploy copy of `/app/shared`. | ✅ joins `net_observability`, exports OTEL vars + `PORT=${ARCHY_APP_PORT}`. | Rebuilt 2025-11-19, healthy.
| cerniq.app | `cerniq.app/Dockerfile` | `cerniq.app/compose/docker-compose.yml` | ✅ identical build pattern. | ✅ added `PORT=${CERNIQ_APP_PORT}`. | Rebuilt, healthy.
| flowxify.app | `flowxify.app/Dockerfile` | `flowxify.app/compose/docker-compose.yml` | ✅ identical build pattern. | ✅ added `PORT=${FLOWX_APP_PORT}`. | Rebuilt, healthy.
| geniuserp.app | `geniuserp.app/Dockerfile` | `geniuserp.app/compose/docker-compose.yml` | ✅ builder mirrors other apps and copies `/app/shared` + production deps. | ✅ attaches to suite/internal/backing/observability networks, exports OTEL vars + `PORT=${GENERP_APP_PORT}`. | Rebuilt 2025-11-19, healthcheck green.
| i-wms.app | `i-wms.app/Dockerfile` | `i-wms.app/compose/docker-compose.yml` | ✅ identical build pattern. | ✅ added `PORT=${IWMS_APP_PORT}`. | Rebuilt, healthy.
| mercantiq.app | `mercantiq.app/Dockerfile` | `mercantiq.app/compose/docker-compose.yml` | ✅ identical build pattern. | ✅ added `PORT=${MERCQ_APP_PORT}`. | Rebuilt, healthy.
| numeriqo.app | `numeriqo.app/Dockerfile` | `numeriqo.app/compose/docker-compose.yml` | ✅ builder now compiles shared libs before deploy; `PORT=${NUMQ_APP_PORT}` exported. | ✅ | Rebuilt, healthy.
| triggerra.app | `triggerra.app/Dockerfile` | `triggerra.app/compose/docker-compose.yml` | ✅ deploy stage switched to copy built `/app/shared`. | ✅ added `PORT=${TRIGR_APP_PORT}`. | Rebuilt, healthy.
| vettify.app | `vettify.app/Dockerfile` | `vettify.app/compose/docker-compose.yml` | ✅ deploy stage switched to copy built `/app/shared`. | ✅ added `PORT=${VETFY_APP_PORT}`. | Rebuilt, healthy.

## Control-Plane Apps (`cp/*`)

| Service | Dockerfile | Compose | Shared packaging | Observability wiring | Notes |
| --- | --- | --- | --- | --- | --- |
| ai-hub | `cp/ai-hub/Dockerfile` | `cp/ai-hub/compose/docker-compose.yml` | ✅ builder copies entire repo; runtime copies compiled shared tree + node_modules. | ✅ includes `.suite.general.env`, `net_observability`, OTEL vars. | Uses compiled dist.
| analytics-hub | same as ai-hub | same | ✅ | ✅ | —
| identity | `cp/identity/Dockerfile` | same | ✅ multi-stage build (dist + node_modules). | ✅ | —
| licensing | `cp/licensing/Dockerfile` | same | ✅ | ✅ | —
| suite-admin | `cp/suite-admin/Dockerfile` | `cp/suite-admin/compose/docker-compose.yml` | ✅ multi-stage build now copies compiled shared tree and uses production-only deps. | ✅ `.suite.general.env` + OTEL vars present. | Hardened runtime (dist), rebuilt healthy.
| suite-login | `cp/suite-login/Dockerfile` | `cp/suite-login/compose/docker-compose.yml` | ✅ multi-stage build identical to suite-admin (shared dist + prod deps). | ✅ env wiring fixed (`.suite.general.env`, OTEL vars, net_observability). | Hardened runtime (dist), rebuilt healthy.
| suite-shell | `cp/suite-shell/Dockerfile` | `cp/suite-shell/compose/docker-compose.yml` | ✅ multi-stage build identical to suite-admin/login. | ✅ attaches required networks/env. | Hardened runtime (dist), rebuilt healthy.

## Importers of `@genius-suite/observability`

`rg -l "@genius-suite/observability"` (2025-11-19) confirms every standalone app (now including `geniuserp.app`) plus each CP service (`ai-hub`, `analytics-hub`, `identity`, `licensing`, `suite-admin`, `suite-login`, `suite-shell`) depends on the shared observability package. Any image lacking the built `shared/observability/dist` will fail at runtime.

## Immediate Gaps

Packaging parity is complete and the orchestrator + per-app stacks were rebuilt on 2025-11-19 19:24 UTC. `geniuserp.app` now reports healthy; Temporal bootstrap + Supertokens are still cycling until seeded, which matches prior baselines.

## Regression Snapshot — 2025-11-19 19:24 UTC

`docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'`

```text
NAMES                        IMAGE                                                             STATUS
genius-suite-geniuserp-app   compose-geniuserp-app                                             Up (healthy)
genius-suite-shell           compose-suite-shell                                               Up (healthy)
genius-suite-login           compose-suite-login                                               Up (healthy)
genius-suite-admin           compose-suite-admin                                               Up (healthy)
genius-suite-licensing       compose-licensing                                                 Up (healthy)
genius-suite-identity        compose-identity                                                  Up (healthy)
genius-suite-analytics-hub   compose-analytics-hub                                             Up (healthy)
genius-suite-ai-hub          compose-ai-hub                                                    Up (healthy)
genius-suite-vettify-app     compose-vettify-app                                               Up (healthy)
genius-suite-triggerra-app   compose-triggerra-app                                             Up (healthy)
genius-suite-numeriqo-app    compose-numeriqo-app                                              Up (healthy)
genius-suite-mercantiq-app   compose-mercantiq-app                                             Up (healthy)
genius-suite-i-wms-app       compose-i-wms-app                                                 Up (healthy)
genius-suite-flowxify-app    compose-flowxify-app                                              Up (healthy)
genius-suite-cerniq-app      compose-cerniq-app                                                Up (healthy)
genius-suite-archify-app     compose-archify-app                                               Up (healthy)
geniuserp-temporal           temporalio/auto-setup:latest                                      Restarting (bootstrap)
geniuserp-postgres-metrics   quay.io/prometheuscommunity/postgres-exporter:v0.15.0             Up
geniuserp-supertokens        registry.supertokens.io/supertokens/supertokens-postgresql:11.2   Restarting (bootstrap)
geniuserp-postgres           postgres:18                                                       Up (healthy)
traefik                      traefik:v3.0                                                      Up (healthy)
geniussuite-grafana          grafana/grafana-oss:11.1.0                                        Up
geniussuite-otel-collector   otel/opentelemetry-collector:latest                               Up
geniussuite-promtail         grafana/promtail:3.1.1                                            Up
geniussuite-loki             grafana/loki:3.1.1                                                Up
geniussuite-prometheus       prom/prometheus:latest                                            Up
geniussuite-tempo            grafana/tempo:2.5.0                                               Up
geniuserp-temporal-metrics   nginx:1.27-alpine                                                 Up
geniuserp-neo4j-metrics      nginx:1.27-alpine                                                 Up
geniuserp-kafka-metrics      danielqsj/kafka-exporter:v1.7.0                                   Up
geniuserp-kafka              apache/kafka:4.1.0                                                Up (healthy)
geniuserp-neo4j              neo4j:5.23-enterprise                                             Up
```

Every standalone + CP container now exposes `@genius-suite/observability` artifacts and reports healthy (or expected bootstrap) status after the rebuild cycle.
