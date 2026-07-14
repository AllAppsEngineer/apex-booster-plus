import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/core/accessibility/low_distraction_service.dart';
import 'package:apex_booster_plus/core/constants/app_colors.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/core/i18n/app_strings.dart';
import 'package:apex_booster_plus/data/datasources/installed_apps_datasource.dart';
import 'package:apex_booster_plus/data/repositories/shared_preferences_game_library_repository.dart';
import 'package:apex_booster_plus/domain/entities/apex_game.dart';
import 'package:apex_booster_plus/domain/entities/gfx_profile.dart';
import 'package:apex_booster_plus/domain/entities/installed_app.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_background.dart';
import 'package:apex_booster_plus/data/services/device_metrics_service_impl.dart';
import 'package:apex_booster_plus/domain/entities/apex_scan_result.dart';
import 'package:apex_booster_plus/domain/entities/device_metrics.dart';
import 'package:apex_booster_plus/domain/services/apex_scan_service.dart';
import 'package:apex_booster_plus/presentation/widgets/app_icon_widget.dart';
import 'package:apex_booster_plus/data/services/focus_mode_service_impl.dart';
import 'package:apex_booster_plus/domain/services/focus_mode_service.dart';
import 'package:apex_booster_plus/domain/entities/session_record.dart';
import 'package:apex_booster_plus/data/repositories/shared_preferences_session_repository.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_pulse.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_ring.dart';
import 'package:apex_booster_plus/presentation/widgets/status_chip.dart';

class GameDetailScreen extends StatefulWidget {
  final String gameId;
  final ApexGame? initialGame;

