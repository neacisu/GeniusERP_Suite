#!/usr/bin/env bash
# github-secrets-cleanup.sh - Assist with removing legacy GitHub Actions secrets (F0.5.22)
set -euo pipefail

SECRETS_TO_REMOVE=(
  BAO_TOKEN
  GH_PAT_TOKEN
  NPM_TOKEN
  DB_PASSWORD
  JWT_SECRET
  DOCKER_USERNAME
  DOCKER_PASSWORD
)

MODE="plan"
EVIDENCE_FILE=""

usage() {
  cat <<'EOF'
Usage: ./scripts/security/github-secrets-cleanup.sh [OPTIONS]

Options:
  --delete            Delete legacy secrets (default: plan-only)
  --evidence <path>   Write gh secret list snapshot to <path>
  -h, --help          Show this message

Requirements:
  - GitHub CLI (gh) authenticated with repo admin rights
  - jq available in PATH
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --delete)
      MODE="delete"
      shift
      ;;
    --evidence)
      EVIDENCE_FILE="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI is required" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 1
fi

REPO_SLUG=$(gh repo view --json nameWithOwner -q .nameWithOwner)
SNAPSHOT=$(gh secret list --json name,updatedAt)

log() {
  printf '[github-secrets-cleanup] %s\n' "$1"
}

for secret in "${SECRETS_TO_REMOVE[@]}"; do
  present=$(echo "$SNAPSHOT" | jq -e --arg name "$secret" '.[] | select(.name == $name)') || true
  if [[ -n "$present" ]]; then
    log "Secret ${secret} present in ${REPO_SLUG}"
    if [[ "$MODE" == "delete" ]]; then
        printf 'y\n' | gh secret delete "$secret"
      log "  → Deleted ${secret}"
    fi
  else
    log "Secret ${secret} already absent"
  fi
done

if [[ -n "$EVIDENCE_FILE" ]]; then
  mkdir -p "$(dirname "$EVIDENCE_FILE")"
  printf '%s\n' "$SNAPSHOT" > "$EVIDENCE_FILE"
  log "Snapshot written to $EVIDENCE_FILE"
fi

if [[ "$MODE" == "plan" ]]; then
  log "Run with --delete to remove the secrets listed above."
else
  log "Legacy secrets removed (if present)."
fi
