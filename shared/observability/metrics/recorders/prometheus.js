import { register, collectDefaultMetrics } from 'prom-client';
// Initialize default metrics (CPU, memory, event loop, etc.)
collectDefaultMetrics({ register });
export async function initMetrics({ serviceName: _serviceName }) {
    // Metrics registry is created automatically by prom-client
    // Default metrics are already collected above
    // Service name will be added as label to all metrics
    return register;
}
export async function metricsHandler() {
    return register.metrics();
}
export { register as promClient };
//# sourceMappingURL=prometheus.js.map