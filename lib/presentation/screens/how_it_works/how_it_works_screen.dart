import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/apex_background.dart';
import '../../widgets/apex_feature_card.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

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
                const SizedBox(height: 8),
                _buildBackNav(context),
                const Spacer(flex: 2),
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildCards(),
                const Spacer(flex: 2),
                _buildCta(context),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackNav(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: const Icon(
        Icons.arrow_back_ios,
        color: AppColors.apexGreen,
        size: 20,
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      'Como o Apex funciona',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: AppColors.white,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    ).animate().fadeIn(delay: 120.ms, duration: 500.ms);
  }

  Widget _buildCards() {
    return Column(
      children: [
        ApexFeatureCard(
          badge: 'BIB',
          title: 'Biblioteca',
          subtitle: 'Organize seus jogos em um só lugar.',
          accentColor: AppColors.apexGreen,
          delay: 200.ms,
        ),
        const SizedBox(height: 12),
        ApexFeatureCard(
          badge: 'GFX',
          title: 'GFX Local',
          subtitle: 'Salve preferências visuais sem alterar jogos de terceiros.',
          accentColor: AppColors.cyberBlue,
          delay: 320.ms,
        ),
        const SizedBox(height: 12),
        ApexFeatureCard(
          badge: 'SCAN',
          title: 'Apex Scan',
          subtitle: 'Leia rede, bateria, temperatura e foco.',
          accentColor: AppColors.cyberBlue,
          delay: 440.ms,
        ),
        const SizedBox(height: 12),
        ApexFeatureCard(
          badge: 'GO',
          title: 'Launcher',
          subtitle: 'Prepare a sessão e abra o jogo.',
          accentColor: AppColors.apexGreen,
          delay: 560.ms,
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
          onPressed: () => context.go('/permissions'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.apexGreen,
            foregroundColor: AppColors.background,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: const Text(
            'ENTENDI',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              fontSize: 15,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 680.ms, duration: 500.ms);
  }
}
