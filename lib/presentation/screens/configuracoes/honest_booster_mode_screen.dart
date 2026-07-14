import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:apex_booster_plus/core/constants/app_colors.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/core/i18n/app_strings.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_background.dart';

class HonestBoosterModeScreen extends StatelessWidget {
  const HonestBoosterModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: languageNotifier,
      builder: (context, _) {
        final s = AppStrings(languageNotifier.value);
        return Scaffold(
          backgroundColor: const Color(0xFF050505),
          body: ApexBackground(
            child: SafeArea(
              child: Column(
                children: [
                  _Header(s: s, onBack: () => context.pop()),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _IntroBox(s: s),
                          const SizedBox(height: 8),
                          _FaqItem(
                            question: s.honestBoosterQ1,
                            answer: s.honestBoosterA1,
                          ),
                          _FaqItem(
                            question: s.honestBoosterQ2,
                            answer: s.honestBoosterA2,
                          ),
                          _FaqItem(
                            question: s.honestBoosterQ3,
                            answer: s.honestBoosterA3,
                          ),
                          _FaqItem(
                            question: s.honestBoosterQ4,
                            answer: s.honestBoosterA4,
                          ),
                          _FaqItem(
                            question: s.honestBoosterQ5,
                            answer: s.honestBoosterA5,
                          ),
                          _FaqItem(
                            question: s.honestBoosterQ6,
                            answer: s.honestBoosterA6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final AppStrings s;
  final VoidCallback onBack;

  const _Header({required this.s, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              s.honestBoosterScreenTitle,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: -0.06, end: 0, duration: 280.ms);
  }
}

// ─── Intro box ───────────────────────────────────────────────────────────────

class _IntroBox extends StatelessWidget {
  final AppStrings s;
  const _IntroBox({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cyberBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.cyberBlue.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_outlined,
            color: AppColors.cyberBlue.withValues(alpha: 0.8),
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              s.honestBoosterIntro,
              style: const TextStyle(
                color: AppColors.textGray,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 60.ms, duration: 400.ms);
  }
}

// ─── FAQ item ────────────────────────────────────────────────────────────────

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Color(0xFF1E1E1E), height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question,
                style: const TextStyle(
                  color: AppColors.apexGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                answer,
                style: const TextStyle(
                  color: AppColors.textGray,
                  fontSize: 13,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
