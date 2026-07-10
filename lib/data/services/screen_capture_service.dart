import 'package:flutter/services.dart';

/// Modo Captura da Sessão is print XOR video, chosen before arming
/// (SOCIAL-U7A, Opção B) — a single MediaProjection instance can only back
/// one VirtualDisplay for its whole lifetime on Android 14+.
enum CaptureMode { screenshot, video }

/// Fixed set of selectable video-recording durations, in seconds
/// (SOCIAL-U7B). The native side re-validates against this exact list
/// before starting a recording — see ScreenCaptureService.kt's
/// ALLOWED_VIDEO_DURATIONS_MS.
const List<int> kVideoDurationOptionsSeconds = [10, 15, 30, 60];

/// Controls Modo Captura da Sessão (SOCIAL-U2B): requests MediaProjection
/// once and arms a native foreground service that stays idle until the A+
/// mini-menu triggers an on-demand capture. No path is returned to Flutter —
/// the capture, save and feedback are entirely native.
class ScreenCaptureService {
  static const _channel = MethodChannel('apex/capture');

  /// Requests MediaProjection consent (Android system dialog) and arms the
  /// session capture service in the given [mode]. [durationSeconds] caps a
  /// video recording (SOCIAL-U7B) — must be one of
  /// [kVideoDurationOptionsSeconds] — and is ignored natively for
  /// screenshot mode. Returns true if armed, false if denied, cancelled or
  /// a request is already in progress.
  Future<bool> armSession({
    required CaptureMode mode,
    int durationSeconds = 10,
  }) async {
    try {
      return await _channel.invokeMethod<bool>('armSession', {
            'mode': mode.name,
            'durationSeconds': durationSeconds,
          }) ??
          false;
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
