import pino from 'pino';
import { trace } from '@opentelemetry/api';

const level = process.env.LOG_LEVEL || 'info';
const isDev = process.env.NODE_ENV === 'development';

const baseLogger = pino({
  level,
  ...(isDev && {
    transport: {
      target: 'pino-pretty',
      options: {
        colorize: true,
      },
    },
  }),
});

export function createLogger(context?: Record<string, any>) {
  const span = trace.getActiveSpan();
  const traceId = span ? span.spanContext().traceId : undefined;
  const childContext = { ...context, ...(traceId && { traceId }) };
  return baseLogger.child(childContext);
}

export const logger = createLogger();