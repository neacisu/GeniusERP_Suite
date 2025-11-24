{{- with secret "kv/data/infrastructure/proxy/dashboard-pass" -}}
PROXY_DASHBOARD_PASS={{ .Data.data.dashboard_pass }}
{{- end }}
{{- with secret "kv/data/infrastructure/proxy/cloudflare-token" -}}
PROXY_CF_API_TOKEN={{ .Data.data.cloudflare_token }}
{{- end }}
