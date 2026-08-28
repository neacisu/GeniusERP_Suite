{{- /* CP Suite Admin stores DB DSN in KV */ -}}
{{- with secret "kv/data/cp/suite-admin" -}}
{
  "db_url": "{{ .Data.data.db_url }}"
}
{{- end -}}
