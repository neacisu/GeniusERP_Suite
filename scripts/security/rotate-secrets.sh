#!/usr/bin/env bash
#
# rotate-secrets.sh - Helper script for rotating static secrets in OpenBao
#
# Usage: ./rotate-secrets.sh <app> <secret_key> [new_value]
# If new_value is not provided, a random 32-byte string is generated.
#

set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <app> <secret_key> [new_value]"
    echo "Example: $0 numeriqo jwt_secret"
    echo "Example: $0 deployments/github pat_token ghp_..."
    exit 1
fi

APP="$1"
KEY="$2"
VALUE="${3:-}"

# Generate random value if not provided
if [[ -z "$VALUE" ]]; then
    echo "Generating random value for $KEY..."
    VALUE=$(openssl rand -base64 32)
fi

# Determine path
if [[ "$APP" == "deployments/"* ]]; then
    PATH="kv/data/$APP"
else
    PATH="kv/data/apps/$APP"
fi

echo "Rotating $KEY in $PATH..."

# Check if path exists
if ! bao kv get "$PATH" > /dev/null 2>&1; then
    echo "Error: Path $PATH does not exist."
    exit 1
fi

# Patch the secret
bao kv patch "$PATH" "$KEY=$VALUE"

echo "✓ Successfully rotated $KEY"
echo "  New version created."
echo "  Note: Applications may need a restart to pick up the new value."
