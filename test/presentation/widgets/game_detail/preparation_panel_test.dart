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

const _sevenLabelsEn = [
  'FPS: OK',
  'RAM: OK',
  'GPU: OK',
  'Ping: OK',
  'Optimization: OK',
  'Boost applied',
  'Performance improved',
];

const _sevenLabelsEs = [
  'FPS: OK',
  'RAM: OK',
  'GPU: OK',
  'Ping: OK',
  'Optimización: OK',
  'Boost aplicado',
  'Rendimiento mejorado',
];

const _labelsByLanguage = {
  AppLanguage.ptBr: _sevenLabelsPtBr,
  AppLanguage.en: _sevenLabelsEn,
  AppLanguage.es: _sevenLabelsEs,
};

// PREP-PANEL-VISUAL-U2B adds a continuous, repeating AnimationController
// (the ambient scanner) behind the chips/badges, so pumpAndSettle() would
// hang forever waiting for a frame that never stops being scheduled. Every
// test below advances the fake clock by a fixed, generous duration instead.
// 3500ms comfortably clears the slowest pre-existing entrance sequence
// (~2.96s in normal motion; ~1.5s in Low Distraction Mode) without ever
// trying to "settle" the now-infinite scanner loop.
const _kEntranceSettleMs = 3500;

// Mirrors the fixed scanner cadence documented in PREP-PANEL-VISUAL-U2B
// (sweep+pause midpoints of the requested ranges) so tests can advance
// through whole cycles deliberately.
const _kNormalCycleMs = 1900 + 1100;
const _kReducedCycleMs = 2500 + 2300;

// A single huge `pump(duration)` jump reaches the correct final *size* but
// can leave an already-completed flutter_animate transform (e.g. the
// Column's entrance slideY) painted at a stale, not-yet-settled offset —
// a test-binding/flutter_animate interaction unrelated to the ambient
// scanner. Stepping through in small increments (as pumpAndSettle itself
// would) avoids it reliably.
Future<void> _pumpFor(
  WidgetTester tester,
  Duration total, {
  Duration step = const Duration(milliseconds: 100),
}) async {
  var remaining = total;
  while (remaining > Duration.zero) {
    final thisStep = remaining < step ? remaining : step;
    await tester.pump(thisStep);
    remaining -= thisStep;
  }
}

Future<void> _pumpEntranceSettle(WidgetTester tester) async {
  await tester.pump();
  await _pumpFor(tester, const Duration(milliseconds: _kEntranceSettleMs));
}

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

/// Reads the ambient scanner's current cycle progress (0..1) straight off
/// the lone [CustomPaint] this widget paints, via dynamic dispatch — the
/// painter class is intentionally private, but its `progress` field is a
/// public member and remains reachable at runtime without exposing the
/// type itself.
double _scannerProgress(WidgetTester tester) {
  final finder = find.descendant(
    of: find.byType(PreparationPanel),
    matching: find.byType(CustomPaint),
  );
  expect(finder, findsOneWidget);
  // ignore: avoid_dynamic_calls
  final dynamic painter = tester.widget<CustomPaint>(finder).painter;
  return painter.progress as double;
}

