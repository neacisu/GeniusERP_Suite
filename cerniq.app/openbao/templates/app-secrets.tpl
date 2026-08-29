{{- /* Template for Cerniq application secrets from OpenBao KV */ -}}
{{- with secret "kv/data/apps/cerniq" -}}
{
  "jwt_secret": "{{ .Data.data.jwt_secret }}",
  "api_key": "{{ .Data.data.api_key }}",
  "encryption_key": "{{ .Data.data.encryption_key }}"
}
{{- end -}}
