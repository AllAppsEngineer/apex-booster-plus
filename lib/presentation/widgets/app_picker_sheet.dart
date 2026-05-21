import 'package:flutter/material.dart';
import 'package:apex_booster_plus/core/constants/app_colors.dart';
import 'package:apex_booster_plus/data/datasources/installed_apps_datasource.dart';
import 'package:apex_booster_plus/domain/entities/installed_app.dart';
import 'package:apex_booster_plus/presentation/widgets/app_icon_widget.dart';

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
        _filtered = List.of(apps);
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
      _filtered = q.isEmpty
          ? List.of(_allApps)
          : _allApps
              .where(
                (a) =>
                    a.appName.toLowerCase().contains(q) ||
                    a.packageName.toLowerCase().contains(q),
              )
              .toList();
    });
  }

  void _select(InstalledApp app) =>
      Navigator.of(context).pop(AppPickerSelected(app));

  void _useManual() =>
      Navigator.of(context).pop(const AppPickerUseManual());

  @override
  Widget build(BuildContext context) {
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
            _buildHeader(context),
            if (!_loading && !_failed && _allApps.isNotEmpty) _buildSearch(),
            Divider(height: 1, color: AppColors.white.withValues(alpha: 0.07)),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
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

  Widget _buildHeader(BuildContext context) {
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
                'Escolher app instalado',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Selecione o jogo instalado no seu dispositivo.',
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

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: AppColors.white, fontSize: 14),
        cursorColor: AppColors.cyberBlue,
        decoration: InputDecoration(
          hintText: 'Buscar por nome ou pacote',
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
                  tooltip: 'Limpar busca',
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

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.cyberBlue,
          strokeWidth: 2,
        ),
      );
    }
    if (_failed) {
      return _PickerErrorState(onManual: _useManual, onRetry: _retry);
    }
    if (_filtered.isEmpty) {
      final query = _searchController.text.trim();
      if (query.isNotEmpty) {
        return _EmptySearchState(query: query, onManual: _useManual);
      }
      return _EmptyAppsState(onManual: _useManual);
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
  final String query;
  final VoidCallback onManual;

  const _EmptySearchState({required this.query, required this.onManual});

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
            'Nenhum resultado para "$query".',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Tente outro nome ou use a entrada manual.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textGray,
                  fontSize: 12,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _ManualButton(onManual: onManual),
        ],
      ),
    );
  }
}

// ─── Empty apps state ─────────────────────────────────────────────────────────

class _EmptyAppsState extends StatelessWidget {
  final VoidCallback onManual;

  const _EmptyAppsState({required this.onManual});

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
            'Nenhum app instalado encontrado.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Use a entrada manual para adicionar o jogo.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textGray,
                  fontSize: 12,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _ManualButton(onManual: onManual),
        ],
      ),
    );
  }
}

// ─── Error state ──────────────────────────────────────────────────────────────

class _PickerErrorState extends StatelessWidget {
  final VoidCallback onManual;
  final VoidCallback onRetry;

  const _PickerErrorState({required this.onManual, required this.onRetry});

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
            'Não foi possível carregar os apps instalados.',
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
              child: const Text(
                'Tentar novamente',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ManualButton(onManual: onManual),
        ],
      ),
    );
  }
}

// ─── Shared manual button ─────────────────────────────────────────────────────

class _ManualButton extends StatelessWidget {
  final VoidCallback onManual;

  const _ManualButton({required this.onManual});

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
        child: const Text(
          'Usar entrada manual',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ),
    );
  }
}
