import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:apex_booster_plus/core/constants/app_colors.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_background.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_badge.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_feature_card.dart';

class HistoricoTab extends StatelessWidget {
  const HistoricoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ApexBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HistoricoHeader(),
              const SizedBox(height: 28),
              const _HistoricoMainCard(),
              const SizedBox(height: 16),
              ApexFeatureCard(
                badge: 'REC',
                title: 'Sessões recentes',
                subtitle: 'As últimas preparações serão exibidas aqui futuramente.',
                accentColor: AppColors.cyberBlue,
                delay: 100.ms,
              ),
              const SizedBox(height: 12),
              ApexFeatureCard(
                badge: 'EVOL',
                title: 'Resumo de evolução',
                subtitle: 'Tendências e progresso serão organizados depois.',
                accentColor: AppColors.energyOrange,
                delay: 200.ms,
              ),
              const SizedBox(height: 32),
              const _HistoricoCTA(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoricoHeader extends StatelessWidget {
  const _HistoricoHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Histórico',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .slideY(begin: -0.08, end: 0, duration: 400.ms),
        const SizedBox(height: 8),
        Text(
          'Acompanhe suas sessões quando o histórico estiver disponível.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textGray,
              ),
        ).animate().fadeIn(delay: 100.ms, duration: 500.ms),
      ],
    );
  }
}

class _HistoricoMainCard extends StatelessWidget {
  const _HistoricoMainCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cyberBlue.withValues(alpha: 0.12),
            AppColors.white.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cyberBlue.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ApexBadge(label: 'HIST', color: AppColors.cyberBlue),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.cyberBlue.withValues(alpha: 0.45),
                size: 14,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Histórico em preparação',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Suas sessões preparadas aparecerão aqui nas próximas etapas.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textGray,
                  fontSize: 13,
                ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.04, end: 0, duration: 400.ms);
  }
}

class _HistoricoCTA extends StatelessWidget {
  const _HistoricoCTA();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Histórico será ativado em etapa futura.'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyberBlue,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: const Text(
          'VER HISTÓRICO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.5,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 500.ms);
  }
}
