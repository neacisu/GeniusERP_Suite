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
  const serviceName = process.env.CP_IDT_OBS_SERVICE_NAME;
  if (!serviceName) {
    throw new Error('CP_IDT_OBS_SERVICE_NAME environment variable is required');
  }

  // Initialize observability - tracing and metrics
  // Reads OTEL_EXPORTER_OTLP_ENDPOINT and OTEL_SERVICE_NAME from environment
  initTracing({ serviceName });
  initMetrics({ serviceName });

  // Create Fastify instance with shared logger for JSON-structured logs
  const app = fastify({ loggerInstance: logger });

  // Health endpoint for Kubernetes/Docker health checks
  app.get('/health', async (_request: FastifyRequest, _reply: FastifyReply) => {
    return { status: 'ok', service: 'identity' };
  });

  const port = requireListenPort('CP_IDT_APP_PORT');
  await startMetricsServer({ port: requireListenPort('CP_IDT_APP_METRICS_PORT') });
  await app.listen({ port, host: '0.0.0.0' });
  logger.info({ port, service: 'identity' }, 'Server started');
}

main().catch((err) => {
  logger.error(err, 'Fatal error');
  process.exit(1);
});
