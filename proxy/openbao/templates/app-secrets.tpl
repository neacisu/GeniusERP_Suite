{{- $dashboard := secret "kv/data/infrastructure/proxy/dashboard-pass" -}}
{{- $cloudflare := secret "kv/data/infrastructure/proxy/cloudflare-token" -}}
{
  "dashboard_password": "{{ $dashboard.Data.data.dashboard_pass }}",
  "cloudflare_token": "{{ $cloudflare.Data.data.cloudflare_token }}"
}
