{{- /* Template for I-wms .env file with all secrets injected */ -}}
{{- with secret "database/creds/i-wms_runtime" -}}
# Database credentials (dynamic from OpenBao)
I_WMS_DB_USER={{ .Data.username }}
I_WMS_DB_PASS={{ .Data.password }}
I_WMS_DB_HOST=${SUITE_DB_POSTGRES_HOST}
I_WMS_DB_PORT=${SUITE_DB_POSTGRES_PORT}
I_WMS_DB_NAME=i-wms_db
{{- end }}

{{- with secret "kv/data/apps/i-wms" }}
# Application secrets (static from OpenBao KV)
I_WMS_JWT_SECRET={{ .Data.data.jwt_secret }}
I_WMS_API_KEY={{ .Data.data.api_key }}
I_WMS_ENCRYPTION_KEY={{ .Data.data.encryption_key }}
{{- end }}

# Non-secret configuration (from environment)
I_WMS_APP_PORT=${I_WMS_APP_PORT}
I_WMS_APP_NODE_ENV=${I_WMS_APP_NODE_ENV:-production}
NODE_ENV=production
LOG_LEVEL=${I_WMS_LOG_LEVEL:-info}
