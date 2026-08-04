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
// badge celebration) may be adjusted in this section.
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
//
// PREP-PANEL-ACTIVATION-U3: the panel now starts `idle` — only the title and
// a pulsing "CLIQUE PARA PREPARAR" button are built, no chips/badges/scanner
// exist yet, so nothing can animate before the user taps. A tap moves to
// `preparing`, mounting the pre-existing chip/badge/scanner subtree exactly
// as before (same delays, same cadence) inside an `AnimatedSize`; a `Timer`
// scheduled for the same `sequenceCompleteMs` this subtree already uses for
// the scanner's own fadeIn flips the state to `ready`, which is now also a
// fourth input (alongside viewport/lifecycle/route) gating
// `_scannerController.repeat()` — so the controller never turns even once
// before the existing entrance sequence has actually finished. `preparing`
// and `ready` render the identical widget subtree (same branch in `build()`)
// so the chip/badge entrance never replays across that transition, matching
// the no-replay guarantee U2C-A/B already provide for pause/resume and
// route push/pop.
//
// PREP-PANEL-ACTIVATION-U3-FIX1 (physical-validation fix): three corrections
// on top of U3, no new phase. (1) All seven indicators (5 chips + 2 badges)
// now share one uniform ~410ms stagger via `_indicatorDelayMs`, identical in
// normal and Baixa Distração motion, instead of the old 70ms chip stagger
// plus a much-later, cyclic-highlight-gated badge entrance — see
// `_sequenceCompleteMs`. The old post-`ready` cyclic FPS/RAM/GPU/Ping
// highlight pass is removed entirely; each indicator instead plays its own
// `_GlowBurst` confirmation on arrival (both motion modes), and the scanner
// is the only continuous animation once `ready`. (2) Ping/Otimização/both
// badges each get an exclusive neon color (`AppColors.neonCyan` /
// `neonViolet` / `neonLime` / `neonMagenta`) instead of reusing FPS/RAM's
// green/blue. (3) The scanner now sweeps right, pauses, sweeps left, pauses,
// repeats — see `_ScannerPainter` and `_syncScannerMotion`'s doubled period
// — instead of a one-way sweep that snapped back to the start.

/// Test hook: the sole tap target that moves the panel from `idle` to
/// `preparing`. Exposed (not private) so widget tests can locate and tap it
/// without relying on text/type finders that also match unrelated widgets.
const preparationPanelPrepareButtonKey = Key('preparationPanelPrepareButton');

enum _PanelState { idle, preparing, ready }

const _kChipEntranceDurMs = 260;
// PREP-PANEL-ACTIVATION-U3-FIX1 — per-chip "checking" window before the OK
// confirmation glow; normal motion only (Baixa Distração skips straight to
// the chip's own confirmation burst, see _ModuleChip).
const _kCheckDurMs = 220;

// Scanner cadence (per one-way leg) — values are fixed midpoints of the
// ranges requested in PREP-PANEL-VISUAL-U2B (kept as named constants, not
// re-derived per frame). PREP-PANEL-ACTIVATION-U3-FIX1: the controller's
// own repeat() period is now double this (see _syncScannerMotion) to cover
// a full sweep-right + pause + sweep-left + pause round trip, but each
// individual leg still takes this long — "aproximadamente a mesma
// velocidade atual em cada direção".
const _kScannerNormalSweepMs = 1900; // range 1600-2200
const _kScannerNormalPauseMs = 1100; // range 800-1500
const _kScannerReducedSweepMs = 2500; // range 2200-2800
const _kScannerReducedPauseMs = 2300; // range 1800-2800
// Only "Modo normal" specifies an "entrada completa" window in the ticket;
// Baixa Distração skips that extra flourish and fades the layer in quickly.
const _kScannerNormalEntranceRampMs = 2100; // range 1800-2400
const _kScannerReducedEntranceRampMs = 400;

