#!/usr/bin/env bash
set -euo pipefail

CI_MODE=${CI_MODE:-false}

if docker compose version >/dev/null 2>&1; then DC=(docker compose); else DC=(docker-compose); fi
COMPOSE_FILE=${COMPOSE_FILE:-"compose/profiles/compose.dev.yml"}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OBSERVABILITY_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${OBSERVABILITY_ROOT}/.." && pwd)"

SUITE_ENV_FILE="${REPO_ROOT}/.suite.general.env"
BACKING_ENV_FILE="${REPO_ROOT}/.backing-services.env"
OBS_ENV_FILE="${OBSERVABILITY_ROOT}/.observability.env"

step() { echo "[validate] $1"; }
check_fail() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); FAILURES+=("$1"); }
check_ok() { echo "  ✓ $1"; }
check_skip() { echo "  ~ $1"; }

FAIL=0
FAILURES=()

trim_quotes() {
  local value="$1"
  value="${value%%$'\r'}"
  value="${value%\"}"
  value="${value#\"}"
  value="$(printf '%s' "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
  echo "$value"
}

read_env_var() {
  local file="$1"
  local key="$2"
  local default="${3:-}"
  if [[ ! -f "$file" ]]; then
    echo "$default"
    return
  fi
  local line
  line=$(grep -E "^[[:space:]]*${key}=" "$file" | tail -n1 | sed -E "s/^[[:space:]]*${key}=//" || true)
  if [[ -z "$line" ]]; then
    echo "$default"
    return
  fi
  local cleaned
  cleaned=$(trim_quotes "$line")
  if [[ -z "$cleaned" ]]; then
    echo "$default"
  else
    echo "$cleaned"
  fi
}

numeric_or_default() {
  local value="$1"
  local fallback="$2"
  if [[ "$value" =~ ^[0-9]+$ ]]; then
    echo "$value"
  else
    echo "$fallback"
  fi
}

extract_port_from_hostport() {
  local value="$1"
  local fallback="$2"
  if [[ -z "$value" ]]; then
    echo "$fallback"
    return
  fi
  local first="${value%%,*}"
  first="${first##*@}"
  local port="${first##*:}"
  port="${port%%/*}"
  if [[ -z "$port" || "$port" == "$first" ]]; then
    echo "$fallback"
  else
    numeric_or_default "$port" "$fallback"
  fi
}

extract_port_from_url() {
  local value="$1"
  local fallback="$2"
  if [[ -z "$value" ]]; then
    echo "$fallback"
    return
  fi
  local stripped="${value#*://}"
  if [[ "$stripped" == "$value" ]]; then
    stripped="$value"
  fi
  stripped="${stripped%%/*}"
  extract_port_from_hostport "$stripped" "$fallback"
}

