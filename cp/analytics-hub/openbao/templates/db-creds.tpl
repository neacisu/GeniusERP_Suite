{{- /* Dynamic database credentials for CP Analytics Hub */ -}}
{{- with secret "database/creds/cp_analytics_runtime" -}}
{
  "username": "{{ .Data.username }}",
  "password": "{{ .Data.password }}",
  "lease_id": "{{ .LeaseID }}",
  "lease_duration": {{ .LeaseDuration }},
  "renewable": {{ .Renewable }}
}
{{- end -}}
