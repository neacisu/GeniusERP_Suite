#!/usr/bin/env bash
set -euo pipefail

# Default CI_MODE to false if not set
CI_MODE=${CI_MODE:-false}

if docker compose version >/dev/null 2>&1; then DC=(docker compose); else DC=(docker-compose); fi
COMPOSE_FILE=${COMPOSE_FILE:-"compose/profiles/compose.dev.yml"}

step() { echo "[validate] $1"; }
check_fail() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); FAILURES+=("$1"); }
check_ok() { echo "  ✓ $1"; }

FAIL=0
FAILURES=()

# ==========================================
# 1. VERIFICARE DOCKER COMPOSE CONFIG
# ==========================================
step "Verific docker compose config"
if ${DC[@]} -f "${COMPOSE_FILE}" config >/dev/null 2>&1; then
  check_ok "Docker compose config valid"
else
  check_fail "Docker compose config INVALID"
fi

# ==========================================
# 2. VERIFICARE CONFORMITATE PORTURI
#    Conform "Strategii de Fișiere.env și Porturi.md"
# ==========================================
step "Verific conformitatea porturilor cu strategia (Tabelul 4 & 5)"

# Tabelul 4: Servicii de bază (Backing Services)
BACKING_SERVICES_PORTS=(
  "5432|PostgreSQL"
  "9092|Kafka"
  "3567|SuperTokens"
  "7233|Temporal"
  "3000|Grafana"
  "9090|Prometheus"
  "3100|Loki"
)

for port_check in "${BACKING_SERVICES_PORTS[@]}"; do
  port="${port_check%%|*}"
  service="${port_check##*|}"
  
  if docker ps --format "{{.Ports}}" | grep -q ":$port->"; then
    check_ok "$service pe portul $port"
  else
    check_fail "$service LIPSĂ sau pe port greșit (așteptat: $port)"
  fi
done

# Verificare specială OTEL (containerul rulează, dar fără port mapping extern)
if docker ps --format "{{.Names}}" | grep -q "geniuserp-otel-collector"; then
  check_ok "OTEL Collector container activ (porturi interne 4317/4318)"
else
  check_fail "OTEL Collector container NU rulează"
fi

# Tabelul 5: Control Plane (6100-6499)
CP_PORTS=(
  "6100|CP:suite-shell"
  "6150|CP:suite-admin"
  "6200|CP:suite-login"
  "6250|CP:identity"
  "6300|CP:licensing"
  "6350|CP:analytics-hub"
  "6400|CP:ai-hub"
)

for port_check in "${CP_PORTS[@]}"; do
  port="${port_check%%|*}"
  service="${port_check##*|}"
  
  if docker ps --format "{{.Ports}}" | grep -q ":$port->"; then
    check_ok "$service pe portul $port"
  else
    check_fail "$service LIPSĂ sau pe port greșit (așteptat: $port)"
  fi
done

# Tabelul 5: Stand-alone Apps (6500-6999)
# Skip in CI mode
if [[ "${CI_MODE}" != "true" ]]; then
  APP_PORTS=(
    "6500|archify.app"
    "6550|cerniq.app"
    "6600|flowxify.app"
    "6650|i-wms.app"
    "6700|mercantiq.app"
    "6750|numeriqo.app"
    "6800|triggerra.app"
    "6850|vettify.app"
  )

  for port_check in "${APP_PORTS[@]}"; do
    port="${port_check%%|*}"
    app="${port_check##*|}"
    
    if docker ps --format "{{.Ports}}" | grep -q ":$port->"; then
      check_ok "$app pe portul $port"
    else
      check_fail "$app LIPSĂ sau pe port greșit (așteptat: $port)"
    fi
  done
fi

# ==========================================
# 3. VERIFICARE REȚELE DOCKER
#    Conform "Strategie Docker: Volumuri, Rețele și Backup.md"
# ==========================================
step "Verific existența rețelelor Docker (Model Zero-Trust)"

