#!/usr/bin/env bash
set -euo pipefail

# If the user provided a custom command (ex: docker run image bash), honor it.
if [[ $# -gt 0 ]]; then
  exec "$@"
fi

CONFIG_PATH=${BAO_AGENT_CONFIG:-/etc/openbao/agent.hcl}
LOG_LEVEL=${OPENBAO_LOG_LEVEL:-info}

if [[ ! -f "$CONFIG_PATH" ]]; then
  echo "[node-openbao] agent config missing: $CONFIG_PATH" >&2
  exit 1
fi

mkdir -p "${OPENBAO_RUNTIME_DIR:-/var/run/openbao}" "$(dirname "$CONFIG_PATH")"
exec bao agent -log-level="$LOG_LEVEL" -config="$CONFIG_PATH"
