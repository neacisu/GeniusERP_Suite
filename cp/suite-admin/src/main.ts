import fastify from 'fastify';
import type { FastifyRequest, FastifyReply } from 'fastify';
import {
  initTracing,
  initMetrics,
  startMetricsServer,
  requireListenPort,
} from '@genius-suite/observability';
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

  const app = fastify({ loggerInstance: logger });

  app.get('/health', async (_request: FastifyRequest, _reply: FastifyReply) => {
    return { status: 'ok', service: 'suite-admin' };
  });

  const port = requireListenPort('CP_ADMIN_APP_PORT');
  await startMetricsServer({ port: requireListenPort('CP_ADMIN_APP_METRICS_PORT') });
  await app.listen({ port, host: '0.0.0.0' });
  logger.info(`Suite Admin API listening at http://0.0.0.0:${port}`);
}

main().catch(console.error);
