#!/usr/bin/env bash
#
# generate-app-config.sh - Generate Process Supervisor configuration for an application
#
# Usage: ./generate-app-config.sh <app-name>
# Example: ./generate-app-config.sh archify
#
set -euo pipefail

APP_NAME="${1:-}"

if [[ -z "$APP_NAME" ]]; then
    echo "Usage: $0 <app-name>"
    echo "Example: $0 archify"
    exit 1
fi

# Determine app directory
if [[ -d "${APP_NAME}.app" ]]; then
    APP_DIR="${APP_NAME}.app"
elif [[ -d "cp/${APP_NAME}" ]]; then
    APP_DIR="cp/${APP_NAME}"
else
    echo "Error: Could not find directory for app: $APP_NAME"
    echo "Tried: ${APP_NAME}.app and cp/${APP_NAME}"
    exit 1
fi

echo "Generating Process Supervisor configuration for: $APP_NAME"
echo "App directory: $APP_DIR"
echo ""

# Create directories
mkdir -p "${APP_DIR}/openbao/templates"
mkdir -p "${APP_DIR}/scripts"

# Generate OpenBao Agent config
cat > "${APP_DIR}/openbao/agent-config.hcl" <<EOF
# OpenBao Agent Configuration for ${APP_NAME^} Application
# This config enables auto-auth and template rendering for secret injection

pid_file = "/tmp/openbao-agent.pid"

# Auto-auth configuration using AppRole
auto_auth {
  method {
    type = "approle"
    
    config = {
      role_id_file_path = "/openbao/role-id"
      secret_id_file_path = "/openbao/secret-id"
      remove_secret_id_file_after_reading = false
    }
  }

  sink {
    type = "file"
    config = {
      path = "/tmp/openbao-token"
    }
  }
}

# Template for database credentials (dynamic from OpenBao)
template {
  source      = "/openbao/templates/db-creds.tpl"
  destination = "/app/secrets/db-creds.json"
  perms       = "0600"
}

# Template for application secrets (static from KV)
template {
  source      = "/openbao/templates/app-secrets.tpl"
  destination = "/app/secrets/app-secrets.json"
  perms       = "0600"
}

# Template for combined .env file
template {
  source      = "/openbao/templates/${APP_NAME}.env.tpl"
  destination = "/app/secrets/.env"
  perms       = "0600"
  
  # Execute command after template is rendered
  exec {
    command = ["/app/scripts/start-app.sh"]
  }
}

# OpenBao server configuration
vault {
  address = "http://openbao:8200"
}
EOF

echo "✓ Created: ${APP_DIR}/openbao/agent-config.hcl"

# Generate DB credentials template
cat > "${APP_DIR}/openbao/templates/db-creds.tpl" <<EOF
{{- /* Template for ${APP_NAME^} database credentials from OpenBao dynamic secrets */ -}}
{{- with secret "database/creds/${APP_NAME}_runtime" -}}
{
  "username": "{{ .Data.username }}",
  "password": "{{ .Data.password }}",
  "lease_id": "{{ .LeaseID }}",
  "lease_duration": {{ .LeaseDuration }},
  "renewable": {{ .Renewable }}
}
{{- end -}}
EOF

echo "✓ Created: ${APP_DIR}/openbao/templates/db-creds.tpl"

# Generate app secrets template
cat > "${APP_DIR}/openbao/templates/app-secrets.tpl" <<EOF
{{- /* Template for ${APP_NAME^} application secrets from OpenBao KV */ -}}
{{- with secret "kv/data/apps/${APP_NAME}" -}}
{
  "jwt_secret": "{{ .Data.data.jwt_secret }}",
  "api_key": "{{ .Data.data.api_key }}",
  "encryption_key": "{{ .Data.data.encryption_key }}"
}
{{- end -}}
EOF

echo "✓ Created: ${APP_DIR}/openbao/templates/app-secrets.tpl"

# Generate combined .env template
APP_PREFIX=$(echo "$APP_NAME" | tr '[:lower:]' '[:upper:]' | tr '-' '_')

cat > "${APP_DIR}/openbao/templates/${APP_NAME}.env.tpl" <<EOF
{{- /* Template for ${APP_NAME^} .env file with all secrets injected */ -}}
{{- with secret "database/creds/${APP_NAME}_runtime" -}}
# Database credentials (dynamic from OpenBao)
${APP_PREFIX}_DB_USER={{ .Data.username }}
${APP_PREFIX}_DB_PASS={{ .Data.password }}
${APP_PREFIX}_DB_HOST=\${SUITE_DB_POSTGRES_HOST}
${APP_PREFIX}_DB_PORT=\${SUITE_DB_POSTGRES_PORT}
${APP_PREFIX}_DB_NAME=${APP_NAME}_db
{{- end }}

{{- with secret "kv/data/apps/${APP_NAME}" }}
# Application secrets (static from OpenBao KV)
${APP_PREFIX}_JWT_SECRET={{ .Data.data.jwt_secret }}
${APP_PREFIX}_API_KEY={{ .Data.data.api_key }}
${APP_PREFIX}_ENCRYPTION_KEY={{ .Data.data.encryption_key }}
{{- end }}

# Non-secret configuration (from environment)
${APP_PREFIX}_APP_PORT=\${${APP_PREFIX}_APP_PORT}
${APP_PREFIX}_APP_NODE_ENV=\${${APP_PREFIX}_APP_NODE_ENV:-production}
NODE_ENV=production
LOG_LEVEL=\${${APP_PREFIX}_LOG_LEVEL:-info}
EOF

