# Build stage
FROM node:24-alpine AS builder

WORKDIR /app

# Copy workspace files from root context
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

# Copy source from workspace root
COPY shared ./shared
COPY cp ./cp

# Install dependencies
# Install pnpm
RUN wget -qO- https://get.pnpm.io/install.sh | ENV="$HOME/.bashrc" SHELL="$(which sh)" sh -

# Add pnpm to PATH
ENV PATH="$HOME/.local/share/pnpm:$PATH"

# Compile shared libraries and suite-admin
RUN cd shared/observability && pnpm run build && cd ../../shared/common && pnpm run build && cd ../../cp/suite-admin && pnpm run build

# Runtime stage
FROM node:24-alpine

WORKDIR /app

# Copy node_modules from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/cp/suite-admin ./cp/suite-admin
COPY --from=builder /app/shared ./shared
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/pnpm-workspace.yaml ./pnpm-workspace.yaml

# Expose API and metrics port
EXPOSE 3002

# Start application with ts-node for TypeScript resolution
CMD ["node", "-r", "ts-node/register", "cp/suite-admin/src/main.ts"]
