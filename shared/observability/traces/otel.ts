import { NodeSDK } from '@opentelemetry/sdk-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { Resource } from '@opentelemetry/resources';
import { SemanticResourceAttributes } from '@opentelemetry/semantic-conventions';

const serviceName = process.env.OTEL_SERVICE_NAME ?? 'genius-suite-service';
// @ts-ignore
const resource = new Resource({ [SemanticResourceAttributes.SERVICE_NAME]: serviceName });
const traceExporter = new OTLPTraceExporter({ url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT ?? 'http://otel-collector:4318/v1/traces' });
export const sdk = new NodeSDK({ resource, traceExporter, instrumentations: [getNodeAutoInstrumentations()] });

export async function startOtel() { await sdk.start(); }