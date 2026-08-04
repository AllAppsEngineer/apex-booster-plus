import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:apex_booster_plus/core/accessibility/low_distraction_service.dart';
import 'package:apex_booster_plus/core/constants/app_colors.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/core/i18n/app_strings.dart';
import 'package:apex_booster_plus/core/routing/app_route_observer.dart';

// ─── Preparation panel section (UX-P1.1 / PREP-PANEL-VISUAL-U1) ─────────────
//
// Indicator labels (FPS/RAM/GPU/Ping/Boost aplicado/Performance melhorada)
// are a fixed, non-negotiable product decision — never alter this copy here.
// Only the surrounding motion (entrance, checking state, confirmation glow,
// cyclic highlight, badge celebration) may be adjusted in this section.
//
// Extracted verbatim from game_detail_screen.dart in PREP-PANEL-ISOLATION-U2A
// (structural refactor only — no visual, textual, behavioral or animation
// change versus PREP-PANEL-VISUAL-U1).
//
// PREP-PANEL-ACCESSIBILITY-U2A1: the chip/badge Row (icon + label) used to
// overflow at textScale 1.3 on narrow viewports (320x640, 360x800) — root
// cause was the label Text having no Flexible, so it could not wrap. Fixed
// by wrapping the label in Flexible (softWrap, maxLines: 2) in both
// _ModuleChip and _ConfirmBadge; textScale 1.0 appearance is unchanged.
//
// PREP-PANEL-VISUAL-U2B: adds a purely decorative, continuous ambient
// scanner (background tint + breathing glow + horizontal sweep) behind the
// chips/badges. It never touches their layout, colors, borders or timing —
// it only becomes visible (via a one-shot flutter_animate fadeIn, not a
// second controller) once the existing entrance sequence above has actually
// finished. Exactly one manually-created AnimationController exists in this
// file (`_scannerController`); it drives both the sweep position and the
// breathing-glow alpha, is disposed in State.dispose(), and is wrapped in
// IgnorePointer/ClipRRect so it can never intercept input or paint outside
// the panel's own bounds.
//
// PREP-PANEL-SCANNER-LIFECYCLE-U2C-A: `_scannerController` is stopped
// (never disposed/recreated) when the panel drops below 5% visible in its
// ancestor Scrollable, or while the app is not `resumed`, and resumed only
// once both conditions clear — with a 5%/15% hysteresis band plus a 200ms
// debounce to avoid flicker right at the boundary. AnimationController.
// repeat() seeds its next phase from the controller's *current* value
// (Flutter's `_RepeatingSimulation` uses it as `_initialT`), so pausing and
// resuming never restarts the sweep from zero and never touches the
// one-shot chip/badge entrance animations above, which are unrelated to
// this controller. This phase intentionally relies only on the ambient
// `TickerMode` Flutter already provides — empirically it does NOT mute this
// controller when a plain route is pushed on top (see the routing PoC in
// preparation_panel_test.dart).
//
// PREP-PANEL-SCANNER-LIFECYCLE-U2C-B: covers exactly that gap via
// `RouteAware`, subscribing to the shared `appRouteObserver` (registered on
// `appRouter`'s `observers`). `didPushNext()`/`didPop()`'s counterparts
// (`didPush()`/`didPopNext()`) flip `_isRouteCovered`, a third input to the
// same `_shouldAnimateScanner` gate/`_applyScannerRunningState()` used by
// U2C-A — no second pause mechanism, no AnimationController recreation.

const _kChipEntranceDurMs = 220;

// Scanner cadence — values are fixed midpoints of the ranges requested in
// PREP-PANEL-VISUAL-U2B (kept as named constants, not re-derived per frame).
const _kScannerNormalSweepMs = 1900; // range 1600-2200
const _kScannerNormalPauseMs = 1100; // range 800-1500
const _kScannerReducedSweepMs = 2500; // range 2200-2800
const _kScannerReducedPauseMs = 2300; // range 1800-2800
// Only "Modo normal" specifies an "entrada completa" window in the ticket;
// Baixa Distração skips that extra flourish and fades the layer in quickly.
const _kScannerNormalEntranceRampMs = 2100; // range 1800-2400
const _kScannerReducedEntranceRampMs = 400;

