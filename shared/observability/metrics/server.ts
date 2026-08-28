import http from 'node:http';
import { metricsHandler } from './recorders/prometheus';

export function requireListenPort(envName: string): number {
  const port = parseInt(process.env[envName] || '', 10);
  if (!Number.isFinite(port) || port <= 0) {
    throw new Error(`${envName} environment variable is required`);
  }
  return port;
}

/**
 * Tabelul 5: API = bază, metrici = bază+1.
 * Listener HTTP separat, doar GET/HEAD /metrics (prom-client).
 */
export async function startMetricsServer(opts: {
  port: number;
  host?: string;
}): Promise<http.Server> {
  const host = opts.host ?? '0.0.0.0';
  if (!Number.isFinite(opts.port) || opts.port <= 0) {
    throw new Error(`invalid metrics port: ${opts.port}`);
  }

  const server = http.createServer((req, res) => {
    const path = req.url?.split('?')[0];
    if (path === '/metrics' && (req.method === 'GET' || req.method === 'HEAD')) {
      void metricsHandler()
        .then((body) => {
          res.writeHead(200, {
            'content-type': 'text/plain; version=0.0.4; charset=utf-8',
          });
          res.end(req.method === 'HEAD' ? undefined : body);
        })
        .catch(() => {
          res.writeHead(500);
          res.end();
        });
      return;
    }
    res.writeHead(404);
    res.end();
  });

  await new Promise<void>((resolve, reject) => {
    server.once('error', reject);
    server.listen(opts.port, host, () => resolve());
  });
  return server;
}
