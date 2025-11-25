#!/usr/bin/env bash
#
# test-f05-chaos.sh - Chaos testing for F0.5 Security Architecture
#
# Scenarios (per target):
# 1. Secret Injection: Verify target container rendered secrets from OpenBao.
# 2. Chaos: Stop OpenBao, ensure target stays healthy with cached secrets.
# 3. Recovery: Restart & auto-unseal OpenBao, confirm target still running.
#
# Enhancements:
#  - Supports running against every Process Supervisor workload (CP modules, stand-alone apps, proxy).
#  - Validates AppRole material and env prerequisites automatically (no manual exports required).
#  - Verifies external Docker volumes (gs_*) before starting chaos runs.
#  - Accepts `all` (default) to run the suite sequentially with a consolidated summary.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
ROOT_COMPOSE_FILE="${REPO_ROOT}/compose.yml"
SECRETS_ROOT="${REPO_ROOT}/.secrets/approle"
OPENBAO_KEYS="${REPO_ROOT}/.secrets/openbao-keys.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

TARGET_INPUT="${1:-all}"

ALL_TARGETS=(
  proxy
  numeriqo
  archify
  mercantiq
  flowxify
  triggerra
  cerniq
  iwms
  vettify
  geniuserp
  cp-identity
  cp-licensing
  cp-suite-admin
  cp-suite-shell
  cp-suite-login
  cp-ai-hub
  cp-analytics-hub
)

# Global docker volumes declared in root compose (must exist before tests)
GLOBAL_VOLUMES=(
  gs_traefik_certs
  gs_prometheus_data
  gs_grafana_data
  gs_loki_data
  gs_tempo_data
  gs_pgdata_identity
  gs_pgdata_licensing
  gs_pgdata_temporal
  gs_pgdata_archify
  gs_pgdata_cerniq
  gs_pgdata_flowxify
  gs_pgdata_iwms
  gs_pgdata_mercantiq
  gs_pgdata_numeriqo
  gs_pgdata_triggerra
  gs_pgdata_vettify
  gs_pgdata_geniuserp
  gs_pgdata_admin
  gs_kafka_data
  gs_neo4j_data
  gs_openbao_data
)

CURRENT_COMPOSE_FILE=""
APP=""
APP_SERVICE=""
SECRET_FILE=""
REQUIRED_ENV_STRING=""
REQUIRED_VOLUMES_STRING=""
ROLE_ID_VAR=""
SECRET_ID_VAR=""
ROLE_ID_FALLBACK=""
SECRET_ID_FALLBACK=""
APPROLE_NAME=""
APPROLE_POLICY=""

SUMMARY_LINES=()

BAO_TOKEN="${BAO_TOKEN:-}"

ensure_openbao_running() {
    docker compose -f "$ROOT_COMPOSE_FILE" up -d openbao >/dev/null
}

ensure_bao_token() {
    if [[ -n "$BAO_TOKEN" ]]; then
        export BAO_TOKEN
        return
    fi
    if command -v jq >/dev/null 2>&1 && [[ -f "$OPENBAO_KEYS" ]]; then
        BAO_TOKEN=$(jq -r '.root_token' "$OPENBAO_KEYS")
        export BAO_TOKEN
        echo -e "${YELLOW}ℹ Loaded BAO_TOKEN from ${OPENBAO_KEYS}${NC}"
    else
        echo -e "${RED}BAO_TOKEN not set and ${OPENBAO_KEYS} missing. Export BAO_TOKEN before running chaos tests.${NC}" >&2
        exit 1
    fi
}

bao_exec() {
    docker exec \
        -e BAO_ADDR="${BAO_ADDR:-http://127.0.0.1:8200}" \
        -e BAO_TOKEN="${BAO_TOKEN}" \
        geniuserp-openbao bao "$@"
}

