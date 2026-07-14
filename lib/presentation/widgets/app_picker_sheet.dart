import 'package:flutter/material.dart';
import 'package:apex_booster_plus/core/constants/app_colors.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/core/i18n/app_strings.dart';
import 'package:apex_booster_plus/data/datasources/installed_apps_datasource.dart';
import 'package:apex_booster_plus/domain/entities/installed_app.dart';
import 'package:apex_booster_plus/presentation/widgets/app_icon_widget.dart';

List<InstalledApp> applyPickerFilter(
  List<InstalledApp> apps,
  String query,
  bool onlyGames,
) {
  Iterable<InstalledApp> result = apps;
  if (onlyGames) result = result.where((a) => a.isGame);
  if (query.isNotEmpty) {
    final q = query.toLowerCase();
    result = result.where(
      (a) =>
          a.appName.toLowerCase().contains(q) ||
          a.packageName.toLowerCase().contains(q),
    );
  }
  return result.toList();
}

sealed class AppPickerResult {
  const AppPickerResult();
}

final class AppPickerSelected extends AppPickerResult {
  final InstalledApp app;
  AppPickerSelected(this.app);
}

final class AppPickerUseManual extends AppPickerResult {
  const AppPickerUseManual();
}

class AppPickerSheet extends StatefulWidget {
  const AppPickerSheet({super.key});

  @override
  State<AppPickerSheet> createState() => _AppPickerSheetState();
}

class _AppPickerSheetState extends State<AppPickerSheet> {
  final _datasource = InstalledAppsDatasource();
  final _searchController = TextEditingController();

  List<InstalledApp> _allApps = [];
  List<InstalledApp> _filtered = [];
  bool _loading = true;
  bool _failed = false;
  bool _hasText = false;
  bool _onlyGames = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final apps = await _datasource.getInstalledApps();
      if (!mounted) return;
      setState(() {
        _allApps = List.of(apps);
        _filtered = applyPickerFilter(apps, _searchController.text.toLowerCase().trim(), _onlyGames);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  Future<void> _retry() async {
    setState(() {
      _failed = false;
      _loading = true;
    });
    await _load();
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase().trim();
    setState(() {
      _hasText = _searchController.text.isNotEmpty;
      _filtered = applyPickerFilter(_allApps, q, _onlyGames);
    });
  }

  void _onToggleFilter(bool value) {
    final q = _searchController.text.toLowerCase().trim();
    setState(() {
      _onlyGames = value;
      _filtered = applyPickerFilter(_allApps, q, value);
    });
  }

  void _select(InstalledApp app) =>
      Navigator.of(context).pop(AppPickerSelected(app));

  void _useManual() =>
      Navigator.of(context).pop(const AppPickerUseManual());

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: languageNotifier,
      builder: (context, _) {
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
                _buildHandle(),
                _buildHeader(context, s),
                if (!_loading && !_failed && _allApps.isNotEmpty) _buildSearch(s),
                if (!_loading && !_failed && _allApps.isNotEmpty) _buildFilterToggle(s),
                Divider(height: 1, color: AppColors.white.withValues(alpha: 0.07)),
                Expanded(child: _buildBody(context, s)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.textGray.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppStrings s) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.apps_rounded,
                color: AppColors.cyberBlue,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                s.pickerTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            s.pickerSubtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textGray,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSearch(AppStrings s) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: AppColors.white, fontSize: 14),
        cursorColor: AppColors.cyberBlue,
        decoration: InputDecoration(
          hintText: s.pickerSearchHint,
          hintStyle: const TextStyle(color: AppColors.textGray, fontSize: 14),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textGray,
            size: 18,
          ),
          suffixIcon: _hasText
              ? IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                    color: AppColors.textGray,
                    size: 16,
                  ),
                  onPressed: _searchController.clear,
                  tooltip: s.pickerClearSearch,
                )
              : null,
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
          filled: true,
          fillColor: AppColors.white.withValues(alpha: 0.05),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildFilterToggle(AppStrings s) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 16, 8),
      child: Row(
        children: [
          Icon(
            Icons.sports_esports_rounded,
            color: _onlyGames ? AppColors.apexGreen : AppColors.textGray,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              s.libraryToggleVerified,
              style: TextStyle(
                color: _onlyGames ? AppColors.apexGreen : AppColors.textGray,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: _onlyGames,
            onChanged: _onToggleFilter,
            activeThumbColor: AppColors.apexGreen,
            activeTrackColor: AppColors.apexGreen.withValues(alpha: 0.3),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            trackOutlineColor: WidgetStatePropertyAll(
              AppColors.textGray.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppStrings s) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.cyberBlue,
          strokeWidth: 2,
        ),
      );
    }
    if (_failed) {
      return _PickerErrorState(s: s, onManual: _useManual, onRetry: _retry);
    }
    if (_filtered.isEmpty) {
      final query = _searchController.text.trim();
      if (query.isNotEmpty) {
        return _EmptySearchState(s: s, query: query, onManual: _useManual);
      }
      if (_onlyGames) {
        return _NoGamesState(s: s, onManual: _useManual);
      }
      return _EmptyAppsState(s: s, onManual: _useManual);
    }
    return ListView.separated(
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        indent: 20,
        endIndent: 20,
        color: AppColors.white.withValues(alpha: 0.05),
      ),
      itemBuilder: (_, index) {
        final app = _filtered[index];
        return _AppPickerItem(app: app, onTap: () => _select(app));
      },
    );
  }
}

