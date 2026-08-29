{{- /* Static secrets for CP Identity */ -}}
{{- with secret "kv/data/cp/identity" -}}
{
  "supertokens_api_key": "{{ .Data.data.supertokens_api_key }}",
  "jwt_secret": "{{ .Data.data.jwt_secret }}",
  "oidc_client_secret": "{{ .Data.data.oidc_client_secret }}"
}
{{- end -}}
