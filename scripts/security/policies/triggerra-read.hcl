# Policy: triggerra-read
# Description: Read-only access to Triggerra KV + runtime DB creds

path "kv/data/apps/triggerra" {
  capabilities = ["read"]
}

path "kv/metadata/apps/triggerra" {
  capabilities = ["read"]
}

path "database/creds/triggerra_runtime" {
  capabilities = ["read"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "auth/token/lookup-self" {
  capabilities = ["read"]
}
