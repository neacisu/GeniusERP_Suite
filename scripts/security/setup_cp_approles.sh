#!/usr/bin/env bash
# setup_cp_approles.sh - Provision AppRole credentials for Control Plane & infra services
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
SECRETS_ROOT="${REPO_ROOT}/.secrets/approle"
POLICY_DIR="${REPO_ROOT}/scripts/security/policies"
OPENBAO_KEYS="${REPO_ROOT}/.secrets/openbao-keys.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Map of AppRole (and secrets dir) -> policy name
read -r -d '' ROLE_MATRIX <<'EOF' || true
cp-identity:identity-read
cp-licensing:licensing-read
cp-suite-admin:suite-admin-read
cp-suite-shell:suite-shell-read
cp-suite-login:suite-login-read
cp-ai-hub:ai-hub-read
cp-analytics-hub:analytics-hub-read
proxy:proxy-read
EOF

if ! command -v jq >/dev/null 2>&1; then
  echo -e "${RED}✗ 'jq' is required to read OpenBao tokens${NC}" >&2
  exit 1
fi

VAULT_ADDR=${VAULT_ADDR:-http://127.0.0.1:8200}
export VAULT_ADDR

if [[ -z "${BAO_TOKEN:-}" ]]; then
  if [[ -f "${OPENBAO_KEYS}" ]]; then
    BAO_TOKEN=$(jq -r '.root_token' "${OPENBAO_KEYS}")
    export BAO_TOKEN
    echo -e "${YELLOW}ℹ Loaded BAO_TOKEN from ${OPENBAO_KEYS}${NC}"
  else
    echo -e "${RED}✗ BAO_TOKEN is not set and ${OPENBAO_KEYS} is missing${NC}" >&2
    exit 1
  fi
fi

mkdir -p "${SECRETS_ROOT}"

bao_exec() {
  docker exec \
    -e BAO_ADDR="${VAULT_ADDR}" \
    -e BAO_TOKEN="${BAO_TOKEN}" \
    geniuserp-openbao bao "$@"
}

copy_policy_into_openbao() {
  local policy_file="$1"
  local policy_name="$2"
  local remote_path="/tmp/${policy_name}.hcl"

  docker cp "${policy_file}" "geniuserp-openbao:${remote_path}"
  bao_exec policy write "${policy_name}" "${remote_path}" >/dev/null
  docker exec geniuserp-openbao rm -f "${remote_path}" >/dev/null 2>&1 || true
}

echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Control Plane & Infra AppRole Provisioning${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"

while IFS=':' read -r ROLE_NAME POLICY_NAME; do
  [[ -z "${ROLE_NAME}" ]] && continue
  POLICY_FILE="${POLICY_DIR}/${POLICY_NAME}.hcl"
  if [[ ! -f "${POLICY_FILE}" ]]; then
    echo -e "${RED}✗ Missing policy file for ${POLICY_NAME} (${POLICY_FILE})${NC}" >&2
    exit 1
  fi

  echo -e "${BLUE}▶ Ensuring policy ${POLICY_NAME}${NC}"
  copy_policy_into_openbao "${POLICY_FILE}" "${POLICY_NAME}"

  echo -e "${BLUE}▶ Provisioning AppRole ${ROLE_NAME}${NC}"
  bao_exec write "auth/approle/role/${ROLE_NAME}" \
    token_policies="${POLICY_NAME}" \
    token_ttl="1h" \
    token_max_ttl="4h" \
    secret_id_ttl="0" \
    bind_secret_id="true" >/dev/null

  ROLE_DIR="${SECRETS_ROOT}/${ROLE_NAME}"
  mkdir -p "${ROLE_DIR}"

  ROLE_ID=$(bao_exec read -field=role_id "auth/approle/role/${ROLE_NAME}/role-id")
  SECRET_ID=$(bao_exec write -field=secret_id -f "auth/approle/role/${ROLE_NAME}/secret-id")

  printf '%s' "${ROLE_ID}" > "${ROLE_DIR}/role-id"
  printf '%s' "${SECRET_ID}" > "${ROLE_DIR}/secret-id"

  chmod 600 "${ROLE_DIR}/role-id" "${ROLE_DIR}/secret-id"
  # UID/GID 1001 is used by appuser inside CP containers
  chown 1001:1001 "${ROLE_DIR}/role-id" "${ROLE_DIR}/secret-id"

  echo -e "${GREEN}  ✓ AppRole ${ROLE_NAME} credentials written to ${ROLE_DIR}${NC}"
  echo ""
done <<< "${ROLE_MATRIX}"

echo -e "${GREEN}All AppRoles provisioned successfully.${NC}"
