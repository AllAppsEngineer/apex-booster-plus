import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:apex_booster_plus/core/constants/app_colors.dart';
import 'package:apex_booster_plus/data/repositories/shared_preferences_game_library_repository.dart';
import 'package:apex_booster_plus/data/repositories/shared_preferences_session_repository.dart';
import 'package:apex_booster_plus/data/services/device_metrics_service_impl.dart';
import 'package:apex_booster_plus/data/services/focus_mode_service_impl.dart';
import 'package:apex_booster_plus/domain/entities/apex_game.dart';
import 'package:apex_booster_plus/domain/entities/device_metrics.dart';
import 'package:apex_booster_plus/domain/entities/gfx_profile.dart';
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

/// Returns the semantic message for a GFX profile name in the local prep scan.
/// Falls back to 'Perfil padrão será usado' for null or unrecognized values.
String buildGfxScanMessage(String? localProfileName) {
  final profile = GfxProfile.fromLabel(localProfileName);
  if (profile == null) return 'Perfil padrão será usado';
  return switch (profile) {
    GfxProfile.balanced => 'Equilibrado — balanço entre visual e fluidez',
    GfxProfile.performance => 'Desempenho — priorizando fluidez local',
    GfxProfile.quality => 'Qualidade — priorizando visual local',
    GfxProfile.economy => 'Economia — priorizando autonomia da bateria',
  };
}

/// Returns up to 3 actionable preparation suggestions for the given GFX profile.
/// Returns an empty list when [profile] is null — no suggestions rendered.
/// Safe with null [metrics] and null [focusGranted].
List<String> buildGfxRecommendations(
  GfxProfile? profile,
  DeviceMetrics? metrics,
  bool? focusGranted,
) {
  if (profile == null) return const [];

  final recs = <String>[];

  switch (profile) {
    case GfxProfile.performance:
      recs.add('Feche apps em segundo plano antes de iniciar');
      if (focusGranted == false) {
        recs.add('Ative o Modo Foco para reduzir interrupções');
      }
      if (metrics?.isLowMemory == true) {
        recs.add('RAM limitada — feche apps pesados antes de jogar');
      } else {
        recs.add('Prefira conexão Wi-Fi estável');
      }

    case GfxProfile.quality:
      recs.add('Mantenha o dispositivo carregado durante a sessão');
      if (metrics != null && metrics.latencyStatus != LatencyStatus.success) {
        recs.add('Conexão estável favorece uma sessão mais consistente');
      }
      if (focusGranted == false) {
        recs.add('Ative o Modo Foco para reduzir interrupções visuais');
      }

    case GfxProfile.economy:
      recs.add('Reduza o brilho da tela para preservar bateria');
      if (metrics?.isLowMemory == true) {
        recs.add('Feche apps em segundo plano antes de iniciar');
      } else {
        recs.add('Prefira sessões mais curtas ou jogue com carga suficiente');
      }
      if (focusGranted == false) {
        recs.add('Modo Foco ajuda a reduzir interrupções na sessão');
      }

    case GfxProfile.balanced:
      recs.add('Prepare a sessão com conexão estável');
      if (metrics?.isLowMemory == true) {
        recs.add('Feche apps que não usa antes de iniciar');
      }
      if (focusGranted == false) {
        recs.add('Ative o Modo Foco para reduzir interrupções');
      }
  }

  return recs.take(3).toList();
}

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
      message: buildGfxScanMessage(game.localProfileName),
      status: GfxProfile.fromLabel(game.localProfileName) != null
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
  final bool isActive;

  const PrepararTab({super.key, this.isActive = false});

  @override
  State<PrepararTab> createState() => _PrepararTabState();
}

class _PrepararTabState extends State<PrepararTab> {
  // Game / session state
  bool _loading = true;
  List<ApexGame> _games = [];
  ApexGame? _selectedGame;
  List<_PrepScanCheck> _scanChecks = [];

  // Device snapshot state — independent loading cycle
  bool _metricsLoading = true;
  DeviceMetrics? _metrics;
  bool? _focusGranted;

  @override
  void initState() {
    super.initState();
    _load();
    _loadMetrics(); // runs concurrently, never blocks game display
  }

  @override
  void didUpdateWidget(PrepararTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _refreshSelectedGame();
    }
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

