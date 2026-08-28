#!/usr/bin/env bash
#
# openbao-configure-oidc.sh - Configure OpenBao OIDC for GitHub Actions
#
# This script sets up JWT/OIDC authentication method in OpenBao to allow
# GitHub Actions workflows to authenticate without static tokens.
#
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  OpenBao OIDC Configuration for GitHub Actions${NC}"
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

echo -e "${BLUE}[1/5] Enabling JWT/OIDC auth method...${NC}"

# Enable JWT auth method if not already enabled
if bao auth list | grep -q "jwt/"; then
    echo -e "${YELLOW}  ⚠ JWT auth method already enabled${NC}"
else
    bao auth enable jwt
    echo -e "${GREEN}  ✓ JWT auth method enabled${NC}"
fi

echo ""
echo -e "${BLUE}[2/5] Configuring GitHub OIDC provider...${NC}"

# Configure JWT auth with GitHub OIDC
bao write auth/jwt/config \
    oidc_discovery_url="https://token.actions.githubusercontent.com" \
    bound_issuer="https://token.actions.githubusercontent.com" \
    default_role="github-actions"

echo -e "${GREEN}  ✓ GitHub OIDC provider configured${NC}"
echo -e "    Issuer: https://token.actions.githubusercontent.com"

echo ""
echo -e "${BLUE}[3/5] Creating GitHub Actions role...${NC}"

# Create role for GitHub Actions
# This role maps GitHub OIDC tokens to OpenBao policies
bao write auth/jwt/role/github-actions \
    role_type="jwt" \
    bound_audiences="https://github.com/neacisu" \
    user_claim="actor" \
    bound_claims_type="glob" \
    bound_claims='{"repository":"neacisu/GeniusERP_Suite"}' \
    token_ttl="15m" \
    token_max_ttl="1h" \
    token_policies="ci-cd-read"

echo -e "${GREEN}  ✓ GitHub Actions role created${NC}"
echo -e "    Role name: github-actions"
echo -e "    Repository: neacisu/GeniusERP_Suite"
echo -e "    Token TTL: 15m (max 1h)"
echo -e "    Policies: ci-cd-read"

echo ""
echo -e "${BLUE}[4/5] Creating CI/CD policy...${NC}"

# Create policy for CI/CD access
cat > /tmp/ci-cd-read.hcl <<'EOF'
# CI/CD Read Policy
# Allows GitHub Actions to read secrets needed for testing and deployment

# Read static secrets from KV
path "kv/data/apps/*" {
  capabilities = ["read", "list"]
}

# Read database credentials (dynamic)
path "database/creds/*" {
  capabilities = ["read"]
}

# List secrets engines
path "sys/mounts" {
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

bao policy write ci-cd-read /tmp/ci-cd-read.hcl
rm /tmp/ci-cd-read.hcl

echo -e "${GREEN}  ✓ CI/CD policy created${NC}"
echo -e "    Policy name: ci-cd-read"
echo -e "    Permissions: read KV secrets, read DB creds"

echo ""
echo -e "${BLUE}[5/5] Verifying configuration...${NC}"

# Verify auth method
echo -e "  Checking JWT auth method..."
if bao auth list | grep -q "jwt/"; then
    echo -e "${GREEN}    ✓ JWT auth enabled${NC}"
else
    echo -e "${RED}    ✗ JWT auth not found${NC}"
    exit 1
fi

# Verify role
echo -e "  Checking GitHub Actions role..."
if bao read auth/jwt/role/github-actions > /dev/null 2>&1; then
    echo -e "${GREEN}    ✓ Role configured${NC}"
else
    echo -e "${RED}    ✗ Role not found${NC}"
    exit 1
fi

# Verify policy
echo -e "  Checking CI/CD policy..."
if bao policy read ci-cd-read > /dev/null 2>&1; then
    echo -e "${GREEN}    ✓ Policy exists${NC}"
else
    echo -e "${RED}    ✗ Policy not found${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ OIDC configuration complete!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. Update GitHub Actions workflows to use OIDC"
echo -e "  2. Remove static BAO_TOKEN from GitHub Secrets"
echo -e "  3. Test authentication with a workflow"
echo ""
echo -e "${BLUE}Example workflow snippet:${NC}"
echo -e "  ${YELLOW}permissions:${NC}"
echo -e "    ${YELLOW}id-token: write${NC}"
echo -e "    ${YELLOW}contents: read${NC}"
echo -e "  ${YELLOW}steps:${NC}"
echo -e "    ${YELLOW}- uses: hashicorp/vault-action@v2${NC}"
echo -e "      ${YELLOW}with:${NC}"
echo -e "        ${YELLOW}url: \${{ secrets.VAULT_ADDR }}${NC}"
echo -e "        ${YELLOW}role: github-actions${NC}"
echo -e "        ${YELLOW}method: jwt${NC}"
echo ""
