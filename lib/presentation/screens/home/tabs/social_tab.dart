import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/core/constants/app_colors.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/core/i18n/app_strings.dart';
import 'package:apex_booster_plus/data/repositories/shared_preferences_game_library_repository.dart';
import 'package:apex_booster_plus/domain/entities/apex_game.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_background.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_badge.dart';
import 'package:apex_booster_plus/presentation/widgets/app_icon_widget.dart';
import 'package:apex_booster_plus/presentation/widgets/social/floating_capture_card.dart';

class SocialTab extends StatefulWidget {
  final bool isActive;
  const SocialTab({super.key, this.isActive = false});

  @override
  State<SocialTab> createState() => _SocialTabState();
}

class _SocialTabState extends State<SocialTab> {
  List<ApexGame> _games = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(SocialTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final games = await SharedPreferencesGameLibraryRepository(prefs).getGames();
    if (!mounted) return;
    setState(() {
      _games = games;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: languageNotifier,
      builder: (context, _) {
        final s = AppStrings(languageNotifier.value);
        return ApexBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.socialTabTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.socialTabSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textGray,
                        ),
                  ),
                  const SizedBox(height: 28),
                  const FloatingCaptureCard(),
                  const SizedBox(height: 20),
                  _CreateCardSection(s: s, loading: _loading, games: _games),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CreateCardSection extends StatelessWidget {
  final AppStrings s;
  final bool loading;
  final List<ApexGame> games;

  const _CreateCardSection({
    required this.s,
    required this.loading,
    required this.games,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.apexGreen.withValues(alpha: 0.08),
            AppColors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.apexGreen.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ApexBadge(label: s.socialTabCreateBadge, color: AppColors.apexGreen),
          const SizedBox(height: 14),
          Text(
            s.socialStudioCreateCard,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            s.socialStudioCreateCardHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textGray,
                  fontSize: 13,
                ),
          ),
          const SizedBox(height: 16),
          if (loading)
            const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (games.isEmpty)
            Text(
              s.socialTabPickGameEmpty,
              style: TextStyle(
                color: AppColors.textGray.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            )
          else
            Column(
              children: [for (final game in games) _GamePickerTile(game: game)],
            ),
        ],
      ),
    );
  }
}

class _GamePickerTile extends StatelessWidget {
  final ApexGame game;
  const _GamePickerTile({required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          debugPrint('[ApexStudio] social tab game tapped');
          context.push('/share-studio/${game.id}');
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              AppIconWidget(packageName: game.packageName, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  game.name,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.apexGreen.withValues(alpha: 0.45),
                size: 13,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
