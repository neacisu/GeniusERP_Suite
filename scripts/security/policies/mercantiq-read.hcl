# Policy: mercantiq-read
# Description: Read-only access to Mercantiq secrets
path "secret/data/mercantiq/*" {
  capabilities = ["read", "list"]
}
path "database/creds/mercantiq-role" {
  capabilities = ["read"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
