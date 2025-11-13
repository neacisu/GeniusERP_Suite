FROM node:22-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
WORKDIR /app
COPY pnpm-lock.yaml ./

FROM base AS deps
COPY pnpm-workspace.yaml package.json ./
COPY mercantiq.app/package.json ./mercantiq.app/
COPY shared/common/package.json ./shared/common/
COPY shared/observability/package.json ./shared/observability/
RUN pnpm install --frozen-lockfile

FROM base AS builder
COPY pnpm-workspace.yaml package.json ./
COPY mercantiq.app/package.json ./mercantiq.app/
COPY shared/common/package.json ./shared/common/
COPY shared/observability/package.json ./shared/observability/
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm --filter=@genius-suite/mercantiq.app build

FROM base AS deploy
WORKDIR /app
COPY pnpm-workspace.yaml package.json pnpm-lock.yaml ./
COPY mercantiq.app/package.json ./mercantiq.app/
COPY shared/common/package.json ./shared/common/
COPY shared/observability/package.json ./shared/observability/
COPY --from=builder /app/shared ./shared
RUN pnpm deploy --filter=@genius-suite/mercantiq.app --prod --legacy --ignore-scripts /deploy

FROM base AS runner
ENV NODE_ENV=production
WORKDIR /app
RUN apk add --no-cache curl && \
    addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 appuser
COPY --from=builder --chown=appuser:nodejs /app/mercantiq.app/dist ./dist
COPY --from=deploy --chown=appuser:nodejs /deploy/node_modules ./node_modules
COPY --from=deploy --chown=appuser:nodejs /deploy/package.json ./package.json
USER appuser
EXPOSE 6750
CMD ["node", "dist/mercantiq.app/src/index.js"]
