# How to Add a New App/Module to Observability

**Audience:** Developers adding new applications or modules to GeniusSuite  
**Prerequisites:** Basic understanding of OpenTelemetry, Docker Compose, and TypeScript/Node.js  
**Last Updated:** 2024-11-13  
**Version:** 1.0.0

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Step 1: Code Integration](#step-1-code-integration)
4. [Step 2: Docker Compose Configuration](#step-2-docker-compose-configuration)
5. [Step 3: Prometheus Scrape Configuration](#step-3-prometheus-scrape-configuration)
6. [Step 4: Network Configuration](#step-4-network-configuration)
7. [Step 5: Validation](#step-5-validation)
8. [Step 6: Testing](#step-6-testing)
9. [Naming Conventions](#naming-conventions)
10. [Complete Example](#complete-example)
11. [Troubleshooting](#troubleshooting)
12. [Checklist](#checklist)

---

## Overview

This guide provides step-by-step instructions for integrating a new application or module into GeniusSuite's observability stack. By following this guide, your application will automatically:

- ✅ Send **traces** to OTEL Collector
- ✅ Expose **metrics** for Prometheus scraping
- ✅ Emit **structured JSON logs** for Loki aggregation
- ✅ Appear in Grafana dashboards and queries

**Integration Time:** ~30-45 minutes for a standard application

---

## Prerequisites

### Required Knowledge
- Basic TypeScript/Node.js
- Docker & Docker Compose fundamentals
- Understanding of REST APIs and environment variables

### Required Tools
- Docker Desktop or Docker Engine
- Node.js 24+ with pnpm
- Text editor (VS Code recommended)
- Access to GeniusSuite repository

### Existing Infrastructure
Before starting, ensure the observability stack is running:

```bash
cd /var/www/GeniusSuite/shared/observability
bash scripts/install.sh dev
bash scripts/validate.sh  # Should show 38/38 checks passing
```

---

## Step 1: Code Integration

### 1.1 Install Observability Package

Add the shared observability library to your application:

```bash
cd /var/www/GeniusSuite/your-app.app
pnpm add @genius-suite/observability
```

**Note:** If the package doesn't exist yet, you'll need to build it first:

```bash
cd /var/www/GeniusSuite/shared/observability
pnpm install
pnpm build
```

### 1.2 Initialize Tracing & Metrics

In your application's entry point (typically `src/index.ts`), initialize observability **before** any other imports:

```typescript
import fastify from 'fastify';
import type { FastifyRequest, FastifyReply } from 'fastify';
import { initTracing, initMetrics, metricsHandler } from '@genius-suite/observability';
import { logger } from '@genius-suite/common';

async function main() {
  // 1. Get service name from environment (convention: <app-name>.app)
  const serviceName = process.env.OTEL_SERVICE_NAME || 'your-app.app';
  const port = parseInt(process.env.PORT || '3000', 10);

  // 2. Initialize OpenTelemetry tracing
  // Automatically reads OTEL_EXPORTER_OTLP_ENDPOINT from environment
  await initTracing({ serviceName });

  // 3. Initialize Prometheus metrics
  await initMetrics({ serviceName });

  // 4. Create Fastify instance with structured JSON logging
  const app = fastify({
    logger: {
      level: 'info',
      formatters: {
        level: (label) => {
          return { level: label };
        },
      },
      timestamp: () => `,"time":"${new Date().toISOString()}"`,
    }
  });

  // ... rest of application code
}

main().catch((err) => {
  logger.error(err, 'Fatal error in your-app.app');
  process.exit(1);
});
```

### 1.3 Add Health Endpoint

**Required for Docker health checks and smoke tests:**

```typescript
// Health endpoint for Docker/Kubernetes health checks
app.get('/health', async () => {
  return { status: 'ok', service: 'your-app.app' };
});
```

**Convention:** Always return HTTP 200 with `{ status: 'ok' }` when healthy.

### 1.4 Add Metrics Endpoint

**Required for Prometheus scraping:**

```typescript
// Metrics endpoint for Prometheus scraping
// Exposes Prometheus metrics in text/plain format
app.get('/metrics', async (_request: FastifyRequest, reply: FastifyReply) => {
  const body = await metricsHandler();
  reply.type('text/plain; version=0.0.4').send(body);
});
```

**Port Convention:** Metrics endpoint is on the **same port** as the application. Prometheus scrapes `http://<service>:<port>/metrics`.

### 1.5 Structured Logging

Use the shared logger from `@genius-suite/common` for structured JSON logs:

```typescript
import { logger } from '@genius-suite/common';

// Info level
logger.info({ userId: 123, action: 'document_created' }, 'Document created successfully');

// Error level (includes stack trace)
logger.error(error, 'Failed to process document');

// Debug level
logger.debug({ query: 'SELECT * FROM docs' }, 'Executing query');
```

**Required fields for Loki parsing:**
- `level` - Log level (info, warn, error, debug)
- `message` - Human-readable message
- `time` - ISO 8601 timestamp
- `traceId` - (Optional) Correlation with distributed traces

---

## Step 2: Docker Compose Configuration

### 2.1 Create Docker Compose File

Create `your-app.app/compose/docker-compose.yml`:

```yaml
version: '3.9'

services:
  your-app-app:
    build:
      context: ../..
      dockerfile: your-app.app/Dockerfile
    container_name: your-app-app
    restart: unless-stopped
    environment:
      # Application port (from Port Strategy - Tabelul 5)
      - NODE_ENV=production
      - PORT=6XXX  # Replace with assigned port
      
      # OpenTelemetry configuration
      - OTEL_EXPORTER_OTLP_ENDPOINT=http://geniuserp-otel-collector:4318
      - OTEL_SERVICE_NAME=your-app.app
    ports:
      - "6XXX:6XXX"  # Replace with assigned port
    networks:
      # Zero-Trust network model (see Docker Strategy - Tabelul 3.5)
      - geniuserp_net_edge               # Public access via Traefik
      - geniuserp_net_suite_internal     # Internal API communication
      - geniuserp_net_backing_services   # Database/Kafka access
      - geniuserp_net_observability      # Metrics/logs/traces exposure
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:6XXX/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

networks:
  geniuserp_net_edge:
    external: true
    name: geniuserp_net_edge
  geniuserp_net_suite_internal:
    external: true
    name: geniuserp_net_suite_internal
  geniuserp_net_backing_services:
    external: true
    name: geniuserp_net_backing_services
  geniuserp_net_observability:
    external: true
    name: geniuserp_net_observability
```

### 2.2 Port Assignment

**Refer to:** `Plan/Strategii de Fișiere.env și Porturi.md` (Tabelul 5)

**Port Ranges:**
- **Control Plane:** 6100-6499 (e.g., 6100, 6150, 6200)
- **Stand-alone Apps:** 6500-6999 (e.g., 6500, 6550, 6600)

**Example assignments:**
- archify.app: `6500`
- cerniq.app: `6550`
- flowxify.app: `6600`
- i-wms.app: `6650`
- mercantiq.app: `6700`
- numeriqo.app: `6750`
- triggerra.app: `6800`
- vettify.app: `6850`

**Next available port for stand-alone apps:** `6900`

### 2.3 Environment Variables

**Required OTEL variables:**

| Variable | Value | Description |
|----------|-------|-------------|
| `OTEL_EXPORTER_OTLP_ENDPOINT` | `http://geniuserp-otel-collector:4318` | OTEL Collector HTTP endpoint |
| `OTEL_SERVICE_NAME` | `your-app.app` | Unique service identifier |

**Optional variables:**

| Variable | Value | Description |
|----------|-------|-------------|
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `http/protobuf` | Protocol (default: auto-detect) |
| `OTEL_TRACES_SAMPLER` | `always_on` | Trace sampling strategy (F0.3) |
| `LOG_LEVEL` | `info` | Log verbosity (debug, info, warn, error) |

---

## Step 3: Prometheus Scrape Configuration

### 3.1 Add Scrape Target

Edit `shared/observability/compose/prometheus.yml`:

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'genius_applications'
    static_configs:
      - targets:
          - 'archify.app:6501'
          - 'cerniq.app:6551'
          # ... existing targets ...
          - 'your-app.app:6XXX'  # Add your application here
```

**Important:** Prometheus scrapes the `/metrics` endpoint on the **application port** (same as health endpoint).

### 3.2 Restart Prometheus

After updating the config, restart Prometheus:

```bash
cd /var/www/GeniusSuite/shared/observability
docker compose -f compose/profiles/compose.dev.yml restart prometheus
```

**Verify scrape target:**
- Open Prometheus: http://localhost:9090
- Navigate to **Status → Targets**
- Find `genius_applications` job
- Verify `your-app.app:6XXX` shows `UP` state

---

## Step 4: Network Configuration

### 4.1 Zero-Trust Network Model

**All applications must connect to 4 networks** (per Docker Strategy - Tabelul 3.5):

| Network | Purpose | Required |
|---------|---------|----------|
| `geniuserp_net_edge` | Public access via Traefik | ✅ Yes |
| `geniuserp_net_suite_internal` | Internal API communication | ✅ Yes |
| `geniuserp_net_backing_services` | Database/Kafka access | ✅ Yes |
| `geniuserp_net_observability` | Metrics/logs/traces exposure | ✅ Yes (Critical) |

**Exception:** If your app doesn't need database access, you can omit `geniuserp_net_backing_services`.

### 4.2 Network Verification

Verify networks exist:

```bash
docker network ls | grep geniuserp_net
# Expected output:
# geniuserp_net_edge
# geniuserp_net_suite_internal
# geniuserp_net_backing_services
# geniuserp_net_observability
```

If networks don't exist, create them:

```bash
docker network create geniuserp_net_edge
docker network create geniuserp_net_suite_internal
docker network create geniuserp_net_backing_services
docker network create geniuserp_net_observability
```

---

## Step 5: Validation

### 5.1 Build and Start Application

```bash
cd /var/www/GeniusSuite/your-app.app/compose
docker compose up -d --build
```

**Check logs:**
```bash
docker logs your-app-app --tail 50
```

**Expected output:**
- OpenTelemetry SDK initialized
- Metrics endpoint registered
- Application listening on port 6XXX

### 5.2 Test Endpoints Manually

**Health check:**
```bash
curl http://localhost:6XXX/health
# Expected: {"status":"ok","service":"your-app.app"}
```

**Metrics endpoint:**
```bash
curl http://localhost:6XXX/metrics
# Expected: Prometheus text format with metrics
```

### 5.3 Run Infrastructure Validation

```bash
cd /var/www/GeniusSuite/shared/observability
bash scripts/validate.sh
```

**Expected output:**
- ✓ Your app on port 6XXX
- ✓ All 4 networks exist
- ✓ All endpoint checks passing

**If validation fails**, check:
1. Container is running: `docker ps | grep your-app`
2. Health endpoint responding: `curl http://localhost:6XXX/health`
3. Correct port in `prometheus.yml`

---

## Step 6: Testing

### 6.1 Add to Smoke Tests

Edit `shared/observability/scripts/smoke.sh`:

```bash
ENDPOINTS=(
  # ... existing endpoints ...
  
  # Your new application
  "http://localhost:6XXX/health|your-app.app"
  "http://localhost:6XXX/metrics|your-app.app-metrics"
)
```

**Run smoke tests:**
```bash
cd /var/www/GeniusSuite/shared/observability
bash scripts/smoke.sh
```

**Expected:**
```
[smoke] ✓ OK   your-app.app
[smoke] ✓ OK   your-app.app-metrics
[smoke] Rezultat Final: OK=35 FAIL=0 (Total: 35)
```

### 6.2 Verify in Grafana

**Access Grafana:** http://localhost:3000 (admin/admin)

**Check Metrics (Prometheus):**
1. Go to **Explore** → Select **Prometheus** datasource
2. Query: `up{job="genius_applications",instance=~"your-app.*"}`
3. Expected: Value `1` (service is up)

**Check Logs (Loki):**
1. Go to **Explore** → Select **Loki** datasource
2. Query: `{container_name="your-app-app"}`
3. Expected: See recent log entries from your application

**Check Traces (F0.4+ when Tempo deployed):**
- Currently traces are logged to OTEL Collector stdout
- Future: Query traces via Tempo datasource in Grafana

---

## Naming Conventions

### Service Names

**Format:** `<app-name>.app` for stand-alone apps, `cp/<service-name>` for Control Plane

**Examples:**
- ✅ `archify.app` (stand-alone)
- ✅ `cp/identity` (control plane)
- ❌ `ArchifyApp` (incorrect casing)
- ❌ `app-archify` (incorrect format)

### Container Names

**Format:** `<app-name>-app` (lowercase, hyphen-separated)

**Examples:**
- ✅ `archify-app`
- ✅ `genius-suite-identity` (Control Plane)
- ❌ `archify_app` (underscores not used)

### OTEL Attributes

**Required attributes** (set via `initTracing()`):

```typescript
{
  "service.name": "your-app.app",
  "service.version": "1.0.0",
  "deployment.environment": "dev",
  "service.namespace": "geniussuite"
}
```

### Metric Names

**Follow OpenTelemetry conventions:**
- Use lowercase with underscores
- Use descriptive suffixes (`_total`, `_duration_ms`, `_count`)

**Examples:**
- ✅ `http_server_request_duration_ms`
- ✅ `db_query_count_total`
- ❌ `HttpRequestDuration` (incorrect casing)

### Log Fields

**Required fields for Loki parsing:**

```json
{
  "level": "info",
  "message": "Document created",
  "time": "2024-11-13T10:00:00Z",
  "service": "your-app.app",
  "traceId": "abc123..."  // Optional but recommended
}
```

---

## Complete Example

### Example: Integrating `docuflow.app`

**Step 1: Code (src/index.ts)**

```typescript
import fastify from 'fastify';
import { initTracing, initMetrics, metricsHandler } from '@genius-suite/observability';
import { logger } from '@genius-suite/common';

async function main() {
  const serviceName = process.env.OTEL_SERVICE_NAME || 'docuflow.app';
  const port = parseInt(process.env.PORT || '6900', 10);

  await initTracing({ serviceName });
  await initMetrics({ serviceName });

  const app = fastify({
    logger: {
      level: 'info',
      formatters: { level: (label) => ({ level: label }) },
      timestamp: () => `,"time":"${new Date().toISOString()}"`,
    }
  });

  app.get('/health', async () => ({ status: 'ok', service: 'docuflow.app' }));
  app.get('/metrics', async (_, reply) => {
    const body = await metricsHandler();
    reply.type('text/plain').send(body);
  });

  await app.listen({ port, host: '0.0.0.0' });
  logger.info({ port, service: serviceName }, 'Docuflow App started');
}

main().catch((err) => {
  logger.error(err, 'Fatal error in docuflow.app');
  process.exit(1);
});
```

**Step 2: Docker Compose (compose/docker-compose.yml)**

```yaml
version: '3.9'

services:
  docuflow-app:
    build:
      context: ../..
      dockerfile: docuflow.app/Dockerfile
    container_name: docuflow-app
    restart: unless-stopped
    environment:
      - NODE_ENV=production
      - PORT=6900
      - OTEL_EXPORTER_OTLP_ENDPOINT=http://geniuserp-otel-collector:4318
      - OTEL_SERVICE_NAME=docuflow.app
    ports:
      - "6900:6900"
    networks:
      - geniuserp_net_edge
      - geniuserp_net_suite_internal
      - geniuserp_net_backing_services
      - geniuserp_net_observability
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:6900/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

networks:
  geniuserp_net_edge:
    external: true
    name: geniuserp_net_edge
  geniuserp_net_suite_internal:
    external: true
    name: geniuserp_net_suite_internal
  geniuserp_net_backing_services:
    external: true
    name: geniuserp_net_backing_services
  geniuserp_net_observability:
    external: true
    name: geniuserp_net_observability
```

**Step 3: Prometheus Config**

Add to `shared/observability/compose/prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'genius_applications'
    static_configs:
      - targets:
          # ... existing ...
          - 'docuflow.app:6900'
```

**Step 4: Smoke Tests**

Add to `shared/observability/scripts/smoke.sh`:

```bash
ENDPOINTS=(
  # ... existing ...
  "http://localhost:6900/health|docuflow.app"
  "http://localhost:6900/metrics|docuflow.app-metrics"
)
```

**Step 5: Validate**

```bash
# Start application
cd docuflow.app/compose
docker compose up -d --build

# Validate infrastructure
cd /var/www/GeniusSuite/shared/observability
bash scripts/validate.sh

# Run smoke tests
bash scripts/smoke.sh
```

---

## Troubleshooting

### Problem: "OTEL Collector connection refused"

**Cause:** Application can't reach OTEL Collector.

**Solution:**
1. Verify OTEL Collector is running:
   ```bash
   docker ps | grep otel-collector
   ```

2. Check application is on `geniuserp_net_observability` network:
   ```bash
   docker inspect your-app-app | grep -A 10 Networks
   ```

3. Test connectivity from application container:
   ```bash
   docker exec your-app-app curl http://geniuserp-otel-collector:4318
   ```

### Problem: "Prometheus not scraping metrics"

**Cause:** Incorrect target configuration or network isolation.

**Solution:**
1. Verify `/metrics` endpoint works:
   ```bash
   curl http://localhost:6XXX/metrics
   ```

2. Check Prometheus config syntax:
   ```bash
   cd shared/observability
   docker compose -f compose/profiles/compose.dev.yml config
   ```

3. Restart Prometheus:
   ```bash
   docker compose -f compose/profiles/compose.dev.yml restart prometheus
   ```

4. Check Prometheus UI (http://localhost:9090/targets)

### Problem: "Logs not appearing in Loki"

**Cause:** Log format doesn't match Promtail parser or container labels missing.

**Solution:**
1. Verify logs are JSON formatted:
   ```bash
   docker logs your-app-app | head -5
   ```

2. Expected format:
   ```json
   {"level":"info","time":"2024-11-13T10:00:00Z","message":"..."}
   ```

3. Check Promtail is discovering container:
   ```bash
   docker logs profiles-promtail-1 | grep your-app
   ```

4. Query Loki directly:
   ```bash
   curl -G http://localhost:3100/loki/api/v1/query \
     --data-urlencode 'query={container_name="your-app-app"}'
   ```

### Problem: "validate.sh reports port conflict"

**Cause:** Port already in use by another service.

**Solution:**
1. Check port assignments in Port Strategy document (Tabelul 5)
2. Find next available port in your category:
   - CP: 6100-6499
   - Apps: 6500-6999
3. Update `docker-compose.yml` and `prometheus.yml` with new port
4. Restart application

### Problem: "Health check failing in Docker Compose"

**Cause:** Health endpoint not responding or wrong port.

**Solution:**
1. Check health endpoint manually:
   ```bash
   docker exec your-app-app curl http://localhost:6XXX/health
   ```

2. Verify container logs:
   ```bash
   docker logs your-app-app --tail 50
   ```

3. Ensure health endpoint returns HTTP 200:
   ```typescript
   app.get('/health', async () => ({ status: 'ok' }));
   ```

---

## Checklist

### Code Integration ✅

- [ ] Installed `@genius-suite/observability` package
- [ ] Added `initTracing()` call before app initialization
- [ ] Added `initMetrics()` call before app initialization
- [ ] Created `/health` endpoint returning `{ status: 'ok' }`
- [ ] Created `/metrics` endpoint using `metricsHandler()`
- [ ] Using structured JSON logging with `logger` from `@genius-suite/common`
- [ ] Log format includes `level`, `message`, `time` fields

### Docker Compose ✅

- [ ] Created `compose/docker-compose.yml` in application directory
- [ ] Set `OTEL_EXPORTER_OTLP_ENDPOINT=http://geniuserp-otel-collector:4318`
- [ ] Set `OTEL_SERVICE_NAME=your-app.app`
- [ ] Assigned port from strategic allocation (Tabelul 5)
- [ ] Connected to all 4 networks (edge, suite_internal, backing_services, observability)
- [ ] Added health check with `curl http://localhost:<port>/health`
- [ ] Set `restart: unless-stopped`

### Prometheus Configuration ✅

- [ ] Added scrape target to `shared/observability/compose/prometheus.yml`
- [ ] Target format: `your-app.app:<port>`
- [ ] Restarted Prometheus after config change
- [ ] Verified target is `UP` in Prometheus UI (http://localhost:9090/targets)

### Network Configuration ✅

- [ ] All 4 networks exist (`docker network ls | grep geniuserp_net`)
- [ ] Networks declared as `external: true` in compose file
- [ ] Application container connected to all 4 networks

### Validation ✅

- [ ] Application builds successfully (`docker compose up -d --build`)
- [ ] Container is running (`docker ps | grep your-app`)
- [ ] Health endpoint responds HTTP 200
- [ ] Metrics endpoint responds with Prometheus format
- [ ] `validate.sh` passes all checks (38/38)

### Testing ✅

- [ ] Added application to `smoke.sh` endpoints array
- [ ] Smoke tests pass (health + metrics)
- [ ] Metrics visible in Grafana → Prometheus datasource
- [ ] Logs visible in Grafana → Loki datasource
- [ ] Traces logged to OTEL Collector (check `docker logs geniuserp-otel-collector`)

### Documentation ✅

- [ ] Updated this guide if you found gaps or errors
- [ ] Added service to `architecture.md` component list (optional)
- [ ] Documented any custom metrics or special configuration

---

## Next Steps

After successful integration:

1. **Create Custom Dashboards** - Build Grafana dashboards for your application metrics
2. **Define Alerts** (F0.4+) - Set up Prometheus alert rules for critical metrics
3. **Optimize Sampling** (F0.4+) - Configure trace sampling strategies for high-traffic apps
4. **Add Business Metrics** - Instrument domain-specific metrics beyond HTTP/DB basics

---

## References

### Internal Documentation

- **Architecture Overview:** `architecture.md`
- **Scripts Usage:** `../scripts/README.md`
- **Port Strategy:** `../../Plan/Strategii de Fișiere.env și Porturi.md`
- **Docker Strategy:** `../../Plan/Strategie Docker_ Volumuri, Rețele și Backup.md`
- **Strategic Plan:** `../../Plan/GeniusERP_Suite_Plan_v1.0.5.md`

### Configuration Files

- **OTEL Collector:** `../otel-config/otel-collector-config.yml`
- **Prometheus:** `../compose/prometheus.yml`
- **Promtail:** `../logs/ingestion/promtail-config.yml`
- **Docker Compose:** `../compose/profiles/compose.dev.yml`

### Example Implementations

- **Stand-alone App:** `../../archify.app/src/index.ts`
- **Control Plane:** `../../cp/identity/src/index.ts`
- **Docker Compose:** `../../archify.app/compose/docker-compose.yml`

### External Resources

- [OpenTelemetry Node.js SDK](https://opentelemetry.io/docs/languages/js/)
- [Prometheus Best Practices](https://prometheus.io/docs/practices/naming/)
- [Fastify Documentation](https://fastify.dev/)
- [Loki LogQL](https://grafana.com/docs/loki/latest/query/)

---

**Questions or Issues?**
- Check `architecture.md` for system-wide observability documentation
- Run `bash scripts/validate.sh` to diagnose infrastructure problems
- Review logs: `docker logs <container-name>`
- Open issue in GeniusSuite repository with `observability` label

**Last Updated:** 2024-11-13  
**Version:** 1.0.0  
**Maintainer:** GeniusSuite DevOps Team
