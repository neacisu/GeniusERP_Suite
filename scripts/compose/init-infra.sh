#!/bin/bash
# ============================================================================
# GeniusSuite - Init Infrastructură Docker (F0.4.19)
# ============================================================================
# Creează toate rețelele "external: true" și volumele persistente
# definite în fazele F0.4.1 – F0.4.18 pentru modelul hibrid Compose.
# Poate fi rulat de oricâte ori; operațiile sunt idempotente.
# ============================================================================

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

if ! command -v docker >/dev/null 2>&1; then
  echo "[ERROR] Docker nu este instalat sau nu este în PATH" >&2
  exit 1
fi

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1"
}

info() {
  printf '   • %s\n' "$1"
}

warn() {
  printf '   ! %s\n' "$1"
}

PROXY_ENV_FILE="proxy/.proxy.env"
if [ -f "$PROXY_ENV_FILE" ]; then
  # shellcheck disable=SC1090
  source "$PROXY_ENV_FILE"
else
  warn "proxy/.proxy.env lipsește – folosesc denumirile implicite ale rețelelor"
fi

NET_EDGE_NAME="${PROXY_NETWORK_EDGE:-geniuserp_net_edge}"
NET_INTERNAL_NAME="${PROXY_NETWORK_INTERNAL:-geniuserp_net_suite_internal}"
NET_BACKING_NAME="${PROXY_NETWORK_BACKING_SERVICES:-geniuserp_net_backing_services}"
NET_OBS_NAME="${PROXY_NETWORK_OBSERVABILITY:-geniuserp_net_observability}"

declare -A NETWORKS=(
  ["$NET_EDGE_NAME"]="172.20.0.0/16"
  ["$NET_INTERNAL_NAME"]="172.21.0.0/16"
  ["$NET_BACKING_NAME"]="172.22.0.0/16"
  ["$NET_OBS_NAME"]="172.23.0.0/16"
)

VOLUMES=(
  gs_traefik_certs
  gs_prometheus_data
  gs_grafana_data
  gs_loki_data
  gs_tempo_data
  geniuserp_pgdata_identity
  geniuserp_pgdata_licensing
  geniuserp_pgdata_temporal
  geniuserp_pgdata_archify
  geniuserp_pgdata_cerniq
  geniuserp_pgdata_flowxify
  geniuserp_pgdata_iwms
  geniuserp_pgdata_mercantiq
  geniuserp_pgdata_numeriqo
  geniuserp_pgdata_triggerra
  geniuserp_pgdata_vettify
  geniuserp_pgdata_geniuserp
  geniuserp_pgdata_admin
  geniuserp_kafka_data
  geniuserp_neo4j_data
  archify_storage_originals
)

declare -A VOLUME_PERMISSIONS=(
  ["archify_storage_originals"]="1001|1001|750"
  ["gs_loki_data"]="10001|10001|770"
)

ensure_volume_permissions() {
  local volume="$1"
  local spec="$2"
  local uid gid mode

  IFS='|' read -r uid gid mode <<<"$spec"

  if ! docker volume inspect "$volume" >/dev/null 2>&1; then
    warn "Volumul $volume nu există – sar peste configurarea permisiunilor"
    return
  fi

  info "Aplic permisiuni ${uid}:${gid} (chmod ${mode}) pentru $volume"
  docker run --rm -v "$volume":/data alpine:3.20 \
    sh -c "chown -R ${uid}:${gid} /data && chmod ${mode} /data" >/dev/null
}

log "=== Verific rețelele Docker necesare (F0.4.2) ==="
for network in "${!NETWORKS[@]}"; do
  subnet="${NETWORKS[$network]}"
  if docker network inspect "$network" >/dev/null 2>&1; then
    info "Rețeaua $network există deja"
  else
    info "Creez $network (subnet $subnet)"
    docker network create --driver bridge --subnet "$subnet" "$network"
  fi
done

log "=== Verific volumele persistente (F0.4.1) ==="
for volume in "${VOLUMES[@]}"; do
  if docker volume inspect "$volume" >/dev/null 2>&1; then
    info "Volumul $volume există deja"
  else
    info "Creez volumul $volume"
    docker volume create "$volume" >/dev/null
  fi
done

log "=== Aplic permisiuni explicite pentru volume sensibile ==="
for volume in "${!VOLUME_PERMISSIONS[@]}"; do
  ensure_volume_permissions "$volume" "${VOLUME_PERMISSIONS[$volume]}"
done

log "✓ Infrastructura Docker (rețele + volume) este pregătită pentru modelul hibrid"
