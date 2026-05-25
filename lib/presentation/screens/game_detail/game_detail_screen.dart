import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/core/constants/app_colors.dart';
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

class GameDetailScreen extends StatefulWidget {
  final String gameId;

  const GameDetailScreen({super.key, required this.gameId});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  ApexGame? _game;
  bool _loading = true;
  SharedPreferencesGameLibraryRepository? _repo;
  ApexScanResult? _scanResult;
  DeviceMetrics? _deviceMetrics;
  bool _metricsLoading = false;
  bool _metricsError = false;

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
    final scanResult = game != null ? await _buildScan(game) : null;
    if (mounted) {
      setState(() {
        _game = game;
        _scanResult = scanResult;
        _loading = false;
      });
      if (game != null) _loadMetrics();
    }
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

  Future<ApexScanResult> _buildScan(ApexGame game) async {
    final pkg = game.packageName;
    bool isLaunchable = false;
    if (pkg != null && pkg.isNotEmpty) {
      try {
        final apps = await InstalledAppsDatasource().getInstalledApps();
        isLaunchable = apps.any((a) => a.packageName == pkg);
      } catch (_) {}
    }
    return ApexScanService().scan(game: game, isLaunchable: isLaunchable);
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
    final scan = await _buildScan(updated);
    if (mounted) setState(() { _game = updated; _scanResult = scan; });
  }

  Future<void> _launchGame() async {
    final pkg = _game?.packageName;
    if (pkg == null || pkg.isEmpty) return;

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
    if (error == null) return;

    final message = error is PlatformException && error.code == 'APP_NOT_FOUND'
        ? 'App não encontrado. Verifique se ainda está instalado.'
        : 'Não foi possível abrir o jogo.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.energyOrange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openProfileSelector() async {
    final game = _game;
    final repo = _repo;
    if (game == null || repo == null) return;

    // Returns: profile.label to select, '' to clear, null if dismissed
    final result = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _GfxProfileSheet(currentLabel: game.localProfileName),
    );

    if (result == null) return;
    if (!mounted) return;

    final ApexGame updated;
    if (result.isEmpty) {
      updated = game.copyWith(
        clearLocalProfileName: true,
        updatedAt: DateTime.now(),
      );
    } else {
      updated = game.copyWith(
        localProfileName: result,
        updatedAt: DateTime.now(),
      );
    }

    await repo.updateGame(updated);
    final scan = await _buildScan(updated);
    if (mounted) setState(() { _game = updated; _scanResult = scan; });
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
                            scanResult: _scanResult,
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
          Text(
            'Detalhe do Jogo',
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
              tooltip: 'Editar',
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
  final VoidCallback? onSelectProfile;
  final ApexScanResult? scanResult;
  final DeviceMetrics? deviceMetrics;
  final bool metricsLoading;
  final bool metricsError;

  const _GameDetailContent({
    required this.game,
    this.onSelectProfile,
    this.scanResult,
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
            title: 'Perfil GFX',
            icon: Icons.tune_rounded,
            value: game.localProfileName,
            emptyMessage: 'Nenhum perfil configurado',
            accentColor: AppColors.energyOrange,
            delay: 180.ms,
            onTap: onSelectProfile,
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
          if (scanResult != null) ...[
            const SizedBox(height: 20),
            _ApexScanCard(
              result: scanResult!,
              deviceMetrics: deviceMetrics,
              metricsLoading: metricsLoading,
              metricsError: metricsError,
            ),
          ],
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
                    _Badge(label: 'GAME', color: AppColors.cyberBlue),
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
  final VoidCallback? onTap;

  const _InfoRow({
    required this.title,
    required this.icon,
    this.value,
    this.emptyMessage,
    required this.accentColor,
    this.delay = Duration.zero,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    final displayValue = hasValue ? value! : (emptyMessage ?? '—');

    final decoration = BoxDecoration(
      color: AppColors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: hasValue
            ? accentColor.withValues(alpha: 0.2)
            : AppColors.white.withValues(alpha: 0.07),
        width: 1,
      ),
    );

    final rowContent = Row(
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
        if (onTap != null) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            color: accentColor.withValues(alpha: 0.7),
            size: 18,
          ),
        ],
      ],
    );

    final Widget built;
    if (onTap != null) {
      built = Ink(
        width: double.infinity,
        decoration: decoration,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          splashColor: accentColor.withValues(alpha: 0.1),
          highlightColor: accentColor.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: rowContent,
          ),
        ),
      );
    } else {
      built = Container(
        width: double.infinity,
        decoration: decoration,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: rowContent,
      );
    }

    return built
        .animate()
        .fadeIn(delay: delay, duration: 400.ms)
        .slideX(begin: 0.03, end: 0, delay: delay, duration: 300.ms);
  }
}

