import fastify from 'fastify';
import { initTracing, initMetrics, metricsHandler } from '@genius-suite/observability';
import { logger } from '@genius-suite/common';

async function main() {
  // Initialize observability
  initTracing({ serviceName: 'suite-shell' });
  initMetrics({ serviceName: 'suite-shell' });

  const app = fastify({ logger });

  // Metrics endpoint for Prometheus scraping
  app.get('/metrics', async (request, reply) => {
    const body = await metricsHandler();
    reply.type('text/plain').send(body);
  });

  // TODO: Add business logic routes here

  await app.listen({ port: 3000, host: '0.0.0.0' });
}

main().catch(console.error);