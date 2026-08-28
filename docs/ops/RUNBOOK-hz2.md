# Runbook hz2.65 — GeniusERP ca tenant pe platformă

**Host:** hz2.65  
**Model:** un edge (Traefik), un Postgres, un stack de observabilitate, infrastructură stateful în `/opt`. Suita nu pornește containere de infrastructură.

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

Datele sunt bind pe `/mnt/HC_Volume_106669639/{openbao,kafka,loki,tempo,postgres,…}`. Backup zilnic incremental: restic pe StorageBox **u655966**, retenție 3 zile (`restic-volume-sb.timer`). Secret: `RESTIC_NOU_PASSWORD` în `/opt/stacks/.env` și `/opt/secrets/restic-nou.env` — copiază parola **off-host**. Valorile nu stau în acest runbook.

Restore volum hz2.65:

```bash
set -a; . /opt/secrets/restic-nou.env; set +a
restic snapshots
restic restore latest --target /tmp/restore
```

Apoi oprește containerul, copiază din `/tmp/restore/mnt/HC_Volume_106669639/<serviciu>` în loc (UID: OpenBao `100:1000`, Loki/Tempo `10001:10001`, Kafka `1000:1000`, Postgres Docker `999`), pornește. OpenBao sealed → `systemctl start openbao-unseal`.

hz2.124 (PGDATA + WAL): `/opt/secrets/restic-nou.env` pe acel host, repo `restic/hz2.124-volume`.

## Restore Postgres (baze GeniusERP)

Nu mai există dump-uri `pgdumps/` (jobul vechi spre u382766 e oprit). Restore din snapshot-ul de volum (directorul `postgres/` pe hz2.65) sau din restic de pe hz2.124 pentru clusterul dedicat.

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
