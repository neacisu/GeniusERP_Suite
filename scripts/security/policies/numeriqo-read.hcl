# Policy: numeriqo-read
# Description: Read-only access to Numeriqo secrets (KV and dynamic DB)
# Principle: Least privilege

# KV v2 secrets for Numeriqo
path "secret/data/numeriqo/*" {
  capabilities = ["read", "list"]
}

# Database dynamic credentials for Numeriqo
path "database/creds/numeriqo-role" {
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
