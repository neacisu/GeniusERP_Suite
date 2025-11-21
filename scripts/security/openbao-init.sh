#!/bin/bash
set -e

# Configuration
BAO_ADDR=${BAO_ADDR:-"http://127.0.0.1:8200"}
SECRETS_DIR="/var/www/GeniusSuite/.secrets"
KEYS_FILE="${SECRETS_DIR}/openbao-keys.json"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[OpenBao Init]${NC} $1"
}

error() {
    echo -e "${RED}[OpenBao Init]${NC} $1"
}

# Ensure secrets directory exists
mkdir -p "$SECRETS_DIR"

# Check if OpenBao is reachable
log "Checking OpenBao status at $BAO_ADDR..."
if ! curl -s "$BAO_ADDR/v1/sys/health" > /dev/null; then
    # Health check might return non-200 if sealed or uninitialized, which is fine.
    # We just want to know if the connection is refused.
    # curl exit code 7 is "Failed to connect to host"
    curl_status=$?
    if [ $curl_status -eq 7 ]; then
        error "OpenBao is not reachable. Is the container running?"
        exit 1
    fi
fi

# Check initialization status
INIT_STATUS=$(curl -s "$BAO_ADDR/v1/sys/init" | grep '"initialized":true') || true

if [ -n "$INIT_STATUS" ]; then
    log "OpenBao is already initialized."
else
    log "Initializing OpenBao..."
    INIT_OUTPUT=$(docker exec geniuserp-openbao bao operator init -key-shares=1 -key-threshold=1 -format=json)
    
    if [ $? -eq 0 ]; then
        echo "$INIT_OUTPUT" > "$KEYS_FILE"
        chmod 600 "$KEYS_FILE"
        log "Initialization successful. Keys saved to $KEYS_FILE"
    else
        error "Initialization failed."
        exit 1
    fi
fi

# Check seal status
SEAL_STATUS=$(curl -s "$BAO_ADDR/v1/sys/health" | grep '"sealed":true') || true

if [ -n "$SEAL_STATUS" ]; then
    log "OpenBao is sealed. Attempting unseal..."
    
    if [ ! -f "$KEYS_FILE" ]; then
        error "Keys file not found at $KEYS_FILE. Cannot unseal automatically."
        exit 1
    fi
    
    UNSEAL_KEY=$(jq -r ".unseal_keys_b64[0]" "$KEYS_FILE")
    
    if [ -z "$UNSEAL_KEY" ] || [ "$UNSEAL_KEY" == "null" ]; then
        error "Could not extract unseal key from $KEYS_FILE."
        exit 1
    fi
    
    UNSEAL_OUTPUT=$(docker exec geniuserp-openbao bao operator unseal "$UNSEAL_KEY")
    
    if [ $? -eq 0 ]; then
        log "Unseal successful."
    else
        error "Unseal failed."
        exit 1
    fi
else
    log "OpenBao is already unsealed."
fi

# Final health check
log "OpenBao is ready and operational."
