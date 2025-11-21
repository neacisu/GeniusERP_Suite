# Policy: i-wms-read
# Description: Read-only access to i-WMS secrets
path "secret/data/i-wms/*" {
  capabilities = ["read", "list"]
}
path "database/creds/iwms-role" {
  capabilities = ["read"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
