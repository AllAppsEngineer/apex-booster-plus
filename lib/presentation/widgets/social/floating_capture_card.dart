import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/core/constants/app_colors.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/core/i18n/app_strings.dart';
import 'package:apex_booster_plus/data/services/screen_capture_service.dart';
import 'package:apex_booster_plus/presentation/services/floating_capture_service.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_badge.dart';

// ─── Botão Flutuante — SOCIAL-U2A-NATIVE ─────────────────────────────────────

enum _FloatPermState { loading, required, granted }

class FloatingCaptureCard extends StatefulWidget {
  const FloatingCaptureCard({super.key});

  @override
  State<FloatingCaptureCard> createState() => _FloatingCaptureCardState();
}

class _FloatingCaptureCardState extends State<FloatingCaptureCard>
    with WidgetsBindingObserver {
  _FloatPermState _permState = _FloatPermState.loading;

  // true somente quando overlay A+ E sessão de captura armada coincidem.
  bool _overlayOn = false;

  static const _optInKey = 'apex_floating_opted_in';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _syncState();
  }

  Future<void> _init() async {
    // Nunca ativa automaticamente ao abrir o app — Modo Captura da Sessão só
    // arma por toque explícito do usuário no toggle.
    await _syncState();
  }

  // Consulta o estado real (permissão, overlay, sessão armada) sem ativar
  // nada. Se overlay e sessão divergirem (ex.: sistema encerrou um dos dois
  // em background), desliga ambos em vez de tentar restaurar sozinho.
  Future<void> _syncState() async {
    final granted = await FloatingCaptureService.isPermissionGranted();
    bool showing = false;
    bool armed = false;
    if (granted) {
      showing = await FloatingCaptureService.isOverlayShowing();
      armed = await ScreenCaptureService().isSessionArmed();
    }
    if (showing != armed) {
      if (showing) {
        final prefs = await SharedPreferences.getInstance();
        await FloatingCaptureService.disable(prefs);
      }
      if (armed) {
        await ScreenCaptureService().disarmSession();
      }
      showing = false;
      armed = false;
    }
    if (!mounted) return;
    setState(() {
      _permState =
          granted ? _FloatPermState.granted : _FloatPermState.required;
      _overlayOn = showing && armed;
    });
  }

  Future<void> _onToggle(bool value) =>
      value ? _enable() : _disable();

  Future<void> _enable() async {
    if (!mounted) return;
    final s = AppStrings(languageNotifier.value);
    final prefs = await SharedPreferences.getInstance();
    final optedIn = prefs.getBool(_optInKey) ?? false;
    if (!mounted) return;

    if (!optedIn) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            s.floatingCaptureOptInTitle,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          content: Text(
            s.floatingCaptureOptInBody,
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
              child: Text(
                s.floatingCaptureEnable,
                style: const TextStyle(
                  color: AppColors.apexGreen,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await prefs.setBool(_optInKey, true);
    }

    if (!mounted) return;
    final granted = await FloatingCaptureService.isPermissionGranted();
    if (!mounted) return;

    if (!granted) {
      setState(() => _permState = _FloatPermState.required);
      await FloatingCaptureService.requestPermission();
      return;
    }

    // SOCIAL-U7A (Opção B): a sessão é print XOR vídeo — o usuário escolhe
    // antes do consentimento, pois cada MediaProjection só sustenta um único
    // VirtualDisplay durante toda a sessão.
    final mode = await _pickCaptureMode();
    if (!mounted || mode == null) return;

    // SOCIAL-U7B: no modo vídeo, a duração também é escolhida antes do
    // consentimento — cancelar a escolha de duração cancela o fluxo inteiro,
    // mesmo comportamento de cancelar a escolha de modo.
    var durationSeconds = kVideoDurationOptionsSeconds.first;
    if (mode == CaptureMode.video) {
      final chosen = await _pickVideoDuration();
      if (!mounted || chosen == null) return;
      durationSeconds = chosen;
    }

    // Arma a MediaProjection (Modo Captura da Sessão) ANTES de exibir o
    // overlay — o botão A+ só deve existir quando a sessão está armada.
    final armed = await ScreenCaptureService().armSession(
      mode: mode,
      durationSeconds: durationSeconds,
    );
    if (!mounted) return;
    if (!armed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.captureScreenDenied),
          backgroundColor: const Color(0xFF1A1A1A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final overlayOk = await FloatingCaptureService.enable(prefs);
    if (!mounted) return;
    if (!overlayOk) {
      await ScreenCaptureService().disarmSession();
      if (mounted) setState(() => _overlayOn = false);
      return;
    }

    setState(() {
      _overlayOn = true;
      _permState = _FloatPermState.granted;
    });
  }

  // SOCIAL-U7A (Opção B): print e vídeo nunca coexistem na mesma sessão
  // armada — o usuário escolhe um dos dois antes do consentimento nativo.
  Future<CaptureMode?> _pickCaptureMode() async {
    final s = AppStrings(languageNotifier.value);
    return showDialog<CaptureMode>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          s.captureModeDialogTitle,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CaptureModeOption(
              title: s.captureModeScreenshotOption,
              subtitle: s.captureModeScreenshotSubtitle,
              color: AppColors.apexGreen,
              onTap: () => Navigator.of(ctx).pop(CaptureMode.screenshot),
            ),
            const SizedBox(height: 10),
            _CaptureModeOption(
              title: s.captureModeVideoOption,
              subtitle: s.captureModeVideoSubtitle,
              color: AppColors.cyberBlue,
              onTap: () => Navigator.of(ctx).pop(CaptureMode.video),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              s.actionCancel,
              style: const TextStyle(
                color: AppColors.textGray,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SOCIAL-U7B: duração escolhida antes do consentimento, junto com o modo.
  Future<int?> _pickVideoDuration() async {
    final s = AppStrings(languageNotifier.value);
    return showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          s.videoDurationDialogTitle,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final seconds in kVideoDurationOptionsSeconds) ...[
              if (seconds != kVideoDurationOptionsSeconds.first)
                const SizedBox(height: 10),
              _DurationOption(
                label: s.videoDurationOptionLabel(seconds),
                onTap: () => Navigator.of(ctx).pop(seconds),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              s.actionCancel,
              style: const TextStyle(
                color: AppColors.textGray,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _disable() async {
    final prefs = await SharedPreferences.getInstance();
    await ScreenCaptureService().disarmSession();
    await FloatingCaptureService.disable(prefs);
    if (!mounted) return;
    setState(() => _overlayOn = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
    final isLoading = _permState == _FloatPermState.loading;
    final permRequired = _permState == _FloatPermState.required;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (_overlayOn ? AppColors.apexGreen : AppColors.textGray)
                .withValues(alpha: _overlayOn ? 0.10 : 0.06),
            AppColors.white.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (_overlayOn ? AppColors.apexGreen : AppColors.textGray)
              .withValues(alpha: _overlayOn ? 0.28 : 0.15),
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
              ApexBadge(
                label: s.captureFloatBadge,
                color: _overlayOn ? AppColors.apexGreen : AppColors.textGray,
              ),
              _buildStatusChip(s, isLoading, permRequired),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            s.captureFloatCardTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: permRequired ? AppColors.textGray : AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            permRequired
                ? s.floatingCapturePermission
                : s.captureFloatCardSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textGray.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
          ),
          if (!isLoading && !permRequired) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _overlayOn
                      ? s.captureFloatCardEnabled
                      : s.captureFloatCardDisabled,
                  style: TextStyle(
                    color: _overlayOn
                        ? AppColors.apexGreen
                        : AppColors.textGray,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Switch(
                  value: _overlayOn,
                  onChanged: _onToggle,
                  activeThumbColor: AppColors.apexGreen,
                  activeTrackColor:
                      AppColors.apexGreen.withValues(alpha: 0.28),
                  inactiveThumbColor:
                      AppColors.textGray.withValues(alpha: 0.5),
                  inactiveTrackColor:
                      AppColors.white.withValues(alpha: 0.08),
                ),
              ],
            ),
          ],
          if (!isLoading && permRequired) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => FloatingCaptureService.requestPermission(),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.apexGreen.withValues(alpha: 0.15),
                  foregroundColor: AppColors.apexGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: AppColors.apexGreen.withValues(alpha: 0.45),
                      width: 1,
                    ),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: Text(
                  s.captureFloatCardOpenSettings,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
          if (!isLoading && !permRequired) ...[
            const SizedBox(height: 12),
            const Divider(color: Color(0xFF2A2A2A), height: 1),
            const SizedBox(height: 10),
            Text(
              s.captureFloatCardFooterNote,
              style: TextStyle(
                color: AppColors.textGray.withValues(alpha: 0.7),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 170.ms, duration: 500.ms)
        .slideY(begin: 0.04, end: 0, duration: 380.ms);
  }

  Widget _buildStatusChip(
      AppStrings s, bool isLoading, bool permRequired) {
    if (isLoading) {
      return SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.textGray.withValues(alpha: 0.5),
        ),
      );
    }
    if (permRequired) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.energyOrange.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: AppColors.energyOrange.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Text(
          s.captureFloatCardPermRequired,
          style: TextStyle(
            color: AppColors.energyOrange,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (_overlayOn ? AppColors.apexGreen : AppColors.textGray)
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: (_overlayOn ? AppColors.apexGreen : AppColors.textGray)
              .withValues(alpha: 0.28),
          width: 1,
        ),
      ),
      child: Text(
        _overlayOn ? s.captureFloatCardEnabled : s.captureFloatCardDisabled,
        style: TextStyle(
          color: _overlayOn ? AppColors.apexGreen : AppColors.textGray,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Seletor de modo — SOCIAL-U7A (Opção B) ──────────────────────────────────

class _CaptureModeOption extends StatelessWidget {
  const _CaptureModeOption({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3)),
            color: color.withValues(alpha: 0.06),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textGray,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DurationOption extends StatelessWidget {
  const _DurationOption({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cyberBlue.withValues(alpha: 0.3)),
            color: AppColors.cyberBlue.withValues(alpha: 0.06),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.cyberBlue,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
