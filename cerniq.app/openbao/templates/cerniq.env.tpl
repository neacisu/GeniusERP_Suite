{{- /* Template for Cerniq .env file with all secrets injected */ -}}
{{- with secret "database/creds/cerniq_runtime" -}}
# Database credentials (dynamic from OpenBao)
CERNIQ_DB_USER={{ .Data.username }}
CERNIQ_DB_PASS={{ .Data.password }}
CERNIQ_DB_HOST=${SUITE_DB_POSTGRES_HOST}
CERNIQ_DB_PORT=${SUITE_DB_POSTGRES_PORT}
CERNIQ_DB_NAME=cerniq_db
{{- end }}

{{- with secret "kv/data/apps/cerniq" }}
# Application secrets (static from OpenBao KV)
CERNIQ_JWT_SECRET={{ .Data.data.jwt_secret }}
CERNIQ_API_KEY={{ .Data.data.api_key }}
CERNIQ_ENCRYPTION_KEY={{ .Data.data.encryption_key }}
{{- end }}

# Non-secret configuration (from environment)
CERNIQ_APP_PORT=${CERNIQ_APP_PORT}
CERNIQ_APP_NODE_ENV=${CERNIQ_APP_NODE_ENV:-production}
NODE_ENV=production
LOG_LEVEL=${CERNIQ_LOG_LEVEL:-info}
