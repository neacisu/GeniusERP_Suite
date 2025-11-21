# Policy: suite-admin-read
# Description: Read-only access to Suite Admin (CP) secrets
path "secret/data/cp/suite-admin/*" {
  capabilities = ["read", "list"]
}
path "database/creds/suite-admin-role" {
  capabilities = ["read"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
