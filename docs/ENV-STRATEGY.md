# Environment Variables Architecture Strategy

## Overview

Acest document defineşte strategia recomandată pentru gestionarea fişierelor `.env` în ecosistemul GeniusSuite, unde avem:

- **1 Control Plane (CP)** cu 7 servicii interdependente
- **9 Aplicaţii standalone** cu logică de business specifică
- **Infrastructură partajată** (observability, auth, licensing, etc.)

**Status**: ✅ **FULL FEASIBILITY** - Propunerea ta este 100% fezabilă şi chiar recomandată din perspective de security, maintainability, şi scalability.

---

## 1. Strategie General (Recomandată)

### Arhitectura Propusă

```
/var/www/GeniusSuite/
├── .env                          # ROOT: Configurări globale (opţional, pentru defaults)
├── .env.local                    # ROOT: Overrides locale (dev only, în .gitignore)
├── .env.production               # ROOT: Prod overrides (în .gitignore)
│
├── cp/                           # Control Plane Services
│   ├── .env.geniussuite          # ✅ RECOMMENDED: Shared CP variables
│   ├── suite-shell/
│   │   ├── .env.local
│   │   └── .env.production
│   ├── suite-admin/
│   │   ├── .env.local
│   │   └── .env.production
│   ├── suite-login/
│   │   ├── .env.local
│   │   └── .env.production
│   ├── identity/
│   ├── licensing/
│   ├── analytics-hub/
│   └── ai-hub/
│
├── archify.app/                  # Standalone Application 1
│   ├── .env.archify              # ✅ RECOMMENDED: Archify-specific variables
│   ├── .env.local
│   └── .env.production
│
├── cerniq.app/                   # Standalone Application 2
│   ├── .env.cerniq               # ✅ RECOMMENDED: Cerniq-specific variables
│   ├── .env.local
│   └── .env.production
│
├── flowxify.app/                 # Standalone Application 3
│   ├── .env.flowxify             # ✅ RECOMMENDED: Flowxify-specific variables
│   ├── .env.local
│   └── .env.production
│
├── i-wms.app/
│   ├── .env.iwms
│   ├── .env.local
│   └── .env.production
│
├── mercantiq.app/
│   ├── .env.mercantiq
│   ├── .env.local
│   └── .env.production
│
├── numeriqo.app/
│   ├── .env.numeriqo
│   ├── .env.local
│   └── .env.production
│
├── triggerra.app/
│   ├── .env.triggerra
│   ├── .env.local
│   └── .env.production
│
├── vettify.app/
│   ├── .env.vettify
│   ├── .env.local
│   └── .env.production
│
└── geniuserp.app/
    ├── .env.geniuserp
    ├── .env.local
    └── .env.production
```

### Why This Structure Works

**✅ Pros:**
- **Segregation of concerns**: Fiecare aplicaţie/serviciu are propriul set de secrets
- **Security**: Nicio companie nu accesează accidental secretele altei aplicaţii
- **Scalability**: Adăugarea de noi aplicaţii nu afectează existentele
- **Audit trail**: Se poate vedea exact cine/ce a accesat ce secret
- **Parallelization**: Teamurile pot lucra independent pe aplicaţii fără merge conflicts
- **Local development**: Dev-ul pe archify nu trebuie să ştie secretele cerniq

**✅ Cons mitigated:**
- ❌ "Prea mulţi .env files" → Automatable cu script loader
- ❌ "Complex" → Standardizat prin pattern unic pentru fiecare

---

## 2. Implementation Pattern

### 2.1 Hierarchical Loading (Recommended)

Create a central configuration loader at root level:

