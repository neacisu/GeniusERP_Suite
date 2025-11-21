#!/usr/bin/env bash
set -euo pipefail

WATCHER_NAME="db-creds-renew"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
ROLES_MANIFEST=${ROLES_MANIFEST:-"${ROOT_DIR}/database/roles/roles.json"}
METRICS_DIR=${METRICS_DIR:-"${ROOT_DIR}/shared/observability/metrics/watchers"}
METRICS_FILE="${METRICS_DIR}/${WATCHER_NAME}.prom"
LOG_PREFIX="[${WATCHER_NAME}]"
LEASE_THRESHOLD_SECONDS=${LEASE_THRESHOLD_SECONDS:-300}
LEASE_RENEW_INCREMENT=${LEASE_RENEW_INCREMENT:-3600}
WATCH_INTERVAL_SECONDS=${WATCH_INTERVAL_SECONDS:-0}
WATCHER_ROLES=${WATCHER_ROLES:-}
PROCESS_SUPERVISOR_PID_FILE=${PROCESS_SUPERVISOR_PID_FILE:-}

REQUIRED_CMDS=("bao" "jq" "date" "mktemp")

usage() {
  cat <<'EOF'
Usage: scripts/security/watchers/db-creds-renew.sh

Environment variables:
  BAO_ADDR / BAO_TOKEN         - OpenBao endpoint and token (required)
  WATCHER_ROLES                - Comma separated roles to monitor (default: all roles from roles.json)
  ROLES_MANIFEST               - Override path to roles manifest
  LEASE_THRESHOLD_SECONDS      - TTL threshold before renew (default: 300)
  LEASE_RENEW_INCREMENT        - Increment requested on renew (default: 3600)
  WATCH_INTERVAL_SECONDS       - If >0, run continuously with the provided sleep interval
  METRICS_DIR                  - Directory for Prometheus textfile output
  PROCESS_SUPERVISOR_PID_FILE  - Optional file containing PID for Process Supervisor (HUP on renew)
EOF
}

log() {
  local level="$1"; shift
  local timestamp
  timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "${LOG_PREFIX} ${timestamp} [${level}] $*"
}

require_commands() {
  local missing=0 cmd
  for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      log "error" "Missing required command: $cmd"
      missing=1
    fi
  done
  if [[ $missing -eq 1 ]]; then
    exit 1
  fi
}

load_roles() {
  if [[ -n "$WATCHER_ROLES" ]]; then
    echo "$WATCHER_ROLES" | tr ',' '\n' | awk 'NF'
    return
  fi

  if [[ ! -f "$ROLES_MANIFEST" ]]; then
    log "error" "Roles manifest not found: ${ROLES_MANIFEST}"
    exit 1
  fi

  jq -r '.roles[].name' "$ROLES_MANIFEST"
}

list_lease_ids() {
  local role="$1"
  local stdout_file stderr_file
  stdout_file="$(mktemp)"
  stderr_file="$(mktemp)"

  if bao list -format=json "sys/leases/lookup/database/creds/${role}" >"$stdout_file" 2>"$stderr_file"; then
    if jq -e 'type == "array"' "$stdout_file" >/dev/null 2>&1; then
      jq -r '.[]?' "$stdout_file"
    else
      jq -r '.data.keys[]?' "$stdout_file" 2>/dev/null || true
    fi
  else
    local err
    err="$(tr -d '\n' <"$stderr_file")"
    if [[ -n "$err" ]] && ! [[ "$err" =~ (no\ value\ found|unsupported|not\ found) ]]; then
      log "warn" "Unable to list leases for role ${role}: ${err}"
    else
      log "debug" "No leases currently active for role ${role}"
    fi
  fi

  rm -f "$stdout_file" "$stderr_file"
}

