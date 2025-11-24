#!/usr/bin/env bash
#
# test-openbao-secrets.sh - Validates that all static KV entries exist in OpenBao
# Usage: ./scripts/security/test-openbao-secrets.sh [--csv path]
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
INVENTORY_CSV="${REPO_ROOT}/docs/security/F0.5-Secrets-Inventory-OpenBao.csv"
BAO_ADDR=${BAO_ADDR:-"http://127.0.0.1:8200"}
OPENBAO_CONTAINER=${OPENBAO_CONTAINER:-geniuserp-openbao}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --csv)
      INVENTORY_CSV="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

if [[ ! -f "$INVENTORY_CSV" ]]; then
  echo "Inventory CSV not found: $INVENTORY_CSV" >&2
  exit 1
fi

if [[ -z "${BAO_TOKEN:-}" ]]; then
  if [[ -f "${REPO_ROOT}/.secrets/openbao-keys.json" ]]; then
    export BAO_TOKEN="$(jq -r '.root_token' "${REPO_ROOT}/.secrets/openbao-keys.json")"
  else
    echo "BAO_TOKEN not set and .secrets/openbao-keys.json missing" >&2
    exit 1
  fi
fi

bao_exec() {
  docker exec -e BAO_ADDR="${BAO_ADDR}" -e BAO_TOKEN="${BAO_TOKEN}" "${OPENBAO_CONTAINER}" bao "$@"
}

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

check_secret() {
  local path="$1"
  local cli_path
  cli_path=$(normalize_kv_cli_path "$path")
  split_kv_target "$cli_path"
  local field="${SECRET_FIELD}"

  local json
  if ! json=$(bao_exec kv get -format=json "$SECRET_DOC_PATH" 2>/dev/null); then
    echo "✗ Missing secret document: $SECRET_DOC_PATH"
    return 1
  fi

  if [[ -z "$field" ]]; then
    if echo "$json" | jq -e '.data.data | length > 0' >/dev/null; then
      echo "✓ $SECRET_DOC_PATH"
      return 0
    fi
    echo "✗ Document $SECRET_DOC_PATH has no keys"
    return 1
  fi

  local field_variants=("$field" "${field//-/_}" "${field//_/-}")
  for candidate in "${field_variants[@]}"; do
    if [[ -z "$candidate" ]]; then
      continue
    fi
    if echo "$json" | jq -e --arg key "$candidate" '.data.data[$key]' >/dev/null; then
      echo "✓ ${SECRET_DOC_PATH}::$candidate"
      return 0
    fi
  done

  echo "✗ Key ${field} not found in ${SECRET_DOC_PATH}"
  return 1
}

checked=0
skipped=0
failed=0

while IFS=, read -r component var_name type path is_dynamic status; do
  [[ "$component" == "Component" ]] && continue

  if [[ "$is_dynamic" == "YES" ]]; then
    skipped=$((skipped + 1))
    continue
  fi

  if [[ "$path" != kv/* ]]; then
    echo "⚠️  Skipping unsupported path: $path"
    skipped=$((skipped + 1))
    continue
  fi

  checked=$((checked + 1))
  if ! check_secret "$path"; then
    failed=$((failed + 1))
  fi

done < "$INVENTORY_CSV"

echo "---"
echo "Validated secrets: $checked"
echo "Skipped entries (dynamic/unsupported): $skipped"

if [[ $failed -gt 0 ]]; then
  echo "Failures: $failed" >&2
  exit 1
fi

echo "All static OpenBao secrets present"
