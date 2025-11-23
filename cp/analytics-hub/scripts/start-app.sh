#!/usr/bin/env bash
# Process Supervisor launcher for CP Analytics Hub
set -eu

ENV_FILE="/app/secrets/.env"
APP_NAME="cp-analytics-hub"
APP_DIST_DIR="/app/cp/analytics-hub/dist"
APP_PACKAGE_SUBPATH="cp/analytics-hub"

log() {
  printf '[Process Supervisor][%s] %s\n' "$APP_NAME" "$1"
}

if [ ! -f "$ENV_FILE" ]; then
  log "ERROR: missing $ENV_FILE"
  exit 1
fi

log "Loading secrets from $ENV_FILE"
set -a
# shellcheck disable=SC1090
. "$ENV_FILE"
set +a

for var in CP_ANLY_DB_POSTGRES_URL CP_ANLY_AUTH_JWT_SECRET CP_ANLY_DB_CLICKHOUSE_PASS CP_ANLY_DB_ELASTICSEARCH_PASS; do
  if [ -z "${!var:-}" ]; then
    log "ERROR: secret $var nu este injectat"
    exit 1
  fi
done

log "✓ Secrets validate"

ENTRYPOINT=""
for candidate in main.js src/main.js index.js \
  "$APP_PACKAGE_SUBPATH/main.js" \
  "$APP_PACKAGE_SUBPATH/src/main.js" \
  "$APP_PACKAGE_SUBPATH/index.js"; do
  if [ -f "$APP_DIST_DIR/$candidate" ]; then
    ENTRYPOINT="$APP_DIST_DIR/$candidate"
    break
  fi
done

if [ -z "$ENTRYPOINT" ]; then
  log "ERROR: nu găsesc fișierul dist/*.js"
  ls -R "$APP_DIST_DIR"
  exit 1
fi

log "Pornesc Node.js: $ENTRYPOINT"
exec node "$ENTRYPOINT"
