# Raport — rotație secrete, audit, Traefik, aplicații (2026-08-29)

**Host:** hz2.65  
**Secrete:** scrise în `/opt/platform.env` și OpenBao KV. Nicio valoare în acest fișier.

## Făcut

1. **OpenBao rotate-keys** (API `rekey` e 405 în 2.6.2; comanda e `bao operator rotate-keys`, cu token + nonce). 5 share-uri / prag 3, scrise în `platform.env` ca `OPENBAO_UNSEAL_KEY_1..5`.
2. **Barrier rotate** OK. Politică `ops-admin` + token periodic 768h → `OPENBAO_ADMIN_TOKEN`. Root-ul expus în chat e **revocat**.
3. **Parole DB** (14 roluri GeniusERP) + SuperTokens API key + AppRole `secret_id`: regenerate, verificate pe TCP din rețeaua `data`, KV patch, oglindă în `platform.env`.
4. **`/opt/secrets/geniuserp.env` și `approles.env` șterse** (shred). Temporal/ST **nu** folosesc `env_file` pe tot `platform.env` (ar injecta `POSTGRES_PASSWORD` superuser și cheile OpenBao). Interpolare: `docker compose --env-file /opt/platform.env`.
5. **`/opt/openbao/unseal.sh`** (700) + `openbao-unseal.service` (enabled). Restic include `/opt/platform.env`. Parola restic rămâne pe același disc — asumat.
6. **Audit ON** declarativ: dir `/mnt/.../openbao/audit` owner `100:1000`, stanza `audit "file" "file"` cu `options.file_path`. Un ciclu standby la unseal, apoi active + `enabled audit backend path=file/`. Fișierul de audit crește. Healthcheck OpenBao: `BAO_ADDR=http://127.0.0.1:8200` → healthy.
7. **Traefik 3.7.12** live. `acme.json` atașat. `curl -I https://mail.opsgraph.app/` → 307; `https://webmail.opsgraph.app/` → 200. Zero erori ACME în log.
8. **Aplicații:** CP + 8 produse healthy. Prometheus `geniuserp-apps`: **15 up / 2 down**. Down: `gateway` și `geniuserp-app` (nu au compose/Dockerfile în repo).

## Devieri

- Compose interpola din **shell** valorile vechi din `geniuserp.env` (exportate anterior). Unset înainte de `up`.
- Stub-urile servesc `/metrics` pe **portul API**, nu baza+1. Job-ul Prometheus a fost aliniat la portul real.
- Fastify 5: `logger` pino instance → `loggerInstance`.
- Dockerfiles produs: trebuie `pnpm build` pe `shared` + `COPY --from=builder /app/shared` în `deploy`, altfel `ERR_MODULE_NOT_FOUND` pe `@genius-suite/observability/dist`.

## Nu e în git

`/opt` nu e repo. Pe disc: `openbao/`, `temporal/`, `supertokens/`, `traefik/`, `unseal.sh`, unit systemd, `restic-hz2-backup.sh`, `platform.env`.