// PREP-PANEL-ACTIVATION-U3-FIX1 — uniform appearance cadence shared by all
// seven indicators (5 chips + 2 badges): indicator #i (0-indexed, in the
// fixed FPS/RAM/GPU/Ping/Otimização/Boost aplicado/Performance melhorada
// order) becomes visible at _kIndicatorBaseDelayMs + i*_kIndicatorStaggerMs
// — identically in normal and Baixa Distração motion, so the stagger itself
// is never compressed to the point indicators read as simultaneous in
// either mode. The stagger sits in the requested ~400-420ms band.
const _kIndicatorCount = 7;
const _kIndicatorBaseDelayMs = 300;
const _kIndicatorStaggerMs = 410;

// Tail after the 7th indicator's own delay before its confirmation
// choreography (fade/slide/scale, plus shimmer/pop in normal motion) has
// visually settled. This is what gates both the `preparing` -> `ready`
// transition and the scanner's own fade-in (see _sequenceCompleteMs) — the
// scanner must never start before indicator #7 has fully appeared. A
// trailing GlowBurst afterglow may still be fading out past this point;
// that is decorative and does not count as "still arriving".
const _kIndicatorTailNormalMs = 570;
const _kIndicatorTailReducedMs = 300;

int _indicatorDelayMs(int i) =>
    _kIndicatorBaseDelayMs + i * _kIndicatorStaggerMs;

