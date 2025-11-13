# Observability Runbooks

**Purpose:** Incident response procedures for GeniusSuite observability stack issues  
**Audience:** On-call engineers, DevOps, SRE teams  
**Last Updated:** 2024-11-13  
**Version:** 1.0.0 (F0.3 Skeleton)

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [General Troubleshooting Process](#general-troubleshooting-process)
3. [Runbook Index](#runbook-index)
4. [Observability Infrastructure](#observability-infrastructure)
5. [Application Issues](#application-issues)
6. [Network & Connectivity](#network--connectivity)
7. [Data Collection Issues](#data-collection-issues)
8. [Escalation Procedures](#escalation-procedures)

---

## Overview

### What is a Runbook?

A **runbook** is a step-by-step guide for diagnosing and resolving specific operational issues. Each runbook follows a consistent structure:

1. **Symptom** - What you observe (alert, error, behavior)
2. **Impact** - Who/what is affected
3. **Possible Causes** - Common root causes
4. **Diagnostic Steps** - How to confirm the issue
5. **Resolution Steps** - How to fix it
6. **Prevention** - How to avoid recurrence

### Runbook Philosophy (F0.3)

**F0.3 Skeleton Phase** focuses on:
- ✅ Infrastructure health (Prometheus, Loki, OTEL Collector)
- ✅ Data collection validation (metrics, logs, traces)
- ✅ Network connectivity between services
- ⚠️ Minimal alerting (manual monitoring via validate.sh/smoke.sh)

**Future Phases:**
- **F0.4:** Automated alerting, on-call integration
- **F0.5:** SLO-based alerts, advanced diagnostics
- **F0.6:** Predictive alerting, auto-remediation

---

## General Troubleshooting Process

### Step 1: Validate the Symptom

**Always start with validation:**

```bash
# Quick health check of observability stack
cd /var/www/GeniusSuite/shared/observability
bash scripts/validate.sh

# Check all service endpoints
bash scripts/smoke.sh
```

**Expected Output:**
- `validate.sh`: **38/38 checks passing**
- `smoke.sh`: **OK=35 FAIL=0**

---

### Step 2: Check Recent Changes

**Git History:**
```bash
# Last 10 commits
git log --oneline -10

# Changes in last 24 hours
git log --since="24 hours ago" --oneline

# Files changed in observability
git log --since="24 hours ago" --name-only -- shared/observability/
```

**Docker Changes:**
```bash
# Recently restarted containers
docker ps --format "{{.Names}} {{.Status}}"

# Container events in last hour
docker events --since 1h --until now
```

---

### Step 3: Gather Context

**System State:**
```bash
# Running containers
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Container resource usage
docker stats --no-stream

# Disk space
df -h

# Recent container logs
docker logs <container-name> --tail 100 --since 10m
```

---

### Step 4: Apply Runbook

Find the relevant runbook below and follow diagnostic/resolution steps.

---

### Step 5: Verify Resolution

**After applying fix:**
```bash
# Revalidate infrastructure
bash scripts/validate.sh

# Rerun smoke tests
bash scripts/smoke.sh

# Check affected service
curl http://localhost:<port>/health
curl http://localhost:<port>/metrics
```

---

### Step 6: Document & Learn

**Post-Incident:**
1. Document root cause in issue tracker
2. Update runbook if steps were incomplete
3. Consider preventive measures (alerts, automation)

---

## Runbook Index

| # | Runbook Title | Severity | Typical Time to Resolve |
|---|---------------|----------|------------------------|
| **Infrastructure** |
| 1 | [Observability Stack Not Starting](#runbook-1-observability-stack-not-starting) | 🔴 Critical | 5-15 min |
| 2 | [Prometheus Not Scraping Metrics](#runbook-2-prometheus-not-scraping-metrics) | 🟡 High | 5-10 min |
| 3 | [Loki Not Receiving Logs](#runbook-3-loki-not-receiving-logs) | 🟡 High | 5-10 min |
| 4 | [OTEL Collector Not Receiving Traces](#runbook-4-otel-collector-not-receiving-traces) | 🟢 Medium | 10-15 min |
| 5 | [Grafana Cannot Connect to Datasources](#runbook-5-grafana-cannot-connect-to-datasources) | 🟡 High | 5 min |
| **Applications** |
| 6 | [Service Not Exposing Metrics](#runbook-6-service-not-exposing-metrics) | 🟢 Medium | 10-20 min |
| 7 | [Service Health Check Failing](#runbook-7-service-health-check-failing) | 🟡 High | 10-20 min |
| 8 | [Service Not Sending Logs to Loki](#runbook-8-service-not-sending-logs-to-loki) | 🟢 Medium | 10 min |
| 9 | [High Error Rate on Service](#runbook-9-high-error-rate-on-service) | 🟡 High | Variable |
| **Network** |
| 10 | [Service Cannot Reach OTEL Collector](#runbook-10-service-cannot-reach-otel-collector) | 🟡 High | 5-10 min |
| 11 | [Docker Networks Missing](#runbook-11-docker-networks-missing) | 🔴 Critical | 2-5 min |
| 12 | [Port Conflicts](#runbook-12-port-conflicts) | 🟡 High | 5-10 min |
| **Data** |
| 13 | [Prometheus Data Loss](#runbook-13-prometheus-data-loss) | 🟢 Medium | Permanent |
| 14 | [Loki Data Loss](#runbook-14-loki-data-loss) | 🟢 Medium | Permanent |
| 15 | [validate.sh Failing](#runbook-15-validatesh-failing) | 🟡 High | Variable |

---

## Observability Infrastructure

### Runbook 1: Observability Stack Not Starting

**Symptom:**
- `docker compose up` fails
- Containers exit immediately after start
- `validate.sh` shows multiple failures

**Impact:** Complete observability outage - no metrics, logs, or traces collected.

**Possible Causes:**
- Missing Docker networks
- Port conflicts
- Configuration file errors
- Insufficient disk space
- Missing environment variables

---

**Diagnostic Steps:**

```bash
# 1. Check Docker Compose config syntax
cd /var/www/GeniusSuite/shared/observability
docker compose -f compose/profiles/compose.dev.yml config

# 2. Check networks exist
docker network ls | grep geniuserp_net

# 3. Check port availability
netstat -tuln | grep -E "3000|3100|4317|4318|9090"

# 4. Check disk space
df -h

# 5. Check container status
docker compose -f compose/profiles/compose.dev.yml ps -a
```

---

**Resolution Steps:**

**If networks missing:**
```bash
# Create all 4 networks
docker network create geniuserp_net_edge
docker network create geniuserp_net_suite_internal
docker network create geniuserp_net_backing_services
docker network create geniuserp_net_observability
```

**If port conflicts:**
```bash
# Find process using port
lsof -i :9090  # Example for Prometheus

# Kill process (if safe)
kill -9 <PID>

# Or override port
export OBS_PROMETHEUS_PORT=9091
docker compose up -d
```

**If config errors:**
```bash
# Validate YAML syntax
yamllint compose/profiles/compose.dev.yml

# Check for typos in volume mounts
docker compose -f compose/profiles/compose.dev.yml config | grep volumes -A 5
```

**If disk space issues:**
```bash
# Clean Docker cache
docker system prune -a --volumes

# Remove old containers
docker container prune
```

**Standard restart procedure:**
```bash
cd /var/www/GeniusSuite/shared/observability

# Stop all services
docker compose -f compose/profiles/compose.dev.yml down

# Recreate and start
docker compose -f compose/profiles/compose.dev.yml up -d

# Wait 30 seconds for initialization
sleep 30

# Validate
bash scripts/validate.sh
```

---

**Prevention:**
- Run `validate.sh` before and after changes
- Use version control for configuration files
- Monitor disk space with alerts (F0.4+)

**Related Dashboards:** N/A (infrastructure down)  
**Escalation:** If issue persists after 15 minutes, escalate to infrastructure team

---

### Runbook 2: Prometheus Not Scraping Metrics

**Symptom:**
- Prometheus UI shows targets as "DOWN"
- No metrics appearing in Grafana queries
- `validate.sh` reports port checks failing

**Impact:** Unable to monitor service health, performance, or errors.

**Possible Causes:**
- Service `/metrics` endpoint not responding
- Incorrect target configuration in `prometheus.yml`
- Network connectivity issue
- Service not on `geniuserp_net_observability` network
- Port mismatch between config and service

---

**Diagnostic Steps:**

```bash
# 1. Check Prometheus targets
open http://localhost:9090/targets
# or
curl http://localhost:9090/api/v1/targets | jq

# 2. Test target endpoint directly
curl http://localhost:6500/metrics  # Example: archify.app

# 3. Test from Prometheus container
docker exec -it $(docker ps -qf name=prometheus) \
  curl http://archify.app:6501/metrics

# 4. Check service networks
docker inspect archify-app | grep -A 10 Networks

# 5. Check Prometheus config
cat shared/observability/compose/prometheus.yml
```

---

**Resolution Steps:**

**If target endpoint not responding:**
```bash
# Check service is running
docker ps | grep archify-app

# Check service logs
docker logs archify-app --tail 50

# Restart service
docker restart archify-app
```

**If wrong port in prometheus.yml:**
```bash
# Edit prometheus.yml
# Change: 'archify.app:6501' to correct port

# Restart Prometheus
docker compose -f compose/profiles/compose.dev.yml restart prometheus

# Verify scrape working
curl http://localhost:9090/targets
```

**If network connectivity issue:**
```bash
# Verify service is on observability network
docker network inspect geniuserp_net_observability | grep -A 3 "archify-app"

# If missing, add network to docker-compose.yml
# Then recreate service
cd /var/www/GeniusSuite/archify.app/compose
docker compose down
docker compose up -d
```

**If Prometheus container issue:**
```bash
# Check Prometheus logs
docker logs $(docker ps -qf name=prometheus) --tail 100

# Restart Prometheus
docker compose -f compose/profiles/compose.dev.yml restart prometheus
```

---

**Prevention:**
- Always add services to `prometheus.yml` when deploying
- Use `validate.sh` to catch misconfigurations
- Verify network configuration in `docker-compose.yml`

**Related Dashboards:** 
- Grafana → Explore → Prometheus → Query: `up{job="genius_applications"}`

**Escalation:** If metrics still not scraping after 10 minutes, escalate to observability team

---

### Runbook 3: Loki Not Receiving Logs

**Symptom:**
- Grafana Explore (Loki) returns no results
- Loki datasource test fails
- Container logs exist but not visible in Loki

**Impact:** Unable to query or search logs centrally - must use `docker logs` manually.

**Possible Causes:**
- Promtail container not running
- Docker socket not mounted in Promtail
- Promtail configuration error
- Loki service down
- Network connectivity issue

---

**Diagnostic Steps:**

```bash
# 1. Check Loki is running
docker ps | grep loki
curl http://localhost:3100/ready

# 2. Check Promtail is running
docker ps | grep promtail

# 3. Check Promtail logs for errors
docker logs profiles-promtail-1 --tail 100

# 4. Test Loki directly
curl -G http://localhost:3100/loki/api/v1/query \
  --data-urlencode 'query={container_name="archify-app"}'

# 5. Check Docker socket mount
docker inspect profiles-promtail-1 | grep -A 5 "docker.sock"
```

---

**Resolution Steps:**

**If Promtail not running:**
```bash
cd /var/www/GeniusSuite/shared/observability
docker compose -f compose/profiles/compose.dev.yml up -d promtail

# Wait 10 seconds
sleep 10

# Check logs
docker logs profiles-promtail-1 --tail 50
```

**If Docker socket not mounted:**
```bash
# Verify compose file has:
# volumes:
#   - /var/run/docker.sock:/var/run/docker.sock:ro

cat compose/profiles/compose.dev.yml | grep -A 3 "docker.sock"

# If missing, add to compose file and recreate
docker compose -f compose/profiles/compose.dev.yml up -d --force-recreate promtail
```

**If Promtail config error:**
```bash
# Check config syntax
cat logs/ingestion/promtail-config.yml

# Validate YAML
yamllint logs/ingestion/promtail-config.yml

# If errors, fix and restart
docker compose -f compose/profiles/compose.dev.yml restart promtail
```

**If Loki service down:**
```bash
# Check Loki logs
docker logs $(docker ps -qf name=loki) --tail 100

# Restart Loki
docker compose -f compose/profiles/compose.dev.yml restart loki

# Wait for startup
sleep 15

# Test again
curl http://localhost:3100/ready
```

---

**Prevention:**
- Ensure Promtail always starts with observability stack
- Monitor Promtail logs for warnings
- Use structured JSON logging in applications

**Related Dashboards:**
- Grafana → Explore → Loki → Query: `{container_name=~".+-app"}`

**Escalation:** If logs still not appearing after 15 minutes, escalate to logging team

---

### Runbook 4: OTEL Collector Not Receiving Traces

**Symptom:**
- Application logs show "failed to export trace" errors
- OTEL Collector logs empty
- `validate.sh` reports OTEL Collector container not running

**Impact:** Distributed traces not collected - unable to debug cross-service requests.

**Possible Causes:**
- OTEL Collector container not running
- Application pointing to wrong OTEL endpoint
- Network connectivity issue
- OTEL Collector configuration error

---

**Diagnostic Steps:**

```bash
# 1. Check OTEL Collector is running
docker ps | grep otel-collector

# 2. Check OTEL Collector logs
docker logs geniuserp-otel-collector --tail 100

# 3. Test OTEL endpoints
curl http://localhost:4318/  # HTTP endpoint
curl http://localhost:4317/  # gRPC endpoint (may timeout, that's OK)

# 4. Check application OTEL config
docker exec archify-app env | grep OTEL

# 5. Test connectivity from app container
docker exec archify-app curl http://geniuserp-otel-collector:4318
```

---

**Resolution Steps:**

**If OTEL Collector not running:**
```bash
cd /var/www/GeniusSuite/shared/observability
docker compose -f compose/profiles/compose.dev.yml up -d otel-collector

# Wait for startup
sleep 10

# Verify running
docker ps | grep otel-collector
```

**If app pointing to wrong endpoint:**
```bash
# Check application docker-compose.yml
cat /var/www/GeniusSuite/archify.app/compose/docker-compose.yml | grep OTEL

# Should be:
# OTEL_EXPORTER_OTLP_ENDPOINT=http://geniuserp-otel-collector:4318

# If pointing to "tempo:4318" (old config), fix:
# 1. Update docker-compose.yml
# 2. Restart application
docker restart archify-app
```

**If network connectivity issue:**
```bash
# Check app is on observability network
docker network inspect geniuserp_net_observability | grep -A 3 "archify-app"

# If missing, add to docker-compose.yml:
# networks:
#   - geniuserp_net_observability

# Recreate app
cd /var/www/GeniusSuite/archify.app/compose
docker compose down
docker compose up -d
```

**If OTEL Collector config error:**
```bash
# Check config file
cat otel-config/otel-collector-config.yml

# Validate YAML
yamllint otel-config/otel-collector-config.yml

# If errors, fix and restart
docker compose -f compose/profiles/compose.dev.yml restart otel-collector
```

---

**Prevention:**
- Use correct OTEL endpoint: `http://geniuserp-otel-collector:4318`
- Verify network configuration when adding new services
- Monitor OTEL Collector logs for errors

**Related Dashboards:** N/A (Tempo not deployed in F0.3)  
**Planned (F0.4):** Tempo deployment, trace querying in Grafana

**Escalation:** If traces still not collected after 15 minutes, escalate to observability team

---

### Runbook 5: Grafana Cannot Connect to Datasources

**Symptom:**
- Grafana datasource test shows "Data source is working" ❌
- Queries return "Cannot connect to datasource" error
- Grafana UI accessible but no data

**Impact:** Unable to visualize metrics or logs - complete observability dashboard outage.

**Possible Causes:**
- Prometheus/Loki service down
- Incorrect datasource URL configuration
- Network connectivity issue
- Grafana not on `geniuserp_net_observability` network

---

**Diagnostic Steps:**

```bash
# 1. Check Grafana is running
docker ps | grep grafana
curl http://localhost:3000/metrics

# 2. Check datasources configured
# Access Grafana: http://localhost:3000
# Go to Configuration → Data Sources

# 3. Test datasource connectivity from Grafana container
docker exec -it $(docker ps -qf name=grafana) curl http://prometheus:9090/-/ready
docker exec -it $(docker ps -qf name=grafana) curl http://loki:3100/ready

# 4. Check Prometheus is running
docker ps | grep prometheus
curl http://localhost:9090/-/ready

# 5. Check Loki is running
docker ps | grep loki
curl http://localhost:3100/ready
```

---

**Resolution Steps:**

**If Prometheus/Loki down:**
```bash
# Restart services
cd /var/www/GeniusSuite/shared/observability
docker compose -f compose/profiles/compose.dev.yml restart prometheus loki

# Wait for startup
sleep 20

# Retest in Grafana
```

**If datasource URL wrong:**
```bash
# Check datasources.yml
cat dashboards/grafana/datasources.yml

# Should be:
# Prometheus: http://prometheus:9090
# Loki: http://loki:3100
# NOT http://localhost:9090

# If incorrect, fix file and restart Grafana
docker compose -f compose/profiles/compose.dev.yml restart grafana
```

**If network connectivity issue:**
```bash
# Check all containers on observability network
docker network inspect geniuserp_net_observability | grep Name

# Should see: grafana, prometheus, loki, otel-collector, promtail

# If missing, check compose file networks configuration
cat compose/profiles/compose.dev.yml | grep -A 5 networks
```

**Standard fix:**
```bash
# Restart entire observability stack
cd /var/www/GeniusSuite/shared/observability
docker compose -f compose/profiles/compose.dev.yml restart

# Wait for initialization
sleep 30

# Validate
bash scripts/validate.sh
```

---

**Prevention:**
- Use container names in datasource URLs (not `localhost`)
- Verify all services on same Docker network
- Test datasources after any configuration changes

**Related Dashboards:** N/A (dashboards not accessible)  
**Escalation:** If datasources still not connecting after 10 minutes, escalate to platform team

---

## Application Issues

### Runbook 6: Service Not Exposing Metrics

**Symptom:**
- `curl http://localhost:6500/metrics` returns 404 or connection refused
- Prometheus target shows as "DOWN"
- `smoke.sh` reports metrics endpoint failing

**Impact:** Unable to monitor service performance - no latency, error rate, or throughput data.

**Possible Causes:**
- Metrics endpoint not implemented
- Application not initialized with observability library
- Wrong port configuration
- Application crashed or not running

---

**Diagnostic Steps:**

```bash
# 1. Check service is running
docker ps | grep archify-app

# 2. Test health endpoint (should work even if metrics doesn't)
curl http://localhost:6500/health

# 3. Test metrics endpoint
curl http://localhost:6500/metrics

# 4. Check application logs for observability initialization
docker logs archify-app | grep -i "metrics\|otel\|observability"

# 5. Check port configuration
docker inspect archify-app | grep -A 5 "ExposedPorts\|PortBindings"
```

---

**Resolution Steps:**

**If metrics endpoint not implemented:**
```bash
# Check if application code has metrics endpoint
# File: archify.app/src/index.ts

# Should contain:
# import { metricsHandler } from '@genius-suite/observability';
# app.get('/metrics', async (_, reply) => {
#   const body = await metricsHandler();
#   reply.type('text/plain').send(body);
# });

# If missing, add endpoint following: docs/how-to-add-new-app(module).md
# Then rebuild and restart:
cd /var/www/GeniusSuite/archify.app/compose
docker compose up -d --build
```

**If observability not initialized:**
```bash
# Check application code imports
# File: archify.app/src/index.ts

# Should contain:
# import { initTracing, initMetrics } from '@genius-suite/observability';
# await initTracing({ serviceName: 'archify.app' });
# await initMetrics({ serviceName: 'archify.app' });

# If missing, add initialization following: docs/how-to-add-new-app(module).md
# Then rebuild
docker compose up -d --build
```

**If wrong port:**
```bash
# Check docker-compose.yml port configuration
cat compose/docker-compose.yml | grep -A 5 "ports:"

# Should match PORT environment variable
# Fix if mismatched, then restart
docker compose down
docker compose up -d
```

**If application crashed:**
```bash
# Check logs for errors
docker logs archify-app --tail 100

# Restart application
docker restart archify-app

# Monitor startup
docker logs archify-app -f
```

---

**Prevention:**
- Use `how-to-add-new-app(module).md` guide when adding services
- Run `smoke.sh` after deploying new services
- Include metrics endpoint in CI/CD health checks

**Related Dashboards:**
- Grafana → Explore → Prometheus → Query: `up{instance=~"archify.app.*"}`

**Escalation:** If metrics still not working after 20 minutes, escalate to application team

---

### Runbook 7: Service Health Check Failing

**Symptom:**
- Docker health check status: `unhealthy`
- `docker ps` shows `(unhealthy)` next to container
- `smoke.sh` reports `/health` endpoint failing

**Impact:** Service may not receive traffic from load balancer - potential service outage.

**Possible Causes:**
- Application failed to start properly
- Health endpoint not implemented
- Application dependency failure (database, Kafka)
- Port misconfiguration
- Resource exhaustion (CPU, memory)

---

**Diagnostic Steps:**

```bash
# 1. Check container health status
docker ps --format "table {{.Names}}\t{{.Status}}"

# 2. Check health check configuration
docker inspect archify-app | grep -A 10 Healthcheck

# 3. Test health endpoint manually
curl http://localhost:6500/health

# 4. Check application logs
docker logs archify-app --tail 50

# 5. Check resource usage
docker stats archify-app --no-stream

# 6. Check dependencies
curl http://localhost:5432  # PostgreSQL
curl http://localhost:9092  # Kafka
```

---

**Resolution Steps:**

**If health endpoint not responding:**
```bash
# Check if application started successfully
docker logs archify-app | grep -i "listening\|started\|ready"

# If no startup message, check for errors
docker logs archify-app | grep -i "error\|fatal"

# Restart application
docker restart archify-app
```

**If health endpoint not implemented:**
```bash
# Check application code
# File: archify.app/src/index.ts

# Should contain:
# app.get('/health', async () => ({ status: 'ok', service: 'archify.app' }));

# If missing, add endpoint and rebuild
docker compose up -d --build
```

**If dependency failure:**
```bash
# Check database connection
docker exec archify-app pg_isready -h postgres -p 5432

# Check Kafka connection
docker exec archify-app nc -zv kafka 9092

# If dependency down, restart dependency
docker restart postgres  # or kafka
```

**If resource exhaustion:**
```bash
# Check CPU/Memory usage
docker stats archify-app --no-stream

# If high usage, check application logs for memory leaks
docker logs archify-app | grep -i "out of memory\|oom"

# Temporary: Increase resources in docker-compose.yml
# deploy:
#   resources:
#     limits:
#       memory: 2G

# Restart with new limits
docker compose up -d
```

---

**Prevention:**
- Always implement `/health` endpoint returning HTTP 200
- Monitor application dependencies health
- Set appropriate health check intervals (30s+)
- Configure startup periods (40s+) for slow-starting apps

**Related Dashboards:**
- Grafana → Explore → Prometheus → Query: `up{instance=~"archify.app.*"}`

**Escalation:** If health check still failing after 20 minutes, escalate to application team

---

### Runbook 8: Service Not Sending Logs to Loki

**Symptom:**
- Grafana Loki query returns no logs for specific service
- Container logs exist (`docker logs` works) but not in Loki
- Other services' logs visible in Loki

**Impact:** Unable to debug service issues using centralized logging - must use `docker logs` manually.

**Possible Causes:**
- Log format not JSON (Promtail can't parse)
- Container labels missing for Promtail discovery
- Promtail not running or restarted recently
- Service restarted recently (logs buffered but not scraped yet)

---

**Diagnostic Steps:**

```bash
# 1. Check container logs exist
docker logs archify-app --tail 20

# 2. Check log format (should be JSON)
docker logs archify-app --tail 5

# Expected format:
# {"level":"info","time":"2024-11-13T10:00:00Z","message":"..."}

# 3. Check Promtail is discovering container
docker logs profiles-promtail-1 | grep -i "archify-app"

# 4. Query Loki directly
curl -G http://localhost:3100/loki/api/v1/query \
  --data-urlencode 'query={container_name="archify-app"}' \
  --data-urlencode 'start=1700000000000000000'

# 5. Check Promtail config
cat logs/ingestion/promtail-config.yml
```

---

**Resolution Steps:**

**If log format not JSON:**
```bash
# Check application logging configuration
# File: archify.app/src/index.ts

# Should use structured JSON logging:
# const app = fastify({
#   logger: {
#     level: 'info',
#     formatters: { level: (label) => ({ level: label }) },
#     timestamp: () => `,"time":"${new Date().toISOString()}"`,
#   }
# });

# If using console.log or plain text, update to JSON
# Rebuild and restart
docker compose up -d --build
```

**If Promtail not discovering container:**
```bash
# Check Promtail is running
docker ps | grep promtail

# If not running, start it
cd /var/www/GeniusSuite/shared/observability
docker compose -f compose/profiles/compose.dev.yml up -d promtail

# Wait 30 seconds for discovery
sleep 30

# Check Promtail logs
docker logs profiles-promtail-1 --tail 50
```

**If logs buffered but not scraped:**
```bash
# Restart Promtail to force rescan
docker compose -f compose/profiles/compose.dev.yml restart promtail

# Wait 30 seconds
sleep 30

# Query Loki again
curl -G http://localhost:3100/loki/api/v1/query \
  --data-urlencode 'query={container_name="archify-app"}'
```

**If time range issue:**
```bash
# In Grafana, expand time range to "Last 24 hours"
# Or query with specific time range:
curl -G http://localhost:3100/loki/api/v1/query_range \
  --data-urlencode 'query={container_name="archify-app"}' \
  --data-urlencode 'start=2024-11-13T00:00:00Z' \
  --data-urlencode 'end=2024-11-13T23:59:59Z'
```

---

**Prevention:**
- Always use structured JSON logging format
- Test log ingestion after deploying new services
- Monitor Promtail logs for discovery issues

**Related Dashboards:**
- Grafana → Explore → Loki → Query: `{container_name=~".+-app"}`

**Escalation:** If logs still not appearing after 15 minutes, escalate to logging team

---

### Runbook 9: High Error Rate on Service

**Symptom:**
- Prometheus query shows high error rate (> 5%)
- Application logs show repeated errors
- Users reporting service failures

**Impact:** Service degradation or outage - users unable to complete requests.

**Possible Causes:**
- Dependency failure (database, external API)
- Application bug introduced in recent deployment
- Resource exhaustion (database connections, memory)
- Misconfiguration after change
- External service outage

---

**Diagnostic Steps:**

```bash
# 1. Check current error rate
curl -G http://localhost:9090/api/v1/query \
  --data-urlencode 'query=rate(http_server_requests_total{status_code=~"5..", instance=~"archify.app.*"}[5m])'

# 2. Check recent errors in logs
docker logs archify-app --tail 100 | grep -i "error\|exception"

# 3. Check recent deployments
git log --oneline --since="1 hour ago" -- archify.app/

# 4. Check dependency health
curl http://localhost:5432  # Database
curl http://localhost:9092  # Kafka
curl http://localhost:3567  # SuperTokens

# 5. Check resource usage
docker stats archify-app --no-stream

# 6. Check error distribution
# Grafana → Explore → Prometheus
# Query: sum by (status_code) (rate(http_server_requests_total{instance=~"archify.app.*"}[5m]))
```

---

**Resolution Steps:**

**If recent deployment caused issue:**
```bash
# Rollback to previous version
cd /var/www/GeniusSuite/archify.app/compose
git log --oneline -5  # Find last good commit
git checkout <commit-hash> ../

# Rebuild and restart
docker compose up -d --build

# Monitor error rate
watch -n 5 'curl -s http://localhost:9090/api/v1/query --data-urlencode "query=rate(http_server_requests_total{status_code=~\"5..\", instance=~\"archify.app.*\"}[5m])" | jq'
```

**If dependency down:**
```bash
# Identify failing dependency from logs
docker logs archify-app | grep -i "connection refused\|timeout"

# Restart dependency
docker restart postgres  # or kafka, or supertokens

# Wait for recovery
sleep 30

# Monitor service recovery
curl http://localhost:6500/health
```

**If resource exhaustion:**
```bash
# Check database connection pool
docker exec archify-app psql -U postgres -c "SELECT count(*) FROM pg_stat_activity;"

# If connections maxed out, restart application
docker restart archify-app

# Long-term: Increase connection pool limits
```

**If external service outage:**
```bash
# Check external API health (if applicable)
curl https://api.external-service.com/health

# If down, enable circuit breaker or fallback logic
# (Requires application code change)

# Temporary: Scale down traffic to reduce error impact
# (Wait for external service recovery)
```

---

**Prevention:**
- Deploy with canary releases (F0.5+)
- Implement circuit breakers for external dependencies
- Set up automated alerts for error rate > 5% (F0.4+)
- Monitor dependencies health continuously

**Related Dashboards:**
- Grafana → Explore → Prometheus → Query: `rate(http_server_requests_total{status_code=~"5..", instance=~"archify.app.*"}[5m])`
- Grafana → Explore → Loki → Query: `{container_name="archify-app"} |= "error"`

**Escalation:** If error rate stays above 5% for 15+ minutes, escalate to application team + page on-call

---

## Network & Connectivity

### Runbook 10: Service Cannot Reach OTEL Collector

**Symptom:**
- Application logs: `"failed to export trace"` or `"connection refused"`
- OTEL Collector not receiving telemetry from specific service
- Service metrics/logs working but traces missing

**Impact:** Distributed traces not collected for service - unable to debug cross-service requests.

**Possible Causes:**
- Service not on `geniuserp_net_observability` network
- Wrong OTEL endpoint in service configuration
- OTEL Collector container down
- Firewall or network policy blocking traffic

---

**Diagnostic Steps:**

```bash
# 1. Check service OTEL configuration
docker exec archify-app env | grep OTEL

# Expected:
# OTEL_EXPORTER_OTLP_ENDPOINT=http://geniuserp-otel-collector:4318
# OTEL_SERVICE_NAME=archify.app

# 2. Test connectivity from service container
docker exec archify-app curl http://geniuserp-otel-collector:4318

# 3. Check service networks
docker inspect archify-app | grep -A 10 Networks

# Should include: geniuserp_net_observability

# 4. Check OTEL Collector is running
docker ps | grep otel-collector

# 5. Check both on same network
docker network inspect geniuserp_net_observability | grep -E "archify-app|otel-collector"
```

---

**Resolution Steps:**

**If service not on observability network:**
```bash
# Edit docker-compose.yml
# Add network:
# networks:
#   - geniuserp_net_observability

# Recreate service
cd /var/www/GeniusSuite/archify.app/compose
docker compose down
docker compose up -d

# Verify network
docker inspect archify-app | grep -A 10 Networks
```

**If wrong OTEL endpoint:**
```bash
# Edit docker-compose.yml
# Change:
# OTEL_EXPORTER_OTLP_ENDPOINT=http://tempo:4318  # WRONG
# To:
# OTEL_EXPORTER_OTLP_ENDPOINT=http://geniuserp-otel-collector:4318  # CORRECT

# Restart service
docker restart archify-app

# Verify configuration
docker exec archify-app env | grep OTEL_EXPORTER
```

**If OTEL Collector down:**
```bash
# Start OTEL Collector
cd /var/www/GeniusSuite/shared/observability
docker compose -f compose/profiles/compose.dev.yml up -d otel-collector

# Wait for startup
sleep 10

# Verify running
docker ps | grep otel-collector
```

---

**Prevention:**
- Always include `geniuserp_net_observability` network in service configs
- Use correct OTEL endpoint: `http://geniuserp-otel-collector:4318`
- Run `validate.sh` after network changes

**Related Dashboards:** N/A (Tempo not deployed in F0.3)  
**Escalation:** If connectivity still failing after 10 minutes, escalate to network team

---

### Runbook 11: Docker Networks Missing

**Symptom:**
- `validate.sh` reports network checks failing
- Docker Compose fails to start: `network not found`
- Services cannot communicate

**Impact:** Critical - entire GeniusSuite may be down. Services isolated and unable to communicate.

**Possible Causes:**
- Networks deleted manually
- Docker daemon restarted (networks not persistent)
- `docker network prune` run accidentally

---

**Diagnostic Steps:**

```bash
# 1. List existing networks
docker network ls | grep geniuserp_net

# Expected: 4 networks
# geniuserp_net_edge
# geniuserp_net_suite_internal
# geniuserp_net_backing_services
# geniuserp_net_observability

# 2. Check which networks missing
bash scripts/validate.sh | grep "network"

# 3. Check if any services running
docker ps --format "{{.Names}}"
```

---

**Resolution Steps:**

**Create missing networks:**
```bash
# Create all 4 networks (idempotent - safe to run multiple times)
docker network create geniuserp_net_edge || true
docker network create geniuserp_net_suite_internal || true
docker network create geniuserp_net_backing_services || true
docker network create geniuserp_net_observability || true

# Verify creation
docker network ls | grep geniuserp_net

# Restart all services to reconnect
cd /var/www/GeniusSuite/shared/observability
bash scripts/install.sh dev

# Validate
bash scripts/validate.sh
```

---

**Prevention:**
- **Never run `docker network prune` in production**
- Use `external: true` in docker-compose.yml (already configured)
- Document network creation in deployment runbooks
- Consider network creation in startup scripts (F0.4+)

**Related Dashboards:** N/A (infrastructure down)  
**Escalation:** If networks cannot be created (permission issues), escalate to infrastructure team immediately

---

### Runbook 12: Port Conflicts

**Symptom:**
- Docker Compose fails: `port is already allocated`
- `validate.sh` reports port check failures
- Service cannot start

**Impact:** Service outage - unable to start affected service.

**Possible Causes:**
- Another container using same port
- Host process using port
- Previous container not cleaned up
- Wrong port in docker-compose.yml

---

**Diagnostic Steps:**

```bash
# 1. Check which port is conflicting (from error message)
# Example: "bind: address already in use :6500"

# 2. Find process using port
lsof -i :6500
# or
netstat -tulpn | grep 6500

# 3. Check if Docker container using port
docker ps --format "{{.Names}} {{.Ports}}" | grep 6500

# 4. Check for stopped containers
docker ps -a | grep 6500

# 5. Verify port assignment strategy
cat /var/www/GeniusSuite/Plan/Strategii\ de\ Fișiere.env\ și\ Porturi.md
```

---

**Resolution Steps:**

**If Docker container using port:**
```bash
# Stop conflicting container
docker stop <container-name>

# Or remove if not needed
docker rm -f <container-name>

# Start your service
docker compose up -d
```

**If host process using port:**
```bash
# Find process ID
lsof -i :6500 | grep LISTEN
# Example output: node 12345 user

# Kill process (if safe to do so)
kill -9 12345

# Or change service to use different port
export APP_PORT=6501
docker compose up -d
```

**If wrong port assigned:**
```bash
# Check Port Strategy document
cat /var/www/GeniusSuite/Plan/Strategii\ de\ Fișiere.env\ și\ Porturi.md

# Find correct port for service
# Update docker-compose.yml:
# ports:
#   - "6500:6500"  # Change to correct port

# Update prometheus.yml if needed:
# - targets:
#     - 'archify.app:6500'  # Change to match new port

# Restart services
docker compose down
docker compose up -d
```

---

**Prevention:**
- Follow Port Strategy (Tabelul 5) strictly
- Document port assignments in centralized location
- Use `validate.sh` to detect conflicts early
- Reserve ports before deploying new services

**Related Dashboards:** N/A  
**Escalation:** If port conflict cannot be resolved (system service using port), escalate to infrastructure team

---

## Data Collection Issues

### Runbook 13: Prometheus Data Loss

**Symptom:**
- Historical metrics missing in Grafana
- Prometheus shows gaps in time series
- Metrics reset to zero unexpectedly

**Impact:** Unable to analyze historical trends - impacts capacity planning and incident investigation.

**Possible Causes:**
- Prometheus container restarted with anonymous volume
- Volume not mounted correctly
- Disk full (data evicted)
- Prometheus retention period exceeded

---

**Diagnostic Steps:**

```bash
# 1. Check Prometheus data volume
docker volume inspect gs_prometheus_data

# 2. Check volume mount
docker inspect $(docker ps -qf name=prometheus) | grep -A 5 "gs_prometheus_data"

# 3. Check disk usage
df -h
docker system df -v

# 4. Check Prometheus retention settings
docker logs $(docker ps -qf name=prometheus) | grep -i "retention"

# 5. Query oldest data point
curl -G http://localhost:9090/api/v1/query \
  --data-urlencode 'query=up{job="genius_applications"}' \
  | jq '.data.result[0].value[0]'
```

---

**Resolution Steps:**

**If volume not mounted:**
```bash
# Check compose file has named volume
cat compose/profiles/compose.dev.yml | grep -A 3 "gs_prometheus_data"

# Should show:
# volumes:
#   gs_prometheus_data:
#     name: gs_prometheus_data

# If missing, add and recreate
docker compose -f compose/profiles/compose.dev.yml down
docker compose -f compose/profiles/compose.dev.yml up -d
```

**If disk full:**
```bash
# Clean up Docker resources
docker system prune -a --volumes

# Or increase retention period (reduce disk usage)
# Edit compose file, add to prometheus command:
# command:
#   - '--storage.tsdb.retention.time=7d'  # Reduce from 15d default

# Restart Prometheus
docker compose restart prometheus
```

**Data loss is permanent:**
- Historical data before restart is lost if volume was not persistent
- Configure named volumes to prevent future data loss (already done in F0.3)

---

**Prevention:**
- ✅ Use named volumes (already configured: `gs_prometheus_data`)
- Monitor disk space usage
- Set appropriate retention periods
- Implement backup strategy (F0.5+)

**Related Dashboards:**
- Grafana → Explore → Prometheus → Query: `up{job="genius_applications"}`

**Escalation:** Data loss cannot be recovered. Document incident and ensure prevention measures in place.

---

### Runbook 14: Loki Data Loss

**Symptom:**
- Historical logs missing in Grafana
- Loki queries return no results for past time ranges
- Recent logs visible but older logs missing

**Impact:** Unable to investigate past incidents - impacts RCA and compliance.

**Possible Causes:**
- Loki container restarted with anonymous volume
- Volume not mounted correctly
- Disk full (data evicted)
- Loki retention period exceeded

---

**Diagnostic Steps:**

```bash
# 1. Check Loki data volume
docker volume inspect gs_loki_data

# 2. Check volume mount
docker inspect $(docker ps -qf name=loki) | grep -A 5 "gs_loki_data"

# 3. Check disk usage
df -h
docker system df -v

# 4. Check Loki retention
docker logs $(docker ps -qf name=loki) | grep -i "retention"

# 5. Query oldest log entry
curl -G http://localhost:3100/loki/api/v1/query \
  --data-urlencode 'query={container_name=~".+-app"}' \
  --data-urlencode 'start=1700000000000000000' \
  | jq
```

---

**Resolution Steps:**

**If volume not mounted:**
```bash
# Check compose file has named volume
cat compose/profiles/compose.dev.yml | grep -A 3 "gs_loki_data"

# Should show:
# volumes:
#   gs_loki_data:
#     name: gs_loki_data

# If missing, add and recreate
docker compose -f compose/profiles/compose.dev.yml down
docker compose -f compose/profiles/compose.dev.yml up -d
```

**If disk full:**
```bash
# Clean up Docker resources
docker system prune --volumes

# Or configure retention limits in Loki config
# (Requires Loki config file update)
```

**Data loss is permanent:**
- Historical logs before restart are lost if volume was not persistent
- Configure named volumes to prevent future data loss (already done in F0.3)

---

**Prevention:**
- ✅ Use named volumes (already configured: `gs_loki_data`)
- Monitor disk space usage
- Set log retention policies
- Implement log archival strategy (F0.5+)

**Related Dashboards:**
- Grafana → Explore → Loki → Query: `{container_name=~".+-app"}`

**Escalation:** Data loss cannot be recovered. Document incident and ensure prevention measures in place.

---

### Runbook 15: validate.sh Failing

**Symptom:**
- `bash scripts/validate.sh` exits with non-zero code
- Validation output shows FAIL count > 0
- List of failing checks displayed

**Impact:** Unknown - depends on which checks are failing. Indicates infrastructure misconfiguration.

**Possible Causes:**
- Service not running
- Port misconfiguration
- Network missing
- Volume not created
- Health endpoint not responding

---

**Diagnostic Steps:**

```bash
# 1. Run validation with full output
cd /var/www/GeniusSuite/shared/observability
bash scripts/validate.sh

# Note which checks are failing

# 2. For port failures, check service status
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 3. For network failures, list networks
docker network ls | grep geniuserp_net

# 4. For volume failures, list volumes
docker volume ls | grep gs_

# 5. For health check failures, test endpoints
curl http://localhost:3000/metrics    # Grafana
curl http://localhost:9090/-/ready   # Prometheus
curl http://localhost:3100/ready     # Loki
```

---

**Resolution Steps:**

**Follow specific runbook based on failure type:**

| Failure Type | Runbook to Follow |
|--------------|-------------------|
| Port check failing | [Runbook 12: Port Conflicts](#runbook-12-port-conflicts) |
| Network missing | [Runbook 11: Docker Networks Missing](#runbook-11-docker-networks-missing) |
| Volume missing | Create volume: `docker volume create gs_<name>_data` |
| Health check failing | [Runbook 7: Service Health Check Failing](#runbook-7-service-health-check-failing) |
| Service not running | [Runbook 1: Observability Stack Not Starting](#runbook-1-observability-stack-not-starting) |

**General fix (restart everything):**
```bash
# Stop all services
cd /var/www/GeniusSuite/shared/observability
docker compose -f compose/profiles/compose.dev.yml down

# Create missing networks
docker network create geniuserp_net_edge || true
docker network create geniuserp_net_suite_internal || true
docker network create geniuserp_net_backing_services || true
docker network create geniuserp_net_observability || true

# Create missing volumes
docker volume create gs_prometheus_data || true
docker volume create gs_loki_data || true
docker volume create gs_grafana_data || true

# Start everything
bash scripts/install.sh dev

# Wait for initialization
sleep 30

# Revalidate
bash scripts/validate.sh
```

---

**Prevention:**
- Run `validate.sh` before and after infrastructure changes
- Integrate `validate.sh` into CI/CD pipeline (F0.4+)
- Monitor infrastructure health continuously

**Related Dashboards:** N/A  
**Escalation:** If validation still failing after following specific runbooks, escalate to platform team

---

## Escalation Procedures

### Escalation Levels

| Level | Criteria | Response Time | Contacts |
|-------|----------|---------------|----------|
| **L1 - Info** | Issue resolved by runbook | N/A | Self-service |
| **L2 - Team** | Issue persists 15+ min | 30 min | Team lead, team channel |
| **L3 - Platform** | Infrastructure issue | 15 min | Platform team, #platform-support |
| **L4 - Critical** | Production outage | 5 min | On-call engineer, page immediately |

---

### When to Escalate

**Escalate to L2 (Team):**
- Application-specific errors persisting after following runbook
- Error rate > 5% for 15+ minutes
- Service health checks failing repeatedly

**Escalate to L3 (Platform):**
- Observability infrastructure down (Prometheus, Loki, Grafana)
- Docker networks cannot be created (permission issues)
- Port conflicts with system services
- Disk space critically low (< 10%)

**Escalate to L4 (Critical):**
- Multiple services down simultaneously
- Data loss incident
- Security breach suspected
- External customer impact confirmed

---

### Escalation Template

```
**Incident:** [Brief description]
**Severity:** [L2/L3/L4]
**Started:** [Timestamp]
**Affected Services:** [List]
**Impact:** [User-facing impact description]
**Runbook Used:** [Runbook number/name]
**Steps Taken:** [Actions already performed]
**Current Status:** [What's happening now]
**Next Steps:** [What needs to be done]
```

---

## Appendix: Quick Reference

### Essential Commands

```bash
# Validate infrastructure
bash scripts/validate.sh

# Test all endpoints
bash scripts/smoke.sh

# Check container status
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# View container logs
docker logs <container-name> --tail 100 --since 10m

# Restart observability stack
docker compose -f compose/profiles/compose.dev.yml restart

# Full restart
docker compose -f compose/profiles/compose.dev.yml down
docker compose -f compose/profiles/compose.dev.yml up -d

# Create networks
docker network create geniuserp_net_edge
docker network create geniuserp_net_suite_internal
docker network create geniuserp_net_backing_services
docker network create geniuserp_net_observability

# Create volumes
docker volume create gs_prometheus_data
docker volume create gs_loki_data
docker volume create gs_grafana_data
```

---

### Key URLs

| Service | URL | Purpose |
|---------|-----|---------|
| Grafana | http://localhost:3000 | Dashboards & visualization |
| Prometheus | http://localhost:9090 | Metrics queries & targets |
| Loki | http://localhost:3100 | Log queries (API only) |
| OTEL Collector | http://localhost:4318 | Trace ingestion (HTTP) |
| OTEL Collector | http://localhost:4317 | Trace ingestion (gRPC) |

---

### Port Reference (Quick Lookup)

**Observability:**
- Grafana: 3000
- Loki: 3100
- Prometheus: 9090
- OTEL: 4317 (gRPC), 4318 (HTTP)

**Control Plane:**
- suite-shell: 6100
- suite-admin: 6150
- suite-login: 6200
- identity: 6250
- licensing: 6300
- analytics-hub: 6350
- ai-hub: 6400

**Stand-alone Apps:**
- archify: 6500
- cerniq: 6550
- flowxify: 6600
- i-wms: 6650
- mercantiq: 6700
- numeriqo: 6750
- triggerra: 6800
- vettify: 6850

---

## References

### Internal Documentation

- **Architecture:** `architecture.md`
- **Scripts Usage:** `../scripts/README.md`
- **How-to Guide:** `how-to-add-new-app(module).md`
- **Dashboards:** `dashboards.md`
- **Port Strategy:** `../../Plan/Strategii de Fișiere.env și Porturi.md`
- **Docker Strategy:** `../../Plan/Strategie Docker_ Volumuri, Rețele și Backup.md`

### External Resources

- [Docker Troubleshooting](https://docs.docker.com/config/daemon/)
- [Prometheus Troubleshooting](https://prometheus.io/docs/prometheus/latest/troubleshooting/)
- [Grafana Troubleshooting](https://grafana.com/docs/grafana/latest/troubleshooting/)
- [Loki Troubleshooting](https://grafana.com/docs/loki/latest/operations/)

---

**Last Updated:** 2024-11-13  
**Version:** 1.0.0 (F0.3 Skeleton)  
**Maintainer:** GeniusSuite DevOps Team

**Feedback:** If you encounter issues not covered by these runbooks, please document your resolution steps and open a PR to update this document.
