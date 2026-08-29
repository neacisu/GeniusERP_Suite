#!/usr/bin/env bash
#
# inject.sh - Bash wrapper for inject.ts
# Provides easier CLI access to secret injection fallback
#
# Usage: ./inject.sh <app-name> <command>
# Example: ./inject.sh numeriqo "npm run migrate"
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INJECT_TS="${SCRIPT_DIR}/inject.ts"

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <app-name> <command>"
    echo "Example: $0 numeriqo 'npm run migrate'"
    exit 1
fi

APP_NAME="$1"
COMMAND="$2"

# Check if inject.ts exists
if [[ ! -f "$INJECT_TS" ]]; then
    echo "Error: inject.ts not found at $INJECT_TS"
    exit 1
fi

# Execute inject.ts
exec ts-node "$INJECT_TS" "$APP_NAME" "$COMMAND"
