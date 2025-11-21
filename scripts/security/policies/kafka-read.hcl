# Policy: kafka-read
# Description: Read-only access to Kafka infrastructure secrets
path "secret/data/infrastructure/kafka/*" {
  capabilities = ["read", "list"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
