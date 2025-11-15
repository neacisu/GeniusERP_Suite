# GeniusSuite Observability Reference

This guide summarizes how to instrument services and how to run the shared observability stack that powers metrics, logs, and traces across the suite.

## Stack Overview

- **Traces:** OpenTelemetry SDKs export OTLP data to `geniuserp-otel-collector` (Tempo integration is planned; traces are currently logged via the collector).
- **Metrics:** `prom-client` in every service plus Prometheus scraping (`shared/observability/compose/prometheus.yml`).
- **Logs:** Structured JSON logs collected by Promtail and stored inside Loki.
- **Visualization:** Grafana dashboards (provisioned via `dashboards/grafana/*`).

All services share the `geniuserp_net_observability` Docker network when running locally via `shared/observability/compose/profiles/compose.dev.yml`.

## Runtime Helpers

The `@genius-suite/observability` workspace package exposes the helpers every service should call:

### Tracing

```ts
import { initTracing } from '@genius-suite/observability';

await initTracing({ serviceName: 'archify.app' });
```

- Uses the OpenTelemetry Node SDK with auto-instrumentations.
- Honors `OTEL_EXPORTER_OTLP_ENDPOINT` (defaults to `http://localhost:4318/v1/traces`).

### Metrics

```ts
import { initMetrics, metricsHandler, promClient } from '@genius-suite/observability';

await initMetrics({ serviceName: 'archify.app' });

app.get('/metrics', async (_req, res) => {
  res.setHeader('Content-Type', promClient.contentType);
  res.send(await metricsHandler());
});
```

- `initMetrics` enables `prom-client` default collectors.
- `metricsHandler` serializes the registry for Prometheus/Grafana.
- `promClient` lets you register custom counters and histograms.

### Logging

Use the shared logger from `shared/common/logger/pino.ts` when you need structured logs with OTEL correlation IDs:

```ts
import { createLogger } from '../../shared/common/logger/pino';

const logger = createLogger();
logger.info({ event: 'bootstrap' }, 'Service started');
```

## Required Environment Variables

Set these either in your service-specific `.env` file or via the shell:

```bash
OTEL_SERVICE_NAME=archify.app
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318/v1/traces
```

The observability stack also expects `.observability.env`; copy `.observability.env.example` under `shared/observability/` and adjust ports if needed.

## Running the Stack Locally

```bash
cd shared/observability
bash scripts/install.sh dev       # docker compose up + readiness checks
bash scripts/validate.sh          # 38 infrastructure checks
bash scripts/smoke.sh             # endpoint smoke tests
```

Services started:
- OpenTelemetry Collector (`4317/4318`)
- Prometheus (`${OBS_PROMETHEUS_PORT:-9090}`)
- Grafana (`${OBS_GRAFANA_PORT:-3000}`)
- Loki (`${OBS_LOKI_PORT:-3100}`)
- Promtail (Docker socket scrape)

## Access Points

- **Grafana:** http://localhost:3000 (admin / admin)
- **Prometheus:** http://localhost:9090
- **Loki readiness:** http://localhost:3100/ready
- **Collector health:** http://localhost:4318

## Configuration Files

- `shared/observability/compose/profiles/compose.dev.yml` – docker-compose stack
- `shared/observability/compose/prometheus.yml` – Prometheus targets + rule files
- `shared/observability/metrics/rules/traefik.rules.yml` – sample alert rule (referenced by Prometheus)
- `shared/observability/logs/ingestion/promtail-config.yml` – Promtail scraping config
- `shared/observability/otel-config/otel-collector-config.yml` – OTEL Collector pipeline
- `shared/observability/.observability.env.example` – environment template

Keep this document updated whenever new components (Tempo, Alertmanager, prod compose profile, etc.) land so onboarding stays accurate.