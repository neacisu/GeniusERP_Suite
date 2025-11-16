# Build stage
FROM node:24-alpine AS builder

WORKDIR /app

# Copy workspace files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

# Copy source from workspace root
COPY shared ./shared
COPY cp ./cp

# Install dependencies
# Install pnpm globally
RUN npm install -g pnpm

# Add pnpm to PATH
ENV PATH="/usr/local/bin:$PATH"

# Install all dependencies (including dev dependencies for building)
RUN pnpm install --frozen-lockfile

# Compile shared libraries and suite-shell
RUN cd shared/observability && pnpm run build && cd ../../shared/common && pnpm run build && cd ../../cp/suite-shell && pnpm run build

# Runtime stage
FROM node:24-alpine

WORKDIR /app

# Copy node_modules and source from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/cp/suite-shell ./cp/suite-shell
COPY --from=builder /app/shared ./shared
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/pnpm-workspace.yaml ./pnpm-workspace.yaml

# Expose metrics and app port
EXPOSE 6100

# Start application with ts-node for TypeScript resolution
CMD ["node", "-r", "ts-node/register", "cp/suite-shell/src/main.ts"]