  const GameDetailScreen({super.key, required this.gameId, this.initialGame});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen>
    with WidgetsBindingObserver {
  ApexGame? _game;
  bool _loading = true;
  SharedPreferencesGameLibraryRepository? _repo;
  DeviceMetrics? _deviceMetrics;
  bool _metricsLoading = false;
  bool _metricsError = false;
  final _focusService = FocusModeServiceImpl();
  bool _focusWasEnabled = false;

  // Reference point for T+ timing logs.
  final int _t0 = DateTime.now().millisecondsSinceEpoch;

  int get _tms => DateTime.now().millisecondsSinceEpoch - _t0;

  @override
  void initState() {
    super.initState();
    // When initialGame is provided by the caller (e.g. PrepararTab already has
    // the object in memory), render content immediately on the first frame
    // instead of showing a spinner while SharedPreferences loads.
    if (widget.initialGame != null) {
      _game = widget.initialGame;
      _loading = false;
    }
    debugPrint('[DETAIL-NAV] T+${_tms}ms detail init (loading=$_loading)');
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('[DETAIL-NAV] T+${_tms}ms detail first frame');
      if (mounted) _loadGame();
    });
    if (widget.initialGame != null) {
      // Log when the first frame with actual content is painted.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('[DETAIL-NAV] T+${_tms}ms first meaningful content rendered');
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_focusWasEnabled) {
      _focusWasEnabled = false;
      unawaited(_focusService.restore());
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _focusWasEnabled) {
      _focusWasEnabled = false;
      unawaited(_focusService.restore());
    }
  }

  Future<void> _loadGame() async {
    debugPrint('[DETAIL-NAV] T+${_tms}ms data load started');
    final bool providedInitially = widget.initialGame != null;
    if (widget.gameId.isEmpty) {
      if (!providedInitially && mounted) setState(() => _loading = false);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    _repo = SharedPreferencesGameLibraryRepository(prefs);
    final game = await _repo!.getGameById(widget.gameId);
    debugPrint('[DETAIL-NAV] T+${_tms}ms game loaded: ${game?.name ?? "null"}');

    if (mounted) {
      setState(() {
        // Always update _game so we reflect any change made between tab and detail.
        _game = game;
        // Only toggle _loading when we were the ones that set it to true — i.e.
        // no initialGame was provided. With initialGame the first frame already
        // showed content, so we never showed a spinner.
        if (!providedInitially) _loading = false;
      });
      final resolvedGame = game ?? (providedInitially ? widget.initialGame : null);
      if (resolvedGame != null) {
        _loadMetrics();
      }
    }
    debugPrint('[DETAIL-NAV] T+${_tms}ms data load ended');
  }

  Future<void> _loadMetrics() async {
    if (!mounted) return;
    setState(() => _metricsLoading = true);
    try {
      final metrics = await DeviceMetricsServiceImpl()
          .measure()
          .timeout(const Duration(seconds: 4));
      if (mounted) {
        setState(() {
          _deviceMetrics = metrics;
          _metricsLoading = false;
        });
      }
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _metricsError = true;
          _metricsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _metricsError = true;
          _metricsLoading = false;
        });
      }
    }
  }

  Future<void> _openEditDialog() async {
    final game = _game;
    final repo = _repo;
    if (game == null || repo == null) return;

    List<InstalledApp> installedApps;
    try {
      installedApps = await InstalledAppsDatasource().getInstalledApps();
    } catch (_) {
      installedApps = const [];
    }

    final allGames = await repo.getGames();
    final otherPackages = allGames
        .where((g) => g.id != game.id && g.packageName != null)
        .map((g) => g.packageName!)
        .toSet();

    if (!mounted) return;

    final result = await showDialog<(String, String)>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => _EditGameDialog(
        initialName: game.name,
        initialPackageName: game.packageName ?? '',
        installedApps: installedApps,
        otherGamePackages: otherPackages,
      ),
    );

    if (result == null) return;
    if (!mounted) return;

    final (newName, newPkg) = result;
    final trimmedPkg = newPkg.trim();

    final updated = game.copyWith(
      name: newName,
      packageName: trimmedPkg.isEmpty ? null : trimmedPkg,
      clearPackageName: trimmedPkg.isEmpty,
      updatedAt: DateTime.now(),
    );

    await repo.updateGame(updated);
    if (mounted) setState(() { _game = updated; });
  }

  Future<void> _launchGame() async {
    final pkg = _game?.packageName;
    if (pkg == null || pkg.isEmpty) return;

    final launchedAt = DateTime.now();

    final focusResult = await _focusService.saveAndEnable();
    if (mounted && focusResult == FocusModeResult.success) {
      _focusWasEnabled = true;
    }
    if (!mounted) return;

    final error = await showModalBottomSheet<Object?>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => _PrepLaunchSheet(
        packageName: pkg,
        profileName: _game?.localProfileName,
      ),
    );

    if (!mounted) return;

    // Build record synchronously — launchStatus known before any await.
    final launchStatus = error == null ? 'success' : 'failed';
    final record = _buildSessionRecord(
      focusResult: focusResult,
      launchStatus: launchStatus,
      launchedAt: launchedAt,
    );
    if (record != null) unawaited(_saveSessionRecord(record));

    if (error == null) return;

    final s = AppStrings(languageNotifier.value);
    final message = error is PlatformException && error.code == 'APP_NOT_FOUND'
        ? s.detailAppNotFound
        : s.detailOpenFailed;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.energyOrange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  SessionRecord? _buildSessionRecord({
    required FocusModeResult focusResult,
    required String launchStatus,
    required DateTime launchedAt,
  }) {
    final game = _game;
    if (game == null) return null;

    final focusModeAvailable = focusResult != FocusModeResult.noPermission;
    final focusModeResultStr = switch (focusResult) {
      FocusModeResult.success => 'enabled',
      FocusModeResult.noPermission => 'noPermission',
      FocusModeResult.notActive => 'skipped',
      FocusModeResult.error => 'error',
    };

    final metrics = _metricsError ? null : _deviceMetrics;
    final metricsAvailable = metrics != null;

    int? memAvailMb;
    int? memTotalMb;
    String? memState;
    int? latencyMs;

    if (metricsAvailable) {
      if (metrics.availableMemoryBytes > 0) {
        memAvailMb = (metrics.availableMemoryBytes / (1024 * 1024)).round();
      }
      if (metrics.totalMemoryBytes > 0) {
        memTotalMb = (metrics.totalMemoryBytes / (1024 * 1024)).round();
      }
      memState = metrics.isLowMemory ? 'low' : 'normal';
      if (metrics.latencyStatus == LatencyStatus.success) {
        latencyMs = metrics.latencyMs;
      }
    }

    return SessionRecord(
      id: '${launchedAt.millisecondsSinceEpoch}_${game.id}',
      gameId: game.id,
      gameName: game.name,
      packageName: game.packageName,
      launchedAt: launchedAt,
      launchStatus: launchStatus,
      focusModeAvailable: focusModeAvailable,
      focusModeAttempted: true,
      focusModeResult: focusModeResultStr,
      metricsAvailable: metricsAvailable,
      memoryAvailableMb: memAvailMb,
      memoryTotalMb: memTotalMb,
      memoryState: memState,
      apexLatencyMs: latencyMs,
      gfxProfile: game.localProfileName,
    );
  }

  Future<void> _saveSessionRecord(SessionRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await SharedPreferencesSessionRepository(prefs).addSession(record);
    } catch (_) {}
  }

  Future<void> _openProfileSelector() async {
    final game = _game;
    if (game == null) return;

    await context.push('/gfx-profile/${game.id}');

    if (!mounted) return;
    await _loadGame();
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = !_loading && _game != null;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: ApexBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BackHeader(
                onBack: () => context.pop(),
                onEdit: canEdit ? _openEditDialog : null,
              ),
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
                        : _GameDetailContent(
                            game: _game!,
                            onSelectProfile: _openProfileSelector,
                            deviceMetrics: _deviceMetrics,
                            metricsLoading: _metricsLoading,
                            metricsError: _metricsError,
                          ),
              ),
              if (!_loading && _game != null)
                _LaunchGameButton(
                  hasPackage: _game!.packageName?.isNotEmpty == true,
                  onTap: _launchGame,
                ),
              if (!_loading && _game != null)
                _CreateCardButton(gameId: widget.gameId),
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
  final VoidCallback? onEdit;

  const _BackHeader({required this.onBack, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
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
            tooltip: s.actionBack,
          ),
          Text(
            s.detailTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          if (onEdit != null)
            IconButton(
              onPressed: onEdit,
              icon: const Icon(
                Icons.edit_rounded,
                color: AppColors.cyberBlue,
                size: 20,
              ),
              tooltip: s.actionEdit,
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
    final s = AppStrings(languageNotifier.value);
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
              s.detailNotFoundTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              s.detailNotFoundDesc,
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
                child: Text(
                  s.actionBackButton,
                  style: const TextStyle(
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
  final VoidCallback? onSelectProfile;
  final DeviceMetrics? deviceMetrics;
  final bool metricsLoading;
  final bool metricsError;

  const _GameDetailContent({
    required this.game,
    this.onSelectProfile,
    this.deviceMetrics,
    this.metricsLoading = false,
    this.metricsError = false,
  });

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
    final s = AppStrings(languageNotifier.value);
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GameHeaderCard(game: game),
          const SizedBox(height: 16),
          _InfoRow(
            title: s.detailPackageLabel,
            icon: Icons.apps_rounded,
            value: game.packageName,
            emptyMessage: s.detailNotConfigured,
            accentColor: AppColors.cyberBlue,
            delay: 100.ms,
          ),
          const SizedBox(height: 10),
          _GfxProfileActionCard(
            profileName: game.localProfileName,
            onTap: onSelectProfile,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            title: s.detailAddedAt,
            icon: Icons.calendar_today_rounded,
            value: _formatDate(game.createdAt),
            accentColor: AppColors.apexGreen,
            delay: 260.ms,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            title: s.detailUpdatedAt,
            icon: Icons.update_rounded,
            value: _formatDate(game.updatedAt),
            accentColor: AppColors.textGray,
            delay: 320.ms,
          ),
          const SizedBox(height: 20),
          _ScanSection(
            game: game,
            deviceMetrics: deviceMetrics,
            metricsLoading: metricsLoading,
            metricsError: metricsError,
          ),
        ],
      ),
    );
  }
}

