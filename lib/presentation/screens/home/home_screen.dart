import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/apex_background.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ApexBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Text(
                  'INÍCIO',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.apexGreen,
                    letterSpacing: 3.0,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 12),
                Text(
                  'Início',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 500.ms),
                const SizedBox(height: 16),
                Text(
                  'O núcleo do app está sendo preparado.\nAs funcionalidades chegam no próximo bloco.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textGray,
                    height: 1.6,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
