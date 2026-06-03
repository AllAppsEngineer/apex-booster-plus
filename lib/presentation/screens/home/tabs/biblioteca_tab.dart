import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/core/constants/app_colors.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/core/i18n/app_strings.dart';
import 'package:apex_booster_plus/data/datasources/installed_apps_datasource.dart';
import 'package:apex_booster_plus/data/repositories/shared_preferences_game_library_repository.dart';
import 'package:apex_booster_plus/domain/entities/apex_game.dart';
import 'package:apex_booster_plus/domain/entities/installed_app.dart';
import 'package:apex_booster_plus/presentation/controllers/game_library_controller.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_background.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_badge.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_feature_card.dart';
import 'package:apex_booster_plus/presentation/widgets/app_icon_widget.dart';
import 'package:apex_booster_plus/presentation/widgets/app_picker_sheet.dart';

/// Returns the set of packageNames from [apps] that are not verified as games
/// (isGame == false). Used to drive the "Não verificado" badge on library cards.
Set<String> buildNotVerifiedSet(List<InstalledApp> apps) =>
    apps.where((a) => !a.isGame).map((a) => a.packageName).toSet();

class BibliotecaTab extends StatefulWidget {
  final bool isActive;
  const BibliotecaTab({super.key, required this.isActive});

  @override
  State<BibliotecaTab> createState() => _BibliotecaTabState();
}

class _BibliotecaTabState extends State<BibliotecaTab> {
  late GameLibraryController _controller;
  bool _gamesLoaded = false;
  bool _installedAppsLoaded = false;
  Set<String> _notVerifiedPkgs = const {};

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  @override
  void didUpdateWidget(BibliotecaTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive && !_installedAppsLoaded) {
      _loadInstalledApps();
    }
  }

  Future<void> _loadGames() async {
    final prefs = await SharedPreferences.getInstance();
    _controller = GameLibraryController(
      SharedPreferencesGameLibraryRepository(prefs),
    );
    await _controller.loadGames();
    if (mounted) setState(() => _gamesLoaded = true);
  }

  Future<void> _loadInstalledApps() async {
    try {
      final apps = await InstalledAppsDatasource().getInstalledApps();
      if (mounted) {
        setState(() {
          _notVerifiedPkgs = buildNotVerifiedSet(apps);
          _installedAppsLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _installedAppsLoaded = true);
    }
  }

  static String _normalize(String s) =>
      s.toLowerCase().trim().replaceAll(RegExp(r'[^a-z0-9]'), '');

  Future<InstalledApp?> _tryAutoLink(String typedName) async {
    final normalized = _normalize(typedName);
    if (normalized.isEmpty) return null;

    List<InstalledApp> apps;
    try {
      apps = await InstalledAppsDatasource().getInstalledApps();
    } catch (_) {
      return null;
    }

    final matches = apps
        .where((a) => _normalize(a.appName) == normalized)
        .toList();

    if (matches.isEmpty) return null;
    if (matches.length == 1) return matches.first;

    if (!mounted) return null;
    final chosen = await showModalBottomSheet<InstalledApp?>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.55,
        child: _AppMatchSheet(matches: matches),
      ),
    );
    return chosen;
  }

  Future<void> _openAddGameDialog({
    String initialName = '',
    String initialPackageName = '',
  }) async {
    List<InstalledApp> installedApps;
    try {
      installedApps = await InstalledAppsDatasource().getInstalledApps();
    } catch (_) {
      installedApps = const [];
    }

    if (!mounted) return;

    final result = await showModalBottomSheet<(String, String?)?>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.85,
        child: _AddGameSheet(
          initialName: initialName,
          initialPackageName: initialPackageName,
          installedApps: installedApps,
        ),
      ),
    );

    if (result == null) return;
    if (!mounted) return;

    final (name, rawPkg) = result;
    final pkg = rawPkg?.trim();
    String? resolvedPkg = (pkg == null || pkg.isEmpty) ? null : pkg;

    if (resolvedPkg == null) {
      final matched = await _tryAutoLink(name);
      if (matched != null) resolvedPkg = matched.packageName;
    }

    if (!mounted) return;

    final s = AppStrings(languageNotifier.value);

    if (resolvedPkg == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.librarySnackNoApp)),
      );
      return;
    }

    final existingGames = _controller.state.games;

    if (existingGames.any((g) => g.packageName == resolvedPkg)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.libraryAlreadyAdded)),
      );
      return;
    }

    final normalizedInput = _normalize(name);
    if (existingGames.any((g) => _normalize(g.name) == normalizedInput)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.libraryAlreadyAdded)),
      );
      return;
    }

    final now = DateTime.now();
    final game = ApexGame(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      packageName: resolvedPkg,
      createdAt: now,
      updatedAt: now,
    );
    await _controller.addGame(game);
    if (mounted) setState(() {});
  }

  Future<void> _openPickerSheet() async {
    final result = await showModalBottomSheet<AppPickerResult?>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.82,
        child: const AppPickerSheet(),
      ),
    );

    if (result == null || !mounted) return;

    if (result is AppPickerUseManual) {
      await _openAddGameDialog();
      return;
    }
    if (result is AppPickerSelected) {
      if (!result.app.isGame) {
        if (!mounted) return;
        final confirmed = await showDialog<bool>(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.75),
          builder: (_) => const _NotVerifiedGameDialog(),
        );
        if (confirmed != true) return;
        if (!mounted) return;
      }
      await _openAddGameDialog(
        initialName: result.app.appName,
        initialPackageName: result.app.packageName,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_gamesLoaded) {
      return const ApexBackground(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.cyberBlue),
        ),
      );
    }

    return ListenableBuilder(
      listenable: languageNotifier,
      builder: (context, _) {
        final s = AppStrings(languageNotifier.value);
        final state = _controller.state;

        return ApexBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BibliotecaHeader(),
                  const SizedBox(height: 28),
                  if (state.games.isEmpty)
                    _BibliotecaEmptyCard()
                  else
                    _GameList(
                      games: state.games,
                      notVerifiedPkgs: _notVerifiedPkgs,
                      onTap: (id) async {
                        await context.push('/game-detail/$id');
                        if (!mounted) return;
                        await _controller.loadGames();
                        if (mounted) setState(() {});
                      },
                      onToggleFavorite: (id) async {
                        await _controller.toggleFavorite(id);
                        if (mounted) setState(() {});
                      },
                      onRemove: (id, name) async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          barrierColor: Colors.black.withValues(alpha: 0.75),
                          builder: (_) => _RemoveGameDialog(gameName: name),
                        );
                        if (confirmed != true) return;
                        if (!mounted) return;
                        await _controller.removeGame(id);
                        if (mounted) setState(() {});
                      },
                    ),
                  const SizedBox(height: 16),
                  ApexFeatureCard(
                    badge: s.libraryFavBadge,
                    title: s.libraryFavTitle,
                    subtitle: s.libraryFavSubtitle,
                    accentColor: AppColors.cyberBlue,
                    delay: 100.ms,
                  ),
                  const SizedBox(height: 12),
                  ApexFeatureCard(
                    badge: s.libraryGfxBadge,
                    title: s.libraryLocalProfilesTitle,
                    subtitle: s.libraryLocalProfilesSubtitle,
                    accentColor: AppColors.energyOrange,
                    delay: 200.ms,
                  ),
                  const SizedBox(height: 32),
                  _BibliotecaCTA(onPressed: _openAddGameDialog),
                  const SizedBox(height: 10),
                  _AppPickerButton(onPressed: _openPickerSheet),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _BibliotecaHeader extends StatelessWidget {
  const _BibliotecaHeader();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.libraryTitle,
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
          s.librarySubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textGray,
              ),
        ).animate().fadeIn(delay: 100.ms, duration: 500.ms),
      ],
    );
  }
}

