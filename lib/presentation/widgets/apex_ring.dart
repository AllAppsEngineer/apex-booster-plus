import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Anel de progresso animado do Apex Visual System.
///
/// Parâmetro [reducedMotion] encurta a animação para 100 ms (padrão: 300 ms).
/// O chamador é responsável por ler [lowDistractionNotifier] e repassar o valor.
class ApexRing extends StatelessWidget {
  final double progress;
  final double size;
  final Color color;
  final bool reducedMotion;
  final Widget? child;

  const ApexRing({
    super.key,
    required this.progress,
    this.size = 64,
    this.color = AppColors.apexGreen,
    this.reducedMotion = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: clamped),
      duration: reducedMotion
          ? const Duration(milliseconds: 100)
          : const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (_, value, __) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _ApexRingPainter(progress: value, color: color),
          child: child != null ? Center(child: child) : null,
        ),
      ),
    );
  }
}

class _ApexRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _ApexRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.white.withValues(alpha: 0.07)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    if (progress <= 0) return;

    final sweep = progress * 2 * math.pi;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..color = color.withValues(alpha: 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ApexRingPainter old) =>
      old.progress != progress || old.color != color;
}