REQUIRED_NETWORKS=(
  "geniuserp_net_observability|Observability"
  "geniuserp_net_suite_internal|API-Intern"
  "geniuserp_net_backing_services|Backing-Services"
  "geniuserp_net_edge|Edge-Public"
)

for net_check in "${REQUIRED_NETWORKS[@]}"; do
  net="${net_check%%|*}"
  label="${net_check##*|}"
  
  if docker network ls --format "{{.Name}}" | grep -q "^${net}$"; then
    check_ok "Rețea $label ($net) există"
  else
    check_fail "Rețea $label ($net) LIPSĂ"
  fi
done

# ==========================================
# 4. VERIFICARE VOLUME PERSISTENTE
#    Conform "Strategie Docker: Volumuri, Rețele și Backup.md" (Tabelul 2.4)
# ==========================================
step "Verific existența volumelor critice (Protecție date)"

CRITICAL_VOLUMES=(
  "gs_prometheus_data|Prometheus-TSDB"
  "gs_loki_data|Loki-Logs"
  "gs_grafana_data|Grafana-Config"
)

for vol_check in "${CRITICAL_VOLUMES[@]}"; do
  vol="${vol_check%%|*}"
  label="${vol_check##*|}"
  
  if docker volume ls --format "{{.Name}}" | grep -q "^${vol}$"; then
    check_ok "Volum $label ($vol) există"
  else
    check_fail "Volum $label ($vol) LIPSĂ - RISC PIERDERE DATE"
  fi
done

# ==========================================
# 5. VERIFICARE ENDPOINT-URI CRITICE (HEALTH)
# ==========================================
step "Verificare endpoint-uri critice (Health & Metrics)"
test_endpoint() {
  local url=$1
  local name=$2
  http_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" || echo "000000")
  if [[ "$http_code" == "200" ]]; then
    check_ok "$name răspunde HTTP 200"
  else
    check_fail "$name FAIL (HTTP $http_code)"
  fi
}

test_endpoint "http://localhost:3000/api/health" "Grafana"
test_endpoint "http://localhost:9090/-/healthy" "Prometheus"
test_endpoint "http://localhost:3100/ready" "Loki"
test_endpoint "http://localhost:6100/health" "CP:suite-shell"
test_endpoint "http://localhost:6250/health" "CP:identity"
test_endpoint "http://localhost:6500/health" "archify.app"
test_endpoint "http://localhost:6850/health" "vettify.app"

CRITICAL_ENDPOINTS=(
  "http://localhost:3000/metrics|Grafana"
  "http://localhost:9090/-/ready|Prometheus"
  "http://localhost:3100/ready|Loki"
  "http://localhost:6100/health|CP:suite-shell"
  "http://localhost:6250/health|CP:identity"
  "http://localhost:6500/health|archify.app"
  "http://localhost:6850/health|vettify.app"
)

for endpoint in "${CRITICAL_ENDPOINTS[@]}"; do
  url="${endpoint%%|*}"
  label="${endpoint##*|}"
  
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 3 --max-time 5 "$url" 2>/dev/null || echo "000")
  
  if [[ "$HTTP_CODE" == "200" ]]; then
    check_ok "$label răspunde HTTP 200"
  else
    check_fail "$label FAIL (HTTP $HTTP_CODE)"
  fi
done

# ==========================================
# RAPORT FINAL
# ==========================================
echo ""
echo "=========================================="
if [[ $FAIL -eq 0 ]]; then
  step "✅ VALIDARE COMPLETĂ: Toate verificările au trecut"
  echo "  - Porturi conforme cu strategia"
  echo "  - Rețele Docker configurate corect"
  echo "  - Volume persistente prezente"
  echo "  - Endpoint-uri operaționale"
  exit 0
else
  step "❌ VALIDARE EȘUATĂ: $FAIL verificări au eșuat"
  echo ""
  echo "Liste probleme identificate:"
  for failure in "${FAILURES[@]}"; do
    echo "  • $failure"
  done
  echo ""
  echo "Recomandare: Verificați configurațiile și reporniți serviciile afectate."
  exit 3
fi