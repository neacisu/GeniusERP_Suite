FROM node:22-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV CI=true
RUN corepack enable
WORKDIR /app
COPY pnpm-lock.yaml ./

FROM base AS deps
COPY package.json pnpm-workspace.yaml ./
COPY vettify.app/package.json ./vettify.app/
COPY shared/common/package.json ./shared/common/
COPY shared/observability/package.json ./shared/observability/
RUN pnpm install --frozen-lockfile

FROM base AS builder
COPY . .
RUN pnpm install --frozen-lockfile
RUN pnpm --filter=@genius-suite/observability build && \
    pnpm --filter=@genius-suite/common build && \
    pnpm --filter=@genius-suite/vettify.app build

FROM base AS deploy
WORKDIR /app
COPY pnpm-workspace.yaml package.json pnpm-lock.yaml ./
COPY vettify.app/package.json ./vettify.app/
COPY shared/common/package.json ./shared/common/
COPY shared/observability/package.json ./shared/observability/
COPY --from=builder /app/shared ./shared
RUN pnpm deploy --filter=@genius-suite/vettify.app --prod --legacy --ignore-scripts /deploy


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
COPY --from=deploy --chown=appuser:nodejs /deploy /app
COPY --from=builder --chown=appuser:nodejs /app/vettify.app/dist /app/vettify.app/dist

# Copy OpenBao Agent configuration and templates
COPY --chown=appuser:nodejs /var/www/GeniusSuite/vettify.app/openbao/agent-config.hcl /openbao/
COPY --chown=appuser:nodejs /var/www/GeniusSuite/vettify.app/openbao/templates/ /openbao/templates/

# Copy Process Supervisor script
COPY --chown=appuser:nodejs /var/www/GeniusSuite/vettify.app/scripts/start-app.sh /app/scripts/
RUN chmod +x /app/scripts/start-app.sh

USER appuser
EXPOSE 6850

# Start OpenBao Agent (will exec start-app.sh after rendering secrets)
CMD ["bao", "agent", "-config", "/openbao/agent-config.hcl"]
