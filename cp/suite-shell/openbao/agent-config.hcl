# OpenBao Agent Configuration for CP Suite Shell
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

# Persist KV payload that includes DB connection metadata
template {
  source      = "/openbao/templates/db-creds.tpl"
  destination = "/app/secrets/db-creds.json"
  perms       = "0600"
}

# Persist JWT secrets separately for audits
template {
  source      = "/openbao/templates/app-secrets.tpl"
  destination = "/app/secrets/app-secrets.json"
  perms       = "0600"
}

# Render runtime .env and start the Process Supervisor script
template {
  source      = "/openbao/templates/cp-suite-shell.env.tpl"
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
