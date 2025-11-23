#!/usr/bin/env bash
#
# validate-app-config.sh - Validate Process Supervisor configuration for an application
#
# Usage: ./validate-app-config.sh <app-name>
# Example: ./validate-app-config.sh archify
#
set -euo pipefail

APP_NAME="${1:-}"

if [[ -z "$APP_NAME" ]]; then
    echo "Usage: $0 <app-name>"
    echo "Example: $0 archify"
    exit 1
fi

# Determine app directory
if [[ -d "${APP_NAME}.app" ]]; then
    APP_DIR="${APP_NAME}.app"
elif [[ -d "cp/${APP_NAME}" ]]; then
    APP_DIR="cp/${APP_NAME}"
else
    echo "Error: Could not find directory for app: $APP_NAME"
    exit 1
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Validating Process Supervisor Config: $APP_NAME${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# Check 1: docker-compose.yml exists
echo -n "[1/10] Checking docker-compose.yml exists... "
if [[ -f "${APP_DIR}/compose/docker-compose.yml" ]]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo "  Error: ${APP_DIR}/compose/docker-compose.yml not found"
    ((ERRORS++))
fi

# Check 2: No hardcoded ports in docker-compose.yml
echo -n "[2/10] Checking for hardcoded ports... "
if grep -qE ":\s*[0-9]{4,5}[^}]" "${APP_DIR}/compose/docker-compose.yml" 2>/dev/null; then
    echo -e "${RED}✗${NC}"
    echo "  Found hardcoded ports:"
    grep -nE ":\s*[0-9]{4,5}[^}]" "${APP_DIR}/compose/docker-compose.yml" | head -5
    ((ERRORS++))
else
    echo -e "${GREEN}✓${NC}"
fi

# Check 3: No hardcoded container names
echo -n "[3/10] Checking for hardcoded container names... "
if grep -qE "container_name:\s*[a-z]" "${APP_DIR}/compose/docker-compose.yml" 2>/dev/null && \
   ! grep -qE "container_name:\s*\\\${" "${APP_DIR}/compose/docker-compose.yml" 2>/dev/null; then
    echo -e "${RED}✗${NC}"
    echo "  Found hardcoded container name:"
    grep -n "container_name:" "${APP_DIR}/compose/docker-compose.yml"
    ((ERRORS++))
else
    echo -e "${GREEN}✓${NC}"
fi

# Check 4: No hardcoded values in environment section
echo -n "[4/10] Checking for hardcoded environment values... "
if grep -qE "^\s*-\s+[A-Z_]+=\w+$" "${APP_DIR}/compose/docker-compose.yml" 2>/dev/null && \
   ! grep -E "^\s*-\s+[A-Z_]+=\w+$" "${APP_DIR}/compose/docker-compose.yml" | grep -q '\${'; then
    echo -e "${YELLOW}⚠${NC}"
    echo "  Found potentially hardcoded values:"
    grep -nE "^\s*-\s+[A-Z_]+=\w+$" "${APP_DIR}/compose/docker-compose.yml" | grep -v '\${' | head -5
    ((WARNINGS++))
else
    echo -e "${GREEN}✓${NC}"
fi

# Check 5: .env.example exists
echo -n "[5/10] Checking .env.example exists... "
if [[ -f "${APP_DIR}/.${APP_NAME}.env.example" ]]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo "  Error: ${APP_DIR}/.${APP_NAME}.env.example not found"
    ((ERRORS++))
fi

# Check 6: OpenBao Agent config exists
echo -n "[6/10] Checking OpenBao Agent config... "
if [[ -f "${APP_DIR}/openbao/agent-config.hcl" ]]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo "  Error: ${APP_DIR}/openbao/agent-config.hcl not found"
    ((ERRORS++))
fi

# Check 7: OpenBao templates exist
echo -n "[7/10] Checking OpenBao templates... "
MISSING_TEMPLATES=0
for template in "db-creds.tpl" "app-secrets.tpl" "${APP_NAME}.env.tpl"; do
    if [[ ! -f "${APP_DIR}/openbao/templates/$template" ]]; then
        if [[ $MISSING_TEMPLATES -eq 0 ]]; then
            echo -e "${RED}✗${NC}"
        fi
        echo "  Missing: ${APP_DIR}/openbao/templates/$template"
        ((MISSING_TEMPLATES++))
    fi
done
if [[ $MISSING_TEMPLATES -eq 0 ]]; then
    echo -e "${GREEN}✓${NC}"
else
    ((ERRORS++))
fi

# Check 8: Process Supervisor script exists
echo -n "[8/10] Checking Process Supervisor script... "
if [[ -f "${APP_DIR}/scripts/start-app.sh" ]] && [[ -x "${APP_DIR}/scripts/start-app.sh" ]]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    if [[ ! -f "${APP_DIR}/scripts/start-app.sh" ]]; then
        echo "  Error: ${APP_DIR}/scripts/start-app.sh not found"
    else
        echo "  Error: ${APP_DIR}/scripts/start-app.sh not executable"
    fi
    ((ERRORS++))
fi

# Check 9: AppRole setup script exists
echo -n "[9/10] Checking AppRole setup script... "
if [[ -f "${APP_DIR}/scripts/setup-approle.sh" ]] && [[ -x "${APP_DIR}/scripts/setup-approle.sh" ]]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    if [[ ! -f "${APP_DIR}/scripts/setup-approle.sh" ]]; then
        echo "  Error: ${APP_DIR}/scripts/setup-approle.sh not found"
    else
        echo "  Error: ${APP_DIR}/scripts/setup-approle.sh not executable"
    fi
    ((ERRORS++))
fi

# Check 10: env_file references .env
echo -n "[10/10] Checking env_file references... "
if grep -q "env_file:" "${APP_DIR}/compose/docker-compose.yml" 2>/dev/null && \
   grep -A2 "env_file:" "${APP_DIR}/compose/docker-compose.yml" | grep -q ".${APP_NAME}.env"; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠${NC}"
    echo "  Warning: env_file may not reference .${APP_NAME}.env"
    ((WARNINGS++))
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Validation Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "  Errors:   ${RED}${ERRORS}${NC}"
echo -e "  Warnings: ${YELLOW}${WARNINGS}${NC}"

if [[ $ERRORS -eq 0 ]] && [[ $WARNINGS -eq 0 ]]; then
    echo ""
    echo -e "${GREEN}✓ All checks passed! Configuration is valid.${NC}"
    exit 0
elif [[ $ERRORS -eq 0 ]]; then
    echo ""
    echo -e "${YELLOW}⚠ Configuration has warnings but is acceptable.${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}✗ Configuration has errors. Please fix them before proceeding.${NC}"
    exit 1
fi
