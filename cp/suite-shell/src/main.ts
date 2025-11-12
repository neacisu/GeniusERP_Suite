import fastify from 'fastify';
import type { FastifyRequest, FastifyReply } from 'fastify';
import { initTracing, initMetrics, metricsHandler } from '@genius-suite/observability';
import { logger } from '@genius-suite/common';

async function main() {
  // Initialize observability
  initTracing({ serviceName: 'suite-shell' });
  initMetrics({ serviceName: 'suite-shell' });

  const app = fastify({ logger: logger as any });

  // Health endpoint
  app.get('/health', async (request: FastifyRequest, reply: FastifyReply) => {
    return { status: 'ok', service: 'suite-shell' };
  });

  // Metrics endpoint for Prometheus scraping
  app.get('/metrics', async (request: FastifyRequest, reply: FastifyReply) => {
    const body = await metricsHandler();
    reply.type('text/plain').send(body);
  });

  // TODO: Add business logic routes here

  await app.listen({ port: 3001, host: '0.0.0.0' });
}

main().catch(console.error);