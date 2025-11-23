#!/usr/bin/env bash
#
# setup-approle.sh - Generate AppRole credentials for mercantiq
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
SECRETS_DIR="${REPO_ROOT}/.secrets/approle/mercantiq"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0;0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  mercantiq AppRole Setup${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# Check OpenBao token
if [[ -z "${BAO_TOKEN:-}" ]]; then
    echo -e "${RED}✗ BAO_TOKEN not set${NC}"
    echo -e "  Export it: export BAO_TOKEN=\$(jq -r '.root_token' .secrets/openbao-keys.json)"
    exit 1
fi

# Create AppRole if it doesn't exist
echo -e "${BLUE}[1/3] Creating AppRole for mercantiq...${NC}"

bao write auth/approle/role/mercantiq \
    token_ttl=1h \
    token_max_ttl=4h \
    token_policies="mercantiq-read" \
    bind_secret_id=true \
    secret_id_ttl=0

echo -e "${GREEN}  ✓ AppRole 'mercantiq' created${NC}"
echo ""

# Get role-id
echo -e "${BLUE}[2/3] Retrieving role-id...${NC}"

ROLE_ID=$(bao read -field=role_id auth/approle/role/mercantiq/role-id)

mkdir -p "${SECRETS_DIR}"
echo -n "${ROLE_ID}" > "${SECRETS_DIR}/role-id"
chmod 600 "${SECRETS_DIR}/role-id"

echo -e "${GREEN}  ✓ role-id saved to ${SECRETS_DIR}/role-id${NC}"
echo ""

# Generate secret-id
echo -e "${BLUE}[3/3] Generating secret-id...${NC}"

SECRET_ID=$(bao write -field=secret_id -f auth/approle/role/mercantiq/secret-id)

echo -n "${SECRET_ID}" > "${SECRETS_DIR}/secret-id"
chmod 600 "${SECRETS_DIR}/secret-id"

echo -e "${GREEN}  ✓ secret-id saved to ${SECRETS_DIR}/secret-id${NC}"
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ AppRole credentials ready!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "  role-id:   ${SECRETS_DIR}/role-id"
echo -e "  secret-id: ${SECRETS_DIR}/secret-id"
echo ""
echo -e "${BLUE}Next: docker compose -f mercantiq.app/compose/docker-compose.yml up${NC}"
echo ""
