# Policy: archify-read
# Description: Read-only access to Archify secrets
path "secret/data/archify/*" {
  capabilities = ["read", "list"]
}
path "database/creds/archify-role" {
  capabilities = ["read"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
