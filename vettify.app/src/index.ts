import fastify from 'fastify';
import type { FastifyRequest, FastifyReply } from 'fastify';
import { initTracing, initMetrics, metricsHandler } from '@genius-suite/observability';
import { logger } from '@genius-suite/common';

async function main() {
  const serviceName = process.env.OTEL_SERVICE_NAME || 'vettify.app';
  const port = parseInt(process.env.PORT || '6850', 10);

  await initTracing({ serviceName });
  await initMetrics({ serviceName });

  const app = fastify({
    logger: {
      level: 'info',
      formatters: {
        level: (label) => {
          return { level: label };
        },
      },
      timestamp: () => `,"time":"${new Date().toISOString()}"`,
    }
  });

  app.get('/health', async () => {
    return { status: 'ok', service: 'vettify.app' };
  });

  app.get('/metrics', async (_request: FastifyRequest, reply: FastifyReply) => {
    const body = await metricsHandler();
    reply.type('text/plain; version=0.0.4').send(body);
  });

  app.get('/', async () => {
    return { message: 'Vettify App - Vendor Management System' };
  });

  await app.listen({ port, host: '0.0.0.0' });
  logger.info({ port, service: serviceName }, 'Vettify App started');
}

main().catch((err) => {
  logger.error(err, 'Fatal error in vettify.app');
  process.exit(1);
});