publish_policy() {
    local policy_name="$1" policy_file="$2"
    local remote_path="/tmp/${policy_name}.hcl"
    docker cp "$policy_file" "geniuserp-openbao:${remote_path}"
    bao_exec policy write "$policy_name" "$remote_path" >/dev/null
    docker exec geniuserp-openbao rm -f "$remote_path" >/dev/null 2>&1 || true
}

provision_approle_if_needed() {
    local role_name="$1" policy_name="$2" role_path="$3" secret_path="$4"
    if [[ -f "$role_path" && -f "$secret_path" ]]; then
        return
    fi

    ensure_openbao_running
    ensure_bao_token

    local policy_file="${REPO_ROOT}/scripts/security/policies/${policy_name}.hcl"
    if [[ ! -f "$policy_file" ]]; then
        echo -e "${RED}Missing policy file: ${policy_file}${NC}" >&2
        exit 1
    fi
    publish_policy "$policy_name" "$policy_file"

    bao_exec write "auth/approle/role/${role_name}" \
        token_policies="${policy_name}" \
        token_ttl="1h" \
        token_max_ttl="4h" \
        secret_id_ttl="0" \
        bind_secret_id="true" >/dev/null

    local role_id secret_id role_dir
    role_dir="$(dirname "$role_path")"
    mkdir -p "$role_dir"
    role_id=$(bao_exec read -field=role_id "auth/approle/role/${role_name}/role-id")
    secret_id=$(bao_exec write -field=secret_id -f "auth/approle/role/${role_name}/secret-id")
    printf '%s' "$role_id" > "$role_path"
    printf '%s' "$secret_id" > "$secret_path"
    chmod 600 "$role_path" "$secret_path"
    chown 1001:1001 "$role_path" "$secret_path" 2>/dev/null || true
}

ensure_target_approle_credentials() {
    if [[ -z "$APPROLE_NAME" || -z "$APPROLE_POLICY" ]]; then
        return
    fi
    provision_approle_if_needed "$APPROLE_NAME" "$APPROLE_POLICY" "$ROLE_ID_FALLBACK" "$SECRET_ID_FALLBACK"
    if [[ -n "$ROLE_ID_VAR" && -n "$ROLE_ID_FALLBACK" ]]; then
        printf -v "$ROLE_ID_VAR" '%s' "$ROLE_ID_FALLBACK"
        export "$ROLE_ID_VAR"
    fi
    if [[ -n "$SECRET_ID_VAR" && -n "$SECRET_ID_FALLBACK" ]]; then
        printf -v "$SECRET_ID_VAR" '%s' "$SECRET_ID_FALLBACK"
        export "$SECRET_ID_VAR"
    fi
}

compose_cmd() {
    docker compose -f "$CURRENT_COMPOSE_FILE" "$@"
}

ensure_env_files() {
    local raw="$1"
    IFS='|' read -ra envs <<< "$raw"
    for rel in "${envs[@]}"; do
        [[ -z "$rel" ]] && continue
        local path="${REPO_ROOT}/${rel}"
        if [[ ! -f "$path" ]]; then
            echo -e "${RED}Missing required env file: ${rel}${NC}" >&2
            exit 1
        fi
    done
}
load_env_files() {
    local raw="$1"
    IFS='|' read -ra envs <<< "$raw"
    for rel in "${envs[@]}"; do
        [[ -z "$rel" ]] && continue
        local path="${REPO_ROOT}/${rel}"
        if [[ -f "$path" ]]; then
            set -a
            # shellcheck disable=SC1090
            source "$path"
            set +a
        fi
    done
}

ensure_target_volumes() {
    local raw="$1"
    IFS='|' read -ra vols <<< "$raw"
    for vol in "${vols[@]}"; do
        [[ -z "$vol" ]] && continue
        if ! docker volume inspect "$vol" >/dev/null 2>&1; then
            echo -e "${YELLOW}Creating missing volume: ${vol}${NC}"
            docker volume create "$vol" >/dev/null
        fi
    done
}

