# Policy: suite-shell-read
# Description: Read-only access to Suite Shell (CP) secrets
path "secret/data/cp/suite-shell/*" {
  capabilities = ["read", "list"]
}
path "database/creds/suite-shell-role" {
  capabilities = ["read"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
