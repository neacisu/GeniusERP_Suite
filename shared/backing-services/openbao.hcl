# OpenBao 2.6.2 — config minimă (file storage). TLS și Namespace Sealing
# per tenant se completează după `bao operator init` (API namespaces, v2.6).
ui = true

storage "file" {
  path = "/openbao/file"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

api_addr     = "http://openbao:8200"
cluster_addr = "http://openbao:8201"
