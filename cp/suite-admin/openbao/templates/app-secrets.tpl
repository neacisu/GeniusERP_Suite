{{- /* Static secrets for CP Suite Admin */ -}}
{{- with secret "kv/data/cp/suite-admin" -}}
{
  "jwt_secret": "{{ .Data.data.jwt_secret }}",
  "audit_webhook_url": "{{ .Data.data.audit_webhook_url }}"
}
{{- end -}}
