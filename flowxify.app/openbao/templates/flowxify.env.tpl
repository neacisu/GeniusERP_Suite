{{- /* Template for Flowxify .env file with all secrets injected */ -}}
{{- with secret "database/creds/flowxify_runtime" -}}
# Database credentials (dynamic from OpenBao)
FLOWXIFY_DB_USER={{ .Data.username }}
FLOWXIFY_DB_PASS={{ .Data.password }}
FLOWXIFY_DB_HOST=${SUITE_DB_POSTGRES_HOST}
FLOWXIFY_DB_PORT=${SUITE_DB_POSTGRES_PORT}
FLOWXIFY_DB_NAME=flowxify_db
{{- end }}

{{- with secret "kv/data/apps/flowxify" }}
# Application secrets (static from OpenBao KV)
FLOWXIFY_JWT_SECRET={{ .Data.data.jwt_secret }}
FLOWXIFY_API_KEY={{ .Data.data.api_key }}
FLOWXIFY_ENCRYPTION_KEY={{ .Data.data.encryption_key }}
{{- end }}

# Non-secret configuration (from environment)
FLOWXIFY_APP_PORT=${FLOWXIFY_APP_PORT}
FLOWXIFY_APP_NODE_ENV=${FLOWXIFY_APP_NODE_ENV:-production}
NODE_ENV=production
LOG_LEVEL=${FLOWXIFY_LOG_LEVEL:-info}
