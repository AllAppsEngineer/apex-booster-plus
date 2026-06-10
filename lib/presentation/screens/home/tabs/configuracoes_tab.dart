import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/core/constants/app_colors.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/core/i18n/app_strings.dart';
import 'package:apex_booster_plus/core/i18n/language_service.dart';
import 'package:apex_booster_plus/data/repositories/shared_preferences_session_repository.dart';
import 'package:apex_booster_plus/data/services/external_url_service.dart';
import 'package:apex_booster_plus/data/services/focus_mode_service_impl.dart';
import 'package:apex_booster_plus/domain/services/focus_mode_service.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_background.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_badge.dart';
import 'package:go_router/go_router.dart';

class ConfiguracoesTab extends StatelessWidget {
  const ConfiguracoesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: languageNotifier,
      builder: (context, _) {
        return ApexBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ConfiguracoesHeader(),
                  const SizedBox(height: 28),
                  _FocusModeCard(),
                  const SizedBox(height: 12),
                  _ClearHistoryCard(),
                  const SizedBox(height: 12),
                  _LanguageCard(),
                  const SizedBox(height: 12),
                  _HonestBoosterCard(),
                  const SizedBox(height: 12),
                  _AboutCard(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _ConfiguracoesHeader extends StatelessWidget {
  const _ConfiguracoesHeader();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.settingsTitle,
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
          s.settingsSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textGray,
              ),
        ).animate().fadeIn(delay: 100.ms, duration: 500.ms),
      ],
    );
  }
}

// ─── Modo Foco Gamer ────────────────────────────────────────────────────────

enum _FocusPermissionState { loading, granted, required }

class _FocusModeCard extends StatefulWidget {
  const _FocusModeCard();

  @override
  State<_FocusModeCard> createState() => _FocusModeCardState();
}

