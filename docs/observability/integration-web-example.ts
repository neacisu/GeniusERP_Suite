// Example integration for apps/web/src/main.tsx

// For frontend, you can use OpenTelemetry JS SDK for tracing
// Install @opentelemetry/api, @opentelemetry/sdk-trace-web, @opentelemetry/exporter-trace-otlp-http

// Example:
// import { WebTracerProvider } from '@opentelemetry/sdk-trace-web';
// import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';
// const provider = new WebTracerProvider();
// provider.addSpanProcessor(new SimpleSpanProcessor(new OTLPTraceExporter()));
// provider.register();

// For logging in SSR/BFF layers, reuse the shared Node logger
// import { createLogger } from '../../shared/common/logger/pino';
// const logger = createLogger();