  /// Reloads the selected game from SharedPreferences to pick up changes
  /// (e.g. a GFX profile update) made in GameDetail/GfxProfile.
  /// Does NOT call getInstalledApps or any MethodChannel.
  Future<void> _refreshSelectedGame() async {
    if (_selectedGame == null) return;
    final currentId = _selectedGame!.id;
    final prefs = await SharedPreferences.getInstance();
    final gameRepo = SharedPreferencesGameLibraryRepository(prefs);
    final games = await gameRepo.getGames();
    final updated = games.cast<ApexGame?>().firstWhere(
          (g) => g?.id == currentId,
          orElse: () => null,
        );
    if (!mounted) return;
    setState(() {
      _games = games;
      if (updated != null) {
        _selectedGame = updated;
        _scanChecks = _buildScanChecks(updated);
      }
    });
  }

  Future<void> _navigateToDetails() async {
    if (_selectedGame == null || !mounted) return;
    await context.push('/game-detail/${_selectedGame!.id}');
    if (!mounted) return;
    await _refreshSelectedGame();
  }

  Future<void> _loadMetrics() async {
    // Start both futures concurrently before any await.
    final metricsFuture = DeviceMetricsServiceImpl().measure().timeout(
          const Duration(seconds: 6),
          onTimeout: () => DeviceMetrics.empty(),
        );
    final focusFuture = FocusModeServiceImpl().isPermissionGranted();

    DeviceMetrics? metrics;
    bool? focusGranted;

    try {
      final m = await metricsFuture;
      // Trava 1: reject zeroed metrics — DeviceMetrics.empty() or real failure.
      // Only accept if totalMemoryBytes is non-zero, signalling a real reading.
      if (m.totalMemoryBytes > 0) metrics = m;
    } catch (_) {
      // leave null → each row shows "Indisponível"
    }

    try {
      focusGranted = await focusFuture;
    } catch (_) {
      // leave null → shows "Indisponível"
    }

    if (mounted) {
      setState(() {
        _metrics = metrics;
        _focusGranted = focusGranted;
        _metricsLoading = false;
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
                        metrics: _metrics,
                        focusGranted: _focusGranted,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _DeviceSnapshotCard(
                      loading: _metricsLoading,
                      metrics: _metrics,
                      focusGranted: _focusGranted,
                    ),
                    const SizedBox(height: 32),
                    _PrepararCTA(
                      game: _selectedGame,
                      onContinue: _navigateToDetails,
                    ),
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.apexGreen.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.apexGreen.withValues(alpha: 0.40),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.swap_horiz_rounded,
                          size: 13,
                          color: AppColors.apexGreen.withValues(alpha: 0.85),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'TROCAR',
                          style: TextStyle(
                            color: AppColors.apexGreen.withValues(alpha: 0.85),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
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
                          color: GfxProfile.fromLabel(game.localProfileName)
                                  ?.accentColor ??
                              AppColors.energyOrange,
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
  final DeviceMetrics? metrics;
  final bool? focusGranted;

  const _PrepScanCard({
    required this.checks,
    required this.game,
    this.metrics,
    this.focusGranted,
  });

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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.cyberBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.cyberBlue.withValues(alpha: 0.30),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.track_changes_rounded,
                      size: 14,
                      color: AppColors.cyberBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'APEX SCAN',
                        style: TextStyle(
                          color: AppColors.cyberBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.4,
                        ),
                      ),
                      Text(
                        'Verificação local do jogo',
                        style: TextStyle(
                          color: AppColors.textGray.withValues(alpha: 0.70),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
          ..._buildSuggestions(context),
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

  List<Widget> _buildSuggestions(BuildContext context) {
    final profile = GfxProfile.fromLabel(game.localProfileName);
    final recs = buildGfxRecommendations(profile, metrics, focusGranted);
    if (recs.isEmpty) return const [];

    return [
      const SizedBox(height: 10),
      Divider(
        color: AppColors.white.withValues(alpha: 0.08),
        thickness: 1,
        height: 1,
      ),
      const SizedBox(height: 10),
      Text(
        'SUGESTÕES',
        style: TextStyle(
          color: AppColors.cyberBlue.withValues(alpha: 0.75),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      const SizedBox(height: 6),
      ...recs.map((r) => _RecommendationRow(text: r)),
    ];
  }
}

class _RecommendationRow extends StatelessWidget {
  final String text;

  const _RecommendationRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.arrow_right_rounded,
            size: 14,
            color: AppColors.cyberBlue.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.textGray.withValues(alpha: 0.85),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
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

// ── Device snapshot card ──────────────────────────────────────────────────────

class _DeviceSnapshotCard extends StatelessWidget {
  final bool loading;
  final DeviceMetrics? metrics;
  final bool? focusGranted;

  const _DeviceSnapshotCard({
    required this.loading,
    required this.metrics,
    required this.focusGranted,
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
            AppColors.energyOrange.withValues(alpha: 0.10),
            AppColors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.energyOrange.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.energyOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.energyOrange.withValues(alpha: 0.30),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.memory_rounded,
                  size: 14,
                  color: AppColors.energyOrange,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SNAPSHOT DO DISPOSITIVO',
                    style: TextStyle(
                      color: AppColors.energyOrange,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.4,
                    ),
                  ),
                  Text(
                    'Leitura local do dispositivo',
                    style: TextStyle(
                      color: AppColors.textGray.withValues(alpha: 0.70),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(
                  color: AppColors.energyOrange,
                  strokeWidth: 2,
                ),
              ),
            )
          else ...[
            _SnapshotRow(
              label: 'Memória disponível',
              value: _formatMemoryMb(metrics?.availableMemoryMb),
              valueColor: _availableMemoryColor(metrics),
            ),
            _SnapshotRow(
              label: 'Memória total',
              value: _formatMemoryMb(metrics?.totalMemoryMb),
              valueColor: AppColors.white.withValues(alpha: 0.85),
            ),
            _SnapshotRow(
              label: 'Estado da memória',
              value: _memoryStateLabel(metrics),
              valueColor: _memoryStateColor(metrics),
            ),
            _SnapshotRow(
              label: 'Latência Apex',
              value: _latencyLabel(metrics),
              valueColor: _latencyColor(metrics),
            ),
            _SnapshotRow(
              label: 'Modo Foco',
              value: _focusLabel(focusGranted),
              valueColor: _focusColor(focusGranted),
            ),
          ],
          const SizedBox(height: 10),
          Divider(
            color: AppColors.white.withValues(alpha: 0.08),
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 10),
          // Trava 2: disclaimer sempre visível, reforça caráter informativo/local.
          Text(
            'Snapshot local. Não representa alteração automática no jogo.',
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
        .fadeIn(delay: 150.ms, duration: 500.ms)
        .slideY(begin: 0.04, end: 0, duration: 400.ms);
  }

  // Trava 1: null → "Indisponível". Zero MB from a real device is still shown
  // as a legitimate reading; only null (failed/empty metric) becomes a label.
  static String _formatMemoryMb(double? mb) {
    if (mb == null) return 'Indisponível';
    return '${mb.round()} MB';
  }

  static Color _availableMemoryColor(DeviceMetrics? m) {
    if (m == null) return AppColors.textGray;
    return m.isLowMemory ? AppColors.energyOrange : AppColors.apexGreen;
  }

  static String _memoryStateLabel(DeviceMetrics? m) {
    if (m == null) return 'Indisponível';
    return m.isLowMemory ? 'Crítico' : 'Normal';
  }

  static Color _memoryStateColor(DeviceMetrics? m) {
    if (m == null) return AppColors.textGray;
    return m.isLowMemory ? AppColors.energyOrange : AppColors.apexGreen;
  }

  static String _latencyLabel(DeviceMetrics? m) {
    if (m == null) return 'Indisponível';
    return switch (m.latencyStatus) {
      LatencyStatus.success =>
        m.latencyMs != null ? '${m.latencyMs} ms' : 'Indisponível',
      LatencyStatus.timeout => 'Tempo esgotado',
      LatencyStatus.noNetwork => 'Sem rede',
      LatencyStatus.error => 'Indisponível',
    };
  }

  static Color _latencyColor(DeviceMetrics? m) {
    if (m == null) return AppColors.textGray;
    return switch (m.latencyStatus) {
      LatencyStatus.success =>
        (m.latencyMs != null && m.latencyMs! < 100)
            ? AppColors.apexGreen
            : AppColors.energyOrange,
      LatencyStatus.timeout => AppColors.energyOrange,
      LatencyStatus.noNetwork => AppColors.textGray,
      LatencyStatus.error => AppColors.textGray,
    };
  }

  static String _focusLabel(bool? granted) {
    if (granted == null) return 'Indisponível';
    return granted ? 'Disponível' : 'Permissão necessária';
  }

  static Color _focusColor(bool? granted) {
    if (granted == null) return AppColors.textGray;
    return granted ? AppColors.apexGreen : AppColors.energyOrange;
  }
}

class _SnapshotRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _SnapshotRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.82),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── CTA ───────────────────────────────────────────────────────────────────────

class _PrepararCTA extends StatelessWidget {
  final ApexGame? game;
  final VoidCallback? onContinue;

  const _PrepararCTA({required this.game, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final enabled = game != null;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: enabled ? onContinue : null,
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
          'CONTINUAR PARA DETALHES',
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
