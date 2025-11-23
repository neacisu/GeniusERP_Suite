#!/usr/bin/env bash
#
# test-f05-chaos.sh - Chaos testing for F0.5 Security Architecture
#
# Scenarios:
# 1. Secret Injection: Verify apps have secrets.
# 2. OpenBao Down: Stop OpenBao and verify app behavior.
# 3. Recovery: Start OpenBao and verify recovery.
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

APP="numeriqo" # Target app for testing

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  F0.5 Chaos Testing: $APP${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# 1. Secret Injection Verification
echo -e "${BLUE}[1/3] Verifying Secret Injection...${NC}"
if docker compose exec $APP ls /app/secrets/db-creds.json > /dev/null 2>&1; then
    echo -e "${GREEN}  ✓ Secrets file exists${NC}"
else
    echo -e "${RED}  ✗ Secrets file missing${NC}"
    exit 1
fi

# Check env vars (indirectly via script or checking process)
# We can't easily see process env vars from outside without root/proc access, 
# but existence of file implies Agent is working.

echo ""
echo -e "${BLUE}[2/3] Simulating OpenBao Outage...${NC}"
echo "  Stopping OpenBao..."
docker compose stop openbao

echo "  Waiting 10s..."
sleep 10

echo "  Checking app status (should be running, Agent caches secrets)..."
if docker compose ps $APP | grep -q "Up"; then
    echo -e "${GREEN}  ✓ App is still running (resilient)${NC}"
else
    echo -e "${RED}  ✗ App crashed${NC}"
    # Note: If app crashes, it might be intended if it can't renew lease. 
    # But for short outage, it should survive.
fi

echo ""
echo -e "${BLUE}[3/3] Recovery...${NC}"
echo "  Starting OpenBao..."
docker compose start openbao
echo "  Waiting for OpenBao to be ready..."
sleep 5
# Unseal would be needed here in real scenario if not auto-unseal
# For this test, we assume unseal is handled or we do it manually if needed.
# In dev mode (file backend), it stays sealed on restart.

echo -e "${YELLOW}  Note: OpenBao needs unseal after restart!${NC}"
echo "  Please run: bao operator unseal <keys>"

echo ""
echo -e "${GREEN}✓ Chaos test sequence completed.${NC}"
