# Policy: proxy-read
# Description: Read-only access to Traefik proxy secrets (TLS, Let's Encrypt)
path "secret/data/infrastructure/proxy/*" {
  capabilities = ["read", "list"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
