# Policy: analytics-hub-read
# Description: Read-only access to Analytics Hub (CP) secrets
path "secret/data/cp/analytics-hub/*" {
  capabilities = ["read", "list"]
}
path "database/creds/analytics-hub-role" {
  capabilities = ["read"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