```typescript
// /var/www/GeniusSuite/src/config/env-loader.ts

import { z } from 'zod';
import * as fs from 'fs';
import * as path from 'path';
import dotenv from 'dotenv';

/**
 * Hierarchical environment loader:
 * 1. .env (base defaults - shared across all services)
 * 2. .env.{APP_NAME} (application-specific in root or app dir)
 * 3. .env.{environment} (environment overrides - local/production)
 * 4. process.env (runtime environment variables - highest priority)
 */
export class EnvLoader {
  private static loadedVars: Map<string, string> = new Map();

  static loadEnv(
    appName: string,
    environment: 'development' | 'production' = 'development',
    appDir?: string
  ): void {
    // Priority order (lowest to highest):
    const filesToLoad = [
      // 1. Root base
      path.join(process.cwd(), '.env'),
      
      // 2. App-specific in root (for monorepo)
      path.join(process.cwd(), `.env.${appName}`),
      
      // 3. App-specific in app directory (if provided)
      appDir ? path.join(appDir, `.env.${appName}`) : null,
      
      // 4. Local overrides (highest priority, not committed)
      path.join(process.cwd(), '.env.local'),
      appDir ? path.join(appDir, '.env.local') : null,
      
      // 5. Environment-specific
      path.join(process.cwd(), `.env.${environment}`),
      appDir ? path.join(appDir, `.env.${environment}`) : null,
    ].filter(Boolean) as string[];

    for (const filePath of filesToLoad) {
      if (fs.existsSync(filePath)) {
        console.log(`📖 Loading: ${filePath}`);
        const envConfig = dotenv.parse(fs.readFileSync(filePath));
        
        // Merge, with later files overriding earlier ones
        Object.entries(envConfig).forEach(([key, value]) => {
          if (!process.env[key]) {
            process.env[key] = value;
          }
          this.loadedVars.set(key, value);
        });
      }
    }
  }

  static getLoadedVars(): Record<string, string> {
    return Object.fromEntries(this.loadedVars);
  }
}

// Usage in each service main.ts:
// EnvLoader.loadEnv('archify', process.env.NODE_ENV as any, __dirname);
// EnvLoader.loadEnv('geniussuite', process.env.NODE_ENV as any); // For CP services
```

### 2.2 Schema Validation per Application

Fiecare aplicaţie trebuie să aibă schema de validare proprie:

```typescript
// /var/www/GeniusSuite/archify.app/src/config/env.schema.ts

import { z } from 'zod';

export const archifyEnvSchema = z.object({
  // ===== APPLICATION ===== 
  NODE_ENV: z.enum(['development', 'production']).default('development'),
  PORT: z.coerce.number().default(3100),
  
  // ===== ARCHIFY-SPECIFIC =====
  // Document Management
  ARCHIFY_MAX_FILE_SIZE: z.coerce.number().default(1024 * 1024 * 100), // 100MB
  ARCHIFY_STORAGE_TYPE: z.enum(['local', 's3', 'azure']).default('local'),
  ARCHIFY_STORAGE_PATH: z.string().default('./data/archify/documents'),
  
  // OCR & Document Processing
  ARCHIFY_OCR_ENABLED: z.boolean().default(false),
  ARCHIFY_OCR_PROVIDER: z.enum(['google-vision', 'aws-textract', 'azure-cv']).optional(),
  ARCHIFY_OCR_API_KEY: z.string().optional(),
  
  // ===== SHARED WITH OTHER APPS (via inheritance/composition) =====
  DATABASE_URL: z.string(),
  REDIS_URL: z.string().optional(),
  
  // ===== OPENTELEMETRY ===== 
  OTEL_EXPORTER_OTLP_ENDPOINT: z.string().default('http://otel-collector:4318'),
  OTEL_SERVICE_NAME: z.string().default('archify'),
  
  // ===== CP INTEGRATION =====
  SUITE_SHELL_URL: z.string().optional(), // To communicate with MF host
  SUITE_LOGIN_URL: z.string().optional(), // For SSO
  JWT_PUBLIC_KEY: z.string().optional(), // For JWT validation from suite-login
});

export type ArchifyEnv = z.infer<typeof archifyEnvSchema>;

export function validateArchifyEnv(): ArchifyEnv {
  const result = archifyEnvSchema.safeParse(process.env);
  
  if (!result.success) {
    console.error('❌ Archify environment validation failed:');
    result.error.errors.forEach(err => {
      console.error(`   ${err.path.join('.')}: ${err.message}`);
    });
    process.exit(1);
  }
  
  return result.data;
}
```

