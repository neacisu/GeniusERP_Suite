import fastify from 'fastify';
import type { FastifyRequest, FastifyReply } from 'fastify';
import { initTracing, initMetrics, metricsHandler } from '@genius-suite/observability';
import { logger } from '@genius-suite/common';

async function main() {
  // Validate required environment variables
  const serviceName = process.env.CP_LIC_OBS_SERVICE_NAME;
  if (!serviceName) {
    throw new Error('CP_LIC_OBS_SERVICE_NAME environment variable is required');
  }

  // Initialize tracing very early in runtime
  initTracing({ serviceName });

  // Create Fastify instance with shared logger for JSON-structured logs
  const app = fastify({ logger });

  // Initialize metrics (registry default prom-client through observability)
  await initMetrics({ serviceName });

  // Health endpoint for Kubernetes/Docker health checks
  app.get('/health', async (_request: FastifyRequest, reply: FastifyReply) => {
    return { status: 'ok', service: 'licensing' };
  });

  // Metrics endpoint for Prometheus scraping
  app.get('/metrics', async (_request: FastifyRequest, reply: FastifyReply) => {
    const body = await metricsHandler();
    reply.type('text/plain; version=0.0.4').send(body);
  });

  // Licensing service routes will be added here
  // TODO: Implement licensing logic (entitlements, metering, billing)

  const portString = process.env.CP_LIC_APP_PORT;
  if (!portString) {
    throw new Error('CP_LIC_APP_PORT environment variable is required');
  }
  const port = parseInt(portString, 10);
  await app.listen({ port, host: '0.0.0.0' });
  logger.info({ port, service: 'licensing' }, 'Server started');
}

main().catch((err) => {
  logger.error(err, 'Fatal error');
  process.exit(1);
});