write_metrics() {
  local total="${1:-0}" expiring="${2:-0}" renewed="${3:-0}" failed="${4:-0}" soonest="${5:-0}"
  local roles_ref="$6" totals_ref="$7" exp_ref="$8" renewed_ref="$9"

  local -n _roles="$roles_ref"
  local -n _totals="$totals_ref"
  local -n _expiring="$exp_ref"
  local -n _renewed="$renewed_ref"

  local timestamp
  timestamp="$(date +%s)"

  mkdir -p "$METRICS_DIR"
  local tmp_file
  tmp_file="$(mktemp)"
  {
    echo "# HELP openbao_db_leases_discovered_total Count of active database leases discovered by ${WATCHER_NAME}"
    echo "# TYPE openbao_db_leases_discovered_total gauge"
    echo "openbao_db_leases_discovered_total ${total}"
    echo "# HELP openbao_db_leases_expiring_total Count of leases below renewal threshold"
    echo "# TYPE openbao_db_leases_expiring_total gauge"
    echo "openbao_db_leases_expiring_total ${expiring}"
    echo "# HELP openbao_db_leases_renewed_total Number of leases renewed in the last cycle"
    echo "# TYPE openbao_db_leases_renewed_total gauge"
    echo "openbao_db_leases_renewed_total ${renewed}"
    echo "# HELP openbao_db_lease_operations_failed_total Failed lease lookup or renew operations"
    echo "# TYPE openbao_db_lease_operations_failed_total counter"
    echo "openbao_db_lease_operations_failed_total ${failed}"
    echo "# HELP openbao_db_lease_next_expiration_seconds Seconds until the soonest lease expires"
    echo "# TYPE openbao_db_lease_next_expiration_seconds gauge"
    echo "openbao_db_lease_next_expiration_seconds ${soonest}"
    echo "# HELP openbao_db_role_active_leases Active leases per role"
    echo "# TYPE openbao_db_role_active_leases gauge"
    for role in "${_roles[@]}"; do
      echo "openbao_db_role_active_leases{role=\"${role}\"} ${_totals[$role]:-0}"
    done
    echo "# HELP openbao_db_role_expiring_leases Leases per role that breached the threshold"
    echo "# TYPE openbao_db_role_expiring_leases gauge"
    for role in "${_roles[@]}"; do
      echo "openbao_db_role_expiring_leases{role=\"${role}\"} ${_expiring[$role]:-0}"
    done
    echo "# HELP openbao_db_role_renewed_leases Renew operations per role in the last cycle"
    echo "# TYPE openbao_db_role_renewed_leases counter"
    for role in "${_roles[@]}"; do
      echo "openbao_db_role_renewed_leases{role=\"${role}\"} ${_renewed[$role]:-0}"
    done
    echo "# HELP openbao_db_watcher_last_run_timestamp Unix timestamp for the last successful run"
    echo "# TYPE openbao_db_watcher_last_run_timestamp gauge"
    echo "openbao_db_watcher_last_run_timestamp ${timestamp}"
  } >"$tmp_file"
  mv "$tmp_file" "$METRICS_FILE"
}

signal_supervisor() {
  local reason="$1"
  if [[ -z "$PROCESS_SUPERVISOR_PID_FILE" || ! -s "$PROCESS_SUPERVISOR_PID_FILE" ]]; then
    return
  fi

  local pid
  pid="$(tr -cd '0-9' <"$PROCESS_SUPERVISOR_PID_FILE")"
  if [[ -z "$pid" ]]; then
    log "warn" "Supervisor PID file is invalid: ${PROCESS_SUPERVISOR_PID_FILE}"
    return
  fi

  if kill -0 "$pid" >/dev/null 2>&1; then
    if kill -HUP "$pid" >/dev/null 2>&1; then
      log "info" "Sent HUP to Process Supervisor (pid=${pid}, reason=${reason})"
    else
      log "warn" "Failed to signal Process Supervisor (pid=${pid})"
    fi
  else
    log "warn" "Process Supervisor pid ${pid} not running"
  fi
}

