# Policy: identity-read
# Description: Read-only access to Identity (SuperTokens) secrets
# Principle: Least privilege

# KV v2 secrets for Identity Control Plane
path "secret/data/cp/identity/*" {
  capabilities = ["read", "list"]
}

# Database dynamic credentials for Identity
path "database/creds/identity-role" {
  capabilities = ["read"]
}

# Allow token renewal
path "auth/token/renew-self" {
  capabilities = ["update"]
}

# Allow looking up own token
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
