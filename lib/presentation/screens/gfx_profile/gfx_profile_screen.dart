import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/core/constants/app_colors.dart';
import 'package:apex_booster_plus/data/repositories/shared_preferences_game_library_repository.dart';
import 'package:apex_booster_plus/domain/entities/apex_game.dart';
import 'package:apex_booster_plus/domain/entities/gfx_profile.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_background.dart';
import 'package:apex_booster_plus/presentation/widgets/app_icon_widget.dart';

class GfxProfileScreen extends StatefulWidget {
  final String gameId;

  const GfxProfileScreen({super.key, required this.gameId});

  @override
  State<GfxProfileScreen> createState() => _GfxProfileScreenState();
}

class _GfxProfileScreenState extends State<GfxProfileScreen> {
  ApexGame? _game;
  bool _loading = true;
  bool _saving = false;
  SharedPreferencesGameLibraryRepository? _repo;

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  Future<void> _loadGame() async {
    if (widget.gameId.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    _repo = SharedPreferencesGameLibraryRepository(prefs);
    final game = await _repo!.getGameById(widget.gameId);
    if (mounted) setState(() { _game = game; _loading = false; });
  }

  Future<void> _selectProfile(String? label) async {
    final game = _game;
    final repo = _repo;
    if (game == null || repo == null || _saving) return;

    setState(() => _saving = true);

    final ApexGame updated;
    if (label == null) {
      updated = game.copyWith(clearLocalProfileName: true, updatedAt: DateTime.now());
    } else {
      updated = game.copyWith(localProfileName: label, updatedAt: DateTime.now());
    }

    await repo.updateGame(updated);

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: ApexBackground(
        child: SafeArea(
          child: Column(
            children: [
              _GfxHeader(onBack: () => context.pop()),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.cyberBlue,
                          strokeWidth: 2,
                        ),
                      )
                    : _game == null
                        ? _GameNotFound(onBack: () => context.pop())
                        : _GfxContent(
                            game: _game!,
                            saving: _saving,
                            onSelectProfile: _selectProfile,
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _GfxHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _GfxHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 8, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.white,
              size: 20,
            ),
            tooltip: 'Voltar',
          ),
          Row(
            children: [
              const Icon(
                Icons.tune_rounded,
                color: AppColors.energyOrange,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Perfil GFX',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Not found ────────────────────────────────────────────────────────────────

class _GameNotFound extends StatelessWidget {
  final VoidCallback onBack;

  const _GameNotFound({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.videogame_asset_off_rounded,
              color: AppColors.textGray.withValues(alpha: 0.45),
              size: 56,
            ),
            const SizedBox(height: 20),
            Text(
              'Jogo não encontrado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Este jogo pode ter sido removido da biblioteca.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textGray,
                    fontSize: 13,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: onBack,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyberBlue,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  elevation: 0,
                ),
                child: const Text(
                  'VOLTAR',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ─── GFX content ──────────────────────────────────────────────────────────────

class _GfxContent extends StatelessWidget {
  final ApexGame game;
  final bool saving;
  final Future<void> Function(String? label) onSelectProfile;

  const _GfxContent({
    required this.game,
    required this.saving,
    required this.onSelectProfile,
  });

  @override
  Widget build(BuildContext context) {
    final currentProfile = GfxProfile.fromLabel(game.localProfileName);

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GameBanner(game: game)
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.04, end: 0, duration: 350.ms),
          const SizedBox(height: 24),
          Text(
            'Ajuste a preferência gráfica de preparação deste jogo.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textGray,
                  fontSize: 13,
                ),
          ).animate().fadeIn(duration: 400.ms, delay: 80.ms),
          const SizedBox(height: 20),
          ...GfxProfile.values.indexed.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ProfileCard(
                profile: entry.$2,
                isSelected: currentProfile == entry.$2,
                saving: saving,
                onTap: () => onSelectProfile(entry.$2.label),
              ).animate().fadeIn(
                    duration: 350.ms,
                    delay: Duration(milliseconds: 120 + entry.$1 * 60),
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _NoneCard(
              isSelected: currentProfile == null,
              saving: saving,
              onTap: () => onSelectProfile(null),
            )
                .animate()
                .fadeIn(
                  duration: 350.ms,
                  delay: Duration(
                    milliseconds: 120 + GfxProfile.values.length * 60,
                  ),
                ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 12,
                color: AppColors.textGray.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 6),
              Text(
                'Perfil aplicado à preparação local do jogo.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textGray.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          )
              .animate()
              .fadeIn(
                duration: 350.ms,
                delay: Duration(
                  milliseconds: 160 + GfxProfile.values.length * 60,
                ),
              ),
        ],
      ),
    );
  }
}

// ─── Game banner ──────────────────────────────────────────────────────────────

class _GameBanner extends StatelessWidget {
  final ApexGame game;

  const _GameBanner({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.energyOrange.withValues(alpha: 0.12),
            AppColors.white.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.energyOrange.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          AppIconWidget(packageName: game.packageName, size: 44),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (game.localProfileName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Atual: ${game.localProfileName}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.energyOrange,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Profile card ─────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final GfxProfile profile;
  final bool isSelected;
  final bool saving;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.profile,
    required this.isSelected,
    required this.saving,
    required this.onTap,
  });

  String get _description {
    switch (profile) {
      case GfxProfile.balanced:
        return 'Equilibra fluidez e qualidade para sessões longas.';
      case GfxProfile.performance:
        return 'Prioriza responsividade na preparação da sessão.';
      case GfxProfile.quality:
        return 'Orientado para uma experiência visual mais rica.';
      case GfxProfile.economy:
        return 'Reduz demanda e preserva bateria durante a sessão.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  profile.accentColor.withValues(alpha: 0.18),
                  profile.accentColor.withValues(alpha: 0.06),
                ],
              )
            : LinearGradient(
                colors: [
                  AppColors.white.withValues(alpha: 0.05),
                  AppColors.white.withValues(alpha: 0.02),
                ],
              ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? profile.accentColor.withValues(alpha: 0.55)
              : AppColors.white.withValues(alpha: 0.08),
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: profile.accentColor.withValues(alpha: 0.15),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: saving ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: profile.accentColor.withValues(alpha: 0.1),
          highlightColor: profile.accentColor.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: profile.accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: profile.accentColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    profile.icon,
                    color: profile.accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? profile.accentColor
                                  : AppColors.white,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 14,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textGray,
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: profile.accentColor,
                    size: 22,
                  )
                else
                  Icon(
                    Icons.radio_button_unchecked_rounded,
                    color: AppColors.textGray.withValues(alpha: 0.35),
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── None card ────────────────────────────────────────────────────────────────

class _NoneCard extends StatelessWidget {
  final bool isSelected;
  final bool saving;
  final VoidCallback onTap;

  const _NoneCard({
    required this.isSelected,
    required this.saving,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.textGray.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppColors.textGray.withValues(alpha: 0.35)
              : AppColors.white.withValues(alpha: 0.06),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: saving ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: AppColors.textGray.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.textGray.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.textGray.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.remove_circle_outline_rounded,
                    color: AppColors.textGray.withValues(alpha: 0.55),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nenhum',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.textGray,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontStyle: isSelected
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                              fontSize: 14,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Sem preferência definida para este jogo.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textGray.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.textGray,
                    size: 22,
                  )
                else
                  Icon(
                    Icons.radio_button_unchecked_rounded,
                    color: AppColors.textGray.withValues(alpha: 0.3),
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
