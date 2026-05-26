import 'package:flutter/services.dart';

import '../../domain/services/focus_mode_service.dart';

class FocusModeServiceImpl implements FocusModeService {
  static const _channel =
      MethodChannel('com.allappsengineer.apex_booster_plus/focus_mode');

  @override
  Future<bool> isPermissionGranted() async {
    try {
      final result = await _channel.invokeMethod<bool>('isPermissionGranted');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<void> openSettings() async {
    try {
      await _channel.invokeMethod<void>('openSettings');
    } on PlatformException {
      // fire-and-forget — caller has no state to handle here
    }
  }

  @override
  Future<FocusModeResult> saveAndEnable() async {
    final hasPermission = await isPermissionGranted();
    if (!hasPermission) return FocusModeResult.noPermission;
    try {
      await _channel.invokeMethod<void>('saveAndEnable');
      return FocusModeResult.success;
    } on PlatformException {
      return FocusModeResult.error;
    }
  }

  @override
  Future<FocusModeResult> restore() async {
    try {
      final wasActive = await _channel.invokeMethod<bool>('restore');
      return (wasActive ?? false) ? FocusModeResult.success : FocusModeResult.notActive;
    } on PlatformException {
      return FocusModeResult.error;
    }
  }
}
