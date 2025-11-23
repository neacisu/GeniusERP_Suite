{{- /* Static secrets for CP Suite Shell */ -}}
{{- with secret "kv/data/cp/suite-shell" -}}
{
  "jwt_secret": "{{ .Data.data.jwt_secret }}"
}
{{- end -}}
