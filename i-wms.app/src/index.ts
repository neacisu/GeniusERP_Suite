import Fastify from 'fastify';
import { initTracing, initMetrics, metricsHandler } from '@genius-suite/observability';
import { logger } from '@genius-suite/common';

// Initialize observability
initTracing({ serviceName: 'i-wms.app' });
initMetrics({ serviceName: 'i-wms.app' });

const PORT = parseInt(process.env.PORT || '6700', 10);

const app = Fastify({
  logger: {
    level: 'info',
    transport: {
      target: 'pino-pretty',
      options: {
        colorize: false,
        translateTime: 'SYS:standard',
        ignore: 'pid,hostname'
      }
    }
  }
});

// Health check endpoint
app.get('/health', async () => {
  return { status: 'ok', service: 'i-wms.app' };
});

// Metrics endpoint for Prometheus
app.get('/metrics', async (_request, reply) => {
  reply.type('text/plain');
  return metricsHandler();
});

app.listen({ port: PORT, host: '0.0.0.0' }, (err) => {
  if (err) {
    logger.error(err);
    process.exit(1);
  }
  logger.info({ port: PORT, service: 'i-wms.app' }, 'i-WMS App started');
});
