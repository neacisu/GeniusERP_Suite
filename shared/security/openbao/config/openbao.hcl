ui = true

storage "file" {
  path = "/bao/file"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

api_addr = "http://0.0.0.0:8200"
cluster_addr = "http://127.0.0.1:8201"

telemetry {
  prometheus_retention_time = "24h"
  disable_hostname = true
}
