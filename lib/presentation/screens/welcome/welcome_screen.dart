import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/apex_background.dart';
import '../../widgets/apex_feature_card.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
        const SizedBox(height: 10),
        Text(
          'Prepare. Analise. Jogue.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            letterSpacing: 1.2,
          ),
        ).animate().fadeIn(delay: 250.ms, duration: 600.ms),
      ],
    );
  }

  Widget _buildFeatures() {
    return Column(
      children: [
        ApexFeatureCard(
          badge: 'BIB',
          title: 'Organize seus jogos',
          subtitle: 'Sua biblioteca pessoal de jogos.',
          accentColor: AppColors.apexGreen,
          delay: 440.ms,
        ),
        const SizedBox(height: 12),
        ApexFeatureCard(
          badge: 'SCAN',
          title: 'Analise antes de jogar',
          subtitle: 'Diagnóstico rápido da sessão.',
          accentColor: AppColors.cyberBlue,
          delay: 560.ms,
        ),
        const SizedBox(height: 12),
        ApexFeatureCard(
          badge: 'GO',
          title: 'Prepare e abra com estilo',
          subtitle: 'Lançamento com preparação completa.',
          accentColor: AppColors.apexGreen,
          delay: 680.ms,
        ),
      ],
    );
  }

  Widget _buildCta(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: AppColors.apexGreen.withValues(alpha: 0.28),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => context.push('/how-it-works'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.apexGreen,
            foregroundColor: AppColors.background,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'COMEÇAR',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  fontSize: 15,
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.arrow_forward_ios, size: 13),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 800.ms, duration: 500.ms);
  }
}
