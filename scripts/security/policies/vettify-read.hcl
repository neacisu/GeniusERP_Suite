# Policy: vettify-read
# Description: Read-only access to Vettify secrets (includes Neo4j)
path "secret/data/vettify/*" {
  capabilities = ["read", "list"]
}
path "database/creds/vettify-role" {
  capabilities = ["read"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