// ─── Scan section (self-contained, isolates rebuild from parent) ──────────────

class _ScanSection extends StatefulWidget {
  final ApexGame game;
  final DeviceMetrics? deviceMetrics;
  final bool metricsLoading;
  final bool metricsError;

  const _ScanSection({
    required this.game,
    this.deviceMetrics,
    this.metricsLoading = false,
    this.metricsError = false,
  });

  @override
  State<_ScanSection> createState() => _ScanSectionState();
}

class _ScanSectionState extends State<_ScanSection> {
  late ApexScanResult _result;

  @override
  void initState() {
    super.initState();
    _result = _computeLocalScan(widget.game, null);
    _verifyLaunchable();
  }

  @override
  void didUpdateWidget(_ScanSection old) {
    super.didUpdateWidget(old);
    if (old.game.id != widget.game.id ||
        old.game.packageName != widget.game.packageName ||
        old.game.localProfileName != widget.game.localProfileName ||
        old.game.isFavorite != widget.game.isFavorite) {
      setState(() {
        _result = _computeLocalScan(widget.game, null);
      });
      _verifyLaunchable();
    }
  }

  /// Resolves whether [widget.game.packageName] is actually installed and
  /// re-scores the result. Leaves the score as "não verificado" (isLaunchable
  /// stays null) if there's no packageName yet or the lookup fails — never
  /// reports a false "incompleto" from a read error.
  Future<void> _verifyLaunchable() async {
    final pkg = widget.game.packageName;
    if (pkg == null || pkg.isEmpty) return;

    final requestedGameId = widget.game.id;
    bool? isLaunchable;
    try {
      final apps = await InstalledAppsDatasource().getInstalledApps();
      isLaunchable = apps.any((a) => a.packageName == pkg);
    } catch (_) {
      return;
    }

    if (!mounted || widget.game.id != requestedGameId) return;
    setState(() {
      _result = _computeLocalScan(widget.game, isLaunchable);
    });
  }

