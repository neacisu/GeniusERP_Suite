# Policy: archify-read
# Description: Read-only access to Archify KV + database credentials

# KV v2 secrets
path "kv/data/apps/archify" {
  capabilities = ["read"]
}

path "kv/metadata/apps/archify" {
  capabilities = ["read"]
}

# Dynamic database credentials
path "database/creds/archify_runtime" {
  capabilities = ["read"]
}

# Token maintenance
path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "auth/token/lookup-self" {
  capabilities = ["read"]
}
