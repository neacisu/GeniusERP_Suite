# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy workspace files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml tsconfig.base.json ./

# Copy source from workspace root
COPY shared ./shared
COPY cp ./cp

# Install dependencies
# Install pnpm
RUN npm install -g pnpm

# Add pnpm to PATH
ENV PATH="/usr/local/bin:$PATH"

# Install all dependencies (including dev dependencies for building)
RUN pnpm install --frozen-lockfile

# Compile shared libraries and analytics-hub service
RUN pnpm --filter=@genius-suite/observability build && \
	pnpm --filter=@genius-suite/common build && \
	pnpm --filter=@genius-suite/cp-analytics-hub build

# Final stage: Use geniuserp/node-openbao for Process Supervisor
FROM geniuserp/node-openbao:local AS runner

ENV NODE_ENV=production
ENV BAO_AGENT_CONFIG=/openbao/agent-config.hcl

# Create necessary directories
RUN mkdir -p /app/secrets /app/scripts /openbao/templates && \
    addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 appuser && \
    chown -R appuser:nodejs /app /openbao

WORKDIR /app

# Copy built application
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/cp/analytics-hub/node_modules ./cp/analytics-hub/node_modules
COPY --from=builder /app/cp/analytics-hub/dist ./cp/analytics-hub/dist
COPY --from=builder /app/cp/analytics-hub/package.json ./cp/analytics-hub/package.json
COPY --from=builder /app/shared ./shared

# Copy OpenBao Agent configuration and templates
COPY --chown=appuser:nodejs cp/analytics-hub/openbao/agent-config.hcl /openbao/
COPY --chown=appuser:nodejs cp/analytics-hub/openbao/templates/ /openbao/templates/

# Copy Process Supervisor script
COPY --chown=appuser:nodejs cp/analytics-hub/scripts/start-app.sh /app/scripts/
RUN chmod +x /app/scripts/start-app.sh

USER appuser
EXPOSE 6350

# Start OpenBao Agent (will exec start-app.sh after rendering secrets)
CMD ["bao", "agent", "-config", "/openbao/agent-config.hcl"]