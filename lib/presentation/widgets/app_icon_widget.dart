import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:apex_booster_plus/core/constants/app_colors.dart';
import 'package:apex_booster_plus/data/datasources/installed_apps_datasource.dart';

class AppIconWidget extends StatefulWidget {
  final String? packageName;
  final double size;

  const AppIconWidget({
    super.key,
    required this.packageName,
    this.size = 36,
  });

  @override
  State<AppIconWidget> createState() => _AppIconWidgetState();
}

class _AppIconWidgetState extends State<AppIconWidget> {
  static final _datasource = InstalledAppsDatasource();

  Uint8List? _bytes;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(AppIconWidget old) {
    super.didUpdateWidget(old);
    if (old.packageName != widget.packageName) {
      setState(() {
        _bytes = null;
        _loaded = false;
      });
      _load();
    }
  }

  Future<void> _load() async {
    final pkg = widget.packageName;
    if (pkg == null || pkg.isEmpty) {
      if (mounted) setState(() => _loaded = true);
      return;
    }
    debugPrint('[PERF-STARTUP] icon loading started: $pkg');
    final bytes = await _datasource.getAppIcon(pkg);
    debugPrint('[PERF-STARTUP] icon loading ended: $pkg (${bytes?.length ?? 0} bytes)');
    if (mounted) {
      setState(() {
        _bytes = bytes;
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;

    if (!_loaded) {
      return _AppIconPlaceholder(size: s, loading: true);
    }
    if (_bytes == null) {
      return _AppIconPlaceholder(size: s, loading: false);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(s * 0.22),
      child: Image.memory(
        _bytes!,
        width: s,
        height: s,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _AppIconPlaceholder(size: s, loading: false),
      ),
    );
  }
}

class _AppIconPlaceholder extends StatelessWidget {
  final double size;
  final bool loading;

  const _AppIconPlaceholder({required this.size, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.cyberBlue.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(
          color: AppColors.cyberBlue.withValues(alpha: 0.20),
        ),
      ),
      child: loading
          ? Center(
              child: SizedBox(
                width: size * 0.4,
                height: size * 0.4,
                child: CircularProgressIndicator(
                  color: AppColors.cyberBlue.withValues(alpha: 0.5),
                  strokeWidth: 1.5,
                ),
              ),
            )
          : Icon(
              Icons.videogame_asset_rounded,
              color: AppColors.cyberBlue.withValues(alpha: 0.7),
              size: size * 0.5,
            ),
    );
  }
}
