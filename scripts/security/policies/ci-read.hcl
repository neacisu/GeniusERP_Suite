# Policy: ci-read
# Description: Limited read access for CI/CD pipelines
# Principle: Least privilege - only NPM token and build secrets

# NPM token for package installations
path "secret/data/ci/npm" {
  capabilities = ["read"]
}

# Build-time secrets (non-sensitive config)
path "secret/data/ci/build/*" {
  capabilities = ["read", "list"]
}

# Docker registry credentials
path "secret/data/ci/docker" {
  capabilities = ["read"]
}

# Allow token renewal
path "auth/token/renew-self" {
  capabilities = ["update"]
}

# Allow looking up own token
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
