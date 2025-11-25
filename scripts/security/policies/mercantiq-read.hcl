# Policy: mercantiq-read
# Description: Read-only access to Mercantiq secrets (KV + DB creds)

path "kv/data/apps/mercantiq" {
  capabilities = ["read"]
}

path "kv/metadata/apps/mercantiq" {
  capabilities = ["read"]
}

path "database/creds/mercantiq_runtime" {
  capabilities = ["read"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "auth/token/lookup-self" {
  capabilities = ["read"]
}