ensure_approle_paths() {
    local var_name="$1" fallback="$2"
    if [[ -z "$var_name" ]]; then
        return
    fi
    local current_value="${!var_name:-}"
    if [[ -z "$current_value" ]]; then
        if [[ -f "$fallback" ]]; then
            printf -v "$var_name" '%s' "$fallback"
        else
            echo -e "${RED}Missing AppRole material: ${fallback}${NC}" >&2
            echo -e "${YELLOW}Run scripts/security/setup_cp_approles.sh or seed AppRole credentials first.${NC}"
            exit 1
        fi
    fi
    export "$var_name"
}

check_service_up() {
    compose_cmd ps "$APP_SERVICE" | grep -q "Up"
}

ensure_service_running() {
    echo -e "${BLUE}▶ Ensuring ${APP} service is running...${NC}"
    compose_cmd up -d "$APP_SERVICE"
    sleep 8
}

stop_openbao() {
    docker compose -f "$ROOT_COMPOSE_FILE" stop openbao >/dev/null
}

start_openbao() {
    docker compose -f "$ROOT_COMPOSE_FILE" start openbao >/dev/null
    sleep 5
    BAO_ADDR=${BAO_ADDR:-"http://127.0.0.1:8200"} bash "${SCRIPT_DIR}/openbao-init.sh" >/dev/null
}

verify_global_volumes() {
    for vol in "${GLOBAL_VOLUMES[@]}"; do
        if ! docker volume inspect "$vol" >/dev/null 2>&1; then
            echo -e "${YELLOW}Creating global volume: ${vol}${NC}"
            docker volume create "$vol" >/dev/null
        fi
    done
}

