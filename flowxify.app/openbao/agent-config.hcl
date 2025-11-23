# OpenBao Agent Configuration for Flowxify Application
# This config enables auto-auth and template rendering for secret injection

pid_file = "/tmp/openbao-agent.pid"

# Auto-auth configuration using AppRole
auto_auth {
  method {
    type = "approle"
    
    config = {
      role_id_file_path = "/openbao/role-id"
      secret_id_file_path = "/openbao/secret-id"
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

# Template for database credentials (dynamic from OpenBao)
template {
  source      = "/openbao/templates/db-creds.tpl"
  destination = "/app/secrets/db-creds.json"
  perms       = "0600"
}

# Template for application secrets (static from KV)
template {
  source      = "/openbao/templates/app-secrets.tpl"
  destination = "/app/secrets/app-secrets.json"
  perms       = "0600"
}

# Template for combined .env file
template {
  source      = "/openbao/templates/flowxify.env.tpl"
  destination = "/app/secrets/.env"
  perms       = "0600"
  
  # Execute command after template is rendered
  exec {
    command = ["/app/scripts/start-app.sh"]
  }
}

# OpenBao server configuration
vault {
  address = "http://openbao:8200"
}
