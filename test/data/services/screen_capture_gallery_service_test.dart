import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/data/services/screen_capture_gallery_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Directory captureDir;

  const channel = MethodChannel('apex/gallery');

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('apex_capture_gallery_test');
    captureDir = Directory('${tempDir.path}/Pictures/apex_captures');
    await captureDir.create(recursive: true);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  void mockChannel(Future<dynamic> Function(MethodCall) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, handler);
  }

  ScreenCaptureGalleryService makeService() =>
      ScreenCaptureGalleryService(resolveBaseDir: () async => tempDir);

  Future<void> writeIndex(List<Map<String, dynamic>> entries) async {
    final indexFile = File('${captureDir.path}/index.json');
    await indexFile.writeAsString(jsonEncode(entries));
  }

  Future<File> writeCaptureFile(String name) async {
    final file = File('${captureDir.path}/$name');
    await file.writeAsBytes([0]);
    return file;
  }

  group('listCaptures', () {
    test('returns empty list when index.json does not exist', () async {
      expect(await makeService().listCaptures(), isEmpty);
    });

    test('returns empty list when base directory resolves to null', () async {
      final service = ScreenCaptureGalleryService(resolveBaseDir: () async => null);
      expect(await service.listCaptures(), isEmpty);
    });

    test('parses valid entries whose files exist', () async {
      final file = await writeCaptureFile('apex_cap_1.png');
      await writeIndex([
        {'path': file.path, 'timestamp': 1000},
      ]);

      final result = await makeService().listCaptures();

      expect(result, hasLength(1));
      expect(result.first.path, file.path);
      expect(result.first.capturedAt, DateTime.fromMillisecondsSinceEpoch(1000));
    });

    test('parses the id field when present', () async {
      final file = await writeCaptureFile('apex_cap_1.png');
      await writeIndex([
        {'path': file.path, 'timestamp': 1000, 'id': 'abc-123'},
      ]);

      final result = await makeService().listCaptures();

      expect(result.first.id, 'abc-123');
    });

    test('leaves id null for legacy entries without it', () async {
      final file = await writeCaptureFile('apex_cap_1.png');
      await writeIndex([
        {'path': file.path, 'timestamp': 1000},
      ]);

      final result = await makeService().listCaptures();

      expect(result.first.id, isNull);
    });

    test('parses audioState and audioOutcomeReason when present', () async {
      final file = await writeCaptureFile('apex_clip_1.mp4');
      await writeIndex([
        {
          'path': file.path,
          'timestamp': 1000,
          'type': 'video',
          'audioState': 'READY_WITHOUT_AUDIO',
          'audioOutcomeReason': 'SOURCE_SILENT_OR_UNAVAILABLE',
        },
      ]);

      final result = await makeService().listCaptures();

      expect(result.first.audioState, 'READY_WITHOUT_AUDIO');
      expect(result.first.audioOutcomeReason, 'SOURCE_SILENT_OR_UNAVAILABLE');
    });

    test('leaves audioState and audioOutcomeReason null for legacy entries', () async {
      final file = await writeCaptureFile('apex_clip_1.mp4');
      await writeIndex([
        {'path': file.path, 'timestamp': 1000, 'type': 'video'},
      ]);

      final result = await makeService().listCaptures();

      expect(result.first.audioState, isNull);
      expect(result.first.audioOutcomeReason, isNull);
    });

    test('drops entries whose file no longer exists on disk', () async {
      await writeIndex([
        {'path': '${captureDir.path}/missing.png', 'timestamp': 1000},
      ]);

      expect(await makeService().listCaptures(), isEmpty);
    });

    test('drops malformed entries without throwing', () async {
      final file = await writeCaptureFile('apex_cap_ok.png');
      await writeIndex([
        {'path': 123, 'timestamp': 1000},
        {'timestamp': 1000},
        {'path': file.path, 'timestamp': 'not-a-number'},
        {'path': file.path, 'timestamp': 2000},
      ]);

      final result = await makeService().listCaptures();

      expect(result, hasLength(1));
      expect(result.first.path, file.path);
    });

    test('returns empty list when index.json is not valid JSON', () async {
      final indexFile = File('${captureDir.path}/index.json');
      await indexFile.writeAsString('not json');

      expect(await makeService().listCaptures(), isEmpty);
    });

    test('sorts newest capture first', () async {
      final older = await writeCaptureFile('apex_cap_older.png');
      final newer = await writeCaptureFile('apex_cap_newer.png');
      await writeIndex([
        {'path': older.path, 'timestamp': 1000},
        {'path': newer.path, 'timestamp': 2000},
      ]);

      final result = await makeService().listCaptures();

      expect(result.map((c) => c.path).toList(), [newer.path, older.path]);
    });
  });

  group('deleteCapture', () {
    test('invokes deleteEntry with kind=screenshot and no id', () async {
      MethodCall? received;
      mockChannel((call) async {
        received = call;
        return {'status': 'success'};
      });

      final capture = CapturedScreenshot(
        path: '${captureDir.path}/apex_cap_1.png',
        capturedAt: DateTime.fromMillisecondsSinceEpoch(1000),
      );

      final ok = await makeService().deleteCapture(capture);

      expect(ok, isTrue);
      expect(received?.method, 'deleteEntry');
      expect(received?.arguments['kind'], 'screenshot');
      expect(received?.arguments['path'], capture.path);
      expect(received?.arguments['id'], isNull);
    });

    test('invokes deleteEntry with kind=video and id when present', () async {
      MethodCall? received;
      mockChannel((call) async {
        received = call;
        return {'status': 'success'};
      });

      final capture = CapturedScreenshot(
        path: '${tempDir.path}/Movies/apex_clips/apex_clip_1.mp4',
        capturedAt: DateTime.fromMillisecondsSinceEpoch(1000),
        isVideo: true,
        id: 'abc-123',
      );

      await makeService().deleteCapture(capture);

      expect(received?.arguments['kind'], 'video');
      expect(received?.arguments['id'], 'abc-123');
    });

    test('returns true when the channel reports success', () async {
      mockChannel((call) async => {'status': 'success'});
      final capture = CapturedScreenshot(
        path: '${captureDir.path}/apex_cap_1.png',
        capturedAt: DateTime.fromMillisecondsSinceEpoch(1000),
      );

      expect(await makeService().deleteCapture(capture), isTrue);
    });

    test('returns true (idempotent) when the channel reports not_found', () async {
      mockChannel((call) async => {'status': 'not_found'});
      final capture = CapturedScreenshot(
        path: '${captureDir.path}/apex_cap_1.png',
        capturedAt: DateTime.fromMillisecondsSinceEpoch(1000),
      );

      expect(await makeService().deleteCapture(capture), isTrue);
    });

    test('returns false when the channel throws PlatformException', () async {
      mockChannel((call) async {
        throw PlatformException(code: 'DELETE_FAILED');
      });
      final capture = CapturedScreenshot(
        path: '${captureDir.path}/apex_cap_1.png',
        capturedAt: DateTime.fromMillisecondsSinceEpoch(1000),
      );

      expect(await makeService().deleteCapture(capture), isFalse);
    });

    test('does not write to index.json or touch the file itself', () async {
      final file = await writeCaptureFile('apex_cap_1.png');
      await writeIndex([
        {'path': file.path, 'timestamp': 1000},
      ]);
      mockChannel((call) async => {'status': 'success'});

      final capture = CapturedScreenshot(
        path: file.path,
        capturedAt: DateTime.fromMillisecondsSinceEpoch(1000),
      );
      await makeService().deleteCapture(capture);

      // Deletion is entirely delegated to the channel handler (mocked here
      // as a no-op on disk) — the service itself never calls File.delete()
      // or writes index.json, so both are untouched by this call.
      expect(await file.exists(), isTrue);
      final indexFile = File('${captureDir.path}/index.json');
      final decoded = jsonDecode(await indexFile.readAsString()) as List;
      expect(decoded, hasLength(1));
    });
  });
}