---

## 3. Recommended `.env` Files Content

### 3.1 Root `.env` (Shared Defaults)

```env
# ============================================
# GENIUSSUITE ROOT CONFIGURATION
# ============================================
# Shared across all applications in the suite
# LOCAL OVERRIDES: .env.local (gitignored)
# PRODUCTION: .env.production (gitignored)

# ===== NODE ENVIRONMENT =====
NODE_ENV=development

# ===== DATABASE (Shared PostgreSQL) =====
DATABASE_URL=postgres://geniussuite:password@localhost:5432/geniussuite_db
DB_POOL_SIZE=20

# ===== REDIS (Shared Cache Layer) =====
REDIS_URL=redis://localhost:6379/0
REDIS_PASSWORD=

# ===== OPENTELEMETRY (Observability) =====
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
OTEL_ENABLED=true

# ===== LOGGING =====
LOG_LEVEL=debug
LOG_FORMAT=json

# ===== COMMON SECURITY (Shared signing keys - different from app-specific secrets) =====
# IMPORTANT: These are NOT application secrets, only for inter-service communication
JWT_PUBLIC_KEY=<multiline-key-or-path>
SESSION_ENCRYPTION_KEY=<for-session-storage>

# ===== CORS & NETWORKING =====
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:3001,http://localhost:3100
API_GATEWAY_URL=http://localhost:3001
```

### 3.2 `/var/www/GeniusSuite/.env.geniussuite` (CP Services Shared)

```env
# ============================================
# GENIUSSUITE CONTROL PLANE - SHARED CONFIG
# ============================================
# For suite-shell, suite-admin, suite-login, identity, licensing, analytics-hub, ai-hub

# ===== MF ORCHESTRATION (suite-shell) =====
MF_REMOTE_ENTRY_HOST=http://localhost:3001
MF_REMOTE_ENTRY_PORT=3001
MF_MODULES_REGISTRY_URL=http://localhost:3001/modules-registry

# ===== AUTHENTICATION (suite-login / identity) =====
# These are references to the auth services, NOT the actual secrets
AUTH_SERVICE_URL=http://localhost:3003
AUTH_JWKS_URL=http://localhost:3003/.well-known/jwks.json
SUPERTOKENS_CONNECTION_URI=postgres://supertokens:password@localhost:5432/supertokens

# ===== LICENSING (licensing service) =====
LICENSING_SERVICE_URL=http://localhost:3005
LICENSE_CHECK_INTERVAL=3600000 # 1 hour in ms

# ===== ANALYTICS HUB (analytics-hub service) =====
ANALYTICS_SERVICE_URL=http://localhost:3006
TELEMETRY_ENABLED=true

# ===== AI HUB (ai-hub service) =====
AI_SERVICE_URL=http://localhost:3007
INFERENCE_TIMEOUT=30000 # 30 seconds

# ===== INTER-SERVICE COMMUNICATION =====
SERVICE_MESH_ENABLED=true
INTERNAL_API_SECRET=<generated-secret-for-service-to-service>
```

### 3.3 `/var/www/GeniusSuite/archify.app/.env.archify`

```env
# ============================================
# ARCHIFY - DOCUMENT MANAGEMENT SYSTEM
# ============================================

# ===== APPLICATION =====
PORT=3100
SERVICE_NAME=archify

# ===== DOCUMENT STORAGE =====
ARCHIFY_MAX_FILE_SIZE=104857600 # 100MB
ARCHIFY_STORAGE_TYPE=local
ARCHIFY_STORAGE_PATH=/data/archify/documents
ARCHIFY_TEMP_PATH=/tmp/archify

# ===== OCR CONFIGURATION =====
ARCHIFY_OCR_ENABLED=false
# When enabled, uncomment one of the providers:
# ARCHIFY_OCR_PROVIDER=google-vision
# ARCHIFY_OCR_API_KEY=<your-api-key>

# ===== FULL-TEXT SEARCH =====
ARCHIFY_SEARCH_ENABLED=true
ARCHIFY_ELASTICSEARCH_URL=http://localhost:9200

# ===== DOCUMENT VERSIONING =====
ARCHIFY_VERSIONING_ENABLED=true
ARCHIFY_MAX_VERSIONS_PER_DOC=10

# ===== PERMISSIONS & SHARING =====
ARCHIFY_SHARE_EXPIRY_DAYS=30
ARCHIFY_ENABLE_PUBLIC_SHARES=false

# ===== INTEGRATIONS =====
# If integrating with other apps in the suite
ARCHIFY_ENABLE_SUITE_INTEGRATION=true
SUITE_SHELL_URL=http://localhost:3001
```

