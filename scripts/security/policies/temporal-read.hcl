# Policy: temporal-read
# Description: Read-only access to Temporal workflow secrets
path "secret/data/infrastructure/temporal/*" {
  capabilities = ["read", "list"]
}
path "database/creds/temporal-role" {
  capabilities = ["read"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
