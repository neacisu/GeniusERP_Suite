#!/usr/bin/env bash
#
# batch-rollout-process-supervisor.sh - Batch rollout Process Supervisor to all apps
#
set -euo pipefail

# List of all applications to process
APPS=(
    "mercantiq"
    "flowxify"
    "triggerra"
    "cerniq"
    "i-wms"
    "vettify"
    "geniuserp"
)

# List of CP modules
CP_MODULES=(
    "identity"
    "licensing"
    "suite-admin"
    "suite-shell"
    "ai-hub"
    "analytics-hub"
)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TOTAL_APPS=$((${#APPS[@]} + ${#CP_MODULES[@]}))
CURRENT=0
FAILED=()

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Batch Process Supervisor Rollout${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "  Total applications: $TOTAL_APPS"
echo -e "  Applications: ${#APPS[@]}"
echo -e "  CP Modules: ${#CP_MODULES[@]}"
echo ""

process_app() {
    local app_name=$1
    ((CURRENT++))
    
    echo -e "${BLUE}[$CURRENT/$TOTAL_APPS] Processing: $app_name${NC}"
    echo ""
    
    # Step 1: Generate OpenBao configs
    echo "  [1/5] Generating OpenBao configs..."
    if ! ./scripts/security/generate-app-config.sh "$app_name" > /dev/null 2>&1; then
        echo -e "  ${RED}✗ Failed to generate configs${NC}"
        FAILED+=("$app_name")
        return 1
    fi
    echo -e "  ${GREEN}✓ Configs generated${NC}"
    
    # Step 2: Analyze compose file
    echo "  [2/5] Analyzing docker-compose.yml..."
    local compose_file
    if [[ -f "${app_name}.app/compose/docker-compose.yml" ]]; then
        compose_file="${app_name}.app/compose/docker-compose.yml"
    elif [[ -f "cp/${app_name}/compose/docker-compose.yml" ]]; then
        compose_file="cp/${app_name}/compose/docker-compose.yml"
    else
        echo -e "  ${RED}✗ docker-compose.yml not found${NC}"
        FAILED+=("$app_name")
        return 1
    fi
    
    ./scripts/security/convert-compose-to-env.sh "$compose_file" > /tmp/${app_name}-analysis.txt 2>&1
    echo -e "  ${GREEN}✓ Analysis complete${NC}"
    
    # Step 3: Update docker-compose.yml (manual step - will be done in bulk)
    echo "  [3/5] Updating docker-compose.yml..."
    echo -e "  ${YELLOW}⚠ Manual update required - see /tmp/${app_name}-analysis.txt${NC}"
    
    # Step 4: Create .env.example
    echo "  [4/5] Creating .env.example..."
    local env_file
    if [[ -f "${app_name}.app/.${app_name}.env.example" ]]; then
        env_file="${app_name}.app/.${app_name}.env.example"
    elif [[ -f "cp/${app_name}/.${app_name}.env.example" ]]; then
        env_file="cp/${app_name}/.${app_name}.env.example"
    fi
    
    if [[ -n "${env_file:-}" ]] && [[ -f "$env_file" ]]; then
        echo -e "  ${GREEN}✓ .env.example exists${NC}"
    else
        echo -e "  ${YELLOW}⚠ .env.example needs to be created${NC}"
    fi
    
    # Step 5: Validate
    echo "  [5/5] Validating configuration..."
    if ./scripts/security/validate-app-config.sh "$app_name" > /dev/null 2>&1; then
        echo -e "  ${GREEN}✓ Validation passed${NC}"
    else
        echo -e "  ${YELLOW}⚠ Validation has warnings/errors${NC}"
    fi
    
    echo ""
}

# Process all applications
echo -e "${BLUE}Processing Applications...${NC}"
echo ""
for app in "${APPS[@]}"; do
    process_app "$app" || true
done

# Process all CP modules
echo -e "${BLUE}Processing CP Modules...${NC}"
echo ""
for module in "${CP_MODULES[@]}"; do
    process_app "$module" || true
done

# Summary
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Batch Rollout Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "  Total processed: $CURRENT/$TOTAL_APPS"
echo -e "  Successful: $((CURRENT - ${#FAILED[@]}))"
echo -e "  Failed: ${#FAILED[@]}"

if [[ ${#FAILED[@]} -gt 0 ]]; then
    echo ""
    echo -e "${RED}Failed applications:${NC}"
    for failed_app in "${FAILED[@]}"; do
        echo -e "  - $failed_app"
    done
fi

echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Review analysis files in /tmp/*-analysis.txt"
echo -e "  2. Update docker-compose.yml files to remove hardcoded values"
echo -e "  3. Create/update .env.example files"
echo -e "  4. Run validation for each app"
echo -e "  5. Commit changes per app or in batches"
echo ""