  static ApexScanResult _computeLocalScan(ApexGame game, bool? isLaunchable) =>
      ApexScanService().scan(game: game, isLaunchable: isLaunchable);

  @override
  Widget build(BuildContext context) {
    return _ApexScanCard(
      result: _result,
      deviceMetrics: widget.deviceMetrics,
      metricsLoading: widget.metricsLoading,
      metricsError: widget.metricsError,
      profileName: widget.game.localProfileName,
    );
  }
}

// ─── Game header card ─────────────────────────────────────────────────────────

class _GameHeaderCard extends StatelessWidget {
  final ApexGame game;

  const _GameHeaderCard({required this.game});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppIconWidget(packageName: game.packageName, size: 52),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Badge(label: s.libraryBadgeVerified, color: AppColors.cyberBlue),
                    if (game.isFavorite) ...[
                      const SizedBox(width: 8),
                      _FavoriteBadge(),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
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
        style: const TextStyle(
          color: Colors.white,
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
    final s = AppStrings(languageNotifier.value);
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.apexGreen, size: 12),
          const SizedBox(width: 4),
          Text(
            s.detailFavoriteBadge,
            style: const TextStyle(
              color: Colors.white,
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

// ─── GFX Profile action card ──────────────────────────────────────────────────

class _GfxProfileActionCard extends StatelessWidget {
  final String? profileName;
  final VoidCallback? onTap;

  const _GfxProfileActionCard({this.profileName, this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
    final hasProfile = profileName != null && profileName!.isNotEmpty;
    final resolvedProfile = GfxProfile.fromLabel(profileName);
    final resolvedLabel = (hasProfile && resolvedProfile != null)
        ? s.gfxProfileLabel(resolvedProfile)
        : s.detailGfxNoProfileDefined;

    return Ink(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1016),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.energyOrange
              .withValues(alpha: hasProfile ? 0.45 : 0.22),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.energyOrange
                .withValues(alpha: hasProfile ? 0.09 : 0.04),
            blurRadius: 14,
            spreadRadius: 0,
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.energyOrange.withValues(alpha: 0.09),
        highlightColor: AppColors.energyOrange.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.energyOrange.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.energyOrange.withValues(alpha: 0.28),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.energyOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.detailGfxProfileLabel,
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      resolvedLabel,
                      style: TextStyle(
                        color: hasProfile && resolvedProfile != null
                            ? AppColors.white
                            : AppColors.textGray.withValues(alpha: 0.55),
                        fontWeight: hasProfile && resolvedProfile != null
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 14,
                        fontStyle: hasProfile && resolvedProfile != null
                            ? FontStyle.normal
                            : FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.detailGfxHint,
                      style: TextStyle(
                        color: AppColors.textGray.withValues(alpha: 0.55),
                        fontSize: 10,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.energyOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.energyOrange.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: Text(
                  s.detailGfxAdjust,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 180.ms, duration: 400.ms)
        .slideX(begin: 0.03, end: 0, delay: 180.ms, duration: 300.ms);
  }
}

// ─── Edit dialog ─────────────────────────────────────────────────────────────

class _EditGameDialog extends StatefulWidget {
  final String initialName;
  final String initialPackageName;
  final List<InstalledApp> installedApps;
  final Set<String> otherGamePackages;

  const _EditGameDialog({
    required this.initialName,
    required this.initialPackageName,
    this.installedApps = const [],
    this.otherGamePackages = const {},
  });

  @override
  State<_EditGameDialog> createState() => _EditGameDialogState();
}

class _EditGameDialogState extends State<_EditGameDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _pkgController;
  String? _nameError;
  String? _pkgError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _pkgController = TextEditingController(text: widget.initialPackageName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pkgController.dispose();
    super.dispose();
  }

  void _submit() {
    final s = AppStrings(languageNotifier.value);
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = s.libraryValidationNameRequired);
      return;
    }

    final pkg = _pkgController.text.trim();
    if (pkg.isNotEmpty) {
      if (!widget.installedApps.any((a) => a.packageName == pkg)) {
        setState(() => _pkgError = s.libraryValidationAppNotFound);
        return;
      }
      if (widget.otherGamePackages.contains(pkg)) {
        setState(() => _pkgError = s.libraryAlreadyAdded);
        return;
      }
    }

    Navigator.of(context).pop((name, pkg));
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
    return AlertDialog(
      backgroundColor: const Color(0xFF111318),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.cyberBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      title: Text(
        s.detailEditTitle,
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DialogField(
            controller: _nameController,
            label: s.libraryFieldGameName,
            autofocus: true,
            errorText: _nameError,
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
          const SizedBox(height: 12),
          _DialogField(
            controller: _pkgController,
            label: s.libraryFieldPackageName,
            errorText: _pkgError,
            onChanged: (_) {
              if (_pkgError != null) setState(() => _pkgError = null);
            },
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(
            s.libraryCancelLower,
            style: const TextStyle(color: AppColors.textGray),
          ),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cyberBlue,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 0,
          ),
          child: Text(
            s.detailEditSave,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool autofocus;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const _DialogField({
    required this.controller,
    required this.label,
    this.autofocus = false,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      style: const TextStyle(color: AppColors.white),
      cursorColor: AppColors.cyberBlue,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: AppColors.textGray, fontSize: 14),
        errorText: errorText,
        errorStyle:
            const TextStyle(color: AppColors.energyOrange, fontSize: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: AppColors.cyberBlue.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: AppColors.cyberBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.energyOrange),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: AppColors.energyOrange, width: 1.5),
        ),
        filled: true,
        fillColor: AppColors.white.withValues(alpha: 0.05),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

// ─── Launch game button ───────────────────────────────────────────────────────

class _LaunchGameButton extends StatelessWidget {
  final bool hasPackage;
  final VoidCallback onTap;

  const _LaunchGameButton({required this.hasPackage, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
    final button = Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: hasPackage ? onTap : null,
          icon: const Icon(Icons.sports_esports_rounded, size: 20),
          label: Text(
            hasPackage ? s.detailOpenGame : s.detailNoAppLinked,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.apexGreen,
            foregroundColor: Colors.black,
            disabledBackgroundColor:
                AppColors.textGray.withValues(alpha: 0.12),
            disabledForegroundColor:
                AppColors.textGray.withValues(alpha: 0.45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
        ),
      ),
    );

    if (!hasPackage) return button;

    return button
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 2000.ms,
          color: Colors.white.withValues(alpha: 0.32),
          angle: 0.0,
        );
  }
}

// ─── Create card button (Share Studio entry point) ───────────────────────────

class _CreateCardButton extends StatelessWidget {
  final String gameId;
  const _CreateCardButton({required this.gameId});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: AppColors.apexGreen.withValues(alpha: 0.12),
          highlightColor: AppColors.apexGreen.withValues(alpha: 0.06),
          onTap: () {
            debugPrint('[ApexStudio] studio tapped');
            context.push('/share-studio/$gameId');
          },
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.apexGreen.withValues(alpha: 0.12),
                  AppColors.cyberBlue.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.apexGreen.withValues(alpha: 0.30),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.apexGreen.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: AppColors.apexGreen.withValues(alpha: 0.25),
                        width: 0.5,
                      ),
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.apexGreen,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.socialStudioCreateCard,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.socialStudioCreateCardHint,
                          style: TextStyle(
                            color: AppColors.apexGreen.withValues(alpha: 0.65),
                            fontSize: 11,
                          ),
                        ),
                      ],
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
        ),
      ),
    );
  }
}

// ─── Prep launch sheet (Checklist Apex / Preparação de Sessão) ────────────────

class _Step {
  final String label;
  final bool isCheck;
  const _Step(this.label, {required this.isCheck});
}

const _kStepDelay = Duration(milliseconds: 380);

class _PrepLaunchSheet extends StatefulWidget {
  final String packageName;
  final String? profileName;

