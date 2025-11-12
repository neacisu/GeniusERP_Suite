import promClient from 'prom-client';

let initialized = false;

if (!initialized) {
  promClient.collectDefaultMetrics({ register: promClient.register });
  initialized = true;
}

export function registerMetricsRoute(app: any) {
  app.get('/metrics', async (_req: any, reply: any) => {
    reply.type('text/plain; version=0.0.4; charset=utf-8');
    return promClient.register.metrics();
  });
}

export { promClient };