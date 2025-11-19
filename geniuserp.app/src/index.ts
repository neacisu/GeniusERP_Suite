import fastify from 'fastify';
import type { FastifyRequest, FastifyReply } from 'fastify';
import { initTracing, initMetrics, metricsHandler } from '@genius-suite/observability';
import { logger } from '@genius-suite/common';

async function main() {
  const serviceName = process.env.OTEL_SERVICE_NAME || 'geniuserp.app';
  const port = parseInt(process.env.PORT || process.env.GENERP_APP_PORT || '6050', 10);

  await initTracing({ serviceName });
  await initMetrics({ serviceName });

  const app = fastify({
    logger: {
      level: process.env.LOG_LEVEL || 'info',
      formatters: {
        level(label) {
          return { level: label };
        },
      },
      timestamp: () => `,"time":"${new Date().toISOString()}"`,
    },
  });

  app.get('/health', async () => ({ status: 'ok', service: 'geniuserp.app' }));

  app.get('/metrics', async (_request: FastifyRequest, reply: FastifyReply) => {
    const body = await metricsHandler();
    reply.type('text/plain; version=0.0.4').send(body);
  });

  app.get('/', async () => ({
    message: 'GeniusERP.app public surface is online',
    portal: process.env.GENERP_PORTAL_ENABLED === 'true',
    docs: process.env.GENERP_WEBSITE_DOCS_ENABLED === 'true',
    status: process.env.GENERP_STATUS_PAGE_ENABLED === 'true',
  }));

  await app.listen({ port, host: '0.0.0.0' });
  logger.info({ port, service: serviceName }, 'GeniusERP.app started');
}

main().catch((err) => {
  logger.error(err, 'Fatal error in geniuserp.app');
  process.exit(1);
});
