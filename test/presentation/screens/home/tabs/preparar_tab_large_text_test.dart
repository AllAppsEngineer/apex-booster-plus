// ACCESSIBILITY-LARGE-TEXT-U1-FIX — the Apex Scan status badge and the
// Device Snapshot title were confirmed physically (S24 Ultra, Android font
// size at maximum) to overflow horizontally because their sibling Column
// (title/subtitle) sits in a Row without Expanded/Flexible. These tests pin
// both header Rows to always give that Column a flexible slot, and to keep
// every label geometrically contained within the screen width at high
// textScale.
//
// Containment (tester.getRect(...).right <= screen width) is used as the
// primary guard rather than tester.takeException(): confirmed by direct
// investigation, RenderFlex does correctly flag this exact nested Row as
// "OVERFLOWING" internally (visible via RenderObject.toStringDeep()), but
// the debug FlutterError this normally triggers isn't reliably captured by
// tester.takeException() this deep inside PrepararTab's scrollable/animated
// tree. Containment checks the real, physically-observed symptom directly —
// the same technique preparation_panel_test.dart already uses for its own
// "no overflow" matrix. takeException() is still asserted as a
// belt-and-suspenders check.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/core/i18n/app_strings.dart';
import 'package:apex_booster_plus/domain/entities/apex_game.dart';
import 'package:apex_booster_plus/presentation/screens/home/tabs/preparar_tab.dart';

const _metricsChannel =
    MethodChannel('com.allappsengineer.apex_booster_plus/metrics');
const _focusChannel =
    MethodChannel('com.allappsengineer.apex_booster_plus/focus_mode');

final _game = ApexGame(
  id: 'g1',
  name: 'Test Game',
  packageName: 'com.test.game',
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

void _primeLibrary() {
  SharedPreferences.setMockInitialValues({
    'apex_game_library': jsonEncode([_game.toJson()]),
  });
}

void _installMockChannels() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_metricsChannel, (call) async {
    if (call.method == 'getMemoryInfo') {
      return {
        'availableBytes': 2048 * 1024 * 1024,
        'totalBytes': 8192 * 1024 * 1024,
        'lowMemory': false,
        'thresholdBytes': 500000000,
      };
    }
    return null;
  });
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_focusChannel, (call) async {
    if (call.method == 'isPermissionGranted') return false;
    return null;
  });
}

void _clearMockChannels() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_metricsChannel, null);
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_focusChannel, null);
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

/// Pumps PrepararTab with a single linked game already selected, without
/// waiting for the device-metrics network probe to resolve — the header
/// Rows under test render before that async work completes.
///
/// [viewport] drives the *real* render surface (via `tester.view`), exactly
/// like preparation_panel_test.dart's matrix — overriding only
/// MediaQueryData.size (without touching tester.view) would be cosmetic and
/// would never actually constrain layout, hiding real overflow bugs.
Future<void> _pumpPrepararTab(
  WidgetTester tester, {
  double textScale = 1.0,
  Size viewport = const Size(480, 900),
}) async {
  tester.view.physicalSize = viewport;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    _wrap(const Scaffold(body: PrepararTab(isActive: true)), textScale: textScale),
  );
  await tester.pump();
  // Lets the async game/session load resolve and the entrance
  // (fadeIn/slideY, max ~700ms) animations run to completion, avoiding
  // "pending timer" failures from flutter_animate without waiting for the
  // (test-intercepted, near-instant) device-metrics network probe.
  await tester.pump(const Duration(milliseconds: 1000));
}