### 3.4 `/var/www/GeniusSuite/cerniq.app/.env.cerniq`

```env
# ============================================
# CERNIQ - BUSINESS INTELLIGENCE & DATA MESH
# ============================================

# ===== APPLICATION =====
PORT=3101
SERVICE_NAME=cerniq

# ===== DATA WAREHOUSE =====
CERNIQ_DW_TYPE=postgres # or snowflake, bigquery, redshift
CERNIQ_DW_HOST=localhost
CERNIQ_DW_PORT=5432
CERNIQ_DW_USER=cerniq_user
CERNIQ_DW_PASSWORD=<encrypted-secret>
CERNIQ_DW_DATABASE=cerniq_warehouse

# ===== DATA MESH =====
CERNIQ_MESH_ENABLED=true
CERNIQ_MESH_REGISTRY_URL=http://localhost:8080/api

# ===== DATA PRODUCTS =====
CERNIQ_DATA_PRODUCT_SCHEMA_REGISTRY=http://localhost:8081

# ===== ANALYTICS & REPORTING =====
CERNIQ_REPORT_ENGINE=jaspersoft # or powerbi, tableau, looker
CERNIQ_REPORT_API_KEY=<api-key>

# ===== DATA GOVERNANCE =====
CERNIQ_LINEAGE_ENABLED=true
CERNIQ_QUALITY_CHECKS_ENABLED=true

# ===== INTEGRATIONS =====
CERNIQ_ENABLE_SUITE_INTEGRATION=true
SUITE_SHELL_URL=http://localhost:3001
```

### 3.5 `.env.local` Example (Development Only, Gitignored)

```env
# ============================================
# LOCAL DEVELOPMENT OVERRIDES
# ============================================
# This file is NOT committed to git
# Use it for local-only configurations

NODE_ENV=development
LOG_LEVEL=debug

# Override any production values for local testing:
DATABASE_URL=postgres://dev_user:dev_password@localhost:5432/geniussuite_dev
REDIS_URL=redis://localhost:6379/1 # Different DB for local

# Local service URLs
SUITE_SHELL_URL=http://localhost:3001
SUITE_LOGIN_URL=http://localhost:3003
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318

# Secrets for local development (these must NEVER be in git)
# Use throw-away values or get from local secure store:
JWT_SECRET=local_dev_secret_change_me
ARCHIFY_OCR_API_KEY=local_test_key
```

### 3.6 `.env.production` Example (Gitignored, CI/CD)

```env
# ============================================
# PRODUCTION CONFIGURATION
# ============================================
# This file is NOT committed to git
# Deployed via CI/CD pipeline or secret management system (Vault, AWS Secrets Manager, etc.)

NODE_ENV=production
LOG_LEVEL=warn
LOG_FORMAT=json

# Database (production RDS/managed service)
DATABASE_URL=postgres://prod_user:${PROD_DB_PASSWORD}@prod-rds.amazonaws.com:5432/geniussuite_prod
DB_POOL_SIZE=50

# Redis (production cluster)
REDIS_URL=redis-cluster.amazonaws.com:6379?password=${PROD_REDIS_PASSWORD}&cluster=true

# OpenTelemetry (production Grafana stack)
OTEL_EXPORTER_OTLP_ENDPOINT=https://otel-collector.monitoring.prod:4318
OTEL_ENABLED=true

# Production secrets (fetched from CI/CD secrets manager)
JWT_SECRET=${PROD_JWT_SECRET}
SESSION_ENCRYPTION_KEY=${PROD_SESSION_KEY}
```