// ─── Empty card ───────────────────────────────────────────────────────────────

class _BibliotecaEmptyCard extends StatelessWidget {
  const _BibliotecaEmptyCard();

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
            AppColors.cyberBlue.withValues(alpha: 0.12),
            AppColors.white.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cyberBlue.withValues(alpha: 0.25),
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
              ApexBadge(label: s.homeLibraryBadge, color: AppColors.cyberBlue),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.cyberBlue.withValues(alpha: 0.45),
                size: 14,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            s.libraryEmptyTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            s.libraryEmptyDesc,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textGray,
                  fontSize: 13,
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

// ─── Game list ────────────────────────────────────────────────────────────────

class _GameList extends StatelessWidget {
  final List<ApexGame> games;
  final Set<String> notVerifiedPkgs;
  final void Function(String id) onTap;
  final void Function(String id) onToggleFavorite;
  final void Function(String id, String name) onRemove;

  const _GameList({
    required this.games,
    required this.notVerifiedPkgs,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.libraryGameCount(games.length),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textGray,
                fontSize: 12,
              ),
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 10),
        ...games.asMap().entries.map((entry) {
          final index = entry.key;
          final game = entry.value;
          final pkg = game.packageName;
          final isNotVerified =
              pkg != null && notVerifiedPkgs.contains(pkg);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _GameCard(
              game: game,
              isNotVerified: isNotVerified,
              delay: (index * 60).ms,
              onTap: () => onTap(game.id),
              onToggleFavorite: () => onToggleFavorite(game.id),
              onRemove: () => onRemove(game.id, game.name),
            ),
          );
        }),
      ],
    );
  }
}

