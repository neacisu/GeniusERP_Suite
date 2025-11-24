#!/bin/bash
# ============================================================================
# GeniusSuite - Script de Pornire Orchestrată
# ============================================================================
#
# Acest script pornește toate serviciile GeniusSuite în ordinea corect conform:
# - Tabelul 3: Matricea Rețelelor (Strategii de Fișiere.env și Porturi)
# - Secțiunea 3: Topologia de Rețea (Strategie Docker: Volumuri, Rețele și Backup)
#
# Ordine de pornire:
# 1. Rețele Docker (4 zone de securitate)
# 2. Backing Services (PostgreSQL, Kafka, Temporal, SuperTokens)
# 3. Observability Stack (Prometheus, Loki, Grafana, OTEL)
# 4. Control Plane Services (Identity, Licensing, Admin, Shell, Login, AI-Hub, Analytics-Hub)
#
# ============================================================================

set -e  # Exit on error

# Culori pentru output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funcție pentru logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

ensure_secure_volume() {
    local volume_name=$1
    local uid=$2
    local gid=$3
    local mode=$4

    if ! docker volume inspect "$volume_name" >/dev/null 2>&1; then
        log "Creez volumul $volume_name..."
        docker volume create "$volume_name" >/dev/null
    else
        info "Volumul $volume_name există deja"
    fi

    log "Setez permisiuni ${uid}:${gid} (chmod ${mode}) pentru $volume_name"
    docker run --rm -v "$volume_name":/data alpine:3.20 \
        sh -c "chown -R ${uid}:${gid} /data && chmod ${mode} /data" >/dev/null
}

ROOT_COMPOSE_FILE="compose.yml"
OBS_ENV_FILE="shared/observability/.observability.env"
SUITE_ENV_FILE=".suite.general.env"
BACKING_ENV_FILE=".backing-services.env"

# Verificare că suntem în directorul corect
if [ ! -f "$ROOT_COMPOSE_FILE" ]; then
    error "Nu suntem în directorul root al GeniusSuite (/var/www/GeniusSuite)"
    error "Rulează: cd /var/www/GeniusSuite && bash scripts/start-suite.sh"
    exit 1
fi

if [ ! -f "$ROOT_COMPOSE_FILE" ]; then
    error "Nu am găsit $ROOT_COMPOSE_FILE în rădăcina repo-ului."
    exit 1
fi

log "==================================================================="
log "  PORNIRE ORCHESTRATĂ GENIUSSUITE"
log "==================================================================="

PROXY_ENV_FILE="proxy/.proxy.env"
PROXY_ENV_LOADED=false
OBS_ENV_LOADED=false
SUITE_ENV_LOADED=false
BACKING_ENV_LOADED=false

load_proxy_env() {
    if [ "${PROXY_ENV_LOADED}" = true ]; then
        return
    fi

    if [ ! -f "$PROXY_ENV_FILE" ]; then
        error "Lipsește $PROXY_ENV_FILE. Copiază proxy/.proxy.env.example și actualizează valorile necesare."
        exit 1
    fi

    set -a
    # shellcheck disable=SC1090
    source "$PROXY_ENV_FILE"
    set +a
    PROXY_ENV_LOADED=true
}

load_suite_env() {
    if [ "${SUITE_ENV_LOADED}" = true ]; then
        return
    fi

    if [ ! -f "$SUITE_ENV_FILE" ]; then
        error "Lipsește $SUITE_ENV_FILE. Copiază .suite.general.env.example și actualizează valorile necesare."
        exit 1
    fi

    set -a
    # shellcheck disable=SC1091
    source "$SUITE_ENV_FILE"
    set +a
    SUITE_ENV_LOADED=true
}