// Full up+down pulse period for the idle "CLIQUE PARA PREPARAR" button.
const _kButtonPulseNormalMs = 1400;
const _kButtonPulseReducedMs = 2200;
const _kButtonPulseNormalScale = 1.05;
const _kButtonPulseReducedScale = 1.02;

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

  // PREP-PANEL-ACTIVATION-U3 — starts `idle` for every new instance (e.g. a
  // fresh Game Detail push); survives route push/pop, app background/resume
  // and viewport scroll because those never recreate this State.
  _PanelState _panelState = _PanelState.idle;
  Timer? _readyTimer;

  bool get _shouldAnimateScanner =>
      _panelState == _PanelState.ready &&
      _isVisible &&
      _lifecycleState == AppLifecycleState.resumed &&
      !_isRouteCovered;

  // PREP-PANEL-ACTIVATION-U3-FIX1 — gates the `ready` transition on the 7th
  // (last) indicator's own instant plus however long its confirmation
  // choreography takes to settle, so the scanner (see `_buildActiveContent`,
  // which reuses this exact same value for its own fadeIn) never starts
  // before "a animação de entrada do sétimo indicador estiver totalmente
  // concluída".
  int _sequenceCompleteMs(bool reducedMotion) {
    final lastDelayMs = _indicatorDelayMs(_kIndicatorCount - 1);
    final tailMs =
        reducedMotion ? _kIndicatorTailReducedMs : _kIndicatorTailNormalMs;
    return lastDelayMs + tailMs;
  }

  // Impossible to invoke twice: the button (the only tap target) is removed
  // from the tree the instant `_panelState` leaves `idle`, but this guard
  // stays as a defensive backstop against any re-entrant call.
  void _onPrepareTap() {
    if (_panelState != _PanelState.idle) return;
    final reducedMotion = lowDistractionNotifier.value;
    setState(() => _panelState = _PanelState.preparing);
    _readyTimer = Timer(
      Duration(milliseconds: _sequenceCompleteMs(reducedMotion)),
      () {
        if (!mounted) return;
        setState(() => _panelState = _PanelState.ready);
      },
    );
  }

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
    _readyTimer?.cancel();
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
      // PREP-PANEL-ACTIVATION-U3-FIX1 — one full controller period now
      // covers a complete round trip (sweep right, pause, sweep left,
      // pause), so `repeat()`'s wrap from 1 back to 0 lands exactly back on
      // the "paused at the left edge" state instead of snapping the beam
      // back to the start mid-sweep. See _ScannerPainter for the segment
      // math driven by this doubled period.
      _scannerPeriod = Duration(milliseconds: 2 * (sweepMs + pauseMs));
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
    // PREP-PANEL-ACTIVATION-U3 — while `idle`, `_scannerPeriod` must never
    // be set, so `_applyScannerRunningState()` (called from viewport/
    // lifecycle/route callbacks too) keeps hitting its existing
    // `period == null` early return and can never call `.repeat()`.
    if (_panelState != _PanelState.idle) {
      _syncScannerMotion(reducedMotion);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Requirement: the section title stays visible in `idle` — it is no
        // longer part of the chip/badge entrance's shared fadeIn below.
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
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          // Chip/badge confirmation glows (`_GlowBurst`) intentionally paint
          // outside their own layout bounds via `Clip.none` ancestors; a
          // clipping `AnimatedSize` would cut that bleed during the resize.
          clipBehavior: Clip.none,
          child: _panelState == _PanelState.idle
              ? _PrepareButton(
                  label: s.detailPreparePanelCta,
                  reducedMotion: reducedMotion,
                  onTap: _onPrepareTap,
                )
              : _buildActiveContent(reducedMotion),
        ),
      ],
    );
  }

  // PREP-PANEL-ACTIVATION-U3 — identical widget subtree for `preparing` and
  // `ready`; only `_shouldAnimateScanner` (read inside `_scannerController`'s
  // own `AnimatedBuilder`) changes between the two, so this never remounts
  // and the chip/badge entrance never replays.
  //
  // PREP-PANEL-ACTIVATION-U3-FIX1 — all seven indicators (five chips, two
  // badges) now share one uniform per-item stagger via `_indicatorDelayMs`
  // (indices 0-6, in this exact FPS/RAM/GPU/Ping/Otimização/Boost aplicado/
  // Performance melhorada order); there is no separate cyclic highlight
  // pass after `ready` any more — once ready, the ambient scanner below is
  // the only continuous animation.
  Widget _buildActiveContent(bool reducedMotion) {
    final s = AppStrings(languageNotifier.value);
    final modules = [
      (label: s.detailModuleFps,          color: AppColors.apexGreen,    icon: Icons.speed_rounded),
      (label: s.detailModuleRam,          color: AppColors.cyberBlue,    icon: Icons.memory_rounded),
      (label: s.detailModuleGpu,          color: AppColors.energyOrange, icon: Icons.videogame_asset_rounded),
      (label: s.detailModulePing,         color: AppColors.neonCyan,     icon: Icons.wifi_rounded),
      (label: s.detailModuleOptimization, color: AppColors.neonViolet,   icon: Icons.tune_rounded),
    ];

    // The ambient scanner layer only fades in once indicator #7's own
    // entrance has actually finished settling — reuses the exact same
    // formula that schedules the `preparing` -> `ready` Timer.
    final sequenceCompleteMs = _sequenceCompleteMs(reducedMotion);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (int i = 0; i < modules.length; i++)
              _ModuleChip(
                label: modules[i].label,
                icon: modules[i].icon,
                color: modules[i].color,
                entranceDelayMs: _indicatorDelayMs(i),
                reducedMotion: reducedMotion,
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
              color: AppColors.neonLime,
              delayMs: _indicatorDelayMs(5),
              reducedMotion: reducedMotion,
            ),
            _ConfirmBadge(
              label: s.detailModulePerfImproved,
              color: AppColors.neonMagenta,
              delayMs: _indicatorDelayMs(6),
              reducedMotion: reducedMotion,
            ),
          ],
        ),
      ],
    );

    // Layer order: fundo -> glow/respiração -> scanner -> content. All
    // three decorative sub-layers are painted together by _ScannerPainter
    // inside a single Positioned.fill so the Stack's size is driven only by
    // `content` (no size change from the scanner).
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
                      sweepMs: sweepMs.toDouble(),
                      pauseMs: pauseMs.toDouble(),
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

