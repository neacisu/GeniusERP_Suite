import Fastify from 'fastify';
import { initTracing, initMetrics, startMetricsServer } from '@genius-suite/observability';
import { logger } from '@genius-suite/common';

async function main() {
  initTracing({ serviceName: 'i-wms.app' });
  initMetrics({ serviceName: 'i-wms.app' });

  const PORT = parseInt(process.env.PORT || '6650', 10);
  const metricsPort = parseInt(process.env.IWMS_APP_METRICS_PORT || String(PORT + 1), 10);

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
    return { status: 'ok', service: 'i-wms.app' };
  });

  await startMetricsServer({ port: metricsPort });
  await app.listen({ port: PORT, host: '0.0.0.0' });
  logger.info({ port: PORT, service: 'i-wms.app' }, 'i-WMS App started');
}

main().catch((err) => {
  logger.error(err);
  process.exit(1);
});
