# Policy: admin-write
# Description: Administrative write access for managing secrets
# Principle: Elevated privileges for DevOps operations

# Full access to all application secrets
path "secret/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/metadata/*" {
  capabilities = ["list", "read", "delete"]
}

# Full access to database role management
path "database/roles/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Full access to database credential generation
path "database/creds/*" {
  capabilities = ["read"]
}

# Policy management
path "sys/policies/acl/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Auth method management
path "sys/auth/*" {
  capabilities = ["create", "read", "update", "delete", "sudo"]
}

# Mount management
path "sys/mounts/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Token creation for other services
path "auth/token/create" {
  capabilities = ["create", "update"]
}

# Token renewal
path "auth/token/renew-self" {
  capabilities = ["update"]
}

# Token lookup
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
