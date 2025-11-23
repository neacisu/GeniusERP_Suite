# Policy: numeriqo-read
# Description: Read-only access to Numeriqo secrets (KV and dynamic DB)
# Principle: Least privilege

# KV v2 secrets for Numeriqo (apps namespace)
path "kv/data/apps/numeriqo" {
  capabilities = ["read"]
}

# Allow metadata lookups for troubleshooting (optional)
path "kv/metadata/apps/numeriqo" {
  capabilities = ["read"]
}

# Database dynamic credentials for Numeriqo runtime role
path "database/creds/numeriqo_runtime" {
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
