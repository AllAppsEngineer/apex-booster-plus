import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/presentation/widgets/social/floating_capture_card.dart';

const _overlayChannel = MethodChannel('apex/overlay');
const _captureChannel = MethodChannel('apex/capture');

void _mockChannels() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_overlayChannel, (call) async {
    switch (call.method) {
      case 'isOverlayPermissionGranted':
        return false;
      case 'isFloatingShowing':
        return false;
      default:
        return null;
    }
  });
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_captureChannel, (call) async {
    if (call.method == 'isSessionArmed') return false;
    return null;
  });
}

void _clearChannels() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_overlayChannel, null);
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_captureChannel, null);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _mockChannels();
  });

  tearDown(_clearChannels);

  testWidgets('FloatingCaptureCard renderiza sem crash fora de Configurações',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: FloatingCaptureCard())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Modo Captura da Sessão'), findsOneWidget);
    expect(find.text('SOCIAL'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