/// PREP-PANEL-ACTIVATION-U3 — the sole `idle`-state tap target. Pulses
/// continuously to invite the tap (that pulse is intentional motion, unlike
/// the chip/badge/scanner sequence it gates); reduces amplitude and slows
/// down in Baixa Distração, and renders fully static when the platform's
/// `disableAnimations` accessibility flag is set.
class _PrepareButton extends StatelessWidget {
  final String label;
  final bool reducedMotion;
  final VoidCallback onTap;

  const _PrepareButton({
    required this.label,
    required this.reducedMotion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    // The key lives on this `Material` (the widget passed into `.animate()`
    // below), not on `_PrepareButton` itself: a key placed on the
    // StatelessWidget that merely returns the animated chain resolves, via
    // `Element.renderObject`, to a render object whose geometry does not
    // reflect the effect's live `Transform` — confirmed empirically before
    // relying on `find.byKey(...)` + `getRect` in tests.
    final buttonCore = Material(
      key: preparationPanelPrepareButtonKey,
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF0D0608),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.apexNeonRed.withValues(alpha: 0.55),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.apexNeonRed.withValues(alpha: 0.35),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  color: AppColors.apexNeonRed,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    softWrap: true,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.apexNeonRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (disableAnimations) return buttonCore;

    final periodMs =
        reducedMotion ? _kButtonPulseReducedMs : _kButtonPulseNormalMs;
    final scaleMax =
        reducedMotion ? _kButtonPulseReducedScale : _kButtonPulseNormalScale;

    return buttonCore
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: Offset(scaleMax, scaleMax),
          duration: Duration(milliseconds: periodMs ~/ 2),
          curve: Curves.easeInOut,
        );
  }
}

/// Purely decorative ambient background painted behind the chips/badges:
/// a faint breathing glow tied to the full cycle, plus a narrow neon core
/// with a diffuse trail that sweeps horizontally. Confined to whatever
/// [Size] it is given by the enclosing ClipRRect — never draws or reports
/// geometry outside it.
///
/// PREP-PANEL-ACTIVATION-U3-FIX1 — the beam now makes a full round trip
/// per controller period: sweep right, short pause at the right edge,
/// sweep back left, short pause at the left edge, then the controller
/// wraps 1 -> 0 (see `_syncScannerMotion`, which sizes the period as
/// `2 * (sweepMs + pauseMs)`). That wrap lands exactly back on the "paused
/// at the left edge, beam hidden" state the cycle started in, so the reset
/// is never visible as a jump/teleport — no second controller, no reverse
/// mode, just this segment math driving the one existing controller.
class _ScannerPainter extends CustomPainter {
  final double progress;
  final double sweepMs;
  final double pauseMs;
  final bool reducedMotion;

  const _ScannerPainter({
    required this.progress,
    required this.sweepMs,
    required this.pauseMs,
    required this.reducedMotion,
  });

  ({bool visible, bool movingRight, double localT}) _segment() {
    final t = progress * (2 * (sweepMs + pauseMs));
    if (t < sweepMs) {
      return (visible: true, movingRight: true, localT: t / sweepMs);
    }
    if (t < sweepMs + pauseMs) {
      return (visible: false, movingRight: true, localT: 1.0);
    }
    if (t < 2 * sweepMs + pauseMs) {
      return (
        visible: true,
        movingRight: false,
        localT: (t - sweepMs - pauseMs) / sweepMs,
      );
    }
    return (visible: false, movingRight: false, localT: 1.0);
  }

  /// Null while paused at either edge (beam hidden); otherwise 0.0
  /// (leftmost) to 1.0 (rightmost) — the fraction of the sweep travelled,
  /// independent of pixel size. Public-named (despite the private class)
  /// so widget tests can read it via the same dynamic-dispatch pattern
  /// already used for `progress`, without duplicating this file's own
  /// timing math.
  double? get beamXFraction {
    final s = _segment();
    if (!s.visible) return null;
    final eased = Curves.easeInOut.transform(s.localT);
    return s.movingRight ? eased : 1 - eased;
  }

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

