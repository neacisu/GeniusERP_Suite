{{- /* Static secrets for CP AI Hub */ -}}
{{- with secret "kv/data/cp/ai-hub" -}}
{
  "jwt_secret": "{{ .Data.data.jwt_secret }}",
  "openai_key": "{{ .Data.data.openai_key }}",
  "anthropic_key": "{{ .Data.data.anthropic_key }}",
  "google_key": "{{ .Data.data.google_key }}"
}
{{- end -}}
