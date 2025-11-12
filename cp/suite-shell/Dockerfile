# Build stage
FROM node:24-alpine AS builder

WORKDIR /app

# Copy workspace files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

# Copy source
COPY shared ./shared
COPY cp/suite-shell ./cp/suite-shell

# Install dependencies
RUN npm install -g pnpm && pnpm install --frozen-lockfile

# Build TypeScript
RUN pnpm --filter @genius-suite/cp-suite-shell run build

# Runtime stage
FROM node:24-alpine

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm

# Copy runtime dependencies
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/cp/suite-shell ./

# Expose metrics and app port
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3001/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Start application
CMD ["node", "dist/main.js"]
