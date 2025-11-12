# Environment Variables Implementation Guide

## Quick Start (5 minutes)

### For Developers Working on an Application

#### 1. Copy Template to Your App

```bash
# For archify
cp archify.app/.env.archify.example archify.app/.env.archify

# For cerniq
cp cerniq.app/.env.cerniq.example cerniq.app/.env.cerniq

# For GeniusSuite CP services
cp cp/.env.geniussuite.example cp/.env.geniussuite
```

#### 2. Create Local Overrides (Development Only)

```bash
# These are NOT committed to git
touch archify.app/.env.local
touch cerniq.app/.env.local
touch .env.local  # Root overrides
```

Add your local secrets to `.env.local`:

```env
# archify.app/.env.local
ARCHIFY_OCR_API_KEY=your_local_test_key
ARCHIFY_STORAGE_TYPE=local
DATABASE_URL=postgres://dev_user:dev_pass@localhost:5432/archify_dev
```

#### 3. Update Your App's main.ts

```typescript
// archify.app/src/main.ts

import { EnvLoader } from '@shared/config/env-loader';
import { validateArchifyEnv } from './config/env.schema';

// Load environment variables (should be first thing in main)
EnvLoader.loadEnv('archify', process.env.NODE_ENV as any, __dirname, {
  verbose: true  // Remove in production
});

// Validate configuration
const config = validateArchifyEnv();

// Now you can use config safely
const app = fastify({ logger: pino() });
app.listen({ port: config.PORT, host: '0.0.0.0' });
```

---

## Complete Implementation Steps

### Step 1: Add EnvLoader to Shared Library

**Status**: ✅ DONE - File created at `libs/shared/src/config/env-loader.ts`

This provides the hierarchical loading mechanism for all apps.

### Step 2: Create Env Schema for Each App

Already done for Archify. For other apps, follow the same pattern:

```typescript
// cerniq.app/src/config/env.schema.ts

import { z } from 'zod';

const sharedEnvSchema = z.object({
  NODE_ENV: z.enum(['development', 'production']).default('development'),
  DATABASE_URL: z.string(),
  // ... shared vars
});

const cerniqSpecificSchema = z.object({
  PORT: z.coerce.number().default(3101),
  CERNIQ_DW_TYPE: z.enum(['postgres', 'snowflake', 'bigquery']).default('postgres'),
  // ... cerniq-specific vars
});

export const cerniqEnvSchema = sharedEnvSchema.merge(cerniqSpecificSchema);
export type CerniqEnv = z.infer<typeof cerniqEnvSchema>;

export function validateCerniqEnv(env: NodeJS.ProcessEnv = process.env): CerniqEnv {
  const result = cerniqEnvSchema.safeParse(env);
  
  if (!result.success) {
    console.error('❌ Cerniq environment validation failed:');
    result.error.errors.forEach(err => {
      console.error(`   ${err.path.join('.')}: ${err.message}`);
    });
    process.exit(1);
  }
  
  console.log('✅ Cerniq configuration validated\n');
  return result.data;
}
```

### Step 3: Update Docker Compose Files

For development (`docker-compose.yml`):

```yaml
services:
  archify:
    build: ./archify.app
    ports:
      - "3100:3100"
    env_file:
      - .env                      # Root shared (lowest priority)
      - archify.app/.env.archify  # App-specific
      - archify.app/.env.local    # Local overrides (highest priority)
    environment:
      NODE_ENV: development
      SERVICE_NAME: archify
    depends_on:
      - postgres
      - redis

  cerniq:
    build: ./cerniq.app
    ports:
      - "3101:3101"
    env_file:
      - .env
      - cerniq.app/.env.cerniq
      - cerniq.app/.env.local
    environment:
      NODE_ENV: development
      SERVICE_NAME: cerniq
    depends_on:
      - postgres
      - redis
```

For production (`docker-compose.prod.yml`):

```yaml
services:
  archify:
    build: ./archify.app
    ports:
      - "3100:3100"
    env_file:
      - .env.production           # Root (lowest priority)
      - archify.app/.env.production # App-specific (highest priority)
    environment:
      NODE_ENV: production
      SERVICE_NAME: archify
    secrets:
      - db_password
      - jwt_secret
      - archify_ocr_key

secrets:
  db_password:
    external: true  # From Vault/AWS Secrets Manager
  jwt_secret:
    external: true
  archify_ocr_key:
    external: true
```

### Step 4: Update .gitignore

Ensure all local and production files are ignored:

