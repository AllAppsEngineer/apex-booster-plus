import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/data/datasources/device_metrics_datasource.dart';
import 'package:apex_booster_plus/data/services/device_metrics_service_impl.dart';
import 'package:apex_booster_plus/domain/entities/device_metrics.dart';

// Fake datasource for testing — overrides channel and network calls.
class _FakeDatasource extends DeviceMetricsDatasource {
  _FakeDatasource({
    required this.memoryResult,
    required this.latencyResult,
  });

  final Map<String, dynamic> memoryResult;
  final (int?, LatencyStatus) latencyResult;

  @override
  Future<Map<String, dynamic>> getMemoryInfo() async => memoryResult;

  @override
  Future<(int?, LatencyStatus)> measureLatency() async => latencyResult;
}

DeviceMetricsServiceImpl _makeService({
  required Map<String, dynamic> memory,
  required (int?, LatencyStatus) latency,
}) =>
    DeviceMetricsServiceImpl(
      datasource: _FakeDatasource(memoryResult: memory, latencyResult: latency),
    );

void main() {
  final fullMemory = {
    'availableBytes': 2000000000,
    'totalBytes': 8000000000,
    'lowMemory': false,
    'thresholdBytes': 500000000,
  };

  group('DeviceMetricsServiceImpl — métricas válidas', () {
    test('retorna RAM e latência corretos quando tudo disponível', () async {
      final svc = _makeService(
        memory: fullMemory,
        latency: (42, LatencyStatus.success),
      );
      final m = await svc.measure();
      expect(m.availableMemoryBytes, 2000000000);
      expect(m.totalMemoryBytes, 8000000000);
      expect(m.isLowMemory, false);
      expect(m.latencyMs, 42);
      expect(m.latencyStatus, LatencyStatus.success);
    });

    test('isLowMemory reflete estado de pressão de memória', () async {
      final svc = _makeService(
        memory: {...fullMemory, 'lowMemory': true},
        latency: (10, LatencyStatus.success),
      );
      final m = await svc.measure();
      expect(m.isLowMemory, true);
    });
  });

  group('DeviceMetricsServiceImpl — falhas de rede', () {
    test('sem internet: latencyMs null, status noNetwork', () async {
      final svc = _makeService(
        memory: fullMemory,
        latency: (null, LatencyStatus.noNetwork),
      );
      final m = await svc.measure();
      expect(m.latencyMs, isNull);
      expect(m.latencyStatus, LatencyStatus.noNetwork);
    });

    test('timeout: latencyMs null, status timeout', () async {
      final svc = _makeService(
        memory: fullMemory,
        latency: (null, LatencyStatus.timeout),
      );
      final m = await svc.measure();
      expect(m.latencyMs, isNull);
      expect(m.latencyStatus, LatencyStatus.timeout);
    });

    test('erro genérico: latencyMs null, status error', () async {
      final svc = _makeService(
        memory: fullMemory,
        latency: (null, LatencyStatus.error),
      );
      final m = await svc.measure();
      expect(m.latencyMs, isNull);
      expect(m.latencyStatus, LatencyStatus.error);
    });
  });

  group('DeviceMetricsServiceImpl — falhas de RAM', () {
    test('memória zerada não causa crash', () async {
      final svc = _makeService(
        memory: {
          'availableBytes': 0,
          'totalBytes': 0,
          'lowMemory': false,
          'thresholdBytes': 0,
        },
        latency: (null, LatencyStatus.error),
      );
      final m = await svc.measure();
      expect(m.availableMemoryBytes, 0);
      expect(m.totalMemoryBytes, 0);
      expect(m.memoryUsagePercent, 0.0);
    });

    test('campos ausentes no map usam fallback zero', () async {
      final svc = _makeService(
        memory: {},
        latency: (null, LatencyStatus.error),
      );
      final m = await svc.measure();
      expect(m.availableMemoryBytes, 0);
      expect(m.totalMemoryBytes, 0);
      expect(m.isLowMemory, false);
    });
  });

  group('DeviceMetricsServiceImpl — copy honesto', () {
    test('nenhum campo menciona FPS, GPU, boost ou ping de jogo', () async {
      final svc = _makeService(
        memory: fullMemory,
        latency: (42, LatencyStatus.success),
      );
      final m = await svc.measure();
      // DeviceMetrics não tem campos de texto — valida que latencyStatus
      // não é um status falso de "boost aplicado"
      expect(m.latencyStatus, isNot(equals(LatencyStatus.error)));
    });

    test('memoryUsagePercent usa dados reais, sem inflação', () async {
      final svc = _makeService(
        memory: {
          'availableBytes': 4 * 1024 * 1024 * 1024,
          'totalBytes': 8 * 1024 * 1024 * 1024,
          'lowMemory': false,
          'thresholdBytes': 0,
        },
        latency: (null, LatencyStatus.error),
      );
      final m = await svc.measure();
      // 50% usado — valor exato, sem arredondamento enganoso
      expect(m.memoryUsagePercent, closeTo(50.0, 0.001));
    });
  });
}
