
// runtime/metrics/exporter.ts (si tu préfères exporter via proc Node)
import { PrometheusExporter } from '@opentelemetry/exporter-prometheus';
import { MeterProvider } from '@opentelemetry/sdk-metrics';

const exporter = new PrometheusExporter({ port: 9464 }, () => {
  console.log('Prometheus scrape on :9464/metrics');
});
const meterProvider = new MeterProvider({ readers: [exporter] });
const meter = meterProvider.getMeter('heaven-runtime');
export const actorCount = meter.createUpDownCounter('heaven_actors', { description: 'actors live' });

