import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/domain/entities/installed_app.dart';

class InstalledAppsDatasource {
  static const _channel =
      MethodChannel('com.allappsengineer.apex_booster_plus/apps');

  static const String _iconPrefPrefix = 'apex_icon_b64_';

  // Session-only caches — nothing is persisted to disk
  static final Map<String, Uint8List?> _iconCache = {};
  static List<InstalledApp>? _appsCache;
  static Future<List<InstalledApp>>? _loadingFuture;

  Future<List<InstalledApp>> getInstalledApps() {
    if (_appsCache != null) return Future.value(List.unmodifiable(_appsCache!));
    return _loadingFuture ??= _doLoad();
  }

  Future<List<InstalledApp>> _doLoad() async {
    try {
      final List<dynamic> raw =
          await _channel.invokeMethod('getInstalledApps');
      final list = raw
          .map((e) => InstalledApp.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      list.sort(
        (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()),
      );
      _appsCache = list;
      return List.unmodifiable(list);
    } catch (_) {
      _loadingFuture = null;
      rethrow;
    }
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

  /// Reads icon bytes from [prefs] and populates the in-memory cache so that
  /// [getAppIcon] returns instantly on the next call — no MethodChannel needed.
  /// Returns cached bytes on hit, null on miss. Synchronous after prefs init.
  static Uint8List? preCacheFromPrefs(
      SharedPreferences prefs, String packageName) {
    final raw = prefs.getString('$_iconPrefPrefix$packageName');
    if (raw == null) return null;
    try {
      final bytes = base64Decode(raw);
      _iconCache[packageName] = bytes;
      return bytes;
    } catch (_) {
      return null;
    }
  }

  /// Persists icon bytes to [prefs] so the next cold start can skip MethodChannel.
  static Future<void> saveIconToPrefs(
      SharedPreferences prefs, String packageName, Uint8List bytes) async {
    await prefs.setString(
        '$_iconPrefPrefix$packageName', base64Encode(bytes));
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
