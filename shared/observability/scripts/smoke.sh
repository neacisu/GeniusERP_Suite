#!/usr/bin/env bash
set -euo pipefail

# Smoke tests pentru TOATE aplicațiile conform strategiei de porturi
# Tabelul 4 și Tabelul 5 din "Strategii de Fișiere.env și Porturi.md"

ENDPOINTS=(
  # OBSERVABILITY STACK (Tabelul 4)
  "http://localhost:3000/metrics|Grafana"
  "http://localhost:9090/-/ready|Prometheus"
  "http://localhost:3100/ready|Loki"
  
  # CONTROL PLANE (Tabelul 5: 6100-6499)
  "http://localhost:6100/health|CP:suite-shell"
  "http://localhost:6100/metrics|CP:suite-shell-metrics"
  "http://localhost:6150/health|CP:suite-admin"
  "http://localhost:6150/metrics|CP:suite-admin-metrics"
  "http://localhost:6200/health|CP:suite-login"
  "http://localhost:6200/metrics|CP:suite-login-metrics"
  "http://localhost:6250/health|CP:identity"
  "http://localhost:6250/metrics|CP:identity-metrics"
  "http://localhost:6300/health|CP:licensing"
  "http://localhost:6300/metrics|CP:licensing-metrics"
  "http://localhost:6350/health|CP:analytics-hub"
  "http://localhost:6350/metrics|CP:analytics-hub-metrics"
  "http://localhost:6400/health|CP:ai-hub"
  "http://localhost:6400/metrics|CP:ai-hub-metrics"
  
  # STAND-ALONE APPS (Conform Tabelul 5 din strategia de porturi)
  "http://localhost:6500/health|archify.app"
  "http://localhost:6500/metrics|archify.app-metrics"
  "http://localhost:6550/health|cerniq.app"
  "http://localhost:6550/metrics|cerniq.app-metrics"
  "http://localhost:6600/health|flowxify.app"
  "http://localhost:6600/metrics|flowxify.app-metrics"
  "http://localhost:6650/health|i-wms.app"
  "http://localhost:6650/metrics|i-wms.app-metrics"
  "http://localhost:6700/health|mercantiq.app"
  "http://localhost:6700/metrics|mercantiq.app-metrics"
  "http://localhost:6750/health|numeriqo.app"
  "http://localhost:6750/metrics|numeriqo.app-metrics"
  "http://localhost:6800/health|triggerra.app"
  "http://localhost:6800/metrics|triggerra.app-metrics"
  "http://localhost:6850/health|vettify.app"
  "http://localhost:6850/metrics|vettify.app-metrics"
)

OK=0; FAIL=0
check() {
  local endpoint="$1"
  local url="${endpoint%%|*}"
  local label="${endpoint##*|}"
  local code
  
  # Use timeout command to prevent hanging
  code=$(timeout 5 curl -s -o /dev/null -w "%{http_code}" --connect-timeout 3 --max-time 5 "$url" 2>/dev/null || echo "000")
  
  if [[ "$code" == "200" ]]; then
    printf "[smoke] ✓ OK   %-35s\n" "$label"
    OK=$((OK + 1))
  else
    printf "[smoke] ✗ FAIL %-35s => HTTP %s\n" "$label" "$code"
    FAIL=$((FAIL + 1))
  fi
}

echo "[smoke] Starting comprehensive smoke tests..."
echo "[smoke] ================================================"

for e in "${ENDPOINTS[@]}"; do 
  check "$e"
done

echo "[smoke] ================================================"
echo "[smoke] Rezultat Final: OK=$OK FAIL=$FAIL (Total: $((OK + FAIL)))"
[[ $FAIL -eq 0 ]] || exit 4
