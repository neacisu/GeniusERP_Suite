import Fastify from 'fastify';
import { initTracing, initMetrics, metricsHandler } from '@genius-suite/observability';
import { logger } from '@genius-suite/common';

// Initialize observability
initTracing({ serviceName: 'flowxify.app' });
initMetrics({ serviceName: 'flowxify.app' });

const PORT = parseInt(process.env.PORT || '6600', 10);

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
  return { status: 'ok', service: 'flowxify.app' };
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
  logger.info({ port: PORT, service: 'flowxify.app' }, 'Flowxify App started');
});
