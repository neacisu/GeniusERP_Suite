# OpenBao Quick Reference Card

> **Cheat sheet for daily OpenBao operations**

## Environment Setup

```bash
# Export OpenBao credentials (run once per terminal session)
export BAO_TOKEN=$(jq -r '.root_token' .secrets/openbao-keys.json)
export BAO_ADDR=http://127.0.0.1:8200

# Or use the helper command
pnpm openbao:login
```

## Common Commands

### Secrets Management

```bash
# List all secrets engines
bao secrets list

# Read a static secret
bao kv get kv/apps/numeriqo

# Write a static secret
bao kv put kv/apps/numeriqo jwt_secret="new-value"

# Delete a secret
bao kv delete kv/apps/numeriqo

# Get secret metadata
bao kv metadata get kv/apps/numeriqo
```

### Dynamic Database Credentials

```bash
# Generate new DB credentials
bao read database/creds/numeriqo_runtime

# List active leases
bao list sys/leases/lookup/database/creds/numeriqo_runtime

# Renew a lease
bao lease renew database/creds/numeriqo_runtime/LEASE_ID

# Revoke a lease
bao lease revoke database/creds/numeriqo_runtime/LEASE_ID
```

### AppRole Management

```bash
# List all AppRoles
bao list auth/approle/role

# Get role-id
bao read -field=role_id auth/approle/role/numeriqo/role-id

# Generate new secret-id
bao write -f auth/approle/role/numeriqo/secret-id

# List secret-id accessors
bao list auth/approle/role/numeriqo/secret-id
```

### Policies

```bash
# List all policies
bao policy list

# Read a policy
bao policy read numeriqo-read

# Write a policy
bao policy write numeriqo-read scripts/security/policies/numeriqo-read.hcl

# Test token capabilities
bao token capabilities kv/data/apps/numeriqo
```

## Application Workflows

### Start Application with Process Supervisor

```bash
# 1. Setup AppRole (once)
cd numeriqo.app
./scripts/setup-approle.sh

# 2. Start application
docker compose -f compose/docker-compose.yml up --build

# 3. View logs
docker logs -f genius-suite-numeriqo-app
```

### Run Migrations

```bash
# Inside container with injected secrets
docker compose -f numeriqo.app/compose/docker-compose.yml run --rm numeriqo-app \
  node dist/numeriqo.app/src/migrations/run.js
```

### Debug Secret Injection

```bash
# Check if secrets were rendered
docker exec genius-suite-numeriqo-app ls -la /app/secrets/

# View rendered .env
docker exec genius-suite-numeriqo-app cat /app/secrets/.env

# View DB credentials
docker exec genius-suite-numeriqo-app cat /app/secrets/db-creds.json
```

## Troubleshooting

### OpenBao Not Accessible

```bash
# Check if OpenBao is running
docker ps | grep openbao

# Check OpenBao health
curl http://127.0.0.1:8200/v1/sys/health

# View OpenBao logs
docker logs geniuserp-openbao
```

### Secrets Not Found

```bash
# Verify secret exists
bao kv get kv/apps/numeriqo

# If not, seed secrets
pnpm openbao:seed
```

### AppRole Authentication Failed

```bash
# Check role-id file exists
cat .secrets/approle/numeriqo/role-id

# Check secret-id file exists
cat .secrets/approle/numeriqo/secret-id

# Regenerate credentials
cd numeriqo.app && ./scripts/setup-approle.sh
```

### Database Connection Failed

```bash
# Check if DB engine is enabled
bao secrets list | grep database

# If not, enable it
pnpm openbao:db-engine

# Verify role exists
bao read database/roles/numeriqo_runtime

# Test credential generation
bao read database/creds/numeriqo_runtime
```

## Helper Scripts

```bash
# Initialize OpenBao (first time only)
pnpm openbao:init

# Seed all secrets
pnpm openbao:seed

# Enable database engine
pnpm openbao:db-engine

# Sync application roles
pnpm openbao:sync-roles

# Full setup (all of the above)
pnpm dev:openbao
```

## Useful Aliases

Add to `~/.bashrc` or `~/.zshrc`:

```bash
# OpenBao login
alias bao-login='export BAO_TOKEN=$(jq -r ".root_token" .secrets/openbao-keys.json) BAO_ADDR=http://127.0.0.1:8200'

# Quick secret read
alias bao-get='bao kv get kv/apps/$1'

# Quick DB creds
alias bao-db='bao read database/creds/${1}_runtime'

# Setup AppRole
alias bao-approle='cd $1 && ./scripts/setup-approle.sh && cd -'

# View secrets in container
alias bao-secrets='docker exec genius-suite-$1-app cat /app/secrets/.env'
```

## Emergency Procedures

### Unseal OpenBao (if sealed)

```bash
# Get unseal keys
cat .secrets/openbao-keys.json | jq -r '.unseal_keys_b64[]'

# Unseal (need 3 keys)
bao operator unseal KEY1
bao operator unseal KEY2
bao operator unseal KEY3
```

### Rotate Root Token

```bash
# Generate new root token
bao token create -policy=root

# Update .secrets/openbao-keys.json manually
```

### Backup Secrets

```bash
# Export all KV secrets
for app in numeriqo archify cerniq; do
  bao kv get -format=json kv/apps/$app > backup-$app.json
done
```

## Links

- [Full Developer Guide](OpenBao-Process-Supervisor.md)
- [Numeriqo Pilot README](../../numeriqo.app/README.md)
- [OpenBao Documentation](https://openbao.org/docs/)
