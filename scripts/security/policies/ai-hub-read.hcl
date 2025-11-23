# Policy: ai-hub-read
# Description: Read-only access to AI Hub (CP) secrets
path "kv/data/cp/ai-hub" {
  capabilities = ["read"]
}
path "database/creds/cp_aihub_runtime" {
  capabilities = ["read"]
}
path "database/creds/cp_aihub_vectors_runtime" {
  capabilities = ["read"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