    // Glow/respiração — roughly one breath per one-way leg (two per full
    // round-trip controller period), matching the pre-FIX1 cadence even
    // though the controller's own period is now double-length.
    final breath = 0.5 + 0.5 * math.sin(2 * math.pi * progress * 2);
    final breathAlpha = (0.03 + 0.05 * breath) * intensity;
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = AppColors.apexGreen.withValues(alpha: breathAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    final segment = _segment();
    if (segment.visible) {
      final localT = segment.localT;
      const edge = 0.08;
      final edgeAlpha = localT < edge
          ? localT / edge
          : (localT > 1 - edge ? (1 - localT) / edge : 1.0);
      final eased = Curves.easeInOut.transform(localT);
      const margin = 26.0;
      final xFrac = segment.movingRight ? eased : 1 - eased;
      final x = -margin + xFrac * (size.width + margin * 2);

      const trailWidth = 46.0;
      final Rect trailRect;
      final List<Color> trailColors;
      if (segment.movingRight) {
        trailRect = Rect.fromLTWH(x - trailWidth, 0, trailWidth, size.height);
        trailColors = [
          AppColors.cyberBlue.withValues(alpha: 0),
          AppColors.cyberBlue.withValues(alpha: 0.22 * edgeAlpha * intensity),
        ];
      } else {
        trailRect = Rect.fromLTWH(x, 0, trailWidth, size.height);
        trailColors = [
          AppColors.cyberBlue.withValues(alpha: 0.22 * edgeAlpha * intensity),
          AppColors.cyberBlue.withValues(alpha: 0),
        ];
      }
      canvas.drawRect(
        trailRect,
        Paint()
          ..shader =
              LinearGradient(colors: trailColors).createShader(trailRect),
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
      oldDelegate.sweepMs != sweepMs ||
      oldDelegate.pauseMs != pauseMs ||
      oldDelegate.reducedMotion != reducedMotion;
}

class _ModuleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int entranceDelayMs;
  final bool reducedMotion;

  const _ModuleChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.entranceDelayMs,
    required this.reducedMotion,
  });

