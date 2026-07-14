import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_language.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/onboarding/onboarding_service.dart';
import '../../widgets/apex_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ring1;
  late final AnimationController _ring2;

  @override
  void initState() {
    super.initState();
    _ring1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _ring2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
      value: 1.0,
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _ring2.repeat();
    });
    Future.delayed(const Duration(milliseconds: 1200), () async {
      debugPrint('[PERF-STARTUP] splash navigate');
      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      final done = OnboardingService(prefs).isDone();
      if (mounted) context.go(done ? '/home' : '/welcome');
    });
  }

  @override
  void dispose() {
    _ring1.dispose();
    _ring2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ApexBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTitleArea(context),
                const SizedBox(height: 24),
                _buildSeparator(),
                const SizedBox(height: 16),
                _buildTagline(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleArea(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildRingWidget(_ring1, 240),
        _buildRingWidget(_ring2, 180),
        Text(
          'APEX BOOSTER+',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontSize: 30,
            letterSpacing: 1.0,
            color: AppColors.apexGreen,
            shadows: [
              Shadow(
                color: AppColors.apexGreen.withValues(alpha: 0.6),
                blurRadius: 24,
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 800.ms)
            .scale(begin: const Offset(0.88, 0.88), duration: 800.ms),
      ],
    );
  }

  Widget _buildRingWidget(AnimationController controller, double size) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value;
        return Transform.scale(
          scale: 0.85 + t * 0.20,
          child: Opacity(
            opacity: (0.6 * (1.0 - t)).clamp(0.0, 1.0),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.apexGreen,
                  width: 1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeparator() {
    return Container(
      height: 1,
      width: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.apexGreen.withValues(alpha: 0.0),
            AppColors.apexGreen.withValues(alpha: 0.5),
            AppColors.apexGreen.withValues(alpha: 0.0),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 500.ms);
  }

  Widget _buildTagline(BuildContext context) {
    return Text(
      AppStrings(languageNotifier.value).appTagline,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        letterSpacing: 1.2,
      ),
    )
        .animate()
        .fadeIn(delay: 500.ms, duration: 600.ms)
        .slideY(begin: 0.15, end: 0, delay: 500.ms, duration: 500.ms);
  }
}
