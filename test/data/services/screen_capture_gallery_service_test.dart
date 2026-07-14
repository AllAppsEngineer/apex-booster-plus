import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/data/services/screen_capture_gallery_service.dart';

void main() {
  late Directory tempDir;
  late Directory captureDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('apex_capture_gallery_test');
    captureDir = Directory('${tempDir.path}/Pictures/apex_captures');
    await captureDir.create(recursive: true);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

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
    Future<Directory> clipDir() async {
      final dir = Directory('${tempDir.path}/Movies/apex_clips');
      await dir.create(recursive: true);
      return dir;
    }

    Future<void> writeClipIndex(
        Directory dir, List<Map<String, dynamic>> entries) async {
      final indexFile = File('${dir.path}/index.json');
      await indexFile.writeAsString(jsonEncode(entries));
    }

    Future<File> writeClipFile(Directory dir, String name) async {
      final file = File('${dir.path}/$name');
      await file.writeAsBytes([0]);
      return file;
    }

    test('deletes screenshot file and removes its index.json entry',
        () async {
      final file = await writeCaptureFile('apex_cap_1.png');
      await writeIndex([
        {'path': file.path, 'timestamp': 1000},
      ]);

      final capture = CapturedScreenshot(
        path: file.path,
        capturedAt: DateTime.fromMillisecondsSinceEpoch(1000),
      );

      final ok = await makeService().deleteCapture(capture);

      expect(ok, isTrue);
      expect(await file.exists(), isFalse);
      final indexFile = File('${captureDir.path}/index.json');
      final decoded = jsonDecode(await indexFile.readAsString()) as List;
      expect(decoded, isEmpty);
    });

    test('deletes video file and removes entry from apex_clips index.json',
        () async {
      final clips = await clipDir();
      final file = await writeClipFile(clips, 'apex_clip_1.mp4');
      await writeClipIndex(clips, [
        {'path': file.path, 'timestamp': 1000, 'type': 'video'},
      ]);

      final capture = CapturedScreenshot(
        path: file.path,
        capturedAt: DateTime.fromMillisecondsSinceEpoch(1000),
        isVideo: true,
      );

      final ok = await makeService().deleteCapture(capture);

      expect(ok, isTrue);
      expect(await file.exists(), isFalse);
      final indexFile = File('${clips.path}/index.json');
      final decoded = jsonDecode(await indexFile.readAsString()) as List;
      expect(decoded, isEmpty);
    });

    test('removes broken index entry without crashing when file already gone',
        () async {
      final file = await writeCaptureFile('apex_cap_gone.png');
      await writeIndex([
        {'path': file.path, 'timestamp': 1000},
      ]);
      await file.delete();

      final capture = CapturedScreenshot(
        path: file.path,
        capturedAt: DateTime.fromMillisecondsSinceEpoch(1000),
      );

      final ok = await makeService().deleteCapture(capture);

      expect(ok, isTrue);
      final indexFile = File('${captureDir.path}/index.json');
      final decoded = jsonDecode(await indexFile.readAsString()) as List;
      expect(decoded, isEmpty);
    });

    test('does not affect other entries or files in the same index',
        () async {
      final keep = await writeCaptureFile('apex_cap_keep.png');
      final remove = await writeCaptureFile('apex_cap_remove.png');
      await writeIndex([
        {'path': keep.path, 'timestamp': 1000},
        {'path': remove.path, 'timestamp': 2000},
      ]);

      final capture = CapturedScreenshot(
        path: remove.path,
        capturedAt: DateTime.fromMillisecondsSinceEpoch(2000),
      );

      final ok = await makeService().deleteCapture(capture);

      expect(ok, isTrue);
      expect(await keep.exists(), isTrue);
      expect(await remove.exists(), isFalse);
      final indexFile = File('${captureDir.path}/index.json');
      final decoded = jsonDecode(await indexFile.readAsString()) as List;
      expect(decoded, hasLength(1));
      expect((decoded.first as Map)['path'], keep.path);
    });

    test('returns false when base directory resolves to null', () async {
      final service = ScreenCaptureGalleryService(resolveBaseDir: () async => null);
      final capture = CapturedScreenshot(
        path: '${captureDir.path}/whatever.png',
        capturedAt: DateTime.fromMillisecondsSinceEpoch(1000),
      );

      expect(await service.deleteCapture(capture), isFalse);
    });
  });
}
