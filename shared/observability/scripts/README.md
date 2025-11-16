# Observability Scripts - Usage Guide

**Location:** `shared/observability/scripts/`  
**Purpose:** Automatizarea instalării, validării și testării stack-ului de observabilitate pentru GeniusSuite.

---

## 📋 Cuprins

1. [Introducere](#introducere)
2. [Precondiții](#precondiții)
3. [Scripturile](#scripturile)
   - [install.sh](#installsh)
   - [validate.sh](#validatesh)
   - [smoke.sh](#smokesh)
4. [Integrare CI/CD](#integrare-cicd)
5. [Extensii viitoare](#extensii-viitoare)

---

## Introducere

Acest director conține trei scripturi Bash care implementează workflow-ul complet de observabilitate:

- **`install.sh`** - Bootstrap și pornire stack observabilitate
- **`validate.sh`** - Validare conformitate cu strategiile arhitecturale
- **`smoke.sh`** - Teste rapide de sănătate pe toate endpoint-urile

Scripturile sunt concepute pentru a funcționa **autonomous** (fără parametri complecși) și respectă principiul "convention over configuration".

---

## Precondiții

### Sistem de operare
- **Linux** (testat pe Ubuntu 24.04)
- **macOS** (compatibil prin Docker Desktop)
- **Windows** via WSL2

### Dependențe obligatorii
```bash
# Docker (orice versiune suportată)
docker --version  # >= 20.10

# Docker Compose (fie plugin, fie standalone)
docker compose version  # >= v2.0 (plugin)
# sau
docker-compose version  # >= 1.29 (standalone)

# curl (pentru health checks)
curl --version

# bash >= 4.0
bash --version
```

### Structură repository
Scripturile presupun că sunt rulate din directorul `shared/observability/`:

```
/var/www/GeniusSuite/
└── shared/
    └── observability/
        ├── compose/
        │   └── profiles/
        │       └── compose.dev.yml    # Stack-ul de observabilitate
        ├── scripts/
        │   ├── install.sh             # ← Scriptul de instalare
        │   ├── validate.sh            # ← Scriptul de validare
        │   ├── smoke.sh               # ← Scriptul de smoke testing
        │   └── README.md              # ← Acest fișier
        └── ...
```

---

## Scripturile

### `install.sh`

**Rol:** Pornește stack-ul de observabilitate în modul dezvoltare (`dev`) și verifică că serviciile principale sunt operaționale.

#### Usage

```bash
cd /var/www/GeniusSuite/shared/observability
bash scripts/install.sh dev
```

#### Comportament

1. **Verificare precondiții:**
   - Docker instalat
   - Detectează automat `docker compose` (plugin) sau `docker-compose` (standalone)

2. **Validare configurație:**
   - Rulează `docker compose config` pe `compose/profiles/compose.dev.yml`
   - Exit code 1 dacă configurația e invalidă

3. **Pornire servicii:**
   - Rulează `docker compose up -d` pentru stack-ul observabilitate
   - Așteptare 10 secunde pentru stabilizare servicii

4. **Health checks:**
   - Verifică 3 endpoint-uri critice:
     - `http://localhost:3000/api/health` (Grafana)
     - `http://localhost:9090/-/ready` (Prometheus)
     - `http://localhost:3100/ready` (Loki)
   - Timeout: 5 secunde per endpoint

#### Exit Codes

| Code | Semnificație |
|------|--------------|
| `0`  | Succes - toate serviciile pornite |
| `1`  | Docker lipsă sau config invalid |
| `2`  | Mod invalid (doar `dev` suportat în F0.3) |

#### Exemple

```bash
# Instalare standard
./scripts/install.sh dev

# Verificare după instalare
docker ps | grep geniuserp

# Acces Grafana
open http://localhost:3000
```

#### Variabile de mediu opționale

| Variabilă | Default | Descriere |
|-----------|---------|-----------|
| `COMPOSE_FILE` | `compose/profiles/compose.dev.yml` | Calea către fișierul compose |

---

### `validate.sh`

**Rol:** Validare comprehensivă a infrastructurii conform documentelor strategice:
- **Strategii de Fișiere.env și Porturi.md** (Tabelul 4 & 5)
- **Strategie Docker: Volumuri, Rețele și Backup.md** (Tabelul 2.4, 3.5)

#### Usage

```bash
cd /var/www/GeniusSuite/shared/observability
bash scripts/validate.sh
```

#### Categorii de validare

##### 1. **Docker Compose Config**
Verifică că `compose/profiles/compose.dev.yml` este valid sintactic.

##### 2. **Conformitate Porturi** (38 verificări)

**Backing Services (Tabelul 4):**
- PostgreSQL: `5432`
- Kafka: `9092`
- SuperTokens: `3567`
- Temporal: `7233`
- Grafana: `3000`
- Prometheus: `9090`
- Loki: `3100`
- OTEL Collector: *container running* (porturi interne 4317/4318)

**Control Plane (Tabelul 5: 6100-6499):**
- `6100` - suite-shell
- `6150` - suite-admin
- `6200` - suite-login
- `6250` - identity
- `6300` - licensing
- `6350` - analytics-hub
- `6400` - ai-hub

**Stand-alone Apps (Tabelul 5: 6500-6999):**
- `6500` - archify.app
- `6550` - cerniq.app
- `6600` - flowxify.app
- `6650` - i-wms.app
- `6700` - mercantiq.app
- `6750` - numeriqo.app
- `6800` - triggerra.app
- `6850` - vettify.app

##### 3. **Rețele Docker Zero-Trust**
Verifică existența celor 4 rețele conform arhitecturii:
- `geniuserp_net_observability` (monitorizare)
- `geniuserp_net_suite_internal` (API-uri interne)
- `geniuserp_net_backing_services` (DB/Kafka izolat)
- `geniuserp_net_edge` (Traefik public)

##### 4. **Volume Persistente**
Verifică existența volumelor critice pentru protecția datelor:
- `gs_prometheus_data` - TSDB Prometheus
- `gs_loki_data` - Log chunks Loki
- `gs_grafana_data` - Configurare Grafana

##### 5. **Endpoint Health Checks**
Testează 7 endpoint-uri critice cu HTTP 200:
- Grafana `/metrics`
- Prometheus `/-/ready`
- Loki `/ready`
- CP: suite-shell `/health`
- CP: identity `/health`
- archify.app `/health`
- vettify.app `/health`

#### Output

```bash
[validate] Verific docker compose config
  ✓ Docker compose config valid
[validate] Verific conformitatea porturilor cu strategia (Tabelul 4 & 5)
  ✓ PostgreSQL pe portul 5432
  ✓ Kafka pe portul 9092
  # ... (24 servicii)
[validate] Verific existența rețelelor Docker (Model Zero-Trust)
  ✓ Rețea Observability (geniuserp_net_observability) există
  # ... (4 rețele)
[validate] Verific existența volumelor critice (Protecție date)
  ✓ Volum Prometheus-TSDB (gs_prometheus_data) există
  # ... (3 volume)
[validate] Verificare endpoint-uri critice (Health & Metrics)
  ✓ Grafana răspunde HTTP 200
  # ... (7 endpoint-uri)

==========================================
[validate] ✅ VALIDARE COMPLETĂ: Toate verificările au trecut
  - Porturi conforme cu strategia
  - Rețele Docker configurate corect
  - Volume persistente prezente
  - Endpoint-uri operaționale
```

#### Exit Codes

| Code | Semnificație |
|------|--------------|
| `0`  | Toate verificările trecute (100%) |
| `3`  | Una sau mai multe verificări eșuate |

#### Exemple

```bash
# Validare completă
./scripts/validate.sh

# Validare în CI/CD
./scripts/validate.sh || exit 1

# Verificare după rebuild
docker compose up -d --build
./scripts/validate.sh
```

---

### `smoke.sh`

**Rol:** Teste rapide de sănătate (smoke tests) pe **toate** endpoint-urile aplicațiilor pentru verificarea disponibilității.

#### Usage

```bash
cd /var/www/GeniusSuite/shared/observability
bash scripts/smoke.sh
```

#### Endpoint-uri testate (33 total)

##### Observability Stack (4 endpoint-uri)
- Grafana: `/metrics`
- Prometheus: `/-/ready`
- Loki: `/ready`
- *OTEL Collector: nu este testat (porturi interne)*

##### Control Plane (14 endpoint-uri: 7 × 2)
Pentru fiecare serviciu CP:
- `/health` - Health check
- `/metrics` - Prometheus metrics

Servicii:
- suite-shell (6100)
- suite-admin (6150)
- suite-login (6200)
- identity (6250)
- licensing (6300)
- analytics-hub (6350)
- ai-hub (6400)

##### Stand-alone Apps (16 endpoint-uri: 8 × 2)
Pentru fiecare aplicație:
- `/health` - Health check
- `/metrics` - Prometheus metrics

Aplicații:
- archify.app (6500)
- cerniq.app (6550)
- flowxify.app (6600)
- i-wms.app (6650)
- mercantiq.app (6700)
- numeriqo.app (6750)
- triggerra.app (6800)
- vettify.app (6850)

#### Output

```bash
[smoke] Starting comprehensive smoke tests...
[smoke] ================================================
[smoke] ✓ OK   Grafana                            
[smoke] ✓ OK   Prometheus                         
[smoke] ✓ OK   Loki                               
[smoke] ✓ OK   CP:suite-shell                     
[smoke] ✓ OK   CP:suite-shell-metrics             
# ... (33 total endpoint tests)
[smoke] ================================================
[smoke] Rezultat Final: OK=33 FAIL=0 (Total: 33)
```

#### Timeout & Resilience

- **Connection timeout:** 3 secunde
- **Max time per request:** 5 secunde
- **Command timeout:** 5 secunde (via `timeout` command)
- Endpoint-urile eșuate sunt raportate cu HTTP code primit

#### Exit Codes

| Code | Semnificație |
|------|--------------|
| `0`  | Toate endpoint-urile răspund HTTP 200 |
| `4`  | Unul sau mai multe endpoint-uri eșuate |

#### Exemple

```bash
# Smoke test complet
./scripts/smoke.sh

# Smoke test în pipeline
./scripts/smoke.sh && echo "Deploy safe" || echo "Rollback needed"

# Monitorizare periodică
watch -n 30 './scripts/smoke.sh'
```

---

## Integrare CI/CD

### Workflow recomandat

```yaml
# .github/workflows/observability-validation.yml (exemplu)
name: Observability Stack Validation

on:
  push:
    branches: [dev, main]
    paths:
      - 'shared/observability/**'
  pull_request:
    paths:
      - 'shared/observability/**'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Start Observability Stack
        run: |
          cd shared/observability
          bash scripts/install.sh dev
      
      - name: Validate Infrastructure
        run: |
          cd shared/observability
          bash scripts/validate.sh
      
      - name: Run Smoke Tests
        run: |
          cd shared/observability
          bash scripts/smoke.sh
      
      - name: Cleanup
        if: always()
        run: |
          cd shared/observability
          docker compose -f compose/profiles/compose.dev.yml down -v
```

### Pre-commit hook (opțional)

```bash
#!/bin/bash
# .git/hooks/pre-commit

cd shared/observability
./scripts/validate.sh || {
  echo "❌ Validare observabilitate eșuată!"
  exit 1
}
```

---

## Extensii viitoare

### Planificate în faze ulterioare (F0.4+)

- **install.sh:**
  - Support pentru modul `prod` (profile production)
  - Parametru `--clean` pentru cleanup complet
  - Integrare cu HashiCorp Vault pentru secrete

- **validate.sh:**
  - Validare configurații Traefik (când va fi implementat)
  - Verificare conectivitate inter-servicii pe rețelele Zero-Trust
  - Validare backup volumes (când backup-manager va fi implementat)
  - Checks pentru limită resurse (CPU/RAM) per container

- **smoke.sh:**
  - Parametru `--app=<name>` pentru teste selective
  - Output format JSON pentru integrare cu monitoring tools
  - Teste funcționale pe scenarii end-to-end (nu doar health checks)

- **Noi scripturi:**
  - `backup.sh` - Trigger manual backup PostgreSQL volumes
  - `restore.sh` - Restore din backup specific
  - `logs.sh` - Agregare logs din Loki cu filtre

### Limitări cunoscute (F0.3)

- **Doar modul `dev` suportat** - profilele `prod` nu sunt implementate încă
- **Fără parametri de customizare** - convenții over configuration
- **Validarea OTEL** - verifică doar existența containerului, nu conectivitatea
- **Smoke tests** - nu testează logica business, doar disponibilitate HTTP

---

## Troubleshooting

### Problema: `docker: command not found`
**Soluție:** Instalați Docker Desktop sau Docker Engine:
```bash
# Ubuntu/Debian
sudo apt-get install docker.io docker-compose-plugin

# macOS
brew install --cask docker
```

### Problema: `install.sh` raportează servicii "Not ready yet"
**Diagnostic:**
```bash
docker ps  # Verificați statusul containerelor
docker logs geniuserp-prometheus  # Verificați logs
```

**Soluție:** Așteptați 30-60 secunde după pornire, apoi rerulați `validate.sh`.

### Problema: `validate.sh` raportează volume lipsă
**Cauză:** Stack-ul nu a fost pornit cu `install.sh` sau volumele au fost șterse manual.

**Soluție:**
```bash
# Repornire stack pentru recreare volume
cd shared/observability
docker compose -f compose/profiles/compose.dev.yml up -d
bash scripts/validate.sh
```

### Problema: `smoke.sh` raportează multe FAIL
**Diagnostic:**
```bash
# Verificați ce servicii nu rulează
docker ps -a | grep geniuserp

# Testați manual un endpoint
curl -v http://localhost:6100/health
```

**Soluție:** Asigurați-vă că toate serviciile sunt pornite (CP + Apps) înainte de smoke test.

---

## Referințe

- **Planul arhitectural:** `../../Plan/GeniusERP_Suite_Plan_v1.0.5.md`
- **Strategia de porturi:** `../../Plan/Strategii de Fișiere.env și Porturi.md`
- **Strategia Docker:** `../../Plan/Strategie Docker_ Volumuri, Rețele și Backup.md`
- **Compose stack:** `../compose/profiles/compose.dev.yml`

---

**Última actualizare:** 2024-11-13  
**Versiune:** F0.3.60  
**Autor:** GeniusSuite DevOps Team
