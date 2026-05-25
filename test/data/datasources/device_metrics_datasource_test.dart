import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/data/datasources/device_metrics_datasource.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel =
      MethodChannel('com.allappsengineer.apex_booster_plus/metrics');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('DeviceMetricsDatasource.getMemoryInfo', () {
    test('retorna dados de memória do canal', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'getMemoryInfo') {
          return {
            'availableBytes': 2000000000,
            'totalBytes': 8000000000,
            'lowMemory': false,
            'thresholdBytes': 500000000,
          };
        }
        return null;
      });

      final ds = DeviceMetricsDatasource();
      final result = await ds.getMemoryInfo();

      expect(result['availableBytes'], 2000000000);
      expect(result['totalBytes'], 8000000000);
      expect(result['lowMemory'], false);
      expect(result['thresholdBytes'], 500000000);
    });

    test('retorna memória zerada quando canal lança PlatformException', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(
            code: 'MEMORY_ERROR', message: 'simulated error');
      });

      final ds = DeviceMetricsDatasource();
      final result = await ds.getMemoryInfo();

      expect(result['availableBytes'], 0);
      expect(result['totalBytes'], 0);
      expect(result['lowMemory'], false);
      expect(result['thresholdBytes'], 0);
    });

    test('retorna memória zerada quando canal retorna null', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => null);

      final ds = DeviceMetricsDatasource();
      final result = await ds.getMemoryInfo();

      expect(result['availableBytes'], 0);
      expect(result['totalBytes'], 0);
    });

    test('retorna memória zerada quando canal lança exceção genérica', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        throw Exception('unexpected');
      });

      final ds = DeviceMetricsDatasource();
      final result = await ds.getMemoryInfo();

      expect(result['availableBytes'], 0);
      expect(result['totalBytes'], 0);
    });

    test('retorna lowMemory true quando canal informa pressão de memória', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'getMemoryInfo') {
          return {
            'availableBytes': 100000000,
            'totalBytes': 4000000000,
            'lowMemory': true,
            'thresholdBytes': 150000000,
          };
        }
        return null;
      });

      final ds = DeviceMetricsDatasource();
      final result = await ds.getMemoryInfo();

      expect(result['lowMemory'], true);
    });
  });
}
