# Docker Orchestration - GeniusSuite

## 📋 Overview

Acest document descrie arhitectura Docker orchestration pentru GeniusSuite, implementată conform strategiilor din documentația de arhitectură.

## 🏗️ Arhitectură Rețele (Zero-Trust Model)

GeniusSuite folosește 4 zone de rețea izolate conform Tabelul 3:

```text
┌─────────────────────────────────────────────────────────────┐
│  net_edge (172.20.0.0/16)                                   │
│  - Gateway/Proxy (Traefik)                                   │
└─────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│  net_suite_internal (172.21.0.0/16)                         │
│  - CP Services: identity, licensing, ai-hub, etc.            │
└─────────────────────────────────────────────────────────────┘
         │                                │
         ▼                                ▼
┌──────────────────────────┐    ┌────────────────────────────┐
│ net_backing_services     │    │  net_observability         │
│ (172.22.0.0/16)          │    │  (172.23.0.0/16)           │
│ - PostgreSQL             │    │  - Prometheus              │
│ - Kafka                  │    │  - Grafana                 │
│ - Temporal               │    │  - Loki                    │
│ - SuperTokens            │    │  - OTEL Collector          │
└──────────────────────────┘    └────────────────────────────┘
```

### Principii Zero-Trust

- **Backing services** (PostgreSQL, Kafka, etc.) nu sunt expuse pe net_edge
- **CP services** comunică cu backing services DOAR prin net_backing_services
- **Observability** colectează metrici prin net_observability
- **Izolare completă** între zone

## 🌐 Edge Proxy (Traefik)

- **Fișier compose:** `compose.yml` definește serviciul Traefik și volumul persistent `gs_traefik_certs` montat la `/letsencrypt` pentru stocarea ACME (`acme.json`).
- **Config statică/dinamică:** `proxy/traefik/traefik.yml` stabilește entrypoints (80/443/8080/9100) și `proxy/traefik/dynamic/middlewares.yml` oferă middleware-uri (security headers, rate limit, basic-auth chain pentru dashboard).
- **Fișier env:** copiați `proxy/.proxy.env.example` în `proxy/.proxy.env`, setați `PROXY_DOMAIN`, `PROXY_DASHBOARD_DOMAIN`, `PROXY_DASHBOARD_USER/PASS`, email ACME și, opțional, token-urile DNS provider.
- **Pornire manuală:**

  ```bash
  set -a && source proxy/.proxy.env && set +a
  docker compose -f compose.yml up -d proxy
  ```
  
  Scriptul `scripts/start-suite.sh` rulează acest pas în FAZA 2, generează hash-ul BasicAuth (folosind `openssl passwd -apr1`) în `proxy/traefik/secrets/dashboard-users` și expune dashboard-ul doar pe `PROXY_DASHBOARD_DOMAIN` via entrypoint `traefik` (localhost:8080).
- **Observabilitate:** Traefik expune metrice Prometheus pe entrypoint `metrics` (9100) din `geniuserp_net_observability`, iar Prometheus le colectează prin job-ul `traefik`.

### Validare rapidă Traefik

```bash
# container up & sănătos
docker compose -f compose.yml ps proxy

# redirect HTTP→HTTPS (folosește porturile din PROXY_HTTP/HTTPS_PORT)
curl -I -H "Host: identity.${PROXY_DOMAIN}" http://127.0.0.1:${PROXY_HTTP_PORT}

# dashboard protejat (SNI + basic-auth)
curl -k -u "$PROXY_DASHBOARD_USER:$PROXY_DASHBOARD_PASS" \
  --resolve "${PROXY_DASHBOARD_DOMAIN}:${PROXY_DASHBOARD_PORT}:127.0.0.1" \
  https://${PROXY_DASHBOARD_DOMAIN}:${PROXY_DASHBOARD_PORT}/dashboard/ -o /dev/null -w '%{http_code}\n'

# Prometheus metrics (din interiorul rețelei observability)
docker exec traefik wget -qO- http://localhost:9100/metrics | head -n 10

# verifică persistența acme.json
docker exec traefik ls -l /letsencrypt
```

## 🚀 Pornire Infrastructure

### Comandă Rapidă

```bash
cd /var/www/GeniusSuite
bash scripts/start-suite.sh
```

### Ordine de Pornire Manuală

#### 1. **Creare Rețele**

```bash
docker network create --driver bridge --subnet 172.20.0.0/16 geniuserp_net_edge
docker network create --driver bridge --subnet 172.21.0.0/16 geniuserp_net_suite_internal
docker network create --driver bridge --subnet 172.22.0.0/16 geniuserp_net_backing_services
docker network create --driver bridge --subnet 172.23.0.0/16 geniuserp_net_observability
```

