# Raport Faza 3 — hz2.65 platformă + tenant GeniusERP

**Data:** 2026-08-29 (UTC 21:xx)  
**Commit:** nu s-a făcut.  
**Restart Traefik/Postgres:** nu s-a făcut.

## Traefik v3.7.12 — așteaptă aprobare

Diff: `/opt/traefik/docker-compose.yml` `image: traefik:v3.7.11` → `traefik:v3.7.12`.  
Rollback: revenire la `traefik:v3.7.11` (imagine locală) + `docker compose --env-file /opt/platform.env -f /opt/traefik/docker-compose.yml up -d`.  
Containerul live rămâne `traefik:v3.7.11` până la acord explicit.

## Tabel serviciu → imagine → rețele → volume → health

| Serviciu | Imagine | Rețele | Volum | Health / notă |
|----------|---------|--------|-------|----------------|
| openbao | openbao/openbao:2.6.2 | backing + observability | platform_openbao_raft → `/mnt/HC_Volume_106669639/openbao` | `bao status` Sealed=false, HA active |
| kafka | apache/kafka:4.3.1 | backing (internal) | platform_kafka_data → `.../kafka` | healthy |
| temporal | temporalio/server:1.31.2 | backing + data + observability | Postgres `temporal` + `temporal_visibility` | Up; schema 1.19 via admin-tools |
| temporal-schema | temporalio/admin-tools:1.31.2 | data | — | Exited 0 (one-shot) |
| temporal-ui | temporalio/ui:2.53.3 | backing | — | intern, fără Traefik |
| supertokens | registry.supertokens.io/supertokens/supertokens-postgresql:12.1.1 | backing + data + observability | Postgres `supertokens` | healthy, GET /hello = Hello |
| loki | grafana/loki:3.7.7 | observability | platform_loki_data → `.../loki` | /ready + push/query OK; wget lipsă în imagine |
| tempo | grafana/tempo:3.0.3 | observability | platform_tempo_data → `.../tempo` | /ready + GET /api/traces/{id} OK |
| otel-collector | otel/opentelemetry-collector-contrib:0.159.0 | observability | — | OTLP 4317/4318 intern; pin 0.159.0 (0.160.0 era nightly) |
| grafana / prometheus | nemodificate ca serviciu | — | — | scrape jobs noi; datasource Loki+Tempo provisioning |
| traefik | live v3.7.11 | — | — | bump 3.7.12 doar în compose |

## Smoke (obligatoriu)

| Test | Rezultat |
|------|----------|
| `bao status` Sealed=false | OK, HA Mode=active |
| Kafka create+produce+consume `hz2-smoke` | OK |
| `temporal operator namespace list` | `temporal-system`; schema curr_version 1.19 |
| SuperTokens GET /hello | `Hello` |
| Loki linie `hz2-smoke` | query_range success |
| Tempo trace `hz2-smoke` | GET `/api/traces/{id}` returnează span `smoke2` |
| Prometheus platform-loki/tempo/otel | **up** |
| Prometheus geniuserp-apps | **down** — aplicațiile nu sunt pornite (așteptat) |
| Prometheus platform-openbao | **403** — metrics necesită auth; vezi devieri |
| `ss` 0.0.0.0 noi din acest lucru | **zero** (fără 8200/9092/3567/8233/15432) |

`ss` pe 0.0.0.0 preexistente (nu din acest task): Traefik 80/443, Stalwart 25/465/587/993/4190, sshd 22. Mail/websites neatins.

## SuperTokens 12.x

Changelog 12.0.0 cere cutover `migration_mode` (LEGACY→…→MIGRATED) **doar pe date 11.x**. Aici baza `supertokens` e **goală** → schema la start, fără pași de migrare.

## OpenBao — predare operator

Init Shamir 5/3 făcut. Cheile și root token-ul **nu** sunt în git. Orfanul din `/opt/stacks/.env` și `.env.validation.json` e înlocuit cu `ROTATED_ORPHAN_CLEARED_2026-08-29`.  
AppRoles per aplicație + KV `secret/<app>/db`. Runtime Temporal/ST citește și `/opt/secrets/geniuserp.env` (mode 600, în afara git) — Docker Compose nu poate porni fără secret la start.

Audit file: API enable respins (OpenBao 2.6 declarative-only). Stanza HCL `audit` a provocat flap HA (lock acquire/release). **Audit nu e activ.** Devieri.

## Fișiere create/modificate

**`/opt`:** `openbao/`, `kafka/`, `temporal/`, `supertokens/`; `observability/{loki,tempo,otel}` + compose + prometheus jobs + grafana datasource; `traefik/docker-compose.yml` (pin, fără up); `/opt/secrets/geniuserp.env`, `approles.env`; restic-hz2-backup.sh; rețea `backing`.

**Repo:** compose-uri aplicație/CP (fără `ports:`, rețele platformă, labels Traefik); `scripts/start-suite.sh`; README; `docs/ENV-IMPLEMENTATION-SUMMARY.md`; Plan porturi addendum; `docs/ops/hz2-baseline-2026-08-28.md`, `RUNBOOK-hz2.md`; markaje pe backing-services / compose.dev.yml / proxy.

## Devieri de la prompt

1. Faza 0 STOP: 9092/3567/8200 ocupate de stack-ul suitei (bind 0.0.0.0). Opriți înainte de creare. Motiv: ocupanții erau duplicatele de înlocuit.
2. Rețeaua `backing` internă pe **172.26.0.0/16** (172.24 se suprapunea cu `geniuserp_net_backing_services`).
3. Volume named + bind pe volumul Hetzner (aliniare restic/postgres existent).
4. OTEL contrib **0.159.0** — ultimul tag stabil GitHub 2026-08-17; 0.160.0 era nightly.
5. Tempo 3.0.3 config: fără `ingester`/`compactor` (eliminate în 3.0); retenție 7z via `backend_scheduler`.
6. Audit OpenBao neactiv (vezi mai sus).
7. Temporal UI intern, fără Traefik (implicit din prompt).
8. Plus baze `geniuserp_db` + `admin_db` (din `POSTGRES_MULTIPLE_DATABASES` al suitei, nu doar cele 10 din Faza 2.4).
9. Job-uri scrape Tabelul 5 incluse; DOWN până pornesc aplicațiile.
10. Traefik 3.7.12 în compose, **fără restart**.
11. `ss` „doar 80/443”: mail+ssh preexistente rămân; nicio publicare nouă.
12. Containerele de produs nu au fost build/up (nu erau cerute ca runtime în Faza 1).