/// Asserts every widget matching [finder] is horizontally contained within
/// the screen — i.e. never pushed past the right edge nor before the left.
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
    _primeLibrary();
    _installMockChannels();
  });

  tearDown(() {
    _clearMockChannels();
    languageNotifier.value = AppLanguage.ptBr;
  });

  group('Apex Scan — badge de status PRONTO/INCOMPLETO', () {
    testWidgets(
        'o titulo/subtitulo do card fica dentro de um Expanded ou Flexible',
        (tester) async {
      await _pumpPrepararTab(tester);

      final titleFinder = find.text('APEX SCAN');
      expect(titleFinder, findsOneWidget);

      final flexibleAncestor = find.ancestor(
        of: titleFinder,
        matching: find.byWidgetPredicate((w) => w is Expanded || w is Flexible),
      );
      expect(
        flexibleAncestor,
        findsWidgets,
        reason:
            'o titulo "APEX SCAN" deve estar dentro de um Expanded/Flexible '
            'para nao empurrar o badge de status para fora da largura '
            'disponivel em textScale alto',
      );
    });

    testWidgets(
        'badge PRONTO permanece dentro da largura da tela com fonte do Android no maximo (textScale 2.0)',
        (tester) async {
      const screenWidth = 480.0;
      await _pumpPrepararTab(tester, textScale: 2.0, viewport: const Size(screenWidth, 900));

      expect(tester.takeException(), isNull);
      final badgeFinder = find.text('● PRONTO');
      expect(badgeFinder, findsOneWidget);
      _expectContainedInScreen(
        tester,
        badgeFinder,
        screenWidth,
        reason:
            'o badge de status "● PRONTO" foi empurrado para fora da tela — '
            'o titulo/subtitulo a esquerda precisa ceder espaco via '
            'Expanded/Flexible',
      );
    });
  });

  group('Snapshot do Dispositivo — titulo do card', () {
    testWidgets(
        'o titulo/subtitulo do card fica dentro de um Expanded ou Flexible',
        (tester) async {
      await _pumpPrepararTab(tester);

      final titleFinder = find.text('SNAPSHOT DO DISPOSITIVO');
      expect(titleFinder, findsOneWidget);

      final flexibleAncestor = find.ancestor(
        of: titleFinder,
        matching: find.byWidgetPredicate((w) => w is Expanded || w is Flexible),
      );
      expect(
        flexibleAncestor,
        findsWidgets,
        reason:
            'o titulo "SNAPSHOT DO DISPOSITIVO" deve estar dentro de um '
            'Expanded/Flexible para poder quebrar linha com seguranca em '
            'textScale alto, em vez de extrapolar horizontalmente',
      );
    });

    testWidgets(
        'titulo permanece dentro da largura da tela com fonte do Android no maximo (textScale 2.0)',
        (tester) async {
      const screenWidth = 480.0;
      await _pumpPrepararTab(tester, textScale: 2.0, viewport: const Size(screenWidth, 900));

      expect(tester.takeException(), isNull);
      final titleFinder = find.text('SNAPSHOT DO DISPOSITIVO');
      expect(titleFinder, findsOneWidget);
      _expectContainedInScreen(
        tester,
        titleFinder,
        screenWidth,
        reason:
            'o titulo "SNAPSHOT DO DISPOSITIVO" extrapolou a largura da tela',
      );
    });
  });

  group('Aparencia em textScale normal permanece equivalente', () {
    testWidgets('textScale 1.0 nao apresenta overflow (regressao)',
        (tester) async {
      const screenWidth = 480.0;
      await _pumpPrepararTab(tester, textScale: 1.0, viewport: const Size(screenWidth, 900));

      expect(tester.takeException(), isNull);
      expect(find.text('APEX SCAN'), findsOneWidget);
      expect(find.text('SNAPSHOT DO DISPOSITIVO'), findsOneWidget);
      _expectContainedInScreen(tester, find.text('● PRONTO'), screenWidth);
      _expectContainedInScreen(
          tester, find.text('SNAPSHOT DO DISPOSITIVO'), screenWidth);
    });
  });

  group('Sem regressao entre idiomas em textScale alto', () {
    for (final lang in AppLanguage.values) {
      testWidgets('idioma $lang: badge de status e titulo do snapshot contidos com textScale 2.0',
          (tester) async {
        const screenWidth = 480.0;
        languageNotifier.value = lang;
        final s = AppStrings(lang);
        await _pumpPrepararTab(tester, textScale: 2.0, viewport: const Size(screenWidth, 900));

        expect(tester.takeException(), isNull);
        expect(find.text('APEX SCAN'), findsOneWidget);

        final badgeFinder = find.text(s.prepScanStatusReady);
        expect(badgeFinder, findsOneWidget);
        _expectContainedInScreen(tester, badgeFinder, screenWidth);

        final snapshotTitleFinder = find.text(s.snapshotTitle.toUpperCase());
        expect(snapshotTitleFinder, findsOneWidget);
        _expectContainedInScreen(tester, snapshotTitleFinder, screenWidth);
      });
    }
  });
}
