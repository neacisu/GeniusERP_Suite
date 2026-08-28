# Policy: proxy-read
# Description: Read-only access to Traefik proxy secrets (dashboard auth, DNS)
path "kv/data/infrastructure/proxy" {
  capabilities = ["read"]
}

path "kv/data/infrastructure/proxy/*" {
  capabilities = ["read", "list"]
}

path "kv/metadata/infrastructure/proxy/*" {
  capabilities = ["read", "list"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