#### 2. **Pornire Proxy (Traefik)**

```bash
cd /var/www/GeniusSuite
cp proxy/.proxy.env.example proxy/.proxy.env  # doar prima dată, apoi actualizează valorile reale
set -a && source proxy/.proxy.env && source shared/observability/.observability.env && set +a
docker compose -f compose.yml up -d proxy
```

> Notă: `gs_traefik_certs` păstrează `acme.json`. Scriptul `scripts/start-suite.sh` regenerează fișierul BasicAuth în `proxy/traefik/secrets/dashboard-users` înainte de fiecare pornire.

#### 3. **Pornire Backing Services**

```bash
cd /var/www/GeniusSuite
docker compose -f docker-compose.backing-services.yml up -d
```

Verifică healthy status:

```bash
docker ps --filter name=geniuserp --format 'table {{.Names}}\t{{.Status}}'
```

Așteptat: 4 containere (postgres, kafka, temporal, supertokens)

#### 4. **Pornire Observability Stack**

```bash
cd /var/www/GeniusSuite
set -a && source shared/observability/.observability.env && set +a
docker compose -f compose.yml up -d otel-collector tempo prometheus grafana loki promtail
```

Accesare UI:

- **Grafana**: `http://localhost:3000 (admin/admin)`
- **Prometheus**: `http://localhost:9090`
- **Temporal UI**: `http://localhost:8233`

#### 5. **Pornire CP Services**

⚠️ **IMPORTANT**: Environment variables trebuie încărcate înainte de build/start:

```bash
cd /var/www/GeniusSuite

# Identity
set -a && source .suite.general.env && source cp/identity/.cp.identity.env && set +a
docker compose -f cp/identity/compose/docker-compose.yml up -d

# Licensing
set -a && source .suite.general.env && source cp/licensing/.cp.licensing.env && set +a
docker compose -f cp/licensing/compose/docker-compose.yml up -d

# AI Hub
set -a && source .suite.general.env && source cp/ai-hub/.cp.ai-hub.env && set +a
docker compose -f cp/ai-hub/compose/docker-compose.yml up -d

# Analytics Hub
set -a && source .suite.general.env && source cp/analytics-hub/.cp.analytics-hub.env && set +a
docker compose -f cp/analytics-hub/compose/docker-compose.yml up -d
```

## 🛑 Oprire Infrastructure

### 1. Comandă Rapidă

```bash
cd /var/www/GeniusSuite
bash scripts/stop-suite.sh
```

### 2. Oprire Manuală (Ordine Inversă)

```bash
# CP Services
docker compose -f cp/analytics-hub/compose/docker-compose.yml down
docker compose -f cp/ai-hub/compose/docker-compose.yml down
docker compose -f cp/licensing/compose/docker-compose.yml down
docker compose -f cp/identity/compose/docker-compose.yml down

# Observability
cd /var/www/GeniusSuite
set -a && source shared/observability/.observability.env && set +a
docker compose -f compose.yml stop otel-collector tempo prometheus grafana loki promtail
docker compose -f compose.yml rm -f otel-collector tempo prometheus grafana loki promtail

# Backing Services
cd /var/www/GeniusSuite
docker compose -f docker-compose.backing-services.yml down
```

⚠️ **NU folosiți `-v` flag** - volumele sunt externe și trebuie păstrate!

## 🔄 Rebuild Serviciu (Fără Pierdere Date)

### Exemplu: Rebuild Identity Service

```bash
cd /var/www/GeniusSuite

# 1. Stop containerul
docker compose -f cp/identity/compose/docker-compose.yml down

# 2. Build nou (cu env variables)
set -a && source .suite.general.env && source cp/identity/.cp.identity.env && set +a
docker compose -f cp/identity/compose/docker-compose.yml build

# 3. Start cu noua imagine
docker compose -f cp/identity/compose/docker-compose.yml up -d

# 4. Verifică logs
docker logs genius-suite-identity --tail 50
```

### Protecție Date

Datele persistă datorită **volumelor externe**:

- `gs_pgdata_*` - Baze de date PostgreSQL
- `gs_kafka_data` - Kafka topics
- `geniuserp_loki_data` - Loki logs

Acestea sunt definite cu `external: true` în compose files, deci nu se șterg la `docker compose down`.

## 🏥 Health Checks

### Verificare Status Complet

```bash
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
```

### Așteptat: 16 Containere

- **4 Backing**: postgres, kafka, temporal, supertokens
- **5 Observability**: prometheus, grafana, loki, promtail, otel-collector
- **7 CP Services**: identity, licensing, suite-admin, suite-shell, suite-login, ai-hub, analytics-hub

### Test Endpoints

