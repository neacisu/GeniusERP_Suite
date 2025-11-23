{{- /* Template for I-wms database credentials from OpenBao dynamic secrets */ -}}
{{- with secret "database/creds/i-wms_runtime" -}}
{
  "username": "{{ .Data.username }}",
  "password": "{{ .Data.password }}",
  "lease_id": "{{ .LeaseID }}",
  "lease_duration": {{ .LeaseDuration }},
  "renewable": {{ .Renewable }}
}
{{- end -}}
