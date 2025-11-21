# Policy: neo4j-read
# Description: Read-only access to Neo4j secrets
# For Vettify and graph database authentication
path "secret/data/infrastructure/neo4j/*" {
  capabilities = ["read", "list"]
}
path "database/creds/neo4j-role" {
  capabilities = ["read"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