```bash
# .gitignore

# Environment variables with secrets
.env.local
.env.production
.env.*.local
.env.*.production

# Allow committed template files
!.env.example
!**/.env.*.example

# Application-specific local configs
archify.app/.env.local
cerniq.app/.env.local
cp/.env.local
# ... etc for all apps
```

### Step 5: Set Up CI/CD Pipeline

GitHub Actions example:

```yaml
# .github/workflows/deploy-prod.yml

name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3

      - name: Create production env files from secrets
        run: |
          # Root production config
          cat > .env.production << 'EOF'
          NODE_ENV=production
          DATABASE_URL=${{ secrets.PROD_DATABASE_URL }}
          REDIS_URL=${{ secrets.PROD_REDIS_URL }}
          LOG_LEVEL=warn
          OTEL_EXPORTER_OTLP_ENDPOINT=${{ secrets.PROD_OTEL_ENDPOINT }}
          EOF

          # Archify production config
          mkdir -p archify.app
          cat > archify.app/.env.production << 'EOF'
          PORT=3100
          ARCHIFY_STORAGE_TYPE=${{ secrets.PROD_ARCHIFY_STORAGE_TYPE }}
          ARCHIFY_STORAGE_PATH=${{ secrets.PROD_ARCHIFY_STORAGE_PATH }}
          ARCHIFY_OCR_API_KEY=${{ secrets.PROD_ARCHIFY_OCR_KEY }}
          EOF

          # Cerniq production config
          mkdir -p cerniq.app
          cat > cerniq.app/.env.production << 'EOF'
          PORT=3101
          CERNIQ_DW_HOST=${{ secrets.PROD_CERNIQ_DW_HOST }}
          CERNIQ_DW_PASSWORD=${{ secrets.PROD_CERNIQ_DW_PASSWORD }}
          CERNIQ_REPORT_API_KEY=${{ secrets.PROD_CERNIQ_REPORT_KEY }}
          EOF

      - name: Build Docker images
        run: docker compose -f docker-compose.prod.yml build

      - name: Push to registry
        run: docker compose -f docker-compose.prod.yml push

      - name: Deploy to production
        run: |
          # Deploy logic (e.g., update K8s manifests, redeploy containers)
          docker compose -f docker-compose.prod.yml up -d
```

### Step 6: Document Required Secrets

Create a `SECRETS-REQUIRED.md` in each app:

```markdown
# Archify - Required Secrets

## Development (.env.local)

These are optional for local development. Use test/throw-away values:

- `ARCHIFY_OCR_API_KEY` - Google Vision API key (for testing OCR)
- `DATABASE_URL` - Local PostgreSQL URL

## Production (.env.production)

These MUST be set via CI/CD secrets manager:

- `DATABASE_URL` - Production PostgreSQL (from RDS)
- `REDIS_URL` - Production Redis (from ElastiCache)
- `ARCHIFY_STORAGE_TYPE` - Must be 's3' or 'azure-blob'
- `ARCHIFY_S3_BUCKET` - S3 bucket name (if using S3)
- `ARCHIFY_S3_ACCESS_KEY_ID` - AWS access key
- `ARCHIFY_S3_SECRET_ACCESS_KEY` - AWS secret key
- `ARCHIFY_OCR_API_KEY` - Google Vision production API key
- `OTEL_EXPORTER_OTLP_ENDPOINT` - Production OTEL collector

## Generating Secrets

```bash
# Generate strong secrets for development
openssl rand -base64 32  # For API keys

# Example
export ARCHIFY_OCR_API_KEY=$(openssl rand -base64 32)
```
```

---

## Testing Your Setup

### 1. Verify Loading Order

Add this to your app's startup:

```typescript
import { EnvLoader } from '@shared/config/env-loader';

// After loading env:
const files = EnvLoader.getLoadedFiles('archify');
console.log('Loaded env files:');
files.forEach(f => console.log(`  - ${f}`));

const vars = EnvLoader.getLoadedVars();
console.log(`Total variables loaded: ${Object.keys(vars).length}`);
```

### 2. Test Validation

```bash
# Should pass
NODE_ENV=development node archify.app/src/main.ts

# Should fail (missing required vars)
# Comment out some required env vars and test
NODE_ENV=development node archify.app/src/main.ts
```

### 3. Test Priority Order

Create different values in each file:

```bash
# .env
DEBUG=false

# archify.app/.env.archify
DEBUG=true

# archify.app/.env.local
DEBUG=false  # This should win
```

Then check:

```typescript
console.log('DEBUG:', process.env.DEBUG); // Should be 'false'
```

---

## Common Issues & Solutions

