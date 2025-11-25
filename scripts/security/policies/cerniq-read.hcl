# Policy: cerniq-read
# Description: Read-only access to Cerniq KV + runtime DB creds

path "kv/data/apps/cerniq" {
  capabilities = ["read"]
}

path "kv/metadata/apps/cerniq" {
  capabilities = ["read"]
}

path "database/creds/cerniq_runtime" {
  capabilities = ["read"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "auth/token/lookup-self" {
  capabilities = ["read"]
}
