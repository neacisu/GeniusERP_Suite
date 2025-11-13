import fastify from 'fastify';
import type { FastifyRequest, FastifyReply } from 'fastify';
import { initTracing, initMetrics, metricsHandler } from '@genius-suite/observability';
import { logger } from '@genius-suite/common';

async function main() {
  // Validate required environment variables
  const serviceName = process.env.CP_IDT_OBS_SERVICE_NAME;
  if (!serviceName) {
    throw new Error('CP_IDT_OBS_SERVICE_NAME environment variable is required');
  }

  // Initialize observability - tracing and metrics
  // Reads OTEL_EXPORTER_OTLP_ENDPOINT and OTEL_SERVICE_NAME from environment
  initTracing({ serviceName });
  initMetrics({ serviceName });

  // Create Fastify instance with shared logger for JSON-structured logs
  const app = fastify({ logger: logger as any });

  // Health endpoint for Kubernetes/Docker health checks
  app.get('/health', async (_request: FastifyRequest, reply: FastifyReply) => {
    return { status: 'ok', service: 'identity' };
  });

  // Metrics endpoint for Prometheus scraping
  // Exposes Prometheus metrics in text/plain format
  app.get('/metrics', async (_request: FastifyRequest, reply: FastifyReply) => {
    const body = await metricsHandler();
    reply.type('text/plain; version=0.0.4').send(body);
  });

  // Identity service routes will be added here
  // TODO: Implement authentication/identity logic

  const portString = process.env.CP_IDT_APP_PORT;
  if (!portString) {
    throw new Error('CP_IDT_APP_PORT environment variable is required');
  }
  const port = parseInt(portString, 10);
  await app.listen({ port, host: '0.0.0.0' });
  logger.info({ port, service: 'identity' }, 'Server started');
}

main().catch((err) => {
  logger.error(err, 'Fatal error');
  process.exit(1);
});
