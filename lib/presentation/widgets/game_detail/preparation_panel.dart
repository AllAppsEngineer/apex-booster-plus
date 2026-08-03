import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:apex_booster_plus/core/accessibility/low_distraction_service.dart';
import 'package:apex_booster_plus/core/constants/app_colors.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/core/i18n/app_strings.dart';

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

const _kChipEntranceDurMs = 220;

class PreparationPanel extends StatelessWidget {
  const PreparationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
    final reducedMotion = lowDistractionNotifier.value;
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

    return Column(
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
  }
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
