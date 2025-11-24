#!/usr/bin/env bash
#
# ci-bootstrap-openbao.sh - Helper to start OpenBao inside CI and seed Control Plane secrets
# Usage: ./scripts/security/ci-bootstrap-openbao.sh [profile]
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PROFILE="${1:-ci}"
BAO_ADDR=${BAO_ADDR:-"http://127.0.0.1:8200"}
COMPOSE_FILE="${REPO_ROOT}/compose.yml"
SECRETS_DIR="${REPO_ROOT}/.secrets"
OPENBAO_CONTAINER=${OPENBAO_CONTAINER:-geniuserp-openbao}

log() {
  local level="$1"
  shift
  printf '%s %s\n' "[ci-openbao:${level}]" "$*"
}

mkdir -p "${SECRETS_DIR}"

REQUIRED_NETWORKS=(
  "geniuserp_net_edge"
  "geniuserp_net_suite_internal"
  "geniuserp_net_backing_services"
  "geniuserp_net_observability"
)

for net in "${REQUIRED_NETWORKS[@]}"; do
  if ! docker network inspect "$net" >/dev/null 2>&1; then
    log INFO "Creating docker network $net"
    docker network create "$net" >/dev/null
  fi
done

log INFO "Starting OpenBao service via docker compose"
docker compose -f "${COMPOSE_FILE}" up -d openbao >/dev/null

log INFO "Ensuring OpenBao is initialized and unsealed"
BAO_ADDR="${BAO_ADDR}" bash "${SCRIPT_DIR}/openbao-init.sh"

if [[ ! -f "${SECRETS_DIR}/openbao-keys.json" ]]; then
  log ERROR "Missing ${SECRETS_DIR}/openbao-keys.json after init"
  exit 1
fi

export BAO_TOKEN="$(jq -r '.root_token' "${SECRETS_DIR}/openbao-keys.json")"

log INFO "Provisioning Control Plane AppRoles"
BAO_ADDR="${BAO_ADDR}" BAO_TOKEN="${BAO_TOKEN}" OPENBAO_CONTAINER="${OPENBAO_CONTAINER}" \
  bash "${SCRIPT_DIR}/setup_cp_approles.sh"

log INFO "Seeding static secrets from inventory (${PROFILE})"
BAO_ADDR="${BAO_ADDR}" BAO_TOKEN="${BAO_TOKEN}" OPENBAO_CONTAINER="${OPENBAO_CONTAINER}" \
  bash "${SCRIPT_DIR}/seed-secrets.sh" --profile "${PROFILE}" --non-interactive

log INFO "OpenBao bootstrap complete"
