# OpenBao Monitoring & Observability

## Overview

This document details the observability stack for OpenBao, including metrics collection, alerts, and dashboards.

## Architecture

- **Source**: OpenBao Telemetry (`/v1/sys/metrics`)
- **Collector**: Prometheus (Job: `openbao`)
- **Visualization**: Grafana (Dashboard: `OpenBao Overview`)
- **Alerting**: Prometheus AlertManager

## Metrics

We collect standard Go runtime metrics and OpenBao-specific metrics:

| Metric | Description |
|--------|-------------|
| `vault_core_sealed` | 1 if sealed, 0 if unsealed |
| `vault_core_active` | 1 if active node, 0 if standby |
| `vault_expire_num_leases` | Number of active leases |
| `vault_core_handle_request_count` | Total request count (by method/path) |
| `vault_route_rollback_errors` | Number of rollback errors |

## Alerts

Defined in `shared/observability/metrics/rules/openbao.rules.yml`:

### Critical
- **OpenBaoDown**: OpenBao instance is unreachable.
- **OpenBaoSealed**: OpenBao is sealed and cannot serve requests.

### Warning
- **OpenBaoHighErrorRate**: Error rate > 10% over 5 minutes.
- **OpenBaoHighLeaseCount**: Active leases > 1000 (capacity warning).

## Dashboards

### OpenBao Overview

Located at `shared/observability/dashboards/grafana/dashboards/openbao.json`.

**Panels:**
1. **Sealed Status**: Instant view of seal state.
2. **Active Leases**: Trend of lease usage.
3. **Request Rate**: Throughput by method.
4. **Error Rate**: Failed requests over time.

## Troubleshooting

### Missing Metrics
- Verify `telemetry` block in `openbao.hcl`.
- Check Prometheus targets: `http://localhost:9090/targets`.
- Ensure OpenBao is unsealed (metrics might be limited if sealed).

### Alert Firing
- **Sealed**: Run `bao operator unseal`.
- **High Lease Count**: Check for lease leaks or high traffic.
