#!/usr/bin/env bash
#
# openbao-enable-db-engine.sh - Configure OpenBao Database Secrets Engine for PostgreSQL
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
SECRETS_DIR="${REPO_ROOT}/.secrets"
DB_ADMIN_PASS_FILE="${SECRETS_DIR}/openbao-db-admin.pass"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0;0m'

# Load shared suite environment variables when available (avoids hard-coded defaults)
SUITE_GENERAL_ENV="${REPO_ROOT}/.suite.general.env"
if [[ -f "${SUITE_GENERAL_ENV}" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "${SUITE_GENERAL_ENV}"
    set +a
fi

REQUIRED_VARS=(
    SUITE_DB_POSTGRES_HOST
    SUITE_DB_POSTGRES_PORT
    SUITE_DB_POSTGRES_DB
    SUITE_DB_POSTGRES_USER
    SUITE_DB_POSTGRES_PASS
)

MISSING_VARS=()
for VAR in "${REQUIRED_VARS[@]}"; do
    if [[ -z "${!VAR:-}" ]]; then
        MISSING_VARS+=("$VAR")
    fi
done

if (( ${#MISSING_VARS[@]} > 0 )); then
    echo -e "${RED}✗ Missing required Postgres env vars: ${MISSING_VARS[*]}${NC}"
    echo -e "${YELLOW}  Load them via: set -a && source .suite.general.env && set +a${NC}"
    exit 1
fi

# Shared Postgres connection metadata (populated strictly from env)
POSTGRES_HOST="${SUITE_DB_POSTGRES_HOST}"
POSTGRES_PORT="${SUITE_DB_POSTGRES_PORT}"
POSTGRES_DB="${SUITE_DB_POSTGRES_DB}"
POSTGRES_SUPERUSER="${SUITE_DB_POSTGRES_USER}"
POSTGRES_SUPERPASS="${SUITE_DB_POSTGRES_PASS}"
CONNECTION_URL="postgresql://{{username}}:{{password}}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}?sslmode=disable"

# Determine OpenBao admin password (never hard-code)
OPENBAO_DB_ADMIN_PASSWORD="${OPENBAO_DB_ADMIN_PASSWORD:-}"
if [[ -z "${OPENBAO_DB_ADMIN_PASSWORD}" && -f "${DB_ADMIN_PASS_FILE}" ]]; then
    OPENBAO_DB_ADMIN_PASSWORD="$(<"${DB_ADMIN_PASS_FILE}")"
fi

if [[ -z "${OPENBAO_DB_ADMIN_PASSWORD}" ]]; then
    if ! command -v openssl >/dev/null 2>&1; then
        echo -e "${RED}✗ openssl not found for password generation${NC}"
        exit 1
    fi
    OPENBAO_DB_ADMIN_PASSWORD="$(openssl rand -base64 32 | tr -d '\n')"
    mkdir -p "${SECRETS_DIR}"
    umask 077 && printf '%s' "${OPENBAO_DB_ADMIN_PASSWORD}" > "${DB_ADMIN_PASS_FILE}"
    echo -e "${YELLOW}  Generated OpenBao DB admin password at ${DB_ADMIN_PASS_FILE}${NC}"
fi

export OPENBAO_DB_ADMIN_PASSWORD

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  OpenBao Database Secrets Engine Configuration${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# Check if OpenBao is accessible
if ! command -v bao &> /dev/null; then
    echo -e "${RED}✗ OpenBao CLI (bao) not found${NC}"
    exit 1
fi

# Check OpenBao token
if [[ -z "${BAO_TOKEN:-}" ]]; then
    echo -e "${RED}✗ BAO_TOKEN environment variable not set${NC}"
    echo -e "${YELLOW}  Set it with: export BAO_TOKEN=\$(cat .secrets/openbao-keys.json | jq -r '.root_token')${NC}"
    exit 1
fi

echo -e "${GREEN}✓ OpenBao CLI available${NC}"
echo -e "${GREEN}✓ BAO_TOKEN configured${NC}"
echo ""

# Enable database secrets engine
echo -e "${BLUE}[Step 1/5] Enabling database secrets engine...${NC}"
if bao secrets enable database 2>/dev/null; then
    echo -e "${GREEN}  ✓ Database engine enabled at: database/${NC}"
elif bao secrets list | grep -q "database/"; then
    echo -e "${YELLOW}  ⚠ Database engine already enabled${NC}"
else
    echo -e "${RED}  ✗ Failed to enable database engine${NC}"
    exit 1
fi
echo ""

# Configure PostgreSQL connection
echo -e "${BLUE}[Step 2/5] Configuring PostgreSQL connection...${NC}"

# Create dedicated database admin user if it doesn't exist
echo -e "  Creating dedicated openbao_admin user in PostgreSQL..."

ESCAPED_PASS="${OPENBAO_DB_ADMIN_PASSWORD//\'/''}"

cat <<EOF | docker exec -i -e PGPASSWORD="${POSTGRES_SUPERPASS}" geniuserp-postgres \
    psql -U "${POSTGRES_SUPERUSER}" -d "${POSTGRES_DB}" -v ON_ERROR_STOP=1 1>/dev/null || true
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'openbao_admin') THEN
        EXECUTE 'CREATE ROLE openbao_admin WITH LOGIN PASSWORD ''${ESCAPED_PASS}'' SUPERUSER';
        COMMENT ON ROLE openbao_admin IS 'OpenBao database secrets engine admin user';
    ELSE
        EXECUTE 'ALTER ROLE openbao_admin WITH LOGIN PASSWORD ''${ESCAPED_PASS}'' SUPERUSER';
    END IF;
END
\$\$;
EOF

echo -e "${GREEN}  ✓ OpenBao admin user ready${NC}"

# Configure OpenBao DB connection
echo -e "  Configuring OpenBao database connection..."

bao write database/config/postgresql \
    plugin_name=postgresql-database-plugin \
    allowed_roles="*" \
    connection_url="${CONNECTION_URL}" \
    username="openbao_admin" \
    password="${OPENBAO_DB_ADMIN_PASSWORD}" \
    verify_connection=true

echo -e "${GREEN}  ✓ PostgreSQL connection configured${NC}"
echo ""

# Configure TTL settings
echo -e "${BLUE}[Step 3/5] Configuring TTL settings...${NC}"

# Tune database engine TTL (idempotent reapply of config)
bao write database/config/postgresql \
    plugin_name=postgresql-database-plugin \
    allowed_roles="*" \
    connection_url="${CONNECTION_URL}" \
    username="openbao_admin" \
    password="${OPENBAO_DB_ADMIN_PASSWORD}" \
    verify_connection=true \
    default_ttl=1h \
    max_ttl=24h

echo -e "${GREEN}  ✓ Default TTL: 1 hour${NC}"
echo -e "${GREEN}  ✓ Maximum TTL: 24 hours${NC}"
echo ""

# Create example role (will be replaced by app-specific roles in F0.5.11)
echo -e "${BLUE}[Step 4/5] Creating example database role...${NC}"

bao write database/roles/example-readonly \
    db_name=postgresql \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
    GRANT CONNECT ON DATABASE postgres TO \"{{name}}\"; \
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"

echo -e "${GREEN}  ✓ Example role 'example-readonly' created${NC}"
echo ""

# Verification
echo -e "${BLUE}[Step 5/5] Verifying configuration...${NC}"

# List secrets engines
if bao secrets list | grep -q "database/"; then
    echo -e "${GREEN}  ✓ Database engine is active${NC}"
else
    echo -e "${RED}  ✗ Database engine not found${NC}"
    exit 1
fi

# Test credential generation
echo -e "  Testing dynamic credential generation..."
if CREDS=$(bao read database/creds/example-readonly 2>&1); then
    echo -e "${GREEN}  ✓ Successfully generated dynamic credentials${NC}"
    echo ""
    echo -e "${BLUE}  Sample Credentials:${NC}"
    echo "$CREDS" | grep -E "username|password" | head -2
    
    # Extract username and cleanup
    USERNAME=$(echo "$CREDS" | grep "username" | awk '{print $2}')
    if [[ -n "$USERNAME" ]]; then
        echo ""
        echo -e "${YELLOW}  Cleaning up test user: $USERNAME${NC}"
        docker exec -e PGPASSWORD="${POSTGRES_SUPERPASS}" geniuserp-postgres \
            psql -U "${POSTGRES_SUPERUSER}" -d "${POSTGRES_DB}" \
            -c "REVOKE ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} FROM \"$USERNAME\"; DROP ROLE IF EXISTS \"$USERNAME\";" 2>/dev/null || true
    fi
else
    echo -e "${RED}  ✗ Failed to generate credentials${NC}"
    echo "$CREDS"
    exit 1
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "  Database Engine: ${GREEN}ACTIVE${NC}"
echo -e "  Mount Path:      database/"
echo -e "  PostgreSQL:      Connected via openbao_admin"
echo -e "  Default TTL:     1 hour"
echo -e "  Maximum TTL:     24 hours"
echo -e "  Example Role:    example-readonly"
echo ""
echo -e "${GREEN}✓ OpenBao Database Secrets Engine is ready!${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo -e "  1. Create application-specific roles (F0.5.11)"
echo -e "  2. Configure automatic credential rotation (F0.5.12)"
echo -e "  3. Update applications to use dynamic credentials"
echo ""
