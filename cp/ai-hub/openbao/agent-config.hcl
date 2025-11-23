# OpenBao Agent Configuration for CP AI Hub
pid_file = "/tmp/openbao-agent.pid"

auto_auth {
  method {
    type = "approle"
    config = {
      role_id_file_path               = "/openbao/role-id"
      secret_id_file_path             = "/openbao/secret-id"
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

# Capture dynamic credentials (primary + vector DB)
template {
  source      = "/openbao/templates/db-creds.tpl"
  destination = "/app/secrets/db-creds.json"
  perms       = "0600"
}

# Capture KV secrets
template {
  source      = "/openbao/templates/app-secrets.tpl"
  destination = "/app/secrets/app-secrets.json"
  perms       = "0600"
}

# Render runtime .env and boot Process Supervisor
template {
  source      = "/openbao/templates/cp-ai-hub.env.tpl"
  destination = "/app/secrets/.env"
  perms       = "0600"
  command_timeout = "0"
  exec {
    command = ["/app/scripts/start-app.sh"]
  }
}

vault {
  address = "http://openbao:8200"
}
