import fastify from 'fastify';
import type { FastifyRequest, FastifyReply } from 'fastify';
// TODO: Update to use sub-path imports when F0.3.7, F0.3.9, F0.3.10 are implemented
// import { initTracing } from '@genius-suite/observability/traces/otel';
// import { metricsRegistry, initDefaultMetrics } from '@genius-suite/observability/metrics/recorders/prometheus';
import { initTracing, initMetrics, metricsHandler } from '@genius-suite/observability';
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
  const app = fastify({ logger });

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

  // Metrics endpoint for Prometheus scraping
  app.get('/metrics', async (_request: FastifyRequest, reply: FastifyReply) => {
    // TODO: Update to use metricsRegistry.metrics() when available
    // reply.type('text/plain');
    // return metricsRegistry.metrics();
    const body = await metricsHandler();
    reply.type('text/plain; version=0.0.4').send(body);
  });

  // AI Hub service routes will be added here
  // TODO: Implement AI logic (model inference, data processing, analytics)

  const portString = process.env.CP_AI_APP_PORT;
  if (!portString) {
    throw new Error('CP_AI_APP_PORT environment variable is required');
  }
  const port = parseInt(portString, 10);
  await app.listen({ port, host: '0.0.0.0' });
  logger.info({ port, service: 'ai-hub' }, 'Server started');
}

main().catch((err) => {
  logger.error(err, 'Fatal error');
  process.exit(1);
});
