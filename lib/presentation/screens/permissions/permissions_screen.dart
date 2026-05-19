import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/apex_background.dart';
import '../../widgets/apex_feature_card.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

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
                const SizedBox(height: 20),
                _buildHeader(context),
                const SizedBox(height: 8),
                _buildSubtitle(context),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildCards(),
                        const SizedBox(height: 20),
                        _buildTrustMessage(context),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildCta(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackNav(BuildContext context) {
    return GestureDetector(
      onTap: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/how-it-works');
          }
        },
      child: const Icon(
        Icons.arrow_back_ios,
        color: AppColors.apexGreen,
        size: 20,
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      'Permissões com transparência',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: AppColors.white,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 500.ms);
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(
      'O Apex Booster+ só pede o necessário para preparar melhor sua sessão.',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppColors.textGray,
        height: 1.5,
      ),
    ).animate().fadeIn(delay: 160.ms, duration: 500.ms);
  }

  Widget _buildCards() {
    return Column(
      children: [
        ApexFeatureCard(
          badge: 'NOTIF',
          title: 'Notificações',
          subtitle: 'Alertas opcionais de sessão e lembretes de preparação.',
          accentColor: AppColors.apexGreen,
          delay: 240.ms,
        ),
        const SizedBox(height: 12),
        ApexFeatureCard(
          badge: 'APPS',
          title: 'Apps instalados',
          subtitle:
              'Usado futuramente para detectar jogos no aparelho. Você também poderá adicionar jogos manualmente.',
          accentColor: AppColors.apexGreen,
          delay: 360.ms,
        ),
        const SizedBox(height: 12),
        ApexFeatureCard(
          badge: 'REDE',
          title: 'Rede',
          subtitle: 'Usado para leitura de conexão e diagnóstico do Apex Scan.',
          accentColor: AppColors.apexGreen,
          delay: 480.ms,
        ),
        const SizedBox(height: 12),
        ApexFeatureCard(
          badge: 'FOCO',
          title: 'Foco',
          subtitle:
              'O app pode orientar você a ativar modos de foco, mas não altera configurações sensíveis automaticamente.',
          accentColor: AppColors.apexGreen,
          delay: 600.ms,
        ),
      ],
    );
  }

  Widget _buildTrustMessage(BuildContext context) {
    return Text(
      'Sem anúncios. Sem tracking. Sem promessa falsa de boost real.',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppColors.apexGreen.withValues(alpha: 0.7),
        fontStyle: FontStyle.italic,
        letterSpacing: 0.3,
      ),
    ).animate().fadeIn(delay: 720.ms, duration: 500.ms);
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
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Home entra na próxima sessão.',
                  style: TextStyle(color: AppColors.white),
                ),
                backgroundColor: const Color(0xFF1C1C1C),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
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
            'CONTINUAR',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              fontSize: 15,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 840.ms, duration: 500.ms);
  }
}