run_cycle() {
  local -a roles_list=("$@")
  local -A role_total=()
  local -A role_expiring=()
  local -A role_renewed=()

  local total=0
  local expiring=0
  local renewed=0
  local failed=0
  local soonest=-1
  local had_renewal=0

  for role in "${roles_list[@]}"; do
    mapfile -t leases < <(list_lease_ids "$role") || true
    role_total["$role"]=${#leases[@]}
    if [[ ${#leases[@]} -eq 0 ]]; then
      continue
    fi

    for lease_suffix in "${leases[@]}"; do
      [[ -z "$lease_suffix" ]] && continue
      local lease_id="database/creds/${role}/${lease_suffix}"
      local lookup_json lookup_err
      lookup_err="$(mktemp)"
      if ! lookup_json=$(bao lease lookup -format=json "$lease_id" 2>"$lookup_err"); then
        local err_msg
        err_msg="$(tr -d '\n' <"$lookup_err")"
        rm -f "$lookup_err"
        log "warn" "Failed to lookup lease ${lease_id}: ${err_msg}"
        ((failed += 1))
        continue
      fi
      rm -f "$lookup_err"

      local ttl renewable_flag
      ttl="$(echo "$lookup_json" | jq -r '.data.ttl // 0')"
      renewable_flag="$(echo "$lookup_json" | jq -r '.data.renewable // false')"
      if [[ "$ttl" == "null" || -z "$ttl" ]]; then
        ttl=0
      fi
      ttl=$((ttl))

      ((total += 1))
      if (( soonest == -1 || ttl < soonest )); then
        soonest=$ttl
      fi

      if [[ "$renewable_flag" != "true" ]]; then
        continue
      fi

      if (( ttl <= LEASE_THRESHOLD_SECONDS )); then
        role_expiring["$role"]=$(( ${role_expiring[$role]:-0} + 1 ))
        ((expiring += 1))
        local renew_json renew_err
        renew_err="$(mktemp)"
        if renew_json=$(bao lease renew -format=json -increment "${LEASE_RENEW_INCREMENT}" "$lease_id" 2>"$renew_err"); then
          rm -f "$renew_err"
          local new_ttl
          new_ttl="$(echo "$renew_json" | jq -r '.lease_duration // 0')"
          role_renewed["$role"]=$(( ${role_renewed[$role]:-0} + 1 ))
          ((renewed += 1))
          had_renewal=1
          if [[ -n "$new_ttl" && "$new_ttl" != "null" ]]; then
            new_ttl=$((new_ttl))
            if (( soonest == -1 || new_ttl < soonest )); then
              soonest=$new_ttl
            fi
          fi
          log "info" "Lease ${lease_id} renewed (ttl=${new_ttl:-unknown}s)"
        else
          local renew_msg
          renew_msg="$(tr -d '\n' <"$renew_err")"
          rm -f "$renew_err"
          log "warn" "Lease renew failed for ${lease_id}: ${renew_msg}"
          ((failed += 1))
        fi
      fi
    done
  done

  if (( soonest < 0 )); then
    soonest=0
  fi

  write_metrics "$total" "$expiring" "$renewed" "$failed" "$soonest" roles_list role_total role_expiring role_renewed

  if (( had_renewal == 1 )); then
    signal_supervisor "lease_renewed"
  fi

  log "info" "cycle completed total=${total} expiring=${expiring} renewed=${renewed} failed=${failed}"
}

main() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
  fi

  require_commands

  mapfile -t roles < <(load_roles)
  if [[ ${#roles[@]} -eq 0 ]]; then
    log "warn" "No roles provided. Nothing to renew."
    exit 0
  fi

  if [[ "$WATCH_INTERVAL_SECONDS" -gt 0 ]]; then
    log "info" "Starting watcher loop (interval=${WATCH_INTERVAL_SECONDS}s, roles=${#roles[@]})"
    while true; do
      run_cycle "${roles[@]}"
      sleep "$WATCH_INTERVAL_SECONDS"
    done
  else
    log "info" "Running single renewal cycle (roles=${#roles[@]})"
    run_cycle "${roles[@]}"
  fi
}

main "$@"