### Issue: "Cannot find module" - env-loader not exported

**Solution**: Make sure env-loader is exported from shared library:

```typescript
// libs/shared/src/index.ts
export { EnvLoader, setupEnv } from './config/env-loader';
export type { EnvLoaderOptions } from './config/env-loader';
```

### Issue: Docker not loading .env files

**Solution**: Check env_file paths are relative to docker-compose.yml location:

```yaml
# ❌ WRONG - looks for ../../../.env
services:
  archify:
    env_file: ../../.env

# ✅ CORRECT - looks for ./.env (from compose file location)
services:
  archify:
    env_file:
      - .env
```

### Issue: GitHub Actions secrets not working

**Solution**: Secret names must match GitHub Secrets exactly:

```yaml
# Create secret PROD_DATABASE_URL in GitHub Settings → Secrets
- run: echo "${{ secrets.PROD_DATABASE_URL }}"  # ✅ Works
- run: echo "${{ secrets.prod_database_url }}"  # ❌ Won't work (different case)
```

### Issue: Validation error but not sure which variable

**Solution**: Enable verbose logging:

```typescript
EnvLoader.loadEnv('archify', process.env.NODE_ENV as any, __dirname, {
  verbose: true  // Shows which files are loaded
});
```

---

## Migration Checklist

For each application (archify, cerniq, flowxify, i-wms, mercantiq, numeriqo, triggerra, vettify, geniuserp):

- [ ] Create `.env.{appname}.example` file
- [ ] Create `src/config/env.schema.ts` with Zod schema
- [ ] Update `src/main.ts` to call `EnvLoader.loadEnv()`
- [ ] Test locally with `.env.local`
- [ ] Update `docker-compose.yml` with `env_file` stack
- [ ] Add to `.gitignore`
- [ ] Create `SECRETS-REQUIRED.md`
- [ ] Update GitHub Actions workflow
- [ ] Test in CI/CD pipeline
- [ ] Document in team wiki

---

## Best Practices

### ✅ DO's

```typescript
// ✅ Load env as first thing in main
import { EnvLoader } from '@shared/config/env-loader';
EnvLoader.loadEnv('archify', process.env.NODE_ENV as any, __dirname);

// ✅ Validate schema immediately
const config = validateArchifyEnv();

// ✅ Use typed config throughout app
console.log(`Starting on port ${config.PORT}`); // config.PORT has type number

// ✅ Use EnvLoader helpers for safe access
const secret = EnvLoader.getRequired('API_KEY', 'archify');
const timeout = EnvLoader.getNumber('TIMEOUT', 5000);
const enabled = EnvLoader.getBoolean('FEATURE_ENABLED', false);

// ✅ Check feature flags early
if (isFeatureEnabled('OCR', config)) {
  setupOcrService(config);
}
```

### ❌ DON'Ts

```typescript
// ❌ Don't access process.env directly (no type safety)
const port = process.env.PORT; // type is string | undefined

// ❌ Don't hardcode defaults in code
const port = parseInt(process.env.PORT || '3100', 10);  // Should be in .env

// ❌ Don't load env multiple times
EnvLoader.loadEnv(...);
EnvLoader.loadEnv(...); // Don't repeat

// ❌ Don't commit .env files with real secrets
git add .env.production  // ❌ Wrong!

// ❌ Don't log sensitive values
console.log('JWT Secret:', config.JWT_SECRET);  // ❌ Wrong!
console.log('JWT Secret length:', config.JWT_SECRET.length);  // ✅ Better
```

---

## Support & Questions

For questions about environment configuration:

1. **Local development issues**: Check `.env.local` values and verify `docker-compose.yml` env_file order
2. **Production deployment**: Verify GitHub Secrets are set correctly in repository settings
3. **Validation errors**: Run with `verbose: true` to see which files are loaded
4. **Adding new env var**: Update `.env.*.example` files AND the Zod schema

---

## Next Steps

1. **Immediate** (This week):
   - Create `.env.example` files for root and all apps
   - Create env schemas for all 9 applications
   - Update Docker Compose files

2. **Short-term** (Next week):
   - Update each app's `main.ts` to use EnvLoader
   - Test locally with `.env.local`
   - Document in team wiki

3. **Long-term** (2-4 weeks):
   - Integrate with Vault/AWS Secrets Manager
   - Set up automated secret rotation
   - Implement audit logging for secret access

---

## References

- [Zod Documentation](https://zod.dev)
- [dotenv Documentation](https://github.com/motdotla/dotenv)
- [12-Factor App - Config](https://12factor.net/config)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
