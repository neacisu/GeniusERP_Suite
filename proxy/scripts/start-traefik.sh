#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="/app/secrets/.env"
SECRETS_DIR="/run/traefik/secrets"
DASHBOARD_USERS_FILE="${SECRETS_DIR}/dashboard-users"

log() {
  printf '[Traefik Supervisor] %s\n' "$1"
}

if [[ ! -f "$ENV_FILE" ]]; then
  log "ERROR: missing $ENV_FILE"
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

if [[ -z "${PROXY_DASHBOARD_USER:-}" ]]; then
  log "ERROR: PROXY_DASHBOARD_USER env missing"
  exit 1
fi

if [[ -z "${PROXY_DASHBOARD_PASS:-}" ]]; then
  log "ERROR: PROXY_DASHBOARD_PASS secret missing"
  exit 1
fi

mkdir -p "$SECRETS_DIR"
htpasswd -nbB "$PROXY_DASHBOARD_USER" "$PROXY_DASHBOARD_PASS" > "$DASHBOARD_USERS_FILE"
chmod 600 "$DASHBOARD_USERS_FILE"

if [[ -n "${PROXY_CF_API_TOKEN:-}" ]]; then
  export CF_DNS_API_TOKEN="$PROXY_CF_API_TOKEN"
  export CF_API_TOKEN="$PROXY_CF_API_TOKEN"
fi

TRAEFIK_ARGS=(
  "--configFile=/etc/traefik/traefik.yml"
  "--providers.docker.exposedbydefault=false"
  "--providers.docker.network=${PROXY_NETWORK_INTERNAL:-geniuserp_net_suite_internal}"
  "--providers.docker.endpoint=unix:///var/run/docker.sock"
  "--certificatesresolvers.letsencrypt.acme.email=${PROXY_TLS_ACME_EMAIL}"
  "--certificatesresolvers.letsencrypt.acme.storage=${PROXY_ACME_STORAGE:-/letsencrypt/acme.json}"
  "--certificatesresolvers.letsencrypt.acme.caserver=${PROXY_TLS_ACME_CA_SERVER:-https://acme-v02.api.letsencrypt.org/directory}"
  "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web"
)

log "Launching Traefik"
exec traefik "${TRAEFIK_ARGS[@]}"