POSTGRES_PORT=$(numeric_or_default "$(read_env_var "$SUITE_ENV_FILE" "SUITE_DB_POSTGRES_PORT" "5432")" "5432")
KAFKA_PORT=$(extract_port_from_hostport "$(read_env_var "$SUITE_ENV_FILE" "SUITE_MQ_KAFKA_BROKERS" "kafka:9092")" "9092")
TEMPORAL_PORT=$(extract_port_from_hostport "$(read_env_var "$SUITE_ENV_FILE" "SUITE_BPM_TEMPORAL_HOST_PORT" "temporal:7233")" "7233")
SUPERTOKENS_PORT=$(extract_port_from_url "$(read_env_var "$BACKING_ENV_FILE" "CP_IDT_AUTH_SUPERTOKENS_CONNECTION_URI" "http://supertokens-core:3567")" "3567")

GRAFANA_PORT=$(numeric_or_default "$(read_env_var "$OBS_ENV_FILE" "OBS_GRAFANA_PORT" "3000")" "3000")
PROMETHEUS_PORT=$(numeric_or_default "$(read_env_var "$OBS_ENV_FILE" "OBS_PROMETHEUS_PORT" "9090")" "9090")
LOKI_PORT=$(numeric_or_default "$(read_env_var "$OBS_ENV_FILE" "OBS_LOKI_PORT" "3100")" "3100")

CP_SHELL_PORT_DEFAULT=6100
CP_IDENTITY_PORT_DEFAULT=6250
ARCHIFY_PORT_DEFAULT=6500
VETTIFY_PORT_DEFAULT=6850

CP_SHELL_PORT=$CP_SHELL_PORT_DEFAULT
CP_IDENTITY_PORT=$CP_IDENTITY_PORT_DEFAULT
ARCHIFY_PORT=$ARCHIFY_PORT_DEFAULT
VETTIFY_PORT=$VETTIFY_PORT_DEFAULT

validate_port_binding() {
  local service="$1"
  local port="$2"
  if docker ps --format "{{.Ports}}" | grep -F ":${port}->" >/dev/null 2>&1; then
    check_ok "$service pe portul $port"
  else
    check_fail "$service LIPSĂ sau pe port greșit (așteptat: $port)"
  fi
}

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
# ==========================================
step "Verific conformitatea porturilor cu strategia (Tabelul 4 & 5)"

BACKING_SERVICES_PORTS=(
  "$POSTGRES_PORT|PostgreSQL"
  "$KAFKA_PORT|Kafka"
  "$SUPERTOKENS_PORT|SuperTokens"
  "$TEMPORAL_PORT|Temporal"
)

for entry in "${BACKING_SERVICES_PORTS[@]}"; do
  port="${entry%%|*}"
  label="${entry##*|}"
  if [[ "$CI_MODE" == "true" && "$label" == "SuperTokens" ]]; then
    check_skip "SuperTokens verificare port sărită în CI (3567)"
    continue
  fi
  validate_port_binding "$label" "$port"
done

if docker ps --format "{{.Names}}" | grep -q "geniuserp-otel-collector"; then
  check_ok "OTEL Collector container activ (porturi interne 4317/4318)"
else
  check_fail "OTEL Collector container NU rulează"
fi

OBSERVABILITY_PORTS=(
  "$GRAFANA_PORT|Grafana"
  "$PROMETHEUS_PORT|Prometheus"
  "$LOKI_PORT|Loki"
)

for entry in "${OBSERVABILITY_PORTS[@]}"; do
  port="${entry%%|*}"
  label="${entry##*|}"
  validate_port_binding "$label" "$port"
done

CP_SERVICE_SPECS=(
  "CP:suite-shell|${REPO_ROOT}/cp/suite-shell/.cp.suite-shell.env|CP_SHELL_APP_PORT|6100"
  "CP:suite-admin|${REPO_ROOT}/cp/suite-admin/.cp.suite-admin.env|CP_ADMIN_APP_PORT|6150"
  "CP:suite-login|${REPO_ROOT}/cp/suite-login/.cp.suite-login.env|CP_LOGIN_APP_PORT|6200"
  "CP:identity|${REPO_ROOT}/cp/identity/.cp.identity.env|CP_IDT_APP_PORT|6250"
  "CP:licensing|${REPO_ROOT}/cp/licensing/.cp.licensing.env|CP_LIC_APP_PORT|6300"
  "CP:analytics-hub|${REPO_ROOT}/cp/analytics-hub/.cp.analytics-hub.env|CP_ANLY_APP_PORT|6350"
  "CP:ai-hub|${REPO_ROOT}/cp/ai-hub/.cp.ai-hub.env|CP_AI_APP_PORT|6400"
)

for spec in "${CP_SERVICE_SPECS[@]}"; do
  IFS='|' read -r label file var fallback <<<"$spec"
  if [[ "$CI_MODE" == "true" && "$label" == "CP:ai-hub" ]]; then
    check_skip "CP:ai-hub verificare port sărită în CI (instabil)"
    continue
  fi
  port=$(numeric_or_default "$(read_env_var "$file" "$var" "$fallback")" "$fallback")
  validate_port_binding "$label" "$port"
  case "$label" in
    "CP:suite-shell") CP_SHELL_PORT="$port" ;;
    "CP:identity") CP_IDENTITY_PORT="$port" ;;
  esac
done

