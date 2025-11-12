// Example integration for apps/api/src/main.ts

// After dotenv.config() and validateEnv()
import { startOtel } from '../../shared/observability';
await startOtel();

// After creating the Express app
import { registerMetricsRoute } from '../../shared/observability';
const app: any = {}; // Your Express app instance
registerMetricsRoute(app);

// For logging, import from the common logger package
import { createLogger } from '../../shared/common/logger/pino';
const appLogger = createLogger();
appLogger.info('App started with observability enabled');

// Ensure OTEL_SERVICE_NAME and OTEL_EXPORTER_OTLP_ENDPOINT are set in .env