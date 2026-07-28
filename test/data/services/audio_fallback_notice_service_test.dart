import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/data/services/audio_fallback_notice_service.dart';
import 'package:apex_booster_plus/data/services/screen_capture_gallery_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Directory clipsDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('apex_audio_fallback_test');
    clipsDir = Directory('${tempDir.path}/Movies/apex_clips');
    await clipsDir.create(recursive: true);
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<File> writeClipFile(String name) async {
    final file = File('${clipsDir.path}/$name');
    await file.writeAsBytes([0]);
    return file;
  }

  Future<void> writeIndex(List<Map<String, dynamic>> entries) async {
    final indexFile = File('${clipsDir.path}/index.json');
    await indexFile.writeAsString(jsonEncode(entries));
  }

  AudioFallbackNoticeService makeService() => AudioFallbackNoticeService(
        galleryService:
            ScreenCaptureGalleryService(resolveBaseDir: () async => tempDir),
      );

  group('checkPending', () {
    test('returns null when there is no video clip', () async {
      expect(await makeService().checkPending(), isNull);
    });

    test('returns null when the newest clip has audio', () async {
      final file = await writeClipFile('a.mp4');
      await writeIndex([
        {
          'path': file.path,
          'timestamp': 1000,
          'type': 'video',
          'id': 'clip-1',
          'audioState': 'READY_WITH_AUDIO',
        },
      ]);

      expect(await makeService().checkPending(), isNull);
    });

    test(
        'returns null when READY_WITHOUT_AUDIO but reason is not SOURCE_SILENT_OR_UNAVAILABLE',
        () async {
      final file = await writeClipFile('a.mp4');
      await writeIndex([
        {
          'path': file.path,
          'timestamp': 1000,
          'type': 'video',
          'id': 'clip-1',
          'audioState': 'READY_WITHOUT_AUDIO',
          'audioOutcomeReason': 'PERMISSION_DENIED',
        },
      ]);

      expect(await makeService().checkPending(), isNull);
    });

    test('returns null when audioOutcomeReason is absent (legacy entry)', () async {
      final file = await writeClipFile('a.mp4');
      await writeIndex([
        {
          'path': file.path,
          'timestamp': 1000,
          'type': 'video',
          'id': 'clip-1',
          'audioState': 'READY_WITHOUT_AUDIO',
        },
      ]);

      expect(await makeService().checkPending(), isNull);
    });

    test(
        'returns a pending notice for READY_WITHOUT_AUDIO + SOURCE_SILENT_OR_UNAVAILABLE',
        () async {
      final file = await writeClipFile('a.mp4');
      await writeIndex([
        {
          'path': file.path,
          'timestamp': 1000,
          'type': 'video',
          'id': 'clip-1',
          'audioState': 'READY_WITHOUT_AUDIO',
          'audioOutcomeReason': 'SOURCE_SILENT_OR_UNAVAILABLE',
        },
      ]);

      final notice = await makeService().checkPending();

      expect(notice, isNotNull);
      expect(notice!.clipId, 'clip-1');
    });

    test('returns null when the clip id was already marked seen', () async {
      final file = await writeClipFile('a.mp4');
      await writeIndex([
        {
          'path': file.path,
          'timestamp': 1000,
          'type': 'video',
          'id': 'clip-1',
          'audioState': 'READY_WITHOUT_AUDIO',
          'audioOutcomeReason': 'SOURCE_SILENT_OR_UNAVAILABLE',
        },
      ]);
      final service = makeService();
      await service.markSeen('clip-1');

      expect(await service.checkPending(), isNull);
    });

    test('re-surfaces once a NEW clip id matches the criteria', () async {
      final file = await writeClipFile('a.mp4');
      await writeIndex([
        {
          'path': file.path,
          'timestamp': 1000,
          'type': 'video',
          'id': 'clip-1',
          'audioState': 'READY_WITHOUT_AUDIO',
          'audioOutcomeReason': 'SOURCE_SILENT_OR_UNAVAILABLE',
        },
      ]);
      final service = makeService();
      await service.markSeen('clip-1');
      expect(await service.checkPending(), isNull);

      final newerFile = await writeClipFile('b.mp4');
      await writeIndex([
        {
          'path': file.path,
          'timestamp': 1000,
          'type': 'video',
          'id': 'clip-1',
          'audioState': 'READY_WITHOUT_AUDIO',
          'audioOutcomeReason': 'SOURCE_SILENT_OR_UNAVAILABLE',
        },
        {
          'path': newerFile.path,
          'timestamp': 2000,
          'type': 'video',
          'id': 'clip-2',
          'audioState': 'READY_WITHOUT_AUDIO',
          'audioOutcomeReason': 'SOURCE_SILENT_OR_UNAVAILABLE',
        },
      ]);

      final notice = await service.checkPending();
      expect(notice, isNotNull);
      expect(notice!.clipId, 'clip-2');
    });

    test('ignores a screenshot even if newer than the video clip', () async {
      final videoFile = await writeClipFile('a.mp4');
      final capturesDir = Directory('${tempDir.path}/Pictures/apex_captures');
      await capturesDir.create(recursive: true);
      final shotFile = File('${capturesDir.path}/shot.png');
      await shotFile.writeAsBytes([0]);
      await File('${capturesDir.path}/index.json').writeAsString(
        jsonEncode([
          {'path': shotFile.path, 'timestamp': 5000},
        ]),
      );
      await writeIndex([
        {
          'path': videoFile.path,
          'timestamp': 1000,
          'type': 'video',
          'id': 'clip-1',
          'audioState': 'READY_WITHOUT_AUDIO',
          'audioOutcomeReason': 'SOURCE_SILENT_OR_UNAVAILABLE',
        },
      ]);

      final notice = await makeService().checkPending();
      expect(notice, isNotNull);
      expect(notice!.clipId, 'clip-1');
    });
  });
}
