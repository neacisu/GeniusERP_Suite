#!/usr/bin/env bash
#
# test-f05-chaos.sh - Chaos testing for F0.5 Security Architecture
#
# Scenarios:
# 1. Secret Injection: Verify target container rendered secrets from OpenBao.
# 2. Chaos: Stop OpenBao, ensure target stays healthy with cached secrets.
# 3. Recovery: Restart & auto-unseal OpenBao, confirm target still running.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
ROOT_COMPOSE_FILE="${REPO_ROOT}/compose.yml"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

TARGET="${1:-proxy}"

case "$TARGET" in
    proxy)
        APP="proxy"
        APP_SERVICE="proxy"
        COMPOSE_FILE="${ROOT_COMPOSE_FILE}"
        REQUIRED_ENV_FILES=("proxy/.proxy.env")
        SECRET_FILE="/run/traefik/secrets/dashboard-users"
        ;;
    numeriqo)
        APP="numeriqo"
        APP_SERVICE="numeriqo-app"
        COMPOSE_FILE="${REPO_ROOT}/numeriqo.app/compose/docker-compose.yml"
        REQUIRED_ENV_FILES=(".suite.general.env" "numeriqo.app/.numeriqo.env")
        SECRET_FILE="/app/secrets/db-creds.json"
        ;;
    *)
        echo -e "${RED}Unknown chaos target: ${TARGET}${NC}" >&2
        exit 1
        ;;
esac

compose_cmd() {
    docker compose -f "$COMPOSE_FILE" "$@"
}

ensure_env_files() {
    for rel in "$@"; do
        local path="${REPO_ROOT}/${rel}"
        if [[ ! -f "$path" ]]; then
            echo -e "${RED}Missing required env file: ${rel}${NC}" >&2
            exit 1
        fi
    done
}

ensure_service_running() {
    echo -e "${BLUE}▶ Ensuring ${APP} service is running...${NC}"
    compose_cmd up -d "$APP_SERVICE"
    sleep 8
}

check_service_up() {
    compose_cmd ps "$APP_SERVICE" | grep -q "Up"
}

ensure_env_files "${REQUIRED_ENV_FILES[@]}"

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  F0.5 Chaos Testing: ${APP}${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

ensure_service_running

echo -e "${BLUE}[1/3] Verifying secret injection...${NC}"
if compose_cmd exec -T "$APP_SERVICE" sh -c "test -f ${SECRET_FILE}"; then
    echo -e "${GREEN}  ✓ Secret artifact present (${SECRET_FILE})${NC}"
else
    echo -e "${RED}  ✗ Secret artifact missing (${SECRET_FILE})${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}[2/3] Simulating OpenBao outage...${NC}"
echo "  Stopping OpenBao container..."
docker compose -f "$ROOT_COMPOSE_FILE" stop openbao
sleep 10

if check_service_up; then
    echo -e "${GREEN}  ✓ ${APP} container stayed up while OpenBao was offline${NC}"
else
    echo -e "${RED}  ✗ ${APP} container exited during outage${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}[3/3] Recovery and auto-unseal...${NC}"
docker compose -f "$ROOT_COMPOSE_FILE" start openbao
sleep 5
BAO_ADDR=${BAO_ADDR:-"http://127.0.0.1:8200"} bash "${SCRIPT_DIR}/openbao-init.sh"

if check_service_up; then
    echo -e "${GREEN}  ✓ ${APP} container healthy after OpenBao recovery${NC}"
else
    echo -e "${YELLOW}  ⚠ ${APP} container exited after recovery - check logs${NC}"
fi

echo ""
echo -e "${GREEN}✓ Chaos test sequence completed for ${APP}.${NC}"
