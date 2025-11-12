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

# Build the licensing service
RUN cd cp/licensing && pnpm run build

# Runtime stage
FROM node:20-alpine

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm

# Add pnpm to PATH
ENV PATH="/usr/local/bin:$PATH"
ENV CI=true

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml tsconfig.base.json ./
RUN pnpm install --frozen-lockfile --production --ignore-scripts

# Copy node_modules and built application from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/cp/licensing/dist ./cp/licensing/dist
COPY --from=builder /app/cp/licensing/package.json ./cp/licensing/package.json
COPY --from=builder /app/shared ./shared

# Install licensing service dependencies
RUN cd cp/licensing && pnpm install --frozen-lockfile --production --ignore-scripts

EXPOSE 3005

# Start application with compiled JavaScript
CMD ["node", "cp/licensing/dist/cp/licensing/src/main.js"]