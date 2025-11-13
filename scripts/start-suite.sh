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

# Verificare că suntem în directorul corect
if [ ! -f "docker-compose.backing-services.yml" ]; then
    error "Nu suntem în directorul root al GeniusSuite (/var/www/GeniusSuite)"
    error "Rulează: cd /var/www/GeniusSuite && bash scripts/start-suite.sh"
    exit 1
fi

log "==================================================================="
log "  PORNIRE ORCHESTRATĂ GENIUSSUITE"
log "==================================================================="

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
docker compose -f docker-compose.backing-services.yml --env-file .suite.general.env up -d

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
docker compose -f compose.dev.yml --env-file ../../.observability.env up -d
cd /var/www/GeniusSuite

log "Așteptăm OTEL Collector să fie ready (10 secunde)..."
sleep 10

log "✓ Observability Stack pornit"
echo ""

# ============================================================================
# FAZA 4: Pornire Control Plane Services
# ============================================================================
log "FAZA 4: Pornire Control Plane Services..."

# Funcție pentru pornirea unui serviciu CP
start_cp_service() {
    local service_name=$1
    local service_path=$2
    
    log "Pornesc $service_name..."
    cd "$service_path"
    docker compose up -d --build
    cd /var/www/GeniusSuite
    sleep 3
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
