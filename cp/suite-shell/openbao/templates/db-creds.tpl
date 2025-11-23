{{- /* CP Suite Shell stores DB DSN inside KV */ -}}
{{- with secret "kv/data/cp/suite-shell" -}}
{
  "db_url": "{{ .Data.data.db_url }}"
}
{{- end -}}
