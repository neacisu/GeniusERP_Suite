# Policy: suite-shell-read
# Description: Read-only access to Suite Shell (CP) secrets
path "kv/data/cp/suite-shell" {
  capabilities = ["read"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
