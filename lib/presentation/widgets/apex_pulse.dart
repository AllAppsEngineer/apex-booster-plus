import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';

/// Halo pulsante para estados ativos do Apex Visual System.
///
/// Quando [reducedMotion] é true, a animação é desligada independentemente de
/// [active]. Quando [active] é false, o halo fica estático sem animação.
/// O chamador é responsável por ler [lowDistractionNotifier] e repassar o valor.
class ApexPulse extends StatelessWidget {
  final Widget child;
  final Color color;
  final double size;
  final bool reducedMotion;
  final bool active;

  const ApexPulse({
    super.key,
    required this.child,
    this.color = AppColors.apexGreen,
    this.size = 48,
    this.reducedMotion = false,
    this.active = true,
  });

  @override
  Widget build(BuildContext context) {
    final shouldAnimate = active && !reducedMotion;

    final haloContainer = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: shouldAnimate ? 0.25 : 0.12),
      ),
    );

    final Widget halo = shouldAnimate
        ? haloContainer
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(
              begin: 0.4,
              duration: 750.ms,
              curve: Curves.easeInOut,
            )
        : haloContainer;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [halo, child],
      ),
    );
  }
}
