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

# Compile shared libraries
RUN cd shared/observability && pnpm run build && cd ../../shared/common && pnpm run build

# Build the analytics-hub service
RUN cd cp/analytics-hub && pnpm run build

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
COPY --from=builder /app/cp/analytics-hub/dist ./cp/analytics-hub/dist
COPY --from=builder /app/cp/analytics-hub/package.json ./cp/analytics-hub/package.json
COPY --from=builder /app/shared ./shared

# Install analytics-hub service dependencies
RUN cd cp/analytics-hub && pnpm install --frozen-lockfile --production --ignore-scripts

EXPOSE 3006

# Start application with compiled JavaScript
CMD ["node", "cp/analytics-hub/dist/cp/analytics-hub/src/main.js"]