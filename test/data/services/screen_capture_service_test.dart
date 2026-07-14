import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/data/services/screen_capture_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('apex/capture');
  MethodCall? lastCall;

  void mockChannel(Map<String, dynamic Function(MethodCall)> handlers) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      lastCall = call;
      final h = handlers[call.method];
      return h != null ? h(call) : null;
    });
  }

  setUp(() {
    lastCall = null;
    mockChannel({'armSession': (_) => true});
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('kVideoDurationOptionsSeconds', () {
    test('contains exactly the four approved durations in order', () {
      expect(kVideoDurationOptionsSeconds, [10, 15, 30, 60]);
    });
  });

  group('armSession', () {
    test('sends mode and durationSeconds=10 by default', () async {
      final ok =
          await ScreenCaptureService().armSession(mode: CaptureMode.video);
      expect(ok, isTrue);
      expect(lastCall!.method, 'armSession');
      expect(lastCall!.arguments, {'mode': 'video', 'durationSeconds': 10});
    });

    test('sends the chosen durationSeconds', () async {
      await ScreenCaptureService().armSession(
        mode: CaptureMode.video,
        durationSeconds: 30,
      );
      expect(lastCall!.arguments, {'mode': 'video', 'durationSeconds': 30});
    });

    test('sends durationSeconds even for screenshot mode', () async {
      await ScreenCaptureService().armSession(mode: CaptureMode.screenshot);
      expect(
        lastCall!.arguments,
        {'mode': 'screenshot', 'durationSeconds': 10},
      );
    });

    test('returns false on PlatformException', () async {
      mockChannel({
        'armSession': (_) => throw PlatformException(code: 'ERR'),
      });
      final ok =
          await ScreenCaptureService().armSession(mode: CaptureMode.video);
      expect(ok, isFalse);
    });
  });
}
