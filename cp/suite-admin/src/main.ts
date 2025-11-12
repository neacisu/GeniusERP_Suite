import fastify from 'fastify';
import type { FastifyRequest, FastifyReply } from 'fastify';
import { initTracing, initMetrics, metricsHandler } from '@genius-suite/observability';
import { logger } from '@genius-suite/common';

async function main() {
  // Initialize observability
  initTracing({
    serviceName: process.env.OTEL_SERVICE_NAME || 'suite-admin',
  });
  await initMetrics({
    serviceName: process.env.OTEL_SERVICE_NAME || 'suite-admin',
  });

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

  await app.listen({ port: 3002, host: '0.0.0.0' });
  logger.info('Suite Admin API listening at http://0.0.0.0:3002');
}

main().catch(console.error);
