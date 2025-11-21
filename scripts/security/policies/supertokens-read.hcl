# Policy: supertokens-read
# Description: Read-only access to SuperTokens (Identity) secrets
path "secret/data/infrastructure/supertokens/*" {
  capabilities = ["read", "list"]
}
path "database/creds/supertokens-role" {
  capabilities = ["read"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
