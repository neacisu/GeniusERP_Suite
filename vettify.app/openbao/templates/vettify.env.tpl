{{- /* Template for Vettify .env file with all secrets injected */ -}}
{{- with secret "database/creds/vettify_runtime" -}}
# Database credentials (dynamic from OpenBao)
VETTIFY_DB_USER={{ .Data.username }}
VETTIFY_DB_PASS={{ .Data.password }}
VETTIFY_DB_HOST=${SUITE_DB_POSTGRES_HOST}
VETTIFY_DB_PORT=${SUITE_DB_POSTGRES_PORT}
VETTIFY_DB_NAME=vettify_db
{{- end }}

{{- with secret "kv/data/apps/vettify" }}
# Application secrets (static from OpenBao KV)
VETTIFY_JWT_SECRET={{ .Data.data.jwt_secret }}
VETTIFY_API_KEY={{ .Data.data.api_key }}
VETTIFY_ENCRYPTION_KEY={{ .Data.data.encryption_key }}
{{- end }}

# Non-secret configuration (from environment)
VETTIFY_APP_PORT=${VETTIFY_APP_PORT}
VETTIFY_APP_NODE_ENV=${VETTIFY_APP_NODE_ENV:-production}
NODE_ENV=production
LOG_LEVEL=${VETTIFY_LOG_LEVEL:-info}
