{{- /* Combined .env template for CP Licensing */ -}}
{{- with secret "database/creds/cp_licensing_runtime" -}}
CP_LIC_DB_POSTGRES_URL=postgresql://{{ .Data.username }}:{{ .Data.password }}@${SUITE_DB_POSTGRES_HOST}:${SUITE_DB_POSTGRES_PORT}/licensing_db
{{- end }}

{{ with secret "kv/data/cp/licensing" -}}
CP_LIC_AUTH_JWT_SECRET={{ .Data.data.jwt_secret }}
CP_LIC_MASTER_KEY={{ .Data.data.master_key }}
CP_LIC_API_STRIPE_SECRET_KEY={{ .Data.data.stripe_secret_key }}
CP_LIC_API_STRIPE_WEBHOOK_SECRET={{ .Data.data.stripe_webhook_secret }}
CP_LIC_API_PADDLE_API_KEY={{ .Data.data.paddle_api_key }}
{{- end }}

# Non-secret configuration
CP_LIC_APP_PORT=${CP_LIC_APP_PORT}
CP_LIC_APP_METRICS_PORT=${CP_LIC_APP_METRICS_PORT}
CP_LIC_APP_NODE_ENV=${CP_LIC_APP_NODE_ENV}
CP_LIC_AUTH_IDENTITY_URL=${CP_LIC_AUTH_IDENTITY_URL}
CP_LIC_VALIDATION_URL=${CP_LIC_VALIDATION_URL}
CP_LIC_CHECK_INTERVAL_HOURS=${CP_LIC_CHECK_INTERVAL_HOURS}
CP_LIC_CACHE_REDIS_URL=${CP_LIC_CACHE_REDIS_URL}
CP_LIC_OBS_OTEL_ENDPOINT=${CP_LIC_OBS_OTEL_ENDPOINT}
CP_LIC_OBS_SERVICE_NAME=${CP_LIC_OBS_SERVICE_NAME}
CP_LIC_OBS_METRICS_PORT=${CP_LIC_OBS_METRICS_PORT}
SUITE_OBS_OTEL_COLLECTOR_GRPC_URL=${SUITE_OBS_OTEL_COLLECTOR_GRPC_URL}
LOG_LEVEL=${LOG_LEVEL:-info}
NODE_ENV=production
