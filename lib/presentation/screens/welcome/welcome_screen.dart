// [TEMP] Placeholder — será implementado na próxima sessão
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'Welcome — [TEMP]',
          style: TextStyle(color: AppColors.textGray),
        ),
      ),
    );
  }
}