class PreparationPanel extends StatefulWidget {
  const PreparationPanel({super.key});

  @override
  State<PreparationPanel> createState() => _PreparationPanelState();
}

class _PreparationPanelState extends State<PreparationPanel>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  late final AnimationController _scannerController;
  bool? _scannerReducedMotion;
  Duration? _scannerPeriod;

  // PREP-PANEL-SCANNER-LIFECYCLE-U2C-A — viewport visibility. Hysteresis
  // (different on/off thresholds) plus a debounce stop flicker right at the
  // boundary from toggling the scanner on/off repeatedly.
  static const _kVisibleOnThreshold = 0.15;
  static const _kVisibleOffThreshold = 0.05;
  static const _kVisibilityDebounceMs = 200;

  ScrollPosition? _scrollPosition;
  bool _isVisible = true; // assumed visible until the first real measurement
  Timer? _visibilityDebounceTimer;

  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;

  // PREP-PANEL-SCANNER-LIFECYCLE-U2C-B — route coverage. Assumed uncovered
  // until `didPushNext()` says otherwise, mirroring `_isVisible`'s
  // assumed-visible default above (both wait for a real signal to flip).
  PageRoute<dynamic>? _subscribedRoute;
  bool _isRouteCovered = false;

  bool get _shouldAnimateScanner =>
      _isVisible &&
      _lifecycleState == AppLifecycleState.resumed &&
      !_isRouteCovered;

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(vsync: this);
    _lifecycleState =
        WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scheduleVisibilityCheck(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newPosition = Scrollable.maybeOf(context)?.position;
    if (newPosition != _scrollPosition) {
      _scrollPosition?.removeListener(_onScrollChanged);
      _scrollPosition = newPosition;
      _scrollPosition?.addListener(_onScrollChanged);
      _scheduleVisibilityCheck();
    }

    final route = ModalRoute.of(context);
    final newRoute = route is PageRoute<dynamic> ? route : null;
    if (newRoute != _subscribedRoute) {
      if (_subscribedRoute != null) {
        appRouteObserver.unsubscribe(this);
      }
      _subscribedRoute = newRoute;
      if (newRoute != null) {
        appRouteObserver.subscribe(this, newRoute);
      }
    }
  }

  @override
  void dispose() {
    _visibilityDebounceTimer?.cancel();
    _scrollPosition?.removeListener(_onScrollChanged);
    WidgetsBinding.instance.removeObserver(this);
    appRouteObserver.unsubscribe(this);
    _scannerController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    _applyScannerRunningState();
  }

  // PREP-PANEL-SCANNER-LIFECYCLE-U2C-B — RouteAware. `didPush`/`didPopNext`
  // mean this route is on top (uncovered); `didPushNext` means another route
  // now covers it. `didPop` (this route itself being popped) needs no
  // action — the widget is on its way to `dispose()` regardless.
  @override
  void didPush() {
    _isRouteCovered = false;
    _applyScannerRunningState();
  }

  @override
  void didPopNext() {
    _isRouteCovered = false;
    _applyScannerRunningState();
  }

  @override
  void didPushNext() {
    _isRouteCovered = true;
    _applyScannerRunningState();
  }

  void _onScrollChanged() => _scheduleVisibilityCheck();

  void _scheduleVisibilityCheck() {
    // Deferred to a post-frame callback so layout is guaranteed up to date
    // before measuring — geometry read mid-scroll-notification can be stale.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _debounceVisibilityUpdate(_measureVisibleFraction());
    });
  }

  // Fraction of the panel's own height currently within its ancestor
  // Scrollable's viewport bounds, computed via RenderBox geometry — no
  // extra dependency needed. Defaults to fully visible when there is no
  // ancestor Scrollable or geometry isn't ready yet.
  double _measureVisibleFraction() {
    final panelBox = context.findRenderObject();
    if (panelBox is! RenderBox || !panelBox.attached || !panelBox.hasSize) {
      return 1.0;
    }
    final viewportBox =
        Scrollable.maybeOf(context)?.context.findRenderObject();
    if (viewportBox is! RenderBox || !viewportBox.attached) return 1.0;

    final panelHeight = panelBox.size.height;
    if (panelHeight <= 0) return 0.0;
    final panelTop = panelBox.localToGlobal(Offset.zero, ancestor: viewportBox).dy;
    final viewportHeight = viewportBox.size.height;

    final visibleTop = math.max(0.0, panelTop);
    final visibleBottom = math.min(viewportHeight, panelTop + panelHeight);
    final visibleHeight = math.max(0.0, visibleBottom - visibleTop);
    return (visibleHeight / panelHeight).clamp(0.0, 1.0);
  }

  void _debounceVisibilityUpdate(double fraction) {
    final wantsVisible = fraction >= _kVisibleOnThreshold
        ? true
        : (fraction < _kVisibleOffThreshold ? false : _isVisible);
    _visibilityDebounceTimer?.cancel();
    if (wantsVisible == _isVisible) return;
    _visibilityDebounceTimer = Timer(
      const Duration(milliseconds: _kVisibilityDebounceMs),
      () {
        if (!mounted) return;
        _isVisible = wantsVisible;
        _applyScannerRunningState();
      },
    );
  }

  // Keeps the single continuous controller's cadence in sync with Low
  // Distraction Mode without ever creating a second controller.
  void _syncScannerMotion(bool reducedMotion) {
    final motionChanged = _scannerReducedMotion != reducedMotion;
    _scannerReducedMotion = reducedMotion;
    if (motionChanged || _scannerPeriod == null) {
      final sweepMs =
          reducedMotion ? _kScannerReducedSweepMs : _kScannerNormalSweepMs;
      final pauseMs =
          reducedMotion ? _kScannerReducedPauseMs : _kScannerNormalPauseMs;
      _scannerPeriod = Duration(milliseconds: sweepMs + pauseMs);
    }
    _applyScannerRunningState(restart: motionChanged);
  }

  // PREP-PANEL-SCANNER-LIFECYCLE-U2C-A — starts/stops `_scannerController`
  // based on viewport visibility and app lifecycle without ever disposing
  // or recreating it, preserving its current phase across pauses (see the
  // file-level doc comment on AnimationController.repeat()'s phase seeding).
  void _applyScannerRunningState({bool restart = false}) {
    final period = _scannerPeriod;
    if (period == null) return;
    if (_shouldAnimateScanner) {
      if (restart || !_scannerController.isAnimating) {
        _scannerController.repeat(period: period);
      }
    } else if (_scannerController.isAnimating) {
      _scannerController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
    final reducedMotion = lowDistractionNotifier.value;
    _syncScannerMotion(reducedMotion);
    final modules = [
      (label: s.detailModuleFps,          color: AppColors.apexGreen,    icon: Icons.speed_rounded),
      (label: s.detailModuleRam,          color: AppColors.cyberBlue,    icon: Icons.memory_rounded),
      (label: s.detailModuleGpu,          color: AppColors.energyOrange, icon: Icons.videogame_asset_rounded),
      (label: s.detailModulePing,         color: AppColors.cyberBlue,    icon: Icons.wifi_rounded),
      (label: s.detailModuleOptimization, color: AppColors.apexGreen,    icon: Icons.tune_rounded),
    ];

    // Req. #1 — sequential entrance, perceptible but short; compressed in Low
    // Distraction Mode (req. #9).
    final entranceStagger = reducedMotion ? 30 : 70;
    final entranceDurMs = reducedMotion ? 140 : _kChipEntranceDurMs;
    // Req. #2-5 — per-chip "checking" window before the OK confirmation glow.
    // Zero (disabled) in Low Distraction Mode.
    final checkDurMs = reducedMotion ? 0 : 240;

    int entranceDelayMs(int i) => 800 + i * entranceStagger;
    int confirmedAtMs(int i) => entranceDelayMs(i) + entranceDurMs + checkDurMs;

    // Req. #6 — cyclic highlight across FPS/RAM/GPU/Ping only, after every
    // chip has confirmed. Skipped entirely when reducedMotion (req. #9).
    final allConfirmedAt = confirmedAtMs(modules.length - 1);
    const cycleStep = 110;
    final cycleBase = allConfirmedAt + 120;

    // Badges land after the cyclic pass settles, or right after the
    // compressed chip entrance when Low Distraction Mode is on.
    final badgeBaseDelay = reducedMotion
        ? allConfirmedAt + 80
        : cycleBase + 3 * cycleStep + 260;

    // Req. #4 — the ambient scanner layer only fades in once the existing
    // entrance sequence above (chips + both badges, incl. their shimmer/
    // bounce settle) has actually finished; never retimed here.
    final badge2DelayMs = badgeBaseDelay + (reducedMotion ? 60 : 140);
    final sequenceCompleteMs = badge2DelayMs + (reducedMotion ? 300 : 570);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.detailModulesTitle,
          style: const TextStyle(
            color: AppColors.textGray,
            fontWeight: FontWeight.bold,
            fontSize: 10,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (int i = 0; i < modules.length; i++)
              _ModuleChip(
                label: modules[i].label,
                icon: modules[i].icon,
                color: modules[i].color,
                entranceDelayMs: entranceDelayMs(i),
                entranceDurMs: entranceDurMs,
                checkDurMs: checkDurMs,
                reducedMotion: reducedMotion,
                cycleDelayMs: (!reducedMotion && i < 4)
                    ? cycleBase + i * cycleStep
                    : null,
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ConfirmBadge(
              label: s.detailModuleBoostApplied,
              delayMs: badgeBaseDelay,
              reducedMotion: reducedMotion,
            ),
            _ConfirmBadge(
              label: s.detailModulePerfImproved,
              delayMs: badgeBaseDelay + (reducedMotion ? 60 : 140),
              reducedMotion: reducedMotion,
            ),
          ],
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 750.ms, duration: 400.ms)
        .slideY(begin: 0.05, end: 0, delay: 750.ms, duration: 350.ms);

    // Layer order (req. #5): fundo -> glow/respiração -> scanner -> content.
    // All three decorative sub-layers are painted together by
    // _ScannerPainter inside a single Positioned.fill so the Stack's size is
    // driven only by `content` (req. "nenhuma alteração de tamanho").
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AnimatedBuilder(
                animation: _scannerController,
                builder: (context, _) {
                  final sweepMs = reducedMotion
                      ? _kScannerReducedSweepMs
                      : _kScannerNormalSweepMs;
                  final pauseMs = reducedMotion
                      ? _kScannerReducedPauseMs
                      : _kScannerNormalPauseMs;
                  return CustomPaint(
                    painter: _ScannerPainter(
                      progress: _scannerController.value,
                      sweepFraction: sweepMs / (sweepMs + pauseMs),
                      reducedMotion: reducedMotion,
                    ),
                  );
                },
              ),
            ),
          )
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: sequenceCompleteMs),
                duration: reducedMotion
                    ? _kScannerReducedEntranceRampMs.ms
                    : _kScannerNormalEntranceRampMs.ms,
              ),
        ),
        content,
      ],
    );
  }
}

