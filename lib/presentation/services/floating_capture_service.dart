import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FloatingCaptureService {
  static const _key = 'capture_float_enabled';
  static const _ch = MethodChannel('apex/overlay');

  static bool _isOverlayActive = false;
  static bool get isOverlayActive => _isOverlayActive;

  static final activeNotifier = ValueNotifier<bool>(false);

  static VoidCallback? _overlayTapCallback;

  static void setOverlayTapCallback(VoidCallback? cb) {
    _overlayTapCallback = cb;
    _ch.setMethodCallHandler((call) async {
      if (call.method == 'onOverlayTapped') {
        debugPrint('dart onOverlayTapped received');
        _overlayTapCallback?.call();
      }
    });
  }

  static bool isEnabled(SharedPreferences prefs) =>
      prefs.getBool(_key) ?? false;

  static Future<void> saveEnabled(SharedPreferences prefs, bool value) =>
      prefs.setBool(_key, value);

  static Future<bool> isPermissionGranted() async {
    try {
      return await _ch.invokeMethod<bool>('isOverlayPermissionGranted') ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> requestPermission() async {
    try {
      await _ch.invokeMethod<void>('openOverlayPermissionSettings');
    } on PlatformException {
      // no-op: falha silenciosa — caller não tem estado para tratar
    }
  }

  static Future<bool> enable(SharedPreferences prefs) async {
    try {
      final ok = await _ch.invokeMethod<bool>('showFloating') ?? false;
      if (ok) {
        await saveEnabled(prefs, true);
        _isOverlayActive = true;
        activeNotifier.value = true;
      }
      return ok;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> disable(SharedPreferences prefs) async {
    try {
      await _ch.invokeMethod<void>('hideFloating');
    } on PlatformException {
      // no-op: overlay pode já não existir
    }
    await saveEnabled(prefs, false);
    _isOverlayActive = false;
    activeNotifier.value = false;
  }

  static Future<bool> isOverlayShowing() async {
    try {
      return await _ch.invokeMethod<bool>('isFloatingShowing') ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> bringToForeground() async {
    try {
      await _ch.invokeMethod<void>('bringToForeground');
    } on PlatformException {
      // no-op
    }
  }
}
