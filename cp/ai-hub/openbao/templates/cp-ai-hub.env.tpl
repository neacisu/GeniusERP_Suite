{{- /* Combined .env template for CP AI Hub */ -}}
{{- with secret "database/creds/cp_aihub_runtime" -}}
CP_AI_DB_POSTGRES_URL=postgresql://{{ .Data.username }}:{{ .Data.password }}@${SUITE_DB_POSTGRES_HOST}:${SUITE_DB_POSTGRES_PORT}/ai_hub_db
{{- end }}
{{ with secret "database/creds/cp_aihub_vectors_runtime" -}}
CP_AI_RAG_VECTOR_DB_URL=postgresql://{{ .Data.username }}:{{ .Data.password }}@${SUITE_DB_POSTGRES_HOST}:${SUITE_DB_POSTGRES_PORT}/ai_vectors_db
{{- end }}

{{ with secret "kv/data/cp/ai-hub" -}}
CP_AI_AUTH_JWT_SECRET={{ .Data.data.jwt_secret }}
CP_AI_API_OPENAI_KEY={{ .Data.data.openai_key }}
CP_AI_API_ANTHROPIC_KEY={{ .Data.data.anthropic_key }}
CP_AI_API_GOOGLE_KEY={{ .Data.data.google_key }}
{{- end }}

# Non-secret configuration
CP_AI_APP_PORT=${CP_AI_APP_PORT}
CP_AI_APP_METRICS_PORT=${CP_AI_APP_METRICS_PORT}
CP_AI_APP_NODE_ENV=${CP_AI_APP_NODE_ENV}
CP_AI_AUTH_IDENTITY_URL=${CP_AI_AUTH_IDENTITY_URL}
CP_AI_API_OPENAI_MODEL=${CP_AI_API_OPENAI_MODEL}
CP_AI_API_ANTHROPIC_MODEL=${CP_AI_API_ANTHROPIC_MODEL}
CP_AI_API_GOOGLE_MODEL=${CP_AI_API_GOOGLE_MODEL}
CP_AI_RAG_ENABLED=${CP_AI_RAG_ENABLED}
CP_AI_RAG_EMBEDDINGS_MODEL=${CP_AI_RAG_EMBEDDINGS_MODEL}
CP_AI_INFERENCE_TIMEOUT=${CP_AI_INFERENCE_TIMEOUT}
CP_AI_INFERENCE_MAX_TOKENS=${CP_AI_INFERENCE_MAX_TOKENS}
CP_AI_OBS_OTEL_ENDPOINT=${CP_AI_OBS_OTEL_ENDPOINT}
CP_AI_OBS_SERVICE_NAME=${CP_AI_OBS_SERVICE_NAME}
CP_AI_OBS_METRICS_PORT=${CP_AI_OBS_METRICS_PORT}
SUITE_OBS_OTEL_COLLECTOR_GRPC_URL=${SUITE_OBS_OTEL_COLLECTOR_GRPC_URL}
LOG_LEVEL=${LOG_LEVEL:-info}
NODE_ENV=production
