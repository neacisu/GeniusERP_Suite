# Policy: triggerra-read
# Description: Read-only access to Triggerra secrets
path "secret/data/triggerra/*" {
  capabilities = ["read", "list"]
}
path "database/creds/triggerra-role" {
  capabilities = ["read"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