  const _PrepLaunchSheet({required this.packageName, this.profileName});

  @override
  State<_PrepLaunchSheet> createState() => _PrepLaunchSheetState();
}

class _PrepLaunchSheetState extends State<_PrepLaunchSheet> {
  int _visibleCount = 1;
  bool _showChips = false;
  bool _ringComplete = false;
  late final List<_Step> _steps;
  late final bool _lowDistraction;

  @override
  void initState() {
    super.initState();
    _lowDistraction = lowDistractionNotifier.value;
    final s = AppStrings(languageNotifier.value);
    final resolvedBoostProfile = GfxProfile.fromLabel(widget.profileName);
    final profileLabel = resolvedBoostProfile != null
        ? s.gfxProfileLabel(resolvedBoostProfile)
        : s.detailProfileDefault;
    _steps = [
      _Step(s.ritualStepGameLock, isCheck: true),
      _Step(
        resolvedBoostProfile != null
            ? s.ritualStepProfileLoad(profileLabel)
            : s.ritualStepProfileReady,
        isCheck: true,
      ),
      _Step(s.ritualStepFocusPrep, isCheck: true),
      _Step(s.ritualStepApexScan, isCheck: true),
      _Step(s.ritualStepVisualSync, isCheck: true),
      _Step(s.ritualStepReadyState, isCheck: false),
    ];
    _runSequence();
  }

