# Grafana Dashboards Documentation

**Purpose:** Documentation of available Grafana dashboards for GeniusSuite observability stack (F0.3 Skeleton Phase)  
**Audience:** Developers, DevOps, SRE teams  
**Last Updated:** 2024-11-13  
**Version:** 1.0.0 (F0.3 Skeleton)

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Dashboard Access](#dashboard-access)
3. [Available Dashboards](#available-dashboards)
4. [Common Panels & Metrics](#common-panels--metrics)
5. [Using Explore Mode](#using-explore-mode)
6. [Creating Custom Dashboards](#creating-custom-dashboards)
7. [Planned Dashboards (F0.4+)](#planned-dashboards-f04)
8. [Troubleshooting](#troubleshooting)

---

## Overview

### Current State (F0.3 Skeleton)

The F0.3 observability stack provides **foundational monitoring infrastructure** with:

- ✅ **Prometheus datasource** - Metrics collection from all services
- ✅ **Loki datasource** - Centralized log aggregation
- ✅ **Tempo datasource** - (Configured but not deployed yet)
- ✅ **Auto-provisioned datasources** - No manual configuration needed
- ⚠️ **Minimal pre-built dashboards** - Focus on data exploration via Explore mode

**Philosophy:** F0.3 prioritizes **data collection and validation** over pre-built dashboards. Teams should use **Explore mode** to query metrics/logs directly and create custom dashboards as needed.

### Dashboard Strategy

| Phase | Focus | Status |
|-------|-------|--------|
| **F0.3 (Current)** | Data collection, manual exploration | ✅ Complete |
| **F0.4** | Pre-built dashboards, alerting rules | 🔄 Planned |
| **F0.5** | Advanced dashboards, SLO tracking | 🔄 Planned |
| **F0.6** | Business metrics, custom visualizations | 🔄 Planned |

---

## Dashboard Access

### Accessing Grafana

**URL:** '[http]://localhost:3000'
**Default Credentials:**

- Username: `admin`
- Password: `admin` (change on first login in production)

**Environment Variables (optional override):**

```bash
OBS_GRAFANA_ADMIN_USER=admin
OBS_GRAFANA_ADMIN_PASS=admin
OBS_GRAFANA_PORT=3000
```

### First-Time Setup

1. **Access Grafana:**

   ```bash
   open http://localhost:3000
   # or
   curl http://localhost:3000/metrics  # Health check
   ```

2. **Verify Datasources:**
   - Go to **Configuration** → **Data Sources**
   - Verify 3 datasources exist:
     - ✅ Prometheus (default) - '[http]://prometheus:9090'
   - ✅ Loki - '[http]://loki:3100'
   - ⚠️ Tempo - '[http]://tempo:3200' (configured but service not deployed)

3. **Test Connectivity:**
   - Click each datasource
   - Click **"Save & Test"**
   - Expect: **"Data source is working"** (except Tempo in F0.3)

---

## Available Dashboards

### Current Dashboards (F0.3)

| Dashboard | Status | Description | Location |
|-----------|--------|-------------|----------|
| **None (Pre-built)** | N/A | Use Explore mode instead | N/A |

**Note:** F0.3 skeleton does **not include pre-built JSON dashboards**. The provisioning system is configured (`dashboards.yml` exists), but the directory is currently empty.

### Dashboard Provisioning Structure

```text
shared/observability/dashboards/
├── grafana/
│   ├── datasources.yml          # Auto-provisions Prometheus, Loki, Tempo
│   ├── dashboards.yml           # Dashboard provider config
│   └── dashboards/              # JSON dashboards (currently empty)
│       └── dashboards.yml       # Duplicate config (cleanup needed)
```

**Provisioning Config:**

- **Provider Name:** "Genius Suite Dashboards"
- **Folder:** Root (no subfolder)
- **Update Interval:** 60 seconds
- **Deletion:** Allowed (`disableDeletion: false`)

---

## Common Panels & Metrics

While F0.3 lacks pre-built dashboards, here are the **essential metrics and queries** to create your own panels:

### 1. Service Health Metrics

#### Panel: Services Up/Down Status

**Metric:** `up`  
**Query (PromQL):**

```promql
# All services status
up{job="genius_applications"}

# Specific service
up{job="genius_applications", instance=~"archify.app.*"}
```

**Visualization:** Stat panel  
**Thresholds:**

- Green: `1` (Up)
- Red: `0` (Down)

---

#### Panel: Request Rate per Service

**Metric:** `http_server_requests_total`  
**Query (PromQL):**

```promql
# Requests per second (5m rate)
rate(http_server_requests_total{job="genius_applications"}[5m])

# By service
sum by (service_name) (rate(http_server_requests_total[5m]))
```

**Visualization:** Graph (Time series)  
**Unit:** ops/sec

---

#### Panel: HTTP Error Rate

**Metric:** `http_server_requests_total`  
**Query (PromQL):**

```promql
# Error rate (4xx + 5xx) by service
sum by (service_name) (
  rate(http_server_requests_total{status_code=~"4..|5.."}[5m])
) / 
sum by (service_name) (
  rate(http_server_requests_total[5m])
) * 100
```

**Visualization:** Graph  
**Unit:** Percent (0-100)  
**Thresholds:**

- Green: < 1%
- Yellow: 1-5%
- Red: > 5%

---

#### Panel: Response Time (Latency) - p95

**Metric:** `http_server_request_duration_ms`  
**Query (PromQL):**

```promql
# p95 latency by service
histogram_quantile(0.95, 
  sum by (service_name, le) (
    rate(http_server_request_duration_ms_bucket[5m])
  )
)
```

**Visualization:** Graph  
**Unit:** milliseconds (ms)  
**Thresholds:**

- Green: < 200ms
- Yellow: 200-500ms
- Red: > 500ms

---

### 2. Infrastructure Metrics (Prometheus)

#### Panel: Prometheus Scrape Duration

**Query (PromQL):**

```promql
# Scrape duration by job
scrape_duration_seconds{job="genius_applications"}
```

**Visualization:** Graph  
**Unit:** seconds

---

#### Panel: Prometheus Active Targets

**Query (PromQL):**

```promql
# Count of active targets
count(up{job="genius_applications"} == 1)
```

**Visualization:** Stat  
**Expected Value:** 14 (6 CP services + 8 stand-alone apps)

---

### 3. Log Metrics (Loki)

#### Panel: Log Volume by Service

**Query (LogQL):**

```logql
# Logs per second by container
sum by (container_name) (
  rate({container_name=~".+-app"}[5m])
)
```

**Visualization:** Graph  
**Unit:** logs/sec

---

#### Panel: Error Logs Count

**Query (LogQL):**

```logql
# Error-level logs in last 5 minutes
sum(count_over_time({container_name=~".+-app"} |= "level" |= "error" [5m]))
```

**Visualization:** Stat  
**Thresholds:**

- Green: 0
- Yellow: 1-10
- Red: > 10

---

### 4. OTEL Collector Metrics

**Note:** OTEL Collector logs to stdout in F0.3. Metrics endpoint not exposed.

**Container Logs:**

```bash
docker logs geniuserp-otel-collector --tail 100
```

**Planned (F0.4):** Expose OTEL Collector metrics on port 8888.

---

### 5. Traefik Metrics (Reverse Proxy)

#### Panel: Traefik Request Rate

**Metric:** `traefik_entrypoint_requests_total`  
**Query (PromQL):**

```promql
# Requests per second
rate(traefik_entrypoint_requests_total[5m])
```

**Visualization:** Graph

---

#### Panel: Traefik Response Time

**Metric:** `traefik_entrypoint_request_duration_seconds`  
**Query (PromQL):**

```promql
# p95 latency
histogram_quantile(0.95, 
  rate(traefik_entrypoint_request_duration_seconds_bucket[5m])
)
```

**Visualization:** Graph  
**Unit:** seconds

---

## Using Explore Mode

**Recommended for F0.3:** Use Explore mode for ad-hoc queries instead of pre-built dashboards.

### Exploring Metrics (Prometheus)

1. **Open Explore:**
   - Click **Explore** icon (compass) in left sidebar
   - Select **Prometheus** datasource

2. **Example Queries:**

   **All services up:**

   ```promql
   up{job="genius_applications"}
   ```

   **CPU usage by service:**

   ```promql
   process_cpu_seconds_total{job="genius_applications"}
   ```

   **Memory usage:**

   ```promql
   process_resident_memory_bytes{job="genius_applications"}
   ```

3. **Visualization Options:**
   - **Table:** Best for current values
   - **Graph:** Best for time series
   - **Stat:** Best for single values

---

### Exploring Logs (Loki)

1. **Open Explore:**
   - Click **Explore** icon
   - Select **Loki** datasource

2. **Example Queries:**

   **All logs from archify.app:**

   ```logql
   {container_name="archify-app"}
   ```

   **Error logs across all services:**

   ```logql
   {container_name=~".+-app"} |= "level" |= "error"
   ```

   **Logs containing "OTEL":**

   ```logql
   {container_name=~".+-app"} |~ "(?i)otel"
   ```

   **Logs from last 5 minutes with rate:**

   ```logql
   rate({container_name="archify-app"}[5m])
   ```

3. **Log Parsing:**
   - Loki supports JSON log parsing automatically
   - Use `| json` to extract fields: `{container_name="archify-app"} | json | level="error"`

---

### Exploring Traces (Tempo - F0.4+)

**Status:** Tempo datasource configured but service not deployed in F0.3.

**Temporary Workaround:**

- Traces are logged to OTEL Collector stdout
- View traces: `docker logs geniuserp-otel-collector | grep -i trace`

**Planned (F0.4):**

- Deploy Tempo service
- Query traces via Grafana Explore
- Correlate traces with logs and metrics

---

## Creating Custom Dashboards

### Quick Start: Create Your First Dashboard

1. **Create New Dashboard:**
   - Click **"+"** → **Dashboard**
   - Click **"Add new panel"**

2. **Configure Panel (Example: Service Health):**
   - **Datasource:** Prometheus
   - **Query:** `up{job="genius_applications"}`
   - **Visualization:** Stat
   - **Panel Title:** "Services Status"
   - **Thresholds:**
     - Base: Red
     - 1: Green

3. **Save Dashboard:**
   - Click **Save** (disk icon)
   - Name: "GeniusSuite - Services Overview"
   - Folder: General
   - Click **Save**

---

### Dashboard Best Practices

#### 1. Organize by Service Layer

**Recommended Structure:**

- **Infrastructure Dashboard:** Prometheus, Loki, OTEL Collector health
- **Application Dashboard:** Per-service metrics (latency, errors, throughput)
- **Business Dashboard:** Domain-specific metrics (documents created, users active)

#### 2. Use Variables for Flexibility

**Example Variable (Service Selector):**

- **Name:** `service`
- **Type:** Query
- **Datasource:** Prometheus
- **Query:** `label_values(up{job="genius_applications"}, instance)`

**Usage in Queries:**

```promql
up{instance="$service"}
```

#### 3. Set Meaningful Thresholds

**SRE Golden Signals:**

- **Latency:** < 200ms (good), 200-500ms (warning), > 500ms (critical)
- **Error Rate:** < 1% (good), 1-5% (warning), > 5% (critical)
- **Saturation:** < 70% (good), 70-85% (warning), > 85% (critical)

#### 4. Add Links to Related Resources

**Panel Links:**

- Link to runbooks: `docs/runbooks.md#service-not-responding`
- Link to logs: Grafana Explore with Loki query pre-filled
- Link to source code: GitHub repository

---

### Exporting & Sharing Dashboards

#### Export to JSON

1. **Open Dashboard Settings:**
   - Click **Settings** (gear icon)
   - Go to **JSON Model**
   - Copy JSON

2. **Save to Repository:**

   ```bash
   # Save dashboard JSON
   cat > shared/observability/dashboards/grafana/dashboards/services-overview.json <<'EOF'
   {
     "dashboard": { ... },
     "overwrite": true
   }
   EOF
   ```

3. **Auto-provision on Restart:**
   - Grafana will auto-load dashboard from `dashboards/` directory
   - Update interval: 60 seconds

---

#### Import from JSON

1. **Import Dashboard:**
   - Click **"+"** → **Import**
   - Paste JSON or upload file
   - Click **Load**

2. **Configure:**
   - Select datasources (Prometheus, Loki)
   - Click **Import**

---

## Planned Dashboards (F0.4+)

### High-Priority Dashboards (F0.4)

| Dashboard | Description | ETA |
|-----------|-------------|-----|
| **GeniusSuite Overview** | High-level health of all services | F0.4 |
| **Service Details** | Per-service metrics (latency, errors, throughput) | F0.4 |
| **Infrastructure Health** | Prometheus, Loki, Tempo, OTEL Collector status | F0.4 |
| **Error Tracking** | Error rates and logs across all services | F0.4 |
| **Traefik Monitoring** | Reverse proxy performance and routing | F0.4 |

---

### Advanced Dashboards (F0.5+)

| Dashboard | Description | ETA |
|-----------|-------------|-----|
| **Database Performance** | PostgreSQL query performance, connections | F0.5 |
| **Kafka Monitoring** | Topic lag, consumer groups, broker health | F0.5 |
| **SLO Dashboard** | SLI tracking, error budgets | F0.5 |
| **Distributed Tracing** | Tempo-based trace analysis | F0.5 |
| **Cost Attribution** | Resource usage by service/team | F0.6 |
| **Business Metrics** | Domain KPIs (documents, users, transactions) | F0.6 |

---

## Troubleshooting

### Problem: "Data source is not working" (Prometheus)

**Symptoms:**

- Grafana shows "Data source is not working" error
- Queries return no data

**Diagnosis:**

```bash
# Check Prometheus is running
docker ps | grep prometheus

# Check Prometheus health
curl http://localhost:9090/-/ready

# Check Prometheus from Grafana network
docker exec -it $(docker ps -qf name=grafana) curl http://prometheus:9090/-/ready
```

**Solutions:**

1. Restart Prometheus: `docker compose -f compose/profiles/compose.dev.yml restart prometheus`
2. Check datasource URL in Grafana: Must be `http://prometheus:9090` (not `http://localhost:9090`)
3. Verify both containers are on `geniuserp_net_observability` network

---

### Problem: No Metrics Appearing in Queries

**Symptoms:**

- Query returns empty result
- Expected services don't show in `up` metric

**Diagnosis:**

```bash
# Check Prometheus targets
open http://localhost:9090/targets

# Check if scrape is successful
curl http://localhost:6500/metrics  # Test individual service
```

**Solutions:**

1. **Target Down:** Service not running or unhealthy

   ```bash
   docker ps | grep archify-app
   docker logs archify-app
   ```

2. **Wrong Port:** Check port in `prometheus.yml` matches service

   ```yaml
   # prometheus.yml
   - targets:
       - 'archify.app:6501'  # Should match PORT env var
   ```

3. **Network Issue:** Service not on `geniuserp_net_observability`

   ```bash
   docker inspect archify-app | grep -A 10 Networks
   ```

---

### Problem: Loki Logs Not Showing

**Symptoms:**

- Loki datasource works but queries return no logs
- Recent logs missing

**Diagnosis:**

```bash
# Check Promtail is running
docker ps | grep promtail

# Check Promtail logs
docker logs profiles-promtail-1 --tail 50

# Query Loki directly
curl -G http://localhost:3100/loki/api/v1/query \
  --data-urlencode 'query={container_name="archify-app"}'
```

**Solutions:**

1. **Promtail Not Running:**

   ```bash
   cd shared/observability
   docker compose -f compose/profiles/compose.dev.yml up -d promtail
   ```

2. **Docker Socket Not Mounted:**
   - Check `compose.dev.yml` has: `/var/run/docker.sock:/var/run/docker.sock:ro`

3. **Wrong Time Range:** Expand time range in Grafana (default: last 1h)

---

### Problem: Dashboard Not Auto-Loading

**Symptoms:**

- Dashboard JSON saved to `dashboards/` directory but not appearing in Grafana

**Diagnosis:**

```bash
# Check provisioning config
cat shared/observability/dashboards/grafana/dashboards.yml

# Check volume mount
docker inspect $(docker ps -qf name=grafana) | grep -A 5 "dashboards"

# Check Grafana logs
docker logs $(docker ps -qf name=grafana) | grep -i provision
```

**Solutions:**

1. **Restart Grafana:**

   ```bash
   docker compose -f compose/profiles/compose.dev.yml restart grafana
   ```

2. **Verify JSON Syntax:**

   ```bash
   jq . shared/observability/dashboards/grafana/dashboards/your-dashboard.json
   ```

3. **Check Provisioning Interval:** Dashboards reload every 60 seconds

---

### Problem: Tempo Not Working

**Expected (F0.3):** Tempo is configured but **not deployed** in skeleton phase.

**Status:**

- ✅ Datasource configured in `datasources.yml`
- ❌ Tempo container not in `compose.dev.yml`
- ✅ OTEL Collector logs traces to stdout

**Workaround:**

```bash
# View traces in OTEL Collector logs
docker logs geniuserp-otel-collector | grep -i "trace"
```

**Planned (F0.4):**

- Add Tempo service to `compose.dev.yml`
- Configure OTEL Collector to export traces to Tempo
- Enable trace queries in Grafana

---

## References

### Internal Documentation

- **Architecture:** `architecture.md`
- **Scripts Usage:** `../scripts/README.md`
- **How-to Guide:** `how-to-add-new-app(module).md`
- **Runbooks:** `runbooks.md`

### Configuration Files

- **Datasources:** `../dashboards/grafana/datasources.yml`
- **Dashboard Provisioning:** `../dashboards/grafana/dashboards.yml`
- **Prometheus Config:** `../compose/prometheus.yml`
- **Docker Compose:** `../compose/profiles/compose.dev.yml`

### External Resources

- [Grafana Documentation](https://grafana.com/docs/grafana/latest/)
- [PromQL Basics](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [LogQL Documentation](https://grafana.com/docs/loki/latest/query/)
- [Grafana Dashboards Library](https://grafana.com/grafana/dashboards/)

---

## Appendix: Example Dashboard Queries

### Complete Service Health Dashboard

> **Row 1: Service Status**

- Panel 1: Services Up/Down (Stat)

  ```promql
  count(up{job="genius_applications"} == 1)
  ```
  
- Panel 2: Service List (Table)

  ```promql
  up{job="genius_applications"}
  ```

> **Row 2: Performance Metrics**

- Panel 3: Request Rate (Graph)

  ```promql
  sum by (instance) (rate(http_server_requests_total[5m]))
  ```

- Panel 4: Error Rate (Graph)

  ```promql
  sum by (instance) (rate(http_server_requests_total{status_code=~"5.."}[5m]))
  ```

> **Row 3: Latency**

- Panel 5: p95 Latency (Graph)

  ```promql
  histogram_quantile(0.95, 
    sum by (instance, le) (rate(http_server_request_duration_ms_bucket[5m]))
  )
  ```

---

**Last Updated:** 2024-11-13  
**Version:** 1.0.0 (F0.3 Skeleton)  
**Maintainer:** GeniusSuite DevOps Team
