import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Shared decoration factory for gamer cards.
/// Neo-skeuomorphism medium + glassmorphism sutil.
/// Split into [elevated] (outer shadow) + [surface] (inner gradient/border)
/// so [ClipRRect] can clip content without clipping the outer shadow.
abstract final class ApexCardDecoration {
  /// Outer wrapper decoration — depth shadows only, transparent fill.
  /// Use as decoration on a Container that wraps a [ClipRRect].
  static BoxDecoration elevated({Color? accentGlow, double radius = 8}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        // Primary depth — card rises sharply from surface
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.65),
          blurRadius: 24,
          offset: const Offset(0, 10),
          spreadRadius: -4,
        ),
        // Secondary ambient halo — widens perceived depth
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.28),
          blurRadius: 44,
          offset: const Offset(0, 5),
          spreadRadius: -12,
        ),
        if (accentGlow != null)
          BoxShadow(
            color: accentGlow.withValues(alpha: 0.22),
            blurRadius: 28,
            spreadRadius: -6,
            offset: const Offset(0, 3),
          ),
      ],
    );
  }

  /// Inner surface decoration — directional gradient + uniform border.
  /// The top-left to bottom-right gradient carries the depth illusion.
  /// Apply inside [ClipRRect] so rounded corners are properly clipped.
  static BoxDecoration surface({double radius = 8}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.white.withValues(alpha: 0.14),
          AppColors.white.withValues(alpha: 0.055),
          AppColors.white.withValues(alpha: 0.018),
        ],
        stops: const [0.0, 0.42, 1.0],
      ),
      border: Border.all(
        color: AppColors.white.withValues(alpha: 0.15),
        width: 1,
      ),
    );
  }
}
