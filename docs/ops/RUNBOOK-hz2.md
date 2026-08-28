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

Datele sunt bind pe `/mnt/HC_Volume_106669639/{openbao,kafka,loki,tempo}`. Restore:

1. Oprește containerul (`docker compose -f /opt/<serviciu>/docker-compose.yml stop`).
2. `restic restore <snapshot> --target /tmp/restore --include /mnt/HC_Volume_106669639/<serviciu>`
3. Copiază în loc, păstrează UID: OpenBao `100:1000`, Loki/Tempo `10001:10001`, Kafka `1000:1000`.
4. Pornește containerul. OpenBao va fi sealed → `systemctl start openbao-unseal` (sau `/opt/openbao/unseal.sh`).

Disaster-recovery secrete: restic include `/opt/platform.env` (repo criptat). **Parola restic trebuie să existe și off-host** (password manager / telefon). Dacă trăiește doar pe hz2.65, moartea mașinii face arhivele indescifrabile — backupul e atunci decor. Copiază `RESTIC_PASSWORD` (ideal și `platform.env`) într-un singur loc din afara discului. Valorile nu stau în acest runbook.

Definiția platformei (fără git pe `/opt`): restic acoperă și `/opt/{openbao,temporal,supertokens,kafka,observability,traefik}` (compose, `unseal.sh`, HCL) plus `/etc/systemd/system/openbao-unseal.service`. Volumele de date rămân pe `/mnt/HC_Volume_106669639/{openbao,kafka,loki,tempo}`.

## Restore Postgres (baze GeniusERP)

Dump-uri zilnice: `/mnt/HC_Volume_106669639/pgdumps/geniuserp/<db>.dump` (custom format), retenție 7 zile în director + restic `keep-daily 7 keep-weekly 4`.

```bash
docker exec -i postgres pg_restore -U postgres -d <db> --clean --if-exists < /mnt/HC_Volume_106669639/pgdumps/geniuserp/<db>.dump
```

Baze: `temporal`, `temporal_visibility`, `supertokens`, `identity_db`, `licensing_db`, `archify_db`, `cerniq_db`, `flowxify_db`, `iwms_db`, `mercantiq_db`, `numeriqo_db`, `triggerra_db`, `vettify_db`, `geniuserp_db`, `admin_db`.

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
