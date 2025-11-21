#!/usr/bin/env bash
# openbao-sync-app-roles.sh - Configure OpenBao database roles per application
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
ROLES_DIR="${REPO_ROOT}/database/roles"
ROLES_MANIFEST="${ROLES_DIR}/roles.json"
SECRETS_DIR="${REPO_ROOT}/.secrets"
DB_ADMIN_PASS_FILE="${SECRETS_DIR}/openbao-db-admin.pass"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0;0m'

if [[ ! -f "${ROLES_MANIFEST}" ]]; then
    echo -e "${RED}✗ roles.json absent (${ROLES_MANIFEST})${NC}"
    exit 1
fi

if [[ ! -f "${DB_ADMIN_PASS_FILE}" ]]; then
    echo -e "${RED}✗ ${DB_ADMIN_PASS_FILE} lipsă. Rulează întâi scripts/security/openbao-enable-db-engine.sh${NC}"
    exit 1
fi

if ! command -v bao >/dev/null 2>&1; then
    echo -e "${RED}✗ OpenBao CLI (bao) nu este instalat${NC}"
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    echo -e "${RED}✗ jq este necesar pentru a parsa roles.json${NC}"
    exit 1
fi

if [[ -z "${BAO_TOKEN:-}" ]]; then
    echo -e "${RED}✗ BAO_TOKEN nu este setat${NC}"
    exit 1
fi