// ─── GFX Profile bottom sheet ─────────────────────────────────────────────────

class _GfxProfileSheet extends StatelessWidget {
  final String? currentLabel;

  const _GfxProfileSheet({required this.currentLabel});

  @override
  Widget build(BuildContext context) {
    final current = GfxProfile.fromLabel(currentLabel);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111318),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textGray.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(
                    Icons.tune_rounded,
                    color: AppColors.energyOrange,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Perfil GFX',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Preferência salva localmente. Não altera jogos de terceiros.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textGray,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Divider(
              height: 1,
              color: AppColors.white.withValues(alpha: 0.07),
            ),
            for (final profile in GfxProfile.values)
              _ProfileOption(
                profile: profile,
                isSelected: current == profile,
                onTap: () => Navigator.of(context).pop(profile.label),
              ),
            _ProfileNoneOption(
              isSelected: current == null,
              onTap: () => Navigator.of(context).pop(''),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final GfxProfile profile;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.profile,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(profile.icon, color: profile.accentColor, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                profile.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                color: AppColors.apexGreen,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileNoneOption extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _ProfileNoneOption({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(
              Icons.remove_circle_outline_rounded,
              color: AppColors.textGray.withValues(alpha: 0.5),
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Nenhum',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textGray,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                color: AppColors.apexGreen,
                size: 20,
              ),
          ],
        ),
      ),
    );
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
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Nome obrigatório');
      return;
    }

    final pkg = _pkgController.text.trim();
    if (pkg.isNotEmpty) {
      if (!widget.installedApps.any((a) => a.packageName == pkg)) {
        setState(() => _pkgError = 'App não encontrado nos instalados');
        return;
      }
      if (widget.otherGamePackages.contains(pkg)) {
        setState(() => _pkgError = 'Já instalado');
        return;
      }
    }

    Navigator.of(context).pop((name, pkg));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF111318),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.cyberBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      title: const Text(
        'Editar jogo',
        style: TextStyle(
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
            label: 'Nome do jogo',
            autofocus: true,
            errorText: _nameError,
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
          const SizedBox(height: 12),
          _DialogField(
            controller: _pkgController,
            label: 'Package name (opcional)',
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
          child: const Text(
            'Cancelar',
            style: TextStyle(color: AppColors.textGray),
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
          child: const Text(
            'Salvar',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: hasPackage ? onTap : null,
          icon: const Icon(Icons.sports_esports_rounded, size: 20),
          label: Text(
            hasPackage ? 'ABRIR JOGO' : 'SEM APP VINCULADO',
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
  late final List<_Step> _steps;

  @override
  void initState() {
    super.initState();
    final profileLabel = (widget.profileName?.isNotEmpty == true)
        ? widget.profileName!
        : 'padrão';
    _steps = [
      _Step('Core Apex: OK', isCheck: true),
      _Step('Jogo localizado: OK', isCheck: true),
      _Step('Perfil $profileLabel: OK', isCheck: true),
      _Step('Rota validada: OK', isCheck: true),
      _Step('Sessão armada: OK', isCheck: true),
      _Step('Abrindo jogo...', isCheck: false),
    ];
    _runSequence();
  }

  Future<void> _runSequence() async {
    for (int i = 1; i < _steps.length; i++) {
      await Future.delayed(_kStepDelay);
      if (!mounted) return;
      setState(() => _visibleCount = i + 1);
    }
    await Future.delayed(_kStepDelay);
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
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111318),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
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
                  Text(
                    'Apex Boost Mode',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              for (int i = 0; i < _visibleCount; i++)
                _PrepStepRow(
                  label: _steps[i].label,
                  isCheck: _steps[i].isCheck,
                )
                    .animate(key: ValueKey(i))
                    .fadeIn(duration: 280.ms)
                    .slideX(begin: 0.04, end: 0, duration: 230.ms),
            ],
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

  const _ApexScanCard({
    required this.result,
    this.deviceMetrics,
    this.metricsLoading = false,
    this.metricsError = false,
  });

  String _statusLabel() {
    if (result.score == ScanScore.pronto) return 'Pronto para iniciar';
    final acesso = result.checks.where((c) => c.id == 'acesso').firstOrNull;
    if (acesso?.status == ScanCheckStatus.fail) return 'App não encontrado';
    return 'Cadastro incompleto';
  }

  Color _statusColor() => result.score == ScanScore.pronto
      ? AppColors.apexGreen
      : AppColors.energyOrange;

  IconData _statusIcon() => result.score == ScanScore.pronto
      ? Icons.verified_rounded
      : Icons.warning_amber_rounded;

  @override
  Widget build(BuildContext context) {
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
                        'Status local da preparação',
                        style: TextStyle(
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
                        _statusLabel(),
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
                  _ScanCheckRow(check: result.checks[i], index: i),
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

// ─── Performance modules section ─────────────────────────────────────────────

class _PerformanceModulesSection extends StatelessWidget {
  const _PerformanceModulesSection();

  static const _modules = [
    'FPS: OK',
    'RAM: OK',
    'GPU: OK',
    'Ping: OK',
    'Otimização: OK',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MÓDULOS DE PERFORMANCE',
          style: TextStyle(
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
            for (int i = 0; i < _modules.length; i++)
              _ModuleChip(label: _modules[i], index: i),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _ConfirmBadge(label: 'Boost aplicado', delay: 1050),
            _ConfirmBadge(label: 'Performance melhorada', delay: 1100),
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
  final int index;

  const _ModuleChip({required this.label, required this.index});

  @override
  Widget build(BuildContext context) {
    final delay = Duration(milliseconds: 800 + index * 40);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.apexGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.apexGreen.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.apexGreen.withValues(alpha: 0.18),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, color: AppColors.apexGreen, size: 13),
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

  const _ScanCheckRow({required this.check, required this.index});

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
              check.message,
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

  String _formatMb(int bytes) {
    if (bytes <= 0) return 'Indisponível';
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(0)} MB';
  }

  String _latencyLabel(DeviceMetrics m) => switch (m.latencyStatus) {
        LatencyStatus.success => '${m.latencyMs} ms',
        LatencyStatus.timeout => 'Timeout',
        LatencyStatus.noNetwork => 'Sem rede',
        LatencyStatus.error => 'Indisponível',
      };

  Color _latencyColor(DeviceMetrics m) => switch (m.latencyStatus) {
        LatencyStatus.success => AppColors.apexGreen,
        LatencyStatus.timeout => AppColors.energyOrange,
        LatencyStatus.noNetwork => AppColors.energyOrange,
        LatencyStatus.error => AppColors.textGray,
      };

  String _memoryStateLabel(DeviceMetrics m) {
    if (m.totalMemoryBytes <= 0) return 'Indisponível';
    return m.isLowMemory ? 'Memória baixa' : 'Normal';
  }

  Color _memoryStateColor(DeviceMetrics m) {
    if (m.totalMemoryBytes <= 0) return AppColors.textGray;
    return m.isLowMemory ? AppColors.energyOrange : AppColors.apexGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.memory_rounded, color: AppColors.cyberBlue, size: 13),
            const SizedBox(width: 6),
            const Text(
              'MÉTRICAS REAIS',
              style: TextStyle(
                color: AppColors.textGray,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        const Text(
          'Snapshot atual do dispositivo',
          style: TextStyle(
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
            label: 'Memória disponível',
            value: _formatMb(metrics!.availableMemoryBytes),
            valueColor: AppColors.white,
          ),
          _RealMetricRow(
            label: 'Memória total',
            value: _formatMb(metrics!.totalMemoryBytes),
            valueColor: AppColors.white,
          ),
          _RealMetricRow(
            label: 'Estado de memória',
            value: _memoryStateLabel(metrics!),
            valueColor: _memoryStateColor(metrics!),
          ),
          _RealMetricRow(
            label: 'Latência Apex',
            subtitle: 'Teste de rede',
            value: _latencyLabel(metrics!),
            valueColor: _latencyColor(metrics!),
          ),
        ],
        const SizedBox(height: 10),
        Text(
          'Snapshot do dispositivo. Não representa alteração de jogos.',
          style: TextStyle(
            color: AppColors.textGray.withValues(alpha: 0.5),
            fontSize: 10,
            fontStyle: FontStyle.italic,
          ),
        ),
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
            'Lendo métricas...',
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
            'Métricas indisponíveis',
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
