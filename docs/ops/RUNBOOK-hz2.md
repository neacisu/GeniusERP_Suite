# Runbook hz2.65 — GeniusERP ca tenant pe platformă

**Host:** hz2.65 (orchestrator / edge)  
**Postgres live:** hz2.124 (`opsgraph-postgres`, privat **`10.10.0.3:5432`**, PGDATA `/mnt/pgdata/18/main`, WAL `/var/lib/postgresql/wal`)  
**Model:** un edge (Traefik pe hz2.65), un Postgres **dedicat** pe hz2.124, un stack de observabilitate, infrastructură stateful în `/opt`. Containerele de pe hz2.65 rezolvă hostname-ul `postgres` → `10.10.0.3` via `extra_hosts`. Traefik TCP `2.29.8.65:5432` → `10.10.0.3:5432`. **Nu** există Postgres Docker pe hz2.65.

**Secrete:** valorile trăiesc în `/opt/platform.env` (mode 600) și în OpenBao KV. Niciodată în git, chat sau acest runbook.

## Unseal OpenBao la reboot

OpenBao folosește raft + Shamir (5 share-uri, prag 3). Cheile stau în `/opt/platform.env` pe același disc cu raft-ul: seal-ul e **mecanism de disponibilitate**, nu protecție a discului. Perimetrul real: SSH, criptare disc, custodia parolei restic (ideal nu pe același disc).

După `docker start` / reboot, unitatea systemd `openbao-unseal.service` (`After=docker.service`) rulează `/opt/openbao/unseal.sh` (mode 700), care aplică 3 chei din `platform.env`.

Verificare:

```bash
systemctl status openbao-unseal.service
docker exec -e BAO_ADDR=http://127.0.0.1:8200 openbao bao status
# Sealed: false, HA Mode: active
```

Manual (dacă unitatea a eșuat): `/opt/openbao/unseal.sh` — nu lista cheile.

Root token nu se păstrează. Administrare: `OPENBAO_ADMIN_TOKEN` (politică `ops-admin`, periodic 768h) din `platform.env`. Dacă e pierdut: `bao operator generate-root` + cheile din `platform.env`, nu re-init (distruge raft-ul).

Cheile și token-urile **nu** se scriu în acest runbook, în git, sau în chat.

## Restore volume (OpenBao / Kafka / Loki / Tempo)

Datele sunt bind pe `/mnt/HC_Volume_106669639/{openbao,kafka,loki,tempo,…}` (**fără** `postgres/` pe hz2.65 după cutover 2026-08-29). Backup zilnic incremental: script `/usr/local/sbin/restic-volume-sb.sh` (nu `restic-hz2-backup.sh`), timer systemd `restic-volume-sb.timer`, repo StorageBox **u655966**, retenție 3 zile. Secret: `RESTIC_NOU_PASSWORD` în `/opt/stacks/.env` și `/opt/secrets/restic-nou.env` — copiază parola **off-host**. Valorile nu stau în acest runbook.

Restore volum hz2.65:

```bash
set -a; . /opt/secrets/restic-nou.env; set +a
restic snapshots
restic restore latest --target /tmp/restore
```

Apoi oprește containerul, copiază din `/tmp/restore/mnt/HC_Volume_106669639/<serviciu>` în loc (UID: OpenBao `100:1000`, Loki/Tempo `10001:10001`, Kafka `1000:1000`), pornește. OpenBao sealed → `systemctl start openbao-unseal`.

## Restore Postgres (cluster dedicat hz2.124)

Live: nativ PostgreSQL 18 pe hz2.124. Backup: restic repo `restic/hz2.124-volume` (PGDATA + WAL), secret pe hostul 124 în `/opt/secrets/restic-nou.env`.

```bash
# pe hz2.124
set -a; . /opt/secrets/restic-nou.env; set +a
restic snapshots
systemctl stop postgresql
restic restore latest --target /tmp/restore
# copiază PGDATA în /mnt/pgdata/18/main, WAL în /var/lib/postgresql/wal,
# symlink pg_wal → /var/lib/postgresql/wal, chown postgres:postgres
systemctl start postgresql
```

