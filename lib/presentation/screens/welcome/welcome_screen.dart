import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              _buildHero(context),
              const Spacer(flex: 2),
              _buildFeatures(),
              const Spacer(flex: 1),
              _buildCta(context),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'APEX BOOSTER+',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: AppColors.apexGreen,
            shadows: [
              Shadow(
                color: AppColors.apexGreen.withValues(alpha: 0.5),
                blurRadius: 20,
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 700.ms)
            .scale(begin: const Offset(0.92, 0.92), duration: 700.ms),
        const SizedBox(height: 8),
        Text(
          'Gaming Prep, Scan & Launcher.',
          style: Theme.of(context).textTheme.bodyMedium,
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
        const SizedBox(height: 6),
        Text(
          'Prepare sua sessão antes de entrar na partida.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.white.withValues(alpha: 0.65),
            fontSize: 14,
            height: 1.4,
          ),
        ).animate().fadeIn(delay: 320.ms, duration: 600.ms),
      ],
    );
  }

  Widget _buildFeatures() {
    return Column(
      children: [
        _FeatureCard(
          badge: 'BIB',
          label: 'Organize seus jogos',
          delay: 440.ms,
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          badge: 'SCAN',
          label: 'Faça um scan antes de jogar',
          delay: 560.ms,
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          badge: 'GO',
          label: 'Prepare e abra com estilo',
          delay: 680.ms,
        ),
      ],
    );
  }

  Widget _buildCta(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => context.push('/how-it-works'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.apexGreen,
          foregroundColor: AppColors.background,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: const Text(
          'COMEÇAR',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            fontSize: 15,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 800.ms, duration: 500.ms);
  }
}

class _FeatureCard extends StatelessWidget {
  final String badge;
  final String label;
  final Duration delay;

  const _FeatureCard({
    required this.badge,
    required this.label,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.apexGreen.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.apexGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppColors.apexGreen.withValues(alpha: 0.55),
                width: 1,
              ),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: AppColors.apexGreen,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: delay, duration: 500.ms)
        .slideX(begin: -0.04, end: 0, delay: delay, duration: 400.ms);
  }
}
