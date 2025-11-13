# Build stage
FROM node:24-alpine AS builder

WORKDIR /app

# Copy workspace files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

# Copy source
COPY shared ./shared
COPY cp/suite-login ./cp/suite-login

# Install dependencies
# Install pnpm
RUN wget -qO- https://get.pnpm.io/install.sh | ENV="$HOME/.bashrc" SHELL="$(which sh)" sh -

# Add pnpm to PATH
ENV PATH="$HOME/.local/share/pnpm:$PATH"

# Build shared libraries first
RUN cd shared/observability && pnpm run build
RUN cd shared/common && pnpm run build

# Build TypeScript for suite-login
RUN pnpm --filter @genius-suite/cp-suite-login run build

# Runtime stage  
FROM node:24-alpine

WORKDIR /app

# Install pnpm globally
# Install pnpm
RUN wget -qO- https://get.pnpm.io/install.sh | ENV="$HOME/.bashrc" SHELL="$(which sh)" sh -

# Add pnpm to PATH
ENV PATH="$HOME/.local/share/pnpm:$PATH"

# Copy entire workspace
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/shared ./shared
COPY --from=builder /app/cp/suite-login ./cp/suite-login

# Expose metrics and app port
EXPOSE 6200

# Start application directly with ts-node from source
CMD ["node", "-r", "ts-node/register", "cp/suite-login/src/main.ts"]
