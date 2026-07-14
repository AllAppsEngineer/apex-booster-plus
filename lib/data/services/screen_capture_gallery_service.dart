import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class CapturedScreenshot {
  final String path;
  final DateTime capturedAt;
  final bool isVideo;

  const CapturedScreenshot({
    required this.path,
    required this.capturedAt,
    this.isVideo = false,
  });
}

/// Reads the capture indices written natively:
/// - apex_captures/index.json — screenshots (ScreenCaptureService.kt)
/// - apex_clips/index.json — short clips (SOCIAL-U7A, "type": "video")
/// Both live under getExternalFilesDir(...), which path_provider's
/// getExternalStorageDirectory() resolves to on Android.
class ScreenCaptureGalleryService {
  final Future<Directory?> Function() _resolveBaseDir;

  ScreenCaptureGalleryService({Future<Directory?> Function()? resolveBaseDir})
      : _resolveBaseDir = resolveBaseDir ?? getExternalStorageDirectory;

  Future<List<CapturedScreenshot>> listCaptures() async {
    try {
      final base = await _resolveBaseDir();
      if (base == null) return [];

      final result = <CapturedScreenshot>[
        ...await _readIndex(
          File('${base.path}/Pictures/apex_captures/index.json'),
        ),
        ...await _readIndex(
          File('${base.path}/Movies/apex_clips/index.json'),
        ),
      ];

      result.sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
      return result;
    } catch (_) {
      return [];
    }
  }

  /// Deletes the physical file and its index.json entry for [capture].
  /// Only touches files under the Apex-owned capture/clip directories.
  Future<bool> deleteCapture(CapturedScreenshot capture) async {
    try {
      final base = await _resolveBaseDir();
      if (base == null) return false;

      final indexFile = capture.isVideo
          ? File('${base.path}/Movies/apex_clips/index.json')
          : File('${base.path}/Pictures/apex_captures/index.json');

      final file = File(capture.path);
      if (await file.exists()) {
        await file.delete();
      }

      await _removeFromIndex(indexFile, capture.path);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _removeFromIndex(File indexFile, String path) async {
    if (!await indexFile.exists()) return;

    final decoded = jsonDecode(await indexFile.readAsString());
    if (decoded is! List) return;

    final updated = decoded
        .whereType<Map>()
        .where((item) => item['path'] != path)
        .toList();
    await indexFile.writeAsString(jsonEncode(updated));
  }

  Future<List<CapturedScreenshot>> _readIndex(File indexFile) async {
    try {
      if (!await indexFile.exists()) return [];

      final decoded = jsonDecode(await indexFile.readAsString());
      if (decoded is! List) return [];

      final result = <CapturedScreenshot>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        final path = item['path'];
        final timestamp = item['timestamp'];
        if (path is! String || timestamp is! int) continue;
        if (!await File(path).exists()) continue;
        result.add(CapturedScreenshot(
          path: path,
          capturedAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
          isVideo: item['type'] == 'video',
        ));
      }
      return result;
    } catch (_) {
      return [];
    }
  }
}
