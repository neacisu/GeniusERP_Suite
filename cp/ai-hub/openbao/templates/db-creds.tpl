{{- /* Dynamic credentials for CP AI Hub (primary + vector DB) */ -}}
{
  "primary": {{- with secret "database/creds/cp_aihub_runtime" -}}
  {
    "username": "{{ .Data.username }}",
    "password": "{{ .Data.password }}",
    "lease_id": "{{ .LeaseID }}",
    "lease_duration": {{ .LeaseDuration }},
    "renewable": {{ .Renewable }}
  }
  {{- end -}},
  "vector": {{- with secret "database/creds/cp_aihub_vectors_runtime" -}}
  {
    "username": "{{ .Data.username }}",
    "password": "{{ .Data.password }}",
    "lease_id": "{{ .LeaseID }}",
    "lease_duration": {{ .LeaseDuration }},
    "renewable": {{ .Renewable }}
  }
  {{- end -}}
}
