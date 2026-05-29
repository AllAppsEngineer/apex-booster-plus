import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/core/constants/app_colors.dart';
import 'package:apex_booster_plus/data/repositories/shared_preferences_session_repository.dart';
import 'package:apex_booster_plus/domain/entities/session_record.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_background.dart';

class HistoricoTab extends StatefulWidget {
  const HistoricoTab({super.key});

  @override
  State<HistoricoTab> createState() => _HistoricoTabState();
}

class _HistoricoTabState extends State<HistoricoTab>
    with WidgetsBindingObserver {
  bool _isLoading = true;
  List<SessionRecord> _sessions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSessions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadSessions();
    }
  }

  Future<void> _loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final repo = SharedPreferencesSessionRepository(prefs);
    final sessions = await repo.getSessions();
    if (mounted) {
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ApexBackground(
      child: SafeArea(
        child: _isLoading
            ? const _LoadingState()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HistoricoHeader(sessionCount: _sessions.length),
                  Expanded(
                    child: _sessions.isEmpty
                        ? const _EmptyState()
                        : _SessionList(sessions: _sessions),
                  ),
                ],
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppColors.apexGreen,
            strokeWidth: 2,
          ),
          const SizedBox(height: 16),
          const Text(
            'Carregando sessões...',
            style: TextStyle(
              color: AppColors.textGray,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _HistoricoHeader extends StatelessWidget {
  final int sessionCount;

  const _HistoricoHeader({required this.sessionCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HISTÓRICO',
            style: TextStyle(
              color: AppColors.textGray,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Sessões registradas',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: -0.08, end: 0, duration: 400.ms),
              ),
              if (sessionCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cyberBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.cyberBlue.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '$sessionCount',
                    style: const TextStyle(
                      color: AppColors.cyberBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Registro local das suas sessões.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textGray,
                ),
          ).animate().fadeIn(delay: 100.ms, duration: 500.ms),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_outlined,
              size: 48,
              color: AppColors.textGray.withValues(alpha: 0.5),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fade(
                  begin: 0.4,
                  end: 0.75,
                  duration: 1400.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: 20),
            Text(
              'Nenhuma sessão ainda.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Abra um jogo pela Biblioteca para começar seu histórico.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textGray,
                    fontSize: 13,
                  ),
            ),
          ],
        ).animate().fadeIn(duration: 500.ms),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _SessionList extends StatelessWidget {
  final List<SessionRecord> sessions;

  const _SessionList({required this.sessions});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      itemCount: sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _SessionCard(
          session: sessions[index],
          index: index,
          delay: (index * 60).ms,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------

class _SessionCard extends StatelessWidget {
  final SessionRecord session;
  final int index;
  final Duration delay;

  const _SessionCard({
    required this.session,
    required this.index,
    required this.delay,
  });

  ({String label, Color color, IconData icon}) _statusInfo() {
    return switch (session.launchStatus) {
      'success' => (
          label: 'Abertura registrada',
          color: AppColors.apexGreen,
          icon: Icons.check_circle_outline,
        ),
      'attempted' => (
          label: 'Tentativa registrada',
          color: AppColors.energyOrange,
          icon: Icons.warning_amber,
        ),
      'failed' => (
          label: 'Falha ao abrir',
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

  String? _focusModeLabel() {
    if (!session.focusModeAttempted) return null;
    return switch (session.focusModeResult) {
      'enabled' => 'Foco ativo',
      'noPermission' => 'Sem permissão de foco',
      'error' => 'Erro no foco',
      _ => null,
    };
  }

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(d.day)}/${pad(d.month)}/${d.year}  ${pad(d.hour)}:${pad(d.minute)}';
  }

  String _formatRam() {
    final avail = session.memoryAvailableMb!;
    final total = session.memoryTotalMb!;
    final availGb = (avail / 1024).toStringAsFixed(1);
    final totalGb = (total / 1024).toStringAsFixed(1);
    final state = session.memoryState;
    if (state != null && state.isNotEmpty) {
      return '$availGb GB livre • $state';
    }
    return '$availGb GB / $totalGb GB';
  }

  @override
  Widget build(BuildContext context) {
    final status = _statusInfo();
    final focusLabel = _focusModeLabel();
    final hasRam =
        session.memoryAvailableMb != null && session.memoryTotalMb != null;
    final hasLatency = session.apexLatencyMs != null;
    final hasGfxProfile = session.gfxProfile != null;
    final hasExtras = hasRam || hasLatency || focusLabel != null || hasGfxProfile;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            status.color.withValues(alpha: 0.08),
            AppColors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status.color.withValues(alpha: 0.20),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '#${(index + 1).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Text(
                _formatDate(session.launchedAt),
                style: const TextStyle(
                  color: AppColors.textGray,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            session.gameName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          _StatusBadge(
            label: status.label,
            color: status.color,
            icon: status.icon,
          ),
          if (hasExtras) ...[
            const SizedBox(height: 12),
            Divider(
              color: AppColors.white.withValues(alpha: 0.08),
              height: 1,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (hasRam)
                  _MetricChip(
                    icon: Icons.memory,
                    label: _formatRam(),
                  ),
                if (hasLatency)
                  _MetricChip(
                    icon: Icons.network_check,
                    label: '${session.apexLatencyMs} ms',
                  ),
                if (focusLabel != null)
                  _MetricChip(
                    icon: Icons.do_not_disturb_on,
                    label: focusLabel,
                  ),
                if (hasGfxProfile)
                  _MetricChip(
                    icon: Icons.tune,
                    label: session.gfxProfile!,
                  ),
              ],
            ),
          ],
        ],
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.04, end: 0, duration: 300.ms);
  }
}

// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.30),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textGray),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textGray,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
