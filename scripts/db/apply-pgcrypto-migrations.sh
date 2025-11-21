#!/usr/bin/env bash
#
# apply-pgcrypto-migrations.sh - Apply pgcrypto migrations to all suite databases
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MIGRATIONS_DIR="${SCRIPT_DIR}/migrations"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  GeniusERP Suite - pgcrypto Migration Script${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# List of all databases
DATABASES=(
    "identity_db"
    "licensing_db"
    "suite_shell_db"
    "suite_admin_db"
    "analytics_hub_db"
    "ai_hub_db"
    "numeriqo_db"
    "archify_db"
    "cerniq_db"
    "flowxify_db"
    "iwms_db"
    "mercantiq_db"
    "triggerra_db"
    "vettify_db"
    "geniuserp_db"
)

echo -e "${BLUE}Enabling pgcrypto extension in all ${#DATABASES[@]} databases...${NC}"
echo ""

success_count=0
failed_count=0

for db in "${DATABASES[@]}"; do
    echo -e "${BLUE}[${db}]${NC} Enabling pgcrypto..."
    
    if docker exec geniuserp-postgres psql -U suite_admin -d "$db" -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;" &>/dev/null; then
        echo -e "${GREEN}  ✓ pgcrypto enabled${NC}"
        
        # Verify extension
        if docker exec geniuserp-postgres psql -U suite_admin -d "$db" -tAc "SELECT extversion FROM pg_extension WHERE extname='pgcrypto';" &>/dev/null; then
            version=$(docker exec geniuserp-postgres psql -U suite_admin -d "$db" -tAc "SELECT extversion FROM pg_extension WHERE extname='pgcrypto';")
            echo -e "${GREEN}  ✓ Verified (version: ${version})${NC}"
            success_count=$((success_count + 1))
        else
            echo -e "${RED}  ✗ Verification failed${NC}"
            failed_count=$((failed_count + 1))
        fi
    else
        echo -e "${RED}  ✗ Failed to enable pgcrypto${NC}"
        failed_count=$((failed_count + 1))
    fi
    echo ""
done

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Migration Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "  Total databases:   ${#DATABASES[@]}"
echo -e "  ${GREEN}Succeeded:         ${success_count}${NC}"
echo -e "  ${RED}Failed:            ${failed_count}${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"

if [[ $failed_count -gt 0 ]]; then
    exit 1
fi

echo -e "${GREEN}✓ All databases now have pgcrypto enabled!${NC}"
