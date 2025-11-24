#!/usr/bin/env bash
#
# seed-secrets.sh - Migrate static secrets to OpenBao
# Usage: ./seed-secrets.sh [--profile dev|staging|prod] [--non-interactive]
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INVENTORY_CSV="${SCRIPT_DIR}/../../docs/security/F0.5-Secrets-Inventory-OpenBao.csv"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PROFILE="${PROFILE:-dev}"
NON_INTERACTIVE=false
BAO_ADDR=${BAO_ADDR:-"http://127.0.0.1:8200"}
OPENBAO_CONTAINER=${OPENBAO_CONTAINER:-geniuserp-openbao}

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --profile)
      PROFILE="$2"
      shift 2
      ;;
    --non-interactive)
      NON_INTERACTIVE=true
      shift
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      exit 1
      ;;
  esac
done

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  GeniusERP Suite - OpenBao Secrets Seed Script${NC}"
echo -e "${BLUE}  Profile: ${PROFILE}${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# Validate OpenBao connection
if ! docker exec geniuserp-openbao bao status &>/dev/null; then
  echo -e "${RED}✗ OpenBao is not accessible or sealed${NC}"
  echo -e "${YELLOW}Run: docker exec geniuserp-openbao bao operator unseal${NC}"
  exit 1
fi

# Check for BAO_TOKEN
if [[ -z "${BAO_TOKEN:-}" ]]; then
  echo -e "${YELLOW}BAO_TOKEN not set. Reading from .secrets/openbao-keys.json...${NC}"
  if [[ -f "${SCRIPT_DIR}/../../.secrets/openbao-keys.json" ]]; then
    BAO_TOKEN=$(jq -r '.root_token' "${SCRIPT_DIR}/../../.secrets/openbao-keys.json")
    export BAO_TOKEN
    echo -e "${GREEN}✓ Token loaded${NC}"
  else
    echo -e "${RED}✗ Cannot find root token. Please set BAO_TOKEN environment variable.${NC}"
    exit 1
  fi
fi

# Validate CSV inventory exists
if [[ ! -f "${INVENTORY_CSV}" ]]; then
  echo -e "${RED}✗ Inventory CSV not found: ${INVENTORY_CSV}${NC}"
  exit 1
fi

echo -e "${GREEN}✓ OpenBao connection validated${NC}"
echo -e "${GREEN}✓ Inventory loaded: $(wc -l < "${INVENTORY_CSV}") entries${NC}"
echo ""

# Enable KV v2 secrets engine if not already enabled
echo -e "${BLUE}Enabling KV v2 secrets engine...${NC}"
bao_exec() {
  docker exec -e BAO_ADDR="${BAO_ADDR}" -e BAO_TOKEN="${BAO_TOKEN}" "${OPENBAO_CONTAINER}" bao "$@"
}

bao_exec secrets enable -version=2 kv 2>/dev/null || \
  echo -e "${YELLOW}  KV engine already enabled (or error ignored)${NC}"

normalize_kv_cli_path() {
  local path="$1"
  if [[ "$path" == kv/data/* ]]; then
    echo "kv/${path#kv/data/}"
  else
    echo "$path"
  fi
}

split_kv_target() {
  local cli_path="$1"
  if [[ "$cli_path" != kv/* ]]; then
    SECRET_DOC_PATH="$cli_path"
    SECRET_FIELD=""
    return
  fi

  local rel="${cli_path#kv/}"
  if [[ "$rel" == */* ]]; then
    SECRET_DOC_PATH="kv/${rel%/*}"
    SECRET_FIELD="${rel##*/}"
  else
    SECRET_DOC_PATH="$cli_path"
    SECRET_FIELD=""
  fi
}

# Function to generate secure random secret
generate_secret() {
  local length="${1:-32}"
  openssl rand -base64 "$length" | tr -d "=+/" | cut -c1-"$length"
}

# Function to seed a single secret
seed_secret() {
  local component="$1"
  local var_name="$2"
  local path="$3"
  local is_dynamic="$4"
  
  # Skip dynamic credentials (handled by database engine)
  if [[ "$is_dynamic" == "YES" ]]; then
    echo -e "${YELLOW}  ⊘ Skipping (dynamic credential): ${var_name}${NC}"
    return 0
  fi
  
  local secret_value
  
  if [[ "$NON_INTERACTIVE" == true ]]; then
    # Generate random secret for non-interactive mode
    secret_value=$(generate_secret 32)
    echo -e "${BLUE}  ⚙ Generated random secret for: ${var_name}${NC}"
  else
    # Interactive: prompt for secret
    echo -e "${YELLOW}  → Enter value for ${component}/${var_name}:${NC}"
    read -s -p "    Value (leave empty to generate): " secret_value
    echo ""
    
    if [[ -z "$secret_value" ]]; then
      secret_value=$(generate_secret 32)
      echo -e "${BLUE}    ✓ Generated random value${NC}"
    fi
  fi
  
  # Write secret to OpenBao
  local cli_path
  cli_path=$(normalize_kv_cli_path "$path")
  split_kv_target "$cli_path"
  local field_canon="${SECRET_FIELD//-/_}"

  if [[ -n "$field_canon" ]]; then
    if bao_exec kv get "$SECRET_DOC_PATH" >/dev/null 2>&1; then
      if bao_exec kv patch "$SECRET_DOC_PATH" "${field_canon}=${secret_value}" &>/dev/null; then
        echo -e "${GREEN}  ✓ Seeded: ${SECRET_DOC_PATH} (${field_canon})${NC}"
        return 0
      fi
    else
      if bao_exec kv put "$SECRET_DOC_PATH" "${field_canon}=${secret_value}" &>/dev/null; then
        echo -e "${GREEN}  ✓ Seeded: ${SECRET_DOC_PATH} (${field_canon})${NC}"
        return 0
      fi
    fi
  else
    if bao_exec kv put "$SECRET_DOC_PATH" value="$secret_value" &>/dev/null; then
      echo -e "${GREEN}  ✓ Seeded: ${SECRET_DOC_PATH}${NC}"
      return 0
    fi
  fi

  echo -e "${RED}  ✗ Failed to seed: ${path}${NC}"
  return 1
}

# Process CSV inventory
echo -e "${BLUE}Starting secrets migration...${NC}"
echo ""

total=0
skipped=0
succeeded=0
failed=0

while IFS=, read -r component var_name type path is_dynamic status; do
  # Skip header row
  if [[ "$component" == "Component" ]]; then
    continue
  fi
  
  total=$((total + 1))
  
  echo -e "${BLUE}[$total] ${component} → ${var_name}${NC}"
  
  if seed_secret "$component" "$var_name" "$path" "$is_dynamic"; then
    if [[ "$is_dynamic" == "YES" ]]; then
      skipped=$((skipped + 1))
    else
      succeeded=$((succeeded + 1))
    fi
  else
    failed=$((failed + 1))
  fi
  
done < "$INVENTORY_CSV"

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Migration Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "  Total entries:     ${total}"
echo -e "  ${GREEN}Succeeded:         ${succeeded}${NC}"
echo -e "  ${YELLOW}Skipped (dynamic): ${skipped}${NC}"
echo -e "  ${RED}Failed:            ${failed}${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"

if [[ $failed -gt 0 ]]; then
  exit 1
fi

echo -e "${GREEN}✓ All static secrets migrated successfully!${NC}"
