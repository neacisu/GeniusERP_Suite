# Policy: ai-hub-read
# Description: Read-only access to AI Hub (CP) secrets
path "secret/data/cp/ai-hub/*" {
  capabilities = ["read", "list"]
}
path "database/creds/ai-hub-role" {
  capabilities = ["read"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
