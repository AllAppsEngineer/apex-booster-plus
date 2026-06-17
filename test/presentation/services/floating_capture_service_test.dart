import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/presentation/services/floating_capture_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('apex/overlay');

  void mockChannel(Map<String, dynamic Function(MethodCall)> handlers) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      final h = handlers[call.method];
      return h != null ? h(call) : null;
    });
  }

  void mockChannelDefault() => mockChannel({
        'isOverlayPermissionGranted': (_) => false,
        'showFloating': (_) => false,
        'hideFloating': (_) => null,
        'isFloatingShowing': (_) => false,
        'openOverlayPermissionSettings': (_) => null,
        'bringToForeground': (_) => null,
      });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockChannelDefault();
  });

  tearDown(() async {
    final prefs = await SharedPreferences.getInstance();
    await FloatingCaptureService.disable(prefs);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  // ─── Preferência ──────────────────────────────────────────────────────────

  test('isEnabled retorna false por padrão', () async {
    final prefs = await SharedPreferences.getInstance();
    expect(FloatingCaptureService.isEnabled(prefs), false);
  });

  test('saveEnabled true persiste', () async {
    final prefs = await SharedPreferences.getInstance();
    await FloatingCaptureService.saveEnabled(prefs, true);
    expect(FloatingCaptureService.isEnabled(prefs), true);
  });

  test('saveEnabled false persiste', () async {
    SharedPreferences.setMockInitialValues({'capture_float_enabled': true});
    final prefs = await SharedPreferences.getInstance();
    await FloatingCaptureService.saveEnabled(prefs, false);
    expect(FloatingCaptureService.isEnabled(prefs), false);
  });

  // ─── Estado estático ──────────────────────────────────────────────────────

  test('isOverlayActive é false por padrão', () {
    expect(FloatingCaptureService.isOverlayActive, false);
  });

  // ─── isPermissionGranted ──────────────────────────────────────────────────

  group('isPermissionGranted', () {
    test('retorna true quando channel retorna true', () async {
      mockChannel({'isOverlayPermissionGranted': (_) => true});
      expect(await FloatingCaptureService.isPermissionGranted(), isTrue);
    });

    test('retorna false quando channel retorna false', () async {
      expect(await FloatingCaptureService.isPermissionGranted(), isFalse);
    });

    test('retorna false em PlatformException', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              channel, (_) async => throw PlatformException(code: 'ERR'));
      expect(await FloatingCaptureService.isPermissionGranted(), isFalse);
    });
  });

  // ─── enable ───────────────────────────────────────────────────────────────

  group('enable', () {
    test('retorna false e não altera pref quando showFloating retorna false',
        () async {
      final prefs = await SharedPreferences.getInstance();
      final ok = await FloatingCaptureService.enable(prefs);
      expect(ok, isFalse);
      expect(FloatingCaptureService.isEnabled(prefs), isFalse);
      expect(FloatingCaptureService.isOverlayActive, isFalse);
      expect(FloatingCaptureService.activeNotifier.value, isFalse);
    });

    test('retorna true e salva pref quando showFloating retorna true', () async {
      mockChannel({'showFloating': (_) => true, 'hideFloating': (_) => null});
      final prefs = await SharedPreferences.getInstance();
      final ok = await FloatingCaptureService.enable(prefs);
      expect(ok, isTrue);
      expect(FloatingCaptureService.isEnabled(prefs), isTrue);
      expect(FloatingCaptureService.isOverlayActive, isTrue);
      expect(FloatingCaptureService.activeNotifier.value, isTrue);
    });

    test('retorna false em PlatformException', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              channel, (_) async => throw PlatformException(code: 'ERR'));
      final prefs = await SharedPreferences.getInstance();
      expect(await FloatingCaptureService.enable(prefs), isFalse);
    });
  });

  // ─── disable ──────────────────────────────────────────────────────────────

  group('disable', () {
    test('salva pref false e zera activeNotifier', () async {
      SharedPreferences.setMockInitialValues({'capture_float_enabled': true});
      final prefs = await SharedPreferences.getInstance();
      await FloatingCaptureService.disable(prefs);
      expect(FloatingCaptureService.isEnabled(prefs), isFalse);
      expect(FloatingCaptureService.isOverlayActive, isFalse);
      expect(FloatingCaptureService.activeNotifier.value, isFalse);
    });

    test('disable quando não ativo é idempotente e salva pref false', () async {
      SharedPreferences.setMockInitialValues({'capture_float_enabled': true});
      final prefs = await SharedPreferences.getInstance();
      await FloatingCaptureService.disable(prefs);
      expect(FloatingCaptureService.isEnabled(prefs), false);
      expect(FloatingCaptureService.isOverlayActive, false);
    });

    test('não propaga PlatformException de hideFloating', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              channel, (_) async => throw PlatformException(code: 'ERR'));
      final prefs = await SharedPreferences.getInstance();
      await expectLater(FloatingCaptureService.disable(prefs), completes);
    });
  });

  // ─── isOverlayShowing ─────────────────────────────────────────────────────

  group('isOverlayShowing', () {
    test('retorna false quando channel retorna false', () async {
      expect(await FloatingCaptureService.isOverlayShowing(), isFalse);
    });

    test('retorna true quando channel retorna true', () async {
      mockChannel({'isFloatingShowing': (_) => true});
      expect(await FloatingCaptureService.isOverlayShowing(), isTrue);
    });

    test('retorna false em PlatformException', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              channel, (_) async => throw PlatformException(code: 'ERR'));
      expect(await FloatingCaptureService.isOverlayShowing(), isFalse);
    });
  });

  // ─── requestPermission ────────────────────────────────────────────────────

  group('requestPermission', () {
    test('completa sem erro quando channel responde', () async {
      await expectLater(FloatingCaptureService.requestPermission(), completes);
    });

    test('não propaga PlatformException', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              channel, (_) async => throw PlatformException(code: 'ERR'));
      await expectLater(
          FloatingCaptureService.requestPermission(), completes);
    });
  });
}
