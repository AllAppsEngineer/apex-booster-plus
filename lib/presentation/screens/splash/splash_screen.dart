import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) context.go('/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'APEX BOOSTER+',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: AppColors.apexGreen,
                shadows: [
                  Shadow(
                    color: AppColors.apexGreen.withValues(alpha: 0.6),
                    blurRadius: 24,
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(begin: const Offset(0.88, 0.88), duration: 800.ms),
            const SizedBox(height: 12),
            Text(
              'Gaming Prep · Scan · Launcher',
              style: Theme.of(context).textTheme.bodyMedium,
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
