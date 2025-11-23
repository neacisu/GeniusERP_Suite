{{- /* Template for Numeriqo application secrets from OpenBao KV */ -}}
{{- with secret "kv/data/apps/numeriqo" -}}
{
  "jwt_secret": "{{ .Data.data.jwt_secret }}",
  "api_key": "{{ .Data.data.api_key }}",
  "encryption_key": "{{ .Data.data.encryption_key }}"
}
{{- end -}}
