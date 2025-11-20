# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy workspace files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml tsconfig.base.json ./

# Copy source from workspace root
COPY shared ./shared
COPY cp ./cp

# Install dependencies
# Install pnpm
RUN npm install -g pnpm

# Add pnpm to PATH
ENV PATH="/usr/local/bin:$PATH"

# Install all dependencies (including dev dependencies for building)
RUN pnpm install --frozen-lockfile

# Compile shared libraries and ai-hub service
RUN pnpm --filter=@genius-suite/observability build && \
	pnpm --filter=@genius-suite/common build && \
	pnpm --filter=@genius-suite/cp-ai-hub build

# Runtime stage
FROM node:20-alpine

WORKDIR /app

# Install curl for health checks
RUN apk add --no-cache curl

# Install pnpm
RUN npm install -g pnpm

# Add pnpm to PATH
ENV PATH="/usr/local/bin:$PATH"
ENV CI=true

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml tsconfig.base.json ./
RUN pnpm install --frozen-lockfile --production --ignore-scripts

# Copy node_modules and built application from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/cp/ai-hub/dist ./cp/ai-hub/dist
COPY --from=builder /app/cp/ai-hub/package.json ./cp/ai-hub/package.json
COPY --from=builder /app/shared ./shared

# Install ai-hub service dependencies
RUN cd cp/ai-hub && pnpm install --frozen-lockfile --production --ignore-scripts

EXPOSE 6400

# Start application with compiled JavaScript
CMD ["node", "cp/ai-hub/dist/main.js"]