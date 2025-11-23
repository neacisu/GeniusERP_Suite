#!/usr/bin/env bash
#
# setup_oidc_roles.sh - Configure OIDC roles and policies for CI/CD pipelines
#
# This script creates specific roles for different pipeline stages with
# appropriate bound claims and least-privilege policies.
#
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  OpenBao OIDC Roles and Policies for CI/CD${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# Check prerequisites
if [[ -z "${BAO_TOKEN:-}" ]]; then
    echo -e "${RED}✗ BAO_TOKEN not set${NC}"
    echo -e "  Export it: export BAO_TOKEN=\$(jq -r '.root_token' .secrets/openbao-keys.json)"
    exit 1
fi

if [[ -z "${BAO_ADDR:-}" ]]; then
    echo -e "${RED}✗ BAO_ADDR not set${NC}"
    echo -e "  Export it: export BAO_ADDR=http://127.0.0.1:8200"
    exit 1
fi

# Repository configuration
REPO="neacisu/GeniusERP_Suite"
AUDIENCE="https://github.com/neacisu"

echo -e "${BLUE}[1/4] Creating pipeline policies...${NC}"
echo ""

# Policy 1: Test/Build - Read-only access to secrets
echo -e "  Creating ${YELLOW}ci-test-build${NC} policy..."
cat > /tmp/ci-test-build.hcl <<'EOF'
# CI Test/Build Policy
# Read-only access for test and build stages

# Read static secrets from KV
path "kv/data/apps/*" {
  capabilities = ["read"]
}

# Read database credentials (dynamic)
path "database/creds/*" {
  capabilities = ["read"]
}

# Renew own token
path "auth/token/renew-self" {
  capabilities = ["update"]
}

# Lookup own token
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
EOF

bao policy write ci-test-build /tmp/ci-test-build.hcl
echo -e "${GREEN}    ✓ ci-test-build policy created${NC}"

# Policy 2: E2E - Read access + ability to generate DB credentials
echo -e "  Creating ${YELLOW}ci-e2e${NC} policy..."
cat > /tmp/ci-e2e.hcl <<'EOF'
# CI E2E Policy
# Read access + dynamic DB credential generation for end-to-end tests

# Read static secrets from KV
path "kv/data/apps/*" {
  capabilities = ["read", "list"]
}

# Generate database credentials for all apps
path "database/creds/*" {
  capabilities = ["read"]
}

# List database roles
path "database/roles/*" {
  capabilities = ["list"]
}

# Renew and revoke own tokens/leases
path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "auth/token/lookup-self" {
  capabilities = ["read"]
}

path "sys/leases/renew" {
  capabilities = ["update"]
}

path "sys/leases/revoke" {
  capabilities = ["update"]
}
EOF

bao policy write ci-e2e /tmp/ci-e2e.hcl
echo -e "${GREEN}    ✓ ci-e2e policy created${NC}"

# Policy 3: Release - Read access + limited write for deployment secrets
echo -e "  Creating ${YELLOW}ci-release${NC} policy..."
cat > /tmp/ci-release.hcl <<'EOF'
# CI Release Policy
# Read access + limited write for deployment and release processes

# Read all app secrets
path "kv/data/apps/*" {
  capabilities = ["read", "list"]
}

# Write deployment-specific secrets
path "kv/data/deployments/*" {
  capabilities = ["create", "read", "update", "list"]
}

# Generate database credentials
path "database/creds/*" {
  capabilities = ["read"]
}

# Manage own tokens and leases
path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "auth/token/lookup-self" {
  capabilities = ["read"]
}

path "sys/leases/renew" {
  capabilities = ["update"]
}

path "sys/leases/revoke" {
  capabilities = ["update"]
}
EOF

bao policy write ci-release /tmp/ci-release.hcl
echo -e "${GREEN}    ✓ ci-release policy created${NC}"

# Cleanup temp files
rm -f /tmp/ci-*.hcl

echo ""
echo -e "${BLUE}[2/4] Creating OIDC role for test/build (dev, feature branches)...${NC}"

# Role 1: Test/Build - For dev and feature branches
bao write auth/jwt/role/ci-test-build \
    role_type="jwt" \
    bound_audiences="${AUDIENCE}" \
    user_claim="actor" \
    bound_claims_type="glob" \
    bound_claims="{\"repository\":\"${REPO}\",\"ref\":\"refs/heads/*\"}" \
    token_ttl="15m" \
    token_max_ttl="30m" \
    token_policies="ci-test-build"

echo -e "${GREEN}  ✓ ci-test-build role created${NC}"
echo -e "    Repository: ${REPO}"
echo -e "    Branches: refs/heads/* (all branches)"
echo -e "    TTL: 15m (max 30m)"
echo -e "    Policy: ci-test-build (read-only)"

echo ""
echo -e "${BLUE}[3/4] Creating OIDC role for E2E tests (main, develop)...${NC}"

# Role 2: E2E - For main and develop branches
bao write auth/jwt/role/ci-e2e \
    role_type="jwt" \
    bound_audiences="${AUDIENCE}" \
    user_claim="actor" \
    bound_claims_type="string" \
    bound_claims="{\"repository\":\"${REPO}\",\"ref\":\"refs/heads/main\"}" \
    token_ttl="20m" \
    token_max_ttl="1h" \
    token_policies="ci-e2e"

echo -e "${GREEN}  ✓ ci-e2e role created (main branch)${NC}"

# Also create for develop branch
bao write auth/jwt/role/ci-e2e-develop \
    role_type="jwt" \
    bound_audiences="${AUDIENCE}" \
    user_claim="actor" \
    bound_claims_type="string" \
    bound_claims="{\"repository\":\"${REPO}\",\"ref\":\"refs/heads/develop\"}" \
    token_ttl="20m" \
    token_max_ttl="1h" \
    token_policies="ci-e2e"

echo -e "${GREEN}  ✓ ci-e2e-develop role created (develop branch)${NC}"
echo -e "    Repository: ${REPO}"
echo -e "    Branches: main, develop"
echo -e "    TTL: 20m (max 1h)"
echo -e "    Policy: ci-e2e (read + DB creds)"

echo ""
echo -e "${BLUE}[4/4] Creating OIDC role for releases (tags only)...${NC}"

# Role 3: Release - For tags only
bao write auth/jwt/role/ci-release \
    role_type="jwt" \
    bound_audiences="${AUDIENCE}" \
    user_claim="actor" \
    bound_claims_type="glob" \
    bound_claims="{\"repository\":\"${REPO}\",\"ref\":\"refs/tags/*\"}" \
    token_ttl="30m" \
    token_max_ttl="2h" \
    token_policies="ci-release"

echo -e "${GREEN}  ✓ ci-release role created${NC}"
echo -e "    Repository: ${REPO}"
echo -e "    Branches: refs/tags/* (tags only)"
echo -e "    TTL: 30m (max 2h)"
echo -e "    Policy: ci-release (read + limited write)"

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ OIDC roles and policies configured!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}Summary:${NC}"
echo ""
echo -e "  ${YELLOW}ci-test-build${NC} role:"
echo -e "    - Branches: All (refs/heads/*)"
echo -e "    - Policy: Read-only KV + DB creds"
echo -e "    - Use for: Unit tests, builds, linting"
echo ""
echo -e "  ${YELLOW}ci-e2e${NC} roles:"
echo -e "    - Branches: main, develop"
echo -e "    - Policy: Read KV + DB creds + lease management"
echo -e "    - Use for: Integration tests, E2E tests"
echo ""
echo -e "  ${YELLOW}ci-release${NC} role:"
echo -e "    - Branches: Tags only (refs/tags/*)"
echo -e "    - Policy: Read KV + write deployments + DB creds"
echo -e "    - Use for: Releases, deployments"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. Update GitHub Actions workflows to use appropriate roles"
echo -e "  2. Test authentication for each role"
echo -e "  3. Verify least-privilege access"
echo ""
