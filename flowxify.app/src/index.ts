import Fastify from 'fastify';
import { initTracing, initMetrics, startMetricsServer } from '@genius-suite/observability';
import { logger } from '@genius-suite/common';

async function main() {
  initTracing({ serviceName: 'flowxify.app' });
  initMetrics({ serviceName: 'flowxify.app' });

  const PORT = parseInt(process.env.PORT || '6600', 10);
  const metricsPort = parseInt(process.env.FLOWX_APP_METRICS_PORT || String(PORT + 1), 10);

  const app = Fastify({
    logger: {
      level: 'info',
      transport: {
        target: 'pino-pretty',
        options: {
          colorize: false,
          translateTime: 'SYS:standard',
          ignore: 'pid,hostname',
        },
      },
    },
  });

  app.get('/health', async () => {
    return { status: 'ok', service: 'flowxify.app' };
  });

  await startMetricsServer({ port: metricsPort });
  await app.listen({ port: PORT, host: '0.0.0.0' });
  logger.info({ port: PORT, service: 'flowxify.app' }, 'Flowxify App started');
}

main().catch((err) => {
  logger.error(err);
  process.exit(1);
});
