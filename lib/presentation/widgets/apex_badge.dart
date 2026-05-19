import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ApexBadge extends StatelessWidget {
  final String label;
  final Color color;

  const ApexBadge({
    super.key,
    required this.label,
    this.color = AppColors.apexGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withValues(alpha: 0.55),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}
