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

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

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

# Verificare că suntem în directorul corect
if [ ! -f "shared/backing-services/docker-compose.backing-services.yml" ]; then
    error "Nu suntem în directorul root al GeniusSuite"
    error "Rulează din rădăcina repo-ului: bash scripts/start-suite.sh"
    exit 1
fi

log "==================================================================="
log "  PORNIRE ORCHESTRATĂ GENIUSSUITE"
log "==================================================================="

# hz2.65: infrastructura de platformă trăiește în /opt. Nu o mai pornim din repo.
if docker network inspect backing >/dev/null 2>&1 && docker inspect postgres >/dev/null 2>&1; then
    log "Detectat host de platformă (rețea backing + postgres). Skip Traefik/Grafana/Postgres/Kafka/Temporal/ST/OpenBao din repo."
    log "Aplicațiile se atașează la traefik_default, observability, backing, data."
    SKIP_PLATFORM_INFRA=1
else
    SKIP_PLATFORM_INFRA=0
fi

if [ "${SKIP_PLATFORM_INFRA:-0}" = "1" ]; then
    log "FAZA 1–3: skip rețele geniuserp_net_* / backing-services / compose.dev.yml (dev-only, nu pe hz2.65)"
else
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

# ============================================================================
# FAZA 2: Pornire Backing Services
# ============================================================================
log "FAZA 2: Pornire Backing Services (PostgreSQL, Kafka, Temporal, SuperTokens)..."

# Încărcăm variabilele de mediu
if [ -f ".backing-services.env" ]; then
    export $(cat .backing-services.env | grep -v '^#' | xargs)
fi
if [ -f ".suite.general.env" ]; then
    export $(cat .suite.general.env | grep -v '^#' | xargs)
fi

# Pornire backing services
docker compose -f shared/backing-services/docker-compose.backing-services.yml --env-file .suite.general.env up -d

log "Așteptăm PostgreSQL să fie ready (30 secunde)..."
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

log "Așteptăm Kafka, Temporal și SuperTokens să pornească (20 secunde)..."
sleep 20

log "✓ Backing Services pornite și funcționale"
echo ""

# ============================================================================
# FAZA 3: Pornire Observability Stack
# ============================================================================
log "FAZA 3: Pornire Observability Stack (Prometheus, Loki, Grafana, OTEL)..."

cd shared/observability/compose/profiles
docker compose -f compose.dev.yml --env-file ./.observability.env up -d
cd "$ROOT"

log "Așteptăm OTEL Collector să fie ready (10 secunde)..."
sleep 10

log "✓ Observability Stack pornit"
echo ""

fi  # SKIP_PLATFORM_INFRA

# ============================================================================
# FAZA 4: Pornire Control Plane Services
# ============================================================================
log "FAZA 4: Pornire Control Plane Services..."

start_compose_build() {
    local service_name=$1
    local service_path=$2
    log "Pornesc $service_name..."
    cd "$ROOT/$service_path"
    local envfile
    envfile=$(find .. -maxdepth 1 -name '.*.env' ! -name '*.example' | head -1 || true)
    if [ -n "${envfile:-}" ]; then
        docker compose --env-file "$ROOT/.suite.general.env" --env-file "$envfile" up -d --build
    else
        docker compose --env-file "$ROOT/.suite.general.env" up -d --build
    fi
    cd "$ROOT"
    sleep 3
}

start_cp_service() {
    start_compose_build "$1" "$2"
}

# Pornire în ordine conform dependențelor
start_cp_service "Identity (Auth Core)" "cp/identity/compose"
sleep 5  # Identity trebuie să fie ready pentru celelalte servicii

start_cp_service "Licensing" "cp/licensing/compose"
start_cp_service "Suite Admin" "cp/suite-admin/compose"
start_cp_service "Suite Shell" "cp/suite-shell/compose"
start_cp_service "Suite Login" "cp/suite-login/compose"
start_cp_service "AI Hub" "cp/ai-hub/compose"
start_cp_service "Analytics Hub" "cp/analytics-hub/compose"

log "Așteptăm toate serviciile CP să pornească complet (15 secunde)..."
sleep 15

log "✓ Control Plane Services pornite"
echo ""

# ============================================================================
# FAZA 5: Aplicații produs (hz2.65)
# ============================================================================
log "FAZA 5: Pornire aplicații produs..."
start_compose_build "Archify" "archify.app/compose"
start_compose_build "Cerniq" "cerniq.app/compose"
start_compose_build "Flowxify" "flowxify.app/compose"
start_compose_build "i-WMS" "i-wms.app/compose"
start_compose_build "Mercantiq" "mercantiq.app/compose"
start_compose_build "Numeriqo" "numeriqo.app/compose"
start_compose_build "Triggerra" "triggerra.app/compose"
start_compose_build "Vettify" "vettify.app/compose"
log "✓ Aplicații produs pornite (gateway și geniuserp.app nu au compose în repo)"
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
log "Acces servicii:"
log "  - Grafana:     http://localhost:3000"
log "  - Prometheus:  http://localhost:9090"
log "  - Temporal UI: http://localhost:8233"
log "  - Identity:    http://localhost:6250"
log "  - Licensing:   http://localhost:6300"
log ""
log "Pentru verificare detalii: docker ps"
log "Pentru logs: docker logs <container_name>"
log "Pentru oprire: bash scripts/stop-suite.sh"
log ""
