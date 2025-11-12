import { register, collectDefaultMetrics } from 'prom-client';

let initialized = false;

export async function initMetrics({ serviceName }: { serviceName: string }) {
  if (!initialized) {
    collectDefaultMetrics({ register });
    initialized = true;
  }
}

export async function metricsHandler() {
  return register.metrics();
}

export { register as promClient };