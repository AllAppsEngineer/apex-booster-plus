import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class CapturedScreenshot {
  final String path;
  final DateTime capturedAt;
  final bool isVideo;
  final String? id;
  // AUDIO-FALLBACK-UX-U1.1: mirrors ClipEntry.audioState/audioOutcomeReason
  // (Kotlin/ClipIndexMutator) verbatim — null on screenshots, on legacy
  // entries written before either field existed, and on entries not yet
  // resolved to a terminal state.
  final String? audioState;
  final String? audioOutcomeReason;

  const CapturedScreenshot({
    required this.path,
    required this.capturedAt,
    this.isVideo = false,
    this.id,
    this.audioState,
    this.audioOutcomeReason,
  });
}

/// Reads the capture indices written natively:
/// - apex_captures/index.json — screenshots (ScreenCaptureService.kt)
/// - apex_clips/index.json — short clips (SOCIAL-U7A, "type": "video")
/// Both live under getExternalFilesDir(...), which path_provider's
/// getExternalStorageDirectory() resolves to on Android.
///
/// AUDIO-CAPTURE-U2.4: Kotlin/native (ClipIndexStore) is the only writer of
/// these index.json files. Reading stays here (never mutates the index);
/// deletion is requested through the "apex/gallery" MethodChannel instead of
/// touching index.json directly.
class ScreenCaptureGalleryService {
  static const _channel = MethodChannel('apex/gallery');

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

  /// Requests native deletion of the physical file and its index.json entry
  /// for [capture] via the "apex/gallery" MethodChannel. Kotlin resolves the
  /// entry (by [CapturedScreenshot.id] when present, by path only as a
  /// fallback for legacy entries without an id) and deletes the physical
  /// file using the path stored in the index itself — this service never
  /// touches index.json or the capture file directly.
  Future<bool> deleteCapture(CapturedScreenshot capture) async {
    try {
      final result = await _channel.invokeMethod<Map>('deleteEntry', {
        'kind': capture.isVideo ? 'video' : 'screenshot',
        'path': capture.path,
        'id': capture.id,
      });
      final status = result?['status'];
      // 'not_found' is treated as success too: the entry is already gone
      // from the index either way, which is what the caller cares about.
      return status == 'success' || status == 'not_found';
    } on PlatformException {
      return false;
    }
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
        final id = item['id'];
        final audioState = item['audioState'];
        final audioOutcomeReason = item['audioOutcomeReason'];
        result.add(CapturedScreenshot(
          path: path,
          capturedAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
          isVideo: item['type'] == 'video',
          id: id is String ? id : null,
          audioState: audioState is String ? audioState : null,
          audioOutcomeReason:
              audioOutcomeReason is String ? audioOutcomeReason : null,
        ));
      }
      return result;
    } catch (_) {
      return [];
    }
  }
}