---

## 4. Docker Compose Integration

### 4.1 For Development (docker-compose.yml)

```yaml
version: '3.9'

services:
  # ===== INFRASTRUCTURE =====
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: geniussuite
      POSTGRES_PASSWORD: local_dev_pass # Override in .env
      POSTGRES_DB: geniussuite_db
    env_file:
      - .env
      - .env.local

  redis:
    image: redis:7-alpine
    env_file:
      - .env
      - .env.local

  # ===== CONTROL PLANE =====
  suite-shell:
    build: ./cp/suite-shell
    ports:
      - "3001:3000"
    env_file:
      - .env
      - .env.geniussuite
      - .env.local
    environment:
      SERVICE_NAME: suite-shell
      OTEL_SERVICE_NAME: suite-shell

  suite-login:
    build: ./cp/suite-login
    ports:
      - "3003:3000"
    env_file:
      - .env
      - .env.geniussuite
      - .env.local
    environment:
      SERVICE_NAME: suite-login
      OTEL_SERVICE_NAME: suite-login

  # ===== APPLICATIONS =====
  archify:
    build: ./archify.app
    ports:
      - "3100:3100"
    env_file:
      - .env
      - archify.app/.env.archify
      - archify.app/.env.local
    environment:
      SERVICE_NAME: archify
      OTEL_SERVICE_NAME: archify

  cerniq:
    build: ./cerniq.app
    ports:
      - "3101:3101"
    env_file:
      - .env
      - cerniq.app/.env.cerniq
      - cerniq.app/.env.local
    environment:
      SERVICE_NAME: cerniq
      OTEL_SERVICE_NAME: cerniq
```

**Key point**: `env_file` stacks from bottom (lowest priority) to top (highest priority).

### 4.2 For Production (docker-compose.prod.yml)

```yaml
version: '3.9'

services:
  archify:
    build: ./archify.app
    ports:
      - "3100:3100"
    env_file:
      - .env.production
      - archify.app/.env.production
    environment:
      SERVICE_NAME: archify
      NODE_ENV: production
    secrets:
      - jwt_secret
      - db_password
      - archify_ocr_key
      
  cerniq:
    build: ./cerniq.app
    ports:
      - "3101:3101"
    env_file:
      - .env.production
      - cerniq.app/.env.production
    environment:
      SERVICE_NAME: cerniq
      NODE_ENV: production
    secrets:
      - jwt_secret
      - db_password
      - cerniq_api_key

secrets:
  jwt_secret:
    external: true  # Managed by Vault/AWS Secrets Manager
  db_password:
    external: true
  archify_ocr_key:
    external: true
  cerniq_api_key:
    external: true
```

---

## 5. CI/CD Integration (GitHub Actions Example)

```yaml
# .github/workflows/deploy.yml

name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      # Load secrets from GitHub Secrets into .env files
      - name: Create production .env files
        run: |
          # Root .env.production
          cat > .env.production << EOF
          NODE_ENV=production
          DATABASE_URL=${{ secrets.PROD_DATABASE_URL }}
          REDIS_URL=${{ secrets.PROD_REDIS_URL }}
          JWT_SECRET=${{ secrets.PROD_JWT_SECRET }}
          EOF

          # GeniusSuite CP .env
          cat > cp/.env.geniussuite << EOF
          AUTH_SERVICE_URL=${{ secrets.PROD_AUTH_SERVICE_URL }}
          SUPERTOKENS_CONNECTION_URI=${{ secrets.PROD_SUPERTOKENS_URI }}
          EOF

          # Archify .env
          cat > archify.app/.env.archify << EOF
          ARCHIFY_STORAGE_TYPE=${{ secrets.PROD_ARCHIFY_STORAGE_TYPE }}
          ARCHIFY_STORAGE_PATH=${{ secrets.PROD_ARCHIFY_STORAGE_PATH }}
          ARCHIFY_OCR_API_KEY=${{ secrets.PROD_ARCHIFY_OCR_KEY }}
          EOF

          # Cerniq .env
          cat > cerniq.app/.env.cerniq << EOF
          CERNIQ_DW_PASSWORD=${{ secrets.PROD_CERNIQ_DW_PASSWORD }}
          CERNIQ_REPORT_API_KEY=${{ secrets.PROD_CERNIQ_REPORT_KEY }}
          EOF

      - name: Build and push Docker images
        run: docker compose -f docker-compose.prod.yml build --push

      - name: Deploy to production
        run: docker compose -f docker-compose.prod.yml up -d
```

