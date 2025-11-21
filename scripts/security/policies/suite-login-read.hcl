# Policy: suite-login-read
# Description: Read-only access to Suite Login (CP) secrets
path "secret/data/cp/suite-login/*" {
  capabilities = ["read", "list"]
}
path "database/creds/suite-login-role" {
  capabilities = ["read"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
