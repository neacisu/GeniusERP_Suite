import Fastify from 'fastify';
import type { FastifyRequest, FastifyReply } from 'fastify';
import { initTracing } from '@genius-suite/observability';
import { initMetrics, startMetricsServer, requireListenPort } from '@genius-suite/observability';
import { logger } from '@genius-suite/common';

const app = Fastify({ loggerInstance: logger });

async function main() {
  // Validate required environment variables
  const serviceName = process.env.CP_LOGIN_OBS_SERVICE_NAME;
  if (!serviceName) {
    throw new Error('CP_LOGIN_OBS_SERVICE_NAME environment variable is required');
  }

  // Initialize observability
  await initTracing({ serviceName });
  await initMetrics({ serviceName });

  app.get('/health', async (_request: FastifyRequest, _reply: FastifyReply) => {
    return { status: 'ok', service: 'suite-login' };
  });

  const port = requireListenPort('CP_LOGIN_APP_PORT');
  await startMetricsServer({ port: requireListenPort('CP_LOGIN_APP_METRICS_PORT') });

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
