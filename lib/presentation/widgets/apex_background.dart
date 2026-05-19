import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ApexBackground extends StatelessWidget {
  final Widget child;

  const ApexBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.3),
              radius: 1.2,
              colors: [
                Color(0xFF0A1A0F),
                Color(0xFF070707),
                Color(0xFF050505),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        CustomPaint(painter: _ParticlePainter()),
        child,
      ],
    );
  }
}

class _ParticlePainter extends CustomPainter {
  const _ParticlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.white.withValues(alpha: 0.05);
    final random = math.Random(42);
    for (var i = 0; i < 30; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        1.5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