echo "✓ Created: ${APP_DIR}/openbao/templates/${APP_NAME}.env.tpl"

# Generate Process Supervisor script
cat > "${APP_DIR}/scripts/start-app.sh" <<'EOFSCRIPT'
#!/bin/sh
#
# start-app.sh - Process Supervisor entrypoint for APP_NAME_PLACEHOLDER
# Launched by OpenBao Agent after secrets are rendered
#
set -e

echo "[Process Supervisor] Starting APP_NAME_PLACEHOLDER application..."
echo "[Process Supervisor] Secrets injected at: /app/secrets/"

# Source the rendered .env file
if [ -f "/app/secrets/.env" ]; then
    echo "[Process Supervisor] Loading secrets from /app/secrets/.env"
    set -a
    # shellcheck disable=SC1091
    . /app/secrets/.env
    set +a
else
    echo "[Process Supervisor] ERROR: /app/secrets/.env not found!"
    exit 1
fi

# Verify critical secrets are present
if [ -z "$APP_PREFIX_PLACEHOLDER_DB_USER" ] || [ -z "$APP_PREFIX_PLACEHOLDER_DB_PASS" ]; then
    echo "[Process Supervisor] ERROR: Database credentials not injected!"
    exit 1
fi

if [ -z "$APP_PREFIX_PLACEHOLDER_JWT_SECRET" ]; then
    echo "[Process Supervisor] ERROR: JWT secret not injected!"
    exit 1
fi

echo "[Process Supervisor] ✓ All secrets validated"
echo "[Process Supervisor] ✓ Database user: $APP_PREFIX_PLACEHOLDER_DB_USER"
echo "[Process Supervisor] ✓ Starting Node.js application..."

# Start the Node.js application
exec node dist/APP_NAME_PLACEHOLDER.app/src/index.js
EOFSCRIPT

# Replace placeholders
sed -i "s/APP_NAME_PLACEHOLDER/${APP_NAME}/g" "${APP_DIR}/scripts/start-app.sh"
sed -i "s/APP_PREFIX_PLACEHOLDER/${APP_PREFIX}/g" "${APP_DIR}/scripts/start-app.sh"

chmod +x "${APP_DIR}/scripts/start-app.sh"

echo "✓ Created: ${APP_DIR}/scripts/start-app.sh"

# Generate AppRole setup script
cat > "${APP_DIR}/scripts/setup-approle.sh" <<'EOFSCRIPT'
#!/usr/bin/env bash
#
# setup-approle.sh - Generate AppRole credentials for APP_NAME_PLACEHOLDER
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
SECRETS_DIR="${REPO_ROOT}/.secrets/approle/APP_NAME_PLACEHOLDER"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0;0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  APP_NAME_PLACEHOLDER AppRole Setup${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# Check OpenBao token
if [[ -z "${BAO_TOKEN:-}" ]]; then
    echo -e "${RED}✗ BAO_TOKEN not set${NC}"
    echo -e "  Export it: export BAO_TOKEN=\$(jq -r '.root_token' .secrets/openbao-keys.json)"
    exit 1
fi

# Create AppRole if it doesn't exist
echo -e "${BLUE}[1/3] Creating AppRole for APP_NAME_PLACEHOLDER...${NC}"

bao write auth/approle/role/APP_NAME_PLACEHOLDER \
    token_ttl=1h \
    token_max_ttl=4h \
    token_policies="APP_NAME_PLACEHOLDER-read" \
    bind_secret_id=true \
    secret_id_ttl=0

echo -e "${GREEN}  ✓ AppRole 'APP_NAME_PLACEHOLDER' created${NC}"
echo ""

# Get role-id
echo -e "${BLUE}[2/3] Retrieving role-id...${NC}"

ROLE_ID=$(bao read -field=role_id auth/approle/role/APP_NAME_PLACEHOLDER/role-id)

mkdir -p "${SECRETS_DIR}"
echo -n "${ROLE_ID}" > "${SECRETS_DIR}/role-id"
chmod 600 "${SECRETS_DIR}/role-id"

echo -e "${GREEN}  ✓ role-id saved to ${SECRETS_DIR}/role-id${NC}"
echo ""

# Generate secret-id
echo -e "${BLUE}[3/3] Generating secret-id...${NC}"

SECRET_ID=$(bao write -field=secret_id -f auth/approle/role/APP_NAME_PLACEHOLDER/secret-id)

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
echo -e "${BLUE}Next: docker compose -f APP_NAME_PLACEHOLDER.app/compose/docker-compose.yml up${NC}"
echo ""
EOFSCRIPT

# Replace placeholders
sed -i "s/APP_NAME_PLACEHOLDER/${APP_NAME}/g" "${APP_DIR}/scripts/setup-approle.sh"

chmod +x "${APP_DIR}/scripts/setup-approle.sh"

echo "✓ Created: ${APP_DIR}/scripts/setup-approle.sh"

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✓ Process Supervisor configuration generated for: $APP_NAME"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo "1. Update ${APP_DIR}/compose/docker-compose.yml to remove hardcoded values"
echo "2. Create ${APP_DIR}/.${APP_NAME}.env.example with all config variables"
echo "3. Update ${APP_DIR}/Dockerfile to use geniuserp/node-openbao:local"
echo "4. Test: cd ${APP_DIR} && ./scripts/setup-approle.sh && docker compose up"
echo ""
