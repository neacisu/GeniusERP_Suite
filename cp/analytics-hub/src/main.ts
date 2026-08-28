import fastify from 'fastify';
import type { FastifyRequest, FastifyReply } from 'fastify';
// TODO: Update to use sub-path imports when F0.3.7, F0.3.9, F0.3.10 are implemented
// import { initTracing } from '@genius-suite/observability/traces/otel';
// import { metricsRegistry, initDefaultMetrics } from '@genius-suite/observability/metrics/recorders/prometheus';
import {
  initTracing,
  initMetrics,
  startMetricsServer,
  requireListenPort,
} from '@genius-suite/observability';
import { logger } from '@genius-suite/common';

async function main() {
  // Validate required environment variables
  const serviceName = process.env.CP_ANLY_OBS_SERVICE_NAME;
  if (!serviceName) {
    throw new Error('CP_ANLY_OBS_SERVICE_NAME environment variable is required');
  }

  // Initialize tracing very early in runtime
  // TODO: Update to use sub-path import when available
  // await initTracing({ serviceName: process.env.CP_ANLY_OBS_SERVICE_NAME || 'analytics-hub' });
  await initTracing({ serviceName });

  // Create Fastify instance with shared logger for JSON-structured logs
  const app = fastify({ loggerInstance: logger });

  // Initialize metrics (registry default prom-client through observability)
  // TODO: Update to use sub-path import when available
  // initDefaultMetrics();
  // const metricsRegistry = promClient;
  await initMetrics({ serviceName });

  // Health endpoint for Kubernetes/Docker health checks
  app.get('/health', async (_request: FastifyRequest, _reply: FastifyReply) => {
    return { status: 'ok', service: 'analytics-hub' };
  });

  const port = requireListenPort('CP_ANLY_APP_PORT');
  await startMetricsServer({ port: requireListenPort('CP_ANLY_APP_METRICS_PORT') });
  await app.listen({ port, host: '0.0.0.0' });
  logger.info({ port, service: 'analytics-hub' }, 'Server started');
}

main().catch((err) => {
  logger.error(err, 'Fatal error');
  process.exit(1);
});
