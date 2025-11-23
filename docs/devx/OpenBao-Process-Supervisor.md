# OpenBao Process Supervisor - Developer Guide

> **Audience**: GeniusERP Suite Developers  
> **Last Updated**: 2025-11-23  
> **Status**: Official Developer Experience Guide

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [How It Works](#how-it-works)
- [Local Development](#local-development)
- [Running Migrations](#running-migrations)
- [Debugging](#debugging)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)

---

## Overview

The **Process Supervisor pattern** eliminates the need for local `.env` files by using OpenBao Agent to automatically inject secrets into application containers at runtime.

### Benefits

✅ **No more `.env` files** - Secrets managed centrally in OpenBao  
✅ **Dynamic credentials** - Database passwords rotate automatically  
✅ **Zero Trust** - Applications never see secrets they don't need  
✅ **Audit trail** - All secret access is logged in OpenBao  
✅ **Production parity** - Same secret injection in dev and prod

### Architecture

```
┌──────────────────────────────────────────────────────┐
│  Developer Machine                                   │
│                                                       │
│  ┌────────────────────────────────────────────────┐  │
│  │ OpenBao Server (container)                     │  │
│  │  - KV secrets engine (static secrets)          │  │
│  │  - Database secrets engine (dynamic creds)     │  │
│  │  - AppRole auth                                │  │
│  └────────────────────────────────────────────────┘  │
│                        │                              │
│                        ▼                              │
│  ┌────────────────────────────────────────────────┐  │
│  │ Application Container (e.g., Numeriqo)         │  │
│  │                                                 │  │
│  │  ┌──────────────────────────────────────────┐  │  │
│  │  │ OpenBao Agent (Process Supervisor)       │  │  │
│  │  │  1. Auto-auth with AppRole               │  │  │
│  │  │  2. Fetch secrets from OpenBao           │  │  │
│  │  │  3. Render templates                     │  │  │
│  │  │  4. Execute application                  │  │  │
│  │  └──────────────────────────────────────────┘  │  │
│  │                        │                         │  │
│  │                        ▼                         │  │
│  │  ┌──────────────────────────────────────────┐  │  │
│  │  │ Node.js Application                      │  │  │
│  │  │  - Secrets loaded from /app/secrets/     │  │  │
│  │  └──────────────────────────────────────────┘  │  │
│  └────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────┘
```

---

## Quick Start

### Prerequisites

1. **Docker and Docker Compose** installed
2. **OpenBao running**:
   ```bash
   docker compose up openbao -d
   ./scripts/security/openbao-init.sh
   ```

3. **Secrets seeded**:
   ```bash
   export BAO_TOKEN=$(jq -r '.root_token' .secrets/openbao-keys.json)
   export BAO_ADDR=http://127.0.0.1:8200
   ./scripts/security/seed-secrets.sh --profile dev --non-interactive
   ```

### Start an Application (Example: Numeriqo)

```bash
# 1. Generate AppRole credentials
cd numeriqo.app
./scripts/setup-approle.sh

# 2. Start the application
docker compose -f compose/docker-compose.yml up --build

# 3. Verify it's running
curl http://localhost:6750/health
```

That's it! No `.env` file needed. 🎉

---

## How It Works

### 1. AppRole Authentication

Each application has an **AppRole** in OpenBao with specific permissions:

```hcl
# Example: numeriqo-read policy
path "kv/data/apps/numeriqo" {
  capabilities = ["read"]
}

path "database/creds/numeriqo_runtime" {
  capabilities = ["read"]
}
```

AppRole credentials (`role-id` + `secret-id`) are mounted into the container:

```yaml
volumes:
  - .secrets/approle/numeriqo/role-id:/openbao/role-id:ro
  - .secrets/approle/numeriqo/secret-id:/openbao/secret-id:ro
```

### 2. OpenBao Agent Configuration

The agent config (`openbao/agent-config.hcl`) defines:

- **Auto-auth**: How to authenticate with OpenBao
- **Templates**: What secrets to fetch and where to write them
- **Exec**: What command to run after secrets are ready

Example:

```hcl
auto_auth {
  method {
    type = "approle"
    config = {
      role_id_file_path = "/openbao/role-id"
      secret_id_file_path = "/openbao/secret-id"
    }
  }
}

template {
  source      = "/openbao/templates/db-creds.tpl"
  destination = "/app/secrets/db-creds.json"
  
  exec {
    command = ["/app/scripts/start-app.sh"]
  }
}
```

### 3. Template Rendering

Templates use Go template syntax to fetch secrets:

```hcl
{{- with secret "database/creds/numeriqo_runtime" -}}
{
  "username": "{{ .Data.username }}",
  "password": "{{ .Data.password }}"
}
{{- end -}}
```

### 4. Application Startup

The Process Supervisor script (`start-app.sh`):

1. Sources rendered secrets from `/app/secrets/.env`
2. Validates critical secrets are present
3. Starts the Node.js application

```bash
#!/bin/sh
set -a
. /app/secrets/.env
set +a

# Validate
if [ -z "$NUMQ_DB_USER" ]; then
  echo "ERROR: Database credentials not injected!"
  exit 1
fi

# Start app
exec node dist/numeriqo.app/src/index.js
```

---

## Local Development

### Option 1: Full Process Supervisor (Recommended)

Run the application exactly as it runs in production:

```bash
# Start OpenBao and dependencies
docker compose up openbao postgres -d

# Start your application with Process Supervisor
docker compose -f numeriqo.app/compose/docker-compose.yml up --build
```

**Pros**:
- ✅ Production parity
- ✅ Tests secret injection
- ✅ No local `.env` files

**Cons**:
- ❌ Slower startup (Agent needs to fetch secrets)
- ❌ Requires OpenBao running

### Option 2: Local `.env` (Fallback)

For rapid iteration, you can still use a local `.env` file:

```bash
# Copy example
cp numeriqo.app/.numeriqo.env.example numeriqo.app/.numeriqo.env

# Fill in values manually
nano numeriqo.app/.numeriqo.env

# Run locally (NOT in Docker)
cd numeriqo.app
pnpm dev
```

**Pros**:
- ✅ Fast iteration
- ✅ No Docker overhead

**Cons**:
- ❌ Not production-like
- ❌ Manual secret management
- ❌ Secrets in Git history risk

---

## Running Migrations

### Database Migrations

To run migrations inside a container with injected secrets:

```bash
# Option 1: Exec into running container
docker exec -it genius-suite-numeriqo-app sh
cd /app
node dist/numeriqo.app/src/migrations/run.js

# Option 2: One-off command
docker compose -f numeriqo.app/compose/docker-compose.yml run --rm numeriqo-app \
  node dist/numeriqo.app/src/migrations/run.js
```

### CLI Commands

For CLI tools that need secrets:

```bash
# Example: Seed database
docker compose -f numeriqo.app/compose/docker-compose.yml run --rm numeriqo-app \
  node dist/numeriqo.app/src/cli/seed.js

# Example: Generate report
docker compose -f numeriqo.app/compose/docker-compose.yml run --rm numeriqo-app \
  node dist/numeriqo.app/src/cli/generate-report.js --month 11
```

**Note**: The OpenBao Agent will run first, inject secrets, then execute your command.

---

## Debugging

### View Injected Secrets

```bash
# List rendered secret files
docker exec genius-suite-numeriqo-app ls -la /app/secrets/

# View .env file
docker exec genius-suite-numeriqo-app cat /app/secrets/.env

# View DB credentials JSON
docker exec genius-suite-numeriqo-app cat /app/secrets/db-creds.json
```

### Check OpenBao Agent Logs

```bash
# View container logs (includes Agent output)
docker logs -f genius-suite-numeriqo-app

# Look for:
# - "[Process Supervisor] Starting..."
# - "[Process Supervisor] ✓ All secrets validated"
# - "[Process Supervisor] ✓ Database user: v-root-numeriqo-..."
```

### Verify AppRole Credentials

```bash
# Check role-id exists
cat .secrets/approle/numeriqo/role-id

# Check secret-id exists
cat .secrets/approle/numeriqo/secret-id

# Test authentication manually
export BAO_ADDR=http://127.0.0.1:8200
bao write auth/approle/login \
  role_id=$(cat .secrets/approle/numeriqo/role-id) \
  secret_id=$(cat .secrets/approle/numeriqo/secret-id)
```

### Verify Secrets in OpenBao

```bash
export BAO_TOKEN=$(jq -r '.root_token' .secrets/openbao-keys.json)
export BAO_ADDR=http://127.0.0.1:8200

# Check static secrets
bao kv get kv/apps/numeriqo

# Check dynamic credentials
bao read database/creds/numeriqo_runtime
```

---

## Troubleshooting

### Container exits immediately

**Symptoms**: Container starts then exits with code 1

**Causes**:
1. AppRole credentials missing
2. OpenBao not accessible
3. Secrets not seeded

**Solution**:
```bash
# Check AppRole files exist
ls -la .secrets/approle/numeriqo/

# Verify OpenBao is running
docker ps | grep openbao

# Check OpenBao is accessible from container network
docker run --rm --network geniuserp_net_backing_services alpine \
  wget -O- http://openbao:8200/v1/sys/health
```

### Secrets not injected

**Symptoms**: Application logs show "ERROR: Database credentials not injected!"

**Causes**:
1. Templates not rendering
2. Wrong AppRole permissions
3. Secrets not in OpenBao

**Solution**:
```bash
# Check if secret files were created
docker exec genius-suite-numeriqo-app ls -la /app/secrets/

# If empty, check Agent logs
docker logs genius-suite-numeriqo-app 2>&1 | grep -i error

# Verify policy allows reading secrets
export BAO_TOKEN=$(cat .secrets/approle/numeriqo/role-id)
bao token capabilities kv/data/apps/numeriqo
```

### Database connection fails

**Symptoms**: "ECONNREFUSED" or "authentication failed"

**Causes**:
1. Dynamic credentials not generated
2. PostgreSQL not accessible
3. Database doesn't exist

**Solution**:
```bash
# Check DB credentials were injected
docker exec genius-suite-numeriqo-app cat /app/secrets/db-creds.json

# Verify user exists in PostgreSQL
docker exec geniuserp-postgres psql -U suite_admin -d numeriqo_db -c "\du"

# Test connection manually
docker exec geniuserp-postgres psql \
  -U $(docker exec genius-suite-numeriqo-app jq -r '.username' /app/secrets/db-creds.json) \
  -d numeriqo_db -c "SELECT 1"
```

---

## FAQ

### Q: Do I need to restart the container when secrets change?

**A**: For **static secrets** (KV), yes - restart the container to re-render templates.

For **dynamic credentials** (database), the Agent can auto-renew leases, but you still need to restart to get new credentials in the application.

### Q: Can I use this pattern for local development?

**A**: Yes! It's actually recommended for production parity. However, for rapid iteration, you can still use local `.env` files.

### Q: How do I add a new secret?

1. Add secret to OpenBao:
   ```bash
   bao kv put kv/apps/numeriqo new_secret="value"
   ```

2. Update template (`openbao/templates/app-secrets.tpl`):
   ```hcl
   "new_secret": "{{ .Data.data.new_secret }}"
   ```

3. Rebuild and restart:
   ```bash
   docker compose -f numeriqo.app/compose/docker-compose.yml up --build
   ```

### Q: What if OpenBao is down?

**A**: Applications won't start without secrets. This is by design (fail-secure). For high availability, run OpenBao in HA mode with Raft storage.

### Q: Can I see what secrets an application has access to?

**A**: Yes, check the AppRole policy:

```bash
bao policy read numeriqo-read
```

### Q: How do I rotate AppRole credentials?

```bash
# Generate new secret-id
cd numeriqo.app
./scripts/setup-approle.sh

# Restart application
docker compose -f compose/docker-compose.yml restart
```

---

## Helper Commands

Add these to your shell profile for convenience:

```bash
# ~/.bashrc or ~/.zshrc

# Quick OpenBao login
alias bao-login='export BAO_TOKEN=$(jq -r ".root_token" .secrets/openbao-keys.json) BAO_ADDR=http://127.0.0.1:8200'

# View app secrets
alias bao-secrets='bao kv get kv/apps/$1'

# Generate DB credentials
alias bao-db='bao read database/creds/$1_runtime'

# Setup AppRole for app
alias bao-approle='cd $1 && ./scripts/setup-approle.sh && cd -'
```

Usage:
```bash
bao-login
bao-secrets numeriqo
bao-db numeriqo
bao-approle numeriqo.app
```

---

## Next Steps

1. **Read**: [Numeriqo README](../../numeriqo.app/README.md) for pilot implementation
2. **Practice**: Run Numeriqo locally with Process Supervisor
3. **Extend**: Apply pattern to your application (see F0.5.16)
4. **Share**: Help teammates adopt the new workflow

---

## References

- [OpenBao Agent Documentation](https://openbao.org/docs/agent/)
- [AppRole Auth Method](https://openbao.org/docs/auth/approle/)
- [Template Syntax](https://openbao.org/docs/agent/template/)
- [GeniusERP Crypto Standards](../security/F0.5-Crypto-Standards-OpenBao.md)
