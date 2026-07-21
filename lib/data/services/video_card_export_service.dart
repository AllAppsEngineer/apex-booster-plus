import 'package:flutter/services.dart';

/// Fit mode applied to the video inside its measured media-slot rect
/// (STUDIO-U3) — mirrors the existing Preencher/Encaixar chips already
/// controlling `_imageFit` in the Studio screen.
enum VideoCardFit { cover, contain }

/// Thrown when native composition fails — callers must surface this to the
/// user, never silently fall back to sharing a PNG/thumbnail instead.
class VideoCardExportException implements Exception {
  final String code;
  final String? message;

  VideoCardExportException(this.code, this.message);

  @override
  String toString() => 'VideoCardExportException($code, $message)';
}

/// STUDIO-U3-PROOF-FIX: [outputPath] is the validated, branded MP4 — the only
/// path callers may hand to `share_plus`. [debugFramePath] is a still frame
/// extracted from the middle of that same MP4 by the native side (see
/// VideoCardExporter.kt's `extractDebugFrame`), saved for manual visual proof
/// that the branding/chrome is actually present in the output — `null` only
/// if frame extraction itself failed (a diagnostic-only step; it never fails
/// the export).
class VideoCardExportResult {
  final String outputPath;
  final String? debugFramePath;

  const VideoCardExportResult({required this.outputPath, this.debugFramePath});
}

/// Composes a branded MP4 (source video + Apex chrome overlay positioned at
/// the measured media-slot rect) via the native Media3 Transformer pipeline
/// (STUDIO-U3). See VideoCardExporter.kt for the composition design.
class VideoCardExportService {
  static const _channel = MethodChannel('apex/video_export');

  /// Composes the final MP4. [slotX]/[slotY]/[slotW]/[slotH] and
  /// [canvasW]x[canvasH] are all in the same pixel space as the fixed hidden
  /// overlay capture canvas (1080x1920 or 1080x1080 — see
  /// share_studio_screen.dart's `_exportVideo()`). Throws
  /// [VideoCardExportException] on native failure (invalid args, video too
  /// long, probe/compose error); the caller is responsible for any timeout
  /// wrapping.
  Future<VideoCardExportResult> composeVideoCard({
    required String videoPath,
    required String overlayPath,
    required String backgroundPath,
    required String outputPath,
    required int slotX,
    required int slotY,
    required int slotW,
    required int slotH,
    required int canvasW,
    required int canvasH,
    required VideoCardFit fit,
  }) async {
    try {
      final raw = await _channel.invokeMethod<Map<Object?, Object?>>('composeVideoCard', {
        'videoPath': videoPath,
        'overlayPath': overlayPath,
        'backgroundPath': backgroundPath,
        'outputPath': outputPath,
        'slotX': slotX,
        'slotY': slotY,
        'slotW': slotW,
        'slotH': slotH,
        'canvasW': canvasW,
        'canvasH': canvasH,
        'fitMode': fit == VideoCardFit.contain ? 'contain' : 'cover',
      });
      final path = raw?['outputPath'] as String?;
      if (path == null || path.isEmpty) {
        throw VideoCardExportException('NO_OUTPUT', 'native returned no output path');
      }
      return VideoCardExportResult(
        outputPath: path,
        debugFramePath: raw?['debugFramePath'] as String?,
      );
    } on PlatformException catch (e) {
      throw VideoCardExportException(e.code, e.message);
    }
  }

  /// Best-effort cancellation of an in-flight compose (used by the Dart-side
  /// safety timeout) — never throws, the compose call's own error handling
  /// is the source of truth for the UI.
  Future<void> cancelVideoExport() async {
    try {
      await _channel.invokeMethod<void>('cancelVideoExport');
    } on PlatformException {
      // no-op: nothing in flight, or already finished
    }
  }
}
