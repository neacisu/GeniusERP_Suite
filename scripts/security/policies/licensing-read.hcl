# Policy: licensing-read
# Description: Read-only access to Licensing (CP) secrets
path "kv/data/cp/licensing" {
  capabilities = ["read"]
}
path "database/creds/cp_licensing_runtime" {
  capabilities = ["read"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