  Future<void> _runSequence() async {
    final stepDelay =
        _lowDistraction ? const Duration(milliseconds: 160) : _kStepDelay;
    for (int i = 1; i < _steps.length; i++) {
      await Future.delayed(stepDelay);
      if (!mounted) return;
      setState(() {
        _visibleCount = i + 1;
        if (i == _steps.length - 1) {
          _showChips = true;
          _ringComplete = true;
        }
      });
      if (!_lowDistraction) {
        if (i == 1) unawaited(HapticFeedback.lightImpact());
        if (i == _steps.length - 1) unawaited(HapticFeedback.mediumImpact());
      }
    }
    await Future.delayed(stepDelay);
    if (!mounted) return;
    try {
      await InstalledAppsDatasource().launchApp(widget.packageName);
      if (mounted) Navigator.of(context).pop<Object?>(null);
    } on PlatformException catch (e) {
      if (mounted) Navigator.of(context).pop<Object?>(e);
    } catch (e) {
      if (mounted) Navigator.of(context).pop<Object?>(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111318),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textGray.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(
                    Icons.rocket_launch_rounded,
                    color: AppColors.apexGreen,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Apex Boost Mode',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        s.boostSubtitle,
                        style: const TextStyle(
                          color: AppColors.textGray,
                          fontSize: 11,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: ApexPulse(
                  active: _ringComplete,
                  reducedMotion: _lowDistraction,
                  color: AppColors.apexGreen,
                  size: 100,
                  child: ApexRing(
                    progress: _visibleCount / _steps.length,
                    size: 80,
                    reducedMotion: _lowDistraction,
                    child: const Icon(
                      Icons.rocket_launch_rounded,
                      color: AppColors.apexGreen,
                      size: 22,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 350.ms),
              const SizedBox(height: 20),
              for (int i = 0; i < _visibleCount; i++)
                _PrepStepRow(
                  label: _steps[i].label,
                  isCheck: _steps[i].isCheck,
                )
                    .animate(key: ValueKey(i))
                    .fadeIn(duration: 280.ms)
                    .slideX(begin: 0.04, end: 0, duration: 230.ms),
              if (_showChips) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusChip(
                      label: s.boostChipSessionReady,
                      color: AppColors.apexGreen,
                      icon: Icons.check_circle_rounded,
                    ),
                    StatusChip(
                      label: s.boostChipProfileLoaded,
                      color: AppColors.cyberBlue,
                      icon: Icons.tune_rounded,
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 280.ms)
                    .slideY(begin: 0.04, end: 0, duration: 230.ms),
              ],
            ],
          ),
        ),
      ),
    ),
  );
  }
}

class _PrepStepRow extends StatelessWidget {
  final String label;
  final bool isCheck;

  const _PrepStepRow({required this.label, required this.isCheck});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: isCheck
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.apexGreen,
                    size: 20,
                  )
                : const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.apexGreen,
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isCheck ? AppColors.white : AppColors.textGray,
                  fontSize: 13,
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Apex Scan card ───────────────────────────────────────────────────────────

class _ApexScanCard extends StatelessWidget {
  final ApexScanResult result;
  final DeviceMetrics? deviceMetrics;
  final bool metricsLoading;
  final bool metricsError;
  final String? profileName;

  const _ApexScanCard({
    required this.result,
    this.deviceMetrics,
    this.metricsLoading = false,
    this.metricsError = false,
    this.profileName,
  });

  String _statusLabel(AppStrings s) {
    switch (result.score) {
      case ScanScore.pronto:
        return s.detailScanStatusReady;
      case ScanScore.naoVerificado:
        return s.detailScanStatusUnverified;
      case ScanScore.incompleto:
        final acesso = result.checks.where((c) => c.id == 'acesso').firstOrNull;
        if (acesso?.status == ScanCheckStatus.fail) return s.detailScanStatusAppNotFound;
        return s.detailScanStatusIncomplete;
    }
  }

  Color _statusColor() => switch (result.score) {
        ScanScore.pronto => AppColors.apexGreen,
        ScanScore.naoVerificado => AppColors.cyberBlue,
        ScanScore.incompleto => AppColors.energyOrange,
      };

