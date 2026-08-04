import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/core/accessibility/low_distraction_service.dart';
import 'package:apex_booster_plus/core/constants/app_colors.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/core/routing/app_route_observer.dart';
import 'package:apex_booster_plus/presentation/widgets/game_detail/preparation_panel.dart';

// PREP-PANEL-ACTIVATION-U3-FIX1 — mirrors the production stagger/tail
// constants in preparation_panel.dart (private to that file, so duplicated
// here) for tests that assert on exact per-indicator timing.
const _kIndicatorBaseDelayMs = 300;
const _kIndicatorStaggerMs = 410;
const _kIndicatorTailNormalMs = 570;
int _indicatorDelayMs(int i) =>
    _kIndicatorBaseDelayMs + i * _kIndicatorStaggerMs;

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
// (PREP-PANEL-ACTIVATION-U3-FIX1: ~3.33s in normal motion — 7th indicator's
// own 2760ms delay + its 570ms confirmation tail; ~3.06s in Baixa Distração
// — same 2760ms delay + a 300ms tail) without ever trying to "settle" the
// now-infinite scanner loop.
const _kEntranceSettleMs = 3500;

// PREP-PANEL-ACTIVATION-U3 — flutter_animate's `Animate` widget schedules its
// own playback via `Future.delayed(widget.delay, ...)` (see
// flutter_animate's animate.dart), which is a real `dart:async` Timer even
// when `delay` is `Duration.zero` (the idle button's pulse uses no explicit
// delay). `WidgetTester.pump()` with no duration never advances the fake
// clock, so that Timer is still "pending" when a test ends right after a
// bare pump — tripping flutter_test's `!timersPending` invariant. Any pump
// with a real, non-zero duration flushes it; this constant documents why one
// is always used instead of a bare `pump()` as the last step before such a
// test's assertions.
const _kFlushMs = Duration(milliseconds: 50);

// Mirrors the fixed scanner cadence documented in PREP-PANEL-VISUAL-U2B
// (sweep+pause midpoints of the requested ranges) so tests can advance
// through whole legs deliberately. PREP-PANEL-ACTIVATION-U3-FIX1: the
// controller's own repeat() period is now double one of these (a full
// sweep-right + pause + sweep-left + pause round trip — see
// _syncScannerMotion) but these constants still represent a single one-way
// leg's timing, which is all the tests below that use them actually need.
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

// PREP-PANEL-ACTIVATION-U3 — the panel now starts `idle`: every caller of
// this helper wants the full chip/badge/scanner sequence, so it now taps the
// "CLIQUE PARA PREPARAR" button first, exactly as a real user would, before
// settling through the (unchanged) entrance timings.
Future<void> _pumpEntranceSettle(WidgetTester tester) async {
  await tester.pump();
  await tester.tap(find.byKey(preparationPanelPrepareButtonKey));
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
  // skipOffstage: false — PREP-PANEL-SCANNER-LIFECYCLE-U2C-A's routing PoC
  // reads this while the panel's route is covered (and therefore offstage
  // per Flutter's Navigator/Overlay), where the widget/state still exist
  // but the default offstage-skipping Finder would otherwise miss them.
  final finder = find.descendant(
    of: find.byType(PreparationPanel, skipOffstage: false),
    matching: find.byType(CustomPaint, skipOffstage: false),
    skipOffstage: false,
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

// PREP-PANEL-ACTIVATION-U3-FIX1 — the chip/badge subtree mounts in full the
// instant the panel enters `preparing` (see `_buildActiveContent`); each
// indicator's own `entranceDelayMs` only holds its `FadeTransition`'s
// opacity at 0 until its instant, it does not delay the widget's presence
// in the tree. So "has this indicator appeared yet" must be read from its
// FadeTransition ancestor's live opacity (as `_expectNoZeroOpacityAncestors`
// already does for a different assertion direction), never from
// `find.text(label)`'s findsOneWidget/findsNothing, which would be
// findsOneWidget the whole time regardless of its instant.
double _labelOpacity(WidgetTester tester, String label) {
  final textFinder = find.text(label);
  expect(textFinder, findsOneWidget, reason: '"$label" missing from the tree');
  final fadeFinder = find.ancestor(
    of: textFinder,
    matching: find.byType(FadeTransition),
  );
  var minOpacity = 1.0;
  for (final fade in tester.widgetList<FadeTransition>(fadeFinder)) {
    if (fade.opacity.value < minOpacity) minOpacity = fade.opacity.value;
  }
  return minOpacity;
}

// ─── PREP-PANEL-SCANNER-LIFECYCLE-U2C-A helpers ────────────────────────────
//
// Wraps the panel in a real Scrollable (with a controller we can jump
// precisely) plus enough trailing scroll extent to push the panel fully
// past the top of the viewport, so tests can compute exact scroll offsets
// for a target visible fraction.
Widget _wrapScrollable(Widget child, ScrollController controller) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        controller: controller,
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: child,
            ),
            const SizedBox(height: 1200),
          ],
        ),
      ),
    ),
  );
}

// One frame so the ScrollPosition listener's postFrameCallback can measure
// the panel's fresh geometry, then comfortably past the 150-250ms debounce
// window used to decide whether the visibility state actually flipped.
Future<void> _settleAfterScroll(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 260));
}

