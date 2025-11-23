#!/bin/sh
#
# start-app.sh - Process Supervisor entrypoint for geniuserp
# Launched by OpenBao Agent after secrets are rendered
#
set -e

echo "[Process Supervisor] Starting geniuserp application..."
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
if [ -z "$GENIUSERP_DB_USER" ] || [ -z "$GENIUSERP_DB_PASS" ]; then
    echo "[Process Supervisor] ERROR: Database credentials not injected!"
    exit 1
fi

if [ -z "$GENIUSERP_JWT_SECRET" ]; then
    echo "[Process Supervisor] ERROR: JWT secret not injected!"
    exit 1
fi

echo "[Process Supervisor] ✓ All secrets validated"
echo "[Process Supervisor] ✓ Database user: $GENIUSERP_DB_USER"
echo "[Process Supervisor] ✓ Starting Node.js application..."

# Start the Node.js application
exec node dist/geniuserp.app/src/index.js
