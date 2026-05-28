import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:apex_booster_plus/core/constants/app_colors.dart';
import 'package:apex_booster_plus/data/repositories/shared_preferences_game_library_repository.dart';
import 'package:apex_booster_plus/data/repositories/shared_preferences_session_repository.dart';
import 'package:apex_booster_plus/domain/entities/apex_game.dart';
import 'package:apex_booster_plus/domain/entities/session_record.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_background.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_badge.dart';
import 'package:apex_booster_plus/presentation/widgets/app_icon_widget.dart';

// ── Pure functions (exported for testing) ────────────────────────────────────

/// Returns the game to pre-select based on session history.
/// Priority: last launched game → first in library → null (empty library).
ApexGame? selectGameForPreparation(
  List<ApexGame> games,
  List<SessionRecord> sessions,
) {
  if (games.isEmpty) return null;
  if (sessions.isNotEmpty) {
    final lastGameId = sessions.first.gameId;
    final found = games.cast<ApexGame?>().firstWhere(
          (g) => g!.id == lastGameId,
          orElse: () => null,
        );
    if (found != null) return found;
  }
  return games.first;
}

/// True when a packageName is registered — used as a local heuristic only.
/// Does not verify whether the app is installed at runtime.
bool buildIsLaunchableHint(ApexGame game) =>
    game.packageName != null && game.packageName!.isNotEmpty;

// ── Private scan model ────────────────────────────────────────────────────────

enum _PrepScanStatus { ok, warn, info }

class _PrepScanCheck {
  final String label;
  final String message;
  final _PrepScanStatus status;

  const _PrepScanCheck({
    required this.label,
    required this.message,
    required this.status,
  });
}

List<_PrepScanCheck> _buildScanChecks(ApexGame game) {
  final hasPackage = buildIsLaunchableHint(game);
  return [
    _PrepScanCheck(
      label: 'App vinculado',
      message: hasPackage
          ? 'PackageName registrado no cadastro'
          : 'Sem vínculo — packageName não cadastrado',
      status: hasPackage ? _PrepScanStatus.ok : _PrepScanStatus.warn,
    ),
    _PrepScanCheck(
      label: 'Perfil GFX',
      message: game.localProfileName != null
          ? 'Perfil ${game.localProfileName} configurado'
          : 'Perfil padrão será usado',
      status: game.localProfileName != null
          ? _PrepScanStatus.ok
          : _PrepScanStatus.info,
    ),
    _PrepScanCheck(
      label: 'Prioridade',
      message:
          game.isFavorite ? 'Marcado como prioritário' : 'Jogo padrão na biblioteca',
      status: game.isFavorite ? _PrepScanStatus.ok : _PrepScanStatus.info,
    ),
  ];
}

// ── Widget ────────────────────────────────────────────────────────────────────

class PrepararTab extends StatefulWidget {
  const PrepararTab({super.key});

  @override
  State<PrepararTab> createState() => _PrepararTabState();
}

class _PrepararTabState extends State<PrepararTab> {
  bool _loading = true;
  List<ApexGame> _games = [];
  ApexGame? _selectedGame;
  List<_PrepScanCheck> _scanChecks = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final gameRepo = SharedPreferencesGameLibraryRepository(prefs);
    final sessionRepo = SharedPreferencesSessionRepository(prefs);

    final results = await Future.wait([
      gameRepo.getGames(),
      sessionRepo.getSessions(),
    ]);

    final games = results[0] as List<ApexGame>;
    final sessions = results[1] as List<SessionRecord>;
    final selected = selectGameForPreparation(games, sessions);

    if (mounted) {
      setState(() {
        _games = games;
        _selectedGame = selected;
        _scanChecks = selected != null ? _buildScanChecks(selected) : [];
        _loading = false;
      });
    }
  }

  void _onGameSelected(ApexGame game) {
    setState(() {
      _selectedGame = game;
      _scanChecks = _buildScanChecks(game);
    });
  }

  void _openGameSelector() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) => _GameSelectorSheet(
        games: _games,
        selectedId: _selectedGame?.id,
        onSelect: (game) {
          Navigator.of(sheetCtx).pop();
          _onGameSelected(game);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ApexBackground(
      child: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.apexGreen,
                  strokeWidth: 2,
                ),
              )
            : SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _PrepararHeader(),
                    const SizedBox(height: 28),
                    if (_selectedGame == null)
                      const _EmptyLibraryState()
                    else ...[
                      _SelectedGameCard(
                        game: _selectedGame!,
                        showTrocar: _games.length > 1,
                        onTrocar: _openGameSelector,
                      ),
                      const SizedBox(height: 16),
                      _PrepScanCard(
                        checks: _scanChecks,
                        game: _selectedGame!,
                      ),
                    ],
                    const SizedBox(height: 32),
                    _PrepararCTA(game: _selectedGame),
                  ],
                ),
              ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _PrepararHeader extends StatelessWidget {
  const _PrepararHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preparar sessão',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .slideY(begin: -0.08, end: 0, duration: 400.ms),
        const SizedBox(height: 8),
        Text(
          'Selecione um jogo e verifique os dados antes de jogar.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textGray,
              ),
        ).animate().fadeIn(delay: 100.ms, duration: 500.ms),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyLibraryState extends StatelessWidget {
  const _EmptyLibraryState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.videogame_asset_off_rounded,
            size: 48,
            color: AppColors.textGray.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum jogo na biblioteca',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione jogos na aba Biblioteca para começar a preparar sua sessão.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textGray,
                  fontSize: 13,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}

