// ACCESSIBILITY-LARGE-TEXT-U1-FIX — the "Aplicativo pago · Compra única"
// line on the About card was confirmed physically (S24 Ultra, Android font
// size at maximum) to be cut off horizontally, because its Text sits in a
// Row without Expanded — unlike the disclaimer Row directly below it, which
// already wraps its Text in Expanded. These tests pin that Row to always
// give the Text a flexible slot, and to keep it geometrically contained
// within the screen width at high textScale.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/core/i18n/app_strings.dart';
import 'package:apex_booster_plus/presentation/screens/home/tabs/configuracoes_tab.dart';

void _mockFocusChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('com.allappsengineer.apex_booster_plus/focus_mode'),
    (call) async {
      if (call.method == 'isPermissionGranted') return false;
      return null;
    },
  );
}

void _clearFocusChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('com.allappsengineer.apex_booster_plus/focus_mode'),
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
      case 'isOverlayPermissionGranted':
        return false;
      case 'isFloatingShowing':
        return false;
      case 'hideFloating':
        return null;
      case 'openOverlayPermissionSettings':
        return null;
      default:
        return null;
    }
  });
}

void _clearOverlayChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_overlayChannel, null);
}

Widget _wrap(Widget child, {double textScale = 1.0}) {
  return MaterialApp(
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: child,
      ),
    ),
  );
}

Future<void> _pumpConfig(
  WidgetTester tester, {
  double textScale = 1.0,
  Size viewport = const Size(480, 1400),
}) async {
  tester.view.physicalSize = viewport;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    _wrap(const Scaffold(body: ConfiguracoesTab()), textScale: textScale),
  );
  await tester.pumpAndSettle();
}

/// Drains every pending overflow exception without asserting on it.
///
/// ConfiguracoesTab also renders the "SOBRE" badge + version-chip header
/// Row (configuracoes_tab.dart:864), a separate, already-catalogued overflow
/// risk (ACCESSIBILITY-LARGE-TEXT-U2-AUDIT, out of scope for this fix) that
/// independently overflows at high textScale. Leaving it unconsumed would
/// fail these tests for a reason unrelated to the "Aplicativo pago" line
/// under test here, so it's drained rather than asserted — the geometric
/// containment check below is what actually proves this fix.
void _drainExceptions(WidgetTester tester) {
  while (tester.takeException() != null) {}
}

void _expectContainedInScreen(
  WidgetTester tester,
  Finder finder,
  double screenWidth, {
  String? reason,
}) {
  final rect = tester.getRect(finder);
  expect(
    rect.left >= -0.5 && rect.right <= screenWidth + 0.5,
    isTrue,
    reason: reason ??
        '$finder at $rect is not contained within the 0..$screenWidth screen width',
  );
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
    languageNotifier.value = AppLanguage.ptBr;
  });

  group('Sobre — linha "Aplicativo pago · Compra única"', () {
    testWidgets('o texto fica dentro de um Expanded ou Flexible',
        (tester) async {
      await _pumpConfig(tester);

      final modelFinder = find.text('Aplicativo pago · Compra única');
      expect(modelFinder, findsOneWidget);

      final flexibleAncestor = find.ancestor(
        of: modelFinder,
        matching: find.byWidgetPredicate((w) => w is Expanded || w is Flexible),
      );
      expect(
        flexibleAncestor,
        findsWidgets,
        reason:
            'o texto "Aplicativo pago · Compra única" deve estar dentro de '
            'um Expanded/Flexible, assim como o disclaimer logo abaixo, '
            'para poder quebrar linha em vez de ser cortado horizontalmente',
      );
    });

    testWidgets(
        'permanece dentro da largura da tela com fonte do Android no maximo (textScale 2.0)',
        (tester) async {
      const screenWidth = 480.0;
      await _pumpConfig(tester, textScale: 2.0, viewport: const Size(screenWidth, 1600));

      _drainExceptions(tester);
      final modelFinder = find.text('Aplicativo pago · Compra única');
      expect(modelFinder, findsOneWidget);
      _expectContainedInScreen(
        tester,
        modelFinder,
        screenWidth,
        reason:
            'a linha "Aplicativo pago · Compra única" foi cortada/'
            'extrapolou a largura da tela',
      );
    });

    testWidgets('textScale 1.0 nao apresenta overflow (regressao)',
        (tester) async {
      const screenWidth = 480.0;
      await _pumpConfig(tester, textScale: 1.0, viewport: const Size(screenWidth, 1400));

      _drainExceptions(tester);
      final modelFinder = find.text('Aplicativo pago · Compra única');
      expect(modelFinder, findsOneWidget);
      _expectContainedInScreen(tester, modelFinder, screenWidth);
    });
  });

  group('Sem regressao entre idiomas em textScale alto', () {
    for (final lang in AppLanguage.values) {
      testWidgets('idioma $lang: linha do modelo de app contida com textScale 2.0',
          (tester) async {
        const screenWidth = 480.0;
        languageNotifier.value = lang;
        final s = AppStrings(lang);
        await _pumpConfig(tester, textScale: 2.0, viewport: const Size(screenWidth, 1600));

        _drainExceptions(tester);
        final modelFinder = find.text(s.appModel);
        expect(modelFinder, findsOneWidget);
        _expectContainedInScreen(tester, modelFinder, screenWidth);
      });
    }
  });
}