Aplicațiile de pe hz2.65: `extra_hosts: ["postgres:10.10.0.3"]` în compose. Traefik: [`/opt/traefik/dynamic/postgres.yml`](/opt/traefik/dynamic/postgres.yml) backend `10.10.0.3:5432`.

**Rollback local Docker pe hz2.65 (doar urgență):** restore directorul `postgres/` din restic hz2.65 (snapshot-uri pre-wipe), `BOOTSTRAP_ALLOW_LOCAL_POSTGRES=1` sau `docker compose --profile local-pg … up -d`, scoate `extra_hosts`, Traefik temporar `127.0.0.1:5432`. Preferă repararea pe hz2.124.

## Temporal / SuperTokens

Compose **nu** pune `/opt/platform.env` ca `env_file` pe serviciu (ar turna cheile OpenBao și `POSTGRES_PASSWORD` superuser în container). Interpolare:

```bash
docker compose --env-file /opt/platform.env -f /opt/temporal/docker-compose.yml up -d --no-deps temporal temporal-ui
docker compose --env-file /opt/platform.env -f /opt/supertokens/docker-compose.yml up -d
```

Variabilele din shell au prioritate față de `--env-file`. Nu lăsa un `source` vechi pe `geniuserp.env`.

Intern, fără Traefik și fără bind pe host. Acces operator:

```bash
docker exec -e TEMPORAL_ADDRESS=temporal:7233 temporal-ui wget -qO- http://127.0.0.1:8080/ || true
# sau un container efemer pe rețeaua backing
```

## Traefik bump 3.7.11 → 3.7.12

Compose: `/opt/traefik/docker-compose.yml`, imagine `traefik:v3.7.12`.

```bash
docker compose --env-file /opt/platform.env -f /opt/traefik/docker-compose.yml config >/dev/null
docker compose --env-file /opt/platform.env -f /opt/traefik/docker-compose.yml up -d
```

Rollback: `image: traefik:v3.7.11` (imagine păstrată local) + același `up -d`.

## Metrici Tabelul 5

API = bază, Prometheus = bază+1, path `/metrics`. Implementare: `startMetricsServer` în `shared/observability` (listener HTTP separat). Job-ul `geniuserp-apps` din `/opt/observability/prometheus/prometheus.yml` scrape-uiește baza+1. Reload: `docker kill -s HUP prometheus`. `gateway` și `geniuserp-app` nu există în repo — rămân down.

## Orchestrare pe hz2.65 (nu `start-suite.sh`)

Pe metal, stack-ul pornește din compose-urile din `/opt/{traefik,openbao,observability,temporal,supertokens,kafka,…}` plus compose-urile din acest repo. `scripts/start-suite.sh` rămâne în git ca unealtă DevX (rețele locale, backing vechi, URL-uri `localhost`) — **nu** e calea de producție după platformizare. `scripts/stop-suite.sh` încă îl citează; nu-l rula pe hz2.65.

## Perimetru 5432 pe hz2.65

UFW e **inactiv** pe hz2.65. Poarta publică `2.29.8.65:5432` e Traefik TCP passthrough + `ipAllowList` (~20 `/32`) din `/opt/traefik/dynamic/postgres.yml`. Confirmă în consola Hetzner Cloud Firewall că există un firewall pe hz2.65 care acoperă măcar SSH (și, ideal, 5432). CLI `hcloud` n-are context/token pe host.

## WAL și disc pe hz2.124

`pg_wal` e symlink spre `/var/lib/postgresql/wal` pe discul **root** (`/dev/sda1`). Umplerea lui `/` oprește clusterul. `prometheus-node-exporter` pe `10.10.0.3:9100`, job Prometheus `node-hz2-124`, alerte `FilesystemFilling85` / `FilesystemFilling92` (același grup ca hz2.65, label `host=hz2.124`).

## Catalog PG arhivat

`/opt/secrets/pg-catalog.env` e leftover de migrare (inventare de roluri, fără parole de cluster live). Arhivat în `/opt/secrets/archive/` — nu-l reintroduce în compose.
