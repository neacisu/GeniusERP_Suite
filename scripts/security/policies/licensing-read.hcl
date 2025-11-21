# Policy: licensing-read
# Description: Read-only access to Licensing (CP) secrets
path "secret/data/cp/licensing/*" {
  capabilities = ["read", "list"]
}
path "database/creds/licensing-role" {
  capabilities = ["read"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
