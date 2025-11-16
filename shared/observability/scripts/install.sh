#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 [dev] [--help]
  dev       Pornește stack-ul de observabilitate pentru dezvoltare
  --help    Afișează acest mesaj
EOF
}

command -v docker >/dev/null || { echo "Eroare: docker lipsă"; exit 1; }
if docker compose version >/dev/null 2>&1; then DC=(docker compose); else DC=(docker-compose); fi

MODE="${1:-dev}"
[[ "${MODE}" == "--help" ]] && { usage; exit 0; }
[[ "${MODE}" != "dev" ]] && { echo "Doar 'dev' suportat în F0.3"; exit 2; }

COMPOSE_FILE=${COMPOSE_FILE:-"compose/profiles/compose.dev.yml"}
ENV_FILE=${ENV_FILE:-".observability.env"}

echo "[install] Verific profilul: ${COMPOSE_FILE}"
${DC[@]} -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" config >/dev/null

echo "[install] Pornez stack-ul de observabilitate (dev)"
${DC[@]} -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" up -d

echo "[install] Aștept ca serviciile să devină healthy..."
sleep 10

# Verificare rapidă că serviciile principale sunt up
SERVICES=(
  "http://localhost:3000/api/health|Grafana"
  "http://localhost:9090/-/ready|Prometheus"
  "http://localhost:3100/ready|Loki"
)

OK=0; FAIL=0
for service in "${SERVICES[@]}"; do
  url="${service%%|*}"
  label="${service##*|}"
  
  if curl -sf --connect-timeout 3 --max-time 5 "$url" >/dev/null 2>&1; then
    echo "[install] ✓ $label - OK"
    OK=$((OK + 1))
  else
    echo "[install] ✗ $label - Not ready yet"
    FAIL=$((FAIL + 1))
  fi
done

if [[ $FAIL -eq 0 ]]; then
  echo "[install] OK. Toate serviciile sunt operaționale ($OK/$((OK + FAIL)))."
  exit 0
else
  echo "[install] WARNING: $FAIL/$((OK + FAIL)) servicii nu sunt ready încă. Verificați cu 'docker ps'."
  exit 0
fi
