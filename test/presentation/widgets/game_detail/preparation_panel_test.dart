import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/core/accessibility/low_distraction_service.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/presentation/widgets/game_detail/preparation_panel.dart';

const _sevenLabelsPtBr = [
  'FPS: OK',
  'RAM: OK',
  'GPU: OK',
  'Ping: OK',
  'Otimização: OK',
  'Boost aplicado',
  'Performance melhorada',
];

Widget _wrap(Widget child, {double textScale = 1.0}) {
  return MaterialApp(
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() => lowDistractionNotifier.value = true);
  tearDown(() {
    lowDistractionNotifier.value = false;
    languageNotifier.value = AppLanguage.ptBr;
  });

  testWidgets('renders all seven indicator texts (pt-BR)', (tester) async {
    languageNotifier.value = AppLanguage.ptBr;
    await tester.pumpWidget(_wrap(const PreparationPanel()));
    await tester.pumpAndSettle();

    for (final label in _sevenLabelsPtBr) {
      expect(find.text(label), findsOneWidget, reason: 'missing "$label"');
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders translated labels for EN', (tester) async {
    languageNotifier.value = AppLanguage.en;
    await tester.pumpWidget(_wrap(const PreparationPanel()));
    await tester.pumpAndSettle();

    expect(find.text('FPS: OK'), findsOneWidget);
    expect(find.text('RAM: OK'), findsOneWidget);
    expect(find.text('GPU: OK'), findsOneWidget);
    expect(find.text('Ping: OK'), findsOneWidget);
    expect(find.text('Optimization: OK'), findsOneWidget);
    expect(find.text('Boost applied'), findsOneWidget);
    expect(find.text('Performance improved'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders translated labels for ES', (tester) async {
    languageNotifier.value = AppLanguage.es;
    await tester.pumpWidget(_wrap(const PreparationPanel()));
    await tester.pumpAndSettle();

    expect(find.text('FPS: OK'), findsOneWidget);
    expect(find.text('RAM: OK'), findsOneWidget);
    expect(find.text('GPU: OK'), findsOneWidget);
    expect(find.text('Ping: OK'), findsOneWidget);
    expect(find.text('Optimización: OK'), findsOneWidget);
    expect(find.text('Boost aplicado'), findsOneWidget);
    expect(find.text('Rendimiento mejorado'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // Combinations known to render without overflow. textScale 1.3 is included
  // only for 411x891 — see the dedicated known-limitation block below for
  // 320x640 and 360x800 at 1.3, which do overflow.
  const cleanCombinations = [
    (viewport: Size(320, 640), textScale: 1.0),
    (viewport: Size(360, 800), textScale: 1.0),
    (viewport: Size(411, 891), textScale: 1.0),
    (viewport: Size(411, 891), textScale: 1.3),
  ];

  for (final combo in cleanCombinations) {
    testWidgets(
      'no overflow at ${combo.viewport.width.toInt()}x'
      '${combo.viewport.height.toInt()}, textScale ${combo.textScale}',
      (tester) async {
        tester.view.physicalSize = combo.viewport;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _wrap(const PreparationPanel(), textScale: combo.textScale),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        for (final label in _sevenLabelsPtBr) {
          expect(find.text(label), findsOneWidget);
        }
      },
    );
  }

  // ─── KNOWN PRE-EXISTING LIMITATION — inherited verbatim from
  // PREP-PANEL-VISUAL-U1, NOT introduced or fixed by PREP-PANEL-ISOLATION-U2A.
  //
  // The module chip's Row (icon + label, no Flexible/FittedBox) overflows its
  // Wrap slot at textScale 1.3 on narrow viewports. This is the same widget
  // tree as U1, moved verbatim; U2A is a structural extraction only and must
  // not touch Wrap/spacing/typography to "fix" this. These tests assert the
  // overflow AS-IS (they will fail loudly if the underlying layout changes),
  // documenting the gap rather than hiding it.
  //
  // Tracked follow-up: PREP-PANEL-ACCESSIBILITY-U2A1 (not started).
  const knownOverflowCombinations = [
    (viewport: Size(320, 640), textScale: 1.3, overflowPx: 63),
    (viewport: Size(360, 800), textScale: 1.3, overflowPx: 23),
  ];

  for (final combo in knownOverflowCombinations) {
    testWidgets(
      'KNOWN LIMITATION (PREP-PANEL-ACCESSIBILITY-U2A1, not fixed here): '
      'RenderFlex overflow at ${combo.viewport.width.toInt()}x'
      '${combo.viewport.height.toInt()}, textScale ${combo.textScale}',
      (tester) async {
        tester.view.physicalSize = combo.viewport;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _wrap(const PreparationPanel(), textScale: combo.textScale),
        );
        await tester.pumpAndSettle();

        final exception = tester.takeException();
        expect(
          exception,
          isA<FlutterError>(),
          reason:
              'Expected the pre-existing RenderFlex overflow inherited from '
              'PREP-PANEL-VISUAL-U1 to still reproduce at textScale '
              '${combo.textScale} on ${combo.viewport.width.toInt()}x'
              '${combo.viewport.height.toInt()}. If this no longer throws, '
              'the layout was fixed — update this test and close '
              'PREP-PANEL-ACCESSIBILITY-U2A1 instead of deleting the case.',
        );
        expect(
          exception.toString(),
          contains('overflowed'),
        );
      },
    );
  }

  testWidgets('all seven chip/badge texts stay within the panel bounds',
      (tester) async {
    await tester.pumpWidget(_wrap(const PreparationPanel()));
    await tester.pumpAndSettle();

    final panelRect = tester.getRect(find.byType(PreparationPanel));
    for (final label in _sevenLabelsPtBr) {
      final textRect = tester.getRect(find.text(label));
      expect(
        panelRect.contains(textRect.topLeft) &&
            panelRect.contains(textRect.bottomRight),
        isTrue,
        reason: '"$label" at $textRect is not contained in panel $panelRect',
      );
    }
  });

  testWidgets(
    'sits below the Apex Scan section and above Real Metrics, '
    'with no overlap between the three sections',
    (tester) async {
      const scanKey = Key('apex-scan-stub');
      const panelKey = Key('preparation-panel-wrapper');
      const metricsKey = Key('real-metrics-stub');

      // Mirrors the exact sibling arrangement in game_detail_screen.dart:
      // Apex Scan card -> Divider -> Padding(PreparationPanel) -> Divider ->
      // Real Metrics section. Stubs stand in for Apex Scan / Real Metrics
      // (out of scope for this structural refactor) to verify the panel's
      // relative position was preserved by the extraction.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    key: scanKey,
                    height: 120,
                    alignment: Alignment.center,
                    child: const Text('Apex Scan stub'),
                  ),
                  const Divider(height: 1),
                  const Padding(
                    key: panelKey,
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: PreparationPanel(),
                  ),
                  const Divider(height: 1),
                  Container(
                    key: metricsKey,
                    height: 120,
                    alignment: Alignment.center,
                    child: const Text('Real Metrics stub'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final scanRect = tester.getRect(find.byKey(scanKey));
      final panelRect = tester.getRect(find.byKey(panelKey));
      final metricsRect = tester.getRect(find.byKey(metricsKey));

      expect(panelRect.top, greaterThanOrEqualTo(scanRect.bottom));
      expect(metricsRect.top, greaterThanOrEqualTo(panelRect.bottom));
      expect(scanRect.overlaps(panelRect), isFalse);
      expect(panelRect.overlaps(metricsRect), isFalse);
      expect(scanRect.overlaps(metricsRect), isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
