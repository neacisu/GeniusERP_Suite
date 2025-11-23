{{- /* Template for Geniuserp .env file with all secrets injected */ -}}
{{- with secret "database/creds/geniuserp_runtime" -}}
# Database credentials (dynamic from OpenBao)
GENIUSERP_DB_USER={{ .Data.username }}
GENIUSERP_DB_PASS={{ .Data.password }}
GENIUSERP_DB_HOST=${SUITE_DB_POSTGRES_HOST}
GENIUSERP_DB_PORT=${SUITE_DB_POSTGRES_PORT}
GENIUSERP_DB_NAME=geniuserp_db
{{- end }}

{{- with secret "kv/data/apps/geniuserp" }}
# Application secrets (static from OpenBao KV)
GENIUSERP_JWT_SECRET={{ .Data.data.jwt_secret }}
GENIUSERP_API_KEY={{ .Data.data.api_key }}
GENIUSERP_ENCRYPTION_KEY={{ .Data.data.encryption_key }}
{{- end }}

# Non-secret configuration (from environment)
GENIUSERP_APP_PORT=${GENIUSERP_APP_PORT}
GENIUSERP_APP_NODE_ENV=${GENIUSERP_APP_NODE_ENV:-production}
NODE_ENV=production
LOG_LEVEL=${GENIUSERP_LOG_LEVEL:-info}
