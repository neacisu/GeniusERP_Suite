#!/usr/bin/env python3
import os
import re

APPS = [
    "archify.app",
    "mercantiq.app",
    "flowxify.app",
    "triggerra.app",
    "cerniq.app",
    "i-wms.app",
    "vettify.app",
    "geniuserp.app",
    "cp/identity",
    "cp/licensing",
    "cp/suite-admin",
    "cp/suite-shell",
    "cp/ai-hub",
    "cp/analytics-hub"
]

TEMPLATE_RUNNER = """
# Final stage: Use geniuserp/node-openbao for Process Supervisor
FROM geniuserp/node-openbao:local AS runner

ENV NODE_ENV=production
ENV BAO_AGENT_CONFIG=/openbao/agent-config.hcl

# Create necessary directories
RUN mkdir -p /app/secrets /app/scripts /openbao/templates && \\
    addgroup --system --gid 1001 nodejs && \\
    adduser --system --uid 1001 appuser && \\
    chown -R appuser:nodejs /app /openbao

WORKDIR /app

# Copy built application
{copy_commands}

# Copy OpenBao Agent configuration and templates
COPY --chown=appuser:nodejs {app_dir}/openbao/agent-config.hcl /openbao/
COPY --chown=appuser:nodejs {app_dir}/openbao/templates/ /openbao/templates/

# Copy Process Supervisor script
COPY --chown=appuser:nodejs {app_dir}/scripts/start-app.sh /app/scripts/
RUN chmod +x /app/scripts/start-app.sh

USER appuser
EXPOSE {port}

# Start OpenBao Agent (will exec start-app.sh after rendering secrets)
CMD ["bao", "agent", "-config", "/openbao/agent-config.hcl"]
"""

def update_dockerfile(app_path):
    dockerfile_path = os.path.join(app_path, "Dockerfile")
    if not os.path.exists(dockerfile_path):
        print(f"Skipping {app_path}: Dockerfile not found")
        return

    print(f"Updating {dockerfile_path}...")
    
    with open(dockerfile_path, "r") as f:
        content = f.read()

    # Extract existing COPY commands from the runner stage (or deploy stage if runner is simple)
    # This is tricky because existing Dockerfiles might vary.
    # Let's look for COPY --from=builder and COPY --from=deploy
    
    copy_lines = []
    port = "3000" # Default
    
    # Simple parsing
    lines = content.splitlines()
    runner_start = -1
    
    for i, line in enumerate(lines):
        if "FROM" in line and "AS runner" in line:
            runner_start = i
        if "EXPOSE" in line:
            port = line.split()[1]
            
    if runner_start == -1:
        print(f"Warning: Could not find 'AS runner' stage in {dockerfile_path}")
        # Fallback: try to find the last stage
        # But we really want to replace the runner stage.
        return

    # Extract COPY commands from the existing runner stage
    # We assume the existing runner stage has the necessary COPYs
    # But wait, the existing runner stage might be:
    # COPY --from=builder --chown=appuser:nodejs /app/archify.app/dist ./dist
    # COPY --from=deploy --chown=appuser:nodejs /deploy/node_modules ./node_modules
    # COPY --from=deploy --chown=appuser:nodejs /deploy/package.json ./package.json
    
    # Let's just grep for COPY --from= in the whole file? No, that might include intermediate stages.
    # We need the ones in the runner stage.
    
    existing_runner_content = lines[runner_start:]
    for line in existing_runner_content:
        if line.strip().startswith("COPY --from="):
            copy_lines.append(line.strip())
            
    if not copy_lines:
        # Fallback for simple Dockerfiles or if we missed them
        print(f"Warning: No COPY --from commands found in runner stage for {app_path}")
        # Try to guess based on standard pattern
        app_name = os.path.basename(app_path)
        if app_path.startswith("cp/"):
            app_name = app_path.replace("cp/", "")
            
        copy_lines = [
            f"COPY --from=builder --chown=appuser:nodejs /app/{app_path}/dist ./dist",
            "COPY --from=deploy --chown=appuser:nodejs /deploy/node_modules ./node_modules",
            "COPY --from=deploy --chown=appuser:nodejs /deploy/package.json ./package.json"
        ]

    # Construct new runner stage
    app_dir_name = app_path # e.g. archify.app or cp/identity
    # But in Dockerfile context (root), cp/identity is just cp/identity
    
    new_runner = TEMPLATE_RUNNER.format(
        copy_commands="\n".join(copy_lines),
        app_dir=app_dir_name,
        port=port
    )
    
    # Replace the old runner stage
    # We keep everything up to runner_start
    new_content = "\n".join(lines[:runner_start]) + "\n" + new_runner
    
    with open(dockerfile_path, "w") as f:
        f.write(new_content)
        
    print(f"Updated {dockerfile_path}")

def main():
    base_dir = "/var/www/GeniusSuite"
    for app in APPS:
        update_dockerfile(os.path.join(base_dir, app))

if __name__ == "__main__":
    main()
