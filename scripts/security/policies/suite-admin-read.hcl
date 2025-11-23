# Policy: suite-admin-read
# Description: Read-only access to Suite Admin (CP) secrets
path "kv/data/cp/suite-admin" {
  capabilities = ["read"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
