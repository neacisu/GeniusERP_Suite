{{- /* Template for Geniuserp database credentials from OpenBao dynamic secrets */ -}}
{{- with secret "database/creds/geniuserp_runtime" -}}
{
  "username": "{{ .Data.username }}",
  "password": "{{ .Data.password }}",
  "lease_id": "{{ .LeaseID }}",
  "lease_duration": {{ .LeaseDuration }},
  "renewable": {{ .Renewable }}
}
{{- end -}}
