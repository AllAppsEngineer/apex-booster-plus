import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/data/services/screen_capture_service.dart';
import 'package:apex_booster_plus/presentation/widgets/social/capture_disclosure_sheet.dart';

const _appsChannel =
    MethodChannel('com.allappsengineer.apex_booster_plus/apps');
final List<MethodCall> _appsChannelCalls = [];

void _mockAppsChannel() {
  _appsChannelCalls.clear();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_appsChannel, (call) async {
    _appsChannelCalls.add(call);
    return null;
  });
}

void _clearAppsChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_appsChannel, null);
}

Widget _wrapForShow(Future<bool> Function(BuildContext) onPressed) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => onPressed(context),
          child: const Text('trigger'),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _mockAppsChannel();
  });

  tearDown(_clearAppsChannel);

  testWidgets('shows video-mode bullets including audio disclosure',
      (tester) async {
    bool? result;
    await tester.pumpWidget(_wrapForShow((context) async {
      result = await CaptureDisclosureSheet.maybeShow(
        context,
        mode: CaptureMode.video,
      );
      return result!;
    }));
    await tester.tap(find.text('trigger'));
    await tester.pumpAndSettle();

    expect(find.text('Antes de gravar'), findsOneWidget);
    expect(
      find.textContaining('exige que o Apex solicite a permissão de áudio'),
      findsOneWidget,
    );
    expect(
      find.textContaining('não grava o microfone nem a sua voz'),
      findsOneWidget,
    );
    expect(
      find.textContaining('não disponibilizar esse áudio'),
      findsOneWidget,
    );
    expect(
      find.textContaining('não envia seus vídeos ou áudios'),
      findsOneWidget,
    );
    expect(find.text('Ver Política de Privacidade'), findsOneWidget);
    expect(find.text('Entendi e continuar'), findsOneWidget);
  });

  testWidgets('shows screenshot-mode bullets without any audio mention',
      (tester) async {
    await tester.pumpWidget(_wrapForShow((context) async {
      return CaptureDisclosureSheet.maybeShow(
        context,
        mode: CaptureMode.screenshot,
      );
    }));
    await tester.tap(find.text('trigger'));
    await tester.pumpAndSettle();

    expect(find.text('Antes de capturar a tela'), findsOneWidget);
    // The generic storage bullet legitimately mentions "áudios" (no data of
    // any kind, audio included, is sent to Apex's own servers) — only the
    // audio-*capture* disclosures (attempt/unavailable/fallback) are
    // video-only and must be absent here.
    expect(
      find.textContaining('permissão de áudio'),
      findsNothing,
    );
    expect(find.textContaining('não disponibilizar esse áudio'), findsNothing);
    expect(find.textContaining('microfone'), findsNothing);
  });

  testWidgets('cancel returns false and does not persist acknowledgement',
      (tester) async {
    bool? result;
    await tester.pumpWidget(_wrapForShow((context) async {
      result = await CaptureDisclosureSheet.maybeShow(
        context,
        mode: CaptureMode.video,
      );
      return result!;
    }));
    await tester.tap(find.text('trigger'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('CANCELAR'));
    await tester.tap(find.text('CANCELAR'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('apex_capture_disclosure_ack_version'), isNull);
  });

  testWidgets('confirming persists kCaptureDisclosureVersion and returns true',
      (tester) async {
    bool? result;
    await tester.pumpWidget(_wrapForShow((context) async {
      result = await CaptureDisclosureSheet.maybeShow(
        context,
        mode: CaptureMode.video,
      );
      return result!;
    }));
    await tester.tap(find.text('trigger'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Entendi e continuar'));
    await tester.tap(find.text('Entendi e continuar'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getInt('apex_capture_disclosure_ack_version'),
      kCaptureDisclosureVersion,
    );
  });

  testWidgets('does not reappear once the current version is acknowledged',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'apex_capture_disclosure_ack_version': kCaptureDisclosureVersion,
    });
    bool? result;
    await tester.pumpWidget(_wrapForShow((context) async {
      result = await CaptureDisclosureSheet.maybeShow(
        context,
        mode: CaptureMode.video,
      );
      return result!;
    }));
    await tester.tap(find.text('trigger'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(find.text('Antes de gravar'), findsNothing);
  });

  testWidgets('tapping the privacy link opens it without closing the sheet',
      (tester) async {
    await tester.pumpWidget(_wrapForShow((context) async {
      return CaptureDisclosureSheet.maybeShow(
        context,
        mode: CaptureMode.video,
      );
    }));
    await tester.tap(find.text('trigger'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Ver Política de Privacidade'));
    await tester.tap(find.text('Ver Política de Privacidade'));
    await tester.pumpAndSettle();

    expect(_appsChannelCalls.single.method, 'openUrl');
    // Sheet stays open — the link is informational, not a decision.
    expect(find.text('Antes de gravar'), findsOneWidget);
  });

  testWidgets('no overflow on a small, short viewport in landscape',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(640, 320));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_wrapForShow((context) async {
      return CaptureDisclosureSheet.maybeShow(
        context,
        mode: CaptureMode.video,
      );
    }));
    await tester.tap(find.text('trigger'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('no overflow with a large text scale factor', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: _wrapForShow((context) async {
          return CaptureDisclosureSheet.maybeShow(
            context,
            mode: CaptureMode.video,
          );
        }),
      ),
    );
    await tester.tap(find.text('trigger'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
