import { NodeSDK } from '@opentelemetry/sdk-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { resourceFromAttributes } from '@opentelemetry/resources';
import { ATTR_SERVICE_NAME } from '@opentelemetry/semantic-conventions';
export async function initTracing({ serviceName }) {
    const traceExporter = new OTLPTraceExporter({
        url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT || 'http://localhost:4318/v1/traces'
    });
    const resource = resourceFromAttributes({
        [ATTR_SERVICE_NAME]: serviceName,
    });
    const sdk = new NodeSDK({
        resource,
        traceExporter,
        instrumentations: [getNodeAutoInstrumentations()]
    });
    await sdk.start();
}
//# sourceMappingURL=otel.js.map