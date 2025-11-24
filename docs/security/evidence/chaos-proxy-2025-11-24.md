# Proxy Chaos Test — 2025-11-24

- Command: `scripts/security/test-f05-chaos.sh proxy`
- AppRole env: `PROXY_APPROLE_ROLE_ID_PATH=.secrets/approle/proxy/role-id`, `PROXY_APPROLE_SECRET_ID_PATH=.secrets/approle/proxy/secret-id`
- Compose stack: `compose.yml`
- Result: secrets rendered, proxy survived the OpenBao outage, OpenBao auto-unsealed and proxy stayed healthy after recovery.

## Console Log

```text
═══════════════════════════════════════════════════════
  F0.5 Chaos Testing: proxy
═══════════════════════════════════════════════════════

▶ Ensuring proxy service is running...
WARN[0000] volume "gs_traefik_certs" already exists but was not created by Docker Compose. Use `external: true` to use an existing volume
[+] Running 1/1
 ✔ Container traefik  Running0.0s 
[1/3] Verifying secret injection...
  ✓ Secret artifact present (/run/traefik/secrets/dashboard-users)

[2/3] Simulating OpenBao outage...
  Stopping OpenBao container...
[+] Stopping 1/1
 ✔ Container geniuserp-openbao  Stopped0.6s  
  ✓ proxy container stayed up while OpenBao was offline

[3/3] Recovery and auto-unseal...
[+] Running 1/1
 ✔ Container geniuserp-openbao  Started0.2s  
[OpenBao Init] Checking OpenBao status at http://127.0.0.1:8200...
[OpenBao Init] OpenBao is already initialized.
[OpenBao Init] OpenBao is sealed. Attempting unseal...
[OpenBao Init] Unseal successful.
[OpenBao Init] OpenBao is ready and operational.
  ✓ proxy container healthy after OpenBao recovery

✓ Chaos test sequence completed for proxy.
```
