# Database Credential Watchers

**Location:** `scripts/security/watchers/`

This folder hosts the OpenBao watcher utilities that keep dynamic database credentials fresh and observable.

## db-creds-renew.sh

`db-creds-renew.sh` performs a full renewal cycle across every role defined in `database/roles/roles.json` (or a comma-separated subset via `WATCHER_ROLES`). For each role it:

1. Lists active leases from `sys/leases/lookup/database/creds/<role>`.
2. Looks up TTL / renewability metadata.
3. Renews leases whose TTL is below the configurable threshold (`LEASE_THRESHOLD_SECONDS`, default 300s).
4. Emits Prometheus textfile metrics under `shared/observability/metrics/watchers/db-creds-renew.prom` so the observability stack can scrape health/expiration data.
5. Optionally sends `HUP` to the Process Supervisor (if `PROCESS_SUPERVISOR_PID_FILE` is provided) after at least one successful renewal.

> ℹ️ Lease IDs are never written to disk; the script keeps them only in memory to comply with F0.5.12 constraints.

### Usage

```bash
# Single cycle
BAO_ADDR=http://127.0.0.1:8200 \
BAO_TOKEN=$(jq -r '.root_token' .secrets/openbao-keys.json) \
./scripts/security/watchers/db-creds-renew.sh

# Continuous watcher (30s interval) for specific roles
WATCHER_ROLES="numeriqo_runtime,cp_aihub_runtime" \
WATCH_INTERVAL_SECONDS=30 \
./scripts/security/watchers/db-creds-renew.sh
```

Key environment variables:

| Variable | Description |
| --- | --- |
| `WATCHER_ROLES` | Optional comma-separated list of roles to monitor. Default: all roles from manifest. |
| `LEASE_THRESHOLD_SECONDS` | TTL threshold that marks a lease as expiring (default `300`). |
| `LEASE_RENEW_INCREMENT` | Renewal increment requested from OpenBao (default `3600`). |
| `WATCH_INTERVAL_SECONDS` | If `>0`, the watcher loops forever, sleeping this many seconds between cycles. |
| `PROCESS_SUPERVISOR_PID_FILE` | Optional PID file used to send `HUP` after renewals. |
| `METRICS_DIR` | Override for the Prometheus textfile directory (defaults to `shared/observability/metrics/watchers`). |

Metrics become available immediately once the first cycle runs and can be scraped through the existing observability stack (Prometheus → Grafana alerting).
