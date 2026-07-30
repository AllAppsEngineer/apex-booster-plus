import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/core/i18n/app_strings.dart';
import 'package:apex_booster_plus/presentation/screens/home/tabs/configuracoes_tab.dart';

Widget _wrapConfig() => MaterialApp(
      home: Scaffold(body: ConfiguracoesTab()),
    );

void _mockFocusChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel(
        'com.allappsengineer.apex_booster_plus/focus_mode'),
    (call) async {
      if (call.method == 'isPermissionGranted') return false;
      return null;
    },
  );
}

void _clearFocusChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel(
        'com.allappsengineer.apex_booster_plus/focus_mode'),
    null,
  );
}

const _appsChannel =
    MethodChannel('com.allappsengineer.apex_booster_plus/apps');

void _mockAppsChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_appsChannel, (call) async => null);
}

void _clearAppsChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_appsChannel, null);
}

const _overlayChannel = MethodChannel('apex/overlay');

void _mockOverlayChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_overlayChannel, (call) async {
    switch (call.method) {
      case 'isOverlayPermissionGranted': return false;
      case 'isFloatingShowing': return false;
      case 'hideFloating': return null;
      case 'openOverlayPermissionSettings': return null;
      default: return null;
    }
  });
}

void _clearOverlayChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_overlayChannel, null);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _mockFocusChannel();
    _mockAppsChannel();
    _mockOverlayChannel();
  });

  tearDown(() {
    _clearFocusChannel();
    _clearAppsChannel();
    _clearOverlayChannel();
  });

  testWidgets('does not show any unlock/purchase CTA (MONETIZATION-PAID-U1)', (tester) async {
    final s = AppStrings(AppLanguage.ptBr);
    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();

    // Legacy unlock card copy must be fully gone from Configurações.
    expect(find.text('Desbloqueio único'), findsNothing);
    expect(find.text('Compra única, sem assinatura'), findsNothing);
    expect(find.text('Ver desbloqueio'), findsNothing);
    expect(find.text(s.settingsTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('remaining Configurações cards stay accessible without any entitlement check',
      (tester) async {
    final s = AppStrings(AppLanguage.ptBr);
    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();

    expect(find.text(s.focusTitle), findsOneWidget);
    expect(find.text(s.clearHistoryTitle), findsOneWidget);
    expect(find.text(s.languageTitle), findsOneWidget);
    expect(find.text(s.honestBoosterCardTitle), findsOneWidget);
    expect(find.text(s.lowDistractionTitle), findsOneWidget);
    expect(find.text('Apex Booster+'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
