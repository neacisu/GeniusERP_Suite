# Backing services — sursă unică

**Decizie de facto (28.08.2026):** compose-ul de infrastructură comună **nu mai trăiește în rădăcina repo-ului**.

| Rol | Cale canonică |
| --- | --- |
| PostgreSQL 18.6, Kafka 4.3.1, Temporal 1.31.2 + UI, SuperTokens 12.1.1, OpenBao 2.6.2 | `shared/backing-services/docker-compose.backing-services.yml` |
| Traefik v3.7.12 (edge) | `proxy/compose/docker-compose.yml` |
| Observability (OTEL 0.159.0, Prometheus, Grafana, Loki) | `shared/observability/compose/profiles/compose.dev.yml` |
| Aplicații / CP | `*/compose/docker-compose.yml` per modul |

Fișierul legacy `docker-compose.backing-services.yml` din rădăcină a fost **șters** (split-brain: CI `up` vs `down` pe căi diferite). Planul F0.4 / „orchestrator root” descrie intentul (rețele shared + Traefik + observability), nu un al doilea fișier compose în root.

Job-ul `temporal-schema` aplică schema **core** (`temporal_db`) și **visibility** (`temporal_visibility`). Serverul 1.31.2 (`temporalio/server`, nu `auto-setup` — tag-ul 1.31.2 nu există pe Hub) nu pornește fără: (1) a doua bază, (2) fișierul `temporal/dynamicconfig/docker.yaml` montat la calea default din imagine.

```bash
docker compose -f shared/backing-services/docker-compose.backing-services.yml --env-file .suite.general.env up -d
```

## SuperTokens Core 12 (major, stateful)

Imaginea e `…/supertokens-postgresql:12.1.1`. Upgrade-ul **11.2 → 12.x** pe un volum PostgreSQL existent **nu e drop-in**.

Înainte de primul `up` peste date vechi:

1. **Backup** al bazei `identity_db` (pg_dump).
2. Citește runbook-ul oficial: [SCHEMA-REWORK.md](https://github.com/supertokens/supertokens-core/blob/master/SCHEMA-REWORK.md) și [CUTOVER-PROCEDURE.md](https://github.com/supertokens/supertokens-core/blob/master/docs/CUTOVER-PROCEDURE.md).
3. Core 12.0.0+ schimbă tabelele user (`all_auth_recipe_users` → reservation tables). Cutover-ul e pe `migration_mode`: `LEGACY` → `DUAL_WRITE_READ_OLD` → `DUAL_WRITE_READ_NEW` → `MIGRATED`.
4. Volum **curat** (dev/CI): schema se creează la start; nu e nevoie de cutover.

Nu porni 12.1.1 peste un volum 11.x fără backup + plan de migrare.
