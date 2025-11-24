# OpenBao Agent Configuration for CP Suite Login
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

# Persist static secrets snapshot for debugging
template {
  source      = "/openbao/templates/app-secrets.tpl"
  destination = "/app/secrets/app-secrets.json"
  perms       = "0600"
}

# Render runtime .env and launch Process Supervisor script
template {
  source      = "/openbao/templates/cp-suite-login.env.tpl"
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
