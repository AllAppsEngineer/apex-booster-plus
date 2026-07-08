import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class CapturedScreenshot {
  final String path;
  final DateTime capturedAt;

  const CapturedScreenshot({required this.path, required this.capturedAt});
}

/// Reads the capture index written natively by ScreenCaptureService.kt after
/// each on-demand screenshot. The index lives at the same directory Android's
/// getExternalFilesDir(DIRECTORY_PICTURES) resolves to, which is exactly what
/// path_provider's getExternalStorageDirectory() returns on Android.
class ScreenCaptureGalleryService {
  final Future<Directory?> Function() _resolveBaseDir;

  ScreenCaptureGalleryService({Future<Directory?> Function()? resolveBaseDir})
      : _resolveBaseDir = resolveBaseDir ?? getExternalStorageDirectory;

  Future<List<CapturedScreenshot>> listCaptures() async {
    try {
      final base = await _resolveBaseDir();
      if (base == null) return [];

      final indexFile = File('${base.path}/Pictures/apex_captures/index.json');
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
        ));
      }

      result.sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
      return result;
    } catch (_) {
      return [];
    }
  }
}
