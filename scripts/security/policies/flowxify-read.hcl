# Policy: flowxify-read
# Description: Read-only access to Flowxify secrets
path "secret/data/flowxify/*" {
  capabilities = ["read", "list"]
}
path "database/creds/flowxify-role" {
  capabilities = ["read"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
