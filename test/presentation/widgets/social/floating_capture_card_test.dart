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

void _mockChannelsGrantedAndArmed() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_overlayChannel, (call) async {
    switch (call.method) {
      case 'isOverlayPermissionGranted':
        return true;
      case 'isFloatingShowing':
        return true;
      default:
        return null;
    }
  });
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_captureChannel, (call) async {
    if (call.method == 'isSessionArmed') return true;
    return null;
  });
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
    expect(find.text('STUDIO'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // STUDIO-U3-FIX: regression for "RenderFlex overflowed by 1.0 pixels on
  // the right" seen on-device — the badge+status Row had no Flexible, so a
  // narrow width overflows without it. Forces a tight width to reproduce.
  testWidgets(
      'FloatingCaptureCard header row does not overflow at a narrow width (permission required)',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(width: 260, child: FloatingCaptureCard()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'FloatingCaptureCard header row does not overflow at a narrow width (enabled)',
      (tester) async {
    _mockChannelsGrantedAndArmed();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(width: 260, child: FloatingCaptureCard()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  // CAPTURE-DISCLOSURE-U1: armSession() must never be invoked before the
  // disclosure sheet is shown and confirmed.
  group('capture disclosure gating', () {
    final List<MethodCall> captureCalls = [];

    void mockGrantedFlow() {
      captureCalls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_overlayChannel, (call) async {
        switch (call.method) {
          case 'isOverlayPermissionGranted':
            return true;
          case 'isFloatingShowing':
            return false;
          case 'showFloating':
            return true;
          default:
            return null;
        }
      });
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_captureChannel, (call) async {
        captureCalls.add(call);
        switch (call.method) {
          case 'isSessionArmed':
            return false;
          case 'armSession':
            return true;
          default:
            return null;
        }
      });
    }

    testWidgets('confirming the disclosure allows armSession to be called',
        (tester) async {
      SharedPreferences.setMockInitialValues({'apex_floating_opted_in': true});
      mockGrantedFlow();
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: FloatingCaptureCard())),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(find.text('Escolha o modo de captura'), findsOneWidget);
      await tester.tap(find.text('Print da tela'));
      await tester.pumpAndSettle();

      // Disclosure must appear before armSession is ever called.
      expect(find.text('Antes de capturar a tela'), findsOneWidget);
      expect(captureCalls.where((c) => c.method == 'armSession'), isEmpty);

      await tester.ensureVisible(find.text('Entendi e continuar'));
      await tester.tap(find.text('Entendi e continuar'));
      await tester.pumpAndSettle();

      expect(
        captureCalls.where((c) => c.method == 'armSession'),
        hasLength(1),
      );
    });

    testWidgets(
        'cancelling the disclosure never calls armSession and reverts the switch',
        (tester) async {
      SharedPreferences.setMockInitialValues({'apex_floating_opted_in': true});
      mockGrantedFlow();
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: FloatingCaptureCard())),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Print da tela'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('CANCELAR'));
      await tester.tap(find.text('CANCELAR'));
      await tester.pumpAndSettle();

      expect(captureCalls.where((c) => c.method == 'armSession'), isEmpty);
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isFalse);
    });
  });
}
