# Genius Suite Observability Setup

This document describes the observability infrastructure for the Genius Suite, including tracing, logging, metrics, and monitoring stack.

## Overview

The observability stack includes:
- **Tracing**: OpenTelemetry with Jaeger for distributed tracing
- **Logging**: Pino with OTEL trace correlation
- **Metrics**: Prometheus client for application metrics
- **Monitoring**: Docker Compose stack with OTEL Collector, Jaeger, Prometheus, Grafana

## Core Modules

### Tracing (`shared/observability/traces/otel.ts`)
- Initializes OpenTelemetry SDK with auto-instrumentations
- Exports OTLP trace exporter to collector
- Use `startOtel()` to initialize tracing

### Logging (`shared/common/logger/pino.ts`)
- Pino logger with pretty printing in development
- Integrates OTEL trace ID for correlation
- Use `createLogger()` to get a logger instance

### Metrics (`shared/observability/metrics/recorders/prometheus.ts`)
- Prometheus client with default metrics collection
- Exports `registerMetricsRoute(app)` to add /metrics endpoint
- Exports `promClient` for custom metrics

## Usage

```typescript
import { startOtel, createLogger, registerMetricsRoute, promClient } from '@genius-suite/observability';

// Initialize tracing
await startOtel();

// Create logger
const logger = createLogger();

// Register metrics route (e.g., in Fastify)
registerMetricsRoute(app);

// Use custom metrics
const counter = new promClient.Counter({ name: 'requests_total', help: 'Total requests' });
counter.inc();
```

## Environment Variables

Set the following in your `.env`:

```bash
OTEL_SERVICE_NAME=genius-suite-service
OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318/v1/traces
```

## Running the Monitoring Stack

1. Start the observability services:
   ```bash
   docker-compose -f configs/docker-compose.observability.yml up -d
   ```

2. Or use the production stack (includes observability):
   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   ```

## Accessing Services

- **Jaeger UI**: http://localhost:16686
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin)
- **Metrics endpoint**: http://localhost:3000/metrics (on your app)

## Configuration Files

- `configs/otel-collector-config.yml`: OTEL Collector configuration
- `configs/prometheus.yml`: Prometheus scrape configuration
- `configs/grafana-dashboard.json`: Sample Grafana dashboard
- `configs/.env.observability.example`: Environment variables template