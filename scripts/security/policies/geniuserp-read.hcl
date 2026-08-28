# Policy: geniuserp-read
# Description: Read-only access to GeniusERP KV + runtime DB creds

path "kv/data/apps/geniuserp" {
  capabilities = ["read"]
}

path "kv/metadata/apps/geniuserp" {
  capabilities = ["read"]
}

path "database/creds/geniuserp_runtime" {
  capabilities = ["read"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "auth/token/lookup-self" {
  capabilities = ["read"]
}
