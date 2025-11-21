# Policy: geniuserp-read
# Description: Read-only access to GeniusERP secrets
path "secret/data/geniuserp/*" {
  capabilities = ["read", "list"]
}
path "database/creds/geniuserp-role" {
  capabilities = ["read"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
