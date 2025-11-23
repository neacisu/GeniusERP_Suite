#!/usr/bin/env bash
#
# convert-compose-to-env.sh - Extract hardcoded values from docker-compose.yml
#
# Usage: ./convert-compose-to-env.sh <path-to-docker-compose.yml>
# Example: ./convert-compose-to-env.sh archify.app/compose/docker-compose.yml
#
set -euo pipefail

COMPOSE_FILE="${1:-}"

if [[ -z "$COMPOSE_FILE" ]] || [[ ! -f "$COMPOSE_FILE" ]]; then
    echo "Usage: $0 <path-to-docker-compose.yml>"
    echo "Example: $0 archify.app/compose/docker-compose.yml"
    exit 1
fi

echo "Analyzing: $COMPOSE_FILE"
echo ""

# Extract app name from path
APP_DIR=$(dirname "$(dirname "$COMPOSE_FILE")")
APP_NAME=$(basename "$APP_DIR" | sed 's/\.app$//')

echo "Detected app: $APP_NAME"
echo "App directory: $APP_DIR"
echo ""

# Create backup
cp "$COMPOSE_FILE" "${COMPOSE_FILE}.backup"
echo "✓ Created backup: ${COMPOSE_FILE}.backup"

# Extract hardcoded values
echo ""
echo "Extracting hardcoded values..."
echo "════════════════════════════════"

# Container name
CONTAINER_NAME=$(grep -E "^\s*container_name:" "$COMPOSE_FILE" | sed 's/.*container_name:\s*//' | tr -d '"' | tr -d "'")
if [[ -n "$CONTAINER_NAME" ]]; then
    echo "Container name: $CONTAINER_NAME"
fi

# Restart policy
RESTART_POLICY=$(grep -E "^\s*restart:" "$COMPOSE_FILE" | sed 's/.*restart:\s*//' | tr -d '"' | tr -d "'")
if [[ -n "$RESTART_POLICY" ]]; then
    echo "Restart policy: $RESTART_POLICY"
fi

# Ports (from environment section)
echo ""
echo "Environment variables with hardcoded defaults:"
grep -E "^\s*-\s+[A-Z_]+=.*:-" "$COMPOSE_FILE" | while read -r line; do
    VAR_NAME=$(echo "$line" | sed 's/.*-\s*//' | cut -d'=' -f1)
    DEFAULT_VALUE=$(echo "$line" | sed 's/.*:-//' | tr -d '}' | tr -d '"' | tr -d "'")
    echo "  $VAR_NAME: $DEFAULT_VALUE"
done

# Hardcoded values in environment section
echo ""
echo "Hardcoded values in environment:"
grep -E "^\s*-\s+[A-Z_]+=\w+" "$COMPOSE_FILE" | grep -v '\${' | while read -r line; do
    VAR_NAME=$(echo "$line" | sed 's/.*-\s*//' | cut -d'=' -f1)
    VALUE=$(echo "$line" | cut -d'=' -f2- | tr -d '"' | tr -d "'")
    echo "  $VAR_NAME: $VALUE"
done

# Traefik labels with hardcoded values
echo ""
echo "Traefik labels with hardcoded values:"
grep -E "traefik\." "$COMPOSE_FILE" | grep -v '\${' | while read -r line; do
    echo "  $(echo "$line" | sed 's/.*traefik\./traefik./' | tr -d '"' | tr -d "'")"
done

# Healthcheck with hardcoded values
echo ""
echo "Healthcheck configuration:"
grep -A5 "healthcheck:" "$COMPOSE_FILE" | grep -E "interval:|timeout:|retries:|start_period:" | while read -r line; do
    echo "  $(echo "$line" | sed 's/^\s*//')"
done

echo ""
echo "════════════════════════════════"
echo ""
echo "Recommendations:"
echo "1. Create .${APP_NAME}.env.example with all extracted values"
echo "2. Replace hardcoded values in $COMPOSE_FILE with \${VAR_NAME}"
echo "3. Remove default values (:-value) from environment variables"
echo "4. Add env_file reference to .${APP_NAME}.env"
echo ""
echo "Example .env.example structure:"
echo ""

APP_PREFIX=$(echo "$APP_NAME" | tr '[:lower:]' '[:upper:]' | tr '-' '_')

cat <<EOF
# ${APP_NAME^} Application Configuration

# Container Configuration
${APP_PREFIX}_CONTAINER_NAME=${CONTAINER_NAME:-genius-suite-${APP_NAME}-app}
${APP_PREFIX}_RESTART_POLICY=${RESTART_POLICY:-unless-stopped}

# Application Ports
${APP_PREFIX}_APP_PORT=XXXX
${APP_PREFIX}_APP_METRICS_PORT=XXXX

# Application Environment
${APP_PREFIX}_APP_NODE_ENV=production
${APP_PREFIX}_LOG_LEVEL=info
${APP_PREFIX}_OTEL_SERVICE_NAME=${APP_NAME}.app

# OpenBao Agent Configuration
${APP_PREFIX}_BAO_AGENT_CONFIG=/openbao/agent-config.hcl
${APP_PREFIX}_APPROLE_ROLE_ID_PATH=../../.secrets/approle/${APP_NAME}/role-id
${APP_PREFIX}_APPROLE_SECRET_ID_PATH=../../.secrets/approle/${APP_NAME}/secret-id

# Traefik Configuration
${APP_PREFIX}_TRAEFIK_ENABLE=true
${APP_PREFIX}_TRAEFIK_HOST=${APP_NAME}.\${SUITE_APP_DOMAIN:-geniuserp.app}
${APP_PREFIX}_TRAEFIK_ENTRYPOINT=websecure
${APP_PREFIX}_TRAEFIK_TLS=true
${APP_PREFIX}_TRAEFIK_CERTRESOLVER=letsencrypt
${APP_PREFIX}_TRAEFIK_MIDDLEWARES=global-chain@file

# Health Check Configuration
${APP_PREFIX}_HEALTHCHECK_INTERVAL=30s
${APP_PREFIX}_HEALTHCHECK_TIMEOUT=10s
${APP_PREFIX}_HEALTHCHECK_RETRIES=3
${APP_PREFIX}_HEALTHCHECK_START_PERIOD=60s
EOF

echo ""
echo "Next steps:"
echo "1. Review extracted values above"
echo "2. Create ${APP_DIR}/.${APP_NAME}.env.example"
echo "3. Run: ./scripts/security/validate-app-config.sh ${APP_NAME}"
echo ""
