import fastify from 'fastify';
import type { FastifyRequest, FastifyReply } from 'fastify';
import { initTracing, initMetrics, metricsHandler } from '@genius-suite/observability';
import { logger } from '@genius-suite/common';

async function main() {
  // Service name from environment or default
  const serviceName = process.env.OTEL_SERVICE_NAME || 'archify.app';
  const port = parseInt(process.env.PORT || '3000', 10);

  // Initialize observability - tracing and metrics
  // Reads OTEL_EXPORTER_OTLP_ENDPOINT from environment
  await initTracing({ serviceName });
  await initMetrics({ serviceName });

  // Create Fastify instance with Pino logger configuration for JSON-structured logs
  const app = fastify({
    logger: {
      level: 'info',
      formatters: {
        level: (label) => {
          return { level: label };
        },
      },
      timestamp: () => `,"time":"${new Date().toISOString()}"`,
    }
  });

  // Health endpoint for Docker/Kubernetes health checks
  app.get('/health', async () => {
    return { status: 'ok', service: 'archify.app' };
  });

  // Metrics endpoint for Prometheus scraping
  // Exposes Prometheus metrics in text/plain format
  app.get('/metrics', async (_request: FastifyRequest, reply: FastifyReply) => {
    const body = await metricsHandler();
    reply.type('text/plain; version=0.0.4').send(body);
  });

  // Application routes will be added here
  app.get('/', async () => {
    return { message: 'Archify App - Document Management System' };
  });

  await app.listen({ port, host: '0.0.0.0' });
  logger.info({ port, service: serviceName }, 'Archify App started');
}

main().catch((err) => {
  logger.error(err, 'Fatal error in archify.app');
  process.exit(1);
});
