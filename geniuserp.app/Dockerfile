FROM node:24-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV CI=true
RUN corepack enable && corepack prepare pnpm@10.34.5 --activate
WORKDIR /app
COPY pnpm-lock.yaml ./

FROM base AS deps
COPY package.json pnpm-workspace.yaml ./
COPY geniuserp.app/package.json ./geniuserp.app/
COPY shared/common/package.json ./shared/common/
COPY shared/observability/package.json ./shared/observability/
RUN pnpm install --frozen-lockfile

FROM base AS builder
COPY . .
RUN pnpm install --frozen-lockfile
RUN pnpm --filter=@genius-suite/common build && pnpm --filter=@genius-suite/observability build && pnpm --filter=@genius-suite/geniuserp.app build

FROM base AS deploy
WORKDIR /app
COPY pnpm-workspace.yaml package.json pnpm-lock.yaml ./
COPY geniuserp.app/package.json ./geniuserp.app/
COPY shared/common/package.json ./shared/common/
COPY shared/observability/package.json ./shared/observability/
COPY --from=builder /app/shared ./shared
RUN pnpm deploy --filter=@genius-suite/geniuserp.app --prod --legacy --ignore-scripts /deploy

FROM node:24-alpine AS runner
RUN apk add --no-cache curl && \
    addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 appuser
WORKDIR /app
COPY --from=deploy --chown=appuser:nodejs /deploy /app
COPY --from=builder --chown=appuser:nodejs /app/geniuserp.app/dist /app/geniuserp.app/dist
USER appuser
EXPOSE 6050
CMD ["node", "geniuserp.app/dist/geniuserp.app/src/index.js"]
