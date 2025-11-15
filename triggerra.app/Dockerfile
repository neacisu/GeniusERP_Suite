FROM node:22-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV CI=true
RUN corepack enable
WORKDIR /app
COPY pnpm-lock.yaml ./

FROM base AS deps
COPY package.json pnpm-workspace.yaml ./
COPY triggerra.app/package.json ./triggerra.app/
COPY shared/common/package.json ./shared/common/
COPY shared/observability/package.json ./shared/observability/
RUN pnpm install --frozen-lockfile

FROM base AS builder
COPY . .
RUN pnpm install --frozen-lockfile
RUN pnpm --filter=@genius-suite/triggerra.app build

FROM base AS deploy
COPY package.json pnpm-workspace.yaml ./
COPY triggerra.app/package.json ./triggerra.app/
COPY shared/common ./shared/common
COPY shared/observability ./shared/observability
RUN pnpm deploy --filter=@genius-suite/triggerra.app --prod --legacy --ignore-scripts /deploy

FROM node:22-alpine AS runner
RUN apk add --no-cache curl && \
    addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 appuser
WORKDIR /app
COPY --from=deploy --chown=appuser:nodejs /deploy /app
COPY --from=builder --chown=appuser:nodejs /app/triggerra.app/dist /app/triggerra.app/dist
USER appuser
EXPOSE 6800
CMD ["node", "triggerra.app/dist/triggerra.app/src/index.js"]
