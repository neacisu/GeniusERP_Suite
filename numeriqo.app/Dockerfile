FROM node:22-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV CI=true
RUN corepack enable
WORKDIR /app
COPY pnpm-lock.yaml ./

FROM base AS deps
COPY package.json pnpm-workspace.yaml ./
COPY numeriqo.app/package.json ./numeriqo.app/
COPY shared/common/package.json ./shared/common/
COPY shared/observability/package.json ./shared/observability/
RUN pnpm install --frozen-lockfile

FROM base AS builder
COPY . .
RUN pnpm install --frozen-lockfile
RUN pnpm --filter=@genius-suite/observability build && \
    pnpm --filter=@genius-suite/common build && \
    pnpm --filter=@genius-suite/numeriqo.app build

FROM base AS deploy
WORKDIR /app
COPY pnpm-workspace.yaml package.json pnpm-lock.yaml ./
COPY numeriqo.app/package.json ./numeriqo.app/
COPY shared/common/package.json ./shared/common/
COPY shared/observability/package.json ./shared/observability/
COPY --from=builder /app/shared ./shared
RUN pnpm deploy --filter=@genius-suite/numeriqo.app --prod --legacy --ignore-scripts /deploy

FROM node:22-alpine AS runner
ENV NODE_ENV=production
RUN apk add --no-cache curl && \
    addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 appuser
WORKDIR /app
COPY --from=builder --chown=appuser:nodejs /app/numeriqo.app/dist ./dist
COPY --from=deploy --chown=appuser:nodejs /deploy/node_modules ./node_modules
COPY --from=deploy --chown=appuser:nodejs /deploy/package.json ./package.json
USER appuser
EXPOSE 6900
CMD ["node", "dist/numeriqo.app/src/index.js"]
