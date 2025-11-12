import { NodeSDK } from '@opentelemetry/sdk-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { Resource as ResourceClass } from '@opentelemetry/resources';
import { ATTR_SERVICE_NAME } from '@opentelemetry/semantic-conventions';

export async function initTracing({ serviceName }: { serviceName: string }) {
  const traceExporter = new OTLPTraceExporter({ url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT ?? 'http://otel-collector:4318/v1/traces' });
  // @ts-ignore - Resource constructor is not exported correctly in v2.2.0 types
  const resource = new ResourceClass({
    [ATTR_SERVICE_NAME]: serviceName,
  });
  const sdk = new NodeSDK({
    resource,
    traceExporter,
    instrumentations: [getNodeAutoInstrumentations()]
  });
  await sdk.start();
}