{{- /* Template for Numeriqo .env file with all secrets injected */ -}}
{{- with secret "database/creds/numeriqo_runtime" -}}
# Database credentials (dynamic from OpenBao)
NUMQ_DB_USER={{ .Data.username }}
NUMQ_DB_PASS={{ .Data.password }}
NUMQ_DB_HOST=${SUITE_DB_POSTGRES_HOST}
NUMQ_DB_PORT=${SUITE_DB_POSTGRES_PORT}
NUMQ_DB_NAME=numeriqo_db
{{- end }}

{{- with secret "kv/data/apps/numeriqo" }}
# Application secrets (static from OpenBao KV)
NUMQ_JWT_SECRET={{ .Data.data.jwt_secret }}
NUMQ_API_KEY={{ .Data.data.api_key }}
NUMQ_ENCRYPTION_KEY={{ .Data.data.encryption_key }}
{{- end }}

# Non-secret configuration (from environment)
NUMQ_APP_PORT=${NUMQ_APP_PORT:-6750}
NUMQ_APP_METRICS_PORT=${NUMQ_APP_METRICS_PORT:-9090}
NUMQ_APP_NODE_ENV=${NUMQ_APP_NODE_ENV:-production}
NODE_ENV=production
LOG_LEVEL=info
