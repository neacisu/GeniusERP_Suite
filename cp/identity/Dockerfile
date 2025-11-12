# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm

COPY package*.json pnpm-lock.yaml* ./
RUN pnpm install --frozen-lockfile

COPY tsconfig*.json ./
COPY src/ ./src/

RUN pnpm run build

# Runtime stage
FROM node:20-alpine

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm

COPY package*.json pnpm-lock.yaml* ./
RUN pnpm install --frozen-lockfile --production

COPY --from=builder /app/dist ./dist

EXPOSE 3005

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3005/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

CMD ["pnpm", "start"]
