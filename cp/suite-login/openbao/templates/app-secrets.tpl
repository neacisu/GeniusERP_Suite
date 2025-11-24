{{- /* Static secrets for CP Suite Login */ -}}
{{- with secret "kv/data/cp/suite-login" -}}
{
  "jwt_secret": "{{ .Data.data.jwt_secret }}"
}
{{- end -}}
