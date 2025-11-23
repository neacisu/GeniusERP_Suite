{{- /* Template for Mercantiq .env file with all secrets injected */ -}}
{{- with secret "database/creds/mercantiq_runtime" -}}
# Database credentials (dynamic from OpenBao)
MERCANTIQ_DB_USER={{ .Data.username }}
MERCANTIQ_DB_PASS={{ .Data.password }}
MERCANTIQ_DB_HOST=${SUITE_DB_POSTGRES_HOST}
MERCANTIQ_DB_PORT=${SUITE_DB_POSTGRES_PORT}
MERCANTIQ_DB_NAME=mercantiq_db
{{- end }}

{{- with secret "kv/data/apps/mercantiq" }}
# Application secrets (static from OpenBao KV)
MERCANTIQ_JWT_SECRET={{ .Data.data.jwt_secret }}
MERCANTIQ_API_KEY={{ .Data.data.api_key }}
MERCANTIQ_ENCRYPTION_KEY={{ .Data.data.encryption_key }}
{{- end }}

# Non-secret configuration (from environment)
MERCANTIQ_APP_PORT=${MERCANTIQ_APP_PORT}
MERCANTIQ_APP_NODE_ENV=${MERCANTIQ_APP_NODE_ENV:-production}
NODE_ENV=production
LOG_LEVEL=${MERCANTIQ_LOG_LEVEL:-info}
