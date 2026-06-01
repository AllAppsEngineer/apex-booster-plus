import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/core/constants/app_colors.dart';
import 'package:apex_booster_plus/data/repositories/shared_preferences_session_repository.dart';
import 'package:apex_booster_plus/data/services/focus_mode_service_impl.dart';
import 'package:apex_booster_plus/domain/services/focus_mode_service.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_background.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_badge.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_feature_card.dart';

class ConfiguracoesTab extends StatelessWidget {
  const ConfiguracoesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ApexBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ConfiguracoesHeader(),
              const SizedBox(height: 28),
              const _ConfiguracoesMainCard(),
              const SizedBox(height: 16),
              const _FocusModeCard(),
              const SizedBox(height: 12),
              const _ClearHistoryCard(),
              const SizedBox(height: 12),
              ApexFeatureCard(
                badge: 'LANG',
                title: 'Idioma do app',
                subtitle: 'Português, inglês e espanhol serão adicionados em fase futura.',
                accentColor: AppColors.apexGreen,
                delay: 100.ms,
              ),
              const SizedBox(height: 12),
              ApexFeatureCard(
                badge: 'APP',
                title: 'Experiência Apex',
                subtitle: 'Ajustes visuais e informações do app serão centralizados aqui.',
                accentColor: AppColors.cyberBlue,
                delay: 200.ms,
              ),
              const SizedBox(height: 32),
              const _ConfiguracoesCTA(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfiguracoesHeader extends StatelessWidget {
  const _ConfiguracoesHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configurações',
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
          'Organize preferências do app em um só lugar.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textGray,
              ),
        ).animate().fadeIn(delay: 100.ms, duration: 500.ms),
      ],
    );
  }
}

class _ConfiguracoesMainCard extends StatelessWidget {
  const _ConfiguracoesMainCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.energyOrange.withValues(alpha: 0.12),
            AppColors.white.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.energyOrange.withValues(alpha: 0.25),
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
              const ApexBadge(label: 'CFG', color: AppColors.energyOrange),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.energyOrange.withValues(alpha: 0.45),
                size: 14,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Preferências em preparação',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Idioma, aparência e ajustes do app serão organizados nas próximas etapas.',
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
              const ApexBadge(label: 'FOCO', color: AppColors.cyberBlue),
              _buildStatusChip(),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Modo Foco Gamer',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Reduz interrupções durante sua sessão usando o Não Perturbe do Android. Requer permissão manual. Não melhora FPS, RAM, GPU ou Ping.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textGray,
                  fontSize: 13,
                ),
          ),
          const SizedBox(height: 16),
          _buildStatusRow(context),
          if (_permState == _FocusPermissionState.required) ...[
            const SizedBox(height: 16),
            _buildPermissionButton(context),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 50.ms, duration: 600.ms)
        .slideY(begin: 0.04, end: 0, duration: 400.ms);
  }

  Widget _buildStatusChip() {
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
        granted ? 'Ativo' : 'Necessário',
        style: TextStyle(
          color: granted ? AppColors.apexGreen : AppColors.energyOrange,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatusRow(BuildContext context) {
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
            'Verificando permissão...',
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
                granted ? 'Permissão concedida' : 'Permissão necessária',
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
                granted
                    ? 'Modo Foco disponível. Será ativado ao iniciar uma sessão.'
                    : 'Conceda acesso para ativar o Modo Foco.',
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

  Widget _buildPermissionButton(BuildContext context) {
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
              const SnackBar(
                content: Text('Não foi possível abrir as configurações do Android.'),
                duration: Duration(seconds: 2),
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
        label: const Text(
          'PERMITIR MODO FOCO',
          style: TextStyle(
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Limpar histórico?',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        content: const Text(
          'Todas as sessões serão apagadas. Esta ação não pode ser desfeita.',
          style: TextStyle(
            color: AppColors.textGray,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'CANCELAR',
              style: TextStyle(
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
            child: const Text(
              'LIMPAR',
              style: TextStyle(
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
      const SnackBar(
        content: Text('Histórico apagado com sucesso.'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    const Text(
                      'Limpar histórico de sessões',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Apaga todas as sessões salvas localmente.',
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

// ─── CTA bottom ─────────────────────────────────────────────────────────────

class _ConfiguracoesCTA extends StatelessWidget {
  const _ConfiguracoesCTA();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Configurações serão ativadas em etapa futura.'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.energyOrange,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: const Text(
          'ABRIR AJUSTES',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.5,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 500.ms);
  }
}
