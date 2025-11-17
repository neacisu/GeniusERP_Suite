#!/bin/bash
# ============================================================================
# GeniusSuite - Script de Oprire Orchestrată
# ============================================================================
#
# Acest script oprește toate serviciile GeniusSuite în ordine inversă,
# FĂRĂ a șterge volumele (conform Secțiunea 2.2: Strategia de Protecție Date)
#
# Ordine de oprire:
# 1. Control Plane Services
# 2. Observability Stack
# 3. Backing Services
# 4. Rețelele rămân (vor fi refolosite la următoarea pornire)
#
# IMPORTANT: Folosim `docker compose down` FĂRĂ flag-ul `-v`
# pentru a păstra volumele conform strategiei de protecție date.
#
# ============================================================================

set -e  # Exit on error

# Culori pentru output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

ROOT_COMPOSE_FILE="compose.yml"
PROXY_ENV_FILE="proxy/.proxy.env"

# Verificare că suntem în directorul corect
if [ ! -f "$ROOT_COMPOSE_FILE" ]; then
    error "Nu suntem în directorul root al GeniusSuite (/var/www/GeniusSuite)"
    error "Rulează: cd /var/www/GeniusSuite && bash scripts/stop-suite.sh"
    exit 1
fi

log "==================================================================="
log "  OPRIRE ORCHESTRATĂ GENIUSSUITE"
log "==================================================================="

# ============================================================================
# FAZA 1: Oprire Control Plane Services
# ============================================================================
log "FAZA 1: Oprire Control Plane Services..."

stop_cp_service() {
    local service_name=$1
    local service_path=$2
    
    log "Opresc $service_name..."
    cd "$service_path"
    docker compose down  # FĂRĂ -v pentru a păstra datele
    cd /var/www/GeniusSuite
}

stop_cp_service "Analytics Hub" "cp/analytics-hub/compose"
stop_cp_service "AI Hub" "cp/ai-hub/compose"
stop_cp_service "Suite Login" "cp/suite-login/compose"
stop_cp_service "Suite Shell" "cp/suite-shell/compose"
stop_cp_service "Suite Admin" "cp/suite-admin/compose"
stop_cp_service "Licensing" "cp/licensing/compose"
stop_cp_service "Identity" "cp/identity/compose"

log "✓ Control Plane Services oprite"
echo ""

# ============================================================================
# FAZA 2: Oprire Observability Stack
# ============================================================================
log "FAZA 2: Oprire Observability Stack..."

if ! docker compose -f "$ROOT_COMPOSE_FILE" stop otel-collector tempo prometheus grafana loki promtail >/dev/null 2>&1; then
    warning "Stack-ul de observabilitate pare deja oprit."
else
    docker compose -f "$ROOT_COMPOSE_FILE" rm -f otel-collector tempo prometheus grafana loki promtail >/dev/null 2>&1 || true
    log "✓ Observability Stack oprit"
fi

echo ""

# ============================================================================
# FAZA 3: Oprire Backing Services
# ============================================================================
log "FAZA 3: Oprire Backing Services..."

if ! docker compose -f "$ROOT_COMPOSE_FILE" stop postgres_server kafka temporal supertokens-core neo4j \
    postgres-metrics kafka-metrics temporal-metrics neo4j-metrics >/dev/null 2>&1; then
    warning "Backing services par deja oprite."
else
    docker compose -f "$ROOT_COMPOSE_FILE" rm -f postgres_server kafka temporal supertokens-core neo4j \
        postgres-metrics kafka-metrics temporal-metrics neo4j-metrics >/dev/null 2>&1 || true
    log "✓ Backing Services oprite"
fi
echo ""

# ============================================================================
# FAZA 4: Oprire Proxy (Traefik)
# ============================================================================
log "FAZA 4: Oprire Proxy (Traefik)..."

if [ -f "$PROXY_ENV_FILE" ]; then
    set -a
    # shellcheck disable=SC1090
    source "$PROXY_ENV_FILE"
    set +a
fi

if ! docker compose -f "$ROOT_COMPOSE_FILE" stop proxy >/dev/null 2>&1; then
    warning "Nu am reușit să opresc proxy-ul (probabil nu era pornit)."
else
    docker compose -f "$ROOT_COMPOSE_FILE" rm -f proxy >/dev/null 2>&1 || true
    log "✓ Proxy oprit"
fi

echo ""

# ============================================================================
# INFORMAȚII FINALE
# ============================================================================
log "==================================================================="
log "  ✓ GENIUSSUITE OPRIT CU SUCCES"
log "==================================================================="
log ""
info "VOLUMELE AU FOST PĂSTRATE (conform strategiei de protecție date)"
info "Rețelele Docker rămân create pentru următoarea pornire"
log ""
log "Verificare containere rămase:"
docker ps -a | grep geniuserp || echo "Niciun container GeniusSuite activ"
log ""
log "Pentru repornire: bash scripts/start-suite.sh"
log "Pentru curățare completă (ȘTERGE TOATE DATELE): bash scripts/clean-all.sh"
log ""
