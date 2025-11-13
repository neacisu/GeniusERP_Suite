import Fastify from 'fastify';
import type { FastifyRequest, FastifyReply } from 'fastify';
import { initTracing } from '@genius-suite/observability';
import { initMetrics, metricsHandler } from '@genius-suite/observability';
import { logger } from '@genius-suite/common';

const app = Fastify({ logger });

async function main() {
  // Validate required environment variables
  const serviceName = process.env.CP_LOGIN_OBS_SERVICE_NAME;
  if (!serviceName) {
    throw new Error('CP_LOGIN_OBS_SERVICE_NAME environment variable is required');
  }

  // Initialize observability
  await initTracing({ serviceName });
  await initMetrics({ serviceName });

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
  const portString = process.env.CP_LOGIN_APP_PORT;
  if (!portString) {
    throw new Error('CP_LOGIN_APP_PORT environment variable is required');
  }
  const port = parseInt(portString, 10);

  try {
    await app.listen({ port, host: '0.0.0.0' });
    logger.info(`Suite-login service started on port ${port}`);
  } catch (err) {
    logger.error(err);
    process.exit(1);
  }
}

main().catch((err) => {
  logger.error(err);
  process.exit(1);
});
