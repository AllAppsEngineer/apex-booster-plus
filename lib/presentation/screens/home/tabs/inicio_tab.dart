import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/core/constants/app_colors.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/core/i18n/app_strings.dart';
import 'package:apex_booster_plus/data/datasources/installed_apps_datasource.dart';
import 'package:apex_booster_plus/data/repositories/shared_preferences_game_library_repository.dart';
import 'package:apex_booster_plus/data/repositories/shared_preferences_session_repository.dart';
import 'package:apex_booster_plus/domain/entities/gfx_profile.dart';
import 'package:apex_booster_plus/domain/entities/session_record.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_background.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_feature_card.dart';

class InicioTab extends StatefulWidget {
  final bool isActive;

  const InicioTab({super.key, required this.isActive});

  @override
  State<InicioTab> createState() => _InicioTabState();
}

class _InicioTabState extends State<InicioTab> {
  bool _loading = true;
  int _gameCount = 0;
  int _sessionCount = 0;
  SessionRecord? _lastSession;
  Uint8List? _lastIconBytes;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(InicioTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final gameRepo = SharedPreferencesGameLibraryRepository(prefs);
    final sessionRepo = SharedPreferencesSessionRepository(prefs);

    final games = await gameRepo.getGames();
    final sessions = await sessionRepo.getSessions();

    final lastSession = sessions.isEmpty ? null : sessions.first;
    Uint8List? iconBytes;

    if (lastSession?.packageName != null) {
      // Synchronous prefs read — no MethodChannel, no Android main-thread block
      iconBytes = InstalledAppsDatasource.preCacheFromPrefs(
          prefs, lastSession!.packageName!);
    }

    if (!mounted) return;
    setState(() {
      _gameCount = games.length;
      _sessionCount = sessions.length;
      _lastSession = lastSession;
      _lastIconBytes = iconBytes;
      _loading = false;
    });

    // Cache miss: defer MethodChannel to after the first frame so the UI
    // renders immediately with a placeholder instead of blocking.
    if (lastSession?.packageName != null && iconBytes == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadIconInBackground(lastSession!.packageName!, prefs);
        }
      });
    }
  }

  Future<void> _loadIconInBackground(
      String packageName, SharedPreferences prefs) async {
    final bytes = await InstalledAppsDatasource().getAppIcon(packageName);
    if (bytes != null) {
      await InstalledAppsDatasource.saveIconToPrefs(prefs, packageName, bytes);
    }
    if (!mounted) return;
    setState(() => _lastIconBytes = bytes);
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
                  _InicioHeader(),
                  const SizedBox(height: 28),
                  if (_lastSession != null) ...[
                    _LastSessionCard(
                      session: _lastSession!,
                      iconBytes: _lastIconBytes,
                    ),
                    const SizedBox(height: 16),
                  ],
                  _QuickStatsRow(
                    gameCount: _gameCount,
                    sessionCount: _sessionCount,
                    loading: _loading,
                  ),
                  const SizedBox(height: 16),
                  ApexFeatureCard(
                    badge: s.homeLibraryBadge,
                    title: s.homeLibraryTitle,
                    subtitle: _loading
                        ? s.homeLibraryLoadingSubtitle
                        : s.gameCountStat(_gameCount),
                    accentColor: AppColors.cyberBlue,
                    delay: 100.ms,
                  ),
                  const SizedBox(height: 12),
                  ApexFeatureCard(
                    badge: s.homeHistoryBadge,
                    title: s.homeHistoryFeatureTitle,
                    subtitle: _loading
                        ? s.homeHistoryLoadingSubtitle
                        : s.sessionCountStat(_sessionCount),
                    accentColor: AppColors.apexGreen,
                    delay: 150.ms,
                  ),
                  const SizedBox(height: 12),
                  ApexFeatureCard(
                    badge: s.focusBadge,
                    title: s.focusTitle,
                    subtitle: s.homeFocusSubtitle,
                    accentColor: AppColors.apexGreen,
                    delay: const Duration(milliseconds: 200),
                  ),
                  const SizedBox(height: 12),
                  ApexFeatureCard(
                    badge: s.prepScanBadge,
                    title: s.homeScanTitle,
                    subtitle: s.homeScanSubtitle,
                    accentColor: AppColors.cyberBlue,
                    delay: const Duration(milliseconds: 250),
                  ),
                  const SizedBox(height: 12),
                  ApexFeatureCard(
                    badge: s.homeGameBadge,
                    title: s.homeClassTitle,
                    subtitle: s.homeClassSubtitle,
                    accentColor: AppColors.apexGreen,
                    delay: const Duration(milliseconds: 300),
                  ),
                  if (!_loading && _lastSession == null) ...[
                    const SizedBox(height: 24),
                    _EmptyHint(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────────────

class _InicioHeader extends StatelessWidget {
  const _InicioHeader();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.homeTitle,
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
          s.homeSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textGray,
              ),
        ).animate().fadeIn(delay: 100.ms, duration: 500.ms),
      ],
    );
  }
}

