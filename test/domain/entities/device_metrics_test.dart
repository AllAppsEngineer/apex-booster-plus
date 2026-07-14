import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/domain/entities/device_metrics.dart';

void main() {
  group('DeviceMetrics.empty', () {
    test('returns safe zero defaults', () {
      final m = DeviceMetrics.empty();
      expect(m.availableMemoryBytes, 0);
      expect(m.totalMemoryBytes, 0);
      expect(m.isLowMemory, false);
      expect(m.latencyMs, isNull);
      expect(m.latencyStatus, LatencyStatus.error);
    });

    test('memoryUsagePercent is 0 when total is 0', () {
      expect(DeviceMetrics.empty().memoryUsagePercent, 0.0);
    });
  });

  group('DeviceMetrics.availableMemoryMb', () {
    test('converts bytes to MB correctly', () {
      final m = DeviceMetrics(
        availableMemoryBytes: 2 * 1024 * 1024,
        totalMemoryBytes: 8 * 1024 * 1024,
        isLowMemory: false,
        latencyMs: null,
        latencyStatus: LatencyStatus.error,
      );
      expect(m.availableMemoryMb, closeTo(2.0, 0.001));
    });

    test('returns 0 when availableMemoryBytes is 0', () {
      final m = DeviceMetrics(
        availableMemoryBytes: 0,
        totalMemoryBytes: 4 * 1024 * 1024,
        isLowMemory: false,
        latencyMs: null,
        latencyStatus: LatencyStatus.error,
      );
      expect(m.availableMemoryMb, 0.0);
    });
  });

  group('DeviceMetrics.totalMemoryMb', () {
    test('converts bytes to MB correctly', () {
      final m = DeviceMetrics(
        availableMemoryBytes: 0,
        totalMemoryBytes: 8 * 1024 * 1024,
        isLowMemory: false,
        latencyMs: null,
        latencyStatus: LatencyStatus.error,
      );
      expect(m.totalMemoryMb, closeTo(8.0, 0.001));
    });
  });

  group('DeviceMetrics.memoryUsagePercent', () {
    test('calculates 75% used correctly', () {
      // 2 GB available out of 8 GB total → 75% used
      final m = DeviceMetrics(
        availableMemoryBytes: 2 * 1024 * 1024 * 1024,
        totalMemoryBytes: 8 * 1024 * 1024 * 1024,
        isLowMemory: false,
        latencyMs: null,
        latencyStatus: LatencyStatus.error,
      );
      expect(m.memoryUsagePercent, closeTo(75.0, 0.001));
    });

    test('calculates 50% used correctly', () {
      final m = DeviceMetrics(
        availableMemoryBytes: 4 * 1024 * 1024,
        totalMemoryBytes: 8 * 1024 * 1024,
        isLowMemory: false,
        latencyMs: null,
        latencyStatus: LatencyStatus.error,
      );
      expect(m.memoryUsagePercent, closeTo(50.0, 0.001));
    });

    test('is 0 when available equals total', () {
      final m = DeviceMetrics(
        availableMemoryBytes: 4 * 1024 * 1024,
        totalMemoryBytes: 4 * 1024 * 1024,
        isLowMemory: false,
        latencyMs: null,
        latencyStatus: LatencyStatus.error,
      );
      expect(m.memoryUsagePercent, 0.0);
    });
  });

  group('LatencyStatus', () {
    test('has exactly 4 distinct values', () {
      expect(LatencyStatus.values.length, 4);
      expect(LatencyStatus.values.toSet().length, 4);
    });

    test('contains expected values', () {
      expect(LatencyStatus.values, containsAll([
        LatencyStatus.success,
        LatencyStatus.timeout,
        LatencyStatus.noNetwork,
        LatencyStatus.error,
      ]));
    });
  });

  group('DeviceMetrics — copy honesto', () {
    test('latencyMs is null on non-success statuses', () {
      for (final status in [
        LatencyStatus.timeout,
        LatencyStatus.noNetwork,
        LatencyStatus.error,
      ]) {
        final m = DeviceMetrics(
          availableMemoryBytes: 0,
          totalMemoryBytes: 0,
          isLowMemory: false,
          latencyMs: null,
          latencyStatus: status,
        );
        expect(m.latencyMs, isNull,
            reason: 'latencyMs should be null for $status');
      }
    });

    test('latencyMs is set on success', () {
      final m = DeviceMetrics(
        availableMemoryBytes: 1000,
        totalMemoryBytes: 4000,
        isLowMemory: false,
        latencyMs: 42,
        latencyStatus: LatencyStatus.success,
      );
      expect(m.latencyMs, 42);
    });
  });
}
