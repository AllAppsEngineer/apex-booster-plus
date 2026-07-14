import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/presentation/screens/home/home_screen.dart';

void _mockChannels() {
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(
    const MethodChannel('apex/overlay'),
    (call) async {
      switch (call.method) {
        case 'isOverlayPermissionGranted':
          return false;
        case 'isFloatingShowing':
          return false;
        default:
          return null;
      }
    },
  );
  messenger.setMockMethodCallHandler(
    const MethodChannel('apex/capture'),
    (call) async => call.method == 'isSessionArmed' ? false : null,
  );
  messenger.setMockMethodCallHandler(
    const MethodChannel('com.allappsengineer.apex_booster_plus/focus_mode'),
    (call) async => call.method == 'isPermissionGranted' ? false : null,
  );
  messenger.setMockMethodCallHandler(
    const MethodChannel('com.allappsengineer.apex_booster_plus/apps'),
    (call) async {
      if (call.method == 'getInstalledApps') return <dynamic>[];
      if (call.method == 'getAppIcon') return null;
      if (call.method == 'launchApp') return false;
      return null;
    },
  );
  messenger.setMockMethodCallHandler(
    const MethodChannel('com.allappsengineer.apex_booster_plus/metrics'),
    (call) async {
      if (call.method == 'getMemoryInfo') {
        return <String, dynamic>{
          'availableBytes': 2000000000,
          'totalBytes': 8000000000,
          'lowMemory': false,
          'thresholdBytes': 150000000,
        };
      }
      return null;
    },
  );
}

void _clearChannels() {
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  for (final name in [
    'apex/overlay',
    'apex/capture',
    'com.allappsengineer.apex_booster_plus/focus_mode',
    'com.allappsengineer.apex_booster_plus/apps',
    'com.allappsengineer.apex_booster_plus/metrics',
  ]) {
    messenger.setMockMethodCallHandler(MethodChannel(name), null);
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _mockChannels();
  });

  tearDown(() {
    _clearChannels();
    languageNotifier.value = AppLanguage.ptBr;
  });

  Widget wrap() => const MaterialApp(home: HomeScreen());

  testWidgets('bottom nav mostra as 6 abas na ordem esperada, incluindo Studio',
      (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Biblioteca'), findsOneWidget);
    expect(find.text('Preparar'), findsOneWidget);
    expect(find.text('Studio'), findsOneWidget);
    expect(find.text('Histórico'), findsOneWidget);
    expect(find.text('Config.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tocar em Studio abre a aba com Modo Captura e Criar Card',
      (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Studio'));
    await tester.pumpAndSettle();

    expect(find.text('Modo Captura da Sessão'), findsOneWidget);
    expect(find.text('Criar card'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('aba Config continua acessivel apos adicionar Studio',
      (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Config.'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Apex Booster+'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
