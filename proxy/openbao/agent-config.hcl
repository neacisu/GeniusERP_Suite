# OpenBao Agent Configuration for Traefik Proxy
pid_file = "/tmp/openbao-agent.pid"

auto_auth {
  method {
    type = "approle"
    config = {
      role_id_file_path                   = "/openbao/role-id"
      secret_id_file_path                 = "/openbao/secret-id"
      remove_secret_id_file_after_reading = false
    }
  }

  sink {
    type = "file"
    config = {
      path = "/tmp/openbao-token"
    }
  }
}

# Persist raw KV secrets for debugging
template {
  source      = "/openbao/templates/app-secrets.tpl"
  destination = "/app/secrets/app-secrets.json"
  perms       = "0600"
}

# Render runtime env file and start Process Supervisor script
template {
  source      = "/openbao/templates/proxy.env.tpl"
  destination = "/app/secrets/.env"
  perms       = "0600"
  command_timeout = "0"
  exec {
    command = ["/app/scripts/start-traefik.sh"]
  }
}

vault {
  address = "http://openbao:8200"
}
