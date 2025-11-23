{{- /* Template for Vettify application secrets from OpenBao KV */ -}}
{{- with secret "kv/data/apps/vettify" -}}
{
  "jwt_secret": "{{ .Data.data.jwt_secret }}",
  "api_key": "{{ .Data.data.api_key }}",
  "encryption_key": "{{ .Data.data.encryption_key }}"
}
{{- end -}}
