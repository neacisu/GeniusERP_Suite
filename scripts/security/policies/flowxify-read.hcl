# Policy: flowxify-read
# Description: Read-only access to Flowxify KV and DB credentials

path "kv/data/apps/flowxify" {
  capabilities = ["read"]
}

path "kv/metadata/apps/flowxify" {
  capabilities = ["read"]
}

path "database/creds/flowxify_runtime" {
  capabilities = ["read"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "auth/token/lookup-self" {
  capabilities = ["read"]
}
