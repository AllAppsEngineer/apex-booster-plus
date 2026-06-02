import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_language.dart';
import '../../../core/i18n/app_strings.dart';
import '../../widgets/apex_background.dart';
import '../../widgets/apex_feature_card.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: languageNotifier,
      builder: (context, _) {
        final s = AppStrings(languageNotifier.value);
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
                    _buildBackNav(context, s),
                    const SizedBox(height: 20),
                    _buildHeader(context, s),
                    const SizedBox(height: 8),
                    _buildSubtitle(context, s),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            _buildCards(s),
                            const SizedBox(height: 20),
                            _buildTrustMessage(context, s),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCta(context, s),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackNav(BuildContext context, AppStrings s) {
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

  Widget _buildHeader(BuildContext context, AppStrings s) {
    return Text(
      s.permissionsTitle,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: AppColors.white,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 500.ms);
  }

  Widget _buildSubtitle(BuildContext context, AppStrings s) {
    return Text(
      s.permissionsSubtitle,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppColors.textGray,
        height: 1.5,
      ),
    ).animate().fadeIn(delay: 160.ms, duration: 500.ms);
  }

  Widget _buildCards(AppStrings s) {
    return Column(
      children: [
        ApexFeatureCard(
          badge: 'NOTIF',
          title: s.permissionsCardNotifTitle,
          subtitle: s.permissionsCardNotifSubtitle,
          accentColor: AppColors.apexGreen,
          delay: 240.ms,
        ),
        const SizedBox(height: 12),
        ApexFeatureCard(
          badge: 'APPS',
          title: s.permissionsCardAppsTitle,
          subtitle: s.permissionsCardAppsSubtitle,
          accentColor: AppColors.apexGreen,
          delay: 360.ms,
        ),
        const SizedBox(height: 12),
        ApexFeatureCard(
          badge: s.permissionsCardNetBadge,
          title: s.permissionsCardNetTitle,
          subtitle: s.permissionsCardNetSubtitle,
          accentColor: AppColors.apexGreen,
          delay: 480.ms,
        ),
        const SizedBox(height: 12),
        ApexFeatureCard(
          badge: s.focusBadge,
          title: s.permissionsCardFocusTitle,
          subtitle: s.permissionsCardFocusSubtitle,
          accentColor: AppColors.apexGreen,
          delay: 600.ms,
        ),
      ],
    );
  }

  Widget _buildTrustMessage(BuildContext context, AppStrings s) {
    return Text(
      s.permissionsTrustMessage,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppColors.apexGreen.withValues(alpha: 0.7),
        fontStyle: FontStyle.italic,
        letterSpacing: 0.3,
      ),
    ).animate().fadeIn(delay: 720.ms, duration: 500.ms);
  }

  Widget _buildCta(BuildContext context, AppStrings s) {
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
            context.go('/home');
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
          child: Text(
            s.permissionsCta,
            style: const TextStyle(
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
