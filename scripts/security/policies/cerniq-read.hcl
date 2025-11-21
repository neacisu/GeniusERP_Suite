# Policy: cerniq-read
# Description: Read-only access to Cerniq secrets
path "secret/data/cerniq/*" {
  capabilities = ["read", "list"]
}
path "database/creds/cerniq-role" {
  capabilities = ["read"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
