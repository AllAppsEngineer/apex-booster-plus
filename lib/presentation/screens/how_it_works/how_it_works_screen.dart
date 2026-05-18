import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  static const _cards = [
    _CardData('BIB', 'Biblioteca', 'Organize seus jogos em um só lugar.'),
    _CardData(
      'GFX',
      'GFX Local',
      'Salve preferências visuais sem alterar jogos de terceiros.',
    ),
    _CardData('SCAN', 'Apex Scan', 'Leia rede, bateria, temperatura e foco.'),
    _CardData('GO', 'Launcher', 'Prepare a sessão e abra o jogo.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Como o Apex funciona',
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
              const Spacer(),
              ..._buildCards(context),
              const Spacer(),
              _buildCta(context),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCards(BuildContext context) {
    final widgets = <Widget>[];
    for (int i = 0; i < _cards.length; i++) {
      if (i > 0) widgets.add(const SizedBox(height: 12));
      widgets.add(
        _InfoCard(
          data: _cards[i],
          delay: Duration(milliseconds: 80 + i * 110),
        ),
      );
    }
    return widgets;
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
                'Permissões entram na próxima sessão.',
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
          'ENTENDI',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            fontSize: 15,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 560.ms, duration: 500.ms);
  }
}

class _CardData {
  final String badge;
  final String title;
  final String desc;

  const _CardData(this.badge, this.title, this.desc);
}

class _InfoCard extends StatelessWidget {
  final _CardData data;
  final Duration delay;

  const _InfoCard({required this.data, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.cyberBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.cyberBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppColors.cyberBlue.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Text(
              data.badge,
              style: const TextStyle(
                color: AppColors.cyberBlue,
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
