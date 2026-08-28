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
  const serviceName = process.env.CP_AI_OBS_SERVICE_NAME;
  if (!serviceName) {
    throw new Error('CP_AI_OBS_SERVICE_NAME environment variable is required');
  }

  // Initialize tracing very early in runtime but do not crash if collector is unreachable
  try {
    await initTracing({ serviceName });
    logger.info({ service: serviceName }, 'Tracing initialized');
  } catch (err) {
    logger.warn(
      { err, service: serviceName },
      'Tracing initialization failed; continuing without OTEL',
    );
  }

  // Create Fastify instance with shared logger for JSON-structured logs
  const app = fastify({ loggerInstance: logger });

  // Initialize metrics (registry default prom-client through observability)
  // TODO: Update to use sub-path import when available
  // initDefaultMetrics();
  // const metricsRegistry = promClient;
  try {
    await initMetrics({ serviceName });
    logger.info({ service: serviceName }, 'Metrics registry initialized');
  } catch (err) {
    logger.warn(
      { err, service: serviceName },
      'Metrics initialization failed; continuing without Prometheus metrics',
    );
  }

  // Health endpoint for Kubernetes/Docker health checks
  app.get('/health', async (_request: FastifyRequest, _reply: FastifyReply) => {
    return { status: 'ok', service: 'ai-hub' };
  });

  const port = requireListenPort('CP_AI_APP_PORT');
  await startMetricsServer({ port: requireListenPort('CP_AI_APP_METRICS_PORT') });
  await app.listen({ port, host: '0.0.0.0' });
  logger.info({ port, service: 'ai-hub' }, 'Server started');
}

main().catch((err) => {
  logger.error(err, 'Fatal error');
  process.exit(1);
});
