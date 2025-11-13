FROM node:22-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
WORKDIR /app
COPY pnpm-lock.yaml ./

FROM base AS deps
COPY pnpm-workspace.yaml package.json ./
COPY cerniq.app/package.json ./cerniq.app/
COPY shared/common/package.json ./shared/common/
COPY shared/observability/package.json ./shared/observability/
RUN pnpm install --frozen-lockfile

FROM base AS builder
COPY . .
RUN pnpm install --frozen-lockfile
RUN pnpm --filter=@genius-suite/cerniq.app build

FROM base AS deploy
WORKDIR /app
COPY pnpm-workspace.yaml package.json pnpm-lock.yaml ./
COPY cerniq.app/package.json ./cerniq.app/
COPY shared/common/package.json ./shared/common/
COPY shared/observability/package.json ./shared/observability/
COPY --from=builder /app/shared ./shared
RUN pnpm deploy --filter=@genius-suite/cerniq.app --prod --legacy --ignore-scripts /deploy

FROM base AS runner
ENV NODE_ENV=production
WORKDIR /app
RUN apk add --no-cache curl && \
    addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 appuser
COPY --from=builder --chown=appuser:nodejs /app/cerniq.app/dist ./dist
COPY --from=deploy --chown=appuser:nodejs /deploy/node_modules ./node_modules
COPY --from=deploy --chown=appuser:nodejs /deploy/package.json ./package.json
USER appuser
EXPOSE 6550
CMD ["node", "dist/cerniq.app/src/index.js"]
