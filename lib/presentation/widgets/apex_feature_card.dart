import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import 'apex_badge.dart';

class ApexFeatureCard extends StatelessWidget {
  final String badge;
  final String title;
  final String subtitle;
  final Color accentColor;
  final Duration delay;

  const ApexFeatureCard({
    super.key,
    required this.badge,
    required this.title,
    required this.subtitle,
    this.accentColor = AppColors.apexGreen,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 3, color: accentColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 16, 14),
                  child: Row(
                    children: [
                      ApexBadge(label: badge, color: accentColor),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: delay, duration: 500.ms)
        .slideX(begin: -0.04, end: 0, delay: delay, duration: 400.ms);
  }
}
