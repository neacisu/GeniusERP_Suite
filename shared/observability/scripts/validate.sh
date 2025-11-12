#!/bin/bash

set -euo pipefail

# Change to the observability directory
cd "$(dirname "$0")/.."

echo "Starting observability stack..."
docker compose -f compose/profiles/compose.dev.yml up -d

echo "Waiting for services to start..."
sleep 10

echo "Checking Prometheus..."
if curl -f http://localhost:9090/-/ready; then
    echo "[OK] Prometheus is ready"
else
    echo "[FAIL] Prometheus is not ready"
    exit 1
fi

echo "Checking Grafana..."
if curl -f -u admin:admin http://localhost:3000/api/health; then
    echo "[OK] Grafana is healthy"
else
    echo "[FAIL] Grafana is not healthy"
    exit 1
fi

echo "Checking Loki..."
if curl -f http://localhost:3100/metrics; then
    echo "[OK] Loki is responding"
else
    echo "[FAIL] Loki is not responding"
    exit 1
fi

echo "Checking OTEL Collector..."
if curl -f http://localhost:4318/v1/traces; then
    echo "[OK] OTEL Collector is responding"
else
    echo "[FAIL] OTEL Collector is not responding"
    exit 1
fi

echo "Observability stack: OK"