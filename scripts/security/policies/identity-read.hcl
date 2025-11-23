# Policy: identity-read
# Description: Read-only access to Identity (SuperTokens) secrets
# Principle: Least privilege

# KV v2 secrets for Identity Control Plane
path "kv/data/cp/identity" {
  capabilities = ["read"]
}

# Database dynamic credentials for Identity
path "database/creds/cp_identity_runtime" {
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
