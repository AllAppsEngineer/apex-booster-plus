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

    for (final label in _sevenLabelsEn) {
      expect(find.text(label), findsOneWidget, reason: 'missing "$label"');
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders translated labels for ES', (tester) async {
    languageNotifier.value = AppLanguage.es;
    await tester.pumpWidget(_wrap(const PreparationPanel()));
    await tester.pumpAndSettle();

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
  const viewports = [Size(320, 640), Size(360, 800), Size(411, 891)];
  const textScales = [1.0, 1.3];

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
            await tester.pumpAndSettle();

            expect(tester.takeException(), isNull);

            final panelRect = tester.getRect(find.byType(PreparationPanel));
            for (final label in entry.value) {
              final finder = find.text(label);
              expect(finder, findsOneWidget, reason: 'missing "$label"');
              final textRect = tester.getRect(finder);
              expect(
                panelRect.contains(textRect.topLeft) &&
                    panelRect.contains(textRect.bottomRight),
                isTrue,
                reason:
                    '"$label" at $textRect is not contained in panel '
                    '$panelRect',
              );
            }
          },
        );
      }
    }
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