SUITE_GENERAL_ENV="${REPO_ROOT}/.suite.general.env"
if [[ -f "${SUITE_GENERAL_ENV}" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "${SUITE_GENERAL_ENV}"
    set +a
fi

for var in SUITE_DB_POSTGRES_HOST SUITE_DB_POSTGRES_PORT SUITE_DB_POSTGRES_USER SUITE_DB_POSTGRES_PASS; do
    if [[ -z "${!var:-}" ]]; then
        echo -e "${RED}✗ Variabila ${var} nu este setată (sursa: .suite.general.env)${NC}"
        exit 1
    fi
done

POSTGRES_HOST="${SUITE_DB_POSTGRES_HOST}"
POSTGRES_PORT="${SUITE_DB_POSTGRES_PORT}"
POSTGRES_SUPERUSER="${SUITE_DB_POSTGRES_USER}"
POSTGRES_SUPERPASS="${SUITE_DB_POSTGRES_PASS}"
POSTGRES_CONTAINER="${SUITE_DB_POSTGRES_CONTAINER:-geniuserp-postgres}"
OPENBAO_DB_ADMIN_PASSWORD="$(<"${DB_ADMIN_PASS_FILE}")"

DEFAULT_PLUGIN="$(jq -r '.defaults.plugin_name' "${ROLES_MANIFEST}")"
DEFAULT_TTL="$(jq -r '.defaults.default_ttl' "${ROLES_MANIFEST}")"
DEFAULT_MAX_TTL="$(jq -r '.defaults.max_ttl' "${ROLES_MANIFEST}")"

if ! command -v docker >/dev/null 2>&1; then
    echo -e "${RED}✗ Docker CLI nu este disponibil${NC}"
    exit 1
fi

create_db_if_missing() {
    local db_name="$1"
    local exists
    exists=$(docker exec -e PGPASSWORD="${POSTGRES_SUPERPASS}" "${POSTGRES_CONTAINER}" \
        psql -U "${POSTGRES_SUPERUSER}" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='${db_name}'" 2>/dev/null || true)
    if [[ "${exists//[[:space:]]/}" != "1" ]]; then
        echo -e "${YELLOW}  ↳ Creez baza de date ${db_name}${NC}"
        docker exec -e PGPASSWORD="${POSTGRES_SUPERPASS}" "${POSTGRES_CONTAINER}" \
            psql -U "${POSTGRES_SUPERUSER}" -d postgres -c "CREATE DATABASE ${db_name} OWNER ${POSTGRES_SUPERUSER};" >/dev/null
    fi
}

run_psql() {
    local db_name="$1"
    local sql="$2"
    docker exec -e PGPASSWORD="${POSTGRES_SUPERPASS}" "${POSTGRES_CONTAINER}" \
        psql -U "${POSTGRES_SUPERUSER}" -d "${db_name}" -v ON_ERROR_STOP=1 -c "${sql}" >/dev/null
}

ensure_extensions() {
    local db_name="$1"
    shift || true
    local extensions=("$@")
    if (( ${#extensions[@]} == 0 )); then
        return
    fi
    for ext in "${extensions[@]}"; do
        echo -e "${YELLOW}  ↳ Activez extensia ${ext} în ${db_name}${NC}"
        run_psql "${db_name}" "CREATE EXTENSION IF NOT EXISTS ${ext};"
    done
}

printf "${BLUE}═══════════════════════════════════════════════${NC}\n"
printf "${BLUE}  OpenBao Dynamic Role Synchronizer${NC}\n"
printf "${BLUE}═══════════════════════════════════════════════${NC}\n\n"
printf "${GREEN}✓ roles.json loaded (${ROLES_MANIFEST})${NC}\n"
printf "${GREEN}✓ BAO_TOKEN detected${NC}\n\n"

UPDATED=()

while IFS= read -r ROLE; do
    ROLE_NAME="$(jq -r '.name' <<<"${ROLE}")"
    DB_NAME="$(jq -r '.db_name' <<<"${ROLE}")"
    CONNECTION_NAME="$(jq -r '.connection' <<<"${ROLE}")"
    SQL_FILE="$(jq -r '.sql_file' <<<"${ROLE}")"
    DESC="$(jq -r '.description' <<<"${ROLE}")"
    ROLE_TTL="$(jq -r '.default_ttl // empty' <<<"${ROLE}")"
    ROLE_MAX_TTL="$(jq -r '.max_ttl // empty' <<<"${ROLE}")"
    mapfile -t ROLE_EXTENSIONS < <(jq -r '.extensions[]?' <<<"${ROLE}")

    [[ -z "${ROLE_TTL}" ]] && ROLE_TTL="${DEFAULT_TTL}"
    [[ -z "${ROLE_MAX_TTL}" ]] && ROLE_MAX_TTL="${DEFAULT_MAX_TTL}"

    SQL_PATH="${ROLES_DIR}/${SQL_FILE}"
    if [[ ! -f "${SQL_PATH}" ]]; then
        echo -e "${RED}✗ SQL template lipsă: ${SQL_PATH}${NC}"
        exit 1
    fi

    printf "${BLUE}▶ Configurare rol: %s (${DESC})${NC}\n" "${ROLE_NAME}"

    create_db_if_missing "${DB_NAME}"
    if (( ${#ROLE_EXTENSIONS[@]} > 0 )); then
        ensure_extensions "${DB_NAME}" "${ROLE_EXTENSIONS[@]}"
    fi

    CONNECTION_URL="postgresql://{{username}}:{{password}}@${POSTGRES_HOST}:${POSTGRES_PORT}/${DB_NAME}?sslmode=disable"

    bao write "database/config/${CONNECTION_NAME}" \
        plugin_name="${DEFAULT_PLUGIN}" \
        allowed_roles="${ROLE_NAME}" \
        connection_url="${CONNECTION_URL}" \
        username="openbao_admin" \
        password="${OPENBAO_DB_ADMIN_PASSWORD}" \
        verify_connection=true >/dev/null

    bao write "database/roles/${ROLE_NAME}" \
        db_name="${CONNECTION_NAME}" \
        creation_statements="@${SQL_PATH}" \
        default_ttl="${ROLE_TTL}" \
        max_ttl="${ROLE_MAX_TTL}" \
        revocation_statements="REVOKE ALL PRIVILEGES ON DATABASE ${DB_NAME} FROM \"{{name}}\"" \
        revocation_statements="REVOKE USAGE ON SCHEMA public FROM \"{{name}}\"" \
        revocation_statements="REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM \"{{name}}\"" \
        revocation_statements="REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public FROM \"{{name}}\"" \
        revocation_statements="REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA public FROM \"{{name}}\"" \
        revocation_statements="SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE usename = '{{name}}'" \
        revocation_statements="DROP ROLE IF EXISTS \"{{name}}\"" \
        rollback_statements="DROP ROLE IF EXISTS \"{{name}}\";" >/dev/null

    UPDATED+=("${ROLE_NAME}")
    printf "${GREEN}  ✓ Rol sincronizat${NC}\n\n"

done < <(jq -c '.roles[]' "${ROLES_MANIFEST}")

printf "${GREEN}Toate rolurile au fost sincronizate:${NC} %s\n" "${UPDATED[*]}"
printf "${YELLOW}Validare:${NC} rulați 'bao read database/creds/<role_name>' pentru a verifica TTL și privilegii.\n"
