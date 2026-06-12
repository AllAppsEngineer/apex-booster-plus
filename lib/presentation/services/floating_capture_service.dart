import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SOCIAL-U2A-RESET: flutter_overlay_window removed. All overlay methods are
// stubs until SOCIAL-U2A-NATIVE implements the Kotlin WindowManager approach.
class FloatingCaptureService {
  static const _key = 'capture_float_enabled';

  static bool _isOverlayActive = false;
  static bool get isOverlayActive => _isOverlayActive;

  static final activeNotifier = ValueNotifier<bool>(false);

  static bool isEnabled(SharedPreferences prefs) =>
      prefs.getBool(_key) ?? false;

  static Future<void> saveEnabled(SharedPreferences prefs, bool value) =>
      prefs.setBool(_key, value);

  static Future<bool> isPermissionGranted() async => false;

  static Future<void> requestPermission() async {}

  static Future<bool> enable(SharedPreferences prefs) async {
    debugPrint('[FloatingCapture] overlay unavailable (SOCIAL-U2A-RESET)');
    return false;
  }

  static Future<void> disable(SharedPreferences prefs) async {
    await saveEnabled(prefs, false);
    _isOverlayActive = false;
    activeNotifier.value = false;
  }

  static Future<void> bringToForeground() async {}
}
