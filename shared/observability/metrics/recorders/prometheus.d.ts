import { register } from 'prom-client';
export declare function initMetrics({ serviceName: _serviceName }: {
    serviceName: string;
}): Promise<import("prom-client").Registry<"text/plain; version=0.0.4; charset=utf-8">>;
export declare function metricsHandler(): Promise<string>;
export { register as promClient };