// ── Selected game card ────────────────────────────────────────────────────────

class _SelectedGameCard extends StatelessWidget {
  final ApexGame game;
  final bool showTrocar;
  final VoidCallback onTrocar;

  const _SelectedGameCard({
    required this.game,
    required this.showTrocar,
    required this.onTrocar,
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
            AppColors.apexGreen.withValues(alpha: 0.12),
            AppColors.white.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.apexGreen.withValues(alpha: 0.30),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ApexBadge(label: 'JOGO', color: AppColors.apexGreen),
              if (showTrocar)
                GestureDetector(
                  onTap: onTrocar,
                  child: Text(
                    'TROCAR',
                    style: TextStyle(
                      color: AppColors.apexGreen.withValues(alpha: 0.85),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              AppIconWidget(packageName: game.packageName, size: 48),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      children: [
                        _InfoChip(
                          label: 'GFX: ${game.localProfileName ?? "Padrão"}',
                          color: AppColors.energyOrange,
                        ),
                        if (game.isFavorite)
                          const _InfoChip(
                            label: '★ Favorito',
                            color: AppColors.cyberBlue,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.04, end: 0, duration: 400.ms);
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.withValues(alpha: 0.9),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Apex Scan card ────────────────────────────────────────────────────────────

class _PrepScanCard extends StatelessWidget {
  final List<_PrepScanCheck> checks;
  final ApexGame game;

  const _PrepScanCard({required this.checks, required this.game});

  bool get _isReady => buildIsLaunchableHint(game);

  @override
  Widget build(BuildContext context) {
    final scoreColor = _isReady ? AppColors.apexGreen : AppColors.energyOrange;
    final scoreLabel = _isReady ? '● PRONTO' : '● INCOMPLETO';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cyberBlue.withValues(alpha: 0.10),
            AppColors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cyberBlue.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ApexBadge(label: 'APEX SCAN', color: AppColors.cyberBlue),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: scoreColor.withValues(alpha: 0.35)),
                ),
                child: Text(
                  scoreLabel,
                  style: TextStyle(
                    color: scoreColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...checks.map((c) => _ScanCheckRow(check: c)),
          const SizedBox(height: 10),
          Divider(
            color: AppColors.white.withValues(alpha: 0.08),
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 10),
          Text(
            'Snapshot local. Sem alteração automática de desempenho.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textGray.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 500.ms)
        .slideY(begin: 0.04, end: 0, duration: 400.ms);
  }
}

class _ScanCheckRow extends StatelessWidget {
  final _PrepScanCheck check;

  const _ScanCheckRow({required this.check});

  Color get _color => switch (check.status) {
        _PrepScanStatus.ok => AppColors.apexGreen,
        _PrepScanStatus.warn => AppColors.energyOrange,
        _PrepScanStatus.info => AppColors.cyberBlue,
      };

  IconData get _icon => switch (check.status) {
        _PrepScanStatus.ok => Icons.check_circle_rounded,
        _PrepScanStatus.warn => Icons.warning_amber_rounded,
        _PrepScanStatus.info => Icons.info_outline_rounded,
      };

  String get _statusLabel => switch (check.status) {
        _PrepScanStatus.ok => 'OK',
        _PrepScanStatus.warn => 'WARN',
        _PrepScanStatus.info => 'INFO',
      };

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(_icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  check.label,
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  check.message,
                  style: TextStyle(
                    color: AppColors.textGray.withValues(alpha: 0.85),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              _statusLabel,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── CTA ───────────────────────────────────────────────────────────────────────

class _PrepararCTA extends StatelessWidget {
  final ApexGame? game;

  const _PrepararCTA({required this.game});

  @override
  Widget build(BuildContext context) {
    final enabled = game != null;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed:
            enabled ? () => context.push('/game-detail/${game!.id}') : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.apexGreen,
          foregroundColor: AppColors.background,
          disabledBackgroundColor: AppColors.apexGreen.withValues(alpha: 0.2),
          disabledForegroundColor: AppColors.textGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: const Text(
          'VER DETALHES DO JOGO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.5,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms);
  }
}

// ── Game selector sheet ───────────────────────────────────────────────────────

class _GameSelectorSheet extends StatelessWidget {
  final List<ApexGame> games;
  final String? selectedId;
  final void Function(ApexGame) onSelect;

  const _GameSelectorSheet({
    required this.games,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Selecionar jogo',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.45,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: games.length,
            itemBuilder: (_, i) {
              final g = games[i];
              final isSelected = g.id == selectedId;
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                leading: AppIconWidget(packageName: g.packageName, size: 36),
                title: Text(
                  g.name,
                  style: TextStyle(
                    color: isSelected ? AppColors.apexGreen : AppColors.white,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        color: AppColors.apexGreen,
                        size: 18,
                      )
                    : null,
                onTap: () => onSelect(g),
              );
            },
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
      ],
    );
  }
}