  IconData _statusIcon() => switch (result.score) {
        ScanScore.pronto => Icons.verified_rounded,
        ScanScore.naoVerificado => Icons.help_outline_rounded,
        ScanScore.incompleto => Icons.warning_amber_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
    final statusColor = _statusColor();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1016),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.30),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.10),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.radar_rounded, color: statusColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'APEX SCAN',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.detailScanSubtitle,
                        style: const TextStyle(
                          color: AppColors.textGray,
                          fontSize: 10,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(), color: statusColor, size: 12),
                      const SizedBox(width: 5),
                      Text(
                        _statusLabel(s),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 550.ms, duration: 300.ms)
                    .scale(
                      begin: const Offset(0.86, 0.86),
                      end: const Offset(1.0, 1.0),
                      delay: 550.ms,
                      duration: 280.ms,
                      curve: Curves.easeOutBack,
                    ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: AppColors.white.withValues(alpha: 0.06),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                for (int i = 0; i < result.checks.length; i++)
                  _ScanCheckRow(
                    check: result.checks[i],
                    index: i,
                    translatedMessage: s.detailScanCheckMessage(
                      result.checks[i],
                      profileLabel: profileName,
                    ),
                  ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: AppColors.white.withValues(alpha: 0.06),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: _PerformanceModulesSection(),
          ),
          Divider(
            height: 1,
            color: AppColors.white.withValues(alpha: 0.06),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: _RealMetricsSection(
              metrics: deviceMetrics,
              loading: metricsLoading,
              hasError: metricsError,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 380.ms, duration: 500.ms)
        .slideY(
          begin: 0.06,
          end: 0,
          delay: 380.ms,
          duration: 420.ms,
          curve: Curves.easeOut,
        );
  }
}

// ─── Preparation panel section (UX-P1.1) ─────────────────────────────────────

class _PerformanceModulesSection extends StatelessWidget {
  const _PerformanceModulesSection();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
    final modules = [
      (label: s.detailModuleFps,          color: AppColors.apexGreen,    icon: Icons.speed_rounded),
      (label: s.detailModuleRam,          color: AppColors.cyberBlue,    icon: Icons.memory_rounded),
      (label: s.detailModuleGpu,          color: AppColors.energyOrange, icon: Icons.videogame_asset_rounded),
      (label: s.detailModulePing,         color: AppColors.cyberBlue,    icon: Icons.wifi_rounded),
      (label: s.detailModuleOptimization, color: AppColors.apexGreen,    icon: Icons.tune_rounded),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.detailModulesTitle,
          style: const TextStyle(
            color: AppColors.textGray,
            fontWeight: FontWeight.bold,
            fontSize: 10,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (int i = 0; i < modules.length; i++)
              _ModuleChip(
                label: modules[i].label,
                icon: modules[i].icon,
                color: modules[i].color,
                index: i,
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ConfirmBadge(label: s.detailModuleBoostApplied, delay: 1050),
            _ConfirmBadge(label: s.detailModulePerfImproved, delay: 1100),
          ],
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 750.ms, duration: 400.ms)
        .slideY(begin: 0.05, end: 0, delay: 750.ms, duration: 350.ms);
  }
}

class _ModuleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int index;

  const _ModuleChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final delay = Duration(milliseconds: 800 + index * 40);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.14),
            color.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.38),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.14),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: delay, duration: 300.ms)
        .scale(
          begin: const Offset(0.88, 0.88),
          end: const Offset(1.0, 1.0),
          delay: delay,
          duration: 250.ms,
          curve: Curves.easeOutBack,
        );
  }
}

class _ConfirmBadge extends StatelessWidget {
  final String label;
  final int delay;

  const _ConfirmBadge({required this.label, required this.delay});

  @override
  Widget build(BuildContext context) {
    final d = Duration(milliseconds: delay);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.apexGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.apexGreen.withValues(alpha: 0.40),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.apexGreen,
            size: 13,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.apexGreen,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: d, duration: 300.ms)
        .scale(
          begin: const Offset(0.88, 0.88),
          end: const Offset(1.0, 1.0),
          delay: d,
          duration: 280.ms,
          curve: Curves.easeOutBack,
        );
  }
}

// ─── Scan check row ───────────────────────────────────────────────────────────

class _ScanCheckRow extends StatelessWidget {
  final ScanCheck check;
  final int index;
  final String? translatedMessage;

  const _ScanCheckRow({
    required this.check,
    required this.index,
    this.translatedMessage,
  });

