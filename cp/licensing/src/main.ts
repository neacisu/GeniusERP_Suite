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
  const serviceName = process.env.CP_LIC_OBS_SERVICE_NAME;
  if (!serviceName) {
    throw new Error('CP_LIC_OBS_SERVICE_NAME environment variable is required');
  }

  // Initialize tracing very early in runtime
  initTracing({ serviceName });

  // Create Fastify instance with shared logger for JSON-structured logs
  const app = fastify({ loggerInstance: logger });

  // Initialize metrics (registry default prom-client through observability)
  await initMetrics({ serviceName });

  // Health endpoint for Kubernetes/Docker health checks
  app.get('/health', async (_request: FastifyRequest, _reply: FastifyReply) => {
    return { status: 'ok', service: 'licensing' };
  });

  const port = requireListenPort('CP_LIC_APP_PORT');
  await startMetricsServer({ port: requireListenPort('CP_LIC_APP_METRICS_PORT') });
  await app.listen({ port, host: '0.0.0.0' });
  logger.info({ port, service: 'licensing' }, 'Server started');
}

main().catch((err) => {
  logger.error(err, 'Fatal error');
  process.exit(1);
});