// ─── PREP-PANEL-SCANNER-LIFECYCLE-U2C-B helpers ────────────────────────────
//
// Wires `appRouteObserver` into a real Navigator (via `navigatorObservers`),
// which the pre-existing "routing PoC" test above deliberately does NOT do —
// that test documents the gap this phase closes. `navigatorKey` lets tests
// push/pop routes directly, the same pattern the PoC test already uses.
Widget _wrapWithRouteObserver(GlobalKey<NavigatorState> navigatorKey) {
  return MaterialApp(
    navigatorKey: navigatorKey,
    navigatorObservers: [appRouteObserver],
    home: const Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: PreparationPanel(),
        ),
      ),
    ),
  );
}

Future<void> _pushCoveringRoute(
  WidgetTester tester,
  GlobalKey<NavigatorState> navigatorKey,
) async {
  navigatorKey.currentState!.push(
    MaterialPageRoute<void>(builder: (_) => const Scaffold(body: SizedBox())),
  );
  await _pumpFor(tester, const Duration(milliseconds: 400));
}

Future<void> _popCoveringRoute(
  WidgetTester tester,
  GlobalKey<NavigatorState> navigatorKey,
) async {
  navigatorKey.currentState!.pop();
  await _pumpFor(tester, const Duration(milliseconds: 400));
}

