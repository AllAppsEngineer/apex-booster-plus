import 'package:flutter/material.dart';
import 'package:apex_booster_plus/core/constants/app_colors.dart';

class BibliotecaTab extends StatelessWidget {
  const BibliotecaTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sports_esports_outlined,
                color: AppColors.apexGreen,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Biblioteca',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.white,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sua biblioteca de jogos será adicionada no próximo bloco.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textGray,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