class _FocusModeCardState extends State<_FocusModeCard>
    with WidgetsBindingObserver {
  final FocusModeService _service = FocusModeServiceImpl();
  _FocusPermissionState _permState = _FocusPermissionState.loading;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    try {
      final granted = await _service
          .isPermissionGranted()
          .timeout(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() {
        _permState = granted
            ? _FocusPermissionState.granted
            : _FocusPermissionState.required;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _permState = _FocusPermissionState.required);
    }
  }

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
            AppColors.cyberBlue.withValues(alpha: 0.10),
            AppColors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cyberBlue.withValues(alpha: 0.28),
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
              ApexBadge(label: s.focusBadge, color: AppColors.cyberBlue),
              _buildStatusChip(s),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            s.focusTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            s.focusDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textGray,
                  fontSize: 13,
                ),
          ),
          const SizedBox(height: 16),
          _buildStatusRow(context, s),
          if (_permState == _FocusPermissionState.required) ...[
            const SizedBox(height: 16),
            _buildPermissionButton(context, s),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 50.ms, duration: 600.ms)
        .slideY(begin: 0.04, end: 0, duration: 400.ms);
  }

  Widget _buildStatusChip(AppStrings s) {
    if (_permState == _FocusPermissionState.loading) {
      return SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.cyberBlue.withValues(alpha: 0.6),
        ),
      );
    }
    final granted = _permState == _FocusPermissionState.granted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (granted ? AppColors.apexGreen : AppColors.energyOrange)
            .withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: (granted ? AppColors.apexGreen : AppColors.energyOrange)
              .withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Text(
        granted ? s.focusStatusActive : s.focusStatusRequired,
        style: TextStyle(
          color: granted ? AppColors.apexGreen : AppColors.energyOrange,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatusRow(BuildContext context, AppStrings s) {
    if (_permState == _FocusPermissionState.loading) {
      return Row(
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: AppColors.textGray.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            s.focusChecking,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textGray,
                  fontSize: 12,
                ),
          ),
        ],
      );
    }

    final granted = _permState == _FocusPermissionState.granted;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          granted
              ? Icons.check_circle_outline_rounded
              : Icons.lock_outline_rounded,
          size: 16,
          color: granted ? AppColors.apexGreen : AppColors.energyOrange,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                granted ? s.focusGrantedLabel : s.focusRequiredLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: granted
                          ? AppColors.apexGreen
                          : AppColors.energyOrange,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                granted ? s.focusGrantedDesc : s.focusRequiredDesc,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textGray,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionButton(BuildContext context, AppStrings s) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton.icon(
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          try {
            await _service.openSettings();
          } catch (_) {
            if (!mounted) return;
            messenger.showSnackBar(
              SnackBar(
                content: Text(s.focusOpenSettingsError),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyberBlue.withValues(alpha: 0.18),
          foregroundColor: AppColors.cyberBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: AppColors.cyberBlue.withValues(alpha: 0.45),
              width: 1,
            ),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.open_in_new_rounded, size: 16),
        label: Text(
          s.focusAllowButton,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

// ─── Limpar Histórico ────────────────────────────────────────────────────────

class _ClearHistoryCard extends StatelessWidget {
  const _ClearHistoryCard();

  Future<void> _onTap(BuildContext context) async {
    final s = AppStrings(languageNotifier.value);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          s.clearHistoryDialogTitle,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        content: Text(
          s.clearHistoryDialogContent,
          style: const TextStyle(
            color: AppColors.textGray,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              s.actionCancel,
              style: const TextStyle(
                color: AppColors.textGray,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: Text(
              s.clearHistoryActionClear,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final repo = SharedPreferencesSessionRepository(prefs);
    await repo.clearAll();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.clearHistorySuccess),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _onTap(context),
        borderRadius: BorderRadius.circular(12),
        splashColor: const Color(0xFFEF4444).withValues(alpha: 0.08),
        highlightColor: const Color(0xFFEF4444).withValues(alpha: 0.04),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFEF4444).withValues(alpha: 0.08),
                AppColors.white.withValues(alpha: 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFEF4444).withValues(alpha: 0.22),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete_sweep_outlined,
                  color: Color(0xFFEF4444),
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.clearHistoryTitle,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.clearHistorySubtitle,
                      style: TextStyle(
                        color: AppColors.textGray.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFFEF4444).withValues(alpha: 0.45),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 80.ms, duration: 500.ms)
        .slideY(begin: 0.04, end: 0, duration: 380.ms);
  }
}

// ─── Idioma ──────────────────────────────────────────────────────────────────

class _LanguageCard extends StatelessWidget {
  const _LanguageCard();

  Future<void> _onTap(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final service = LanguageService(prefs);

    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _LanguageSheet(service: service),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
    final current = languageNotifier.value;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _onTap(context),
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.cyberBlue.withValues(alpha: 0.08),
        highlightColor: AppColors.cyberBlue.withValues(alpha: 0.04),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.cyberBlue.withValues(alpha: 0.08),
                AppColors.white.withValues(alpha: 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.cyberBlue.withValues(alpha: 0.22),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.cyberBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.language_rounded,
                  color: AppColors.cyberBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.languageTitle,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      current.label,
                      style: TextStyle(
                        color: AppColors.cyberBlue.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.cyberBlue.withValues(alpha: 0.45),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 120.ms, duration: 500.ms)
        .slideY(begin: 0.04, end: 0, duration: 380.ms);
  }
}

class _LanguageSheet extends StatelessWidget {
  final LanguageService service;

  const _LanguageSheet({required this.service});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
    final current = languageNotifier.value;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              s.languageSheetTitle,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const Divider(color: Color(0xFF2A2A2A), height: 1),
          for (final lang in AppLanguage.values)
            _LanguageOption(lang: lang, current: current, service: service),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final AppLanguage lang;
  final AppLanguage current;
  final LanguageService service;

  const _LanguageOption({
    required this.lang,
    required this.current,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = lang == current;

    return InkWell(
      onTap: () async {
        await service.save(lang);
        languageNotifier.value = lang;
        if (context.mounted) Navigator.of(context).pop();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                lang.nativeLabel,
                style: TextStyle(
                  color:
                      isSelected ? AppColors.cyberBlue : AppColors.white,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 15,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                color: AppColors.cyberBlue,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Sobre o app ─────────────────────────────────────────────────────────────

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  Future<void> _openPrivacyPolicy(BuildContext context, AppStrings s) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ExternalUrlService().openUrl(s.privacyPolicyUrl);
    } on PlatformException {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(s.aboutPrivacyOpenError),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

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
            AppColors.apexGreen.withValues(alpha: 0.08),
            AppColors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.apexGreen.withValues(alpha: 0.22),
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
              ApexBadge(label: s.aboutBadge, color: AppColors.apexGreen),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.apexGreen.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.apexGreen.withValues(alpha: 0.28),
                    width: 1,
                  ),
                ),
                child: Text(
                  s.appVersion,
                  style: const TextStyle(
                    color: AppColors.apexGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Apex Booster+',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            s.appTagline,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.apexGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.lock_open_rounded,
                size: 14,
                color: AppColors.textGray.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                s.appModel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textGray,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: AppColors.textGray.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  s.appDisclaimer,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textGray.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF2A2A2A), height: 1),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _openPrivacyPolicy(context, s),
              child: Row(
                children: [
                  Icon(
                    Icons.privacy_tip_outlined,
                    size: 14,
                    color: AppColors.textGray.withValues(alpha: 0.55),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      s.aboutPrivacyLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textGray,
                            fontSize: 12,
                          ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.cyberBlue.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: AppColors.cyberBlue.withValues(alpha: 0.28),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      s.aboutPrivacyAction,
                      style: const TextStyle(
                        color: AppColors.cyberBlue,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .slideY(begin: 0.04, end: 0, duration: 400.ms);
  }
}

// ─── Modo Booster Honesto ────────────────────────────────────────────────────

class _HonestBoosterCard extends StatelessWidget {
  const _HonestBoosterCard();

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
            AppColors.cyberBlue.withValues(alpha: 0.08),
            AppColors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cyberBlue.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ApexBadge(label: s.honestBoosterCardBadge, color: AppColors.cyberBlue),
          const SizedBox(height: 14),
          Text(
            s.honestBoosterCardTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            s.honestBoosterCardSubtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textGray,
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF2A2A2A), height: 1),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => context.push('/honest-booster-mode'),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 14,
                      color: AppColors.cyberBlue.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        s.honestBoosterCardAction,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textGray,
                              fontSize: 12,
                            ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: AppColors.cyberBlue.withValues(alpha: 0.55),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 120.ms, duration: 500.ms)
        .slideY(begin: 0.04, end: 0, duration: 380.ms);
  }
}
