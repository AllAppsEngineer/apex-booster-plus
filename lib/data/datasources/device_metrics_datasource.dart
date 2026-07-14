import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import '../../domain/entities/device_metrics.dart';

class DeviceMetricsDatasource {
  static const _channel =
      MethodChannel('com.allappsengineer.apex_booster_plus/metrics');

  static const _primaryEndpoint =
      'https://clients3.google.com/generate_204';
  static const _fallbackEndpoint =
      'https://connectivitycheck.gstatic.com/generate_204';
  static const _timeoutSeconds = 5;

  Future<Map<String, dynamic>> getMemoryInfo() async {
    try {
      final raw = await _channel.invokeMethod<Map>('getMemoryInfo');
      if (raw == null) return _emptyMemory();
      return Map<String, dynamic>.from(raw);
    } catch (_) {
      return _emptyMemory();
    }
  }

  /// Returns the round-trip time in ms to reach a known endpoint,
  /// or null with an appropriate [LatencyStatus] on failure.
  /// Never throws — all failures are encapsulated in the return value.
  Future<(int?, LatencyStatus)> measureLatency() async {
    final primary = await _probeEndpoint(_primaryEndpoint);
    if (primary.$2 == LatencyStatus.success) return primary;
    // Timeout means the network is slow — no point retrying a fallback.
    if (primary.$2 == LatencyStatus.timeout) return primary;
    // Generic error (DNS, connection refused): try fallback once.
    return _probeEndpoint(_fallbackEndpoint);
  }

  Future<(int?, LatencyStatus)> _probeEndpoint(String url) async {
    final stopwatch = Stopwatch()..start();
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: _timeoutSeconds);
    try {
      final request = await client
          .headUrl(Uri.parse(url))
          .timeout(const Duration(seconds: _timeoutSeconds));
      final response = await request
          .close()
          .timeout(const Duration(seconds: _timeoutSeconds));
      await response.drain<void>();
      return (stopwatch.elapsedMilliseconds, LatencyStatus.success);
    } on TimeoutException {
      return (null, LatencyStatus.timeout);
    } on SocketException {
      return (null, LatencyStatus.noNetwork);
    } catch (_) {
      return (null, LatencyStatus.error);
    } finally {
      stopwatch.stop();
      client.close(force: true);
    }
  }

  Map<String, dynamic> _emptyMemory() => const {
        'availableBytes': 0,
        'totalBytes': 0,
        'lowMemory': false,
        'thresholdBytes': 0,
      };
}
