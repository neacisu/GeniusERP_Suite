# Policy: postgres-read
# Description: Read-only access to PostgreSQL infrastructure secrets
path "secret/data/infrastructure/postgres/*" {
  capabilities = ["read", "list"]
}
path "database/creds/postgres-admin-role" {
  capabilities = ["read"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