  (IconData, Color) _iconAndColor() {
    return switch (check.status) {
      ScanCheckStatus.ok => (Icons.check_circle_rounded, AppColors.apexGreen),
      ScanCheckStatus.warn => (
          Icons.warning_amber_rounded,
          AppColors.energyOrange
        ),
      ScanCheckStatus.fail => (Icons.cancel_rounded, AppColors.energyOrange),
      ScanCheckStatus.info => (Icons.info_outline_rounded, AppColors.cyberBlue),
    };
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconAndColor();
    final delay = Duration(milliseconds: 600 + index * 70);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              translatedMessage ?? check.message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: check.status == ScanCheckStatus.info
                        ? AppColors.textGray
                        : AppColors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: delay, duration: 300.ms)
        .slideX(begin: -0.04, end: 0, delay: delay, duration: 250.ms);
  }
}

// ─── Real metrics section ─────────────────────────────────────────────────────

class _RealMetricsSection extends StatelessWidget {
  final DeviceMetrics? metrics;
  final bool loading;
  final bool hasError;

  const _RealMetricsSection({
    required this.metrics,
    required this.loading,
    required this.hasError,
  });

  String _formatMb(int bytes, AppStrings s) {
    if (bytes <= 0) return s.snapshotUnavailable;
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(0)} MB';
  }

  String _latencyLabel(DeviceMetrics m, AppStrings s) => switch (m.latencyStatus) {
        LatencyStatus.success => '${m.latencyMs} ms',
        LatencyStatus.timeout => s.snapshotLatencyTimeout,
        LatencyStatus.noNetwork => s.snapshotLatencyNoNetwork,
        LatencyStatus.error => s.snapshotUnavailable,
      };

  Color _latencyColor(DeviceMetrics m) => switch (m.latencyStatus) {
        LatencyStatus.success => AppColors.apexGreen,
        LatencyStatus.timeout => AppColors.energyOrange,
        LatencyStatus.noNetwork => AppColors.energyOrange,
        LatencyStatus.error => AppColors.textGray,
      };

  String _memoryStateLabel(DeviceMetrics m, AppStrings s) {
    if (m.totalMemoryBytes <= 0) return s.snapshotUnavailable;
    return m.isLowMemory ? s.detailMemoryLow : s.snapshotMemoryNormal;
  }

  Color _memoryStateColor(DeviceMetrics m) {
    if (m.totalMemoryBytes <= 0) return AppColors.textGray;
    return m.isLowMemory ? AppColors.energyOrange : AppColors.apexGreen;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.memory_rounded, color: AppColors.cyberBlue, size: 13),
            const SizedBox(width: 6),
            Text(
              s.detailMetricsTitle,
              style: const TextStyle(
                color: AppColors.textGray,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          s.detailMetricsSubtitle,
          style: const TextStyle(
            color: AppColors.textGray,
            fontSize: 9,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 12),
        if (loading)
          const _MetricsLoadingRow()
        else if (hasError || metrics == null)
          const _MetricsErrorRow()
        else ...[
          _RealMetricRow(
            label: s.snapshotRamAvail,
            value: _formatMb(metrics!.availableMemoryBytes, s),
            valueColor: AppColors.white,
          ),
          _RealMetricRow(
            label: s.snapshotRamTotal,
            value: _formatMb(metrics!.totalMemoryBytes, s),
            valueColor: AppColors.white,
          ),
          _RealMetricRow(
            label: s.snapshotRamState,
            value: _memoryStateLabel(metrics!, s),
            valueColor: _memoryStateColor(metrics!),
          ),
          _RealMetricRow(
            label: s.snapshotLatency,
            subtitle: s.detailLatencySubtitle,
            value: _latencyLabel(metrics!, s),
            valueColor: _latencyColor(metrics!),
          ),
        ],
      ],
    )
        .animate()
        .fadeIn(delay: 900.ms, duration: 400.ms)
        .slideY(begin: 0.04, end: 0, delay: 900.ms, duration: 350.ms);
  }
}

class _MetricsLoadingRow extends StatelessWidget {
  const _MetricsLoadingRow();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: AppColors.cyberBlue.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            s.detailMetricsLoading,
            style: TextStyle(
              color: AppColors.textGray.withValues(alpha: 0.7),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsErrorRow extends StatelessWidget {
  const _MetricsErrorRow();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.textGray.withValues(alpha: 0.5),
            size: 14,
          ),
          const SizedBox(width: 8),
          Text(
            s.detailMetricsUnavailable,
            style: TextStyle(
              color: AppColors.textGray.withValues(alpha: 0.6),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _RealMetricRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final String value;
  final Color valueColor;

  const _RealMetricRow({
    required this.label,
    this.subtitle,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 11,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: AppColors.textGray.withValues(alpha: 0.55),
                      fontSize: 9,
                      letterSpacing: 0.2,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