void main() {
  setUp(() => lowDistractionNotifier.value = true);
  tearDown(() {
    lowDistractionNotifier.value = false;
    languageNotifier.value = AppLanguage.ptBr;
  });

  // ─── PREP-PANEL-ACTIVATION-U3 — manual activation ──────────────────────

  double? scannerProgressOrNull(WidgetTester tester) {
    final finder = find.descendant(
      of: find.byType(PreparationPanel, skipOffstage: false),
      matching: find.byType(CustomPaint, skipOffstage: false),
      skipOffstage: false,
    );
    if (finder.evaluate().isEmpty) return null;
    expect(finder, findsOneWidget);
    // ignore: avoid_dynamic_calls
    final dynamic painter = tester.widget<CustomPaint>(finder).painter;
    return painter.progress as double;
  }

  // PREP-PANEL-ACTIVATION-U3-FIX1 — reads the scanner painter's public-named
  // `beamXFraction` getter (0.0 leftmost .. 1.0 rightmost, null while paused
  // at either edge) via the same dynamic-dispatch trick as
  // `scannerProgressOrNull`, so directionality can be asserted without
  // duplicating the painter's own segment math in the test.
  double? beamXFraction(WidgetTester tester) {
    final finder = find.descendant(
      of: find.byType(PreparationPanel, skipOffstage: false),
      matching: find.byType(CustomPaint, skipOffstage: false),
      skipOffstage: false,
    );
    expect(finder, findsOneWidget);
    // ignore: avoid_dynamic_calls
    final dynamic painter = tester.widget<CustomPaint>(finder).painter;
    return painter.beamXFraction as double?;
  }

  Rect buttonRect(WidgetTester tester) =>
      tester.getRect(find.byKey(preparationPanelPrepareButtonKey));

  testWidgets('starts idle: title visible, button visible, no indicators, '
      'no scanner built', (tester) async {
    languageNotifier.value = AppLanguage.ptBr;
    await tester.pumpWidget(_wrap(const PreparationPanel()));
    // A non-zero duration (not a bare pump()) so flutter_animate's internal
    // `Future.delayed` housekeeping Timer for the idle button's pulse
    // actually fires before the test ends — see the note on `_kFlushMs`.
    await tester.pump(_kFlushMs);

    expect(find.text('PAINEL DE PREPARAÇÃO'), findsOneWidget);
    expect(find.byKey(preparationPanelPrepareButtonKey), findsOneWidget);
    expect(find.text('CLIQUE PARA PREPARAR'), findsOneWidget);
    for (final label in _sevenLabelsPtBr) {
      expect(find.text(label), findsNothing, reason: '"$label" leaked before tap');
    }
    expect(
      scannerProgressOrNull(tester),
      isNull,
      reason: 'scanner CustomPaint must not exist before the panel is tapped',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping the button removes it and starts the sequence',
      (tester) async {
    await tester.pumpWidget(_wrap(const PreparationPanel()));
    await tester.pump(_kFlushMs);

    await tester.tap(find.byKey(preparationPanelPrepareButtonKey));
    await tester.pump(_kFlushMs);

    expect(find.byKey(preparationPanelPrepareButtonKey), findsNothing);
    expect(tester.takeException(), isNull);

    // Drain every chip/badge `Future.delayed` the freshly-mounted sequence
    // just scheduled (see `_kFlushMs`'s note) before the test ends.
    await _pumpFor(tester, const Duration(milliseconds: _kEntranceSettleMs));
  });

  testWidgets(
    'scanner stays frozen through preparing and only advances once ready',
    (tester) async {
      lowDistractionNotifier.value = false;
      await tester.pumpWidget(_wrap(const PreparationPanel()));
      await tester.pump(_kFlushMs);
      await tester.tap(find.byKey(preparationPanelPrepareButtonKey));
      await tester.pump(_kFlushMs);

      // Still well inside the ~3.33s normal-motion sequence
      // (PREP-PANEL-ACTIVATION-U3-FIX1: 7th indicator delay 2760ms + 570ms
      // tail): scanner exists (subtree already mounted) but must not have
      // started yet.
      await _pumpFor(tester, const Duration(milliseconds: 1000));
      final duringPreparing = scannerProgressOrNull(tester);
      expect(duringPreparing, isNotNull);
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        scannerProgressOrNull(tester),
        duringPreparing,
        reason: 'scanner must not run before the last indicator confirms',
      );

      // Past sequenceCompleteMs (~3.33s from tap) — now it must be running.
      await _pumpFor(tester, const Duration(milliseconds: 2500));
      final afterReady = scannerProgressOrNull(tester);
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        scannerProgressOrNull(tester),
        isNot(equals(afterReady)),
        reason: 'scanner should be running once ready',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('a second tap while preparing/ready is a no-op', (tester) async {
    await tester.pumpWidget(_wrap(const PreparationPanel()));
    await tester.pump();

    // Two taps fired back-to-back, before any rebuild reconciles the tree —
    // exercises the `_panelState != idle` guard directly.
    await tester.tap(find.byKey(preparationPanelPrepareButtonKey));
    await tester.tap(find.byKey(preparationPanelPrepareButtonKey));
    await _pumpFor(tester, const Duration(milliseconds: _kEntranceSettleMs));

    for (final label in _sevenLabelsPtBr) {
      expect(find.text(label), findsOneWidget, reason: 'missing "$label"');
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('a fresh Game Detail instance starts idle again', (tester) async {
    await tester.pumpWidget(_wrap(const PreparationPanel()));
    await _pumpEntranceSettle(tester);
    expect(find.byKey(preparationPanelPrepareButtonKey), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(_kFlushMs);
    await tester.pumpWidget(_wrap(const PreparationPanel()));
    await tester.pump(_kFlushMs);

    expect(find.byKey(preparationPanelPrepareButtonKey), findsOneWidget);
    for (final label in _sevenLabelsPtBr) {
      expect(find.text(label), findsNothing,
          reason: '"$label" leaked into the new instance\'s idle state');
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('button pulses in normal motion', (tester) async {
    lowDistractionNotifier.value = false;
    await tester.pumpWidget(_wrap(const PreparationPanel()));
    await tester.pump(_kFlushMs);

    final samples = <Rect>{buttonRect(tester)};
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 350));
      samples.add(buttonRect(tester));
    }
    expect(samples.length, greaterThan(1),
        reason: 'button never changed size/position — pulse looks frozen');
    expect(tester.takeException(), isNull);
  });

  testWidgets('button still pulses in Baixa Distração, with smaller amplitude',
      (tester) async {
    Future<double> maxWidthDelta(bool reduced, Duration span) async {
      lowDistractionNotifier.value = reduced;
      await tester.pumpWidget(_wrap(const PreparationPanel()));
      await tester.pump(_kFlushMs);
      final baseline = buttonRect(tester).width;
      var maxDelta = 0.0;
      var elapsed = Duration.zero;
      const step = Duration(milliseconds: 80);
      while (elapsed < span) {
        await tester.pump(step);
        elapsed += step;
        final delta = (buttonRect(tester).width - baseline).abs();
        if (delta > maxDelta) maxDelta = delta;
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pump(_kFlushMs);
      return maxDelta;
    }

    // Cover slightly more than a full period in each mode so the sampled
    // peak reflects the mode's own amplitude, not an unlucky sampling phase.
    final reducedDelta =
        await maxWidthDelta(true, const Duration(milliseconds: 2300));
    final normalDelta =
        await maxWidthDelta(false, const Duration(milliseconds: 1500));

    expect(reducedDelta, greaterThan(0),
        reason: 'button must keep pulsing in Baixa Distração, just smaller');
    expect(
      reducedDelta,
      lessThan(normalDelta),
      reason: 'Baixa Distração pulse should be noticeably smaller than normal',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('button stays static when disableAnimations is set',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: const PreparationPanel(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final baseline = buttonRect(tester);
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 350));
      expect(buttonRect(tester), baseline,
          reason: 'button must not animate when disableAnimations is set');
    }
    expect(tester.takeException(), isNull);
  });

  const idleViewports = [Size(320, 640), Size(360, 800)];
  const idleTextScales = [1.0, 1.3];

  for (final viewport in idleViewports) {
    for (final textScale in idleTextScales) {
      testWidgets(
        'idle button has no overflow — '
        '${viewport.width.toInt()}x${viewport.height.toInt()}, '
        'textScale $textScale',
        (tester) async {
          tester.view.physicalSize = viewport;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            _wrap(const PreparationPanel(), textScale: textScale),
          );
          await tester.pump(_kFlushMs);

          expect(tester.takeException(), isNull);
          final panelRect = tester.getRect(find.byType(PreparationPanel));
          final labelRect =
              tester.getRect(find.text('CLIQUE PARA PREPARAR'));
          expect(
            panelRect.contains(labelRect.topLeft) &&
                panelRect.contains(labelRect.bottomRight),
            isTrue,
            reason:
                'button label at $labelRect is not contained in panel $panelRect',
          );
        },
      );
    }
  }

  // ─── PREP-PANEL-ACTIVATION-U3-FIX1 — physical-validation fix ───────────

  for (final reduced in [false, true]) {
    final modeLabel = reduced ? 'Baixa Distração' : 'normal';
    testWidgets(
      'each of the seven indicators appears strictly in order, never before '
      'its own instant, and stays visible once shown ($modeLabel mode)',
      (tester) async {
        lowDistractionNotifier.value = reduced;
        languageNotifier.value = AppLanguage.ptBr;
        await tester.pumpWidget(_wrap(const PreparationPanel()));
        await tester.pump();
        await tester.tap(find.byKey(preparationPanelPrepareButtonKey));
        await tester.pump();

        var elapsedMs = 0;
        for (var i = 0; i < _sevenLabelsPtBr.length; i++) {
          final dueAtMs = _indicatorDelayMs(i);

          // Just before this indicator's own instant: its own opacity must
          // still be zero, while every earlier one must already be visible
          // (opacity > 0) and stay that way.
          final justBeforeMs = dueAtMs - 60;
          await _pumpFor(
            tester,
            Duration(milliseconds: justBeforeMs - elapsedMs),
          );
          elapsedMs = justBeforeMs;
          expect(
            _labelOpacity(tester, _sevenLabelsPtBr[i]),
            0.0,
            reason: '"${_sevenLabelsPtBr[i]}" appeared before its own '
                'instant ($dueAtMs ms) in $modeLabel mode',
          );
          for (var j = 0; j < i; j++) {
            expect(
              _labelOpacity(tester, _sevenLabelsPtBr[j]),
              greaterThan(0.0),
              reason: '"${_sevenLabelsPtBr[j]}" is no longer visible after '
                  'having appeared, in $modeLabel mode',
            );
          }

          // Just after: it must now be visible.
          final justAfterMs = dueAtMs + 120;
          await _pumpFor(
            tester,
            Duration(milliseconds: justAfterMs - elapsedMs),
          );
          elapsedMs = justAfterMs;
          expect(
            _labelOpacity(tester, _sevenLabelsPtBr[i]),
            greaterThan(0.0),
            reason: '"${_sevenLabelsPtBr[i]}" did not appear at its own '
                'instant ($dueAtMs ms) in $modeLabel mode',
          );
        }
        expect(tester.takeException(), isNull);

        // Drain any remaining scheduled `Future.delayed` housekeeping
        // before the test ends (see `_kFlushMs`'s note).
        await _pumpFor(tester, const Duration(milliseconds: _kEntranceSettleMs));
      },
    );
  }

  testWidgets('all seven indicators use seven distinct, non-red colors',
      (tester) async {
    await tester.pumpWidget(_wrap(const PreparationPanel()));
    await _pumpEntranceSettle(tester);

    final icons = tester
        .widgetList<Icon>(
          find.descendant(
            of: find.byType(PreparationPanel),
            matching: find.byType(Icon),
          ),
        )
        .toList();
    expect(icons.length, 7,
        reason: 'expected exactly 7 indicator icons once ready');

    final colors = icons.map((icon) => icon.color).toSet();
    expect(colors.length, 7,
        reason: 'indicator colors are not all distinct');
    expect(colors, {
      AppColors.apexGreen,
      AppColors.cyberBlue,
      AppColors.energyOrange,
      AppColors.neonCyan,
      AppColors.neonViolet,
      AppColors.neonLime,
      AppColors.neonMagenta,
    });
    expect(colors.contains(AppColors.apexNeonRed), isFalse,
        reason: 'red must never be used on the indicators themselves');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'scanner beam sweeps left-to-right then pauses, then sweeps back '
    'right-to-left and pauses, within one round-trip cycle',
    (tester) async {
      lowDistractionNotifier.value = false;
      await tester.pumpWidget(_wrap(const PreparationPanel()));
      await _pumpEntranceSettle(tester);

      const stepMs = 100;
      // One full round trip is 2*(1900+1100)=6000ms; stay safely inside it
      // so a second cycle's rise doesn't get folded into this sample set.
      const spanMs = 5800;
      final samples = <double?>[];
      for (var elapsed = 0; elapsed <= spanMs; elapsed += stepMs) {
        samples.add(beamXFraction(tester));
        await tester.pump(const Duration(milliseconds: stepMs));
      }

      final visible = <double>[];
      for (final v in samples) {
        if (v != null) visible.add(v);
      }
      expect(visible, isNotEmpty, reason: 'beam was never visible');

      var peakIndex = 0;
      var peakValue = -1.0;
      for (var i = 0; i < visible.length; i++) {
        if (visible[i] > peakValue) {
          peakValue = visible[i];
          peakIndex = i;
        }
      }
      expect(peakValue, greaterThan(0.9),
          reason: 'beam never reached near the right edge');

      const tolerance = 0.05;
      for (var i = 1; i <= peakIndex; i++) {
        expect(
          visible[i],
          greaterThanOrEqualTo(visible[i - 1] - tolerance),
          reason: 'beam moved backward while sweeping right (sample $i)',
        );
      }
      for (var i = peakIndex + 1; i < visible.length; i++) {
        expect(
          visible[i],
          lessThanOrEqualTo(visible[i - 1] + tolerance),
          reason: 'beam moved forward while sweeping left (sample $i)',
        );
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'scanner does not jump or restart mid-sweep when a round-trip cycle '
    'wraps',
    (tester) async {
      lowDistractionNotifier.value = false;
      await tester.pumpWidget(_wrap(const PreparationPanel()));
      await _pumpEntranceSettle(tester);

      // The controller's own repeat() cycle began the instant `ready` was
      // reached (sequenceCompleteMs = 2760 + 570 = 3330ms in normal
      // motion), and `_pumpEntranceSettle` already advanced a fixed
      // _kEntranceSettleMs (3500ms) past the tap — so by now the scanner is
      // already (3500-3330)=170ms into its own first round-trip cycle. One
      // full round trip is 2*(1900+1100)=6000ms, so the wrap lands
      // 6000-170=5830ms from here.
      final sequenceCompleteMs = _indicatorDelayMs(6) + _kIndicatorTailNormalMs;
      final alreadyIntoCycleMs = _kEntranceSettleMs - sequenceCompleteMs;
      const totalCycleMs = 2 * (1900 + 1100);
      final msUntilWrap = totalCycleMs - alreadyIntoCycleMs;

      await _pumpFor(
        tester,
        Duration(milliseconds: msUntilWrap - 80),
      );
      final justBeforeWrap = beamXFraction(tester);

      await tester.pump(const Duration(milliseconds: 160));
      final justAfterWrap = beamXFraction(tester);

      // Right around the wrap the beam is at/near the left edge on both
      // sides — paused-left just before it, the very start of a fresh
      // rightward sweep just after — never a sudden mid-travel value.
      if (justBeforeWrap != null) {
        expect(justBeforeWrap, lessThan(0.1),
            reason: 'beam was not near the left edge just before the wrap');
      }
      if (justAfterWrap != null) {
        expect(justAfterWrap, lessThan(0.15),
            reason: 'beam jumped to a mid-travel position right after the '
                'wrap instead of restarting from the left edge');
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'scanner only starts animating once the 7th indicator has appeared',
    (tester) async {
      lowDistractionNotifier.value = false;
      languageNotifier.value = AppLanguage.ptBr;
      await tester.pumpWidget(_wrap(const PreparationPanel()));
      await tester.pump();
      await tester.tap(find.byKey(preparationPanelPrepareButtonKey));
      await tester.pump();

      // Just before the 7th indicator's own instant (300 + 6*410 = 2760ms):
      // its opacity must still be zero, and the scanner must still be
      // frozen.
      await _pumpFor(tester, const Duration(milliseconds: 2700));
      expect(_labelOpacity(tester, 'Performance melhorada'), 0.0);
      final frozenBefore = scannerProgressOrNull(tester);
      expect(frozenBefore, isNotNull);
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        scannerProgressOrNull(tester),
        frozenBefore,
        reason: 'scanner moved before the 7th indicator appeared',
      );

      // Past the 7th indicator's own entrance and its confirmation tail
      // (~570ms in normal motion) — now it must be visible and the scanner
      // must be running.
      await _pumpFor(tester, const Duration(milliseconds: 700));
      expect(
        _labelOpacity(tester, 'Performance melhorada'),
        greaterThan(0.0),
      );
      final afterReady = scannerProgressOrNull(tester);
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        scannerProgressOrNull(tester),
        isNot(equals(afterReady)),
        reason: 'scanner did not start once the 7th indicator was ready',
      );
      expect(tester.takeException(), isNull);
    },
  );

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

    // PREP-PANEL-ACTIVATION-U3 — the title now sits above the animated
    // content area (outside the scanner's clip), so the clip is compared
    // against the `AnimatedSize` region it lives in rather than the whole
    // panel (which also includes the always-visible title).
    final contentAreaFinder = find.descendant(
      of: find.byType(PreparationPanel),
      matching: find.byType(AnimatedSize),
    );

    for (var i = 0; i < 3; i++) {
      await _pumpFor(tester, const Duration(milliseconds: 900));
      final contentRect = tester.getRect(contentAreaFinder);
      final clipRect = tester.getRect(clipFinder);
      expect(
        clipRect,
        rectMoreOrLessEquals(contentRect, epsilon: 0.5),
        reason: 'scanner clip $clipRect escaped content bounds $contentRect',
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

  // ─── PREP-PANEL-SCANNER-LIFECYCLE-U2C-A — viewport visibility ──────────

  testWidgets(
    'pauses the ambient scanner when the panel scrolls below 5% visible',
    (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _wrapScrollable(const PreparationPanel(), controller),
      );
      await _pumpEntranceSettle(tester);

      final panelRect = tester.getRect(find.byType(PreparationPanel));
      double offsetForFraction(double f) =>
          panelRect.top + (1 - f) * panelRect.height;

      controller.jumpTo(offsetForFraction(0.0));
      await _settleAfterScroll(tester);

      final frozenA = _scannerProgress(tester);
      await tester.pump(const Duration(milliseconds: 600));
      final frozenB = _scannerProgress(tester);

      expect(
        frozenA,
        frozenB,
        reason: 'scanner should freeze once the panel drops below 5% visible',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'resumes the ambient scanner without resetting phase when back above '
    '15% visible',
    (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _wrapScrollable(const PreparationPanel(), controller),
      );
      await _pumpEntranceSettle(tester);

      final panelRect = tester.getRect(find.byType(PreparationPanel));
      double offsetForFraction(double f) =>
          panelRect.top + (1 - f) * panelRect.height;

      controller.jumpTo(offsetForFraction(0.0));
      await _settleAfterScroll(tester);
      final frozen = _scannerProgress(tester);
      await tester.pump(const Duration(milliseconds: 400));
      expect(_scannerProgress(tester), frozen);

      controller.jumpTo(offsetForFraction(0.30));
      await _settleAfterScroll(tester);

      // AnimationController.repeat() seeds its new simulation's phase from
      // the controller's current value (Flutter's _RepeatingSimulation uses
      // it as _initialT), so resuming must continue forward from `frozen`
      // instead of snapping back near zero.
      final resumedFirstSample = _scannerProgress(tester);
      expect(
        resumedFirstSample,
        greaterThanOrEqualTo(frozen),
        reason:
            'scanner phase should continue from where it froze ($frozen), '
            'not restart at the beginning of the sweep',
      );

      await tester.pump(const Duration(milliseconds: 400));
      expect(_scannerProgress(tester), isNot(equals(resumedFirstSample)));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'keeps the prior scanner state while the visible fraction sits in the '
    '5%-15% hysteresis band',
    (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _wrapScrollable(const PreparationPanel(), controller),
      );
      await _pumpEntranceSettle(tester);

      final panelRect = tester.getRect(find.byType(PreparationPanel));
      double offsetForFraction(double f) =>
          panelRect.top + (1 - f) * panelRect.height;

      // Coming from fully visible (animating): dip into the dead zone and
      // confirm it keeps animating instead of pausing just for being < 15%.
      controller.jumpTo(offsetForFraction(0.10));
      await _settleAfterScroll(tester);
      final s1 = _scannerProgress(tester);
      await tester.pump(const Duration(milliseconds: 500));
      final s2 = _scannerProgress(tester);
      expect(
        s1,
        isNot(equals(s2)),
        reason: 'scanner paused inside the 5%-15% band coming from visible',
      );

      // Push it fully out of view so it actually pauses...
      controller.jumpTo(offsetForFraction(0.0));
      await _settleAfterScroll(tester);
      final frozen = _scannerProgress(tester);
      await tester.pump(const Duration(milliseconds: 300));
      expect(_scannerProgress(tester), frozen);

      // ...then bring it back only into the dead zone and confirm it stays
      // paused instead of resuming just for being >= 5%.
      controller.jumpTo(offsetForFraction(0.10));
      await _settleAfterScroll(tester);
      final f1 = _scannerProgress(tester);
      await tester.pump(const Duration(milliseconds: 500));
      final f2 = _scannerProgress(tester);
      expect(
        f1,
        f2,
        reason: 'scanner resumed inside the 5%-15% band coming from hidden',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'keeps panel size unchanged while scrolling in and out of view',
    (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _wrapScrollable(const PreparationPanel(), controller),
      );
      await _pumpEntranceSettle(tester);

      final panelRect = tester.getRect(find.byType(PreparationPanel));
      final baselineSize = panelRect.size;
      double offsetForFraction(double f) =>
          panelRect.top + (1 - f) * panelRect.height;

      for (final f in [0.0, 0.10, 0.30]) {
        controller.jumpTo(offsetForFraction(f));
        await _settleAfterScroll(tester);
        expect(
          tester.getRect(find.byType(PreparationPanel)).size,
          baselineSize,
          reason: 'panel size changed while scrolling to fraction $f',
        );
      }
      controller.jumpTo(0);
      await _settleAfterScroll(tester);
      expect(
        tester.getRect(find.byType(PreparationPanel)).size,
        baselineSize,
      );
      expect(tester.takeException(), isNull);
    },
  );

  // ─── PREP-PANEL-SCANNER-LIFECYCLE-U2C-A — app lifecycle ────────────────

  testWidgets(
    'pauses the ambient scanner when the app goes to background',
    (tester) async {
      await tester.pumpWidget(_wrap(const PreparationPanel()));
      await _pumpEntranceSettle(tester);

      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.detached,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
        await tester.pump();
        final frozenA = _scannerProgress(tester);
        await tester.pump(const Duration(milliseconds: 500));
        final frozenB = _scannerProgress(tester);
        expect(frozenA, frozenB, reason: 'scanner kept animating in $state');

        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'resumes the ambient scanner on AppLifecycleState.resumed only if the '
    'panel is visible',
    (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _wrapScrollable(const PreparationPanel(), controller),
      );
      await _pumpEntranceSettle(tester);

      final panelRect = tester.getRect(find.byType(PreparationPanel));
      double offsetForFraction(double f) =>
          panelRect.top + (1 - f) * panelRect.height;

      controller.jumpTo(offsetForFraction(0.0));
      await _settleAfterScroll(tester);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();

      final frozen = _scannerProgress(tester);
      await tester.pump(const Duration(milliseconds: 300));
      expect(_scannerProgress(tester), frozen);

      // Foreground again while the panel is STILL off-screen — must stay
      // paused.
      tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        _scannerProgress(tester),
        frozen,
        reason:
            'scanner resumed on app foreground even though the panel is '
            'not visible',
      );

      // Now scroll it back into view (app already resumed) — should resume.
      controller.jumpTo(offsetForFraction(0.30));
      await _settleAfterScroll(tester);
      final afterResume = _scannerProgress(tester);
      await tester.pump(const Duration(milliseconds: 400));
      expect(_scannerProgress(tester), isNot(equals(afterResume)));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'does not replay the chip/badge entrance sequence across a pause/resume '
    'cycle',
    (tester) async {
      await tester.pumpWidget(_wrap(const PreparationPanel()));
      await _pumpEntranceSettle(tester);

      for (final label in _sevenLabelsPtBr) {
        _expectNoZeroOpacityAncestors(
          tester,
          find.text(label),
          label,
          'before pause',
        );
      }

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(milliseconds: 500));
      tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );
      await tester.pump();

      // If the entrance sequence had replayed, chips/badges would be back
      // in their initial (fully transparent) fadeIn state right here.
      for (final label in _sevenLabelsPtBr) {
        _expectNoZeroOpacityAncestors(
          tester,
          find.text(label),
          label,
          'immediately after resume',
        );
      }
      await tester.pump(const Duration(milliseconds: 500));
      for (final label in _sevenLabelsPtBr) {
        _expectNoZeroOpacityAncestors(
          tester,
          find.text(label),
          label,
          'after resume settle',
        );
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'keeps seven texts present through scroll-away, background and resume',
    (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _wrapScrollable(const PreparationPanel(), controller),
      );
      await _pumpEntranceSettle(tester);

      final panelRect = tester.getRect(find.byType(PreparationPanel));
      double offsetForFraction(double f) =>
          panelRect.top + (1 - f) * panelRect.height;

      controller.jumpTo(offsetForFraction(0.0));
      await _settleAfterScroll(tester);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(milliseconds: 300));
      tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );
      await tester.pump();
      controller.jumpTo(offsetForFraction(0.30));
      await _settleAfterScroll(tester);

      for (final label in _sevenLabelsPtBr) {
        expect(find.text(label), findsOneWidget, reason: 'missing "$label"');
      }
      expect(tester.takeException(), isNull);
    },
  );

  // ─── PREP-PANEL-SCANNER-LIFECYCLE-U2C-A — dispose safety ───────────────

  testWidgets(
    'cancels pending scroll/debounce work on dispose without leaking a '
    'Timer',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _wrapScrollable(const PreparationPanel(), controller),
      );
      await _pumpEntranceSettle(tester);

      final panelRect = tester.getRect(find.byType(PreparationPanel));
      controller.jumpTo(panelRect.top + panelRect.height);
      // One frame lets the scroll listener schedule its debounce timer, but
      // we deliberately do NOT wait it out before disposing.
      await tester.pump();

      await tester.pumpWidget(const SizedBox());
      // If dispose leaked the debounce Timer, or a postFrameCallback still
      // touched the disposed State, this pump (or flutter_test's automatic
      // pending-timer check at tearDown) would fail.
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
    },
  );

  // ─── PREP-PANEL-SCANNER-LIFECYCLE-U2C-A — routing / TickerMode PoC ─────
  //
  // FINDING (documented, not assumed — see debugDumpApp() trace captured
  // while building this PoC): pushing a plain MaterialPageRoute on top of
  // PreparationPanel's route does NOT mute its ticker. The dumped tree
  // showed `_EffectiveTickerMode(effective mode: enabled)` and
  // `_PreparationPanelState(... ticker active)` still active for the
  // covered route after the push transition fully completed. Overlay's
  // onstage/tickerEnabled scan (see overlay.dart OverlayState.build) keys
  // off each OverlayEntry's own `opaque` flag, and ModalRoute only ever
  // sets that flag on its *barrier* entry (`overlayEntries.first.opaque =
  // opaque`, in TransitionRoute._handleStatusChanged/install — see
  // routes.dart), never on the `_modalScope` content entry itself; in this
  // plain-push scenario that was not enough to flip the covered route
  // offstage. Per PREP-PANEL-SCANNER-LIFECYCLE-U2C-AUDIT item 4, this
  // means Flutter's built-in TickerMode does NOT cover the "route pushed
  // on top" case here — PREP-PANEL-SCANNER-LIFECYCLE-U2C-B (RouteObserver)
  // is required to pause the scanner while covered by another route. No
  // RouteObserver is introduced in this phase; this test only records the
  // real, observed behavior so U2C-B has an accurate starting point.
  testWidgets(
    'documents that a plain pushed route does NOT mute the scanner via '
    'TickerMode alone — PREP-PANEL-SCANNER-LIFECYCLE-U2C-B is needed for '
    'that case',
    (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: PreparationPanel(),
              ),
            ),
          ),
        ),
      );
      await _pumpEntranceSettle(tester);

      final before = _scannerProgress(tester);
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        _scannerProgress(tester),
        isNot(equals(before)),
        reason: 'sanity check: scanner should be running before the push',
      );

      navigatorKey.currentState!.push(
        MaterialPageRoute<void>(builder: (_) => const Scaffold(body: SizedBox())),
      );
      // Bounded pump (not pumpAndSettle — the scanner's own controller
      // repeats forever) covering the default push transition.
      await _pumpFor(tester, const Duration(milliseconds: 400));

      final coveredA = _scannerProgress(tester);
      await tester.pump(const Duration(milliseconds: 600));
      final coveredB = _scannerProgress(tester);
      expect(
        coveredA,
        isNot(equals(coveredB)),
        reason:
            'this documents the current, real Flutter behavior: the '
            'scanner keeps animating while covered by a plain pushed '
            'route, because TickerMode alone does not disable it here — '
            'if this assertion ever starts failing (i.e. it becomes '
            'equal), Flutter changed this behavior and U2C-B may no '
            'longer be necessary; re-verify before assuming so',
      );

      navigatorKey.currentState!.pop();
      await _pumpFor(tester, const Duration(milliseconds: 400));
      final afterPopA = _scannerProgress(tester);
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        _scannerProgress(tester),
        isNot(equals(afterPopA)),
        reason: 'scanner did not keep animating after popping back',
      );
      expect(tester.takeException(), isNull);
    },
  );

  // ─── PREP-PANEL-SCANNER-LIFECYCLE-U2C-B — route awareness ──────────────
  //
  // Same scenario as the PoC above, but now wired through `appRouteObserver`
  // (registered as a real `navigatorObservers` entry), which is exactly what
  // the PoC documented as missing.

  testWidgets('pushing a route on top pauses the ambient scanner',
      (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(_wrapWithRouteObserver(navigatorKey));
    await _pumpEntranceSettle(tester);

    final before = _scannerProgress(tester);
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      _scannerProgress(tester),
      isNot(equals(before)),
      reason: 'sanity check: scanner should be running before the push',
    );

    await _pushCoveringRoute(tester, navigatorKey);

    final coveredA = _scannerProgress(tester);
    await tester.pump(const Duration(milliseconds: 600));
    final coveredB = _scannerProgress(tester);
    expect(
      coveredA,
      coveredB,
      reason:
          'scanner should freeze once another route covers Game Detail',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'popping the covering route resumes the scanner from its preserved '
    'phase',
    (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(_wrapWithRouteObserver(navigatorKey));
      await _pumpEntranceSettle(tester);

      await _pushCoveringRoute(tester, navigatorKey);
      final frozen = _scannerProgress(tester);
      await tester.pump(const Duration(milliseconds: 400));
      expect(_scannerProgress(tester), frozen);

      await _popCoveringRoute(tester, navigatorKey);

      // Same phase-preservation guarantee as U2C-A's viewport resume: the
      // controller's repeat() reseeds from its current value, so this must
      // continue forward from `frozen`, never snap back near zero.
      final resumedFirstSample = _scannerProgress(tester);
      expect(
        resumedFirstSample,
        greaterThanOrEqualTo(frozen),
        reason:
            'scanner phase should continue from where it froze ($frozen), '
            'not restart at the beginning of the sweep',
      );

      await tester.pump(const Duration(milliseconds: 400));
      expect(_scannerProgress(tester), isNot(equals(resumedFirstSample)));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'does not replay the chip/badge entrance sequence across a route '
    'push/pop cycle',
    (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(_wrapWithRouteObserver(navigatorKey));
      await _pumpEntranceSettle(tester);

      for (final label in _sevenLabelsPtBr) {
        _expectNoZeroOpacityAncestors(
          tester,
          find.text(label),
          label,
          'before push',
        );
      }

      await _pushCoveringRoute(tester, navigatorKey);
      await _popCoveringRoute(tester, navigatorKey);

      // If the entrance sequence had replayed, chips/badges would be back
      // in their initial (fully transparent) fadeIn state right here.
      for (final label in _sevenLabelsPtBr) {
        expect(find.text(label), findsOneWidget,
            reason: 'missing "$label" after pop');
        _expectNoZeroOpacityAncestors(
          tester,
          find.text(label),
          label,
          'after pop',
        );
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'scanner resumes only once route, viewport and lifecycle conditions '
    'all clear',
    (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final navigatorKey = GlobalKey<NavigatorState>();
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          navigatorObservers: [appRouteObserver],
          home: Scaffold(
            body: SingleChildScrollView(
              controller: controller,
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: PreparationPanel(),
                  ),
                  const SizedBox(height: 1200),
                ],
              ),
            ),
          ),
        ),
      );
      await _pumpEntranceSettle(tester);

      final panelRect = tester.getRect(find.byType(PreparationPanel));
      double offsetForFraction(double f) =>
          panelRect.top + (1 - f) * panelRect.height;

      // Sanity: running while all three conditions are good.
      final running1 = _scannerProgress(tester);
      await tester.pump(const Duration(milliseconds: 300));
      expect(_scannerProgress(tester), isNot(equals(running1)));

      // Break the viewport condition only.
      controller.jumpTo(offsetForFraction(0.0));
      await _settleAfterScroll(tester);
      final frozenViewport = _scannerProgress(tester);
      await tester.pump(const Duration(milliseconds: 300));
      expect(_scannerProgress(tester), frozenViewport);

      // Break the route condition too (viewport + route both bad).
      await _pushCoveringRoute(tester, navigatorKey);
      final frozenRoute = _scannerProgress(tester);
      await tester.pump(const Duration(milliseconds: 300));
      expect(_scannerProgress(tester), frozenRoute);

      // Break the lifecycle condition too (all three bad).
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      final frozenAll = _scannerProgress(tester);
      await tester.pump(const Duration(milliseconds: 300));
      expect(_scannerProgress(tester), frozenAll);

      // Clear lifecycle — must stay frozen (route + viewport still bad).
      tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        _scannerProgress(tester),
        frozenAll,
        reason: 'route still covers and viewport is still out of view',
      );

      // Clear route — must stay frozen (viewport still bad).
      await _popCoveringRoute(tester, navigatorKey);
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        _scannerProgress(tester),
        frozenAll,
        reason: 'viewport is still out of view',
      );

      // Clear the last condition (viewport) — only now does it resume.
      controller.jumpTo(offsetForFraction(0.30));
      await _settleAfterScroll(tester);
      final afterResume = _scannerProgress(tester);
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        _scannerProgress(tester),
        isNot(equals(afterResume)),
        reason: 'scanner should resume once all three conditions clear',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'stacks correctly across repeated pushes and unsubscribes cleanly on '
    'dispose',
    (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(_wrapWithRouteObserver(navigatorKey));
      await _pumpEntranceSettle(tester);

      // Two routes stacked on top of Game Detail.
      await _pushCoveringRoute(tester, navigatorKey);
      await _pushCoveringRoute(tester, navigatorKey);
      final frozenUnderTwo = _scannerProgress(tester);
      await tester.pump(const Duration(milliseconds: 400));
      expect(_scannerProgress(tester), frozenUnderTwo);

      // Popping only ONE of the two must NOT resume it yet — a miscounted
      // or duplicated subscription is exactly what would make this resume
      // one pop too early.
      await _popCoveringRoute(tester, navigatorKey);
      final stillFrozen = _scannerProgress(tester);
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        _scannerProgress(tester),
        stillFrozen,
        reason:
            'still covered by the second pushed route — must stay paused',
      );

      // Popping the last one resumes it.
      await _popCoveringRoute(tester, navigatorKey);
      final afterResume = _scannerProgress(tester);
      await tester.pump(const Duration(milliseconds: 400));
      expect(_scannerProgress(tester), isNot(equals(afterResume)));

      // Clean unsubscribe: once removed from the tree, the shared observer
      // must no longer be tracking this panel's route at all.
      final route = ModalRoute.of(
        tester.element(find.byType(PreparationPanel)),
      )! as PageRoute<dynamic>;
      await tester.pumpWidget(const SizedBox());
      expect(appRouteObserver.debugObservingRoute(route), isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'unsubscribes safely on dispose while still covered by a pushed route',
    (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(_wrapWithRouteObserver(navigatorKey));
      await _pumpEntranceSettle(tester);

      await _pushCoveringRoute(tester, navigatorKey);

      // Tear down the whole tree (panel + covering route + Navigator) while
      // the panel's route is still covered/offstage and still subscribed.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
    },
  );
}
