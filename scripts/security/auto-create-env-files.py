#!/usr/bin/env python3
"""
Auto-update all compose files to remove hardcoded values and create .env.example files
"""
import os
import re
from pathlib import Path

# App configurations
APPS = {
    'flowxify': {'port': '6600', 'prefix': 'FLOWX'},
    'triggerra': {'port': '6650', 'prefix': 'TRIG'},
    'cerniq': {'port': '6800', 'prefix': 'CERN'},
    'i-wms': {'port': '6850', 'prefix': 'IWMS'},
    'vettify': {'port': '6900', 'prefix': 'VETT'},
    'geniuserp': {'port': '7000', 'prefix': 'GERP'},
}

CP_MODULES = {
    'identity': {'port': '6250', 'prefix': 'IDENT'},
    'licensing': {'port': '6300', 'prefix': 'LIC'},
    'suite-admin': {'port': '6350', 'prefix': 'SADMIN'},
    'suite-shell': {'port': '6400', 'prefix': 'SHELL'},
    'ai-hub': {'port': '6450', 'prefix': 'AIHUB'},
    'analytics-hub': {'port': '6550', 'prefix': 'ANHUB'},
}

def create_env_example(app_name, config):
    """Create .env.example file for an app"""
    prefix = config['prefix']
    port = config['port']
    
    content = f"""# {app_name.title()} Application Configuration
# Copy this file to .{app_name}.env and fill in the values
# NOTE: This file contains NON-SECRET configuration only
# SECRETS (DB passwords, JWT secrets, API keys) are injected via OpenBao Agent

# ============================================================================
# Container Configuration
# ============================================================================
{prefix}_CONTAINER_NAME=genius-suite-{app_name}-app
{prefix}_RESTART_POLICY=unless-stopped

# ============================================================================
# Application Ports
# ============================================================================
{prefix}_APP_PORT={port}
{prefix}_APP_METRICS_PORT={int(port) + 90}
{prefix}_APP_WORKER_PORT={int(port) + 1}

# ============================================================================
# Application Environment
# ============================================================================
{prefix}_APP_NODE_ENV=production
{prefix}_LOG_LEVEL=info
{prefix}_OTEL_SERVICE_NAME={app_name}.app

# ============================================================================
# OpenBao Agent Configuration
# ============================================================================
{prefix}_BAO_AGENT_CONFIG=/openbao/agent-config.hcl
{prefix}_APPROLE_ROLE_ID_PATH=../../.secrets/approle/{app_name}/role-id
{prefix}_APPROLE_SECRET_ID_PATH=../../.secrets/approle/{app_name}/secret-id

# ============================================================================
# Traefik Configuration
# ============================================================================
{prefix}_TRAEFIK_ENABLE=true
{prefix}_TRAEFIK_HOST={app_name}.${{SUITE_APP_DOMAIN:-geniuserp.app}}
{prefix}_TRAEFIK_ENTRYPOINT=websecure
{prefix}_TRAEFIK_TLS=true
{prefix}_TRAEFIK_CERTRESOLVER=letsencrypt
{prefix}_TRAEFIK_MIDDLEWARES=global-chain@file

# ============================================================================
# Health Check Configuration
# ============================================================================
{prefix}_HEALTHCHECK_INTERVAL=30s
{prefix}_HEALTHCHECK_TIMEOUT=10s
{prefix}_HEALTHCHECK_RETRIES=3
{prefix}_HEALTHCHECK_START_PERIOD=60s

# ============================================================================
# SECRETS - DO NOT DEFINE HERE!
# ============================================================================
# The following secrets are injected via OpenBao Agent:
# - {prefix}_DB_USER (dynamic from database/creds/{app_name}_runtime)
# - {prefix}_DB_PASS (dynamic from database/creds/{app_name}_runtime)
# - {prefix}_JWT_SECRET (static from kv/data/apps/{app_name})
# - {prefix}_API_KEY (static from kv/data/apps/{app_name})
# - {prefix}_ENCRYPTION_KEY (static from kv/data/apps/{app_name})
#
# These are rendered by OpenBao Agent into /app/secrets/.env
# DO NOT add them to this file!
"""
    return content

def main():
    for app_name, config in {**APPS, **CP_MODULES}.items():
        print(f"Processing {app_name}...")
        
        # Determine app directory
        if app_name in APPS:
            app_dir = Path(f"{app_name}.app")
        else:
            app_dir = Path(f"cp/{app_name}")
        
        if not app_dir.exists():
            print(f"  ⚠ Directory not found: {app_dir}")
            continue
        
        # Create .env.example
        env_file = app_dir / f".{app_name}.env.example"
        env_content = create_env_example(app_name, config)
        env_file.write_text(env_content)
        print(f"  ✓ Created {env_file}")
        
        # Copy to .env
        env_actual = app_dir / f".{app_name}.env"
        env_actual.write_text(env_content)
        print(f"  ✓ Created {env_actual}")

if __name__ == "__main__":
    main()
