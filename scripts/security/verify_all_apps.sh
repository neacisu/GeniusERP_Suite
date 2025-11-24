#!/bin/bash
# verify_all_apps.sh
# Verifies if apps have been migrated to Process Supervisor pattern

APPS=(
    "archify.app"
    "mercantiq.app"
    "flowxify.app"
    "triggerra.app"
    "cerniq.app"
    "i-wms.app"
    "vettify.app"
    "geniuserp.app"
    "cp/identity"
    "cp/licensing"
    "cp/suite-admin"
    "cp/suite-shell"
    "cp/suite-login"
    "cp/ai-hub"
    "cp/analytics-hub"
)

echo "Verifying apps..."
echo "---------------------------------------------------"
printf "%-20s | %-10s | %-10s | %-10s | %-10s\n" "App" "Config" "Compose" "EnvEx" "Docker"
echo "---------------------------------------------------"

for app in "${APPS[@]}"; do
    APP_NAME=$(basename "$app" .app)
    if [[ "$app" == cp/* ]]; then
        APP_NAME=$(basename "$app")
    fi
    
    # 1. Check OpenBao Config
    # Pattern: [app]/openbao/agent-config.hcl
    if [[ -f "$app/openbao/agent-config.hcl" ]]; then
        CONFIG="✅"
    else
        CONFIG="❌"
    fi

    # 2. Check Compose (check for BAO_AGENT_CONFIG env var)
    if [[ -f "$app/compose/docker-compose.yml" ]]; then
        if grep -q "BAO_AGENT_CONFIG=" "$app/compose/docker-compose.yml"; then
            COMPOSE="✅"
        else
            COMPOSE="❌"
        fi
    else
        COMPOSE="MISSING"
    fi

    # 3. Check .env.example
    # The naming convention varies. Let's check for .[appname].env.example or .env.example
    if [[ -f "$app/.$APP_NAME.env.example" ]] || [[ -f "$app/.env.example" ]]; then
        ENV="✅"
    else
        ENV="❌"
    fi

    # 4. Check Dockerfile
    if [[ -f "$app/Dockerfile" ]]; then
        if grep -q "geniuserp/node-openbao:local" "$app/Dockerfile"; then
            DOCKER="✅"
        else
            DOCKER="❌"
        fi
    else
        DOCKER="MISSING"
    fi

    printf "%-20s | %-10s | %-10s | %-10s | %-10s\n" "$app" "$CONFIG" "$COMPOSE" "$ENV" "$DOCKER"
done