/// Purely decorative ambient background painted behind the chips/badges:
/// a faint breathing glow tied to the full cycle, plus a narrow neon core
/// with a diffuse trail that sweeps horizontally during the sweep phase of
/// the cycle and stays hidden during the pause phase. Confined to whatever
/// [Size] it is given by the enclosing ClipRRect — never draws or reports
/// geometry outside it.
class _ScannerPainter extends CustomPainter {
  final double progress;
  final double sweepFraction;
  final bool reducedMotion;

  const _ScannerPainter({
    required this.progress,
    required this.sweepFraction,
    required this.reducedMotion,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || size.width.isInfinite || size.height.isInfinite) {
      return;
    }
    final intensity = reducedMotion ? 0.65 : 1.0;
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(14));

    canvas.save();
    canvas.clipRRect(rrect);

    // Glow/respiração — one soft pulse per full sweep+pause cycle.
    final breath = 0.5 + 0.5 * math.sin(2 * math.pi * progress);
    final breathAlpha = (0.03 + 0.05 * breath) * intensity;
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = AppColors.apexGreen.withValues(alpha: breathAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    if (progress < sweepFraction) {
      final localT = progress / sweepFraction;
      const edge = 0.08;
      final edgeAlpha = localT < edge
          ? localT / edge
          : (localT > 1 - edge ? (1 - localT) / edge : 1.0);
      final eased = Curves.easeInOut.transform(localT);
      const margin = 26.0;
      final x = -margin + eased * (size.width + margin * 2);

      const trailWidth = 46.0;
      final trailRect =
          Rect.fromLTWH(x - trailWidth, 0, trailWidth, size.height);
      canvas.drawRect(
        trailRect,
        Paint()
          ..shader = LinearGradient(
            colors: [
              AppColors.cyberBlue.withValues(alpha: 0),
              AppColors.cyberBlue.withValues(alpha: 0.22 * edgeAlpha * intensity),
            ],
          ).createShader(trailRect),
      );

      canvas.drawRect(
        Rect.fromLTWH(x - 1.5, 0, 3, size.height),
        Paint()
          ..color = AppColors.cyberBlue
              .withValues(alpha: 0.55 * edgeAlpha * intensity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );

      // Brilho refletido, discreto, nas bordas superior/inferior.
      final edgeGlowAlpha = 0.16 * edgeAlpha * intensity;
      for (final y in [1.5, size.height - 1.5]) {
        canvas.drawLine(
          Offset(x - 14, y),
          Offset(x + 14, y),
          Paint()
            ..color = AppColors.cyberBlue.withValues(alpha: edgeGlowAlpha)
            ..strokeWidth = 2
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScannerPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.sweepFraction != sweepFraction ||
      oldDelegate.reducedMotion != reducedMotion;
}

class _ModuleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int entranceDelayMs;
  final int entranceDurMs;
  final int checkDurMs;
  final bool reducedMotion;
  final int? cycleDelayMs;

  const _ModuleChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.entranceDelayMs,
    required this.entranceDurMs,
    required this.checkDurMs,
    required this.reducedMotion,
    this.cycleDelayMs,
  });

  @override
  Widget build(BuildContext context) {
    final entranceDelay = Duration(milliseconds: entranceDelayMs);
    final entranceDur = Duration(milliseconds: entranceDurMs);
    final checkDur = Duration(milliseconds: checkDurMs);
    final checkEndDelay = entranceDelay + entranceDur + checkDur;

    // Req. #4 — soft icon pulse confined to the checking window (single
    // bounded up/down cycle; never loops indefinitely).
    Widget iconWidget = Icon(icon, color: color, size: 13);
    if (!reducedMotion) {
      iconWidget = iconWidget
          .animate()
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.22, 1.22),
            delay: entranceDelay + entranceDur,
            duration: 110.ms,
            curve: Curves.easeInOut,
          )
          .then()
          .scale(
            begin: const Offset(1.22, 1.22),
            end: const Offset(1, 1),
            duration: 130.ms,
            curve: Curves.easeInOut,
          );
    }

    final chipBody = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.14),
            color.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.38),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.14),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          iconWidget,
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              softWrap: true,
              maxLines: 2,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );

    // Entrance (req. #1) always applies.
    var animated = chipBody
        .animate()
        .fadeIn(delay: entranceDelay, duration: entranceDur)
        .scale(
          begin: const Offset(0.88, 0.88),
          end: const Offset(1.0, 1.0),
          delay: entranceDelay,
          duration: entranceDur,
          curve: Curves.easeOutBack,
        );

    if (!reducedMotion) {
      // Req. #3 — sweep/shimmer crossing the chip during the checking window,
      // then req. #5 — a short confirmation pop once checking completes.
      animated = animated
          .shimmer(
            delay: entranceDelay + entranceDur,
            duration: checkDur,
            color: color.withValues(alpha: 0.5),
          )
          .then()
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.06, 1.06),
            duration: 110.ms,
            curve: Curves.easeOut,
          )
          .then()
          .scale(
            begin: const Offset(1.06, 1.06),
            end: const Offset(1, 1),
            duration: 140.ms,
            curve: Curves.easeIn,
          );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (!reducedMotion)
          _GlowBurst(color: color, delayMs: checkEndDelay.inMilliseconds),
        if (cycleDelayMs != null)
          _GlowBurst(color: color, delayMs: cycleDelayMs!, strong: true),
        animated,
        // Req. #2 — visual-only "checking" state: a dark scrim that dims the
        // chip (same label, same text, never altered) and dissolves right as
        // the confirmation pop/glow fires.
        if (!reducedMotion)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.background.withValues(alpha: 0.55),
                ),
              )
                  .animate()
                  .fadeOut(
                    delay: entranceDelay + entranceDur + 90.ms,
                    duration: 150.ms,
                    curve: Curves.easeOut,
                  ),
            ),
          ),
      ],
    );
  }
}

