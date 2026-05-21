import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/core/constants/app_colors.dart';
import 'package:apex_booster_plus/data/repositories/shared_preferences_game_library_repository.dart';
import 'package:apex_booster_plus/domain/entities/apex_game.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_background.dart';

class GameDetailScreen extends StatefulWidget {
  final String gameId;

  const GameDetailScreen({super.key, required this.gameId});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  ApexGame? _game;
  bool _loading = true;

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
    final repo = SharedPreferencesGameLibraryRepository(prefs);
    final game = await repo.getGameById(widget.gameId);
    if (mounted) {
      setState(() {
        _game = game;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: ApexBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BackHeader(onBack: () => context.pop()),
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
                        : _GameDetailContent(game: _game!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Back header ─────────────────────────────────────────────────────────────

class _BackHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _BackHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 16, 4),
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
          Text(
            'Detalhe do Jogo',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Not found ───────────────────────────────────────────────────────────────

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

// ─── Detail content ──────────────────────────────────────────────────────────

class _GameDetailContent extends StatelessWidget {
  final ApexGame game;

  const _GameDetailContent({required this.game});

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y  $h:$min';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GameHeaderCard(game: game),
          const SizedBox(height: 16),
          _InfoRow(
            title: 'Package',
            icon: Icons.apps_rounded,
            value: game.packageName,
            emptyMessage: 'Não configurado',
            accentColor: AppColors.cyberBlue,
            delay: 100.ms,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            title: 'Perfil local',
            icon: Icons.tune_rounded,
            value: game.localProfileName,
            emptyMessage: 'Nenhum perfil configurado',
            accentColor: AppColors.energyOrange,
            delay: 180.ms,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            title: 'Adicionado em',
            icon: Icons.calendar_today_rounded,
            value: _formatDate(game.createdAt),
            accentColor: AppColors.apexGreen,
            delay: 260.ms,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            title: 'Atualizado em',
            icon: Icons.update_rounded,
            value: _formatDate(game.updatedAt),
            accentColor: AppColors.textGray,
            delay: 320.ms,
          ),
        ],
      ),
    );
  }
}

class _GameHeaderCard extends StatelessWidget {
  final ApexGame game;

  const _GameHeaderCard({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cyberBlue.withValues(alpha: 0.15),
            AppColors.white.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: game.isFavorite
              ? AppColors.apexGreen.withValues(alpha: 0.4)
              : AppColors.cyberBlue.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Badge(label: 'GAME', color: AppColors.cyberBlue),
              if (game.isFavorite) ...[
                const SizedBox(width: 8),
                _FavoriteBadge(),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            game.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.04, end: 0, duration: 400.ms);
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _FavoriteBadge extends StatelessWidget {
  const _FavoriteBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.apexGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.apexGreen.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: AppColors.apexGreen, size: 12),
          SizedBox(width: 4),
          Text(
            'FAVORITO',
            style: TextStyle(
              color: AppColors.apexGreen,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? value;
  final String? emptyMessage;
  final Color accentColor;
  final Duration delay;

  const _InfoRow({
    required this.title,
    required this.icon,
    this.value,
    this.emptyMessage,
    required this.accentColor,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    final displayValue = hasValue ? value! : (emptyMessage ?? '—');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasValue
              ? accentColor.withValues(alpha: 0.2)
              : AppColors.white.withValues(alpha: 0.07),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(
            icon,
            color: hasValue
                ? accentColor
                : AppColors.textGray.withValues(alpha: 0.4),
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textGray,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  displayValue,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: hasValue
                            ? AppColors.white
                            : AppColors.textGray.withValues(alpha: 0.55),
                        fontSize: 13,
                        fontStyle:
                            hasValue ? FontStyle.normal : FontStyle.italic,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: delay, duration: 400.ms)
        .slideX(begin: 0.03, end: 0, delay: delay, duration: 300.ms);
  }
}
