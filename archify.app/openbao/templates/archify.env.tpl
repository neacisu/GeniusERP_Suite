{{- /* Template for Archify .env file with all secrets injected */ -}}
{{- with secret "database/creds/archify_runtime" -}}
# Database credentials (dynamic from OpenBao)
ARCHIFY_DB_USER={{ .Data.username }}
ARCHIFY_DB_PASS={{ .Data.password }}
ARCHIFY_DB_HOST=${SUITE_DB_POSTGRES_HOST}
ARCHIFY_DB_PORT=${SUITE_DB_POSTGRES_PORT}
ARCHIFY_DB_NAME=archify_db
{{- end }}

{{- with secret "kv/data/apps/archify" }}
# Application secrets (static from OpenBao KV)
ARCHIFY_JWT_SECRET={{ .Data.data.jwt_secret }}
ARCHIFY_API_KEY={{ .Data.data.api_key }}
ARCHIFY_ENCRYPTION_KEY={{ .Data.data.encryption_key }}
{{- end }}

# Non-secret configuration (from environment)
ARCHIFY_APP_PORT=${ARCHIFY_APP_PORT}
ARCHIFY_APP_NODE_ENV=${ARCHIFY_APP_NODE_ENV:-production}
NODE_ENV=production
LOG_LEVEL=${ARCHIFY_LOG_LEVEL:-info}