class _ConfirmBadge extends StatelessWidget {
  final String label;
  final int delayMs;
  final bool reducedMotion;

  const _ConfirmBadge({
    required this.label,
    required this.delayMs,
    required this.reducedMotion,
  });

  @override
  Widget build(BuildContext context) {
    final delay = Duration(milliseconds: delayMs);
    final badgeBody = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.apexGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.apexGreen.withValues(alpha: 0.40),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.apexGreen,
            size: 13,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              softWrap: true,
              maxLines: 2,
              style: const TextStyle(
                color: AppColors.apexGreen,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );

    // Req. #7 — scale-in + fade/slide (always) plus, at normal motion, a
    // shimmer sweep and a short "activation complete" bounce + glow burst.
    var animated = badgeBody
        .animate()
        .fadeIn(delay: delay, duration: 300.ms)
        .slideY(
          begin: 0.10,
          end: 0,
          delay: delay,
          duration: 280.ms,
          curve: Curves.easeOut,
        )
        .scale(
          begin: const Offset(0.82, 0.82),
          end: const Offset(1.0, 1.0),
          delay: delay,
          duration: 300.ms,
          curve: Curves.easeOutBack,
        );

    const shimmerDur = 340;
    if (!reducedMotion) {
      animated = animated
          .shimmer(
            delay: delay,
            duration: shimmerDur.ms,
            color: AppColors.apexGreen.withValues(alpha: 0.6),
          )
          .then()
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: 100.ms,
            curve: Curves.easeOut,
          )
          .then()
          .scale(
            begin: const Offset(1.05, 1.05),
            end: const Offset(1, 1),
            duration: 130.ms,
            curve: Curves.easeIn,
          );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (!reducedMotion)
          _GlowBurst(
            color: AppColors.apexGreen,
            delayMs: delayMs + shimmerDur,
            strong: true,
          ),
        animated,
      ],
    );
  }
}

/// Short, bounded glow flash used for chip/badge confirmation moments and the
/// cyclic FPS/RAM/GPU/Ping highlight pass. Purely decorative (`IgnorePointer`)
/// and self-contained: no manual `AnimationController`, timer, or listener —
/// `flutter_animate` owns and disposes its own controller for this effect.
class _GlowBurst extends StatelessWidget {
  final Color color;
  final int delayMs;
  final bool strong;

  const _GlowBurst({
    required this.color,
    required this.delayMs,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    final delay = Duration(milliseconds: delayMs);
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: strong ? 0.55 : 0.40),
                blurRadius: strong ? 16 : 12,
                spreadRadius: strong ? 2 : 1,
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: delay, duration: 110.ms, curve: Curves.easeOut)
            .then()
            .fadeOut(
              duration: strong ? 220.ms : 180.ms,
              curve: Curves.easeIn,
            ),
      ),
    );
  }
}