load_backing_env() {
    if [ "${BACKING_ENV_LOADED}" = true ]; then
        return
    fi

    if [ ! -f "$BACKING_ENV_FILE" ]; then
        error "Lipsește $BACKING_ENV_FILE. Copiază .backing-services.env.example și configurează secretele pentru DB/Kafka/Temporal."
        exit 1
    fi

    set -a
    # shellcheck disable=SC1091
    source "$BACKING_ENV_FILE"
    set +a
    BACKING_ENV_LOADED=true
}

load_obs_env() {
    if [ "${OBS_ENV_LOADED}" = true ]; then
        return
    fi

    if [ ! -f "$OBS_ENV_FILE" ]; then
        error "Lipsește $OBS_ENV_FILE. Copiază shared/observability/.observability.env.example și configurează valorile pentru stack-ul de observabilitate."
        exit 1
    fi

    set -a
    # shellcheck disable=SC1090
    source "$OBS_ENV_FILE"
    set +a
    OBS_ENV_LOADED=true
}

# ============================================================================
# FAZA 1: Creare Rețele Docker (Dacă nu există deja)
# ============================================================================
log "FAZA 1: Verificare/Creare rețele Docker..."

create_network_if_not_exists() {
    local network_name=$1
    local subnet=$2
    
    if docker network inspect "$network_name" >/dev/null 2>&1; then
        info "Rețeaua $network_name există deja"
    else
        log "Creez rețeaua $network_name (subnet: $subnet)..."
        docker network create --driver bridge --subnet="$subnet" "$network_name"
    fi
}

create_network_if_not_exists "geniuserp_net_edge" "172.20.0.0/16"
create_network_if_not_exists "geniuserp_net_suite_internal" "172.21.0.0/16"
create_network_if_not_exists "geniuserp_net_backing_services" "172.22.0.0/16"
create_network_if_not_exists "geniuserp_net_observability" "172.23.0.0/16"

log "✓ Toate rețelele sunt create"
echo ""

log "FAZA 1.1: Verificare volume sensibile (Archify, Loki)..."
ensure_secure_volume "archify_storage_originals" 1001 1001 750
ensure_secure_volume "gs_loki_data" 10001 10001 770
log "✓ Volumele critice au permisiuni aplicate"
echo ""

# ============================================================================
# FAZA 2: Pornire Proxy (Traefik)
# ============================================================================
log "FAZA 2: Pornire Proxy (Traefik)..."

load_proxy_env

docker compose -f "$ROOT_COMPOSE_FILE" up -d proxy

log "Așteptăm Traefik să devină ready (10 secunde)..."
sleep 10

log \"✓ Proxy pornit\"
echo ""

# ============================================================================
# FAZA 2.5: Pornire și Inițializare OpenBao
# ============================================================================
log "FAZA 2.5: Pornire OpenBao (Secrets Management)..."

load_suite_env

docker compose -f "$ROOT_COMPOSE_FILE" up -d openbao

log "Așteptăm OpenBao să pornească (10 secunde)..."
sleep 10

# Verificare dacă OpenBao este inițializat
if [ ! -f ".secrets/openbao-keys.json" ]; then
    log "OpenBao nu este inițializat. Rulăm openbao-init.sh..."
    bash scripts/security/openbao-init.sh
else
    info "OpenBao este deja inițializat (.secrets/openbao-keys.json există)"
fi

log "✓ OpenBao pornit și inițializat"
echo ""

# ============================================================================
# FAZA 3: Pornire Backing Services
# ============================================================================
log "FAZA 3: Pornire Backing Services (PostgreSQL, Kafka, Temporal, SuperTokens, Neo4j) + Exportere..."

load_suite_env
load_backing_env

docker compose -f "$ROOT_COMPOSE_FILE" up -d postgres_server kafka temporal supertokens-core neo4j \
    postgres-metrics kafka-metrics temporal-metrics neo4j-metrics

log "Așteptăm PostgreSQL să fie ready (15 secunde)..."
sleep 15