// ─── List item ────────────────────────────────────────────────────────────────

class _AppPickerItem extends StatelessWidget {
  final InstalledApp app;
  final VoidCallback onTap;

  const _AppPickerItem({required this.app, required this.onTap});

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
            if (app.isGame)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.apexGreen.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppColors.apexGreen.withValues(alpha: 0.5),
                    width: 0.8,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  AppStrings(languageNotifier.value).libraryBadgeVerified,
                  style: const TextStyle(
                    color: AppColors.apexGreen,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
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

// ─── Empty search state ───────────────────────────────────────────────────────

class _EmptySearchState extends StatelessWidget {
  final AppStrings s;
  final String query;
  final VoidCallback onManual;

  const _EmptySearchState({
    required this.s,
    required this.query,
    required this.onManual,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            color: AppColors.textGray.withValues(alpha: 0.4),
            size: 44,
          ),
          const SizedBox(height: 16),
          Text(
            s.pickerNoResults(query),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            s.pickerNoResultsHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textGray,
                  fontSize: 12,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _ManualButton(s: s, onManual: onManual),
        ],
      ),
    );
  }
}

// ─── Empty apps state ─────────────────────────────────────────────────────────

class _EmptyAppsState extends StatelessWidget {
  final AppStrings s;
  final VoidCallback onManual;

  const _EmptyAppsState({required this.s, required this.onManual});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.apps_rounded,
            color: AppColors.textGray.withValues(alpha: 0.4),
            size: 44,
          ),
          const SizedBox(height: 16),
          Text(
            s.pickerNoApps,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            s.pickerNoAppsHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textGray,
                  fontSize: 12,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _ManualButton(s: s, onManual: onManual),
        ],
      ),
    );
  }
}

// ─── Error state ──────────────────────────────────────────────────────────────

class _PickerErrorState extends StatelessWidget {
  final AppStrings s;
  final VoidCallback onManual;
  final VoidCallback onRetry;

  const _PickerErrorState({
    required this.s,
    required this.onManual,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.textGray.withValues(alpha: 0.4),
            size: 44,
          ),
          const SizedBox(height: 16),
          Text(
            s.pickerLoadError,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textGray,
                  fontSize: 13,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyberBlue,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                elevation: 0,
              ),
              child: Text(
                s.pickerRetry,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ManualButton(s: s, onManual: onManual),
        ],
      ),
    );
  }
}

// ─── No games state ───────────────────────────────────────────────────────────

class _NoGamesState extends StatelessWidget {
  final AppStrings s;
  final VoidCallback onManual;

  const _NoGamesState({required this.s, required this.onManual});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_esports_rounded,
            color: AppColors.textGray.withValues(alpha: 0.4),
            size: 44,
          ),
          const SizedBox(height: 16),
          Text(
            s.pickerNoGames,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            s.pickerNoGamesHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textGray,
                  fontSize: 12,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _ManualButton(s: s, onManual: onManual),
        ],
      ),
    );
  }
}

// ─── Shared manual button ─────────────────────────────────────────────────────

class _ManualButton extends StatelessWidget {
  final AppStrings s;
  final VoidCallback onManual;

  const _ManualButton({required this.s, required this.onManual});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        onPressed: onManual,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textGray,
          side: BorderSide(
            color: AppColors.textGray.withValues(alpha: 0.3),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: Text(
          s.pickerUseManual,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ),
    );
  }
}
