import Fastify, { FastifyRequest, FastifyReply } from 'fastify';
import { initTracing } from '@genius-suite/observability';
import { initMetrics, metricsHandler } from '@genius-suite/observability';
import { logger } from '@genius-suite/common';

const app = Fastify({ logger });

async function main() {
  // Initialize observability
  await initTracing({ serviceName: 'suite-login' });
  await initMetrics({ serviceName: 'suite-login' });

  // Metrics endpoint
  app.get('/metrics', async (request: FastifyRequest, reply: FastifyReply) => {
    reply.type('text/plain');
    return metricsHandler();
  });

  // Health endpoint
  app.get('/health', async (request: FastifyRequest, reply: FastifyReply) => {
    return { status: 'ok', service: 'suite-login' };
  });

  // Start server
  try {
    await app.listen({ port: 3003, host: '0.0.0.0' });
    logger.info('Suite-login service started on port 3003');
  } catch (err) {
    logger.error(err);
    process.exit(1);
  }
}

main().catch((err) => {
  logger.error(err);
  process.exit(1);
});
