import Fastify from 'fastify';
import { initTracing, initMetrics, startMetricsServer } from '@genius-suite/observability';
import { logger } from '@genius-suite/common';

async function main() {
  initTracing({ serviceName: 'cerniq.app' });
  initMetrics({ serviceName: 'cerniq.app' });

  const PORT = parseInt(process.env.PORT || '6550', 10);
  const metricsPort = parseInt(process.env.CERNIQ_APP_METRICS_PORT || String(PORT + 1), 10);

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
    return { status: 'ok', service: 'cerniq.app' };
  });

  await startMetricsServer({ port: metricsPort });
  await app.listen({ port: PORT, host: '0.0.0.0' });
  logger.info({ port: PORT, service: 'cerniq.app' }, 'Cerniq App started');
}

main().catch((err) => {
  logger.error(err);
  process.exit(1);
});