```bash
# PostgreSQL
docker exec geniuserp-postgres pg_isready -U suite_admin

# Identity API
curl http://localhost:6250/health

# Licensing API
curl http://localhost:6300/health

# AI Hub
curl http://localhost:6400/health

# Analytics Hub
curl http://localhost:6350/health

# Grafana
curl http://localhost:3000/api/health
```

## 🔧 Troubleshooting

### 1. Container "unhealthy"

```bash
# Verifică health check logs
docker inspect <container_name> --format '{{json .State.Health}}' | jq

# Verifică logs aplicație
docker logs <container_name> --tail 100
```

**Cauze frecvente:**

- Health check folosește `localhost` în loc de `127.0.0.1` (alpine DNS issue)
- Port greșit în health check test
- Aplicația nu e ready în timpul `start_period`

### 2. "invalid proto:" Error

Cauză: Referințe `depends_on` către servicii din alte compose files.

**Fix**: Eliminat toate `depends_on` pentru servicii externe. Orchestrarea se face manual prin scripts/start-suite.sh.

### 3. PostgreSQL "POSTGRES_PASSWORD not specified"

Cauză: Variable substitution `${VAR}` nu funcționează în CONNECTION_URI.

**Fix**: Folosit parametri separați:

```yaml
POSTGRESQL_HOST: postgres_server
POSTGRESQL_PORT: 5432
POSTGRESQL_USER: suite_admin
POSTGRESQL_PASSWORD: ${SUITE_DB_POSTGRES_PASS:-ChangeThisPostgresPassword}
POSTGRESQL_DATABASE_NAME: identity_db
```

### 4. Kafka "unhealthy"

Cauză: Health check script nu e în PATH.

**Fix**: Folosit full path:

```yaml
healthcheck:
  test: ["CMD-SHELL", "/opt/kafka/bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092"]
```

### 5. SuperTokens connection error

Cauză: Baza de date `identity_db` nu există (PostgreSQL nu creează automat bazele multiple).

**Fix**: Create manual:

```bash
docker exec geniuserp-postgres psql -U suite_admin -d postgres -c "CREATE DATABASE identity_db;"
```

### 6. Environment variables nu se încarcă

Cauză: Docker Compose nu încarcă automat .env files la build.

**Fix**: Source explicit înainte de comenzi:

```bash
set -a && source .suite.general.env && source cp/service/.cp.service.env && set +a
docker compose -f cp/service/compose/docker-compose.yml build
```

### 7. OTEL Collector connection refused

Cauză: OTEL încearcă să se conecteze la Tempo (care nu există).

**Status**: Non-blocker - serviciile funcționează fără tracing complet.

## 📊 Porturi Alocate (Tabelul 4 & 5)

### Backing Services

| Service | Port | Protocol |
|---------|------|----------|
| PostgreSQL | 5432 | TCP |
| Kafka | 9092 | TCP |
| Temporal | 7233 | gRPC |
| Temporal UI | 8233 | HTTP |
| SuperTokens | 3567 | HTTP |

### Observability

| Service | Port | Protocol |
|---------|------|----------|
| Prometheus | 9090 | HTTP |
| Grafana | 3000 | HTTP |
| Loki | 3100 | HTTP |
| OTEL gRPC | 4317 | gRPC |
| OTEL HTTP | 4318 | HTTP |

### Control Plane Services

| Service | Port | Range | Status |
|---------|------|-------|--------|
| Suite Shell | 6100 | 6100-6149 | ✅ Operational |
| Suite Admin | 6150 | 6150-6199 | ✅ Operational |
| Suite Login | 6200 | 6200-6249 | ✅ Operational |
| Identity | 6250 | 6250-6299 | ✅ Operational |
| Licensing | 6300 | 6300-6349 | ✅ Operational |
| Analytics Hub | 6350 | 6350-6399 | ✅ Operational |
| AI Hub | 6400 | 6400-6449 | ✅ Operational |

## 📚 Referințe Strategii

- **Tabelul 2.4**: Volume management strategy
- **Tabelul 3**: Network architecture (4 zones)
- **Tabelul 3.5**: Service-to-network mapping
- **Tabelul 4**: Infrastructure ports allocation
- **Tabelul 5**: Application ports allocation
- **Secțiunea 2.2**: Data protection strategy

## ⚠️ Troubleshooting Archive

### Historical Issues (RESOLVED ✅)

#### Historical Issue 1: Container "unhealthy" - Health check alpine DNS

- **Cauză**: Health check folosește `localhost` în loc de `127.0.0.1` (alpine DNS issue)
- **Fix**: ✅ Toate health checks actualizate să folosească `127.0.0.1` și CMD-SHELL format

