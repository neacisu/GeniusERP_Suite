// Example integration for apps/api/src/main.ts

// After dotenv.config() and validateEnv()
import { startOtel } from '@genius-suite/observability';
await startOtel();

// After creating the Express app
import { registerMetricsRoute } from '@genius-suite/observability';
registerMetricsRoute(app);

// For logging, replace existing logger
import { createLogger } from '@genius-suite/observability';
const appLogger = createLogger();

// Ensure OTEL_SERVICE_NAME and OTEL_EXPORTER_OTLP_ENDPOINT are set in .env