#!/usr/bin/env bash
# Process Supervisor launcher for CP Suite Login
set -eu

ENV_FILE="/app/secrets/.env"
APP_NAME="cp-suite-login"
APP_DIST_DIR="/app/dist"

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

for var in CP_LOGIN_AUTH_JWT_SECRET CP_LOGIN_APP_PORT CP_LOGIN_OBS_SERVICE_NAME; do
  if [ -z "${!var:-}" ]; then
    log "ERROR: secret/config $var nu este injectat"
    exit 1
  fi
done

ENTRYPOINT=""
for candidate in main.js src/main.js index.js; do
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
