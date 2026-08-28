{{- /* Static secrets for CP Licensing */ -}}
{{- with secret "kv/data/cp/licensing" -}}
{
  "jwt_secret": "{{ .Data.data.jwt_secret }}",
  "master_key": "{{ .Data.data.master_key }}",
  "stripe_secret_key": "{{ .Data.data.stripe_secret_key }}",
  "stripe_webhook_secret": "{{ .Data.data.stripe_webhook_secret }}",
  "paddle_api_key": "{{ .Data.data.paddle_api_key }}"
}
{{- end -}}