load_target_config() {
    local target="$1"
    case "$target" in
        proxy)
            APP="proxy"
            APP_SERVICE="proxy"
            CURRENT_COMPOSE_FILE="$ROOT_COMPOSE_FILE"
            REQUIRED_ENV_STRING="proxy/.proxy.env"
            SECRET_FILE="/run/traefik/secrets/dashboard-users"
            REQUIRED_VOLUMES_STRING="gs_traefik_certs"
            ROLE_ID_VAR="PROXY_APPROLE_ROLE_ID_PATH"
            SECRET_ID_VAR="PROXY_APPROLE_SECRET_ID_PATH"
            ROLE_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/proxy/role-id"
            SECRET_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/proxy/secret-id"
            APPROLE_NAME="proxy"
            APPROLE_POLICY="proxy-read"
            ;;
        numeriqo)
            APP="numeriqo.app"
            APP_SERVICE="numeriqo-app"
            CURRENT_COMPOSE_FILE="${REPO_ROOT}/numeriqo.app/compose/docker-compose.yml"
            REQUIRED_ENV_STRING=".suite.general.env|numeriqo.app/.numeriqo.env"
            SECRET_FILE="/app/secrets/.env"
            REQUIRED_VOLUMES_STRING=""
            ROLE_ID_VAR="NUMQ_APPROLE_ROLE_ID_PATH"
            SECRET_ID_VAR="NUMQ_APPROLE_SECRET_ID_PATH"
            ROLE_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/numeriqo/role-id"
            SECRET_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/numeriqo/secret-id"
            APPROLE_NAME="numeriqo"
            APPROLE_POLICY="numeriqo-read"
            ;;
        archify)
            APP="archify.app"
            APP_SERVICE="archify-app"
            CURRENT_COMPOSE_FILE="${REPO_ROOT}/archify.app/compose/docker-compose.yml"
            REQUIRED_ENV_STRING=".suite.general.env|archify.app/.archify.env"
            SECRET_FILE="/app/secrets/.env"
            REQUIRED_VOLUMES_STRING="archify_storage_originals"
            ROLE_ID_VAR="ARCHY_APPROLE_ROLE_ID_PATH"
            SECRET_ID_VAR="ARCHY_APPROLE_SECRET_ID_PATH"
            ROLE_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/archify/role-id"
            SECRET_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/archify/secret-id"
            APPROLE_NAME="archify"
            APPROLE_POLICY="archify-read"
            ;;
        mercantiq)
            APP="mercantiq.app"
            APP_SERVICE="mercantiq-app"
            CURRENT_COMPOSE_FILE="${REPO_ROOT}/mercantiq.app/compose/docker-compose.yml"
            REQUIRED_ENV_STRING=".suite.general.env|mercantiq.app/.mercantiq.env"
            SECRET_FILE="/app/secrets/.env"
            REQUIRED_VOLUMES_STRING=""
            ROLE_ID_VAR="MERCQ_APPROLE_ROLE_ID_PATH"
            SECRET_ID_VAR="MERCQ_APPROLE_SECRET_ID_PATH"
            ROLE_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/mercantiq/role-id"
            SECRET_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/mercantiq/secret-id"
            APPROLE_NAME="mercantiq"
            APPROLE_POLICY="mercantiq-read"
            ;;
        flowxify)
            APP="flowxify.app"
            APP_SERVICE="flowxify-app"
            CURRENT_COMPOSE_FILE="${REPO_ROOT}/flowxify.app/compose/docker-compose.yml"
            REQUIRED_ENV_STRING=".suite.general.env|flowxify.app/.flowxify.env"
            SECRET_FILE="/app/secrets/.env"
            REQUIRED_VOLUMES_STRING=""
            ROLE_ID_VAR="FLOWX_APPROLE_ROLE_ID_PATH"
            SECRET_ID_VAR="FLOWX_APPROLE_SECRET_ID_PATH"
            ROLE_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/flowxify/role-id"
            SECRET_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/flowxify/secret-id"
            APPROLE_NAME="flowxify"
            APPROLE_POLICY="flowxify-read"
            ;;
        triggerra)
            APP="triggerra.app"
            APP_SERVICE="triggerra-app"
            CURRENT_COMPOSE_FILE="${REPO_ROOT}/triggerra.app/compose/docker-compose.yml"
            REQUIRED_ENV_STRING=".suite.general.env|triggerra.app/.triggerra.env"
            SECRET_FILE="/app/secrets/.env"
            REQUIRED_VOLUMES_STRING=""
            ROLE_ID_VAR="TRIGR_APPROLE_ROLE_ID_PATH"
            SECRET_ID_VAR="TRIGR_APPROLE_SECRET_ID_PATH"
            ROLE_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/triggerra/role-id"
            SECRET_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/triggerra/secret-id"
            APPROLE_NAME="triggerra"
            APPROLE_POLICY="triggerra-read"
            ;;
        cerniq)
            APP="cerniq.app"
            APP_SERVICE="cerniq-app"
            CURRENT_COMPOSE_FILE="${REPO_ROOT}/cerniq.app/compose/docker-compose.yml"
            REQUIRED_ENV_STRING=".suite.general.env|cerniq.app/.cerniq.env"
            SECRET_FILE="/app/secrets/.env"
            REQUIRED_VOLUMES_STRING=""
            ROLE_ID_VAR="CERNIQ_APPROLE_ROLE_ID_PATH"
            SECRET_ID_VAR="CERNIQ_APPROLE_SECRET_ID_PATH"
            ROLE_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/cerniq/role-id"
            SECRET_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/cerniq/secret-id"
            APPROLE_NAME="cerniq"
            APPROLE_POLICY="cerniq-read"
            ;;
        iwms)
            APP="i-wms.app"
            APP_SERVICE="i-wms-app"
            CURRENT_COMPOSE_FILE="${REPO_ROOT}/i-wms.app/compose/docker-compose.yml"
            REQUIRED_ENV_STRING=".suite.general.env|i-wms.app/.i-wms.env"
            SECRET_FILE="/app/secrets/.env"
            REQUIRED_VOLUMES_STRING=""
            ROLE_ID_VAR="IWMS_APPROLE_ROLE_ID_PATH"
            SECRET_ID_VAR="IWMS_APPROLE_SECRET_ID_PATH"
            ROLE_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/i-wms/role-id"
            SECRET_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/i-wms/secret-id"
            APPROLE_NAME="i-wms"
            APPROLE_POLICY="i-wms-read"
            ;;
        vettify)
            APP="vettify.app"
            APP_SERVICE="vettify-app"
            CURRENT_COMPOSE_FILE="${REPO_ROOT}/vettify.app/compose/docker-compose.yml"
            REQUIRED_ENV_STRING=".suite.general.env|vettify.app/.vettify.env"
            SECRET_FILE="/app/secrets/.env"
            REQUIRED_VOLUMES_STRING=""
            ROLE_ID_VAR="VETFY_APPROLE_ROLE_ID_PATH"
            SECRET_ID_VAR="VETFY_APPROLE_SECRET_ID_PATH"
            ROLE_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/vettify/role-id"
            SECRET_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/vettify/secret-id"
            APPROLE_NAME="vettify"
            APPROLE_POLICY="vettify-read"
            ;;
        geniuserp)
            APP="geniuserp.app"
            APP_SERVICE="geniuserp-app"
            CURRENT_COMPOSE_FILE="${REPO_ROOT}/geniuserp.app/compose/docker-compose.yml"
            REQUIRED_ENV_STRING=".suite.general.env|geniuserp.app/.geniuserp.env"
            SECRET_FILE="/app/secrets/.env"
            REQUIRED_VOLUMES_STRING=""
            ROLE_ID_VAR="GENERP_APPROLE_ROLE_ID_PATH"
            SECRET_ID_VAR="GENERP_APPROLE_SECRET_ID_PATH"
            ROLE_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/geniuserp/role-id"
            SECRET_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/geniuserp/secret-id"
            APPROLE_NAME="geniuserp"
            APPROLE_POLICY="geniuserp-read"
            ;;
        cp-identity)
            APP="cp/identity"
            APP_SERVICE="identity"
            CURRENT_COMPOSE_FILE="${REPO_ROOT}/cp/identity/compose/docker-compose.yml"
            REQUIRED_ENV_STRING=".suite.general.env|cp/identity/.cp.identity.env"
            SECRET_FILE="/app/secrets/.env"
            REQUIRED_VOLUMES_STRING=""
            ROLE_ID_VAR="CP_IDT_APPROLE_ROLE_ID_PATH"
            SECRET_ID_VAR="CP_IDT_APPROLE_SECRET_ID_PATH"
            ROLE_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/cp-identity/role-id"
            SECRET_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/cp-identity/secret-id"
            APPROLE_NAME="cp-identity"
            APPROLE_POLICY="identity-read"
            ;;
        cp-licensing)
            APP="cp/licensing"
            APP_SERVICE="licensing"
            CURRENT_COMPOSE_FILE="${REPO_ROOT}/cp/licensing/compose/docker-compose.yml"
            REQUIRED_ENV_STRING=".suite.general.env|cp/licensing/.cp.licensing.env"
            SECRET_FILE="/app/secrets/.env"
            REQUIRED_VOLUMES_STRING=""
            ROLE_ID_VAR="CP_LIC_APPROLE_ROLE_ID_PATH"
            SECRET_ID_VAR="CP_LIC_APPROLE_SECRET_ID_PATH"
            ROLE_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/cp-licensing/role-id"
            SECRET_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/cp-licensing/secret-id"
            APPROLE_NAME="cp-licensing"
            APPROLE_POLICY="licensing-read"
            ;;
        cp-suite-admin)
            APP="cp/suite-admin"
            APP_SERVICE="suite-admin"
            CURRENT_COMPOSE_FILE="${REPO_ROOT}/cp/suite-admin/compose/docker-compose.yml"
            REQUIRED_ENV_STRING=".suite.general.env|cp/suite-admin/.cp.suite-admin.env"
            SECRET_FILE="/app/secrets/.env"
            REQUIRED_VOLUMES_STRING=""
            ROLE_ID_VAR="CP_ADMIN_APPROLE_ROLE_ID_PATH"
            SECRET_ID_VAR="CP_ADMIN_APPROLE_SECRET_ID_PATH"
            ROLE_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/cp-suite-admin/role-id"
            SECRET_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/cp-suite-admin/secret-id"
            APPROLE_NAME="cp-suite-admin"
            APPROLE_POLICY="suite-admin-read"
            ;;
        cp-suite-shell)
            APP="cp/suite-shell"
            APP_SERVICE="suite-shell"
            CURRENT_COMPOSE_FILE="${REPO_ROOT}/cp/suite-shell/compose/docker-compose.yml"
            REQUIRED_ENV_STRING=".suite.general.env|cp/suite-shell/.cp.suite-shell.env"
            SECRET_FILE="/app/secrets/.env"
            REQUIRED_VOLUMES_STRING=""
            ROLE_ID_VAR="CP_SHELL_APPROLE_ROLE_ID_PATH"
            SECRET_ID_VAR="CP_SHELL_APPROLE_SECRET_ID_PATH"
            ROLE_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/cp-suite-shell/role-id"
            SECRET_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/cp-suite-shell/secret-id"
            APPROLE_NAME="cp-suite-shell"
            APPROLE_POLICY="suite-shell-read"
            ;;
        cp-suite-login)
            APP="cp/suite-login"
            APP_SERVICE="suite-login"
            CURRENT_COMPOSE_FILE="${REPO_ROOT}/cp/suite-login/compose/docker-compose.yml"
            REQUIRED_ENV_STRING=".suite.general.env|cp/suite-login/.cp.suite-login.env"
            SECRET_FILE="/app/secrets/.env"
            REQUIRED_VOLUMES_STRING=""
            ROLE_ID_VAR="CP_LOGIN_APPROLE_ROLE_ID_PATH"
            SECRET_ID_VAR="CP_LOGIN_APPROLE_SECRET_ID_PATH"
            ROLE_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/cp-suite-login/role-id"
            SECRET_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/cp-suite-login/secret-id"
            APPROLE_NAME="cp-suite-login"
            APPROLE_POLICY="suite-login-read"
            ;;
        cp-ai-hub)
            APP="cp/ai-hub"
            APP_SERVICE="ai-hub"
            CURRENT_COMPOSE_FILE="${REPO_ROOT}/cp/ai-hub/compose/docker-compose.yml"
            REQUIRED_ENV_STRING=".suite.general.env|cp/ai-hub/.cp.ai-hub.env"
            SECRET_FILE="/app/secrets/.env"
            REQUIRED_VOLUMES_STRING=""
            ROLE_ID_VAR="CP_AI_APPROLE_ROLE_ID_PATH"
            SECRET_ID_VAR="CP_AI_APPROLE_SECRET_ID_PATH"
            ROLE_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/cp-ai-hub/role-id"
            SECRET_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/cp-ai-hub/secret-id"
            APPROLE_NAME="cp-ai-hub"
            APPROLE_POLICY="ai-hub-read"
            ;;
        cp-analytics-hub)
            APP="cp/analytics-hub"
            APP_SERVICE="analytics-hub"
            CURRENT_COMPOSE_FILE="${REPO_ROOT}/cp/analytics-hub/compose/docker-compose.yml"
            REQUIRED_ENV_STRING=".suite.general.env|cp/analytics-hub/.cp.analytics-hub.env"
            SECRET_FILE="/app/secrets/.env"
            REQUIRED_VOLUMES_STRING=""
            ROLE_ID_VAR="CP_ANLY_APPROLE_ROLE_ID_PATH"
            SECRET_ID_VAR="CP_ANLY_APPROLE_SECRET_ID_PATH"
            ROLE_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/cp-analytics-hub/role-id"
            SECRET_ID_FALLBACK="${REPO_ROOT}/.secrets/approle/cp-analytics-hub/secret-id"
            APPROLE_NAME="cp-analytics-hub"
            APPROLE_POLICY="analytics-hub-read"
            ;;
        *)
            echo -e "${RED}Unknown chaos target: ${target}${NC}" >&2
            exit 1
            ;;
    esac
}

