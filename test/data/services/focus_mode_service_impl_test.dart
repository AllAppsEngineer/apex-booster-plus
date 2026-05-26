import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/data/services/focus_mode_service_impl.dart';
import 'package:apex_booster_plus/domain/services/focus_mode_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('apex_booster_plus/focus_mode');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  void mockChannel(Future<dynamic> Function(MethodCall) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, handler);
  }

  FocusModeServiceImpl makeService() => FocusModeServiceImpl();

  group('isPermissionGranted', () {
    test('retorna true quando Android retorna true', () async {
      mockChannel((call) async {
        if (call.method == 'isPermissionGranted') return true;
      });
      expect(await makeService().isPermissionGranted(), isTrue);
    });

    test('retorna false quando Android retorna false', () async {
      mockChannel((call) async {
        if (call.method == 'isPermissionGranted') return false;
      });
      expect(await makeService().isPermissionGranted(), isFalse);
    });

    test('retorna false em PlatformException', () async {
      mockChannel((call) async {
        throw PlatformException(code: 'ERROR');
      });
      expect(await makeService().isPermissionGranted(), isFalse);
    });
  });

  group('openSettings', () {
    test('completa sem erro quando channel responde', () async {
      mockChannel((call) async => null);
      await expectLater(makeService().openSettings(), completes);
    });

    test('não propaga PlatformException para o caller', () async {
      mockChannel((call) async {
        throw PlatformException(code: 'ERROR');
      });
      await expectLater(makeService().openSettings(), completes);
    });
  });

  group('saveAndEnable', () {
    test('retorna noPermission sem chamar channel quando permissão ausente',
        () async {
      final calls = <String>[];
      mockChannel((call) async {
        calls.add(call.method);
        if (call.method == 'isPermissionGranted') return false;
      });
      final result = await makeService().saveAndEnable();
      expect(result, FocusModeResult.noPermission);
      expect(calls, isNot(contains('saveAndEnable')));
    });

    test('retorna success quando permissão existe e channel responde', () async {
      mockChannel((call) async {
        if (call.method == 'isPermissionGranted') return true;
        if (call.method == 'saveAndEnable') return null;
      });
      expect(await makeService().saveAndEnable(), FocusModeResult.success);
    });

    test('retorna error quando channel lança PlatformException', () async {
      mockChannel((call) async {
        if (call.method == 'isPermissionGranted') return true;
        throw PlatformException(code: 'ERROR');
      });
      expect(await makeService().saveAndEnable(), FocusModeResult.error);
    });
  });

  group('restore', () {
    test('retorna success quando Android retorna true', () async {
      mockChannel((call) async {
        if (call.method == 'restore') return true;
      });
      expect(await makeService().restore(), FocusModeResult.success);
    });

    test('retorna notActive quando Android retorna false', () async {
      mockChannel((call) async {
        if (call.method == 'restore') return false;
      });
      expect(await makeService().restore(), FocusModeResult.notActive);
    });

    test('retorna notActive quando Android retorna null', () async {
      mockChannel((call) async {
        if (call.method == 'restore') return null;
      });
      expect(await makeService().restore(), FocusModeResult.notActive);
    });

    test('retorna error em PlatformException', () async {
      mockChannel((call) async {
        throw PlatformException(code: 'ERROR');
      });
      expect(await makeService().restore(), FocusModeResult.error);
    });
  });
}
