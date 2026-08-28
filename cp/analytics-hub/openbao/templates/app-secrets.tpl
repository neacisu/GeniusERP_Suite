{{- /* Static secrets for CP Analytics Hub */ -}}
{{- with secret "kv/data/cp/analytics-hub" -}}
{
  "jwt_secret": "{{ .Data.data.jwt_secret }}",
  "clickhouse_pass": "{{ .Data.data.clickhouse_pass }}",
  "elasticsearch_pass": "{{ .Data.data.elasticsearch_pass }}",
  "mixpanel_key": "{{ .Data.data.mixpanel_key }}",
  "ga_key": "{{ .Data.data.ga_key }}",
  "hotjar_key": "{{ .Data.data.hotjar_key }}"
}
{{- end -}}
