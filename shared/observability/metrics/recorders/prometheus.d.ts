import { register } from 'prom-client';
export declare function initMetrics({ serviceName }: {
    serviceName: string;
}): Promise<void>;
export declare function metricsHandler(): Promise<string>;
export { register as promClient };
