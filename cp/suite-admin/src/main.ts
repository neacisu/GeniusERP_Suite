import fastify from 'fastify';
import type { FastifyRequest, FastifyReply } from 'fastify';
import { initTracing, initMetrics, metricsHandler } from '@genius-suite/observability';
import { logger } from '@genius-suite/common';

async function main() {
  // Validate required environment variables
  const serviceName = process.env.CP_ADMIN_OBS_SERVICE_NAME;
  if (!serviceName) {
    throw new Error('CP_ADMIN_OBS_SERVICE_NAME environment variable is required');
  }

  // Initialize observability
  initTracing({ serviceName });
  await initMetrics({ serviceName });

  const app = fastify({ logger: logger as any });

  // Metrics endpoint for Prometheus scraping
  app.get('/metrics', async (request: FastifyRequest, reply: FastifyReply) => {
    reply.type('text/plain');
    const body = await metricsHandler();
    return body;
  });

  // Health endpoint
  app.get('/health', async (request: FastifyRequest, reply: FastifyReply) => {
    return { status: 'ok', service: 'suite-admin' };
  });

  // TODO: Add business logic routes here

  const portString = process.env.CP_ADMIN_APP_PORT;
  if (!portString) {
    throw new Error('CP_ADMIN_APP_PORT environment variable is required');
  }
  const port = parseInt(portString, 10);

  await app.listen({ port, host: '0.0.0.0' });
  logger.info(`Suite Admin API listening at http://0.0.0.0:${port}`);
}

main().catch(console.error);