class _GameCard extends StatelessWidget {
  final ApexGame game;
  final bool isNotVerified;
  final Duration delay;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onRemove;

  const _GameCard({
    required this.game,
    required this.isNotVerified,
    required this.delay,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.cyberBlue.withValues(alpha: 0.10),
            AppColors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: game.isFavorite
              ? AppColors.apexGreen.withValues(alpha: 0.35)
              : AppColors.cyberBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  AppIconWidget(packageName: game.packageName, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          game.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isNotVerified) ...[
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.energyOrange
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.energyOrange
                                    .withValues(alpha: 0.35),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              AppStrings(languageNotifier.value).libraryBadgeNotVerified,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onToggleFavorite,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                game.isFavorite
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color: game.isFavorite
                    ? AppColors.apexGreen
                    : AppColors.textGray.withValues(alpha: 0.6),
                size: 20,
              ),
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.textGray.withValues(alpha: 0.5),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: delay, duration: 350.ms)
        .slideX(begin: 0.04, end: 0, delay: delay, duration: 300.ms);
  }
}

// ─── Add game sheet ───────────────────────────────────────────────────────────

class _AddGameSheet extends StatefulWidget {
  final String initialName;
  final String initialPackageName;
  final List<InstalledApp> installedApps;

  const _AddGameSheet({
    this.initialName = '',
    this.initialPackageName = '',
    this.installedApps = const [],
  });

  @override
  State<_AddGameSheet> createState() => _AddGameSheetState();
}