---

## 6. Security Best Practices

### ✅ DO's

```bash
✅ DO use .env.local for development secrets (gitignored)
✅ DO use CI/CD secrets manager for production
✅ DO rotate secrets regularly (quarterly minimum)
✅ DO encrypt secrets at rest (Vault, AWS Secrets Manager, etc.)
✅ DO audit secret access logs
✅ DO use different secrets per environment
✅ DO namespace secrets by application (ARCHIFY_*, CERNIQ_*, etc.)
✅ DO use type-safe schema validation (Zod)
✅ DO document ALL required env vars in .env.example files
```

### ❌ DON'Ts

```bash
❌ DON'T commit ANY .env file with real secrets
❌ DON'T use the same secret across environments
❌ DON'T hardcode secrets in code
❌ DON'T pass secrets in URL query parameters
❌ DON'T log secret values (even truncated)
❌ DON'T share .env.local via slack/email
❌ DON'T use weak secrets (use openssl rand -base64 32)
```

### 6.1 Secret Generation Commands

```bash
# Generate strong secrets
openssl rand -base64 32  # JWT_SECRET
openssl rand -base64 32  # SESSION_SECRET
openssl rand -base64 32  # API_KEYS

# Example:
export JWT_SECRET=$(openssl rand -base64 32)
export SESSION_SECRET=$(openssl rand -base64 32)
export DB_PASSWORD=$(openssl rand -base64 32)
```

---

## 7. Migration Path (How to Implement)

### Phase 1: Foundation (Week 1)
- [ ] Create `.env.example` files for each app
- [ ] Create env schema files (Zod validation)
- [ ] Create `EnvLoader` utility
- [ ] Update root `.env` with shared defaults

### Phase 2: Application Configuration (Week 2)
- [ ] Create `.env.{appname}` files for each app
- [ ] Update `docker-compose.yml` to load multiple env files
- [ ] Update each app's `main.ts` to use `EnvLoader`
- [ ] Test local development setup

### Phase 3: CI/CD Integration (Week 3)
- [ ] Update GitHub Actions workflow
- [ ] Configure secrets in GitHub Settings → Secrets
- [ ] Create `.env.production` example (without values)
- [ ] Test prod deployment pipeline

### Phase 4: Documentation & Training (Week 4)
- [ ] Document per-application env vars
- [ ] Create onboarding guide for new devs
- [ ] Document secret rotation procedure
- [ ] Set up audit logging for secret access

---

## 8. Example File Structure After Implementation