// ── Último jogo card ─────────────────────────────────────────────────────────

class _LastSessionCard extends StatelessWidget {
  final SessionRecord session;
  final Uint8List? iconBytes;

  const _LastSessionCard({
    required this.session,
    required this.iconBytes,
  });

  List<String> _collectChips() {
    final chips = <String>[];
    final ram = session.memoryAvailableMb;
    if (ram != null && ram > 0) chips.add('RAM $ram MB');
    final lat = session.apexLatencyMs;
    if (lat != null) chips.add('$lat ms');
    return chips;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
    final chips = _collectChips();
    final gfxProfile = GfxProfile.fromLabel(session.gfxProfile);
    final hasChips = chips.isNotEmpty || gfxProfile != null;
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
          color: AppColors.apexGreen.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InlineBadge(
                label: s.homeLastGameBadge,
                color: AppColors.apexGreen,
              ),
              _StatusChip(status: session.launchStatus),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _IconSlot(bytes: iconBytes, size: 44),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.gameName,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.relativeTime(session.launchedAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textGray,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasChips) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (gfxProfile != null)
                  _MetricChip(
                    label: 'GFX: ${s.gfxProfileLabel(gfxProfile)}',
                    accentColor: gfxProfile.accentColor,
                    icon: gfxProfile.icon,
                  ),
                ...chips.map((label) => _MetricChip(label: label)),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () => context.push('/game-detail/${session.gameId}'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.apexGreen,
                side: BorderSide(
                  color: AppColors.apexGreen.withValues(alpha: 0.50),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                s.homeViewDetails,
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
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.04, end: 0, duration: 400.ms);
  }
}

// ── Icon slot — cache-aware, zero MethodChannel ──────────────────────────────
// Renders Image.memory immediately when bytes are available, or a static
// premium placeholder when not. Never triggers a platform channel call.

class _IconSlot extends StatelessWidget {
  final Uint8List? bytes;
  final double size;

  const _IconSlot({required this.bytes, required this.size});

  @override
  Widget build(BuildContext context) {
    if (bytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Image.memory(
          bytes!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        ),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.apexGreen.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(
          color: AppColors.apexGreen.withValues(alpha: 0.25),
        ),
      ),
      child: Icon(
        Icons.videogame_asset_rounded,
        color: AppColors.apexGreen.withValues(alpha: 0.65),
        size: size * 0.5,
      ),
    );
  }
}

// ── Inline badge ─────────────────────────────────────────────────────────────

class _InlineBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _InlineBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

// ── Status chip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
    final Color color;
    final String label;

    if (status == 'success') {
      color = AppColors.apexGreen;
      label = s.statusOpened;
    } else if (status == 'failed') {
      color = AppColors.energyOrange;
      label = s.statusFailed;
    } else {
      color = AppColors.cyberBlue;
      label = s.statusAttempted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Metric chip — subtle info pill from SessionRecord ────────────────────────

class _MetricChip extends StatelessWidget {
  final String label;
  final Color? accentColor;
  final IconData? icon;

  const _MetricChip({
    required this.label,
    this.accentColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color != null
            ? color.withValues(alpha: 0.10)
            : AppColors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color != null
              ? color.withValues(alpha: 0.30)
              : AppColors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 11,
              color: color ?? AppColors.textGray,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color != null
                  ? AppColors.white.withValues(alpha: 0.90)
                  : AppColors.textGray,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick stats row ───────────────────────────────────────────────────────────

class _QuickStatsRow extends StatelessWidget {
  final int gameCount;
  final int sessionCount;
  final bool loading;

  const _QuickStatsRow({
    required this.gameCount,
    required this.sessionCount,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            value: loading ? '—' : '$gameCount',
            label: s.homeGamesLabel,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatChip(
            value: loading ? '—' : '$sessionCount',
            label: s.homeSessionsLabel,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms);
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;

  const _StatChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textGray,
                  letterSpacing: 1.2,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Empty hint ────────────────────────────────────────────────────────────────

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
    return Text(
      s.homeEmptyHint,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textGray.withValues(alpha: 0.6),
          ),
      textAlign: TextAlign.center,
    ).animate().fadeIn(delay: 400.ms, duration: 500.ms);
  }
}