run_chaos_for_target() {
    local target="$1"
    load_target_config "$target"

    ensure_env_files "$REQUIRED_ENV_STRING"
    load_env_files "$REQUIRED_ENV_STRING"
    ensure_target_volumes "$REQUIRED_VOLUMES_STRING"
    ensure_target_approle_credentials
    ensure_approle_paths "$ROLE_ID_VAR" "$ROLE_ID_FALLBACK"
    ensure_approle_paths "$SECRET_ID_VAR" "$SECRET_ID_FALLBACK"

    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  F0.5 Chaos Testing: ${APP}${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo ""

    ensure_service_running

    echo -e "${BLUE}[1/3] Verifying secret injection...${NC}"
    if compose_cmd exec -T "$APP_SERVICE" sh -c "test -f ${SECRET_FILE}"; then
        echo -e "${GREEN}  ✓ Secret artifact present (${SECRET_FILE})${NC}"
    else
        echo -e "${RED}  ✗ Secret artifact missing (${SECRET_FILE})${NC}"
        SUMMARY_LINES+=("${APP}|FAILED (missing secret artifact)")
        return 1
    fi

    echo ""
    echo -e "${BLUE}[2/3] Simulating OpenBao outage...${NC}"
    echo "  Stopping OpenBao container..."
    stop_openbao
    sleep 10

    if check_service_up; then
        echo -e "${GREEN}  ✓ ${APP} container stayed up while OpenBao was offline${NC}"
    else
        echo -e "${RED}  ✗ ${APP} container exited during outage${NC}"
        start_openbao
        SUMMARY_LINES+=("${APP}|FAILED (container exited during outage)")
        return 1
    fi

    echo ""
    echo -e "${BLUE}[3/3] Recovery and auto-unseal...${NC}"
    start_openbao

    if check_service_up; then
        echo -e "${GREEN}  ✓ ${APP} container healthy after OpenBao recovery${NC}"
        SUMMARY_LINES+=("${APP}|PASS")
    else
        echo -e "${YELLOW}  ⚠ ${APP} container exited after recovery - check logs${NC}"
        SUMMARY_LINES+=("${APP}|WARN (not healthy post-recovery)")
    fi

    echo ""
    echo -e "${GREEN}✓ Chaos test sequence completed for ${APP}.${NC}"
}

run_suite() {
    verify_global_volumes
    local overall_rc=0
    for t in "${ALL_TARGETS[@]}"; do
        if ! run_chaos_for_target "$t"; then
            overall_rc=1
        fi
    done

    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Chaos Suite Summary${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    printf "%-25s | %-10s\n" "Target" "Result"
    printf "%-25s-+-%-10s\n" "-------------------------" "----------"
    for line in "${SUMMARY_LINES[@]}"; do
        IFS='|' read -r name status <<< "$line"
        printf "%-25s | %-10s\n" "$name" "$status"
    done
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"

    return "$overall_rc"
}

main() {
    if [[ "$TARGET_INPUT" == "all" ]]; then
        run_suite
        exit $?
    fi

    if [[ ! " ${ALL_TARGETS[*]} " =~ " ${TARGET_INPUT} " ]]; then
        echo -e "${RED}Unknown chaos target: ${TARGET_INPUT}${NC}" >&2
        echo "Supported targets: ${ALL_TARGETS[*]} or 'all'"
        exit 1
    fi

    verify_global_volumes
    if run_chaos_for_target "$TARGET_INPUT"; then
        exit 0
    else
        exit 1
    fi
}

main "$@"
