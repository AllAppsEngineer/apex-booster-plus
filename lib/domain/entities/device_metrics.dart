enum LatencyStatus { success, timeout, noNetwork, error }

class DeviceMetrics {
  final int availableMemoryBytes;
  final int totalMemoryBytes;
  final bool isLowMemory;
  final int? latencyMs;
  final LatencyStatus latencyStatus;

  const DeviceMetrics({
    required this.availableMemoryBytes,
    required this.totalMemoryBytes,
    required this.isLowMemory,
    required this.latencyMs,
    required this.latencyStatus,
  });

  factory DeviceMetrics.empty() => const DeviceMetrics(
        availableMemoryBytes: 0,
        totalMemoryBytes: 0,
        isLowMemory: false,
        latencyMs: null,
        latencyStatus: LatencyStatus.error,
      );

  double get availableMemoryMb => availableMemoryBytes / (1024 * 1024);
  double get totalMemoryMb => totalMemoryBytes / (1024 * 1024);

  double get memoryUsagePercent {
    if (totalMemoryBytes <= 0) return 0.0;
    final used = totalMemoryBytes - availableMemoryBytes;
    return (used / totalMemoryBytes) * 100;
  }
}
