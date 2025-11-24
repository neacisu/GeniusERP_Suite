FROM node:24-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV CI=true
RUN corepack enable
WORKDIR /app
COPY pnpm-lock.yaml ./

FROM base AS deps
COPY pnpm-workspace.yaml package.json ./
COPY cp/suite-login/package.json ./cp/suite-login/
COPY shared/common/package.json ./shared/common/
COPY shared/observability/package.json ./shared/observability/
RUN pnpm install --frozen-lockfile

FROM base AS builder
COPY . .
RUN pnpm install --frozen-lockfile
RUN pnpm --filter=@genius-suite/observability build && \
	pnpm --filter=@genius-suite/common build && \
	pnpm --filter=@genius-suite/cp-suite-login build

FROM base AS deploy
WORKDIR /app
COPY pnpm-workspace.yaml package.json pnpm-lock.yaml ./
COPY cp/suite-login/package.json ./cp/suite-login/
COPY shared/common/package.json ./shared/common/
COPY shared/observability/package.json ./shared/observability/
COPY --from=builder /app/shared ./shared
RUN pnpm deploy --filter=@genius-suite/cp-suite-login --prod --legacy --ignore-scripts /deploy

FROM geniuserp/node-openbao:local AS runner

ENV NODE_ENV=production
ENV BAO_AGENT_CONFIG=/openbao/agent-config.hcl

RUN mkdir -p /app/secrets /app/scripts /openbao/templates && \
	addgroup --system --gid 1001 nodejs && \
	adduser --system --uid 1001 appuser && \
	chown -R appuser:nodejs /app /openbao

WORKDIR /app

# Copy built application
COPY --from=builder --chown=appuser:nodejs /app/cp/suite-login/dist ./dist
COPY --from=deploy --chown=appuser:nodejs /deploy/node_modules ./node_modules
COPY --from=deploy --chown=appuser:nodejs /deploy/package.json ./package.json

# Copy OpenBao Agent configuration and templates
COPY --chown=appuser:nodejs cp/suite-login/openbao/agent-config.hcl /openbao/
COPY --chown=appuser:nodejs cp/suite-login/openbao/templates/ /openbao/templates/

# Copy Process Supervisor script
COPY --chown=appuser:nodejs cp/suite-login/scripts/start-app.sh /app/scripts/
RUN chmod +x /app/scripts/start-app.sh

USER appuser
EXPOSE 6200

# Start OpenBao Agent which will exec the application after rendering secrets
CMD ["bao", "agent", "-config", "/openbao/agent-config.hcl"]