if [[ "$CI_MODE" != "true" ]]; then
  APP_SERVICE_SPECS=(
    "archify.app|${REPO_ROOT}/archify.app/.archify.env|ARCHY_APP_PORT|6500"
    "cerniq.app|${REPO_ROOT}/cerniq.app/.cerniq.env|CERNIQ_APP_PORT|6550"
    "flowxify.app|${REPO_ROOT}/flowxify.app/.flowxify.env|FLOWX_APP_PORT|6600"
    "i-wms.app|${REPO_ROOT}/i-wms.app/.i-wms.env|IWMS_APP_PORT|6650"
    "mercantiq.app|${REPO_ROOT}/mercantiq.app/.mercantiq.env|MERCQ_APP_PORT|6700"
    "numeriqo.app|${REPO_ROOT}/numeriqo.app/.numeriqo.env|NUMQ_APP_PORT|6750"
    "triggerra.app|${REPO_ROOT}/triggerra.app/.triggerra.env|TRIGR_APP_PORT|6800"
    "vettify.app|${REPO_ROOT}/vettify.app/.vettify.env|VETFY_APP_PORT|6850"
  )

  for spec in "${APP_SERVICE_SPECS[@]}"; do
    IFS='|' read -r label file var fallback <<<"$spec"
    port=$(numeric_or_default "$(read_env_var "$file" "$var" "$fallback")" "$fallback")
    validate_port_binding "$label" "$port"
    case "$label" in
      "archify.app") ARCHIFY_PORT="$port" ;;
      "vettify.app") VETTIFY_PORT="$port" ;;
    esac
  done
fi

# ==========================================
# 3. VERIFICARE REȚELE DOCKER
# ==========================================
step "Verific existența rețelelor Docker (Model Zero-Trust)"

REQUIRED_NETWORKS=(
  "geniuserp_net_observability|Observability"
  "geniuserp_net_suite_internal|API-Intern"
  "geniuserp_net_backing_services|Backing-Services"
  "geniuserp_net_edge|Edge-Public"
)

for entry in "${REQUIRED_NETWORKS[@]}"; do
  net="${entry%%|*}"
  label="${entry##*|}"
  if docker network ls --format "{{.Name}}" | grep -q "^${net}$"; then
    check_ok "Rețea $label ($net) există"
  else
    check_fail "Rețea $label ($net) LIPSĂ"
  fi
done

# ==========================================
# 4. VERIFICARE VOLUME PERSISTENTE
# ==========================================
step "Verific existența volumelor critice (Protecție date)"

CRITICAL_VOLUMES=(
  "gs_prometheus_data|Prometheus-TSDB"
  "gs_loki_data|Loki-Logs"
  "gs_grafana_data|Grafana-Config"
)

for entry in "${CRITICAL_VOLUMES[@]}"; do
  vol="${entry%%|*}"
  label="${entry##*|}"
  if docker volume ls --format "{{.Name}}" | grep -q "^${vol}$"; then
    check_ok "Volum $label ($vol) există"
  else
    check_fail "Volum $label ($vol) LIPSĂ - RISC PIERDERE DATE"
  fi
done

# ==========================================
# 5. VERIFICARE ENDPOINT-URI CRITICE
# ==========================================
step "Verificare endpoint-uri critice (Health & Metrics)"

test_endpoint() {
  local url="$1"
  local name="$2"
  local code
  code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 --max-time 10 "$url" || echo "000")
  if [[ "$code" == "200" ]]; then
    check_ok "$name răspunde HTTP 200"
  else
    check_fail "$name FAIL (HTTP $code)"
  fi
}

ENDPOINT_CHECKS=(
  "http://localhost:${GRAFANA_PORT}/api/health|Grafana"
  "http://localhost:${GRAFANA_PORT}/metrics|Grafana metrics"
  "http://localhost:${PROMETHEUS_PORT}/-/ready|Prometheus"
  "http://localhost:${LOKI_PORT}/ready|Loki"
  "http://localhost:${CP_SHELL_PORT}/health|CP:suite-shell"
  "http://localhost:${CP_IDENTITY_PORT}/health|CP:identity"
)

if [[ "$CI_MODE" != "true" ]]; then
  ENDPOINT_CHECKS+=(
    "http://localhost:${ARCHIFY_PORT}/health|archify.app"
    "http://localhost:${VETTIFY_PORT}/health|vettify.app"
  )
fi

for entry in "${ENDPOINT_CHECKS[@]}"; do
  url="${entry%%|*}"
  label="${entry##*|}"
  test_endpoint "$url" "$label"
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