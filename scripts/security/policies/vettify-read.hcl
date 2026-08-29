# Policy: vettify-read
# Description: Read-only access to Vettify KV + runtime DB creds

path "kv/data/apps/vettify" {
  capabilities = ["read"]
}

path "kv/metadata/apps/vettify" {
  capabilities = ["read"]
}

path "database/creds/vettify_runtime" {
  capabilities = ["read"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "auth/token/lookup-self" {
  capabilities = ["read"]
}