void _expectNoZeroOpacityAncestors(WidgetTester tester, Finder textFinder,
    String label, String context) {
  final fadeFinder = find.ancestor(
    of: textFinder,
    matching: find.byType(FadeTransition),
  );
  for (final fade in tester.widgetList<FadeTransition>(fadeFinder)) {
    expect(
      fade.opacity.value,
      greaterThan(0.0),
      reason: '"$label" faded to zero opacity $context',
    );
  }
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
    await _pumpEntranceSettle(tester);

    for (final label in _sevenLabelsPtBr) {
      expect(find.text(label), findsOneWidget, reason: 'missing "$label"');
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders translated labels for EN', (tester) async {
    languageNotifier.value = AppLanguage.en;
    await tester.pumpWidget(_wrap(const PreparationPanel()));
    await _pumpEntranceSettle(tester);

    for (final label in _sevenLabelsEn) {
      expect(find.text(label), findsOneWidget, reason: 'missing "$label"');
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders translated labels for ES', (tester) async {
    languageNotifier.value = AppLanguage.es;
    await tester.pumpWidget(_wrap(const PreparationPanel()));
    await _pumpEntranceSettle(tester);

    for (final label in _sevenLabelsEs) {
      expect(find.text(label), findsOneWidget, reason: 'missing "$label"');
    }
    expect(tester.takeException(), isNull);
  });

  // ─── PREP-PANEL-ACCESSIBILITY-U2A1 — full validation matrix ────────────
  //
  // Every viewport x textScale x language combination must render all seven
  // texts with zero RenderFlex overflow and every label fully contained
  // within the panel bounds. At textScale 1.0 this also guards the U1
  // appearance (chip/badge Row stays single-line, since Flexible only
  // wraps when the single-line width would exceed the available space).
  //
  // PREP-PANEL-VISUAL-U2B also pumps two extra ambient-scanner cycles per
  // combination and re-checks the same invariants, so the matrix doubles as
  // the "zero overflow across the viewports/textScales already covered"
  // requirement for the new continuous sweep.
  const viewports = [Size(320, 640), Size(360, 800), Size(411, 891)];
  const textScales = [1.0, 1.3];

  void expectSevenTextsContained(WidgetTester tester, List<String> labels) {
    final panelRect = tester.getRect(find.byType(PreparationPanel));
    for (final label in labels) {
      final finder = find.text(label);
      expect(finder, findsOneWidget, reason: 'missing "$label"');
      final textRect = tester.getRect(finder);
      expect(
        panelRect.contains(textRect.topLeft) &&
            panelRect.contains(textRect.bottomRight),
        isTrue,
        reason:
            '"$label" at $textRect is not contained in panel $panelRect',
      );
    }
  }

  for (final viewport in viewports) {
    for (final textScale in textScales) {
      for (final entry in _labelsByLanguage.entries) {
        testWidgets(
          'no overflow, seven texts contained in panel — '
          '${viewport.width.toInt()}x${viewport.height.toInt()}, '
          'textScale $textScale, ${entry.key.name}',
          (tester) async {
            tester.view.physicalSize = viewport;
            tester.view.devicePixelRatio = 1.0;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            languageNotifier.value = entry.key;
            await tester.pumpWidget(
              _wrap(const PreparationPanel(), textScale: textScale),
            );
            await _pumpEntranceSettle(tester);

            expect(tester.takeException(), isNull);
            expectSevenTextsContained(tester, entry.value);

            // Low Distraction Mode is on by default (setUp) for this matrix.
            for (var cycle = 0; cycle < 2; cycle++) {
              await _pumpFor(
                tester,
                const Duration(milliseconds: _kReducedCycleMs),
              );
              expect(tester.takeException(), isNull);
              expectSevenTextsContained(tester, entry.value);
            }
          },
        );
      }
    }
  }

  testWidgets('all seven chip/badge texts stay within the panel bounds',
      (tester) async {
    await tester.pumpWidget(_wrap(const PreparationPanel()));
    await _pumpEntranceSettle(tester);

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
      await _pumpEntranceSettle(tester);

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

  // ─── PREP-PANEL-VISUAL-U2B — ambient scanner ────────────────────────────

  for (final reduced in [true, false]) {
    final modeLabel = reduced ? 'Baixa Distração' : 'normal';
    testWidgets(
      'seven texts stay present with non-zero opacity across several '
      'ambient scanner cycles ($modeLabel mode)',
      (tester) async {
        lowDistractionNotifier.value = reduced;
        languageNotifier.value = AppLanguage.ptBr;
        await tester.pumpWidget(_wrap(const PreparationPanel()));
        await _pumpEntranceSettle(tester);

        final cycleMs = reduced ? _kReducedCycleMs : _kNormalCycleMs;
        for (var cycle = 0; cycle < 3; cycle++) {
          await _pumpFor(tester, Duration(milliseconds: cycleMs));
          for (final label in _sevenLabelsPtBr) {
            final finder = find.text(label);
            expect(finder, findsOneWidget,
                reason: 'missing "$label" after cycle $cycle ($modeLabel)');
            _expectNoZeroOpacityAncestors(
              tester,
              finder,
              label,
              'after cycle $cycle ($modeLabel)',
            );
          }
          expect(tester.takeException(), isNull);
        }
      },
    );
  }

  testWidgets('panel size stays constant while the scanner sweeps',
      (tester) async {
    await tester.pumpWidget(_wrap(const PreparationPanel()));
    await _pumpEntranceSettle(tester);

    final baseline = tester.getRect(find.byType(PreparationPanel));

    const steps = 6;
    for (var i = 1; i <= steps; i++) {
      await _pumpFor(
        tester,
        Duration(milliseconds: (_kReducedCycleMs / steps).round()),
      );
      final rect = tester.getRect(find.byType(PreparationPanel));
      expect(
        rect,
        equals(baseline),
        reason: 'panel size/position changed mid-sweep at step $i',
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('ambient scanner layer stays clipped within the panel bounds',
      (tester) async {
    await tester.pumpWidget(_wrap(const PreparationPanel()));
    await _pumpEntranceSettle(tester);

    final clipFinder = find.descendant(
      of: find.byType(PreparationPanel),
      matching: find.byType(ClipRRect),
    );
    expect(clipFinder, findsOneWidget);

    for (var i = 0; i < 3; i++) {
      await _pumpFor(tester, const Duration(milliseconds: 900));
      final panelRect = tester.getRect(find.byType(PreparationPanel));
      final clipRect = tester.getRect(clipFinder);
      expect(
        clipRect,
        rectMoreOrLessEquals(panelRect, epsilon: 0.5),
        reason: 'scanner clip $clipRect escaped panel bounds $panelRect',
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Baixa Distração mode keeps the ambient scanner animating',
      (tester) async {
    // setUp already sets lowDistractionNotifier.value = true.
    await tester.pumpWidget(_wrap(const PreparationPanel()));
    await _pumpEntranceSettle(tester);

    final samples = <double>{};
    samples.add(_scannerProgress(tester));
    for (var i = 0; i < 3; i++) {
      await _pumpFor(tester, const Duration(milliseconds: 1500));
      samples.add(_scannerProgress(tester));
    }

    expect(
      samples.length,
      greaterThan(1),
      reason:
          'scanner progress never changed across pumps in Baixa Distração '
          'mode — the ambient loop appears frozen',
    );
    expect(tester.takeException(), isNull);
  });
}
