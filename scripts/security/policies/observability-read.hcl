# Policy: observability-read
# Description: Read-only access for observability stack (Prometheus, Grafana, Loki, Tempo)
path "secret/data/infrastructure/observability/*" {
  capabilities = ["read", "list"]
}
path "secret/data/infrastructure/prometheus/*" {
  capabilities = ["read", "list"]
}
path "secret/data/infrastructure/grafana/*" {
  capabilities = ["read", "list"]
}
path "secret/data/infrastructure/loki/*" {
  capabilities = ["read", "list"]
}
path "secret/data/infrastructure/tempo/*" {
  capabilities = ["read", "list"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
