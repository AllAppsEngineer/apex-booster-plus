import '../../data/datasources/device_metrics_datasource.dart';
import '../../domain/entities/device_metrics.dart';
import '../../domain/services/device_metrics_service.dart';

class DeviceMetricsServiceImpl implements DeviceMetricsService {
  DeviceMetricsServiceImpl({DeviceMetricsDatasource? datasource})
      : _datasource = datasource ?? DeviceMetricsDatasource();

  final DeviceMetricsDatasource _datasource;

  @override
  Future<DeviceMetrics> measure() async {
    // Start both futures concurrently before awaiting either.
    final memFuture = _datasource.getMemoryInfo();
    final latFuture = _datasource.measureLatency();

    final memory = await memFuture;
    final (latencyMs, latencyStatus) = await latFuture;

    return DeviceMetrics(
      availableMemoryBytes: memory['availableBytes'] as int? ?? 0,
      totalMemoryBytes: memory['totalBytes'] as int? ?? 0,
      isLowMemory: memory['lowMemory'] as bool? ?? false,
      latencyMs: latencyMs,
      latencyStatus: latencyStatus,
    );
  }
}