```yaml
healthcheck:
  test: ["CMD-SHELL", "wget -qO- http://127.0.0.1:6250/health || exit 1"]
```

#### Historical Issue 2: "invalid proto:" error

- **Cauză**: Referințe `depends_on` către servicii din alte compose files
- **Fix**: ✅ Eliminat toate `depends_on` pentru servicii externe; orchestrarea se face manual prin `scripts/start-suite.sh`

#### Historical Issue 3: PostgreSQL "POSTGRES_PASSWORD not specified"

- **Cauză**: Variable substitution `${VAR}` nu funcționează în CONNECTION_URI
- **Fix**: ✅ Folosit parametri separați

```yaml
POSTGRESQL_HOST: postgres_server
POSTGRESQL_PORT: 5432
POSTGRESQL_USER: suite_admin
POSTGRESQL_PASSWORD: ${SUITE_DB_POSTGRES_PASS:-ChangeThisPostgresPassword}
POSTGRESQL_DATABASE_NAME: identity_db
```

#### Historical Issue 4: Kafka "unhealthy"

- **Cauză**: Health check script nu e în PATH
- **Fix**: ✅ Folosit full path

```yaml
healthcheck:
  test: ["CMD-SHELL", "/opt/kafka/bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092"]
```

#### Historical Issue 5: SuperTokens connection error

- **Cauză**: Baza de date `identity_db` nu există (PostgreSQL nu creează automat bazele multiple)
- **Fix**: ✅ Creat manual

```bash
docker exec geniuserp-postgres psql -U suite_admin -d postgres -c "CREATE DATABASE identity_db;"
```

#### Historical Issue 6: Dockerfile pnpm installation failures (suite-admin/shell/login)

- **Cauză**: Scriptul `wget` pentru instalarea pnpm a eșuat în containere alpine
- **Fix**: ✅ Înlocuit cu `npm install -g pnpm`

```dockerfile
RUN npm install -g pnpm
ENV PATH="/usr/local/bin:$PATH"
RUN pnpm install --frozen-lockfile
```

#### Historical Issue 7: OTEL Collector connection refused + Tempo errors

- **Cauză**: OTEL încerca să se conecteze la Tempo (inexistent) și folosea exporter-ul `logging` depreciat
- **Fix**: ✅ Tempo exporter a fost comentat, `logging` a fost înlocuit cu `debug`

```yaml
exporters:
  debug:
    verbosity: detailed
  prometheus:
    endpoint: "0.0.0.0:8889"

service:
  pipelines:
    traces:
      exporters: [debug]
    metrics:
      exporters: [prometheus, debug]
```

Result: OTEL ascultă pe 4317/4318, iar CP services se conectează cu succes.

#### Historical Issue 8: Temporal gRPC connection warnings

- **Cauză**: Temporal asculta doar pe observability network IP, nu pe `0.0.0.0`
- **Fix**: ✅ Adăugat variabila de mediu `BIND_ON_IP=0.0.0.0`

```yaml
environment:
  - BIND_ON_IP=0.0.0.0
```

Result: Licensing → Temporal gRPC connection successful (test cu `nc -zv temporal 7233`).

## 🎯 Current Status

✅ **ALL SYSTEMS OPERATIONAL** - 16/16 containere funcționale

**Infrastructure Complete:**

- ✅ 4 Backing Services (postgres, kafka, temporal, supertokens) - toate healthy
- ✅ 5 Observability Services (prometheus, grafana, loki, promtail, otel-collector) - toate funcționale
- ✅ 7 Control Plane Services - toate healthy pe porturile alocate

**Connectivity Verified:**

- ✅ CP → PostgreSQL
- ✅ CP → Kafka
- ✅ CP → OTEL Collector (4317 gRPC)
- ✅ Licensing → Temporal (7233 gRPC)
- ✅ Zero-Trust architecture (net_edge izolat)

**Data Persistence Verified:**

- ✅ PostgreSQL volumes persist through container rebuild
- ✅ External volumes strategy funcționează conform Tabelul 2.4

## 🎯 Next Steps

1. ~~Fix Dockerfiles pentru suite-admin/shell/login~~ ✅ COMPLETE
2. ~~Configure OTEL Collector să accepte traces fără Tempo backend~~ ✅ COMPLETE  
3. ~~Fix Temporal gRPC binding~~ ✅ COMPLETE
4. Add application-level metrics collection în toate CP services
5. Implement graceful shutdown în stop-suite.sh (wait for drain)
6. Add backup/restore scripts pentru PostgreSQL volumes
7. Deploy Tempo backend pentru distributed tracing (optional)

---

**Versiune**: 2.0  
**Data**: 2025-11-13  
**Status**: ✅ ALL SYSTEMS OPERATIONAL - 16/16 containere
