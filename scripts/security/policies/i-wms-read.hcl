# Policy: i-wms-read
# Description: Read-only access to i-WMS KV + runtime DB creds

path "kv/data/apps/i-wms" {
  capabilities = ["read"]
}

path "kv/metadata/apps/i-wms" {
  capabilities = ["read"]
}

path "database/creds/iwms_runtime" {
  capabilities = ["read"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "auth/token/lookup-self" {
  capabilities = ["read"]
}