  @override
  Widget build(BuildContext context) {
    final entranceDelay = Duration(milliseconds: entranceDelayMs);
    const entranceDur = Duration(milliseconds: _kChipEntranceDurMs);
    // PREP-PANEL-ACTIVATION-U3-FIX1 — the checking window (scrim + shimmer +
    // confirmation pop) only plays in normal motion; Baixa Distração still
    // gets its own confirmation via the always-on _GlowBurst below, just
    // without this extra flourish.
    final checkDur =
        reducedMotion ? Duration.zero : const Duration(milliseconds: _kCheckDurMs);
    final checkEndDelay = entranceDelay + entranceDur + checkDur;
    // Baixa Distração — reduce (not remove) the entrance scale amplitude.
    final scaleBegin = reducedMotion ? 0.94 : 0.88;

    Widget iconWidget = Icon(icon, color: color, size: 13);
    if (!reducedMotion) {
      // Soft icon pulse confined to the checking window (single bounded
      // up/down cycle; never loops indefinitely).
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

    // Entrance — starts fully invisible, fades in with a light scale pop.
    var animated = chipBody
        .animate()
        .fadeIn(delay: entranceDelay, duration: entranceDur)
        .scale(
          begin: Offset(scaleBegin, scaleBegin),
          end: const Offset(1.0, 1.0),
          delay: entranceDelay,
          duration: entranceDur,
          curve: Curves.easeOutBack,
        );

    if (!reducedMotion) {
      // Sweep/shimmer crossing the chip during the checking window, then a
      // short confirmation pop once checking completes.
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
        // PREP-PANEL-ACTIVATION-U3-FIX1 — every indicator plays its own
        // confirmation glow on arrival, in both motion modes (dimmer and
        // shorter in Baixa Distração via `_GlowBurst.reducedMotion`); the
        // cross-chip cyclic highlight pass that used to run after `ready`
        // is gone — the scanner is now the only continuous animation once
        // ready.
        _GlowBurst(
          color: color,
          delayMs: checkEndDelay.inMilliseconds,
          reducedMotion: reducedMotion,
        ),
        animated,
        // Visual-only "checking" state: a dark scrim that dims the chip
        // (same label, same text, never altered) and dissolves right as the
        // confirmation pop/glow fires. Normal motion only.
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
  final Color color;
  final int delayMs;
  final bool reducedMotion;

  const _ConfirmBadge({
    required this.label,
    required this.color,
    required this.delayMs,
    required this.reducedMotion,
  });

  @override
  Widget build(BuildContext context) {
    final delay = Duration(milliseconds: delayMs);
    // Baixa Distração — reduce (not remove) the slide/scale amplitude.
    final slideBegin = reducedMotion ? 0.05 : 0.10;
    final scaleBegin = reducedMotion ? 0.92 : 0.82;

    final badgeBody = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.40),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: color,
            size: 13,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              softWrap: true,
              maxLines: 2,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );

    // Scale-in + fade/slide (always) plus, at normal motion, a shimmer
    // sweep and a short "activation complete" bounce.
    var animated = badgeBody
        .animate()
        .fadeIn(delay: delay, duration: 300.ms)
        .slideY(
          begin: slideBegin,
          end: 0,
          delay: delay,
          duration: 280.ms,
          curve: Curves.easeOut,
        )
        .scale(
          begin: Offset(scaleBegin, scaleBegin),
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
            color: color.withValues(alpha: 0.6),
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

    // PREP-PANEL-ACTIVATION-U3-FIX1 — own confirmation glow in both motion
    // modes; only its trigger instant differs (right after the shimmer in
    // normal motion, right after the basic entrance settles in Baixa
    // Distração, since there is no shimmer there).
    final glowDelayMs =
        reducedMotion ? delayMs + 300 : delayMs + shimmerDur;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _GlowBurst(
          color: color,
          delayMs: glowDelayMs,
          strong: true,
          reducedMotion: reducedMotion,
        ),
        animated,
      ],
    );
  }
}

/// Short, bounded glow flash used for each indicator's own confirmation
/// moment on arrival. Purely decorative (`IgnorePointer`) and
/// self-contained: no manual `AnimationController`, timer, or listener —
/// `flutter_animate` owns and disposes its own controller for this effect.
/// PREP-PANEL-ACTIVATION-U3-FIX1 — dimmer and shorter in Baixa Distração
/// (reduced, never removed).
class _GlowBurst extends StatelessWidget {
  final Color color;
  final int delayMs;
  final bool strong;
  final bool reducedMotion;

  const _GlowBurst({
    required this.color,
    required this.delayMs,
    this.strong = false,
    this.reducedMotion = false,
  });

  @override
  Widget build(BuildContext context) {
    final delay = Duration(milliseconds: delayMs);
    final baseAlpha = strong ? 0.55 : 0.40;
    final alpha = reducedMotion ? baseAlpha * 0.55 : baseAlpha;
    final blurRadius = (strong ? 16.0 : 12.0) * (reducedMotion ? 0.7 : 1.0);
    final fadeOutMs = reducedMotion
        ? (strong ? 150 : 120)
        : (strong ? 220 : 180);
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: alpha),
                blurRadius: blurRadius,
                spreadRadius: strong ? 2 : 1,
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: delay, duration: 110.ms, curve: Curves.easeOut)
            .then()
            .fadeOut(
              duration: fadeOutMs.ms,
              curve: Curves.easeIn,
            ),
      ),
    );
  }
}
