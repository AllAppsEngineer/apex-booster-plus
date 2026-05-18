import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  static const _cards = [
    _CardData('NOTIF', 'Notificações', 'Alertas opcionais de sessão e lembretes de preparação.'),
    _CardData(
      'APPS',
      'Apps instalados',
      'Usado futuramente para detectar jogos no aparelho. Você também poderá adicionar jogos manualmente.',
    ),
    _CardData('REDE', 'Rede', 'Usado para leitura de conexão e diagnóstico do Apex Scan.'),
    _CardData(
      'FOCO',
      'Foco',
      'O app pode orientar você a ativar modos de foco, mas não altera configurações sensíveis automaticamente.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Permissões com transparência',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            fontSize: 17,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.apexGreen),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildSubtitle(context),
                      const SizedBox(height: 24),
                      ..._buildCards(),
                      const SizedBox(height: 24),
                      _buildTrustMessage(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              _buildCta(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(
      'O Apex Booster+ só pede o necessário para preparar melhor sua sessão.',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppColors.textGray,
        height: 1.5,
      ),
    ).animate().fadeIn(delay: 80.ms, duration: 500.ms);
  }

  List<Widget> _buildCards() {
    final widgets = <Widget>[];
    for (int i = 0; i < _cards.length; i++) {
      if (i > 0) widgets.add(const SizedBox(height: 12));
      widgets.add(
        _PermissionCard(
          data: _cards[i],
          delay: Duration(milliseconds: 160 + i * 110),
        ),
      );
    }
    return widgets;
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
    ).animate().fadeIn(delay: 620.ms, duration: 500.ms);
  }

  Widget _buildCta(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
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
    ).animate().fadeIn(delay: 720.ms, duration: 500.ms);
  }
}

class _CardData {
  final String badge;
  final String title;
  final String desc;

  const _CardData(this.badge, this.title, this.desc);
}

class _PermissionCard extends StatelessWidget {
  final _CardData data;
  final Duration delay;

  const _PermissionCard({required this.data, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.apexGreen.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.apexGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppColors.apexGreen.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Text(
              data.badge,
              style: const TextStyle(
                color: AppColors.apexGreen,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.desc,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: delay, duration: 500.ms)
        .slideY(begin: 0.04, end: 0, delay: delay, duration: 420.ms);
  }
}
