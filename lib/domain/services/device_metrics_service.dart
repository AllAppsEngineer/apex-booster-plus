import '../entities/device_metrics.dart';

abstract class DeviceMetricsService {
  Future<DeviceMetrics> measure();
}
