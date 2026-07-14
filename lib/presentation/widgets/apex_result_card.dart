import 'package:flutter/material.dart';
import '../../core/accessibility/low_distraction_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/i18n/app_language.dart';
import '../../core/i18n/app_strings.dart';
import '../../domain/entities/gfx_profile.dart';
import '../../domain/entities/session_record.dart';
import 'apex_badge.dart';
import 'apex_pulse.dart';
import 'apex_ring.dart';
import 'app_icon_widget.dart';
import 'status_chip.dart';

/// Card premium de fechamento pós-sessão (PREMIUM-U3A).
///
/// Resume localmente uma [SessionRecord] já registrada: nome do jogo, status
/// de abertura, perfil GFX aplicado, foco quando disponível e as métricas
/// salvas no snapshot daquela sessão. Nunca recalcula ou inventa valores —
/// quando o snapshot não tinha métricas, mostra texto honesto em vez de zero.
class ApexResultCard extends StatelessWidget {
  final SessionRecord session;
  final VoidCallback? onReopenGame;
  final VoidCallback? onCreateSocialCard;
  final VoidCallback? onClose;

  const ApexResultCard({
    super.key,
    required this.session,
    this.onReopenGame,
    this.onCreateSocialCard,
    this.onClose,
  });

  ({String label, Color color, IconData icon}) _statusInfo(AppStrings s) {
    return switch (session.launchStatus) {
      'success' => (
          label: s.historyStatusSuccess,
          color: AppColors.apexGreen,
          icon: Icons.check_circle_outline,
        ),
      'attempted' => (
          label: s.historyStatusAttempted,
          color: AppColors.energyOrange,
          icon: Icons.warning_amber,
        ),
      'failed' => (
          label: s.historyStatusFailed,
          color: Colors.redAccent,
          icon: Icons.cancel_outlined,
        ),
      _ => (
          label: session.launchStatus,
          color: AppColors.textGray,
          icon: Icons.circle_outlined,
        ),
    };
  }

  String? _focusLabel(AppStrings s) {
    if (!session.focusModeAttempted) return null;
    return switch (session.focusModeResult) {
      'enabled'      => s.historyFocusEnabled,
      'noPermission' => s.historyFocusNoPermission,
      'error'        => s.historyFocusError,
      _              => null,
    };
  }

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(d.day)}/${pad(d.month)}/${d.year}  ${pad(d.hour)}:${pad(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
    final lowDistraction = lowDistractionNotifier.value;
    final status = _statusInfo(s);
    final focusLabel = _focusLabel(s);
    final resolvedProfile = GfxProfile.fromLabel(session.gfxProfile);
    final hasRam =
        session.memoryAvailableMb != null && session.memoryTotalMb != null;
    final hasLatency = session.apexLatencyMs != null;
    final hasMetrics = session.metricsAvailable && (hasRam || hasLatency);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111318),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status.color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ApexBadge(label: s.resultCardHeaderLabel, color: status.color),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ApexPulse(
                active: session.launchStatus == 'success',
                reducedMotion: lowDistraction,
                color: status.color,
                size: 64,
                child: ApexRing(
                  progress: 1,
                  size: 52,
                  reducedMotion: lowDistraction,
                  color: status.color,
                  child: AppIconWidget(
                    packageName: session.packageName,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.gameName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    StatusChip(
                      label: status.label,
                      color: status.color,
                      icon: status.icon,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${s.resultCardTimestampPrefix} ${_formatDate(session.launchedAt)}',
            style: const TextStyle(color: AppColors.textGray, fontSize: 12),
          ),
          const SizedBox(height: 20),
          Text(
            s.resultCardSectionPreparation,
            style: const TextStyle(
              color: AppColors.textGray,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (resolvedProfile != null)
                StatusChip(
                  label:
                      '${s.resultCardProfileLabel}: ${s.gfxProfileLabel(resolvedProfile)}',
                  color: resolvedProfile.accentColor,
                  icon: resolvedProfile.icon,
                ),
              if (focusLabel != null)
                StatusChip(
                  label: focusLabel,
                  color: AppColors.cyberBlue,
                  icon: Icons.do_not_disturb_on,
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            s.detailMetricsTitle,
            style: const TextStyle(
              color: AppColors.textGray,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          if (!hasMetrics)
            Text(
              s.resultCardMetricsUnavailable,
              style: const TextStyle(color: AppColors.textGray, fontSize: 13),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (hasRam)
                  StatusChip(
                    label: session.memoryState != null
                        ? s.historyRamChip(
                            (session.memoryAvailableMb! / 1024)
                                .toStringAsFixed(1),
                            session.memoryState!,
                          )
                        : '${(session.memoryAvailableMb! / 1024).toStringAsFixed(1)} GB / ${(session.memoryTotalMb! / 1024).toStringAsFixed(1)} GB',
                    color: AppColors.cyberBlue,
                    icon: Icons.memory,
                  ),
                if (hasLatency)
                  StatusChip(
                    label: '${session.apexLatencyMs} ms',
                    color: AppColors.cyberBlue,
                    icon: Icons.network_check,
                  ),
              ],
            ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (onReopenGame != null)
                ElevatedButton(
                  onPressed: onReopenGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.apexGreen,
                    foregroundColor: Colors.black,
                  ),
                  child: Text(s.resultCardCtaReopen),
                ),
              if (onCreateSocialCard != null)
                OutlinedButton(
                  onPressed: onCreateSocialCard,
                  child: Text(s.resultCardCtaShare),
                ),
              if (onClose != null)
                TextButton(
                  onPressed: onClose,
                  child: Text(s.actionClose),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
