# Numeriqo Application - Process Supervisor Pilot

> **Status**: ✅ Process Supervisor Pattern Enabled  
> **OpenBao Integration**: Active  
> **Secrets Management**: Dynamic credentials from OpenBao

## Overview

Numeriqo is the **pilot application** for the Process Supervisor pattern, demonstrating how applications can run without local `.env` files by using OpenBao Agent for automatic secret injection.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│  Container: genius-suite-numeriqo-app                   │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │ OpenBao Agent (Process Supervisor)                 │ │
│  │  - Auto-auth with AppRole                          │ │
│  │  - Template rendering                              │ │
│  │  - Secret injection                                │ │
│  └────────────────────────────────────────────────────┘ │
│                        │                                 │
│                        ▼                                 │
│  ┌────────────────────────────────────────────────────┐ │
│  │ Rendered Secrets                                   │ │
│  │  /app/secrets/.env                                 │ │
│  │  /app/secrets/db-creds.json                        │ │
│  │  /app/secrets/app-secrets.json                     │ │
│  └────────────────────────────────────────────────────┘ │
│                        │                                 │
│                        ▼                                 │
│  ┌────────────────────────────────────────────────────┐ │
│  │ Node.js Application                                │ │
│  │  Started by: /app/scripts/start-app.sh            │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

## Prerequisites

1. **OpenBao running and initialized**:
   ```bash
   docker compose up openbao -d
   ./scripts/security/openbao-init.sh
   ```

2. **Database secrets engine configured**:
   ```bash
   export BAO_TOKEN=$(jq -r '.root_token' .secrets/openbao-keys.json)
   export BAO_ADDR=http://127.0.0.1:8200
   ./scripts/security/openbao-enable-db-engine.sh
   ```

3. **Application secrets seeded**:
   ```bash
   ./scripts/security/seed-secrets.sh --profile dev --non-interactive
   ```

4. **AppRole credentials generated**:
   ```bash
   cd numeriqo.app
   ./scripts/setup-approle.sh
   ```

## Running Numeriqo

### Development Mode

```bash
# From repository root
docker compose -f numeriqo.app/compose/docker-compose.yml up --build
```

### Production Mode

```bash
# Build image
docker compose -f numeriqo.app/compose/docker-compose.yml build

# Run
docker compose -f numeriqo.app/compose/docker-compose.yml up -d

# View logs
docker logs -f genius-suite-numeriqo-app
```

## Secret Injection Flow

1. **Container starts** → OpenBao Agent begins
2. **Auto-auth** → Agent authenticates using AppRole (role-id + secret-id)
3. **Template rendering** → Agent fetches secrets and renders templates:
   - `database/creds/numeriqo_runtime` → Dynamic DB credentials
   - `kv/data/apps/numeriqo` → Static application secrets
4. **Exec command** → After all templates rendered, Agent executes `/app/scripts/start-app.sh`
5. **Application starts** → Node.js app loads with injected secrets

## Secrets Structure

### Dynamic Database Credentials

```json
{
  "username": "v-root-numeriqo-XXXXXXXXXX",
  "password": "XXXXXXXXXXXXXXXXXXXXXXXX",
  "lease_id": "database/creds/numeriqo_runtime/XXXXX",
  "lease_duration": 3600,
  "renewable": true
}
```

### Static Application Secrets

```json
{
  "jwt_secret": "XXXXXXXXXXXXXXXXXXXXXXXX",
  "api_key": "XXXXXXXXXXXXXXXXXXXXXXXX",
  "encryption_key": "XXXXXXXXXXXXXXXXXXXXXXXX"
}
```

### Combined .env File

```bash
# Database (dynamic)
NUMQ_DB_USER=v-root-numeriqo-XXXXXXXXXX
NUMQ_DB_PASS=XXXXXXXXXXXXXXXXXXXXXXXX
NUMQ_DB_HOST=postgres
NUMQ_DB_PORT=5432
NUMQ_DB_NAME=numeriqo_db

# Application secrets (static)
NUMQ_JWT_SECRET=XXXXXXXXXXXXXXXXXXXXXXXX
NUMQ_API_KEY=XXXXXXXXXXXXXXXXXXXXXXXX
NUMQ_ENCRYPTION_KEY=XXXXXXXXXXXXXXXXXXXXXXXX

# Non-secret config
NUMQ_APP_PORT=6750
NODE_ENV=production
```

## Troubleshooting

### Container exits immediately

Check OpenBao Agent logs:
```bash
docker logs genius-suite-numeriqo-app
```

Common issues:
- AppRole credentials missing or invalid
- OpenBao not accessible from container
- Secrets not seeded in OpenBao

### Secrets not injected

Verify templates are rendering:
```bash
docker exec genius-suite-numeriqo-app ls -la /app/secrets/
```

Should show:
- `.env`
- `db-creds.json`
- `app-secrets.json`

### Database connection fails

Check dynamic credentials:
```bash
docker exec genius-suite-numeriqo-app cat /app/secrets/db-creds.json
```

Verify user exists in PostgreSQL:
```bash
docker exec geniuserp-postgres psql -U suite_admin -d numeriqo_db -c "\du"
```

## Files Structure

```
numeriqo.app/
├── Dockerfile                    # Multi-stage build with OpenBao Agent
├── compose/
│   └── docker-compose.yml        # Service definition with volumes
├── openbao/
│   ├── agent-config.hcl          # OpenBao Agent configuration
│   └── templates/
│       ├── db-creds.tpl          # Dynamic DB credentials template
│       ├── app-secrets.tpl       # Static secrets template
│       └── numeriqo.env.tpl      # Combined .env template
├── scripts/
│   ├── setup-approle.sh          # Generate AppRole credentials
│   └── start-app.sh              # Process Supervisor entrypoint
└── README.md                     # This file
```

## Next Steps

After successful Numeriqo pilot:

1. **F0.5.15**: Developer Experience & Training documentation
2. **F0.5.16**: Rollout to remaining applications (Archify, Cerniq, etc.)
3. **F0.5.17**: CI/CD integration for automated secret injection

## References

- [OpenBao Agent Documentation](https://openbao.org/docs/agent/)
- [Process Supervisor Pattern](../../docs/security/Process-Supervisor-Pattern.md)
- [GeniusERP Crypto Standards](../../docs/security/F0.5-Crypto-Standards-OpenBao.md)
