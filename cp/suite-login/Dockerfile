# Builder stage
FROM node:24-alpine AS builder

WORKDIR /app

# Copy workspace files
COPY pnpm-workspace.yaml pnpm-lock.yaml package.json ./
COPY cp/suite-login cp/suite-login
COPY libs libs

# Install dependencies
RUN npm install -g pnpm && pnpm install --frozen-lockfile

# Build suite-login
RUN cd cp/suite-login && pnpm run build

# Runtime stage
FROM node:24-alpine

WORKDIR /app

# Copy pnpm configuration
COPY pnpm-workspace.yaml pnpm-lock.yaml package.json ./

# Copy node_modules from builder
COPY --from=builder /app/node_modules node_modules
COPY --from=builder /app/cp/suite-login/dist cp/suite-login/dist
COPY --from=builder /app/cp/suite-login/node_modules cp/suite-login/node_modules
COPY --from=builder /app/libs libs

WORKDIR /app/cp/suite-login

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3003/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

EXPOSE 3003

CMD ["node", "dist/main.js"]
