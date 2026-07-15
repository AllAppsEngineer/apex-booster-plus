import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  testWidgets('shows the unlock CTA card with title, subtitle and action', (tester) async {
    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();

    expect(find.text('Desbloqueio único'), findsOneWidget);
    expect(find.text('Compra única, sem assinatura'), findsOneWidget);
    expect(find.text('Ver desbloqueio'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
