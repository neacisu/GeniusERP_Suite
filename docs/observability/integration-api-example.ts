// Example integration for apps/api/src/main.ts

// After dotenv.config() and validateEnv()
import { initMetrics, initTracing, metricsHandler, promClient } from '../../shared/observability';

await initTracing({ serviceName: 'apps/api' });
await initMetrics({ serviceName: 'apps/api' });

// After creating the Express/Fastify app
const app: any = {}; // Replace with your HTTP server instance
app.get('/metrics', async (_req, res) => {
  res.set('Content-Type', promClient.contentType);
  res.send(await metricsHandler());
});

// For logging, import from the common logger package
import { createLogger } from '../../shared/common/logger/pino';
const appLogger = createLogger();
appLogger.info('App started with observability enabled');

// Ensure OTEL_SERVICE_NAME (or pass serviceName) and OTEL_EXPORTER_OTLP_ENDPOINT are configured