class _AddGameSheetState extends State<_AddGameSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _pkgController;
  String? _nameError;
  String? _pkgError;
  List<InstalledApp> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _pkgController = TextEditingController(text: widget.initialPackageName);
    _nameController.addListener(_updateSuggestions);
    _pkgController.addListener(_updateSuggestions);
    if (widget.initialName.isNotEmpty) _updateSuggestions();
  }

  void _updateSuggestions() {
    final query = _nameController.text.trim();
    final pkg = _pkgController.text.trim();

    if (pkg.isNotEmpty || query.isEmpty) {
      setState(() {
        _nameError = null;
        _pkgError = null;
        _suggestions = const [];
      });
      return;
    }

    final q = query.toLowerCase();

    int rankApp(InstalledApp a) {
      final name = a.appName.toLowerCase();
      final p = a.packageName.toLowerCase();
      if (name.startsWith(q)) return 0;
      if (name.contains(q)) return 1;
      if (p.startsWith(q)) return 2;
      return 3;
    }

    final seen = <String>{};
    final ranked = widget.installedApps
        .where((a) {
          final name = a.appName.toLowerCase();
          final p = a.packageName.toLowerCase();
          return name.contains(q) || p.contains(q);
        })
        .where((a) => seen.add(a.packageName))
        .toList()
      ..sort((a, b) {
        final diff = rankApp(a).compareTo(rankApp(b));
        return diff != 0
            ? diff
            : a.appName.toLowerCase().compareTo(b.appName.toLowerCase());
      });

    setState(() {
      _nameError = null;
      _pkgError = null;
      _suggestions = ranked;
    });
  }

  void _selectSuggestion(InstalledApp app) {
    _nameController.removeListener(_updateSuggestions);
    _pkgController.removeListener(_updateSuggestions);

    _nameController.text = app.appName;
    _nameController.selection = TextSelection.fromPosition(
      TextPosition(offset: _nameController.text.length),
    );
    _pkgController.text = app.packageName;

    _nameController.addListener(_updateSuggestions);
    _pkgController.addListener(_updateSuggestions);

    setState(() {
      _nameError = null;
      _pkgError = null;
      _suggestions = const [];
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateSuggestions);
    _pkgController.removeListener(_updateSuggestions);
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
    if (pkg.isNotEmpty &&
        !widget.installedApps.any((a) => a.packageName == pkg)) {
      setState(() => _pkgError = s.libraryValidationAppNotFound);
      return;
    }
    Navigator.of(context).pop((name, pkg.isEmpty ? null : pkg));
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
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textGray.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Builder(builder: (ctx) {
                  final s = AppStrings(languageNotifier.value);
                  return Text(
                    s.libraryAddGameSheetTitle,
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Builder(builder: (_) {
                  final s = AppStrings(languageNotifier.value);
                  return _SheetField(
                    controller: _nameController,
                    label: s.libraryFieldGameName,
                    autofocus: widget.initialName.isEmpty,
                    errorText: _nameError,
                  );
                }),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Builder(builder: (_) {
                  final s = AppStrings(languageNotifier.value);
                  return _SheetField(
                    controller: _pkgController,
                    label: s.libraryFieldPackageName,
                    errorText: _pkgError,
                  );
                }),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _suggestions.isEmpty
                    ? const SizedBox.shrink()
                    : Container(
                        margin: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.cyberBlue.withValues(alpha: 0.15),
                          ),
                        ),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: _suggestions.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: AppColors.white.withValues(alpha: 0.05),
                          ),
                          itemBuilder: (_, i) => _SuggestionItem(
                            app: _suggestions[i],
                            onTap: () => _selectSuggestion(_suggestions[i]),
                          ),
                        ),
                      ),
              ),
              Divider(
                height: 1,
                color: AppColors.white.withValues(alpha: 0.07),
              ),
              Builder(builder: (ctx) {
                final s = AppStrings(languageNotifier.value);
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(null),
                        child: Text(
                          s.libraryCancelLower,
                          style: const TextStyle(color: AppColors.textGray),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cyberBlue,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          elevation: 0,
                        ),
                        child: Text(
                          s.libraryActionAddLower,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sheet field ──────────────────────────────────────────────────────────────

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool autofocus;
  final String? errorText;

  const _SheetField({
    required this.controller,
    required this.label,
    this.autofocus = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      style: const TextStyle(color: AppColors.white),
      cursorColor: AppColors.cyberBlue,
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

// ─── Suggestion item ──────────────────────────────────────────────────────────

class _SuggestionItem extends StatelessWidget {
  final InstalledApp app;
  final VoidCallback onTap;

  const _SuggestionItem({required this.app, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            AppIconWidget(packageName: app.packageName, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    app.appName,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    app.packageName,
                    style: TextStyle(
                      color: AppColors.textGray.withValues(alpha: 0.6),
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.north_west_rounded,
              color: AppColors.cyberBlue.withValues(alpha: 0.4),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Remove game dialog ───────────────────────────────────────────────────────

class _RemoveGameDialog extends StatelessWidget {
  final String gameName;

  const _RemoveGameDialog({required this.gameName});

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
        s.libraryRemoveTitle,
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      content: Text(
        s.libraryRemoveConfirm(gameName),
        style: const TextStyle(
          color: AppColors.textGray,
          fontSize: 14,
          height: 1.5,
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            s.libraryCancelLower,
            style: const TextStyle(color: AppColors.textGray),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.energyOrange,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 0,
          ),
          child: Text(
            s.libraryActionRemove,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

// ─── Not verified game dialog ─────────────────────────────────────────────────

class _NotVerifiedGameDialog extends StatelessWidget {
  const _NotVerifiedGameDialog();

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
        s.libraryNotVerifiedTitle,
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      content: Text(
        s.libraryNotVerifiedContent,
        style: const TextStyle(
          color: AppColors.textGray,
          fontSize: 14,
          height: 1.5,
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            s.libraryCancelLower,
            style: const TextStyle(color: AppColors.textGray),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
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
            s.libraryActionAddAnyway,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

// ─── CTAs ─────────────────────────────────────────────────────────────────────

class _BibliotecaCTA extends StatelessWidget {
  final VoidCallback onPressed;

  const _BibliotecaCTA({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyberBlue,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Text(
          AppStrings(languageNotifier.value).libraryAddGame,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.5,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 500.ms);
  }
}

class _AppPickerButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AppPickerButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.apps_rounded, size: 16),
        label: Text(
          AppStrings(languageNotifier.value).libraryChooseInstalled,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 1.2,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.cyberBlue,
          side: BorderSide(color: AppColors.cyberBlue.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 500.ms);
  }
}

// ─── App match sheet (multiple exact matches for auto-link) ───────────────────

class _AppMatchSheet extends StatelessWidget {
  final List<InstalledApp> matches;

  const _AppMatchSheet({required this.matches});

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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textGray.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: AppColors.cyberBlue,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        s.libraryMultiMatchTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.libraryMultiMatchSubtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textGray,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.white.withValues(alpha: 0.07)),
            Expanded(
              child: ListView(
                children: [
                  for (final app in matches)
                    _MatchItem(
                      app: app,
                      onTap: () => Navigator.of(context).pop(app),
                    ),
                  _ManualItem(onTap: () => Navigator.of(context).pop(null)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchItem extends StatelessWidget {
  final InstalledApp app;
  final VoidCallback onTap;

  const _MatchItem({required this.app, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            AppIconWidget(packageName: app.packageName, size: 36),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.appName,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    app.packageName,
                    style: TextStyle(
                      color: AppColors.textGray.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.cyberBlue.withValues(alpha: 0.5),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _ManualItem extends StatelessWidget {
  final VoidCallback onTap;

  const _ManualItem({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.textGray.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.textGray.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                Icons.edit_outlined,
                color: AppColors.textGray.withValues(alpha: 0.6),
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                AppStrings(languageNotifier.value).libraryContinueManual,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textGray,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
