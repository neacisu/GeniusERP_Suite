// shared/observability/index.ts
export { startOtel } from './traces/otel';
export { createLogger } from '../common/logger/pino';
export { registerMetricsRoute, promClient } from './metrics/recorders/prometheus';