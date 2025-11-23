#!/bin/sh
#
# start-app.sh - Process Supervisor entrypoint for cerniq
# Launched by OpenBao Agent after secrets are rendered
#
set -e

echo "[Process Supervisor] Starting cerniq application..."
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
if [ -z "$CERNIQ_DB_USER" ] || [ -z "$CERNIQ_DB_PASS" ]; then
    echo "[Process Supervisor] ERROR: Database credentials not injected!"
    exit 1
fi

if [ -z "$CERNIQ_JWT_SECRET" ]; then
    echo "[Process Supervisor] ERROR: JWT secret not injected!"
    exit 1
fi

echo "[Process Supervisor] ✓ All secrets validated"
echo "[Process Supervisor] ✓ Database user: $CERNIQ_DB_USER"
echo "[Process Supervisor] ✓ Starting Node.js application..."

# Start the Node.js application
exec node dist/cerniq.app/src/index.js
