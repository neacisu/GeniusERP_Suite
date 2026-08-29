{{- /* Template for Triggerra .env file with all secrets injected */ -}}
{{- with secret "database/creds/triggerra_runtime" -}}
# Database credentials (dynamic from OpenBao)
TRIGGERRA_DB_USER={{ .Data.username }}
TRIGGERRA_DB_PASS={{ .Data.password }}
TRIGGERRA_DB_HOST=${SUITE_DB_POSTGRES_HOST}
TRIGGERRA_DB_PORT=${SUITE_DB_POSTGRES_PORT}
TRIGGERRA_DB_NAME=triggerra_db
{{- end }}

{{- with secret "kv/data/apps/triggerra" }}
# Application secrets (static from OpenBao KV)
TRIGGERRA_JWT_SECRET={{ .Data.data.jwt_secret }}
TRIGGERRA_API_KEY={{ .Data.data.api_key }}
TRIGGERRA_ENCRYPTION_KEY={{ .Data.data.encryption_key }}
{{- end }}

# Non-secret configuration (from environment)
TRIGGERRA_APP_PORT=${TRIGGERRA_APP_PORT}
TRIGGERRA_APP_NODE_ENV=${TRIGGERRA_APP_NODE_ENV:-production}
NODE_ENV=production
LOG_LEVEL=${TRIGGERRA_LOG_LEVEL:-info}
