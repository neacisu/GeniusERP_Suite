# Policy: analytics-hub-read
# Description: Read-only access to Analytics Hub (CP) secrets
path "kv/data/cp/analytics-hub" {
  capabilities = ["read"]
}
path "database/creds/cp_analytics_runtime" {
  capabilities = ["read"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
