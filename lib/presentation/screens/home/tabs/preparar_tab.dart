import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:apex_booster_plus/core/constants/app_colors.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/core/i18n/app_strings.dart';
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
/// Falls back to [s.prepGfxMsgNone] for null or unrecognized values.
String buildGfxScanMessage(String? localProfileName, AppStrings s) {
  final profile = GfxProfile.fromLabel(localProfileName);
  if (profile == null) return s.prepGfxMsgNone;
  return switch (profile) {
    GfxProfile.balanced     => s.prepGfxMsgBalanced,
    GfxProfile.performance  => s.prepGfxMsgPerformance,
    GfxProfile.quality      => s.prepGfxMsgQuality,
    GfxProfile.economy      => s.prepGfxMsgEconomy,
  };
}

/// Returns up to 3 actionable preparation suggestions for the given GFX profile.
/// Returns an empty list when [profile] is null — no suggestions rendered.
/// Safe with null [metrics] and null [focusGranted].
List<String> buildGfxRecommendations(
  GfxProfile? profile,
  DeviceMetrics? metrics,
  bool? focusGranted,
  AppStrings s,
) {
  if (profile == null) return const [];

  final recs = <String>[];

  switch (profile) {
    case GfxProfile.performance:
      recs.add(s.recPerfCloseBackground);
      if (focusGranted == false) {
        recs.add(s.recPerfFocus);
      }
      if (metrics?.isLowMemory == true) {
        recs.add(s.recPerfLowMemory);
      } else {
        recs.add(s.recPerfWifi);
      }

    case GfxProfile.quality:
      recs.add(s.recQualCharge);
      if (metrics != null && metrics.latencyStatus != LatencyStatus.success) {
        recs.add(s.recQualLatency);
      }
      if (focusGranted == false) {
        recs.add(s.recQualFocus);
      }

    case GfxProfile.economy:
      recs.add(s.recEcoBrightness);
      if (metrics?.isLowMemory == true) {
        recs.add(s.recPerfCloseBackground);
      } else {
        recs.add(s.recEcoShortSessions);
      }
      if (focusGranted == false) {
        recs.add(s.recEcoFocus);
      }

    case GfxProfile.balanced:
      recs.add(s.recBalStable);
      if (metrics?.isLowMemory == true) {
        recs.add(s.recBalCloseUnused);
      }
      if (focusGranted == false) {
        recs.add(s.recPerfFocus);
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

List<_PrepScanCheck> _buildScanChecks(ApexGame game, AppStrings s) {
  final hasPackage = buildIsLaunchableHint(game);
  return [
    _PrepScanCheck(
      label: s.prepScanLabelApp,
      message: hasPackage ? s.prepScanMsgAppOk : s.prepScanMsgAppWarn,
      status: hasPackage ? _PrepScanStatus.ok : _PrepScanStatus.warn,
    ),
    _PrepScanCheck(
      label: s.prepScanLabelGfx,
      message: buildGfxScanMessage(game.localProfileName, s),
      status: GfxProfile.fromLabel(game.localProfileName) != null
          ? _PrepScanStatus.ok
          : _PrepScanStatus.info,
    ),
    _PrepScanCheck(
      label: s.prepScanLabelPriority,
      message: game.isFavorite ? s.prepScanMsgPriorityOk : s.prepScanMsgPriorityInfo,
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
  // Scan checks are computed in build() from _selectedGame + current language.

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
    });
  }

  void _openGameSelector() {
    final s = AppStrings(languageNotifier.value);
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
        s: s,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: languageNotifier,
      builder: (context, _) {
        final s = AppStrings(languageNotifier.value);
        final scanChecks = _selectedGame != null
            ? _buildScanChecks(_selectedGame!, s)
            : <_PrepScanCheck>[];

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
                        _PrepararHeader(s: s),
                        const SizedBox(height: 28),
                        if (_selectedGame == null)
                          _EmptyLibraryState(s: s)
                        else ...[
                          _SelectedGameCard(
                            game: _selectedGame!,
                            showTrocar: _games.length > 1,
                            onTrocar: _openGameSelector,
                            s: s,
                          ),
                          const SizedBox(height: 16),
                          _PrepScanCard(
                            checks: scanChecks,
                            game: _selectedGame!,
                            metrics: _metrics,
                            focusGranted: _focusGranted,
                            s: s,
                          ),
                        ],
                        const SizedBox(height: 16),
                        _DeviceSnapshotCard(
                          loading: _metricsLoading,
                          metrics: _metrics,
                          focusGranted: _focusGranted,
                          s: s,
                        ),
                        const SizedBox(height: 32),
                        _PrepararCTA(
                          game: _selectedGame,
                          onContinue: _navigateToDetails,
                          s: s,
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

// ── Header ────────────────────────────────────────────────────────────────────

class _PrepararHeader extends StatelessWidget {
  final AppStrings s;

  const _PrepararHeader({required this.s});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.prepTitle,
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
          s.prepSubtitle,
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
  final AppStrings s;

  const _EmptyLibraryState({required this.s});

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
            s.prepEmptyTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            s.prepEmptyDesc,
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
  final AppStrings s;

  const _SelectedGameCard({
    required this.game,
    required this.showTrocar,
    required this.onTrocar,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    final gfxProfile = GfxProfile.fromLabel(game.localProfileName);
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
              ApexBadge(label: s.prepGameBadge, color: AppColors.apexGreen),
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
                          s.prepChangeGame,
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
                          label: 'GFX: ${gfxProfile != null ? s.gfxProfileLabel(gfxProfile) : s.prepGfxDefault}',
                          color: gfxProfile?.accentColor ?? AppColors.energyOrange,
                        ),
                        if (game.isFavorite)
                          _InfoChip(
                            label: s.prepFavoriteLabel,
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
  final AppStrings s;

  const _PrepScanCard({
    required this.checks,
    required this.game,
    this.metrics,
    this.focusGranted,
    required this.s,
  });

  bool get _isReady => buildIsLaunchableHint(game);

  @override
  Widget build(BuildContext context) {
    final scoreColor = _isReady ? AppColors.apexGreen : AppColors.energyOrange;
    final scoreLabel =
        _isReady ? s.prepScanStatusReady : s.prepScanStatusIncomplete;

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
                        s.prepScanTitle.toUpperCase(),
                        style: TextStyle(
                          color: AppColors.cyberBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.4,
                        ),
                      ),
                      Text(
                        s.prepScanSubtitle,
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
            s.prepDisclaimer1,
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
    final recs = buildGfxRecommendations(profile, metrics, focusGranted, s);
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
        s.prepSuggestionsTitle.toUpperCase(),
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
        _PrepScanStatus.ok   => AppColors.apexGreen,
        _PrepScanStatus.warn => AppColors.energyOrange,
        _PrepScanStatus.info => AppColors.cyberBlue,
      };

  IconData get _icon => switch (check.status) {
        _PrepScanStatus.ok   => Icons.check_circle_rounded,
        _PrepScanStatus.warn => Icons.warning_amber_rounded,
        _PrepScanStatus.info => Icons.info_outline_rounded,
      };

  String get _statusLabel => switch (check.status) {
        _PrepScanStatus.ok   => 'OK',
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
  final AppStrings s;

  const _DeviceSnapshotCard({
    required this.loading,
    required this.metrics,
    required this.focusGranted,
    required this.s,
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
                    s.snapshotTitle.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.energyOrange,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.4,
                    ),
                  ),
                  Text(
                    s.snapshotLocalReading,
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
              label: s.snapshotRamAvail,
              value: _formatMemoryMb(metrics?.availableMemoryMb, s),
              valueColor: _availableMemoryColor(metrics),
            ),
            _SnapshotRow(
              label: s.snapshotRamTotal,
              value: _formatMemoryMb(metrics?.totalMemoryMb, s),
              valueColor: AppColors.white.withValues(alpha: 0.85),
            ),
            _SnapshotRow(
              label: s.snapshotRamState,
              value: _memoryStateLabel(metrics, s),
              valueColor: _memoryStateColor(metrics),
            ),
            _SnapshotRow(
              label: s.snapshotLatency,
              value: _latencyLabel(metrics, s),
              valueColor: _latencyColor(metrics),
            ),
            _SnapshotRow(
              label: s.snapshotFocusMode,
              value: _focusLabel(focusGranted, s),
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
            s.prepDisclaimer2,
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

  // Trava 1: null → s.snapshotUnavailable. Zero MB from a real device is still
  // shown as a legitimate reading; only null (failed/empty metric) becomes a label.
  static String _formatMemoryMb(double? mb, AppStrings s) {
    if (mb == null) return s.snapshotUnavailable;
    return '${mb.round()} MB';
  }

  static Color _availableMemoryColor(DeviceMetrics? m) {
    if (m == null) return AppColors.textGray;
    return m.isLowMemory ? AppColors.energyOrange : AppColors.apexGreen;
  }

  static String _memoryStateLabel(DeviceMetrics? m, AppStrings s) {
    if (m == null) return s.snapshotUnavailable;
    return m.isLowMemory ? s.snapshotMemoryCritical : s.snapshotMemoryNormal;
  }

  static Color _memoryStateColor(DeviceMetrics? m) {
    if (m == null) return AppColors.textGray;
    return m.isLowMemory ? AppColors.energyOrange : AppColors.apexGreen;
  }

  static String _latencyLabel(DeviceMetrics? m, AppStrings s) {
    if (m == null) return s.snapshotUnavailable;
    return switch (m.latencyStatus) {
      LatencyStatus.success =>
        m.latencyMs != null ? '${m.latencyMs} ms' : s.snapshotUnavailable,
      LatencyStatus.timeout   => s.snapshotLatencyTimeout,
      LatencyStatus.noNetwork => s.snapshotLatencyNoNetwork,
      LatencyStatus.error     => s.snapshotUnavailable,
    };
  }

  static Color _latencyColor(DeviceMetrics? m) {
    if (m == null) return AppColors.textGray;
    return switch (m.latencyStatus) {
      LatencyStatus.success =>
        (m.latencyMs != null && m.latencyMs! < 100)
            ? AppColors.apexGreen
            : AppColors.energyOrange,
      LatencyStatus.timeout   => AppColors.energyOrange,
      LatencyStatus.noNetwork => AppColors.textGray,
      LatencyStatus.error     => AppColors.textGray,
    };
  }

  static String _focusLabel(bool? granted, AppStrings s) {
    if (granted == null) return s.snapshotUnavailable;
    return granted ? s.snapshotFocusAvailable : s.snapshotFocusPermissionRequired;
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
  final AppStrings s;

  const _PrepararCTA({
    required this.game,
    required this.onContinue,
    required this.s,
  });

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
        child: Text(
          s.prepContinue,
          style: const TextStyle(
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
  final AppStrings s;

  const _GameSelectorSheet({
    required this.games,
    required this.selectedId,
    required this.onSelect,
    required this.s,
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
              s.prepSelectGame,
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
