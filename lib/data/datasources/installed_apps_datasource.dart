import 'package:flutter/services.dart';
import 'package:apex_booster_plus/domain/entities/installed_app.dart';

class InstalledAppsDatasource {
  static const _channel =
      MethodChannel('com.allappsengineer.apex_booster_plus/apps');

  // Session-only caches — nothing is persisted to disk
  static final Map<String, Uint8List?> _iconCache = {};
  static List<InstalledApp>? _appsCache;

  Future<List<InstalledApp>> getInstalledApps() async {
    if (_appsCache != null) return List.unmodifiable(_appsCache!);
    final List<dynamic> raw =
        await _channel.invokeMethod('getInstalledApps');
    final list = raw
        .map((e) => InstalledApp.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    list.sort(
      (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()),
    );
    _appsCache = list;
    return List.unmodifiable(_appsCache!);
  }

  Future<Uint8List?> getAppIcon(String packageName) async {
    if (_iconCache.containsKey(packageName)) {
      return _iconCache[packageName];
    }
    try {
      final bytes = await _channel.invokeMethod<Uint8List>(
        'getAppIcon',
        {'packageName': packageName},
      );
      _iconCache[packageName] = bytes;
      return bytes;
    } catch (_) {
      _iconCache[packageName] = null;
      return null;
    }
  }

  /// Throws [PlatformException] with code 'APP_NOT_FOUND' if the app has no
  /// launcher intent, or code 'LAUNCH_ERROR' on unexpected failure.
  Future<void> launchApp(String packageName) async {
    await _channel.invokeMethod<void>(
      'launchApp',
      {'packageName': packageName},
    );
  }
}