# Verificare health PostgreSQL
log "Verificare health PostgreSQL..."
for i in {1..10}; do
    if docker exec geniuserp-postgres pg_isready -U "${SUITE_DB_POSTGRES_USER:-suite_admin}" >/dev/null 2>&1; then
        log "✓ PostgreSQL este ready"
        break
    fi
    if [ $i -eq 10 ]; then
        error "PostgreSQL nu a devenit ready după 50 secunde"
        exit 1
    fi
    sleep 5
done

log "Așteptăm Kafka, Temporal, SuperTokens, Neo4j și exporterele să pornească (20 secunde)..."
sleep 20

log "✓ Backing Services pornite și funcționale"
echo ""

# ============================================================================
# FAZA 4: Pornire Observability Stack
# ============================================================================
log "FAZA 4: Pornire Observability Stack (Prometheus, Loki, Grafana, Tempo, OTEL, Promtail)..."

load_obs_env
docker compose -f "$ROOT_COMPOSE_FILE" up -d otel-collector tempo prometheus grafana loki promtail

log "Așteptăm OTEL Collector să fie ready (10 secunde)..."
sleep 10

log "✓ Observability Stack pornit"
echo ""

# ============================================================================
# FAZA 5: Pornire Control Plane Services
# ============================================================================
log "FAZA 5: Pornire Control Plane Services..."

# Funcție pentru pornirea unui serviciu CP
start_cp_service() {
    local service_name=$1
    local service_path=$2
    local env_file_rel=${3:-}

    log "Pornesc $service_name..."
    pushd "$service_path" >/dev/null

    if [ -n "$env_file_rel" ] && [ -f "$env_file_rel" ]; then
        docker compose --env-file "$env_file_rel" up -d --build
    else
        docker compose up -d --build
    fi

    popd >/dev/null
    sleep 3
}

# Pornire în ordine conform dependențelor
start_cp_service "Identity (Auth Core)" "cp/identity/compose" "../.cp.identity.env"
sleep 5  # Identity trebuie să fie ready pentru celelalte servicii

start_cp_service "Licensing" "cp/licensing/compose" "../.cp.licensing.env"
start_cp_service "Suite Admin" "cp/suite-admin/compose" "../.cp.suite-admin.env"
start_cp_service "Suite Shell" "cp/suite-shell/compose" "../.cp.suite-shell.env"
start_cp_service "Suite Login" "cp/suite-login/compose" "../.cp.suite-login.env"
start_cp_service "AI Hub" "cp/ai-hub/compose" "../.cp.ai-hub.env"
start_cp_service "Analytics Hub" "cp/analytics-hub/compose" "../.cp.analytics-hub.env"

log "Așteptăm toate serviciile CP să pornească complet (15 secunde)..."
sleep 15

log "✓ Control Plane Services pornite"
echo ""

# ============================================================================
# VERIFICARE FINALĂ
# ============================================================================
log "==================================================================="
log "  VERIFICARE STATUS CONTAINERE"
log "==================================================================="

docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep geniuserp

echo ""
log "==================================================================="
log "  ✓ GENIUSSUITE PORNIT CU SUCCES"
log "==================================================================="
log ""
GRAFANA_HOST=${OBS_GRAFANA_DOMAIN:-"grafana.${PROXY_DOMAIN:-geniuserp.app}"}
PROM_HOST=${OBS_PROMETHEUS_DOMAIN:-"prometheus.${PROXY_DOMAIN:-geniuserp.app}"}

log "Acces servicii:"
log "  - Grafana:     https://${GRAFANA_HOST} (Traefik) / http://localhost:${OBS_GRAFANA_PORT:-3000}"
log "  - Prometheus:  https://${PROM_HOST} (Traefik) / http://localhost:${OBS_PROMETHEUS_PORT:-9090}"
log "  - Temporal UI: disponibil doar în net_backing_services"
log "  - Identity:    http://localhost:6250"
log "  - Licensing:   http://localhost:6300"
log ""
log "Pentru verificare detalii: docker ps"
log "Pentru logs: docker logs <container_name>"
log "Pentru oprire: bash scripts/stop-suite.sh"
log ""
