
## Faza 0.2 — Porturi țintă (verificare live)

| Port | Serviciu așteptat | Stare pe host | Ocupant |
|------|-------------------|---------------|---------|
| 9092 | Kafka intern | OCUPAT 0.0.0.0 | `geniuserp-kafka` (compose `backing-services`, pornit ~minute înainte de Faza 0) |
| 3567 | SuperTokens intern | OCUPAT 0.0.0.0 | `geniuserp-supertokens` |
| 8200 | OpenBao intern | OCUPAT 0.0.0.0 | `geniuserp-openbao` |
| 7233 | Temporal intern | liber | — |
| 3100 | Loki intern | liber | — |
| 3200 | Tempo intern | liber | — |
| 4317/4318 | OTLP intern | liber | — |

**STOP condiție îndeplinită pentru 9092/3567/8200.** Ocupanții sunt stack-ul duplicat al suitei, cu bind pe 0.0.0.0 (interzis). Plus: `geniuserp-postgres` pe `0.0.0.0:15432`, `geniuserp-temporal-ui` pe `0.0.0.0:8233`, `geniuserp-temporal` în Restarting.

**Acțiune:** `docker compose down` pe `shared/backing-services` **înainte** de a crea stack-urile `/opt/*`. Nu e un al doilea Kafka: e același rol, pornit din repo, de mutat pe platformă fără `ports:`.

## Faza 0.3 — OPENBAO_ROOT_TOKEN (valori nearătate)

| Cale | Notă |
|------|------|
| `/opt/stacks/.env:283` | KEY_PRESENT — orfan, de rotit/șters după re-init |
| `/opt/stacks/.env.validation.json:659` | KEY_PRESENT — marcat LIVE 2026-08-21, container absent atunci; nu se refolosește |
| transcript Cursor (2 fișiere jsonl) | mențiuni în istoric chat; nu se refolosesc |

