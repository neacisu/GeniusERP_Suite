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
  const serviceName = process.env.CP_SHELL_OBS_SERVICE_NAME;
  if (!serviceName) {
    throw new Error('CP_SHELL_OBS_SERVICE_NAME environment variable is required');
  }

  // Initialize observability
  initTracing({ serviceName });
  initMetrics({ serviceName });

  const app = fastify({ loggerInstance: logger });

  // Health endpoint
  app.get('/health', async (_request: FastifyRequest, _reply: FastifyReply) => {
    return { status: 'ok', service: 'suite-shell' };
  });

  const port = requireListenPort('CP_SHELL_APP_PORT');
  await startMetricsServer({ port: requireListenPort('CP_SHELL_APP_METRICS_PORT') });
  await app.listen({ port, host: '0.0.0.0' });
}

main().catch(console.error);
