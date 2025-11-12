import fastify from 'fastify';
import type { FastifyRequest, FastifyReply } from 'fastify';
import { initTracing, initMetrics, metricsHandler } from '@genius-suite/observability';
import { logger } from '@genius-suite/common';

async function main() {
  // Initialize observability - tracing and metrics
  // Reads OTEL_EXPORTER_OTLP_ENDPOINT and OTEL_SERVICE_NAME from environment
  initTracing({ serviceName: process.env.OTEL_SERVICE_NAME ?? 'identity' });
  initMetrics({ serviceName: process.env.OTEL_SERVICE_NAME ?? 'identity' });

  // Create Fastify instance with shared logger for JSON-structured logs
  const app = fastify({ logger: logger as any });

  // Health endpoint for Kubernetes/Docker health checks
  app.get('/health', async (_request: FastifyRequest, reply: FastifyReply) => {
    return { status: 'ok', service: 'identity' };
  });

  // Metrics endpoint for Prometheus scraping
  // Exposes Prometheus metrics in text/plain format
  app.get('/metrics', async (_request: FastifyRequest, reply: FastifyReply) => {
    const body = await metricsHandler();
    reply.type('text/plain; version=0.0.4').send(body);
  });

  // Identity service routes will be added here
  // TODO: Implement authentication/identity logic

  const port = parseInt(process.env.PORT ?? '3005', 10);
  await app.listen({ port, host: '0.0.0.0' });
  logger.info({ port, service: 'identity' }, 'Server started');
}

main().catch((err) => {
  logger.error(err, 'Fatal error');
  process.exit(1);
});
