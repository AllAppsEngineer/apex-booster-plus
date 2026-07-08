import 'package:flutter/services.dart';

/// Controls Modo Captura da Sessão (SOCIAL-U2B): requests MediaProjection
/// once and arms a native foreground service that stays idle until the A+
/// mini-menu triggers an on-demand capture. No path is returned to Flutter —
/// the capture, save and feedback are entirely native.
class ScreenCaptureService {
  static const _channel = MethodChannel('apex/capture');

  /// Requests MediaProjection consent (Android system dialog) and arms the
  /// session capture service. Returns true if armed, false if denied,
  /// cancelled or a request is already in progress.
  Future<bool> armSession() async {
    try {
      return await _channel.invokeMethod<bool>('armSession') ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Stops the armed session and releases the MediaProjection.
  Future<void> disarmSession() async {
    try {
      await _channel.invokeMethod<void>('disarmSession');
    } on PlatformException {
      // no-op: session may already be stopped
    }
  }

  /// Returns whether a capture session is currently armed.
  Future<bool> isSessionArmed() async {
    try {
      return await _channel.invokeMethod<bool>('isSessionArmed') ?? false;
    } on PlatformException {
      return false;
    }
  }
}