```
/var/www/GeniusSuite/
├── .env.example                    # Template for root defaults
├── .env                            # Root shared (committed)
├── .env.local                      # Local overrides (gitignored)
├── .env.production                 # Prod overrides (gitignored, for reference)
│
├── cp/
│   ├── .env.geniussuite.example
│   ├── .env.geniussuite            # CP services shared (committed)
│   ├── suite-shell/
│   │   ├── .env.example
│   │   ├── .env.local
│   │   └── .env.production
│   ├── suite-admin/
│   ├── suite-login/
│   ├── identity/
│   ├── licensing/
│   ├── analytics-hub/
│   └── ai-hub/
│
├── archify.app/
│   ├── .env.archify.example
│   ├── .env.archify                # App-specific defaults (committed)
│   ├── .env.local                  # Local overrides (gitignored)
│   └── .env.production             # Prod overrides (gitignored)
│
├── cerniq.app/
│   ├── .env.cerniq.example
│   ├── .env.cerniq
│   ├── .env.local
│   └── .env.production
│
├── flowxify.app/
│   ├── .env.flowxify.example
│   ├── .env.flowxify
│   ├── .env.local
│   └── .env.production
│
├── i-wms.app/
│   ├── .env.iwms.example
│   ├── .env.iwms
│   ├── .env.local
│   └── .env.production
│
├── mercantiq.app/
│   ├── .env.mercantiq.example
│   ├── .env.mercantiq
│   ├── .env.local
│   └── .env.production
│
├── numeriqo.app/
│   ├── .env.numeriqo.example
│   ├── .env.numeriqo
│   ├── .env.local
│   └── .env.production
│
├── triggerra.app/
│   ├── .env.triggerra.example
│   ├── .env.triggerra
│   ├── .env.local
│   └── .env.production
│
├── vettify.app/
│   ├── .env.vettify.example
│   ├── .env.vettify
│   ├── .env.local
│   └── .env.production
│
└── geniuserp.app/
    ├── .env.geniuserp.example
    ├── .env.geniuserp
    ├── .env.local
    └── .env.production
```

---

## 9. Comparison: Your Approach vs Current State

### Current State (GeniusERP)
- ❌ Single `.env` at root for entire ERP
- ❌ No application-level separation
- ❌ Hard to share ERP env with Suite apps
- ❌ Dev working on invoice module loads secrets for everything
- ⚠ Requires discipline to not expose unrelated secrets

### Your Proposed Approach (GeniusSuite)
- ✅ `.env.geniussuite` for CP services only
- ✅ `.env.{appname}` for each application
- ✅ `.env` at root for infrastructure only
- ✅ Dev on archify never sees cerniq secrets
- ✅ Easy to onboard new apps (just add `.env.{appname}`)
- ✅ Audit trail per application

**Result**: Your approach is not only feasible, it's **the recommended pattern** for multi-tenant microservices architectures!

---

## 10. Tools & Utilities

### Tool: Validate All .env Files

```bash
# scripts/validate-all-envs.sh
#!/bin/bash

echo "🔍 Validating all .env files..."

check_env() {
  local app=$1
  local env_file=$2
  
  if [ ! -f "$env_file" ]; then
    echo "❌ Missing: $env_file"
    return 1
  fi
  
  echo "✅ Found: $env_file"
  return 0
}

check_env "root" ".env"
check_env "geniussuite" "cp/.env.geniussuite"
check_env "archify" "archify.app/.env.archify"
check_env "cerniq" "cerniq.app/.env.cerniq"
# ... etc

echo "✅ All required .env files validated!"
```

### Tool: Generate Secret Placeholders

```bash
# scripts/generate-env-templates.sh
#!/bin/bash

for app in archify cerniq flowxify i-wms mercantiq numeriqo triggerra vettify geniuserp; do
  cat > "${app}.app/.env.${app}.example" << EOF
# ===== ${app} APPLICATION CONFIGURATION =====
PORT=31XX
SERVICE_NAME=${app}

# ===== SECRETS (Replace with actual values) =====
# Use: openssl rand -base64 32

# ===== INTEGRATIONS =====
SUITE_SHELL_URL=http://localhost:3001
EOF
done
```

---

## Conclusion

✅ **Your proposal is 100% feasible and highly recommended.**

The `.env.geniussuite` + `.env.{appname}` pattern provides:
- **Security**: Secrets isolated per application
- **Scalability**: Easy to add new apps
- **Maintainability**: Clear separation of concerns
- **Auditability**: Track which secrets are used where
- **Developer Experience**: Dev works only on their app's secrets

**Next Steps**:
1. Create `.env.example` files as templates
2. Implement `EnvLoader` utility for hierarchical loading
3. Add Zod schema validation per app
4. Update Docker Compose files
5. Update CI/CD workflows
6. Document in team wiki

Would you like me to create the actual implementation files?
